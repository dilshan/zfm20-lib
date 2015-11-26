namespace zfm20cs
{
	partial class FrmMain
	{
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.IContainer components = null;

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		/// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
		protected override void Dispose(bool disposing)
		{
			if (disposing && (components != null))
			{
				components.Dispose();
			}
			base.Dispose(disposing);
		}

		#region Windows Form Designer generated code

		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FrmMain));
            this.grpOptions = new System.Windows.Forms.GroupBox();
            this.txtDevID = new System.Windows.Forms.TextBox();
            this.lblDevID = new System.Windows.Forms.Label();
            this.txtBaud = new System.Windows.Forms.TextBox();
            this.lblBaud = new System.Windows.Forms.Label();
            this.txtPort = new System.Windows.Forms.TextBox();
            this.lblPort = new System.Windows.Forms.Label();
            this.grpHelp = new System.Windows.Forms.GroupBox();
            this.lblHelp = new System.Windows.Forms.Label();
            this.imgHelp = new System.Windows.Forms.PictureBox();
            this.grpPreview = new System.Windows.Forms.GroupBox();
            this.imgPreview = new System.Windows.Forms.PictureBox();
            this.btnCheck = new System.Windows.Forms.Button();
            this.btnCapture = new System.Windows.Forms.Button();
            this.btnDownload = new System.Windows.Forms.Button();
            this.btnSave = new System.Windows.Forms.Button();
            this.dlgSave = new System.Windows.Forms.SaveFileDialog();
            this.grpOptions.SuspendLayout();
            this.grpHelp.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.imgHelp)).BeginInit();
            this.grpPreview.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.imgPreview)).BeginInit();
            this.SuspendLayout();
            // 
            // grpOptions
            // 
            this.grpOptions.Controls.Add(this.txtDevID);
            this.grpOptions.Controls.Add(this.lblDevID);
            this.grpOptions.Controls.Add(this.txtBaud);
            this.grpOptions.Controls.Add(this.lblBaud);
            this.grpOptions.Controls.Add(this.txtPort);
            this.grpOptions.Controls.Add(this.lblPort);
            this.grpOptions.Location = new System.Drawing.Point(12, 12);
            this.grpOptions.Name = "grpOptions";
            this.grpOptions.Size = new System.Drawing.Size(384, 57);
            this.grpOptions.TabIndex = 0;
            this.grpOptions.TabStop = false;
            this.grpOptions.Text = " Options ";
            // 
            // txtDevID
            // 
            this.txtDevID.Location = new System.Drawing.Point(295, 22);
            this.txtDevID.Name = "txtDevID";
            this.txtDevID.Size = new System.Drawing.Size(75, 20);
            this.txtDevID.TabIndex = 5;
            this.txtDevID.Text = "FFFFFFFF";
            // 
            // lblDevID
            // 
            this.lblDevID.AutoSize = true;
            this.lblDevID.Location = new System.Drawing.Point(231, 25);
            this.lblDevID.Name = "lblDevID";
            this.lblDevID.Size = new System.Drawing.Size(58, 13);
            this.lblDevID.TabIndex = 4;
            this.lblDevID.Text = "D&evice ID:";
            // 
            // txtBaud
            // 
            this.txtBaud.Location = new System.Drawing.Point(155, 22);
            this.txtBaud.Name = "txtBaud";
            this.txtBaud.Size = new System.Drawing.Size(70, 20);
            this.txtBaud.TabIndex = 3;
            this.txtBaud.Text = "57600";
            // 
            // lblBaud
            // 
            this.lblBaud.AutoSize = true;
            this.lblBaud.Location = new System.Drawing.Point(114, 25);
            this.lblBaud.Name = "lblBaud";
            this.lblBaud.Size = new System.Drawing.Size(35, 13);
            this.lblBaud.TabIndex = 2;
            this.lblBaud.Text = "&Baud:";
            // 
            // txtPort
            // 
            this.txtPort.Location = new System.Drawing.Point(38, 22);
            this.txtPort.Name = "txtPort";
            this.txtPort.Size = new System.Drawing.Size(70, 20);
            this.txtPort.TabIndex = 1;
            this.txtPort.Text = "COM3";
            // 
            // lblPort
            // 
            this.lblPort.AutoSize = true;
            this.lblPort.Location = new System.Drawing.Point(6, 25);
            this.lblPort.Name = "lblPort";
            this.lblPort.Size = new System.Drawing.Size(29, 13);
            this.lblPort.TabIndex = 0;
            this.lblPort.Text = "&Port:";
            // 
            // grpHelp
            // 
            this.grpHelp.Controls.Add(this.lblHelp);
            this.grpHelp.Controls.Add(this.imgHelp);
            this.grpHelp.Location = new System.Drawing.Point(12, 399);
            this.grpHelp.Name = "grpHelp";
            this.grpHelp.Size = new System.Drawing.Size(384, 64);
            this.grpHelp.TabIndex = 6;
            this.grpHelp.TabStop = false;
            // 
            // lblHelp
            // 
            this.lblHelp.Location = new System.Drawing.Point(39, 14);
            this.lblHelp.Name = "lblHelp";
            this.lblHelp.Size = new System.Drawing.Size(337, 45);
            this.lblHelp.TabIndex = 0;
            this.lblHelp.Text = "To capture fingerprint hold finger to the sensor and press \"Capture\" button. To g" +
    "et captured fingerprint image press \"Download\" button. In serial interface downl" +
    "oad take some time to complete.";
            // 
            // imgHelp
            // 
            this.imgHelp.Image = global::zfm20cs.Properties.Resources.help_icon;
            this.imgHelp.Location = new System.Drawing.Point(6, 14);
            this.imgHelp.Name = "imgHelp";
            this.imgHelp.Size = new System.Drawing.Size(26, 25);
            this.imgHelp.TabIndex = 0;
            this.imgHelp.TabStop = false;
            // 
            // grpPreview
            // 
            this.grpPreview.Controls.Add(this.imgPreview);
            this.grpPreview.Location = new System.Drawing.Point(119, 75);
            this.grpPreview.Name = "grpPreview";
            this.grpPreview.Size = new System.Drawing.Size(277, 319);
            this.grpPreview.TabIndex = 5;
            this.grpPreview.TabStop = false;
            this.grpPreview.Text = " Preview ";
            // 
            // imgPreview
            // 
            this.imgPreview.Location = new System.Drawing.Point(11, 19);
            this.imgPreview.Name = "imgPreview";
            this.imgPreview.Size = new System.Drawing.Size(256, 288);
            this.imgPreview.TabIndex = 0;
            this.imgPreview.TabStop = false;
            // 
            // btnCheck
            // 
            this.btnCheck.Location = new System.Drawing.Point(12, 75);
            this.btnCheck.Name = "btnCheck";
            this.btnCheck.Size = new System.Drawing.Size(98, 23);
            this.btnCheck.TabIndex = 1;
            this.btnCheck.Text = "&Availability";
            this.btnCheck.UseVisualStyleBackColor = true;
            this.btnCheck.Click += new System.EventHandler(this.btnCheck_Click);
            // 
            // btnCapture
            // 
            this.btnCapture.Location = new System.Drawing.Point(12, 104);
            this.btnCapture.Name = "btnCapture";
            this.btnCapture.Size = new System.Drawing.Size(98, 23);
            this.btnCapture.TabIndex = 2;
            this.btnCapture.Text = "&Capture";
            this.btnCapture.UseVisualStyleBackColor = true;
            this.btnCapture.Click += new System.EventHandler(this.btnCapture_Click);
            // 
            // btnDownload
            // 
            this.btnDownload.Location = new System.Drawing.Point(12, 133);
            this.btnDownload.Name = "btnDownload";
            this.btnDownload.Size = new System.Drawing.Size(98, 23);
            this.btnDownload.TabIndex = 3;
            this.btnDownload.Text = "&Download";
            this.btnDownload.UseVisualStyleBackColor = true;
            this.btnDownload.Click += new System.EventHandler(this.btnDownload_Click);
            // 
            // btnSave
            // 
            this.btnSave.Location = new System.Drawing.Point(12, 162);
            this.btnSave.Name = "btnSave";
            this.btnSave.Size = new System.Drawing.Size(98, 23);
            this.btnSave.TabIndex = 4;
            this.btnSave.Text = "&Save";
            this.btnSave.UseVisualStyleBackColor = true;
            this.btnSave.Click += new System.EventHandler(this.btnSave_Click);
            // 
            // dlgSave
            // 
            this.dlgSave.CheckFileExists = true;
            this.dlgSave.DefaultExt = "bmp";
            this.dlgSave.Filter = "24-bit Bitmap file (*.bmp)|*.bmp";
            this.dlgSave.Title = "Save file as...";
            // 
            // FrmMain
            // 
            this.AcceptButton = this.btnCheck;
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(408, 474);
            this.Controls.Add(this.btnSave);
            this.Controls.Add(this.btnDownload);
            this.Controls.Add(this.btnCapture);
            this.Controls.Add(this.btnCheck);
            this.Controls.Add(this.grpHelp);
            this.Controls.Add(this.grpPreview);
            this.Controls.Add(this.grpOptions);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MaximizeBox = false;
            this.Name = "FrmMain";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "ZFM20 Fingerprint Demo";
            this.Load += new System.EventHandler(this.FrmMain_Load);
            this.grpOptions.ResumeLayout(false);
            this.grpOptions.PerformLayout();
            this.grpHelp.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.imgHelp)).EndInit();
            this.grpPreview.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.imgPreview)).EndInit();
            this.ResumeLayout(false);

		}

		#endregion

		private System.Windows.Forms.GroupBox grpOptions;
		private System.Windows.Forms.Label lblDevID;
		private System.Windows.Forms.TextBox txtBaud;
		private System.Windows.Forms.Label lblBaud;
		private System.Windows.Forms.TextBox txtPort;
		private System.Windows.Forms.Label lblPort;
		private System.Windows.Forms.TextBox txtDevID;
		private System.Windows.Forms.GroupBox grpHelp;
		private System.Windows.Forms.PictureBox imgHelp;
		private System.Windows.Forms.GroupBox grpPreview;
		private System.Windows.Forms.PictureBox imgPreview;
		private System.Windows.Forms.Button btnCheck;
		private System.Windows.Forms.Button btnCapture;
		private System.Windows.Forms.Button btnDownload;
		private System.Windows.Forms.Button btnSave;
		private System.Windows.Forms.Label lblHelp;
        private System.Windows.Forms.SaveFileDialog dlgSave;
	}
}

