CREATE TABLE [dbo].[Request]
(
[REGN_PRVN_CNTY_CODE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Request_REGN_PRVN_CNTY_CODE] DEFAULT ('001'),
[REGN_PRVN_CODE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Request_REGN_PRVN_CODE] DEFAULT ('001'),
[REGN_CODE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PROJ_INQR_CODE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROJ_RQST_RQID] [bigint] NULL,
[RQST_RQID] [bigint] NULL,
[RQID] [bigint] NOT NULL CONSTRAINT [DF_RQST_RQID] DEFAULT ((0)),
[RQTP_CODE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RQTT_CODE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JOBP_CODE] [bigint] NULL,
[JOBP_DESC] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LAST_JOBP_CODE_DNRM] [bigint] NULL,
[SUB_SYS] [smallint] NOT NULL CONSTRAINT [DF_Request_SUB_SYS] DEFAULT ((1)),
[RQST_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RQST_RQST_STAT] DEFAULT ('001'),
[RQST_DATE] [datetime] NULL,
[SAVE_DATE] [datetime] NULL,
[LETT_NO] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LETT_DATE] [datetime] NULL,
[LETT_OWNR] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSTT_MSTT_SUB_SYS] [smallint] NOT NULL CONSTRAINT [DF_Request_SSTT_MSTT_SUB_SYS] DEFAULT ((1)),
[SSTT_MSTT_CODE] [smallint] NOT NULL CONSTRAINT [DF_Request_SSTT_MSTT_CODE] DEFAULT ((1)),
[SSTT_CODE] [smallint] NOT NULL CONSTRAINT [DF_Request_SSTT_CODE] DEFAULT ((1)),
[YEAR] [smallint] NULL CONSTRAINT [DF_Request_YEAR] DEFAULT ((1393)),
[CYCL] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Request_CYCL] DEFAULT ('001'),
[SEND_EXPN] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Request_SEND_EXPN] DEFAULT ('001'),
[MDUL_NAME] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SECT_NAME] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RQST_DESC] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RQST_NUMB] [bigint] NULL,
[SRVC_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SORC_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COLR] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$ADEL_RQST]
   ON  [dbo].[Request]
   AFTER DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   /*IF SUSER_NAME() <> 'SCSC' 
   BEGIN
      RAISERROR ('شما مجوز حذف فیزیکی اطلاعات رکورد جدول مورد نظر را ندارید. >:(', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRANSACTION;
   END*/ 
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[CG$AINS_RQST]
   ON  [dbo].[Request]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   -- INSERT STATEMENTS FOR TRIGGER HERE
   -- CHECK REQUEST_TYPE/REQUESTER_TYPE PERMISSION
   IF NOT EXISTS(   
      SELECT  Perm_Stat
        FROM  dbo.Request_Requester RQ, dbo.Regulation RG, INSERTED I
       WHERE  RQ.RQTP_CODE      = I.RQTP_CODE
         AND  RQ.RQTT_CODE      = I.RQTT_CODE
         AND  RG.SUB_SYS        = I.SUB_SYS
         AND  RQ.REGL_CODE      = RG.CODE
         AND  RQ.REGL_YEAR      = RG.YEAR
         AND  RG.[TYPE]         = '001'
         AND  RG.REGL_STAT      = '002'
         AND  RQ.PERM_STAT      = '002'
   )
   BEGIN
      RAISERROR (N'ترکیب تقاضا/متقاضی این درخواست مجاز نمی باشد. لطفا کنترل و اصلاح کنید.', -- Message text.
                 16, -- Severity.
                 1   -- State.
                );
      ROLLBACK TRANSACTION;
   END;

   -- INSERT REQUEST
   DECLARE @RQID BIGINT;
   SET @RQID = DBO.GNRT_NVID_U();
   
   -- 1396/11/19 * ثبت شماره درخواست به فرمت درون سازمانی   
   --DECLARE @ProjInqrCode VARCHAR(50);
   --SELECT @ProjInqrCode = INQR_FRMT FROM dbo.Settings WHERE DFLT_STAT = '002' AND INQR_FRMT IS NOT NULL;   
   
   --IF @ProjInqrCode IS NOT NULL
   --   SELECT @ProjInqrCode + CAST(COUNT(*) AS VARCHAR(30))
   --     FROM dbo.Request
   --    WHERE RQTP_CODE = '013';
   
   MERGE dbo.Request T
   USING (SELECT * FROM INSERTED) S
   ON (T.REGN_PRVN_CNTY_CODE = S.REGN_PRVN_CNTY_CODE AND
       T.REGN_PRVN_CODE      = S.REGN_PRVN_CODE      AND
       T.REGN_CODE           = S.REGN_CODE           AND
       T.RQTP_CODE           = S.RQTP_CODE           AND
       T.RQTT_CODE           = S.RQTT_CODE           AND
       T.SUB_SYS             = S.SUB_SYS             AND
       T.RQST_STAT           = S.RQST_STAT           AND
       T.SSTT_MSTT_SUB_SYS   = S.SSTT_MSTT_SUB_SYS   AND
       T.SSTT_MSTT_CODE      = S.SSTT_MSTT_CODE      AND
       T.SSTT_CODE           = S.SSTT_CODE           AND
       T.[YEAR]              = S.[YEAR]              AND
       T.CYCL                = S.CYCL                AND
       T.RQID                = S.RQID)
    WHEN MATCHED THEN
      UPDATE
         SET CRET_BY   = UPPER(SUSER_NAME())
            ,CRET_DATE = GETDATE()
            ,SUB_SYS   = (SELECT SUB_SYS FROM Request_Type WHERE CODE = S.Rqtp_Code)
            ,RQID      = @RQID
            ,RQST_DATE = GETDATE()
            ,T.SORC_TYPE = '001'
            ,T.SRVC_TYPE = '001'
            --,T.PROJ_INQR_CODE = @ProjInqrCode
            ,JOBP_CODE = 
               CASE WHEN S.JOBP_CODE IS NOT NULL THEN S.JOBP_CODE 
                    ELSE (
                        SELECT TOP 1 Code
                          FROM dbo.Job_Personnel Jp
                         WHERE Jp.USER_NAME = UPPER(SUSER_NAME())
                    ) 
               END;
    
    -- ثبت آیین نامه فعال برای درخواست جاری
    MERGE dbo.Request_Regulation_History T
    USING (SELECT R.YEAR, R.CODE, @RQID AS RQID 
             FROM dbo.Regulation R, INSERTED I
            WHERE R.REGL_STAT = '002' 
              AND R.SUB_SYS   = I.SUB_SYS) S
    ON (T.REGL_YEAR    = S.YEAR AND
        T.REGL_CODE    = S.CODE AND
        T.RQST_RQID    = S.RQID)
    WHEN NOT MATCHED THEN
      INSERT (RQST_RQID, REGL_YEAR, REGL_CODE)
      VALUES (S.RQID   , S.YEAR   , S.CODE   );
    
   
END
;
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[CG$AUPD_RQST]
   ON  [dbo].[Request]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   
   -- Insert statements for trigger here
   IF NOT EXISTS(SELECT * FROM inserted) RETURN;
   DECLARE @FILENO BIGINT
          ,@RqstNumb BIGINT;

   
   -- CHECK REQUEST_TYPE/REQUESTER_TYPE PERMISSION
   IF NOT EXISTS(   
      SELECT  Perm_Stat
        FROM  dbo.Request_Requester RQ, dbo.Regulation RG, INSERTED I
       WHERE  RQ.RQTP_CODE      = I.RQTP_CODE
         AND  RQ.RQTT_CODE      = I.RQTT_CODE
         AND  RG.SUB_SYS        = I.SUB_SYS
         AND  RQ.REGL_CODE      = RG.CODE
         AND  RQ.REGL_YEAR      = RG.YEAR
         AND  RG.[TYPE]         = '001'
         AND  RG.REGL_STAT      = '002'
         AND  RQ.PERM_STAT      = '002'
   )
   BEGIN
      RAISERROR (N'ترکیب تقاضا/متقاضی این درخواست مجاز نمی باشد. لطفا کنترل و اصلاح کنید.', -- Message text.
                 16, -- Severity.
                 1   -- State.
                );
      ROLLBACK TRANSACTION;
   END
   -- آیا درخواست پایانی شده
   --ELSE IF EXISTS(SELECT * FROM DELETED WHERE RQST_STAT IN ('002', '003'))
   --BEGIN
   --   RAISERROR (N'درخواست های پایانی شده به هیچ عنوان قابل تغییر نیستند', -- Message text.
   --              16, -- Severity.
   --              1   -- State.
   --             );
   --   ROLLBACK TRANSACTION;
   --END
   -- درخواست هایی که هزینه آنها پرداخت شده است
   ELSE IF EXISTS(
      SELECT *
        FROM Request R, Payment P, Payment_Detail Pd, Inserted I
       WHERE R.RQID = P.RQST_RQID
         AND P.RQST_RQID = Pd.PYMT_RQST_RQID
         AND P.CASH_CODE = Pd.PYMT_CASH_CODE
         AND Pd.PAY_STAT = '002'
         AND R.RQID = I.RQID
         AND R.RQST_STAT = '003'
   ) OR EXISTS (
      SELECT *
        FROM Request R, Payment P, Payment_Method Pm, Inserted I
       WHERE R.RQID = P.RQST_RQID
         AND P.RQST_RQID = Pm.PYMT_RQST_RQID
         AND P.CASH_CODE = Pm.PYMT_CASH_CODE
         AND Pm.AMNT > 0
         AND R.RQID = I.RQID
         AND R.RQST_STAT = '003'
   )   
   BEGIN
      RAISERROR (N'درخواست هایی که پرداختی داشته باشند قادر به انصراف نیستید', -- Message text.
                 16, -- Severity.
                 1   -- State.
                );
      ROLLBACK TRANSACTION;
   END
   ELSE IF EXISTS(
      SELECT * 
      FROM INSERTED I, DELETED D 
      WHERE I.RQID = D.RQID
        AND (I.RQTP_CODE <> D.RQTP_CODE
          OR I.RQTT_CODE <> D.RQTT_CODE)
        AND NOT(I.SSTT_MSTT_CODE = 1 -- درخواست
            AND I.SSTT_CODE = 1) -- ثبت موقت
   )
   BEGIN
      RAISERROR (N'شماره درخواستی که با نوع متقاضی و نوع تقاضا ثبت گردید دیگر قابل تغییر نیستند. باید درخواست خود را انصراف بزنید و دوباره نوع تقاضا و متقاضی خود را درست وارد کنید.', -- Message text.
                 16, -- Severity.
                 1   -- State.
                );
      ROLLBACK TRANSACTION;
   END
   -- UPDATE REQUEST
   MERGE dbo.Request T
   USING (SELECT * FROM INSERTED) S
   ON (T.REGN_PRVN_CNTY_CODE = S.REGN_PRVN_CNTY_CODE AND
       T.REGN_PRVN_CODE      = S.REGN_PRVN_CODE      AND
       T.REGN_CODE           = S.REGN_CODE           AND
       T.RQTP_CODE           = S.RQTP_CODE           AND
       T.RQTT_CODE           = S.RQTT_CODE           AND
       T.SUB_SYS             = S.SUB_SYS             AND
       T.RQST_STAT           = S.RQST_STAT           AND
       T.SSTT_MSTT_SUB_SYS   = S.SSTT_MSTT_SUB_SYS   AND
       T.SSTT_MSTT_CODE      = S.SSTT_MSTT_CODE      AND
       T.SSTT_CODE           = S.SSTT_CODE           AND
       T.[YEAR]              = S.[YEAR]              AND
       T.CYCL                = S.CYCL                AND
       T.RQID                = S.RQID)
    WHEN MATCHED THEN
      UPDATE
         SET MDFY_BY   = UPPER(SUSER_NAME())
            ,MDFY_DATE = GETDATE()
            ,YEAR  = SUBSTRING(DBO.GET_MTOS_U(GETDATE()), 1, 4)
            ,CYCL      = '0' + SUBSTRING(DBO.GET_MTOS_U(GETDATE()), 6, 2); 
    
   -- ذخیره کردن کد پرسنلی های ثبت شده در جدول تاریخچه ارجاعی ها      
   --SELECT * FROM inserted;
   --SELECT * FROM Deleted;
   IF EXISTS(
      SELECT * FROM Inserted Rnew, Deleted Rold
       WHERE rnew.RQID = Rold.RQID
         AND ISNULL(Rnew.JOBP_CODE, 0) != ISNULL(Rold.JOBP_CODE, 0)
   )
   BEGIN
      INSERT INTO dbo.Request_Job_Personnel( RQST_RQID ,RWNO ,RQST_JOBP_CODE ,RQST_JOBP_DESC )
      SELECT Deleted.RQID, 0, Deleted.JOBP_CODE, Deleted.JOBP_DESC
        FROM Deleted;
   END;

    
    -- log on sstt_mstt_code & sstt_code
    IF EXISTS(
      SELECT * FROM DELETED D, INSERTED I
       WHERE ( D.RQID = I.RQID 
           AND (  D.RQST_STAT         <> I.RQST_STAT
               OR D.SSTT_MSTT_CODE    <> I.SSTT_MSTT_CODE
               OR D.SSTT_CODE         <> I.SSTT_CODE
               )
            OR (  I.SSTT_MSTT_CODE    = 1
               OR I.SSTT_CODE         = 1
               )
             )
         AND D.SSTT_MSTT_SUB_SYS = I.SSTT_MSTT_SUB_SYS
    )
    BEGIN
      -- اینجا مشخص میشود که وضعیت اصلی و فرعی درخواست عوض شده
      DECLARE C#RQSTCHNGMSSS CURSOR FOR
       SELECT I.Rqid, I.SSTT_MSTT_SUB_SYS, I.SSTT_MSTT_CODE, I.SSTT_CODE, I.RQST_STAT
         FROM DELETED D, INSERTED I
        WHERE ( D.RQID = I.RQID 
           AND (  D.RQST_STAT    <> I.RQST_STAT
               OR D.SSTT_MSTT_CODE    <> I.SSTT_MSTT_CODE
               OR D.SSTT_CODE         <> I.SSTT_CODE
               )
            OR (  I.SSTT_MSTT_CODE    = 1
               OR I.SSTT_CODE         = 1
               )
             )
         AND D.SSTT_MSTT_SUB_SYS = I.SSTT_MSTT_SUB_SYS
       ORDER BY I.Rqid;
       
      OPEN C#RQSTCHNGMSSS;
         
      DECLARE @SSTT_MSTT_SUB_SYS SMALLINT
             ,@SSTT_MSTT_CODE SMALLINT
             ,@SSTT_CODE      SMALLINT
             ,@RQID           BIGINT
             ,@RQST_STAT      VARCHAR(3);
      
      L$NextRow:       
      DECLARE @ORQID BIGINT;
      SET @ORQID = @RQID;
      FETCH NEXT FROM C#RQSTCHNGMSSS INTO @RQID, @SSTT_MSTT_SUB_SYS, @SSTT_MSTT_CODE, @SSTT_CODE, @RQST_STAT;
      
      IF @@FETCH_STATUS <> 0
         GOTO L$EndFetch;
      
      IF @RQID = @ORQID 
         GOTO L$NextRow;
      
      -- اگر تغییر وضعیت عادی انجام شده باشد
      DECLARE @SHIS_RWNO SMALLINT;
      IF @SSTT_MSTT_CODE < 90 AND @SSTT_CODE < 90 AND @RQST_STAT = '001'
      BEGIN
         MERGE dbo.Step_History_Summery T
         USING (SELECT * FROM INSERTED WHERE RQID = @RQID) S
         ON (T.RQST_RQID = S.RQID AND
             T.RWNO      = (SELECT MAX(RWNO) FROM dbo.Step_History_Summery WHERE RQST_RQID = S.RQID) AND
             T.SSTT_MSTT_CODE = @SSTT_MSTT_CODE)
         WHEN NOT MATCHED THEN
            INSERT (RQST_RQID, SSTT_MSTT_SUB_SYS, SSTT_MSTT_CODE)
            VALUES (@RQID    , SSTT_MSTT_SUB_SYS,@SSTT_MSTT_CODE);
         
         SELECT @SHIS_RWNO = MAX(RWNO) FROM dbo.Step_History_Summery WHERE RQST_RQID = @RQID;
         
         MERGE dbo.Step_History_Detail T
         USING (SELECT * FROM INSERTED WHERE RQID = @RQID) S
         ON (T.SHIS_RQST_RQID = S.RQID AND
             T.SHIS_RWNO      = @SHIS_RWNO AND
             T.RWNO           = (SELECT MAX(RWNO) FROM dbo.Step_History_Detail WHERE SHIS_RQST_RQID = S.RQID AND SHIS_RWNO = @SHIS_RWNO) AND
             T.SSTT_MSTT_CODE = @SSTT_MSTT_CODE AND
             T.SSTT_CODE      = @SSTT_CODE)
         WHEN NOT MATCHED THEN
            INSERT (SHIS_RQST_RQID, 
                    SHIS_RWNO, 
                    SSTT_MSTT_SUB_SYS, 
                    SSTT_MSTT_CODE, 
                    SSTT_CODE)
            VALUES (@RQID,
                    @SHIS_RWNO,
                    @SSTT_MSTT_SUB_SYS,
                    @SSTT_MSTT_CODE,
                    @SSTT_CODE);   
      END
      ELSE IF @SSTT_MSTT_CODE < 90 AND @SSTT_CODE < 90 AND @RQST_STAT = '002'
      BEGIN 
         -- چک کردن مدارک مورد نیاز درخواست        
         IF EXISTS(
            SELECT * 
              FROM Receive_Document Rd, Request_Row Rr , Image_Document Id
             WHERE Rd.RQRO_RQST_RQID = Rr.RQST_RQID 
               AND Rd.RQRO_RWNO = Rr.RWNO 
               AND Id.RCDC_RCID = Rd.RCID
               AND Id.IMAG IS NULL
               AND Rr.RQST_RQID = @RQID 
               AND EXISTS(SELECT * FROM Request_Document Rqd WHERE Rqd.RDID = Rd.RQDC_RDID AND Rqd.NEED_TYPE = '001'))
         BEGIN
            RAISERROR (N'برای درخواست مدارکی به صورت اجباری مشخص شده که از طرف هنرجو تحویل داده نشده. لطفا بررسی کنید', -- Message text.
                 16, -- Severity.
                 1   -- State.
                );
            ROLLBACK TRANSACTION;
         END
         -- 1395/06/19 * در این قسمت اگر بر اساس مدارک مورد نیاز ارگان مشخص شده باشد باید پیام حاوی اینکه یکسری مدارک باید به صورت اجباری وارد شوند
         -- ذخیره نهایی
         INSERT INTO dbo.Step_History_Summery 
                (RQST_RQID, SSTT_MSTT_SUB_SYS, SSTT_MSTT_CODE)
         VALUES (@RQID    ,@SSTT_MSTT_SUB_SYS, 95);
         
         SELECT @SHIS_RWNO = MAX(RWNO) FROM dbo.Step_History_Summery WHERE RQST_RQID = @RQID AND SSTT_MSTT_CODE = 95;
         
         INSERT INTO dbo.Step_History_Detail
                (SHIS_RQST_RQID, SHIS_RWNO, SSTT_MSTT_SUB_SYS, SSTT_MSTT_CODE, SSTT_CODE)
         VALUES (@RQID         ,@SHIS_RWNO,@SSTT_MSTT_SUB_SYS, 95            , 1);
         -- پایانی
         INSERT INTO dbo.Step_History_Summery 
                (RQST_RQID, SSTT_MSTT_SUB_SYS, SSTT_MSTT_CODE)
         VALUES (@RQID    ,@SSTT_MSTT_SUB_SYS, 99);
         
         SELECT @SHIS_RWNO = MAX(RWNO) FROM dbo.Step_History_Summery WHERE RQST_RQID = @RQID AND SSTT_MSTT_CODE = 99;
         
         INSERT INTO dbo.Step_History_Detail
                (SHIS_RQST_RQID, SHIS_RWNO, SSTT_MSTT_SUB_SYS, SSTT_MSTT_CODE, SSTT_CODE)
         VALUES (@RQID         ,@SHIS_RWNO,@SSTT_MSTT_SUB_SYS, 99            , 99);
         
         SELECT @FILENO = SERV_FILE_NO
           FROM dbo.Request_Row
          WHERE RQST_RQID = @RQID;
         
         SELECT @RqstNumb = COUNT(R.RQID)
           FROM dbo.Request R, dbo.Request_Row Rr
          WHERE R.RQID = Rr.RQST_RQID          
            AND RR.SERV_FILE_NO = @FILENO
            AND R.RQST_STAT = '002';
         
         UPDATE Request
            SET SSTT_MSTT_CODE = 99
               ,SSTT_CODE      = 99
               ,SAVE_DATE      = GETDATE()
               ,RQST_NUMB      = @RqstNumb
          WHERE RQID = @RQID;
      END
      ELSE IF @SSTT_MSTT_CODE < 90 AND @SSTT_CODE < 90 AND @RQST_STAT = '003'
      BEGIN
         -- انصراف درخواست
         INSERT INTO dbo.Step_History_Summery 
          (RQST_RQID, SSTT_MSTT_SUB_SYS, SSTT_MSTT_CODE)
         VALUES (@RQID    ,@SSTT_MSTT_SUB_SYS, 90);
         
         SELECT @SHIS_RWNO = MAX(RWNO) FROM dbo.Step_History_Summery WHERE RQST_RQID = @RQID AND SSTT_MSTT_CODE = 90;
         
         INSERT INTO dbo.Step_History_Detail
                (SHIS_RQST_RQID, SHIS_RWNO, SSTT_MSTT_SUB_SYS, SSTT_MSTT_CODE, SSTT_CODE)
         VALUES (@RQID         ,@SHIS_RWNO,@SSTT_MSTT_SUB_SYS, 90            , 1);
         -- پایانی
         INSERT INTO dbo.Step_History_Summery 
                (RQST_RQID, SSTT_MSTT_SUB_SYS, SSTT_MSTT_CODE)
         VALUES (@RQID    ,@SSTT_MSTT_SUB_SYS, 99);

         SELECT @SHIS_RWNO = MAX(RWNO) FROM dbo.Step_History_Summery WHERE RQST_RQID = @RQID AND SSTT_MSTT_CODE = 99;

         INSERT INTO dbo.Step_History_Detail
                (SHIS_RQST_RQID, SHIS_RWNO, SSTT_MSTT_SUB_SYS, SSTT_MSTT_CODE, SSTT_CODE)
         VALUES (@RQID         ,@SHIS_RWNO,@SSTT_MSTT_SUB_SYS, 99            , 99);      
         
         UPDATE Request
            SET SSTT_MSTT_CODE = 99
               ,SSTT_CODE     = 99
          WHERE RQID = @RQID;
      END
      
      -- برای پایانی کردن درخواست نباید درخواست پیرو در حال اجرایی وجود داشته باشد
      IF @RQST_STAT IN ('002', '003')
      BEGIN
         IF EXISTS(
            SELECT *
              FROM dbo.Request R, Inserted I
             WHERE R.RQST_RQID = i.RQID
               AND R.RQST_STAT = '001'            
         )
         BEGIN
            RAISERROR(N'درخواست های پیرو برای درخواست شما ثبت گردیده که باید منتظر پایانی شدن آن باشید', 16, 1);
            RETURN;
         END           
      END
      
      -- برای آزاد کردن مشترک های درگیر در درخواست های پایانی شده یا انصراف زده شده
      IF @RQST_STAT IN ('003')
      BEGIN
         MERGE dbo.Service T
         USING (SELECT * FROM INSERTED) S
         ON (T.RQST_RQID = S.RQID)
         WHEN MATCHED THEN
            UPDATE
               SET RQST_RQID = NULL
                  ,SERV_STAT = '002';
      END      
      ELSE IF @RQST_STAT IN ('002')
      BEGIN
         MERGE dbo.Service T
         USING (
            SELECT rr.* 
              FROM INSERTED r, dbo.Request_Row rr
             WHERE r.RQID = rr.RQST_RQID
         ) S
         ON (T.FILE_NO = s.SERV_FILE_NO)
         WHEN MATCHED THEN
            UPDATE
               SET RQST_RQID = NULL
                  ,SERV_STAT = '002'
                  ,T.LAST_RQST_RQID_DNRM = S.RQST_RQID;
         
         -- 1395/03/11 * نیاز به این بود که با آخرین مشتری از این شرکت که در ارتباط بوده ایم دسترسی مستقیم داشته باشیم         
         MERGE dbo.Company T
         USING (
            SELECT s.COMP_CODE_DNRM, s.FILE_NO, rr.RQST_RQID
              FROM INSERTED r, dbo.Request_Row rr, dbo.Service S
             WHERE r.RQID = rr.RQST_RQID
               AND Rr.SERV_FILE_NO = s.FILE_NO
         ) S
         ON (T.CODE = s.COMP_CODE_DNRM)
         WHEN MATCHED THEN
            UPDATE
               SET T.LAST_SERV_FILE_NO_DNRM = S.FILE_NO
                  ,T.LAST_RQST_RQID_DNRM = S.RQST_RQID;
      END
      
               
      GOTO L$NextRow;
      L$EndFetch:
      CLOSE C#RQSTCHNGMSSS;
      DEALLOCATE C#RQSTCHNGMSSS;
    END
END
;
GO
ALTER TABLE [dbo].[Request] ADD CONSTRAINT [CK_RQST_RQST_STAT] CHECK (([RQST_STAT]='003' OR [RQST_STAT]='002' OR [RQST_STAT]='001'))
GO
ALTER TABLE [dbo].[Request] ADD CONSTRAINT [RQST_PK] PRIMARY KEY CLUSTERED  ([RQID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Request] ADD CONSTRAINT [FK_PRQT_RQST] FOREIGN KEY ([PROJ_RQST_RQID]) REFERENCES [dbo].[Request] ([RQID])
GO
ALTER TABLE [dbo].[Request] ADD CONSTRAINT [FK_RQST_JOBP] FOREIGN KEY ([JOBP_CODE]) REFERENCES [dbo].[Job_Personnel] ([CODE])
GO
ALTER TABLE [dbo].[Request] ADD CONSTRAINT [FK_RQST_LJBP] FOREIGN KEY ([LAST_JOBP_CODE_DNRM]) REFERENCES [dbo].[Job_Personnel] ([CODE])
GO
ALTER TABLE [dbo].[Request] WITH NOCHECK ADD CONSTRAINT [FK_RQST_REGN] FOREIGN KEY ([REGN_PRVN_CNTY_CODE], [REGN_PRVN_CODE], [REGN_CODE]) REFERENCES [dbo].[Region] ([PRVN_CNTY_CODE], [PRVN_CODE], [CODE])
GO
ALTER TABLE [dbo].[Request] ADD CONSTRAINT [FK_RQST_RQST] FOREIGN KEY ([RQST_RQID]) REFERENCES [dbo].[Request] ([RQID])
GO
ALTER TABLE [dbo].[Request] ADD CONSTRAINT [FK_RQST_RQTP] FOREIGN KEY ([RQTP_CODE]) REFERENCES [dbo].[Request_Type] ([CODE])
GO
ALTER TABLE [dbo].[Request] ADD CONSTRAINT [FK_RQST_RQTT] FOREIGN KEY ([RQTT_CODE]) REFERENCES [dbo].[Requester_Type] ([CODE])
GO
ALTER TABLE [dbo].[Request] WITH NOCHECK ADD CONSTRAINT [FK_RQST_SSTT] FOREIGN KEY ([SSTT_MSTT_CODE], [SSTT_MSTT_SUB_SYS], [SSTT_CODE]) REFERENCES [dbo].[Sub_State] ([MSTT_CODE], [MSTT_SUB_SYS], [CODE])
GO
EXEC sp_addextendedproperty N'MS_Description', N'رنگ درخواست', 'SCHEMA', N'dbo', 'TABLE', N'Request', 'COLUMN', N'COLR'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ارجاع به ', 'SCHEMA', N'dbo', 'TABLE', N'Request', 'COLUMN', N'JOBP_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'شماره درخواست با فرمت داخل سازمانی', 'SCHEMA', N'dbo', 'TABLE', N'Request', 'COLUMN', N'PROJ_INQR_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'درخواست های پروژه', 'SCHEMA', N'dbo', 'TABLE', N'Request', 'COLUMN', N'PROJ_RQST_RQID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'تعداد درخواست های انجام شده', 'SCHEMA', N'dbo', 'TABLE', N'Request', 'COLUMN', N'RQST_NUMB'
GO
EXEC sp_addextendedproperty N'MS_Description', N'منبع ثبت درخواست', 'SCHEMA', N'dbo', 'TABLE', N'Request', 'COLUMN', N'SORC_TYPE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نوع روش ثبت درخواست', 'SCHEMA', N'dbo', 'TABLE', N'Request', 'COLUMN', N'SRVC_TYPE'
GO
