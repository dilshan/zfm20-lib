{ ZFM-20 series fingerprint sensor support library.

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

unit uzfm;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

const
  ZFM_BASE_PACKAGE_SIZE = 11; // Size of the request package excluding payload buffer.
  ZFM_STATIC_HEADER_SIZE = 6; // Size of the static part of the request.

  ZFM_CMD_HANDSHAKE = $17; // Communicate link.
  ZFM_CMD_GEN_IMG = $01; // Collect finger image.
  ZFM_CMD_UPLOAD_IMG = $0A; // Upload the image in ImgBuffer to upper computer.

  ZFM_PACKAGE_ID_ACK = $07; // Acknowledge packet.
  ZFM_PACKAGE_ID_CMD = $01; // Command packet.
  ZFM_PACKAGE_ID_DATA = $02; // Data packet.
  ZFM_PACKAGE_ID_END = $08; // End of Data packet.

type
  TZfmBuffer = array of byte;
  TZfmCommandType = (tzCmd, tzData, tzAck, tzEnd);

  TZfmSensor = class(TObject)
  public
    constructor Create;
    function CreateZfmPackage(CmdType: TZfmCommandType; Data: TZfmBuffer): TZfmBuffer;
    function CreateZfmCommand(Data: TZfmBuffer): TZfmBuffer;
    procedure SetSensorAddress(SensorAddr: TZfmBuffer);
    function DecodeZfmAcknowledge(AckData: TZfmBuffer; out Data: TZfmBuffer): Boolean;
    function IsValidSensorHeader(inBuffer: TZfmBuffer): Boolean;
  private
    headerArray : array [1..ZFM_STATIC_HEADER_SIZE] of byte;
    function GetPackageIDByte(CmdType: TZfmCommandType): Byte;
  end;

implementation

constructor TZfmSensor.Create;
const
  defaultHeader : array [1..ZFM_STATIC_HEADER_SIZE] of byte = ($EF, $01, $FF, $FF, $FF, $FF);
begin
  Move(defaultHeader[1], headerArray[1], ZFM_STATIC_HEADER_SIZE);
end;

// Assign new sensor address to ZFM sensor module.
procedure TZfmSensor.SetSensorAddress(SensorAddr: TZfmBuffer);
begin
  Move(SensorAddr[0], headerArray[3], 4);
end;

// Function to convert TZfmCommandType to byte.
function TZfmSensor.GetPackageIDByte(CmdType: TZfmCommandType): Byte;
begin
  Result := ZFM_PACKAGE_ID_CMD;
  case CmdType of
    tzData : Result := ZFM_PACKAGE_ID_DATA;
    tzAck : Result := ZFM_PACKAGE_ID_ACK;
    tzEnd : Result := ZFM_PACKAGE_ID_END;
  end;
end;

// Create ZFM-20 series compatiable package based on specified command type and data buffer.
function TZfmSensor.CreateZfmPackage(CmdType: TZfmCommandType; Data: TZfmBuffer): TZfmBuffer;
var
  outputDataBuffer: TZfmBuffer;
  dataLength, tmpPos: Word;
  checkSum: LongWord;
begin
  SetLength(outputDataBuffer, ZFM_BASE_PACKAGE_SIZE + Length(Data));

  // Move static header part to output buffer.
  Move(headerArray[1], outputDataBuffer[0], ZFM_STATIC_HEADER_SIZE);
  outputDataBuffer[6] := GetPackageIDByte(CmdType);

  // Size of the payload buffer.
  dataLength := 2 + Length(Data);
  outputDataBuffer[7] := Hi(dataLength);
  outputDataBuffer[8] := Lo(dataLength);

  // Copy payload to output buffer.
  if(Length(Data) > 0) then
  begin
    Move(Data[0], outputDataBuffer[9], Length(Data));
  end;

  // Calculate checksum for output buffer.
  checkSum := outputDataBuffer[6] + dataLength;
  for tmpPos := 0 to (Length(Data) - 1) do
  begin
    checkSum := checkSum + Data[tmpPos];
  end;

  outputDataBuffer[Length(outputDataBuffer) - 2] := Lo(checkSum shr 8);
  outputDataBuffer[Length(outputDataBuffer) - 1] := Lo(checkSum);

  Result := outputDataBuffer;
end;

// Send command to ZFM-20 series sensor.
function TZfmSensor.CreateZfmCommand(Data: TZfmBuffer): TZfmBuffer;
begin
  Result := CreateZfmPackage(tzCmd, Data);
end;

// Decode acknowledge package and extract data.
function TZfmSensor.DecodeZfmAcknowledge(AckData: TZfmBuffer; out Data: TZfmBuffer): Boolean;
var
  dataLen: Integer;
begin
  SetLength(Data, 0);
  Result := false;
  if(Length(AckData) > 0) then
  begin
    // Validate header and chip address values.
    if(CompareMem(@AckData[0], @headerArray[1], ZFM_STATIC_HEADER_SIZE)) then
    begin
      // Check package ID for acknowledge byte.
      if(AckData[6] = ZFM_PACKAGE_ID_ACK)then
      begin
        // Extract data size and copy content to output data buffer.
        dataLen := Integer((AckData[8] + (AckData[7] shl 8))) - 2;
        if(dataLen > 0) then
        begin
          SetLength(Data, dataLen);
          Move(AckData[9], Data[0], dataLen);
          Result := true;
        end;
      end;
    end;
  end;
end;

// Check specified buffer contain valid sensor response header.
function TZfmSensor.IsValidSensorHeader(inBuffer: TZfmBuffer): Boolean;
begin
  Result := false;
  if(Length(inBuffer) >= ZFM_STATIC_HEADER_SIZE) then
  begin
    Result := CompareMem(@inBuffer[0], @headerArray[1], ZFM_STATIC_HEADER_SIZE);
  end;
end;

end.

