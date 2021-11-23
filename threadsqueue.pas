unit ThreadSQueue;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;
type
PExecuteInThreadParametrs=^TExecuteInThreadParametrs;

TTaskNotifyCallBackToObj = Procedure(ATask:PExecuteInThreadParametrs; AData : Pointer)of object;
TTaskNotifyCallBack = Procedure(ATask:PExecuteInThreadParametrs; AData : Pointer);
TThreadExecuteCallbackToObj=procedure(AData : Pointer) of object;

TExecuteInThreadParametrs = record
 Data:Pointer;
 RunnedThread:Tthread;
 case Obj:boolean of
 false:(DataHandlerMethod:TThreadExecuteCallback;TaskCallBack:TTaskNotifyCallBack);
 true:(DataHandlerMethodToObj:TThreadExecuteCallbackToObj;TaskCallBackToObj:TTaskNotifyCallBackToObj);
end;



var RunnedTaskList,TaskList:{tfplist}TList;


function AddTask(ADataHandlerMethod:TThreadExecuteCallback;AData:Pointer;ATaskCallBack:TTaskNotifyCallBack):
         PExecuteInThreadParametrs;overload;
function AddTask(ADataHandlerMethod:TThreadExecuteCallbackToObj;AData:Pointer;ATaskCallBack:TTaskNotifyCallBackToObj):
         PExecuteInThreadParametrs;overload;

function TaskRunned(ATask:PExecuteInThreadParametrs):boolean;

procedure SetMaxActiveThreadsNow(N:byte);

implementation

var MaxActiveThreads:byte;

procedure CheckQueue;forward;

procedure SetMaxActiveThreadsNow(N:byte);begin MaxActiveThreads:=N;CheckQueue;end;

function LeaveTaskList(Task:PExecuteInThreadParametrs):boolean;
var n:integer;
begin
n:=TaskList.IndexOf(Task);if n<0 then exit(false);TaskList.Delete(n);
end;

function LeaveList(item:pointer;List:{tfplist}TList):boolean;
var n:integer;
begin
n:=List.IndexOf(item);if n<0 then exit(false);List.Delete(n);
end;

procedure ExecuteCallback(ATask : Pointer);//сюда приходит PExecuteInThreadParametrs, см. RunTask и TthreadEnd
var Task:PExecuteInThreadParametrs;
begin
Task:=ATask;
if Task^.Obj then Task^.DataHandlerMethodToObj(Task^.Data)
else Task^.DataHandlerMethod(Task^.Data);
end;

procedure TthreadEnd(Sender : TObject; Done :Pointer{ PExecuteInThreadParametrs});
var EndedTask:PExecuteInThreadParametrs;
  n:byte;
begin
EndedTask:=Done;
{//there are no notifiers called if task was deleted from runned list
it can cause to memory leek if EndedTask^.Data not free!
}
if LeaveList(EndedTask,RunnedTaskList) then
  if (EndedTask^.Obj)then begin
    if assigned(EndedTask^.TaskCallBackToObj) then
      EndedTask^.TaskCallBackToObj(EndedTask,EndedTask^.Data);
  end else begin
    if (assigned(EndedTask^.TaskCallBack))then
      EndedTask^.TaskCallBack(EndedTask,EndedTask^.Data);
 end;
dispose(EndedTask);

{
for n:=0 to RunnedTaskList.Count-1 do begin
  EndedTask:=RunnedTaskList.Items[n];
  if EndedTask^.RunnedThread=sender then begin
    LeaveList(EndedTask,RunnedTaskList);
    if (EndedTask^.Obj=false)and (assigned(EndedTask^.TaskCallBack))then
      EndedTask^.TaskCallBack(EndedTask,EndedTask^.Data);
    if (EndedTask^.Obj)and (assigned(EndedTask^.TaskCallBackToObj))then
      EndedTask^.TaskCallBackToObj(EndedTask,EndedTask^.Data);
    dispose(EndedTask);
    break;
  end;
end;}
CheckQueue;
end;

procedure RunTask(Task:PExecuteInThreadParametrs);
var nTerminate: TNotifyCallBack;
 nExecuteCallback:TThreadExecuteCallback;
begin
nTerminate:=@TthreadEnd;
nExecuteCallback:=@ExecuteCallback;
//здесь подмена задания! см, ExecuteCallback и TthreadEnd
LeaveList(Task,TaskList);
Task^.RunnedThread:=Tthread.ExecuteInThread(nExecuteCallback,Task,nTerminate);
RunnedTaskList.Add(Task);
end;

procedure CheckQueue;
begin
while (TaskList.Count>0)and(RunnedTaskList.Count<MaxActiveThreads)do RunTask(TaskList.Items[0]);
end;

function AddTask(ADataHandlerMethod:TThreadExecuteCallback;AData:Pointer;ATaskCallBack:TTaskNotifyCallBack):PExecuteInThreadParametrs;overload;
var NewTaskParameters:PExecuteInThreadParametrs;
begin
if ADataHandlerMethod=nil then exit;
new(NewTaskParameters);
with NewTaskParameters^ do begin
  DataHandlerMethod:=ADataHandlerMethod;Data:=AData;TaskCallBack:=ATaskCallBack;
  Obj:=false;
end;
TaskList.Add(NewTaskParameters);result:=NewTaskParameters;
CheckQueue;
end;

function AddTask(ADataHandlerMethod:TThreadExecuteCallbackToObj;AData:Pointer;ATaskCallBack:TTaskNotifyCallBackToObj):PExecuteInThreadParametrs;overload;
var NewTaskParameters:PExecuteInThreadParametrs;
begin
if ADataHandlerMethod=nil then exit;
new(NewTaskParameters);
with NewTaskParameters^ do begin
  DataHandlerMethodToObj:=ADataHandlerMethod;Data:=AData;TaskCallBackToObj:=ATaskCallBack;
  Obj:=true;
end;
TaskList.Add(NewTaskParameters);result:=NewTaskParameters;
CheckQueue;
end;

function TaskRunned(ATask:PExecuteInThreadParametrs):boolean;
begin
  result:=RunnedTaskList.IndexOf(ATask)>=0;
end;

begin
TaskList:={tfplist}TList.Create;
RunnedTaskList:={tfplist}TList.Create;
end.

