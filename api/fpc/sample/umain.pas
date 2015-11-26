{ ZFM-20 series fingerprint library demo application for Lazarus/FPC.

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

unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, zfm20;

type
  { TfrmMain }
  TfrmMain = class(TForm)
    btnCheck: TButton;
    btnCapture: TButton;
    btnGet: TButton;
    btnSave: TButton;
    dlgFileSave: TSaveDialog;
    txtPort: TEdit;
    txtBaud: TEdit;
    txtDevID: TEdit;
    grpOptions: TGroupBox;
    grpPreview: TGroupBox;
    grpHelp: TGroupBox;
    imgPreview: TImage;
    imgHelp: TImage;
    lblPort: TLabel;
    lblBaud: TLabel;
    lblDevID: TLabel;
    lblHelp: TLabel;
    procedure btnCaptureClick(Sender: TObject);
    procedure btnCheckClick(Sender: TObject);
    procedure btnGetClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    function UpdateSensorSettings(): Boolean;
    function ZfmStatusToString(inStatus: TZfmStatus): string;
  private
    zfmSensor: TZfm20Fingerprint;
  end;

var
  frmMain: TfrmMain;

const
  // Default COM port settings.
  DEFAULT_COM_PORT = 'COM3';
  DEFAULT_BAUD_RATE = 57600;

  // Size of the fingerprint image.
  IMG_WIDTH = 256;
  IMG_HEIGHT = 288;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  zfmSensor := TZfm20Fingerprint.Create(DEFAULT_COM_PORT, DEFAULT_BAUD_RATE);
end;

// Function to convert ZfmStatus to human readable string.
function TfrmMain.ZfmStatusToString(inStatus: TZfmStatus): string;
begin
  case inStatus of
    ZsUnknownError: Result := 'Unknown error has occurred.';
    ZsTimeout: Result := 'Communication timeout with sensor.';
    ZsNoFinger: Result := 'Finger is not available.';
    ZsFingerCollectError: Result := 'Finger collection error.';
    ZsBadResponse: Result := 'Communication failure with sensor.';
    ZsDataError: Result := 'Data format error.';
    ZsIoError: Result := 'Data I/O error occurred.';
    ZsMemoryError: Result := 'Memory error has been occurred.';
  else
    Result := '';
  end;
end;

procedure TfrmMain.btnCheckClick(Sender: TObject);
var
  msgText: String;
begin
  try
    if(UpdateSensorSettings) then
    begin
      if(zfmSensor.IsAvailable()) then
        msgText := 'Fingerprint sensor is available.'
      else
        msgText := 'Fingerprint sensor is not available.'#10#13'Check sensor configuration options.';
      MessageDlg(Application.Title, msgText, TMsgDlgType.mtInformation, [mbOK], 0)
    end;
  except
    on ex: Exception do
      MessageDlg(Application.Title, ex.Message, TMsgDlgType.mtError, [mbOK], 0);
  end;
end;

procedure TfrmMain.btnGetClick(Sender: TObject);
var
  downloadStatus: TZfmStatus;
  dataBuffer: PByte;
  dataBufferSize, bufferPos: LongWord;
  posX, posY: Word;
  previewBmp: TBitmap;
  colorByte: Byte;
begin
  try
    if(UpdateSensorSettings) then
    begin
      dataBuffer := nil;
      dataBufferSize := 0;
      downloadStatus := zfmSensor.GetFingerprintBuffer(dataBuffer, dataBufferSize);
      self.Update;
      if(downloadStatus = ZsSuccessful) then
      begin
        if(dataBufferSize > 0) then
        begin
          // Create output bitmap buffer object.
          previewBmp := TBitmap.Create;
          previewBmp.Width := IMG_WIDTH;
          previewBmp.Height :=IMG_HEIGHT;
          previewBmp.PixelFormat := pf24bit;

          bufferPos := 0;

          // Paint bitmap buffer with received data buffer content.
          for posY := 0 to (IMG_HEIGHT - 1) do
          begin
            for posX := 0 to (IMG_WIDTH - 1) do
            begin
              colorByte := dataBuffer[bufferPos];
              previewBmp.Canvas.Pixels[posX, posY] := RGBToColor(colorByte, colorByte, colorByte);
              inc(bufferPos);
            end;
          end;

          // Flush data buffer and show bitmap on UI.
          zfmSensor.FreeFingerprintBuffer(dataBuffer);
          imgPreview.Picture.Bitmap := previewBmp;

        end
        else
          MessageDlg(Application.Title, 'Fingerprint image data is not available from the sensor library.', TMsgDlgType.mtWarning, [mbOK], 0);
      end
      else
        MessageDlg(Application.Title, ZfmStatusToString(downloadStatus), TMsgDlgType.mtWarning, [mbOK], 0);
    end;
  except
    on ex: Exception do
      MessageDlg(Application.Title, ex.Message, TMsgDlgType.mtError, [mbOK], 0);
  end;
end;

procedure TfrmMain.btnSaveClick(Sender: TObject);
var
  saveStatus: TZfmStatus;
begin
  try
    dlgFileSave.FileName := '';
    if(dlgFileSave.Execute) then
    begin
      // Check fingerprint image is already available in the UI.
      if((imgPreview.Picture.Bitmap <> nil) and (imgPreview.Picture.Bitmap.Width = IMG_WIDTH) and (imgPreview.Picture.Bitmap.Height = IMG_HEIGHT)) then
      begin
        imgPreview.Picture.Bitmap.SaveToFile(dlgFileSave.FileName);
      end
      else
      begin
        // Get fingerprint image from sensor ImageBuffer and save it to specified file.
        saveStatus := zfmSensor.SaveFingerprintToFile(dlgFileSave.FileName);
        if(saveStatus <> ZsSuccessful) then
          MessageDlg(Application.Title, ZfmStatusToString(saveStatus), TMsgDlgType.mtWarning, [mbOK], 0);
      end;
    end;
  except
    on ex: Exception do
      MessageDlg(Application.Title, ex.Message, TMsgDlgType.mtError, [mbOK], 0);
  end;
end;

procedure TfrmMain.btnCaptureClick(Sender: TObject);
var
  captureStatus: TZfmStatus;
begin
  try
    if(UpdateSensorSettings) then
    begin
      captureStatus := zfmSensor.Capture();
      if(captureStatus <> ZsSuccessful) then
        MessageDlg(Application.Title, ZfmStatusToString(captureStatus), TMsgDlgType.mtWarning, [mbOK], 0);
    end;
  except
    on ex: Exception do
      MessageDlg(Application.Title, ex.Message, TMsgDlgType.mtError, [mbOK], 0);
  end;
end;

// Update sensor settings based on UI control values.
function TfrmMain.UpdateSensorSettings(): Boolean;

  // Function to validate content of specified string and show message if it's empty.
  function IsStringEmpty(inStr: string; msgText: string): Boolean;
  begin
    Result := false;
    if(inStr = '') then
    begin
      MessageDlg(Application.Title, msgText, TMsgDlgType.mtError, [mbOK], 0);
      Result:= true;
    end;
  end;

var
  tempVal: string;
  baudRate: Integer;
  devID: LongWord;
begin
  Result := false;
  if(Assigned(zfmSensor)) then
  begin
    // Validate text data fields.
    tempVal := Trim(txtPort.Text);
    if(IsStringEmpty(tempVal, 'Port value is not specified.')) then
      exit;

    // Validate numerical data fields.
    if(tempVal <> zfmSensor.Port) then
      zfmSensor.Port := tempVal;

    tempVal := Trim(txtBaud.Text);
    if(IsStringEmpty(tempVal, 'Baud rate value is not specified.')) then
      exit;
    baudRate := StrToIntDef(tempVal, zfmSensor.BaudRate);

    if(baudRate <> zfmSensor.BaudRate) then
      zfmSensor.BaudRate := baudRate;

    tempVal := Trim(txtDevID.Text);
    if(IsStringEmpty(tempVal, 'Sensor ID is not specified.')) then
      exit;
    devID := StrToIntDef(('$' + tempVal), zfmSensor.DeviceID);

    if(devID <> zfmSensor.DeviceID) then
      zfmSensor.DeviceID := devID;

    Result := true;
  end;
end;

end.

