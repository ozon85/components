unit WaitingThread;

{$mode objfpc}{$H+}

interface

uses
  Classes{, SysUtils};

type
TWaitingThread = class;
TWaitingThreadlist=class(TFPList)
protected
    function Get(Index: Integer): TWaitingThread;
    procedure Put(Index: Integer; Item: TWaitingThread);
public
    function Last: TWaitingThread;
    property Items[Index: Integer]: TWaitingThread read Get write Put; default;
end;

TNotifyMethod = procedure(Sender: TObject);

TWaitingThread = class(TThread)
  private
    FEvent:PRTLEvent;
    FExecuteMethod: TThreadExecuteCallBack;
    FOnExecEnd : TNotifyCallBack;
    FData: Pointer;
    FworkDone:boolean;
    function GetWaitingStatus:boolean;
    procedure CallOnTerminate;
  protected
    procedure Execute; override;
    procedure WaitEvent;
    procedure SetEvent;
    procedure SyncCall;
    procedure DoTerminate;override;
  public
    OnTerminateMethod:TNotifyCallBack;
    Constructor Create(CreateSuspended: Boolean=false;const StackSize: SizeUInt = DefaultStackSize;
                                  AFreeOnTerminate:boolean=true);
    destructor Destroy; override;
    function ExecuteInThread(AMethod : TThreadExecuteCallback; AData : Pointer = Nil;
                              AOnExecEnd: TNotifyCallBack = Nil):boolean;
    procedure WaitForWorkDone;
    procedure EndWork;
    property ReadyToExecute:boolean read GetWaitingStatus;
    property Data : Pointer read FData write FData;
    property ExecuteMethod: TThreadExecuteCallBack read FExecuteMethod write FExecuteMethod;
end;


implementation

function TWaitingThreadlist.Get(Index: Integer): TWaitingThread;
begin
Result:=TWaitingThread(inherited);
end;

procedure TWaitingThreadlist.Put(Index: Integer; Item: TWaitingThread);
begin
inherited put(Index,Item);
end;

function TWaitingThreadlist.Last: TWaitingThread;
begin
result:=TWaitingThread(inherited);
end;


Constructor TWaitingThread.Create(CreateSuspended: Boolean=false;
                                  const StackSize: SizeUInt = DefaultStackSize;
                                  AFreeOnTerminate:boolean=true);
begin
FEvent:=RTLEventCreate;
RTLEventResetEvent(Fdata);
FreeOnTerminate:=AFreeOnTerminate;
FExecuteMethod:=nil;
FOnExecEnd:=nil;
FData:=nil;
inherited create(CreateSuspended,StackSize);
end;

destructor TWaitingThread.Destroy;
begin
RTLEventDestroy(FEvent);
inherited Destroy;
end;

procedure TWaitingThread.Execute;
begin
repeat
  WaitEvent;//Wait to get or set FExecuteMethod, Fdata
  if FExecuteMethod<>nil then begin
    FExecuteMethod(Fdata);
    Queue(@SyncCall);//Thread will fall down if exception in main thread
    //Synchronize(TThreadMethod(@SyncCall));//Thread will fall down if exception in main thread
  end;
until Terminated;
end;

procedure TWaitingThread.SyncCall;
begin
if FOnExecEnd<>nil then
  FOnExecEnd(self,{SyncCallData}Fdata);
end;

procedure TWaitingThread.SetEvent;
begin
RTLeventSetEvent(FEvent);
end;

procedure TWaitingThread.WaitEvent;
begin
FworkDone:=true;
RTLEventWaitFor(FEvent);
RTLEventResetEvent(Fdata);
FworkDone:=false;
end;

function TWaitingThread.GetWaitingStatus:boolean;
begin
result:=FExecuteMethod=nil;
end;

procedure TWaitingThread.WaitForWorkDone;
begin
while (not FworkDone)do
 CheckSynchronize(500);
end;

procedure TWaitingThread.EndWork;
begin
Terminate;
SetEvent;
end;

procedure TWaitingThread.DoTerminate;
begin
  Synchronize(@CallOnTerminate);
end;

procedure TWaitingThread.CallOnTerminate;
begin
  if Assigned(OnTerminateMethod)then
    OnTerminateMethod(Self,Fdata);
end;

function TWaitingThread.ExecuteInThread(AMethod : TThreadExecuteCallback; AData : Pointer = Nil;
                              AOnExecEnd: TNotifyCallBack = Nil):boolean;
begin
result:=ReadyToExecute and (AMethod<>nil);
if not result then exit;
FExecuteMethod := AMethod;
FOnExecEnd := AOnExecEnd;
FData:=AData;
SetEvent;
end;

end.
