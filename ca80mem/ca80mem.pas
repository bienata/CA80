program ca80mem;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp,
  { you can add units after this }
  Synaser, crt, strutils;

type TCA80MemLoader = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    serialPort : TBlockSerial;
    verbose : boolean;
    constructor Create(TheOwner: TComponent); override;
    procedure WriteHelp; virtual;
    procedure sendData ( s : string );
  end;

procedure TCA80MemLoader.DoRun;
var
  ErrorMsg: String;
  serialPortName : string;
  hFile : TextFile;
  fileName : string;
  txt : string;
  startAddress : string;
  sp, command : string;
  i : integer;
begin
  ErrorMsg := CheckOptions('hp:f:rv', 'help port: file: reset verbose' );
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  if HasOption('h', 'help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  serialPortName := trim( GetOptionValue( 'port' ) );
  fileName := trim( GetOptionValue( 'file' ) );
  if fileName = '' then Halt;
  verbose := HasOption('verbose');

  self.serialPort := TBlockSerial.Create;

  self.serialPort.LinuxLock := false;
  self.serialPort.Connect( serialPortName );
  self.serialPort.config( 19200, 8, 'N', SB1, False, False );
  writeln('ca80mem, run');
  for i := 1 to 4 do sendData( '' );
  sendData( ':ini' );
  sendData( ':dml' ); // access!

     AssignFile( hFile, fileName );
     reset( hFile );
     while not eof( hFile ) do
     begin
       readln( hFile , txt );
       sendData( trim( txt ) );
     end;
     CloseFile( hFile );
     if HasOption('reset') then sendData( ':reset' );
     writeln('ca80mem, done');
  Halt;
end;

procedure TCA80MemLoader.sendData ( s : string );
var r : string;
begin
  self.serialPort.SendString( s + #$d#$a );
  r := self.serialPort.Recvstring(300);
  if (trim(r) <> '') and verbose then writeln( r );
end;

constructor TCA80MemLoader.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

procedure TCA80MemLoader.WriteHelp;
begin
  writeln('Usage: ca80mem --port=serialPort --file=path_to_ihex [--reset][--verbose]');
end;

var
  Application: TCA80MemLoader;
begin
  Application := TCA80MemLoader.Create(nil);
  Application.Title:='CA80 Direct Memory Loader';
  Application.Run;
  Application.Free;
end.

