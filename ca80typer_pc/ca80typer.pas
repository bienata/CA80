program ca80typer;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp,
  { you can add units after this }
  Synaser, crt, strutils;

type

  { TCA80Typer }

  TCA80Typer = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    serialPort : TBlockSerial;
    speed : integer;
    constructor Create(TheOwner: TComponent); override;
    procedure WriteHelp; virtual;
    procedure pressKey( c : char; faster : boolean = false );
    procedure typeSequenceG ( a : string );
    procedure typeSequenceD ( s : string );
  end;

{ TCA80Typer }

procedure TCA80Typer.pressKey( c : char; faster : boolean = false  );
begin
  self.serialPort.SendByte( byte( c ) );
  //write( c );
  write( chr(self.serialPort.RecvByte(500)) );
  if faster then delay( round(self.speed/2) ) else delay( self.speed );
end;

procedure TCA80Typer.typeSequenceG ( a : string );
var
   i : integer;
begin
    self.pressKey( 'm' );
    self.pressKey( 'g' );
    for i:= 1 to 4 do
    begin
       self.pressKey( lowercase( a[ i ] ), true );
    end;
    self.pressKey( '=' );
end;

procedure TCA80Typer.typeSequenceD ( s : string );
var
   addr, data : string;
   i, n : integer;
begin
    if LeftStr( s, 1 ) <> ':' then exit;
    n := Hex2Dec( Copy( s,2,2) );
    if n = 0 then exit;
    if Copy( s,8,2 ) <> '00' then exit;

    self.pressKey( 'm' );
    self.pressKey( 'd' );
    // adres
    addr := Copy( s, 4, 4 );
    for i:= 1 to 4 do
    begin
       self.pressKey( lowercase( addr[ i ] ), true );
    end;
    self.pressKey( '=' );
    for i := 0 to n - 1 do
    begin
      data := Copy( s, 10 + i*2 ,2 );
      self.pressKey( lowercase( data[ 1 ] ), true );       // hi
      self.pressKey( lowercase( data[ 2 ] ), true );       // lo
      self.pressKey( '=' );
    end;
end;

procedure TCA80Typer.DoRun;
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
  ErrorMsg := CheckOptions('hp:f:s:a:c:', 'help port: file: speed: address: command:' );
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

  sp := trim( GetOptionValue( 'speed' ) );
  if sp = '' then sp := '200';
  speed := StrToInt( sp );
  if speed < 100 then speed := 100;

  self.serialPort := TBlockSerial.Create;
  try
     self.serialPort.LinuxLock := false;
     self.serialPort.Connect( serialPortName );
     self.serialPort.config( 9600, 8, 'N', SB1, False, False );

     // zaladuj heksik
     fileName := trim( GetOptionValue( 'file' ) );
     if fileName <> '' then
       begin
         startAddress := trim( GetOptionValue( 'address' ) );
         self.pressKey('m');
         self.pressKey('m');
         AssignFile( hFile, fileName );
         reset( hFile );
         while not eof( hFile ) do
           begin
              readln( hFile , txt );
              typeSequenceD ( trim( txt ) );
           end;
         CloseFile( hFile );
         // opcjonalnie uruchom
         if startAddress <> '' then typeSequenceG ( startAddress );
       end;
       // dodatkowe klikanie, np. parametry programu
       command := trim( GetOptionValue( 'command' ) );
       if command <> '' then
         begin
              for i := 1 to length(command) do self.pressKey( lowercase( command[i] ) );
         end;
  finally
    self.Free;
  end;
  writeln( '' );
  Halt;
end;

constructor TCA80Typer.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

procedure TCA80Typer.WriteHelp;
begin
  writeln('Usage: ca80typer --port=serialPort --speed=typespeed [other parameters]');
  writeln('to click simple command: --command="keystrokes"');
  writeln('to type hex file:        --file=hexfilepath --address=startaddress');
  writeln('Example - setting CA80 clock:');
  writeln('     ca80typer --port=/dev/ttyACM0 --speed=200 --command="m122.33.44=m0" ');
  writeln('Example - clicking hello1.hex and starting app from 0xC000 location');
  writeln('     ca80typer --port=/dev/ttyACM0 --speed=150 --file=hello1.hex --address=c000 ');
end;

var
  Application: TCA80Typer;
begin
  Application:=TCA80Typer.Create(nil);
  Application.Title:='CA80 keyboard typer';
  Application.Run;
  Application.Free;
end.

