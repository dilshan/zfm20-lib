/* ZFM-20 series fingerprint library Microsoft.net wrapper.

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
using System.Runtime.InteropServices;

namespace zfm20
{
	public class Zfm20Fingerprint
	{
		public enum ZfmStatus
		{
			ZsUnknownError = 0, 
			ZsSuccessful, 
			ZsTimeout, 
			ZsNoFinger, 
			ZsFingerCollectError,
			ZsBadResponse,
			ZsDataError, 
			ZsIoError, 
			ZsMemoryError
		}

		[DllImport("zfm20lib.dll", CallingConvention = CallingConvention.StdCall)]
		private static extern ZfmStatus Zfm20CaptureFingerprint(string comPort, Int32 baudRate, UInt32 sensorAddr);

		[DllImport("zfm20lib.dll", CallingConvention = CallingConvention.StdCall)]
		private static extern ZfmStatus Zfm20SensorAvailable(string comPort, Int32 baudRate, UInt32 sensorAddr);

		[DllImport("zfm20lib.dll", CallingConvention = CallingConvention.StdCall)]
		private static extern ZfmStatus Zfm20SaveFingerprintImage(string comPort, Int32 baudRate, UInt32 sensorAddr, string fileName);

		[DllImport("zfm20lib.dll", CallingConvention = CallingConvention.StdCall)]
		private static extern ZfmStatus Zfm20FreeFingerprintBuffer(ref IntPtr dataBuffer);

		[DllImport("zfm20lib.dll", CallingConvention = CallingConvention.StdCall)]
		private static extern ZfmStatus Zfm20GetFingerprintBuffer(string comPort, Int32 baudRate, UInt32 sensorAddr, out UInt32 outBufferSize, out IntPtr outBuffer);

		private string _pComPort;
		private Int32 _pBaud;
		private UInt32 _pDevId;

		/// <summary>
		/// Communication port address or value. 
		/// </summary>
		public string Port
		{
			get { return _pComPort; }
			set { _pComPort = value; }
		}

		/// <summary>
		/// Communication port baud rate. (Default baud rate for ZFM-20 sensor is 56700.) 
		/// </summary>
		public int BaudRate
		{
			get { return _pBaud; }
			set { _pBaud = value; }
		}

		/// <summary>
		/// Sensor ID. (Default ZFM-20 sensor ID is 0xFFFFFFFF.)  
		/// </summary>
		public uint DeviceID
		{
			get { return _pDevId; }
			set { _pDevId = value; }
		}

		/// <summary>
		/// Constructor.
		/// </summary>
		/// <param name="portName">Communication port address or value.</param>
		/// <param name="baudRate">Communication port baud rate.</param>
		public Zfm20Fingerprint(string portName, int baudRate)
		{
			_pComPort = portName;
			_pBaud = baudRate;
			_pDevId = 0xFFFFFFFF;
		}

		/// <summary>
		/// Check availability of fingerprint sensor. 
		/// </summary>
		/// <returns>True if fingerprint sensor is available, otherwise this function returns False.</returns>
		public bool IsAvailable()
		{
			return (Zfm20SensorAvailable(_pComPort, _pBaud, _pDevId) == ZfmStatus.ZsSuccessful);
		}

		/// <summary>
		/// Send capture command to sensor module.
		/// </summary>
		/// <returns>Sensor status or communication status.</returns>
		public ZfmStatus Capture()
		{
			return Zfm20CaptureFingerprint(_pComPort, _pBaud, _pDevId);
		}

		/// <summary>
		/// Save content of sensor's ImageBuffer to specified bitmap file. 
		/// </summary>
		/// <param name="fileName">Filename to save sensor's ImageBuffer.</param>
		/// <returns>Sensor status or communication status.</returns>
		public ZfmStatus SaveFingerprintToFile(string fileName)
		{
			return Zfm20SaveFingerprintImage(_pComPort, _pBaud, _pDevId, fileName);
		}

		/// <summary>
		/// Get content of sensor ImageBuffer as buffer. 
		/// </summary>
		/// <param name="dataBuffer">Data buffer which contain processed sensor ImageBuffer data.</param>
		/// <param name="dataBufferSize">Size of the returned data buffer.</param>
		/// <returns>Sensor status or communication status.</returns>
		public ZfmStatus GetFingerprintBuffer(out IntPtr dataBuffer, out uint dataBufferSize)
		{
			return Zfm20GetFingerprintBuffer(_pComPort, _pBaud, _pDevId, out dataBufferSize, out dataBuffer);
		}

		/// <summary>
		/// Flush allocated fingerprint image buffer. 
		/// </summary>
		/// <param name="dataBuffer">Data buffer to clean.</param>
		/// <returns>Status of the clean operation.</returns>
		public ZfmStatus FreeFingerprintBuffer(ref IntPtr dataBuffer)
		{
			return Zfm20FreeFingerprintBuffer(ref dataBuffer);
		}

	}
}
