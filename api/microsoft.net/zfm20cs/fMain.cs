/* ZFM-20 series fingerprint library demo application for Visual C#.

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
*/

using System;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using zfm20;

namespace zfm20cs
{
	public partial class FrmMain : Form
	{
        // Default COM port settings. 
        private const string DefaultComPort = "COM3";
		private const int DefaultBaudRate = 57600;

        // Size of the fingerprint image. 
		private const int ImageWidth = 256;
		private const int ImageHeight = 288;
		
		private Zfm20Fingerprint _zfmSensor;
		
		public FrmMain()
		{
			InitializeComponent();
		}

		private void FrmMain_Load(object sender, EventArgs e)
		{
			_zfmSensor = new Zfm20Fingerprint(DefaultComPort, DefaultBaudRate);
		}

        // Function to convert ZfmStatus to human readable string.
		private string ZfmStatusToString(Zfm20Fingerprint.ZfmStatus inStatus)
		{
			switch (inStatus)
			{
				case Zfm20Fingerprint.ZfmStatus.ZsUnknownError:
					return @"Unknown error has occurred.";
				case Zfm20Fingerprint.ZfmStatus.ZsTimeout:
					return @"Communication timeout with sensor.";
				case Zfm20Fingerprint.ZfmStatus.ZsNoFinger:
					return @"Finger is not available.";
				case Zfm20Fingerprint.ZfmStatus.ZsFingerCollectError:
					return @"Finger collection error.";
				case Zfm20Fingerprint.ZfmStatus.ZsBadResponse:
					return @"Communication failure with sensor.";
				case Zfm20Fingerprint.ZfmStatus.ZsDataError:
					return @"Data format error.";
				case Zfm20Fingerprint.ZfmStatus.ZsIoError:
					return @"Data I/O error occurred.";
				case Zfm20Fingerprint.ZfmStatus.ZsMemoryError:
					return @"Memory error has been occurred.";
				default:
					return string.Empty;
			}
		}

        // Update sensor settings based on UI control values.
		private bool UpdateSensorSettings()
		{
			if (_zfmSensor != null)
			{
                // Validate text data fields.
                string tempVal = txtPort.Text.Trim();
				if (tempVal == string.Empty)
				{
					MessageBox.Show(@"Port value is not specified.", Text, MessageBoxButtons.OK, MessageBoxIcon.Warning);
					return false;
				}
                
				if(tempVal != _zfmSensor.Port)
					_zfmSensor.Port = tempVal;

                // Validate numerical data fields.
				tempVal = txtBaud.Text.Trim();
				if (tempVal == string.Empty)
				{
					MessageBox.Show(@"Baud rate value is not specified.", Text, MessageBoxButtons.OK, MessageBoxIcon.Warning);
					return false;
				}

				int tempNumVal;
				if ((int.TryParse(tempVal, out tempNumVal)) && (tempNumVal != _zfmSensor.BaudRate))
				{
					_zfmSensor.BaudRate = tempNumVal;
				}

				tempVal = txtDevID.Text.Trim();
				if (tempVal == string.Empty)
				{
					MessageBox.Show(@"Sensor ID is not specified.", Text, MessageBoxButtons.OK, MessageBoxIcon.Warning);
					return false;
				}

				tempVal = "0x" + tempVal;
				uint tempUNumVal;
				if ((uint.TryParse(tempVal, out tempUNumVal)) && (tempUNumVal != _zfmSensor.DeviceID))
				{
					_zfmSensor.DeviceID = tempUNumVal;
				}

				return true;
			}
				
			return false;
		}

		private void btnCheck_Click(object sender, EventArgs e)
		{
			try
			{				
				if (UpdateSensorSettings())
				{
					string msgText = _zfmSensor.IsAvailable() ? @"Fingerprint sensor is available." : "Fingerprint sensor is not available.\nCheck sensor configuration options.";
					MessageBox.Show(msgText, Text, MessageBoxButtons.OK, MessageBoxIcon.Information);
				}
			}
			catch (Exception ex)
			{
				MessageBox.Show(ex.Message, Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
			}
		}

		private void btnCapture_Click(object sender, EventArgs e)
		{
			try
			{
				if (UpdateSensorSettings())
				{
					Zfm20Fingerprint.ZfmStatus captureStatus = _zfmSensor.Capture();
					if (captureStatus != Zfm20Fingerprint.ZfmStatus.ZsSuccessful)
						MessageBox.Show(ZfmStatusToString(captureStatus), Text, MessageBoxButtons.OK, MessageBoxIcon.Warning);
				}
			}
			catch (Exception ex)
			{
				MessageBox.Show(ex.Message, Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
			}
		}

		private void btnDownload_Click(object sender, EventArgs e)
		{
			try
			{
				if (UpdateSensorSettings())
				{
					IntPtr dataBuffer;
					uint dataBufferSize;

					Zfm20Fingerprint.ZfmStatus downloadStatus = _zfmSensor.GetFingerprintBuffer(out dataBuffer, out dataBufferSize);
					if (downloadStatus == Zfm20Fingerprint.ZfmStatus.ZsSuccessful)
					{
						if (dataBufferSize > 0)
						{
                            // Create output bitmap buffer object. 
                            Bitmap outputImage = new Bitmap(ImageWidth, ImageHeight);
							byte[] colorBuffer = new byte[dataBufferSize];
							int bufferPos = 0;

							Marshal.Copy(dataBuffer, colorBuffer, 0, (int)(dataBufferSize - 1));

                            // Paint bitmap buffer with received data buffer content.
							for (int yPos = 0; yPos < ImageHeight; yPos++)
							{
								for (int xPos = 0; xPos < ImageWidth; xPos++)
								{
									outputImage.SetPixel(xPos, yPos, Color.FromArgb(colorBuffer[bufferPos], colorBuffer[bufferPos], colorBuffer[bufferPos]));
									bufferPos++;
								}
							}

                            // Flush data buffer and show bitmap on UI.
							_zfmSensor.FreeFingerprintBuffer(ref dataBuffer);
							imgPreview.Image = outputImage;
						}
						else
							MessageBox.Show(@"Fingerprint image data is not available from the sensor library.", Text, MessageBoxButtons.OK, MessageBoxIcon.Warning);
					}
					else
						MessageBox.Show(ZfmStatusToString(downloadStatus), Text, MessageBoxButtons.OK, MessageBoxIcon.Warning);
				}
			}
			catch (Exception ex)
			{
				MessageBox.Show(ex.Message, Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
			}
		}

		private void btnSave_Click(object sender, EventArgs e)
		{
            try
            {
                dlgSave.FileName = string.Empty;
                if (dlgSave.ShowDialog() == System.Windows.Forms.DialogResult.OK)
                {
                    // Check fingerprint image is already available in the UI.
                    if ((imgPreview.Image != null) && (imgPreview.Image.Width == ImageWidth) && (imgPreview.Image.Height == ImageHeight))
                    {
                        imgPreview.Image.Save(dlgSave.FileName);
                    }
                    else
                    {
                        // Get fingerprint image from sensor ImageBuffer and save it to specified file.
                        Zfm20Fingerprint.ZfmStatus saveStatus = _zfmSensor.SaveFingerprintToFile(dlgSave.FileName);
                        if(saveStatus != Zfm20Fingerprint.ZfmStatus.ZsSuccessful)
                            MessageBox.Show(ZfmStatusToString(saveStatus), Text, MessageBoxButtons.OK, MessageBoxIcon.Warning); 
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
		}
	}
}
