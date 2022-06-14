SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[EXEC_JOBS_P]	
   @X XML
AS
BEGIN
	-- در این تابع ما میخواهیم که ارسال ایمیل و ارسال پیامک انجام شود ولی بعدا ممکن است گزینه های دیگری به سیستم اضافه شوند
	
	-- گام اول ارسال کردن ایمیل
	-- این قسمت ابتدا باید مشخص کنیم که چه کاربری در امر کمک رسانی به سرور مشارکت کرده است
	DECLARE @UserIdHelpServer BIGINT;
	SELECT TOP 1
	       @UserIdHelpServer = ID
	  FROM dbo.V#Users
	 WHERE DFLT_USER_HELP_SRVR = '002'
	   AND MAIL_SRVR_STAT = '002'
	   AND MAIL_SRVR_PROF IS NOT NULL 
	   AND MAIL_SRVR_ACNT IS NOT NULL;
	
	IF @UserIdHelpServer IS NULL
	BEGIN
	   -- باید در جدولی در پابگاه داده اصلی جدولی منظور گردد که مشخص شود عملیات در این قسمت ناموفق بوده است
	   SAVE_ERROR_LOG:
	END
	
	-- اگر کاربر مناسب برای امر ارسال ایمیل مشخص شد 
	-- در گام بعدی باید مشخص کنیم که کدام ایمیل های مورد نظر ارسال نشده یا آماده ارسال هستند
	DECLARE @SendCount INT;
	
	SELECT @SendCount = COUNT(EMID) 	
	  FROM dbo.Email
	 WHERE SEND_STAT IN( '003' /* ارسال نشده */, '005' /* آماده برای ارسال */ )
	   AND SEND_DATE <= GETDATE()
	   AND MAIL_ITEM_NO IS NULL;
	
	IF @SendCount = 0
	BEGIN
	   -- اگر گزینه ای برای ارسال وجود نداشته باشد
	   NO_SEND_EMAIL_LOG:	   
	   -- بررسی ایمیل های ارسال شده سمت ایمیل سرور پایگاه داده که آیا اطلاعات با موفقیت ارسال شده است یا خیر
	   -- ****** @@@###@@@###
	   UPDATE dbo.Email
	      SET SEND_STAT = (
	         SELECT CASE sm.sent_status
	                  WHEN 1 THEN '004' -- ارسال شده
	                  WHEN 0 THEN '003' -- ارسال نشده
	                  WHEN 3 THEN '005' -- آماده برای ارسال
	                  ELSE '007' -- ناموفق در ارسال
	                END
	           FROM msdb.dbo.sysmail_mailitems sm
	          WHERE sm.mailitem_id = MAIL_ITEM_NO
	      )
	    WHERE SEND_STAT IN( '003' /* ارسال نشده */, '005' /* آماده برای ارسال */ )
	      AND SEND_DATE <= GETDATE()
	      AND MAIL_ITEM_NO IS NOT NULL;
	   
	   GOTO L$END_SEND_MAIL;
	END
	
	-- اگر گزینه ای برای ایمیل وجود داشته باشد حال برای هر تعداد مشتری به صورت تک به تک ارسال میکنیم تا بعدا با بهینه کردن این قسمت با کمترین ارسال بتوانیم موارد ارسالی را انجام دهیم
	DECLARE C$SendEmails CURSOR FOR
	   SELECT EMID, RQRO_RQST_RQID, FROM_MAIL, SUBJ_DESC, EMAL_CMNT
	     FROM dbo.Email
	    WHERE SEND_STAT IN( '003' /* ارسال نشده */, '005' /* آماده برای ارسال */ )
	      AND SEND_DATE <= GETDATE()
	      AND MAIL_ITEM_NO IS NULL;
	
	DECLARE @Emid BIGINT
	       ,@RqroRqstRqid BIGINT
	       ,@FromMail VARCHAR(250)
	       ,@ToMails VARCHAR(MAX)
	       ,@UserIdSendEmail BIGINT = NULL
	       ,@MailServerProfile VARCHAR(250)
	       ,@SubjDesc NVARCHAR(250)
	       ,@EmalCmnt NVARCHAR(4000)
	       ,@FileAttachment NVARCHAR(MAX)
	       ,@MailItemNo BIGINT;
	
	OPEN [C$SendEmails];
	L$LoopSendEmails:
	FETCH NEXT FROM [C$SendEmails] INTO @Emid, @RqroRqstRqid, @FromMail, @SubjDesc, @EmalCmnt;
	
	IF @@FETCH_STATUS <> 0
	   GOTO L$EndLoopSendEmails;
	
	-- بدست آوردن کاربری که میخواهد ایمیل ارسال کند
   SELECT TOP 1
          @UserIdSendEmail = ID
     FROM dbo.V#Users
    WHERE EMAL_ADRS = @FromMail
      AND MAIL_SRVR_STAT = '002'
      AND MAIL_SRVR_PROF IS NOT NULL 
      AND MAIL_SRVR_ACNT IS NOT NULL;
	
	-- اگر کاربر فعلی اطلاعات مربوط به ارسال از طریق سرور تنظیم نشده باشد بایستی از گزینه جایگزین استفاده نماید
	IF @UserIdSendEmail IS NULL
	   SET @UserIdSendEmail = @UserIdHelpServer;
	
   -- بررسی میکنیم که آیا ایمیل فایل ضمیمه هم دارد یا خیر 	
	SELECT @FileAttachment = COALESCE(@FileAttachment + '; ', '') + sf.FILE_SRVR_LINK
	  FROM dbo.Request r, dbo.Request_Row rr, dbo.Send_File sf
	 WHERE r.RQID = rr.RQST_RQID
	   AND rr.RQST_RQID = sf.RQRO_RQST_RQID
	   AND rr.RWNO = sf.RQRO_RWNO
	   AND r.RQST_RQID = @RqroRqstRqid
	
	-- بدست آوردن اطلاعات ایمیل مقصد
	SELECT @ToMails = COALESCE(@ToMails + '; ', '') + ete.TO_MAIL
	  FROM dbo.Email_To_Email ete
	 WHERE EMAL_EMID = @Emid;
	
	-- بدست آوردن پروفایل کاربر برای ارسال
	SELECT TOP 1
          @MailServerProfile = MAIL_SRVR_PROF
     FROM dbo.V#Users
    WHERE ID = @UserIdSendEmail;
	
	-- ارسال ایمیل
	EXEC msdb.dbo.sp_send_dbmail 
     @profile_name=@MailServerProfile,
     @recipients=@ToMails,
     @subject=@SubjDesc,
     @body=@EmalCmnt,
     @file_attachments=@FileAttachment,
     @mailitem_id = @MailItemNo OUTPUT;
   
   SET @ToMails = NULL;
   SET @FileAttachment = NULL;
   
   -- قرار دادن کد مربوط به ایمیل سرور برای رهگیری
   UPDATE dbo.Email
      SET MAIL_ITEM_NO = @MailItemNo
    WHERE EMID = @Emid;
	
	GOTO L$LoopSendEmails;	
	L$EndLoopSendEmails:
	CLOSE [C$SendEmails];
	DEALLOCATE [C$SendEmails];
	
	L$END_SEND_MAIL:
	
	-- ارسال پیامک
	DECLARE C$SendMessages CURSOR FOR
	   SELECT MSID, RQRO_RQST_RQID, CELL_PHON, MESG_CMNT, MBST_MBID
	     FROM dbo.Message
	    WHERE MESG_STAT IN( '003' /* ارسال نشده */, '005' /* آماده برای ارسال */ )
	      AND MESG_DATE <= GETDATE()
	      AND SMSC_CODE IS NULL
	      AND MBST_MBID IS NOT NULL;
   
   DECLARE @Msid BIGINT
          ,@CellPhon VARCHAR(11)
          ,@MesgCmnt NVARCHAR(1000)
          ,@MbstMbid BIGINT
          ,@SmscCode BIGINT;
   
 	OPEN [C$SendMessages];
	L$LoopSendMessages:
	FETCH NEXT FROM [C$SendMessages] INTO @Msid, @RqroRqstRqid, @CellPhon, @MesgCmnt, @MbstMbid;
	
	IF @@FETCH_STATUS <> 0
	   GOTO L$EndLoopSendMessages;
   
   DECLARE @Object as Int;
   Declare @ResponseText as VARCHAR(8000);
   DECLARE @Url NVARCHAR(1000) = N'http://smscall.ir/url/?method=send&sender={0}&reciver={1}&userid={2}&pass={3}&text={4}';
   DECLARE @Sender NVARCHAR(30)
          ,@UserName NVARCHAR(250)
          ,@Password NVARCHAR(250);
   
   SELECT @Sender = LINE_NUMB
         ,@UserName = USER_NAME
         ,@Password = PASS_WORD   
     FROM dbo.V#Message_Broad_Settings
    WHERE MBID = @MbstMbid;
   
   SELECT @Url = REPLACE( REPLACE( REPLACE( REPLACE( REPLACE(@Url, N'{0}', @Sender), N'{1}', @CellPhon ), N'{2}', @UserName ), N'{3}', @Password ), N'{4}', @MesgCmnt );
   
   PRINT @Url;
   DECLARE @Ret AS INT;
   Exec @ret = sp_OACreate 'MSXML2.ServerXMLHTTP', @Object OUT;
   IF @ret <> 0 RAISERROR('Unable to open HTTP connection.', 10, 1);
   
   Exec sp_OAMethod @Object, 'open', NULL, 'GET', @Url,'false'
   Exec sp_OAMethod @Object, 'send'
   Exec sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT
   SELECT @SmscCode = CAST(@ResponseText AS XML).query('xmsresponse/recipient').value('.', 'bigint');
   Exec sp_OADestroy @Object
   
   -- بروزرسانی اطلاعات ارسال پیامک
   UPDATE dbo.Message
      SET SMSC_CODE = @SmscCode
         ,SEND_STAT = CASE WHEN @SmscCode = 0 THEN '007' WHEN @SmscCode <> 0 THEN '004' END
         ,MESG_STAT = CASE WHEN @SmscCode = 0 THEN '007' WHEN @SmscCode <> 0 THEN '004' END
    WHERE MSID = @Msid;
      
   GOTO L$LoopSendMessages;
   L$EndLoopSendMessages:
   CLOSE [C$SendMessages];
   DEALLOCATE [C$SendMessages];
	
	END_EXEC_JOBS_P:
	PRINT 'OK Run Jobs';
END
GO
