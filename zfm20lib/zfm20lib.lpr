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

library zfm20lib;

{$mode objfpc}{$H+}
{$hints off} {$warnings off} {$notes off}
uses
  SysUtils, uZfm, SynaSer, Classes, Graphics, Interfaces;
{$hints on} {$warnings off} {$notes on}

const
  COM_NUMBER_OF_BITS = 8; // Serial communication data bits count. (Default: 8)
  HEADER_SEGMENT_SIZE = 6; // Size of the response header and module address.
  MAX_ACK_BUFFER_SIZE = 32; // Default buffer size for ACK. response.
  COM_SLEEP_TIME = 25; // Serial communication default delay in miliseconds.
  TIME_OUT_LIMIT = 40; // Number of try counts for serial communication.
  MAX_DATA_PACKAGES = 2048; // Maximum allowed data packages for each upload session.

  IMG_WIDTH = 256; // Width of the fingerprint image.
  IMG_HEIGHT = 288; // Height of the fingerprint image.

type
  TZfmLibStatus = (zsUnknownError = 0, zsSuccessful, zsTimeout, zsNoFinger, zsFingerCollectError, zsBadResponse, zsDataError, zsIOError, zsMemoryError);

{$R *.res}

// Convert LongWord sensor address to byte buffer.
function SensorAddrToByteArray(inAddr: LongWord): TZfmBuffer;
var
  returnCode: TZfmBuffer;
begin
  SetLength(returnCode, 4);
  returnCode[0] := inAddr shr 24;
  returnCode[1] := inAddr shr 16;
  returnCode[2] := inAddr shr 8;
  returnCode[3] := inAddr and $000000ff;
  Result := returnCode;
end;

// Ping ZFM-20 series sensor and return the status.
function Zfm20SensorAvailable(comPort: PChar; baudRate: Integer; sensorAddr: LongWord): TZfmLibStatus; stdcall;
var
  dataReadCount, timeOutCounter: Integer;
  sensorIntf: TZfmSensor;
  comIntf: TBlockSerial;
  retData, payloadBuffer: TZfmBuffer;
  ackResponseBuffer: array[0..MAX_ACK_BUFFER_SIZE] of Byte;
  cmdBuffer: array[0..1] of Byte = (ZFM_CMD_HANDSHAKE, 0);
begin
  Result := zsUnknownError;
{$hints off}
  FillChar(ackResponseBuffer[0], Length(ackResponseBuffer), 0);
{$hints on}
  // Configure ZFM20 class object.
  sensorIntf := TZfmSensor.Create;
  sensorIntf.SetSensorAddress(SensorAddrToByteArray(sensorAddr));

  // Configure serial communication interface.
  comIntf := TBlockSerial.Create;
  comIntf.Connect(comPort);
  comIntf.Config(baudRate, COM_NUMBER_OF_BITS, 'N', SB1, false, false);

  payloadBuffer := sensorIntf.CreateZfmCommand(cmdBuffer);
  if(Length(payloadBuffer) > 0) then
  begin
    // Transfer handshake command to fingerprint sensor.
    comIntf.Purge;
    comIntf.SendBuffer(@payloadBuffer[0], Length(payloadBuffer));
    timeOutCounter := 0;

    // Waiting for response from sensor.
    repeat
      Inc(timeOutCounter);
      Sleep(COM_SLEEP_TIME);
      dataReadCount := comIntf.RecvBufferEx(@ackResponseBuffer, MAX_ACK_BUFFER_SIZE, COM_SLEEP_TIME * 4);
      if(timeOutCounter > TIME_OUT_LIMIT) then
      begin
        Result := zsTimeout;
        break;
      end;
    until (dataReadCount > 0);

    // Decode response received from sensor.
    sensorIntf.DecodeZfmAcknowledge(ackResponseBuffer, retData);
    if ((Length(retData) > 0) and (retData[0] = 0)) then
    begin
      Result := zsSuccessful;
    end;
  end;

  // Clean resources.
  if(Assigned(comIntf)) then
  begin
    comIntf.CloseSocket;
    FreeAndNil(comIntf);
  end;

  if(Assigned(sensorIntf)) then
  begin
    FreeAndNil(sensorIntf);
  end;
end;

// Issue fingerprint capture command to ZFM-20 series sensor.
function Zfm20CaptureFingerprint(comPort: PChar; baudRate: Integer; sensorAddr: LongWord): TZfmLibStatus; stdcall;
var
  dataReadCount, timeOutCounter: Integer;
  sensorIntf: TZfmSensor;
  comIntf: TBlockSerial;
  retData, payloadBuffer: TZfmBuffer;
  ackResponseBuffer: array[0..MAX_ACK_BUFFER_SIZE] of Byte;
  cmdBuffer: array[0..0] of Byte = (ZFM_CMD_GEN_IMG);
begin
  Result := zsUnknownError;
{$hints off}
  FillChar(ackResponseBuffer[0], Length(ackResponseBuffer), 0);
{$hints on}
  // Configure ZFM20 class object.
  sensorIntf := TZfmSensor.Create;
  sensorIntf.SetSensorAddress(SensorAddrToByteArray(sensorAddr));

  // Configure serial communication interface.
  comIntf := TBlockSerial.Create;
  comIntf.Connect(comPort);
  comIntf.Config(baudRate, COM_NUMBER_OF_BITS, 'N', SB1, false, false);

  payloadBuffer := sensorIntf.CreateZfmCommand(cmdBuffer);
  if(Length(payloadBuffer) > 0) then
  begin
    // Transfer fingerprint capture command to the sensor.
    comIntf.Purge;
    comIntf.SendBuffer(@payloadBuffer[0], Length(payloadBuffer));
    timeOutCounter := 0;

    // Waiting for response from sensor.
    repeat
      Inc(timeOutCounter);
      Sleep(COM_SLEEP_TIME);
      dataReadCount := comIntf.RecvBufferEx(@ackResponseBuffer, MAX_ACK_BUFFER_SIZE, COM_SLEEP_TIME * 4);
      if(timeOutCounter > TIME_OUT_LIMIT) then
      begin
        Result := zsTimeout;
        break;
      end;
    until (dataReadCount > 0);

    // Decode response received from sensor.
    sensorIntf.DecodeZfmAcknowledge(ackResponseBuffer, retData);
    if(Length(retData) > 0) then
    begin
      case retData[0] of
        0: Result := zsSuccessful;
        2: Result := zsNoFinger;
        3: Result := zsFingerCollectError;
      end;
    end;
  end;

  // Clean resources.
  if(Assigned(comIntf)) then
  begin
    comIntf.CloseSocket;
    FreeAndNil(comIntf);
  end;

  if(Assigned(sensorIntf)) then
  begin
    FreeAndNil(sensorIntf);
  end;
end;

// Extract fingerprint data from sensor response data stream.
function ExtractFingerprintImage(zfmObj: TZfmSensor; var inStream: TMemoryStream; out outStream: TMemoryStream): TZfmLibStatus;
var
  dataLen, packageCount: Word;
  packageID: Byte;
  tempBuffer: TZfmBuffer;
  headerSegment: array[0..(HEADER_SEGMENT_SIZE-1)] of Byte;

  // Function to calculate size of the response data buffer.
  function GetWord() : Word;
  var
  dataB1, dataB2 : Byte;
  begin
     dataB1 := inStream.ReadByte;
     dataB2 := inStream.ReadByte;
     result := Integer((dataB2 + (dataB1 shl 8))) - 2;
  end;

begin
  Result := zsUnknownError;
  if(Assigned(inStream) and Assigned(zfmObj)) then
  begin
    inStream.Position := 0;

    // Extract sensor response header to validate the input stream.
{$hints off}
    FillByte(headerSegment, HEADER_SEGMENT_SIZE, 0);
{$hints on}
    inStream.Read(headerSegment, HEADER_SEGMENT_SIZE);
    if(not zfmObj.IsValidSensorHeader(headerSegment)) then
    begin
      Result := zsBadResponse;
    end;

    // Check data package type and continue extraction.
    if((Result = zsUnknownError) and (inStream.ReadByte = ZFM_PACKAGE_ID_ACK)) then
    begin
      // Check status and skip trail bytes of the response.
      dataLen := inStream.ReadWord;
      if(inStream.ReadByte = 0) then
      begin
        inStream.ReadWord;
        outStream := TMemoryStream.Create;
        packageCount := 0;

        // Reading data contents.
        while true do
        begin
          FillByte(headerSegment, HEADER_SEGMENT_SIZE, 0);
          inStream.Read(headerSegment, HEADER_SEGMENT_SIZE);
          if(not zfmObj.IsValidSensorHeader(headerSegment)) then
          begin
            // Invalid response data header.
            Result := zsDataError;
            break;
          end;
          // Read package data content and copy it to output stream.
          packageID := inStream.ReadByte;
          dataLen := GetWord;
          SetLength(tempBuffer, dataLen);
          inStream.ReadBuffer(tempBuffer[0], dataLen);
          outStream.WriteBuffer(tempBuffer[0], dataLen);
          if(packageID = ZFM_PACKAGE_ID_DATA) then
            inStream.ReadWord
          else
            break;

          // Check for package space overflows to avoid freeze due to data error.
          Inc(packageCount);
          if(packageCount >= MAX_DATA_PACKAGES) then
          begin
            Result := zsDataError;
            Break;
          end;
        end;
        outStream.Position := 0;
        Result := zsSuccessful;
      end
      else
      begin
        Result := zsBadResponse;
      end;
    end;
  end;
end;

// Issue command to upload content of sensor ImageBuffer to host terminal.
function UploadImageBufferToHost(comPort: PChar; baudRate: Integer; sensorAddr: LongWord; out dataStream: TMemoryStream): TZfmLibStatus;
var
  timeOutCounter: Integer;
  sensorIntf: TZfmSensor;
  comIntf: TBlockSerial;
  sensorStream: TMemoryStream;
  payloadBuffer: TZfmBuffer;
  cmdBuffer: array[0..0] of byte = (ZFM_CMD_UPLOAD_IMG);
begin
  Result := zsUnknownError;

  // Configure ZFM20 class object.
  sensorIntf := TZfmSensor.Create;
  sensorIntf.SetSensorAddress(SensorAddrToByteArray(sensorAddr));

  // Configure serial communication interface.
  comIntf := TBlockSerial.Create;
  comIntf.Connect(comPort);
  comIntf.Config(baudRate, COM_NUMBER_OF_BITS, 'N', SB1, false, false);

  payloadBuffer := sensorIntf.CreateZfmCommand(cmdBuffer);
  if(Length(payloadBuffer) > 0) then
  begin
    // Transfer image buffer download command to the sensor.
    comIntf.Purge;
    comIntf.SendBuffer(@payloadBuffer[0], Length(payloadBuffer));
    timeOutCounter := 0;

    // Waiting for data stream from sensor.
    repeat
      Inc(timeOutCounter);
      Sleep(COM_SLEEP_TIME);
      if(timeOutCounter > TIME_OUT_LIMIT) then
      begin
        Result := zsTimeout;
        break;
      end;
    until comIntf.CanRead(COM_SLEEP_TIME * 6);

    // Downloading data stream from sensor module.
    if(Result <> zsTimeout) then
    begin
      sensorStream := TMemoryStream.Create;
      comIntf.RecvStreamRaw(sensorStream, COM_SLEEP_TIME * 4);
      if(sensorStream.Size > 0) then
      begin
        // Data downloading from sensor is completed.
        Result := ExtractFingerprintImage(sensorIntf, sensorStream, dataStream);
      end
      else
        Result := zsBadResponse;
    end;
  end;

  // Clean resources.
  if(Assigned(sensorStream)) then
  begin
    sensorStream.Clear;
    FreeAndNil(sensorStream);
  end;

  if(Assigned(comIntf)) then
  begin
    comIntf.CloseSocket;
    FreeAndNil(comIntf);
  end;

  if(Assigned(sensorIntf)) then
  begin
    FreeAndNil(sensorIntf);
  end;
end;

// Load ImageBuffer content from sensor and draw it on TBitmap canvas.
function UploadImageBufferToBitmap(comPort: PChar; baudRate: Integer; sensorAddr: LongWord; out bitmapBuffer: TBitmap): TZfmLibStatus;
var
  isLowNibble: Boolean;
  posX, posY: Word;
  sensData, colorData: Byte;
  dataBuffer: TMemoryStream;
begin
  Result := UploadImageBufferToHost(comPort, baudRate, sensorAddr, dataBuffer);
  if(Result = zsSuccessful) then
  begin
    try
      // Setup output image.
      bitmapBuffer := TBitmap.Create;
      bitmapBuffer.Width := IMG_WIDTH;
      bitmapBuffer.Height := IMG_HEIGHT;
      bitmapBuffer.PixelFormat := pf24bit;

      dataBuffer.Position := 0;
      isLowNibble := false;

      // Draw fingerprint image on bitmap canvas.
      for posY := 0 to (IMG_HEIGHT - 1) do
      begin
        for posX := 0 to (IMG_WIDTH - 1) do
        begin
          // Extract nibble from stream and convert it to hi-byte.
          if(not isLowNibble) then
          begin
            sensData := dataBuffer.ReadByte;
            colorData := sensData and $f0;
          end
          else
          begin
            colorData := (sensData and $0f) shl 4;
          end;

          isLowNibble := not isLowNibble;
          bitmapBuffer.Canvas.Pixels[posX, posY] := RGBToColor(colorData, colorData, colorData);
        end;
      end;
    except
      // General exception. Fail the current task and return memory error.
      Result := zsMemoryError;
    end;
  end;

  // Clean resources.
  if(Assigned(dataBuffer)) then
  begin
    dataBuffer.Clear;
    FreeAndNil(dataBuffer);
  end;
end;

// Load ImageBuffer content from sensor and save it to specified filename as bitmap image.
function Zfm20SaveFingerprintImage(comPort: PChar; baudRate: Integer; sensorAddr: LongWord; fileName: PChar): TZfmLibStatus; stdcall;
var
  bitmapBuffer: TBitmap;
begin
  try
     Result := UploadImageBufferToBitmap(comPort, baudRate, sensorAddr, bitmapBuffer);
     if(Result = zsSuccessful) then
     begin
       bitmapBuffer.SaveToFile(fileName);
     end;
  except
    // General exception. Fail the current task and return memory error.
      Result := zsIOError;
  end;

  // Clean resources.
  if(Assigned(bitmapBuffer)) then
  begin
    bitmapBuffer.Clear;
    FreeAndNil(bitmapBuffer);
  end;
end;

// Load ImageBuffer content from sensor and save it to memory buffer.
function Zfm20GetFingerprintBuffer(comPort: PChar; baudRate: Integer; sensorAddr: LongWord; var outBufferSize: LongWord; var outBuffer: PByte): TZfmLibStatus; stdcall;
var
  isLowNibble: Boolean;
  posX, posY: Word;
  sensData, colorData: Byte;
  dataBuffer: TMemoryStream;
  addressCounter: LongWord;
begin
  Result := UploadImageBufferToHost(comPort, baudRate, sensorAddr, dataBuffer);
  if(Result = zsSuccessful) then
  begin
    try
      // Setup output buffer.
      outBufferSize := IMG_HEIGHT * IMG_WIDTH;
      outBuffer := AllocMem(outBufferSize);
      addressCounter := 0;

      dataBuffer.Position := 0;
      isLowNibble := false;

      // Draw fingerprint image on bitmap canvas.
      for posY := 0 to (IMG_HEIGHT - 1) do
      begin
        for posX := 0 to (IMG_WIDTH - 1) do
        begin
          // Extract nibble from stream and convert it to hi-byte.
          if(not isLowNibble) then
          begin
            sensData := dataBuffer.ReadByte;
            colorData := sensData and $f0;
          end
          else
          begin
            colorData := (sensData and $0f) shl 4;
          end;

          isLowNibble := not isLowNibble;
          outBuffer[addressCounter] := colorData;
          Inc(addressCounter);
        end;
      end;
    except
      // General exception. Fail the current task and return memory error.
      Result := zsMemoryError;
    end;
  end;

  // Clean resources.
  if(Assigned(dataBuffer)) then
  begin
    dataBuffer.Clear;
    FreeAndNil(dataBuffer);
  end;
end;

// Function to free allocated memory buffer(s).
function Zfm20FreeFingerprintBuffer(var dataBuffer: PByte): TZfmLibStatus; stdcall;
begin
  Result := zsUnknownError;
  try
    Freemem(dataBuffer, (IMG_HEIGHT * IMG_WIDTH));
    Result := zsSuccessful;
  except
    Result := zsMemoryError;
  end;
end;

exports
  Zfm20SensorAvailable, Zfm20CaptureFingerprint, Zfm20SaveFingerprintImage,
  Zfm20GetFingerprintBuffer, Zfm20FreeFingerprintBuffer;

begin
end.

