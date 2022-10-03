unit HeapHandler;

{$if FPC_FULLVERSION < 30101}
  {$ERROR this unit needs version 3.1.1}
{$endif}
{$modeSwitch advancedRecords+ ALLOWINLINE+}


interface

//uses  Classes{, SysUtils};

type

generic TObjectHandler<T>=record
Heap:T;
class operator Initialize(var O:TObjectHandler);inline;
class operator  Finalize(var O:TObjectHandler);inline;
end;


generic TVariableHandler<T>=record
Heap:T;
class operator Initialize(var O:TVariableHandler);inline;
class operator  Finalize(var O:TVariableHandler);inline;
end;

implementation

class operator  TObjectHandler.Initialize(var O:TObjectHandler);inline;
begin
O.Heap:=nil;
end;

class operator  TObjectHandler.Finalize(var O:TObjectHandler);inline;
begin
O.Heap.Free;
end;

class operator  TVariableHandler.Initialize(var O:TVariableHandler);inline;
begin
O.Heap:=nil;
end;

class operator  TVariableHandler.Finalize(var O:TVariableHandler);inline;
begin
dispose(O.Heap);
end;

end.

