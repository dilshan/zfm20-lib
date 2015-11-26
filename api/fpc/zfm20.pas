{ ZFM-20 series fingerprint library Lazarus/FPC wrapper.

  Copyright (c) 2015 Dilshan R Jayakody [jayakody2000lk@gmail.com]

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to
  deal in the Software without restriction, including without limitation the
  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
  sell copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
  IN THE SOFTWARE.
}

unit zfm20;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  { TZfmStatus }
  TZfmStatus = (ZsUnknownError = 0, ZsSuccessful, ZsTimeout, ZsNoFinger, ZsFingerCollectError, ZsBadResponse, ZsDataError, ZsIoError, ZsMemoryError);

  { TfrmMain }
  TZFM20Fingerprint = class(TObject)
  public
    constructor Create(portName: string; baudRate: integer); overload;
    destructor Destroy; override;
    function IsAvailable(): Boolean;
    function Capture(): TZfmStatus;
    function SaveFingerprintToFile(fileName: string): TZfmStatus;
    function GetFingerprintBuffer(var dataBuffer: PByte; var dataBufferSize: LongWord): TZfmStatus;
    function FreeFingerprintBuffer(var dataBuffer: PByte): TZfmStatus;
  private
    _pComPort: string;
    _pBaud: integer;
    _pDevID: LongWord;
  public
    // Communication port address or value.
    property Port: string read _pComPort write _pComPort;

    // Communication port baud rate. (Default baud rate for ZFM-20 sensor is 56700.)
    property BaudRate: integer read _pBaud write _pBaud;

    // Sensor ID. (Default ZFM-20 sensor ID is 0xFFFFFFFF.)
    property DeviceID: LongWord read _pDevID write _pDevID;
  end;

implementation

function Zfm20CaptureFingerprint(comPort: PChar; baudRate: Integer; sensorAddr: LongWord): TZfmStatus; stdcall; external 'zfm20lib.dll';
function Zfm20SensorAvailable(comPort: PChar; baudRate: Integer; sensorAddr: LongWord): TZfmStatus; stdcall; external 'zfm20lib.dll';
function Zfm20SaveFingerprintImage(comPort: PChar; baudRate: Integer; sensorAddr: LongWord; fileName: PChar): TZfmStatus; stdcall; external 'zfm20lib.dll';
function Zfm20FreeFingerprintBuffer(var dataBuffer: PByte): TZfmStatus; stdcall; external 'zfm20lib.dll';
function Zfm20GetFingerprintBuffer(comPort: PChar; baudRate: Integer; sensorAddr: LongWord; var outBufferSize: LongWord; var outBuffer: PByte): TZfmStatus; stdcall;  external 'zfm20lib.dll';

// Constructor.
constructor TZfm20Fingerprint.Create(portName: string; baudRate: integer);
begin
  inherited Create;
  _pComPort := portName;
  _pBaud := baudRate;
  _pDevID := $FFFFFFFF;
end;

// Destructor.
destructor TZfm20Fingerprint.Destroy;
begin
  inherited;
end;

// Check availability of fingerprint sensor.
function TZfm20Fingerprint.IsAvailable(): Boolean;
begin
  Result := (Zfm20SensorAvailable(PChar(_pComPort), _pBaud, _pDevId) = zsSuccessful);
end;

// Send capture command to sensor module.
function TZfm20Fingerprint.Capture(): TZfmStatus;
begin
  Result := Zfm20CaptureFingerprint(PChar(_pComPort), _pBaud, _pDevId);
end;

// Save content of sensor's ImageBuffer to specified bitmap file.
function TZfm20Fingerprint.SaveFingerprintToFile(fileName: string): TZfmStatus;
begin
  Result := Zfm20SaveFingerprintImage(PChar(_pComPort), _pBaud, _pDevId, PChar(fileName));
end;

// Get content of sensor ImageBuffer as buffer.
function TZfm20Fingerprint.GetFingerprintBuffer(var dataBuffer: PByte; var dataBufferSize: LongWord): TZfmStatus;
begin
  Result := Zfm20GetFingerprintBuffer(PChar(_pComPort), _pBaud, _pDevId, dataBufferSize, dataBuffer);
end;

// Flush allocated fingerprint image buffer.
function TZfm20Fingerprint.FreeFingerprintBuffer(var dataBuffer: PByte): TZfmStatus;
begin
  Result := Zfm20FreeFingerprintBuffer(dataBuffer);
end;

end.

