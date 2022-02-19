unit WaitingThread;

{$mode objfpc}{$H+}

interface

uses
  Classes{, SysUtils};

type

TWaitingThread = class(TThread)
  private
    FEvent:PRTLEvent;
    FExecuteMethod: TThreadExecuteCallBack;
    FOnExecEnd : TNotifyCallBack;
    FData : Pointer;
    function GetWaitingStatus:boolean;
  protected
    procedure Execute; override;
    procedure WaitEvent;
    procedure SetEvent;
    procedure SyncCall;
  public
    Constructor Create(CreateSuspended: Boolean=false;const StackSize: SizeUInt = DefaultStackSize;
                                  AFreeOnTerminate:boolean=true);
    destructor Destroy; override;
    function ExecuteInThread(AMethod : TThreadExecuteCallback; AData : Pointer = Nil;
                              AOnExecEnd: TNotifyCallBack = Nil):boolean;
    procedure EndWork;
    property ReadyToExecute:boolean read GetWaitingStatus;
end;


implementation


Constructor TWaitingThread.Create(CreateSuspended: Boolean=false;
                                  const StackSize: SizeUInt = DefaultStackSize;
                                  AFreeOnTerminate:boolean=true);
begin
FEvent:=RTLEventCreate;
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
  if FExecuteMethod=nil then
    WaitEvent
  else begin
    FExecuteMethod(Fdata);
    Synchronize(@SyncCall);
  end;
until Terminated;
end;

procedure TWaitingThread.SyncCall;
begin
FExecuteMethod:=nil;
if FOnExecEnd<>nil then
  FOnExecEnd(self,Fdata);
end;

procedure TWaitingThread.SetEvent;
begin
RTLeventSetEvent(FEvent);
end;

procedure TWaitingThread.WaitEvent;
begin
RTLEventWaitFor(FEvent);
end;

function TWaitingThread.GetWaitingStatus:boolean;
begin
result:=FExecuteMethod=nil;
end;

procedure TWaitingThread.EndWork;
begin
Terminate;
SetEvent;
end;


function TWaitingThread.ExecuteInThread(AMethod : TThreadExecuteCallback; AData : Pointer = Nil;
                              AOnExecEnd: TNotifyCallBack = Nil):boolean;
begin
result:=ReadyToExecute and (AMethod<>nil);
FExecuteMethod := AMethod;
FOnExecEnd := AOnExecEnd;
FData:=AData;
SetEvent;
end;

end.

