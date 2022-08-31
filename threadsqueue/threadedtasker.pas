unit ThreadedTasker;
{
Rename to ObjectThreadManager ?
}

{$mode objfpc}{$H+}
//{$ASSERTIONS ON} Use Assert flag (-Sa)
interface

uses
  Classes, SysUtils,CPUTasksQueue;

type

PTask=^TTask;

//TTaskCallBack = Procedure(TaskCustomer:Tobject;AData : Pointer;TaskFlushed:boolean)of object;
TTaskCallBack = Procedure(ATaskData : Pointer;TaskCanceled:boolean)of object;

TTask = record
 Data:Pointer;//user set data
// RunnedThread:Tthread;//service info
 AllowParallel,AllowFlush,Waiting:boolean;//User set
 //TaskCustomer:Tobject;//service set
 DataHandlerMethodToObj:TThreadExecuteCallbackToObj;//user set method
 TaskCallBackToObj:TTaskCallBack;//user set method of object to be notified
end;

type TPTaskList=class(TFPList)
  function Get(Index: Integer):PTask;
  procedure Put(Index: Integer; Item: PTask);
  public
    function Last: PTask;
    property Items[Index: Integer]: PTask read Get write Put;
end;

TProcedureOfObject = procedure of object;

TThreadedTasker=class(TObject)
  private
    //simple fields
    FOnDestroy,FOnTasksEnd:TNotifyEvent;
    FdestroyStarted,FAWaitingAllTasksEnd:boolean;

    //Need create and destroy
    RunnedTasksList,TasksQueueList:TPTaskList;
    NotifyFlagsOfDestroy:TFPList;//not need while WaitAllTasksEnd in destroy

    procedure StartFirstTask;
    procedure TaskExecutionEnd(ATask:PExecuteInThreadParametrs; AData : Pointer);
    procedure FinishTask(FinishedTask:PTask;TaskFlushed:boolean=false);
    procedure TaskEndNotify(EndedCPUTask:PTask;TaskFlushed:boolean=false);
    procedure Execution(ATask : Pointer);
    procedure FreeObjectsInList(ClrList:TFPList);
  public
    //Is it used?
    FreeObjectsOnDestroy:TFPList;

    constructor Create;
    destructor Destroy; override;
    function IsRunned:boolean;
    function BuildTask(//ATaskCustomer:Tobject;
                       ADataHandlerMethod:TThreadExecuteCallbackToObj;
                       AData:Pointer;
                       ATaskCallBack:TTaskCallBack;
                       AAllowParallel:boolean;   AAllowFlush:boolean=false;
                       Awaiting:boolean=false):PTask;
    //Add Task to Tasks queue list
    procedure AddQueueTask(NewCPUTask:PTask;ACheckQueue:boolean=true);
    //Mark Task as waiting and AddQueueTask
    procedure AddWaitingTask(NewCPUTask:PTask);

    //Flush Task from TasksQueue list despite AllowFlush flag. It will call data processing end.
    function CancelTask(CancelCPUTask:PTask;ACheckQueue:boolean=true):boolean;
    //Waiting task set as not waiting, and check queu
    function ResumeWaitingTask(ResumeCPUTask:PTask):boolean;
    //cancel tasks in queue that marked as allowed to flush
    procedure CancelAllowedTasksInQueue;
    //Use before destroy to clear All not runned tasks in queue
    procedure ForceCancelAllTasksInQueue;

    function LastRunnedAllowParallel:boolean;
    function NextTaskAllowParallel:boolean;
    function NextTaskWaiting:boolean;
    function NextTaskExist:boolean;
    function RunnedTasksExist:boolean;
    function NotificationInProcess:boolean;deprecated;
    procedure CheckQueueList;
    {Use to wait while runned. You may send @(application.ProcessMessages)
    Called with nil when destroy}
    procedure WaitAllTasksEnd(SyncProcedure:TProcedureOfObject=nil;OneStepMs:word=500);

//    procedure ClearTaskSCustomer;only for TaskCustomer:Tobject;
    property OnDestroy:TNotifyEvent read FOnDestroy write FOnDestroy;
    property OnTasksEnd:TNotifyEvent read FOnTasksEnd write FOnTasksEnd;
end;


implementation

//--------------------------------------------
function TPTaskList.Get(Index: Integer): PTask;
begin result:=PTask(inherited get(Index));end;

procedure TPTaskList.Put(Index: Integer; Item: PTask);
begin inherited Put(Index,Pointer(Item));end;

function TPTaskList.Last: PTask;
begin
result:=inherited;
end;

//--------------------------------------------

procedure TThreadedTasker.StartFirstTask;
var NewTaskParameters:PExecuteInThreadParametrs;
startTask:PTask;
begin
startTask:=TasksQueueList.Items[0];
TasksQueueList.Delete(0);
if startTask^.DataHandlerMethodToObj<>nil then begin
  NewTaskParameters:=CPUTasksQueue.BuildCPUTask(@Execution,startTask,@TaskExecutionEnd);
  if AddCPUTask(NewTaskParameters)then
    RunnedTasksList.Add(startTask)
  else
    FinishTask(startTask,true);
end else begin
  FinishTask(startTask);
end;
end;

function TThreadedTasker.NextTaskAllowParallel:boolean;
begin
result:=TasksQueueList.Items[0]^.AllowParallel;
end;

function TThreadedTasker.NextTaskWaiting:boolean;
begin
result:=TasksQueueList.Items[0]^.Waiting;
end;

function TThreadedTasker.NextTaskExist:boolean;
begin
  result:=TasksQueueList.Count>0;
end;

function TThreadedTasker.RunnedTasksExist:boolean;
begin
result:=RunnedTasksList.Count>0;
end;

function TThreadedTasker.LastRunnedAllowParallel:boolean;
begin
result:=(RunnedTasksList.Last^.AllowParallel);
end;

procedure TThreadedTasker.CheckQueueList;
function RunnedTasksAndQueuAllowAddOne(NextAllowParallel:boolean):boolean;
begin
result:=(not RunnedTasksExist)
      or(LastRunnedAllowParallel and NextAllowParallel);
end;

begin
  while NextTaskExist and(not NextTaskWaiting)
    and RunnedTasksAndQueuAllowAddOne(NextTaskAllowParallel)
  do begin
    StartFirstTask;
  end;
if (not IsRunned)and(OnTasksEnd<>nil) then
    OnTasksEnd(self);
end;

constructor TThreadedTasker.Create;
begin
inherited;
RunnedTasksList:=TPTaskList.Create;
TasksQueueList:=TPTaskList.Create;
FreeObjectsOnDestroy:=TFPList.Create;
NotifyFlagsOfDestroy:=TFPList.Create;
FdestroyStarted:=false;
end;

destructor TThreadedTasker.Destroy;
var n:word;
begin
assert(FdestroyStarted=false,'Destroy called twice!');
FdestroyStarted:=true;
WaitAllTasksEnd;
if OnDestroy<>nil then
  OnDestroy(self);
FreeObjectsInList(FreeObjectsOnDestroy);

if NotifyFlagsOfDestroy.Count>0 then{//deprecated}
  for n:=0 to NotifyFlagsOfDestroy.Count-1 do
    PBoolean(NotifyFlagsOfDestroy.Items[n])^:=true;
FreeAndNil(RunnedTasksList);
FreeAndNil(TasksQueueList);
FreeAndNil(FreeObjectsOnDestroy);
FreeAndNil(NotifyFlagsOfDestroy);
inherited;
end;

function TThreadedTasker.IsRunned:boolean;
begin
result:=RunnedTasksExist or NextTaskExist
//(RunnedTasksList.Count>0)or(TasksQueueList.Count>0)
;
end;

procedure TThreadedTasker.AddQueueTask(NewCPUTask:PTask;ACheckQueue:boolean=true);
begin
//assert(not FdestroyStarted,'DestroyStarted');
TasksQueueList.Add(NewCPUTask);
if ACheckQueue then
  CheckQueueList;
end;

procedure TThreadedTasker.AddWaitingTask(NewCPUTask:PTask);
begin
NewCPUTask^.Waiting:=true;
AddQueueTask(NewCPUTask,false);
end;

function TThreadedTasker.ResumeWaitingTask(ResumeCPUTask:PTask):boolean;
begin
result:=TasksQueueList.IndexOf(ResumeCPUTask)>-1;
if result then begin
ResumeCPUTask^.Waiting:=false;
CheckQueueList;
end;
end;

function TThreadedTasker.CancelTask(CancelCPUTask:PTask;
                                     ACheckQueue:boolean=true):boolean;
begin
result:=TasksQueueList.Remove(CancelCPUTask)>-1;
if result then begin
  FinishTask(CancelCPUTask,true);
  if ACheckQueue then
    CheckQueueList;
end;
end;

procedure TThreadedTasker.Execution(ATask : Pointer);
//сюда приходит PTask
var Task:PTask;
begin
Task:=ATask;
if TMethod(Task^.DataHandlerMethodToObj).Data<>nil then
  Task^.DataHandlerMethodToObj(Task^.Data);
end;

procedure TThreadedTasker.TaskExecutionEnd(ATask:PExecuteInThreadParametrs; AData : Pointer);
var DestroyCalled:boolean;
begin
RunnedTasksList.Remove(AData);
DestroyCalled:=false;
//first notify, then run new task, because next task can be runned immediately in main thread
NotifyFlagsOfDestroy.Add(@DestroyCalled);
FinishTask(AData);
if DestroyCalled then //no fields available
  exit;
NotifyFlagsOfDestroy.Remove(@DestroyCalled);
CheckQueueList;
end;

procedure TThreadedTasker.CancelAllowedTasksInQueue;
var CPUTask:PTask;
n:cardinal;
begin
if TasksQueueList.Count>0 then
for n:=TasksQueueList.Count-1 downto 0 do begin
  CPUTask:=TasksQueueList.Items[n];
  if CPUTask^.AllowFlush then begin
    TasksQueueList.Delete(n);
    FinishTask(CPUTask,true);//TaskExecutionEnd inside, CPUTask dispose
  end;
end;
CheckQueueList;
end;

procedure TThreadedTasker.ForceCancelAllTasksInQueue;
var CPUTask:PTask;
n:cardinal;
begin
if TasksQueueList.Count>0 then
for n:=TasksQueueList.Count-1 downto 0 do begin
  CPUTask:=TasksQueueList.Items[n];
  TasksQueueList.Delete(n);
  FinishTask(CPUTask,true);//TaskExecutionEnd inside, CPUTask dispose
end;
end;

{procedure TThreadedTasker.ClearTaskSCustomer;
var n:qword;
begin
if TasksQueueList.Count>0 then
  for n:=0 to TasksQueueList.Count-1 do begin
    TasksQueueList.Items[n]^.TaskCustomer:=nil;
  end;

if RunnedTasksList.Count>0 then
  for n:=0 to RunnedTasksList.Count-1 do begin
    RunnedTasksList.Items[n]^.TaskCustomer:=nil;
  end;
end; }

procedure TThreadedTasker.TaskEndNotify(EndedCPUTask:PTask;TaskFlushed:boolean=false);
begin
if EndedCPUTask^.TaskCallBackToObj<>nil then
EndedCPUTask^.TaskCallBackToObj({EndedCPUTask^.TaskCustomer,}EndedCPUTask^.Data,TaskFlushed);
end;

procedure TThreadedTasker.FinishTask(FinishedTask:PTask;TaskFlushed:boolean=false);
begin
TaskEndNotify(FinishedTask,TaskFlushed);
dispose(FinishedTask);
end;

procedure TThreadedTasker.FreeObjectsInList(ClrList:TFPList);
var n:word;
begin
if ClrList.Count>0 then begin
  for n:=ClrList.Count-1 downto 0 do begin
     Tobject(ClrList.Items[n]).Free;
  end;
  ClrList.Clear;
end;
end;

function TThreadedTasker.BuildTask(//ATaskCustomer:Tobject;
          ADataHandlerMethod:TThreadExecuteCallbackToObj;AData:Pointer;
          ATaskCallBack:TTaskCallBack;
          AAllowParallel:boolean;AAllowFlush:boolean=false;
          Awaiting:boolean=false):PTask;
begin
new(result);
with result^ do begin
//  TaskCustomer:=ATaskCustomer;
  Data:=AData;
  AllowParallel:=AAllowParallel;
  AllowFlush:=AAllowFlush;
  waiting:=Awaiting;
  DataHandlerMethodToObj:=ADataHandlerMethod;
  TaskCallBackToObj:=ATaskCallBack;
end;
end;

procedure TThreadedTasker.WaitAllTasksEnd(SyncProcedure:TProcedureOfObject=nil;OneStepMs:word=500);
begin
while IsRunned do begin
  CheckQueueList;
  if SyncProcedure=nil then
    checksynchronize(OneStepMs)
  else
    SyncProcedure;
end;
end;

function TThreadedTasker.NotificationInProcess:boolean;
begin
result:=NotifyFlagsOfDestroy.Count>0;
end;

end.
