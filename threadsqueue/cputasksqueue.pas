unit CPUTasksQueue;

{$mode objfpc}{$H+}
{$ASSERTIONS ON}
interface

uses
  Classes{,SysUtils},
  MTPCPU{for GetSystemThreadCount from package multithreadprocslaz, get process affinity},
  WaitingThread;
type
PExecuteInThreadParametrs=^TExecuteInThreadParametrs;

TTaskNotifyCallBackToObj = Procedure(ATask:PExecuteInThreadParametrs; AData : Pointer)of object;
TTaskNotifyCallBack = Procedure(ATask:PExecuteInThreadParametrs; AData : Pointer);
TThreadExecuteCallbackToObj=procedure(AData : Pointer) of object;

TExecuteInThreadParametrs = record
 UserData:Pointer;//user set data
 RunnedThread:Tthread;//service info, may use to set priority
 case Obj:boolean of //service info
 false:(DataHandlerMethod:TThreadExecuteCallback;//user set method
        TaskCallBack:TTaskNotifyCallBack);//user set method to be notified
 true:(
       DataHandlerMethodToObj:TThreadExecuteCallbackToObj;//user set method
       TaskCallBackToObj:TTaskNotifyCallBackToObj//user set method of object to be notified
       );
end;




function BuildCPUTask(ADataHandlerMethod:TThreadExecuteCallbackToObj;AData:Pointer;
                 ATaskCallBack:TTaskNotifyCallBackToObj):PExecuteInThreadParametrs;overload;
function BuildCPUTask(ADataHandlerMethod:TThreadExecuteCallback;AData:Pointer;
                 ATaskCallBack:TTaskNotifyCallBack):PExecuteInThreadParametrs;overload;

function AddCPUTask(ADataHandlerMethod:TThreadExecuteCallback;
                    AData:Pointer;
                    ATaskCallBack:TTaskNotifyCallBack):PExecuteInThreadParametrs;overload;
function AddCPUTask(ADataHandlerMethod:TThreadExecuteCallbackToObj;
                    AData:Pointer;
                    ATaskCallBack:TTaskNotifyCallBackToObj):PExecuteInThreadParametrs;overload;
function AddCPUTask(ATask:PExecuteInThreadParametrs):boolean;overload;

function CPUTaskIsRunned(ATask:PExecuteInThreadParametrs):boolean;
procedure WaitForTask(ATask:PExecuteInThreadParametrs);
procedure ManualSetCPUThreadsLimit(NewLimit:word);

procedure AutoLimitBackgroundCPUThreadsCount;

function GetCPUThreadsCount:word;
function GetCurrentCPUThreadsLimit:word;

procedure CheckQueue;



var RunnedTasksList,TaskListQueue:TList;
  CPUThreadsList:TWaitingThreadlist;
  HDDThreadsList:TWaitingThreadlist;
  {AllCPUTasksEndedEventToObj:TThreadMethod;
  AllCPUTasksEndedEvent:TSynchronizeProcVar;}

implementation

var EndingWorkCPUThreadsList:TWaitingThreadlist;
DetectedThreadsCountLimit:word;
ManualThreadsCountLimit:word=0;

procedure TthreadEndExecution(Sender : TObject; Done :Pointer);forward;
function StandartCreateWaitingThread:TWaitingThread;forward;

procedure ThreadFalldown(Sender : TObject; AData : Pointer);
var index:integer;
EndWorkThread:TWaitingThread;
begin
EndWorkThread:=TWaitingThread(Sender);
index:=CPUThreadsList.IndexOf(EndWorkThread);
if index>=0 then
  CPUThreadsList.Items[index]:=StandartCreateWaitingThread;
if (EndWorkThread.ExecuteMethod<>nil) then
  TthreadEndExecution(Sender,AData);
end;

function StandartCreateWaitingThread:TWaitingThread;
begin
result:=TWaitingThread.Create;
result.OnTerminateMethod:=@ThreadFalldown;
end;

procedure ThreadOnTerminateCallBack(Sender : TObject; AData : Pointer);
begin
assert(AData=nil,'thread not end task?');
EndingWorkCPUThreadsList.Remove(Sender);
end;

procedure Standart_WaitingThreadEndWork(EndThr:TWaitingThread);
begin
EndThr.OnTerminateMethod:=@ThreadOnTerminateCallBack;
EndThr.EndWork;
end;

procedure SetThreadsCount(Newcount:word);
begin
if Newcount=CPUThreadsList.Count then exit;

if Newcount<CPUThreadsList.Count then begin
  repeat
    EndingWorkCPUThreadsList.Add(CPUThreadsList.Last);
    Standart_WaitingThreadEndWork(CPUThreadsList.Last);
    CPUThreadsList.Delete(CPUThreadsList.Count-1);
  until (Newcount=CPUThreadsList.Count);
end else begin
  repeat
    CPUThreadsList.Add(StandartCreateWaitingThread);
  until (Newcount=CPUThreadsList.Count);
end;
end;

function GetCurrentCPUThreadsLimit:word;
begin
if ManualThreadsCountLimit>0 then
  result:=ManualThreadsCountLimit
else
  result:=DetectedThreadsCountLimit
;
end;

procedure UpdateThreadCountWithLimit;
var limit,count:word;
begin
count:=CPUThreadsList.Count;
limit:=GetCurrentCPUThreadsLimit;
if count=limit then exit;
if count>limit then begin
  SetThreadsCount(limit);
end else begin
  CheckQueue;
end;
end;

procedure AutoLimitBackgroundCPUThreadsCount;
begin
DetectedThreadsCountLimit:=GetSystemThreadCount;//detect affinity
if DetectedThreadsCountLimit<1 then DetectedThreadsCountLimit:=1;//allow atleast one background thread
ManualThreadsCountLimit:=0;
UpdateThreadCountWithLimit;
end;

procedure ManualSetCPUThreadsLimit(NewLimit:word);
begin
ManualThreadsCountLimit:=NewLimit;
UpdateThreadCountWithLimit;
end;

function GetCPUThreadsCount:word;
begin
result:=CPUThreadsList.Count;
end;

function GetFreeCPUThread:TWaitingThread;
var n,RunnedCount,ThreadsCount:word;//as SetBackgroundCPUThreadsCount parametr
begin
result:=nil;
RunnedCount:=RunnedTasksList.Count;
ThreadsCount:=CPUThreadsList.Count;
if ThreadsCount<=RunnedCount then
  exit;

{n:=RunnedCount;
while(result=nil)and(n<ThreadsCount)do begin
if CPUThreadsList.Items[n].ReadyToExecute then
  result:=CPUThreadsList.Items[n];
n:=n+1;
end;}

n:=0;
while(result=nil)and(n<ThreadsCount)do begin
if CPUThreadsList.Items[n].ReadyToExecute then
  result:=CPUThreadsList.Items[n];
n:=n+1;
end;
end;

function LeaveList(item:pointer;List:TList):boolean;
begin
result:=List.Remove(item)>-1;
end;

procedure ExecuteCallback(ATask : Pointer);//сюда приходит PExecuteInThreadParametrs, см. RunTask и TthreadEnd
var Task:PExecuteInThreadParametrs;
begin
Task:=ATask;
if Task^.Obj then Task^.DataHandlerMethodToObj(Task^.UserData)
else Task^.DataHandlerMethod(Task^.UserData);
end;

procedure NotifyTaskExecuted(EndedTask:PExecuteInThreadParametrs);
begin
if (EndedTask^.Obj)then begin
      if assigned(EndedTask^.TaskCallBackToObj) then
        EndedTask^.TaskCallBackToObj(EndedTask,EndedTask^.UserData);
    end else begin
      if (assigned(EndedTask^.TaskCallBack))then
        EndedTask^.TaskCallBack(EndedTask,EndedTask^.UserData);
    end;
end;

procedure TthreadEndExecution(Sender : TObject; Done :Pointer);
var EndedTask:PExecuteInThreadParametrs;
EndWorkThread:TWaitingThread;
begin
assert(Done<>nil);
if Sender<>nil then begin
EndWorkThread:=TWaitingThread(Sender);
EndWorkThread.Data:=nil;
EndWorkThread.ExecuteMethod:=nil;//mark Thread as ReadyToExecute
end;

EndedTask:=Done;
LeaveList(EndedTask,RunnedTasksList);
NotifyTaskExecuted(EndedTask);
dispose(EndedTask);
CheckQueue;

{//call notifier for all task ended
if (RunnedTasksList.Count=0)and(TaskListQueue.Count=0)then begin
  if assigned(AllCPUTasksEndedEventToObj)then
    AllCPUTasksEndedEventToObj();
  if assigned(AllCPUTasksEndedEvent)then
    AllCPUTasksEndedEvent();
end;
}
end;

function TaskDataHandlerMethodIsNil(Task:PExecuteInThreadParametrs):boolean;
begin
if Task^.Obj then
  result:=TMethod(Task^.DataHandlerMethodToObj).Data=nil
else
  result:=Task^.DataHandlerMethod=nil;
end;

function RunTaskInThread(WorkerThread:TWaitingThread;ATask:PExecuteInThreadParametrs):boolean;
begin
assert(WorkerThread.Data=nil);
result:=WorkerThread.ExecuteInThread(@ExecuteCallback,ATask,@TthreadEndExecution);
if result then ATask^.RunnedThread:=WorkerThread;
end;

{function RunFirstTaskInThread(WorkerThread:TWaitingThread):boolean;
var Task:PExecuteInThreadParametrs;
begin
Task:=TaskListQueue.Items[0];
//здесь подмена задания! см, ExecuteCallback и TthreadEndExecution

if TaskDataHandlerMethodIsNil(Task)then begin
  TthreadEndExecution(nil,Task);
  result:=true;
end else begin// run in thread
  result:=WorkerThread.ExecuteInThread(@ExecuteCallback,ATask,@TthreadEndExecution);
  if result then begin
    Task^.RunnedThread:=WorkerThread;
    RunnedTasksList.Add(Task);
  end;
end;
if result then begin
      Task^.RunnedThread:=WorkerThread;
    TaskListQueue.Delete(0);
//    LeaveList(Task,TaskListQueue);
    RunnedTasksList.Add(Task);
  end;
end;}

function CPUThreadLimitNotReached:boolean;
begin
result:=CPUThreadsList.Count<GetCurrentCPUThreadsLimit;
end;

function StartTaskThreaded(Task:PExecuteInThreadParametrs):boolean;
var WorkerThread:TWaitingThread;
begin
WorkerThread:=GetFreeCPUThread;
if(WorkerThread=nil)and CPUThreadLimitNotReached then begin
  WorkerThread:=StandartCreateWaitingThread;
  CPUThreadsList.Add(WorkerThread);
end;
result:=(WorkerThread<>nil)and RunTaskInThread(WorkerThread,Task);
end;

Function RunFirstTask:boolean;
var Task:PExecuteInThreadParametrs;
begin
Task:=TaskListQueue.Items[0];
if TaskDataHandlerMethodIsNil(Task)then begin
  TaskListQueue.Delete(0);
  TthreadEndExecution(nil,Task);
  result:=true;
end else begin
  result:=StartTaskThreaded(Task);
  if result then begin
    TaskListQueue.Delete(0);
    RunnedTasksList.Add(Task);
  end;
end;
end;

procedure CheckQueue;
var //WorkerThread:TWaitingThread;
{CanNotRun,}Runed:boolean;
begin
{Here can add analyse of waiting tasks: if TaskListQueue.Count>1, this mean that all thread busy.
 And if limit of thread not reached, we can add thread to work.
 If it will implement, then need to realise(?) threads count decrease(?) }
repeat
  Runed:=(TaskListQueue.Count>0)and RunFirstTask;
until not Runed;
{  if (TaskListQueue.Count>0) then begin
    WorkerThread:=nil;
    if RunnedTasksList.Count=CPUThreadsList.Count then begin //no free CPUThread available
      if CPUThreadLimitNotReached then begin
        WorkerThread:=StandartCreateWaitingThread;
        CPUThreadsList.Add(WorkerThread);
      end;
    end else
      WorkerThread:=GetFreeCPUThread;

    CanNotRun:=(WorkerThread=nil)or(not RunFirstTaskInThread(WorkerThread));
  end else
    CanNotRun:=true;
until CanNotRun;}
end;

function AddCPUTask(ADataHandlerMethod:TThreadExecuteCallback;AData:Pointer;ATaskCallBack:TTaskNotifyCallBack):PExecuteInThreadParametrs;overload;
var NewTaskParameters:PExecuteInThreadParametrs;
begin
NewTaskParameters:=BuildCPUTask(ADataHandlerMethod,AData,ATaskCallBack);
TaskListQueue.Add(NewTaskParameters);
result:=NewTaskParameters;
CheckQueue;
end;

function AddCPUTask(ADataHandlerMethod:TThreadExecuteCallbackToObj;AData:Pointer;
                 ATaskCallBack:TTaskNotifyCallBackToObj):PExecuteInThreadParametrs;overload;
var NewTaskParameters:PExecuteInThreadParametrs;
begin
NewTaskParameters:=BuildCPUTask(ADataHandlerMethod,AData,ATaskCallBack);
TaskListQueue.Add(NewTaskParameters);
result:=NewTaskParameters;
CheckQueue;
end;

function AddCPUTask(ATask:PExecuteInThreadParametrs):boolean;overload;
begin
result:=ATask<>nil;
assert(result);
TaskListQueue.Add(ATask);
CheckQueue;
end;

function CPUTaskIsRunned(ATask:PExecuteInThreadParametrs):boolean;
begin
  result:=(RunnedTasksList.IndexOf(ATask)>-1)or(ATask^.RunnedThread<>nil);
end;

procedure WaitForTask(ATask:PExecuteInThreadParametrs);
var TaskIndex:integer;
begin
if (ATask^.RunnedThread=nil) then begin
  TaskIndex:=TaskListQueue.IndexOf(ATask);
  if (TaskIndex<0)then exit;
  repeat
    repeat
      CheckSynchronize(500);
    until not ((TaskListQueue.Count>TaskIndex)and(TaskListQueue.Items[TaskIndex]=ATask));
    TaskIndex:=TaskListQueue.IndexOf(ATask);
  until (TaskIndex<0);
end;

if (ATask^.RunnedThread=nil)then exit;
TWaitingThread(ATask^.RunnedThread).WaitForWorkDone;
{TaskIndex:=RunnedTasksList.IndexOf(ATask);
if (TaskIndex<0)then exit;
  repeat
    repeat
      CheckSynchronize(500);
    until not ((RunnedTasksList.Count>TaskIndex)and(RunnedTasksList.Items[TaskIndex]=ATask));
    TaskIndex:=RunnedTasksList.IndexOf(ATask);
  until (TaskIndex<0);}
end;

function BuildCPUTask(ADataHandlerMethod:TThreadExecuteCallbackToObj;AData:Pointer;
                 ATaskCallBack:TTaskNotifyCallBackToObj):PExecuteInThreadParametrs;overload;
var NewTaskParameters:PExecuteInThreadParametrs;
begin
//if ADataHandlerMethod=nil then see RunFirstTaskInThread;
new(NewTaskParameters);
with NewTaskParameters^ do begin
  Obj:=true;
  DataHandlerMethodToObj:=ADataHandlerMethod;
  UserData:=AData;
  TaskCallBackToObj:=ATaskCallBack;
  RunnedThread:=nil;
end;
result:=NewTaskParameters;
end;

function BuildCPUTask(ADataHandlerMethod:TThreadExecuteCallback;AData:Pointer;
                 ATaskCallBack:TTaskNotifyCallBack):PExecuteInThreadParametrs;overload;
var NewTaskParameters:PExecuteInThreadParametrs;
begin
//if ADataHandlerMethod=nil then see RunFirstTaskInThread;
new(NewTaskParameters);
with NewTaskParameters^ do begin
  Obj:=false;
  DataHandlerMethod:=ADataHandlerMethod;
  UserData:=AData;
  TaskCallBack:=ATaskCallBack;
  RunnedThread:=nil;
end;
result:=NewTaskParameters;
end;

{function GetCPUTaskThread(ATask:PExecuteInThreadParametrs):TWaitingThread;
var n,RunnedCount:word;
begin
result:=nil;n:=0;
RunnedCount:=RunnedTasksList.Count;
while(result=nil)and(n<RunnedCount)do begin
  RunnedTasksList.Items[n];

end;
end;}

initialization
TaskListQueue:=TList.Create;
RunnedTasksList:=TList.Create;
CPUThreadsList:=TWaitingThreadlist.Create;
HDDThreadsList:=TWaitingThreadlist.Create;
EndingWorkCPUThreadsList:=TWaitingThreadlist.Create;
AutoLimitBackgroundCPUThreadsCount;
finalization

//Wait all tasks Run
while TaskListQueue.Count>0 do begin
CheckSynchronize(500);
end;

while RunnedTasksList.Count>0 do begin
CheckSynchronize(500);
end;

SetThreadsCount(0);
while EndingWorkCPUThreadsList.Count>0 do begin
CheckSynchronize(500);
end;

TaskListQueue.Free;
RunnedTasksList.Free;
CPUThreadsList.Free;
HDDThreadsList.Free;
EndingWorkCPUThreadsList.Free;
end.


