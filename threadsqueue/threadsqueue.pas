unit ThreadSQueue;{//rename to CPUThreadSQueue}

{$mode objfpc}{$H+}
{$ASSERTIONS ON}
interface

uses
  Classes, {SysUtils,}MTPCPU{from package multithreadprocslaz},WaitingThread;
type
PExecuteInThreadParametrs=^TExecuteInThreadParametrs;

TTaskNotifyCallBackToObj = Procedure(ATask:PExecuteInThreadParametrs; AData : Pointer)of object;
TTaskNotifyCallBack = Procedure(ATask:PExecuteInThreadParametrs; AData : Pointer);
TThreadExecuteCallbackToObj=procedure(AData : Pointer) of object;

TExecuteInThreadParametrs = record
 Data:Pointer;//user set data
 RunnedThread:Tthread;//service info
 //AllowParallel,AllowFlush:boolean;//User Help flag, not used in this unit, all tasks start according MaxActiveThreads
// TaskCustomer:Tobject;//user set help info
 case Obj:boolean of //service info
 false:(DataHandlerMethod:TThreadExecuteCallback;//user set method
        TaskCallBack:TTaskNotifyCallBack);//user set method to be notified
 true:(
       DataHandlerMethodToObj:TThreadExecuteCallbackToObj;//user set method
       TaskCallBackToObj:TTaskNotifyCallBackToObj//user set method of object to be notified
       );
end;




function BuildTask(ATaskCustomer:Tobject;ADataHandlerMethod:TThreadExecuteCallbackToObj;AData:Pointer;
                 ATaskCallBack:TTaskNotifyCallBackToObj):PExecuteInThreadParametrs;overload;
function BuildTask(ADataHandlerMethod:TThreadExecuteCallback;AData:Pointer;
                 ATaskCallBack:TTaskNotifyCallBack):PExecuteInThreadParametrs;overload;

function AddTask(ADataHandlerMethod:TThreadExecuteCallback;AData:Pointer;ATaskCallBack:TTaskNotifyCallBack):
         PExecuteInThreadParametrs;overload;
function AddTask(ATaskCustomer:Tobject;ADataHandlerMethod:TThreadExecuteCallbackToObj;AData:Pointer;ATaskCallBack:TTaskNotifyCallBackToObj):
         PExecuteInThreadParametrs;overload;
function AddTask(ATask:PExecuteInThreadParametrs):boolean;overload;

function TaskRunned(ATask:PExecuteInThreadParametrs):boolean;

procedure SetMaxActiveThreadsNow(N:word);

procedure SetMaxActiveThreadsAuto;

function GetMaxActiveThreads:word;

procedure NotifyTaskExecuted(EndedTask:PExecuteInThreadParametrs);


var RunnedTaskList,TaskList:TList;
  ConsiderMainThread:boolean=true;

implementation

var //MaxActiveThreads:shortint;
ThreadArray:array of TWaitingThread;

procedure CheckQueue;forward;

procedure SetThreadArrayCount(Newcount:word);
var count:word;
begin
count:=length(ThreadArray);
if Newcount=count then exit;

if Newcount<count then begin
  repeat
    ThreadArray[count-1].EndWork;
    count:=count-1;
  until (Newcount=count);
  setlength(ThreadArray,Newcount);
end else begin
  setlength(ThreadArray,Newcount);
  repeat
    ThreadArray[count]:=TWaitingThread.Create();
    count:=count+1;
  until (Newcount=count);
end;
end;

procedure SetMaxActiveThreadsNow(N:word);
begin
SetThreadArrayCount(n);
assert(n>0,'Threads count is 0, mean no one tasks in ThreadSQueue will run');
CheckQueue;
end;

procedure SetMaxActiveThreadsAuto;
var Newcount:integer;
begin
Newcount:=GetSystemThreadCount;
if Newcount<1 then Newcount:=1;
if ConsiderMainThread then Newcount:=Newcount-1;
SetMaxActiveThreadsNow(Newcount);
end;

function GetMaxActiveThreads:word;
begin
result:=//MaxActiveThreads;
length(ThreadArray);
end;

function GetFreeThread:TWaitingThread;
var n,c:byte;//as SetMaxActiveThreadsNow parametr
begin
result:=nil;n:=0;
c:=length(ThreadArray);
while(result=nil)and(n<c)do begin
if ThreadArray[n].ReadyToExecute then result:=ThreadArray[n];
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
if Task^.Obj then Task^.DataHandlerMethodToObj(Task^.Data)
else Task^.DataHandlerMethod(Task^.Data);
end;

procedure TthreadEndExecution(Sender : TObject; Done :Pointer);
var EndedTask:PExecuteInThreadParametrs;
begin
EndedTask:=Done;
LeaveList(EndedTask,RunnedTaskList);
NotifyTaskExecuted(EndedTask);
dispose(EndedTask);
CheckQueue;
end;

procedure NotifyTaskExecuted(EndedTask:PExecuteInThreadParametrs);
begin
if (EndedTask^.Obj)then begin
      if assigned(EndedTask^.TaskCallBackToObj) then
        EndedTask^.TaskCallBackToObj(EndedTask,EndedTask^.Data);
    end else begin
      if (assigned(EndedTask^.TaskCallBack))then
        EndedTask^.TaskCallBack(EndedTask,EndedTask^.Data);
    end;
end;

function TaskDataHandlerMethodIsNil(Task:PExecuteInThreadParametrs):boolean;
begin
if Task^.Obj then
  result:=TMethod(Task^.DataHandlerMethodToObj).Data=nil
else
  result:=Task^.DataHandlerMethod=nil;
end;

function RunTaskInThread(Task:PExecuteInThreadParametrs;WorkerThread:TWaitingThread):boolean;
begin
//check if task DataHandlerMethod is nil - then nothing to run:
if TaskDataHandlerMethodIsNil(Task)then begin
  TthreadEndExecution(nil,Task);
end else begin// run in thread
  //здесь подмена задания! см, ExecuteCallback и TthreadEndExecution
  result:=WorkerThread.ExecuteInThread(@ExecuteCallback,Task,@TthreadEndExecution);
  if result then begin
    Task^.RunnedThread:=WorkerThread;
    LeaveList(Task,TaskList);
    RunnedTaskList.Add(Task);
  end;
end;

end;

procedure CheckQueue;
var WorkerThread:TWaitingThread;
FailStart:boolean;
begin
{Here can add analyse of waiting tasks: if TaskList.Count>1, this mean that all thread busy.
 And if limit of thread not reached, we can add thread to work.
 If it will implement, then need to realise(?) threads count decrease(?) }

repeat
  FailStart:=true;
  if (TaskList.Count>0) then begin
    WorkerThread:=GetFreeThread;
    if WorkerThread<>nil then
      FailStart:=not RunTaskInThread(TaskList.Items[0],WorkerThread);
  end;
until FailStart;
end;

function AddTask(ADataHandlerMethod:TThreadExecuteCallback;AData:Pointer;ATaskCallBack:TTaskNotifyCallBack):PExecuteInThreadParametrs;overload;
var NewTaskParameters:PExecuteInThreadParametrs;
begin
NewTaskParameters:=BuildTask(ADataHandlerMethod,AData,ATaskCallBack);
TaskList.Add(NewTaskParameters);
result:=NewTaskParameters;
CheckQueue;
end;

function AddTask(ATaskCustomer:Tobject;ADataHandlerMethod:TThreadExecuteCallbackToObj;AData:Pointer;
                 ATaskCallBack:TTaskNotifyCallBackToObj):PExecuteInThreadParametrs;overload;
var NewTaskParameters:PExecuteInThreadParametrs;
begin
NewTaskParameters:=BuildTask(ATaskCustomer,ADataHandlerMethod,AData,ATaskCallBack);
TaskList.Add(NewTaskParameters);
result:=NewTaskParameters;
CheckQueue;
end;

function AddTask(ATask:PExecuteInThreadParametrs):boolean;overload;
begin
if ATask=nil then exit(false)
else result:=true;
TaskList.Add(ATask);
CheckQueue;
end;

function TaskRunned(ATask:PExecuteInThreadParametrs):boolean;
begin
  result:=(RunnedTaskList.IndexOf(ATask)>-1)or(ATask^.RunnedThread<>nil);
end;

function BuildTask(ATaskCustomer:Tobject;ADataHandlerMethod:TThreadExecuteCallbackToObj;AData:Pointer;
                 ATaskCallBack:TTaskNotifyCallBackToObj):PExecuteInThreadParametrs;overload;
var NewTaskParameters:PExecuteInThreadParametrs;
begin
//if ADataHandlerMethod=nil then see RunTaskInThread;
new(NewTaskParameters);
with NewTaskParameters^ do begin
  Obj:=true;
  DataHandlerMethodToObj:=ADataHandlerMethod;
  Data:=AData;
  TaskCallBackToObj:=ATaskCallBack;
  //TaskCustomer:=ATaskCustomer;
  //Default values:
  //AllowParallel:=false;
  RunnedThread:=nil;
end;
result:=NewTaskParameters;
end;

function BuildTask(ADataHandlerMethod:TThreadExecuteCallback;AData:Pointer;
                 ATaskCallBack:TTaskNotifyCallBack):PExecuteInThreadParametrs;overload;
var NewTaskParameters:PExecuteInThreadParametrs;
begin
//if ADataHandlerMethod=nil then see RunTaskInThread;
new(NewTaskParameters);
with NewTaskParameters^ do begin
  DataHandlerMethod:=ADataHandlerMethod;Data:=AData;TaskCallBack:=ATaskCallBack;
  Obj:=false;
  //Default values:
  //AllowParallel:=false;
  RunnedThread:=nil;
  //TaskCustomer:=nil;
end;
result:=NewTaskParameters;
end;

begin
TaskList:=TList.Create;
RunnedTaskList:=TList.Create;
SetMaxActiveThreadsAuto;
end.

