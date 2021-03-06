CREATE TABLE [dbo].[Payment_Method]
(
[PYMT_CASH_CODE] [bigint] NOT NULL,
[PYMT_RQST_RQID] [bigint] NOT NULL,
[RQRO_RQST_RQID] [bigint] NOT NULL,
[RQRO_RWNO] [smallint] NOT NULL,
[RWNO] [smallint] NOT NULL,
[AMNT] [bigint] NULL,
[RCPT_MTOD] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Payment_Base_Tariff_RCPT_BTRF] DEFAULT ('001'),
[TERM_NO] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRAN_NO] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CARD_NO] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BANK] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FLOW_NO] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REF_NO] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACTN_DATE] [datetime] NULL,
[SHOP_NO] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRET_BY] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRET_DATE] [datetime] NULL,
[MDFY_BY] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MDFY_DATE] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  TRIGGER [dbo].[CG$ADEL_PMTD]
   ON [dbo].[Payment_Method]
   AFTER DELETE 
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   
   -- 1395/12/27 * بروز رسانی جدول هزینه برای ستون جمع مبلغ های دریافتی مشترک
   MERGE dbo.Payment T
   USING (SELECT * FROM Deleted )S
   ON (T.CASH_CODE = S.PYMT_CASH_CODE AND 
       T.RQST_RQID = S.PYMT_RQST_RQID)
   WHEN MATCHED THEN
      UPDATE SET
         T.SUM_RCPT_EXPN_PRIC = (
            SELECT ISNULL(SUM(Amnt) , 0)
              FROM dbo.Payment_Method
             WHERE PYMT_CASH_CODE = S.PYMT_CASH_CODE
               AND PYMT_RQST_RQID = S.PYMT_RQST_RQID
         );
   
   
   -- بروز کردن مبلغ بدهی هنرجو
   UPDATE dbo.Service
      SET CONF_STAT = CONF_STAT
    WHERE FILE_NO IN (
      SELECT SERV_FILE_NO
        FROM dbo.Request_Row Rr, INSERTED I
       WHERE Rr.Rqst_rqid = I.Pymt_Rqst_Rqid       
    );
END
;
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[CG$AINS_PMTD]
   ON [dbo].[Payment_Method]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   
   DECLARE @TotlRcptAmnt BIGINT;
   DECLARE @TotlDebtAmnt BIGINT;
   DECLARE @TotlRemnAmnt BIGINT;
   
   SELECT @TotlRcptAmnt = 
          SUM(Amnt)
     FROM Payment_Method T
    WHERE EXISTS(
      SELECT *
        FROM INSERTED S
       WHERE S.PYMT_CASH_CODE = T.PYMT_CASH_CODE
         AND S.PYMT_RQST_RQID = T.PYMT_RQST_RQID
         AND T.RWNO           <> 0
    );
   
   SELECT @TotlDebtAmnt =
          SUM_EXPN_PRIC + SUM_EXPN_EXTR_PRCT
     FROM Payment T
    WHERE EXISTS(
      SELECT *
        FROM INSERTED S
       WHERE S.PYMT_CASH_CODE = T.CASH_CODE
         AND S.PYMT_RQST_RQID = T.RQST_RQID
    );
   
   SELECT @TotlRemnAmnt = SUM(AMNT)
     FROM INSERTED S;
   
   IF @TotlRemnAmnt + @TotlRcptAmnt > @TotlDebtAmnt
      RAISERROR(N'مبلغ بدهی هنرجو کمتر مبلغ وارد شده می باشد. لطفا مبلغ درست را وارد کنید.', 16, 1);
   
   IF EXISTS(SELECT * FROM INSERTED WHERE AMNT IS NULL)
      RAISERROR(N'مبلغ بدهی هنرجو باید مبلغ قابل قبول و درستی باشد.', 16, 1);
   
   -- Insert statements for trigger here
   MERGE dbo.Payment_Method T
   USING (SELECT * FROM INSERTED) S
   ON (T.PYMT_CASH_CODE = S.PYMT_CASH_CODE AND
       T.PYMT_RQST_RQID = S.PYMT_RQST_RQID AND
       T.RQRO_RQST_RQID = S.RQRO_RQST_RQID AND
       T.RQRO_RWNO      = S.RQRO_RWNO      AND
       T.RWNO           = S.RWNO)
   WHEN MATCHED THEN
      UPDATE 
         SET CRET_BY   = UPPER(SUSER_NAME())
            ,CRET_DATE = GETDATE()
            ,RWNO      = (SELECT ISNULL(MAX(RWNO), 0) + 1 FROM dbo.Payment_Method WHERE PYMT_CASH_CODE = S.PYMT_CASH_CODE AND PYMT_RQST_RQID = S.PYMT_RQST_RQID AND RQRO_RQST_RQID = S.RQRO_RQST_RQID AND RQRO_RWNO      = S.RQRO_RWNO)
            ,ACTN_DATE = COALESCE(S.Actn_Date, GETDATE());
   
   -- اگر مبلغ ذخیره شده صفر باشد   
   DELETE Payment_Method
    WHERE EXISTS(
      SELECT *
        FROM INSERTED S
       WHERE S.PYMT_CASH_CODE = Payment_Method.PYMT_CASH_CODE
         AND S.PYMT_RQST_RQID = Payment_Method.PYMT_RQST_RQID
         AND S.RQRO_RQST_RQID = Payment_Method.RQRO_RQST_RQID
         AND S.RQRO_RWNO      = Payment_Method.RQRO_RWNO
         AND S.AMNT           = Payment_Method.AMNT
         AND Payment_Method.AMNT = 0
    )
END
;
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[CG$AUPD_PMTD]
   ON [dbo].[Payment_Method]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   
   DECLARE @TotlRcptAmnt BIGINT;
   DECLARE @TotlDebtAmnt BIGINT;
   DECLARE @TotlRemnAmnt BIGINT;
   
   SELECT @TotlRcptAmnt = 
          SUM(Amnt)
     FROM Payment_Method T
    WHERE EXISTS(
      SELECT *
        FROM INSERTED S
       WHERE S.PYMT_CASH_CODE = T.PYMT_CASH_CODE
         AND S.PYMT_RQST_RQID = T.PYMT_RQST_RQID
         AND S.RWNO          <> T.RWNO
    );
   
   SELECT @TotlDebtAmnt =
          SUM_EXPN_PRIC + SUM_EXPN_EXTR_PRCT
     FROM Payment T
    WHERE EXISTS(
      SELECT *
        FROM INSERTED S
       WHERE S.PYMT_CASH_CODE = T.CASH_CODE
         AND S.PYMT_RQST_RQID = T.RQST_RQID
    );
   
   SELECT @TotlRemnAmnt = SUM(AMNT)
     FROM INSERTED S;
   
   IF @TotlRemnAmnt + @TotlRcptAmnt > @TotlDebtAmnt
      RAISERROR(N'مبلغ بدهی هنرجو کمتر مبلغ وارد شده می باشد. لطفا مبلغ اصلاحی خود را بررسی کنید.', 16, 1);
   
   -- Insert statements for trigger here
   MERGE dbo.Payment_Method T
   USING (SELECT * FROM INSERTED) S
   ON (T.PYMT_CASH_CODE = S.PYMT_CASH_CODE AND
       T.PYMT_RQST_RQID = S.PYMT_RQST_RQID AND
       T.RQRO_RQST_RQID = S.RQRO_RQST_RQID AND
       T.RQRO_RWNO      = S.RQRO_RWNO      AND
       T.RWNO           = S.RWNO)
   WHEN MATCHED THEN
      UPDATE 
         SET MDFY_BY   = UPPER(SUSER_NAME())
            ,MDFY_DATE = GETDATE();
   
   SELECT * FROM Inserted;
   
   -- 1395/12/27 * بروز رسانی جدول هزینه برای ستون جمع مبلغ های دریافتی مشترک
   MERGE dbo.Payment T
   USING (SELECT * FROM Inserted )S
   ON (T.CASH_CODE = S.PYMT_CASH_CODE AND 
       T.RQST_RQID = S.PYMT_RQST_RQID)
   WHEN MATCHED THEN
      UPDATE SET
         T.SUM_RCPT_EXPN_PRIC = (
            SELECT ISNULL(SUM(Amnt) , 0)
              FROM dbo.Payment_Method
             WHERE PYMT_CASH_CODE = S.PYMT_CASH_CODE
               AND PYMT_RQST_RQID = S.PYMT_RQST_RQID
         );
   
   
   -- بروز کردن مبلغ بدهی هنرجو
   UPDATE dbo.Service
      SET CONF_STAT = CONF_STAT
    WHERE FILE_NO IN (
      SELECT SERV_FILE_NO
        FROM dbo.Request_Row Rr, INSERTED I
       WHERE Rr.Rqst_rqid = I.Pymt_Rqst_Rqid       
    );
END
;
GO
ALTER TABLE [dbo].[Payment_Method] ADD CONSTRAINT [PK_PMTD] PRIMARY KEY CLUSTERED  ([PYMT_CASH_CODE], [PYMT_RQST_RQID], [RQRO_RQST_RQID], [RQRO_RWNO], [RWNO]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Payment_Method] ADD CONSTRAINT [FK_PMTD_PYMT] FOREIGN KEY ([PYMT_CASH_CODE], [PYMT_RQST_RQID]) REFERENCES [dbo].[Payment] ([CASH_CODE], [RQST_RQID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Payment_Method] ADD CONSTRAINT [FK_PMTD_RQRO] FOREIGN KEY ([RQRO_RQST_RQID], [RQRO_RWNO]) REFERENCES [dbo].[Request_Row] ([RQST_RQID], [RWNO])
GO
EXEC sp_addextendedproperty N'MS_Description', N'تاریخ انجام', 'SCHEMA', N'dbo', 'TABLE', N'Payment_Method', 'COLUMN', N'ACTN_DATE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'بانک صادر کننده', 'SCHEMA', N'dbo', 'TABLE', N'Payment_Method', 'COLUMN', N'BANK'
GO
EXEC sp_addextendedproperty N'MS_Description', N'شماره کارت', 'SCHEMA', N'dbo', 'TABLE', N'Payment_Method', 'COLUMN', N'CARD_NO'
GO
EXEC sp_addextendedproperty N'MS_Description', N'شماره پیگیری', 'SCHEMA', N'dbo', 'TABLE', N'Payment_Method', 'COLUMN', N'FLOW_NO'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نوع پرداخت مبلغ', 'SCHEMA', N'dbo', 'TABLE', N'Payment_Method', 'COLUMN', N'RCPT_MTOD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'شماره ارجاع', 'SCHEMA', N'dbo', 'TABLE', N'Payment_Method', 'COLUMN', N'REF_NO'
GO
EXEC sp_addextendedproperty N'MS_Description', N'شناسه فروشگاه / پذیرنده', 'SCHEMA', N'dbo', 'TABLE', N'Payment_Method', 'COLUMN', N'SHOP_NO'
GO
EXEC sp_addextendedproperty N'MS_Description', N'شماره ترمینال', 'SCHEMA', N'dbo', 'TABLE', N'Payment_Method', 'COLUMN', N'TERM_NO'
GO
EXEC sp_addextendedproperty N'MS_Description', N'شماره تراکنش', 'SCHEMA', N'dbo', 'TABLE', N'Payment_Method', 'COLUMN', N'TRAN_NO'
GO
