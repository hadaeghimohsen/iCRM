CREATE TABLE [dbo].[Job_Personnel]
(
[SERV_FILE_NO] [bigint] NULL,
[JOB_CODE] [bigint] NULL,
[USER_NAME] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CODE] [bigint] NOT NULL,
[USER_DESC_DNRM] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RMND_APPT] [smallint] NULL,
[RMND_TASK] [smallint] NULL,
[SEND_EMAL_WHEN_TASK_ASGN_TO_ME] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SEND_EMAL_WHEN_LCAD_ASGN_TO_ME] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SEND_EMAL_WHEN_MY_LCAD_ASGN_TO_SOME_ONE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SEND_NOTF_WHEN_EMAL_SENT_BY_ME_OPEN] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SEND_NOTF_WHEN_EMAL_SENT_BY_ME_CLCK] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SEND_NOTF_WHEN_RECV_EMAL_RPLY] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SEND_NOTF_WHEN_LCAD_ASGN_TO_ME] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SEND_NOTF_WHEN_TASK_ASGN_TO_ME] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SEND_NOTF_WHEN_APPT_SCHD_FOR_ME] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DFLT_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RMND_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RMND_INTR] [int] NULL,
[RMND_NOT_READ_DNRM] [int] NULL,
[MNTN_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MNTN_NOT_READ_DNRM] [int] NULL,
[ALRM_DAY_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ALRM_DAY_NUMB] [int] NULL,
[ADD_LOGC_RLST_NOAN] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADD_LOGC_TIME_PROD] [int] NULL,
[RUN_QURY] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FTCH_ROWS] [int] NULL,
[INQR_FRMT] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[INIT_SECT_LOAD] [bigint] NULL,
[INIT_FORM_LOAD] [bigint] NULL,
[ADVC_FIND_MODE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRCB_TCID] [bigint] NULL,
[CNTY_CODE_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DFLT_CNTY_CODE] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DFLT_CLND_VIEW] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STRT_TIME] [time] (0) NULL,
[END_TIME] [time] (0) NULL,
[SEND_FEED_BACK] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRET_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRET_DATE] [datetime] NULL,
[MDFY_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MDFY_DATE] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[CG$AINS_JOBP]
   ON  [dbo].[Job_Personnel]
   AFTER INSERT   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   IF EXISTS(SELECT * FROM dbo.Job_Personnel jp, Inserted i WHERE jp.USER_NAME = i.USER_NAME AND jp.JOB_CODE = i.JOB_CODE AND jp.CODE != 0)
   BEGIN
      UPDATE dbo.Job_Personnel
         SET STAT = '002'
        FROM Inserted i
       WHERE dbo.Job_Personnel.USER_NAME = i.USER_NAME 
         AND dbo.Job_Personnel.JOB_CODE = i.JOB_CODE;
      RETURN;
   END      
   
   -- Insert statements for trigger here
   MERGE dbo.Job_Personnel T
   USING (SELECT * FROM Inserted) S
   ON (T.JOB_CODE = S.JOB_CODE AND
       T.USER_NAME = S.USER_NAME AND 
       T.CODE = S.CODE)
   WHEN MATCHED THEN
      UPDATE 
         SET T.CRET_BY = UPPER(SUSER_NAME())
            ,T.CRET_DATE = GETDATE()
            ,T.CODE = dbo.GNRT_NVID_U()
            ,T.STAT = '002'
            ,T.USER_DESC_DNRM = (SELECT u.USER_NAME FROM dbo.V#Users u WHERE S.USER_NAME = u.USER_DB);
   
   IF NOT EXISTS(SELECT * FROM dbo.Company WHERE HOST_STAT = '002' AND RECD_STAT = '002')
   BEGIN
      RAISERROR(N'لطفا ابتدا اطلاعات شرکت خود را وارد کنید', 16, 1);
      RETURN;
   END
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[CG$AUPD_JOBP]
   ON  [dbo].[Job_Personnel]
   AFTER UPDATE   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.	
	SET NOCOUNT ON;
	IF NOT EXISTS(
	   SELECT * FROM Inserted
	)
	   RETURN;
	
   IF NOT EXISTS(
      SELECT * 
        FROM dbo.Job_Personnel T, Inserted S
       WHERE T.USER_NAME = S.USER_NAME
         AND T.DFLT_STAT = '002'        
   )
   BEGIN
      RAISERROR(N'برای کاربر بایستی یک شغل به صورت پیش فرض انتخاب شده باشد که، نرم افزار بتواند از تنظیمات آن استفاده کند', 16, 1);
      RETURN;
   END;
   
   DECLARE @Code BIGINT
          ,@ApbsCode BIGINT;

	SELECT TOP 1 @ApbsCode = Code FROM dbo.App_Base_Define WHERE ENTY_NAME = 'COMPANYCHART_INFO';   
	
	SELECT @Code = p.CODE
     FROM dbo.Job_Personnel p, Inserted i
    WHERE p.USER_NAME = i.USER_NAME
      AND p.STAT = '002';
   
   INSERT INTO dbo.Job_Personnel_Relation
           ( JOBP_CODE ,
             RLAT_JOBP_CODE ,
             APBS_CODE ,
             CODE ,
             REC_STAT ,
             JBPR_DESC 
           )
   VALUES  ( @Code , -- JOBP_CODE - bigint
             @Code , -- RLAT_JOBP_CODE - bigint
             @ApbsCode , -- APBS_CODE - bigint
             0 , -- CODE - bigint
             '002' , -- REC_STAT - varchar(3)
             N'کارکنان' -- JBPR_DESC - nvarchar(250)
           );
   
   
   -- اگر برای این کار گزینه پیش فرضی قبلا تنظیم شده باشد آن را غیل فعال میکنیم
   UPDATE dbo.Job_Personnel 
      SET DFLT_STAT = '001'
     FROM Inserted S      
    WHERE S.USER_NAME = dbo.Job_Personnel.USER_NAME
      AND S.DFLT_STAT = '002'
      AND S.CODE <> dbo.Job_Personnel.CODE
      AND dbo.Job_Personnel.DFLT_STAT = '002';
   
    -- Insert statements for trigger here
   MERGE dbo.Job_Personnel T
   USING (SELECT * FROM Inserted) S
   ON (T.JOB_CODE = S.JOB_CODE AND
       T.USER_NAME = S.USER_NAME AND 
       T.CODE = S.CODE)
   WHEN MATCHED THEN
      UPDATE 
         SET T.MDFY_BY = UPPER(SUSER_NAME())
            ,T.MDFY_DATE = GETDATE();
   
   -- بررسی اینکه آیا اطلاعات کارمند در جدول مشتریان هم ثبت شده یا خیر
   IF EXISTS(SELECT * FROM Inserted s, dbo.Job_Personnel t WHERE s.CODE = t.CODE AND t.SERV_FILE_NO IS NOT NULL) RETURN;
   
   -- ذخیره کردن کاربر در لیست کارمندان شرکت
   L$SaveService:
   DECLARE @CntyCode VARCHAR(3)
          ,@PrvnCode VARCHAR(3)
          ,@RegnCode VARCHAR(3)
          ,@CompCode BIGINT
          ,@LastName NVARCHAR(250)
          ,@FrstName NVARCHAR(250);
   
   SELECT TOP 1 
          @CntyCode = REGN_PRVN_CNTY_CODE
         ,@PrvnCode = REGN_PRVN_CODE
         ,@RegnCode = REGN_CODE
         ,@CompCode = CODE
     FROM dbo.Company
    WHERE HOST_STAT = '002'
      AND RECD_STAT = '002';
   
   SELECT @LastName = u.USER_NAME
         ,@FrstName = u.USER_DB
     FROM Inserted i, dbo.V#Users u
    WHERE i.USER_NAME = u.USER_DB;
   
   DECLARE @X XML;
   SELECT @X = (
      SELECT 0 AS '@rqid'
            ,'001' AS '@rqtpcode'
            ,'004' AS '@rqttcode'
            ,@CntyCode AS '@cntycode'
            ,@PrvnCode AS '@prvncode'
            ,@RegnCode AS '@regncode'
            ,0 AS 'Service/@fileno'
            ,@CompCode AS 'Service/Service_Public/Comp_Code'
            ,@LastName AS 'Service/Service_Public/Last_Name'
            ,@FrstName AS 'Service/Service_Public/Frst_Name'
            ,'002'     AS 'Service/Service_Public/Type'
            ,'001'     AS 'Service/Service_Public/Serv_Stag_Code'
        FOR XML PATH('Request'), ROOT('Process')
   );
   
   EXEC dbo.ADM_ARQT_F @X = @X -- xml
   
   DECLARE @Rqid BIGINT
          ,@RqroRwno SMALLINT
          ,@ServFileNo BIGINT;
          
   -- بدست آوردن اطلاعات مربوط به ثبت موقت کارمند
   SELECT TOP 1 
          @Rqid = r.Rqid
         ,@RqroRwno = Rr.RWNO
         ,@ServFileNo = Rr.SERV_FILE_NO        
     FROM dbo.Request r, dbo.Request_Row rr
    WHERE r.rqid = rr.RQST_RQID
      AND r.RQTP_CODE = '001' -- ثبت اطلاعات مشتری
      AND r.RQTT_CODE = '004' -- به درخواست شرکت
      AND r.RQST_STAT = '001' -- ثبت موقت
      AND r.CRET_BY = UPPER(SUSER_NAME())
      AND CAST(r.CRET_DATE AS DATE) = CAST(GETDATE() AS DATE)
      AND r.REGN_PRVN_CNTY_CODE = @CntyCode
      AND r.REGN_PRVN_CODE = @PrvnCode
      AND r.REGN_CODE = @RegnCode
 ORDER BY r.CRET_DATE DESC;
   
   SELECT @X = (
      SELECT @Rqid AS '@rqid'
            ,@RqroRwno AS 'Request_Row/@rwno'
            ,@ServFileNo AS 'Request_Row/@servfileno'
        FOR XML PATH('Request'), ROOT('Process')        
   );
   
   -- ذخیره نهایی کردن کارمند
   EXEC dbo.ADM_ASAV_F @X = @X -- xml
   
   UPDATE dbo.Job_Personnel 
      SET SERV_FILE_NO = @ServFileNo
    WHERE CODE IN (
      SELECT CODE  
        FROM Inserted i
    );
   
   -- اضافه کردن شاخص کارمندی در جدول Personnel_Access_Service_Type
   MERGE dbo.Personnel_Access_Service_Type T
   USING (SELECT * FROM Inserted) S
   ON (t.JOBP_CODE = s.CODE AND 
       t.SRTP_CODE = '001')
   WHEN NOT MATCHED THEN
      INSERT (JOBP_CODE, SRTP_CODE, PAID, RECD_STAT)
      VALUES (s.CODE, '001', 0, '002');
END
GO
ALTER TABLE [dbo].[Job_Personnel] ADD CONSTRAINT [PK_JOBP] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Job_Personnel] ADD CONSTRAINT [FK_JBPR_INTF] FOREIGN KEY ([INIT_FORM_LOAD]) REFERENCES [dbo].[App_Base_Define] ([CODE])
GO
ALTER TABLE [dbo].[Job_Personnel] ADD CONSTRAINT [FK_JBPR_INTS] FOREIGN KEY ([INIT_SECT_LOAD]) REFERENCES [dbo].[App_Base_Define] ([CODE])
GO
ALTER TABLE [dbo].[Job_Personnel] ADD CONSTRAINT [FK_JBPR_TRCB] FOREIGN KEY ([TRCB_TCID]) REFERENCES [dbo].[Transaction_Currency_Base] ([TCID])
GO
ALTER TABLE [dbo].[Job_Personnel] ADD CONSTRAINT [FK_JOBP_JOB] FOREIGN KEY ([JOB_CODE]) REFERENCES [dbo].[Job] ([CODE])
GO
ALTER TABLE [dbo].[Job_Personnel] ADD CONSTRAINT [FK_JOBP_SERV] FOREIGN KEY ([SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO])
GO
EXEC sp_addextendedproperty N'MS_Description', N'آیا بعد از جواب ندادن درخواست تماس تلفنی دیگری ذخیره شود', 'SCHEMA', N'dbo', 'TABLE', N'Job_Personnel', 'COLUMN', N'ADD_LOGC_RLST_NOAN'
GO
EXEC sp_addextendedproperty N'MS_Description', N'چه مدت زمان برای تماس بعدی لحاظ شود', 'SCHEMA', N'dbo', 'TABLE', N'Job_Personnel', 'COLUMN', N'ADD_LOGC_TIME_PROD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'قابلیت جستجوی پیشرفته به چه صورت باشد', 'SCHEMA', N'dbo', 'TABLE', N'Job_Personnel', 'COLUMN', N'ADVC_FIND_MODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'تعداد روز قابل نمایش هشدارها', 'SCHEMA', N'dbo', 'TABLE', N'Job_Personnel', 'COLUMN', N'ALRM_DAY_NUMB'
GO
EXEC sp_addextendedproperty N'MS_Description', N'وضعیت نمایش پیام ها برای بازه تعداد روز محدود شود یا خیر', 'SCHEMA', N'dbo', 'TABLE', N'Job_Personnel', 'COLUMN', N'ALRM_DAY_STAT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'پیش شماره کد کشور فعال باشد', 'SCHEMA', N'dbo', 'TABLE', N'Job_Personnel', 'COLUMN', N'CNTY_CODE_STAT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'وضعیت نمایش تاریخ سیستم', 'SCHEMA', N'dbo', 'TABLE', N'Job_Personnel', 'COLUMN', N'DFLT_CLND_VIEW'
GO
EXEC sp_addextendedproperty N'MS_Description', N'پیش شماره کد کشوری', 'SCHEMA', N'dbo', 'TABLE', N'Job_Personnel', 'COLUMN', N'DFLT_CNTY_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'بعد از باز شدن صفحه کدام قسمت به صورت پیش فرض نمایش داده شود', 'SCHEMA', N'dbo', 'TABLE', N'Job_Personnel', 'COLUMN', N'INIT_FORM_LOAD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'صفحه اولیه کجا را نشان دهد', 'SCHEMA', N'dbo', 'TABLE', N'Job_Personnel', 'COLUMN', N'INIT_SECT_LOAD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'فرمت شماره درخواست درون سازمانی', 'SCHEMA', N'dbo', 'TABLE', N'Job_Personnel', 'COLUMN', N'INQR_FRMT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'مدت زمان باقیمانده برای یادآوری قبل از قرار ملاقات', 'SCHEMA', N'dbo', 'TABLE', N'Job_Personnel', 'COLUMN', N'RMND_APPT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'مدت زمان بازیابی خودکار اطلاعات یادآوری', 'SCHEMA', N'dbo', 'TABLE', N'Job_Personnel', 'COLUMN', N'RMND_INTR'
GO
EXEC sp_addextendedproperty N'MS_Description', N'پیام های خوانده نشده', 'SCHEMA', N'dbo', 'TABLE', N'Job_Personnel', 'COLUMN', N'RMND_NOT_READ_DNRM'
GO
EXEC sp_addextendedproperty N'MS_Description', N'وضعیت آیتم یادآوری کاربر', 'SCHEMA', N'dbo', 'TABLE', N'Job_Personnel', 'COLUMN', N'RMND_STAT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'مدت زمان باقیمانده برای یادآوری قبل از انجام وظیفه', 'SCHEMA', N'dbo', 'TABLE', N'Job_Personnel', 'COLUMN', N'RMND_TASK'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ارسال ایمیل برای ثبت کردن نام مشتری، یا خریدار، یا شرکت یا معامله به نام کاربری من', 'SCHEMA', N'dbo', 'TABLE', N'Job_Personnel', 'COLUMN', N'SEND_EMAL_WHEN_LCAD_ASGN_TO_ME'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ارسال ایمیل بخاطر انتصاب مشتریان به کاربر دیگر', 'SCHEMA', N'dbo', 'TABLE', N'Job_Personnel', 'COLUMN', N'SEND_EMAL_WHEN_MY_LCAD_ASGN_TO_SOME_ONE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ارسال ایمیل بخاطر ثبت وظیفه برای من', 'SCHEMA', N'dbo', 'TABLE', N'Job_Personnel', 'COLUMN', N'SEND_EMAL_WHEN_TASK_ASGN_TO_ME'
GO
EXEC sp_addextendedproperty N'MS_Description', N'برای پیام پاپاپ بخاطر زمان قرار ملاقات', 'SCHEMA', N'dbo', 'TABLE', N'Job_Personnel', 'COLUMN', N'SEND_NOTF_WHEN_APPT_SCHD_FOR_ME'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ارسال پیام پاپاپ برای ایمیل های ارسال شده و باز شده', 'SCHEMA', N'dbo', 'TABLE', N'Job_Personnel', 'COLUMN', N'SEND_NOTF_WHEN_EMAL_SENT_BY_ME_CLCK'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ارسال پیام پاپاپ برای ایمیل های ارسال شده', 'SCHEMA', N'dbo', 'TABLE', N'Job_Personnel', 'COLUMN', N'SEND_NOTF_WHEN_EMAL_SENT_BY_ME_OPEN'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ارسال پیام پاپاپ برای مشتریان که به من انتصاب داده شده است', 'SCHEMA', N'dbo', 'TABLE', N'Job_Personnel', 'COLUMN', N'SEND_NOTF_WHEN_LCAD_ASGN_TO_ME'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ارسال پیام پاپاپ برای ایمیل های دریافتی', 'SCHEMA', N'dbo', 'TABLE', N'Job_Personnel', 'COLUMN', N'SEND_NOTF_WHEN_RECV_EMAL_RPLY'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ارسال پیام پاپاپ بخاطر ثبت وظیفه برای من', 'SCHEMA', N'dbo', 'TABLE', N'Job_Personnel', 'COLUMN', N'SEND_NOTF_WHEN_TASK_ASGN_TO_ME'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نوع نمایش واحد پولی به چه صورت باشد', 'SCHEMA', N'dbo', 'TABLE', N'Job_Personnel', 'COLUMN', N'TRCB_TCID'
GO
