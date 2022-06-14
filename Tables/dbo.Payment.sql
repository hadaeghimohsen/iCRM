CREATE TABLE [dbo].[Payment]
(
[CASH_CODE] [bigint] NOT NULL,
[RQST_RQID] [bigint] NOT NULL,
[SERV_FILE_NO] [bigint] NULL,
[SRPB_RWNO_DNRM] [int] NULL,
[SRPB_RECT_CODE_DNRM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Payment__TYPE__02FC7413] DEFAULT ('001'),
[RECV_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Payment__RECV_TY__03F0984C] DEFAULT ('001'),
[SUM_EXPN_PRIC] [int] NOT NULL CONSTRAINT [DF__Payment__SUM_EXP__04E4BC85] DEFAULT ((0)),
[SUM_EXPN_EXTR_PRCT] [int] NOT NULL CONSTRAINT [DF__Payment__SUM_EXP__05D8E0BE] DEFAULT ((0)),
[SUM_REMN_PRIC] [int] NOT NULL CONSTRAINT [DF__Payment__SUM_REM__06CD04F7] DEFAULT ((0)),
[SUM_RCPT_EXPN_PRIC] [int] NOT NULL CONSTRAINT [DF__Payment__SUM_RCP__07C12930] DEFAULT ((0)),
[SUM_RCPT_EXPN_EXTR_PRCT] [int] NOT NULL CONSTRAINT [DF__Payment__SUM_RCP__08B54D69] DEFAULT ((0)),
[SUM_RCPT_REMN_PRIC] [int] NOT NULL CONSTRAINT [DF__Payment__SUM_RCP__09A971A2] DEFAULT ((0)),
[SUM_PYMT_DSCN_DNRM] [int] NULL CONSTRAINT [DF_Payment_SUM_PYMT_DSCN_DNRM] DEFAULT ((0)),
[CASH_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CASH_DATE] [datetime] NULL,
[ANNC_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Payment__ANNC_TY__0A9D95DB] DEFAULT ('001'),
[ANNC_DATE] [datetime] NULL,
[LETT_NO] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LETT_DATE] [datetime] NULL,
[DELV_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Payment_DELV_STAT] DEFAULT ((1)),
[DELV_DATE] [datetime] NULL,
[DELV_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COMP_CODE_DNRM] [bigint] NULL,
[AMNT_UNIT_TYPE_DNRM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOCK_DATE] [datetime] NULL,
[PYMT_DESC] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PYMT_STAG] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SINF_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SINF_SORC_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REF_SERV_FILE_NO] [bigint] NULL,
[REF_COMP_CODE] [bigint] NULL,
[REF_OTHR_DESC] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PYMT_DATE] [datetime] NULL,
[PYMT_LOST_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PYMT_LOST_DESC] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_PYMT]
   ON  [dbo].[Payment]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Payment T
   USING (SELECT * FROM INSERTED) S
   ON (T.RQST_RQID = S.RQST_RQID AND
       T.CASH_CODE = S.CASH_CODE)
   WHEN MATCHED THEN
      UPDATE 
         SET CRET_BY   = UPPER(SUSER_NAME())
            ,CRET_DATE = GETDATE()
            ,DELV_STAT = '001'
            ,COMP_CODE_DNRM = 
            CASE WHEN (
				   SELECT TOP 1 COMP_CODE 
				     FROM Service_Public F 
				    WHERE F.Rqro_Rqst_Rqid = S.Rqst_Rqid) IS NOT NULL THEN (
				      SELECT TOP 1 COMP_CODE 
				        FROM Service_Public F 
				       WHERE F.Rqro_Rqst_Rqid = S.Rqst_Rqid)
				    ELSE (
				      SELECT F.COMP_Code_Dnrm
				        FROM Service F
				       WHERE F.Rqst_Rqid = S.Rqst_Rqid
				    )
				 END
				,AMNT_UNIT_TYPE_DNRM = (
				   SELECT ISNULL(AMNT_TYPE, '001')
				     FROM dbo.Regulation
				    WHERE REGL_STAT = '002'
				      AND [TYPE] = '001'
				)
				,T.LOCK_DATE = DATEADD(DAY, 30, GETDATE())
				,T.SRPB_RECT_CODE_DNRM = '004'
				,T.SRPB_RWNO_DNRM = (SELECT SRPB_RWNO_DNRM FROM service WHERE FILE_NO = S.SERV_FILE_NO);
END
;
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[CG$AUPD_PYMT]
   ON  [dbo].[Payment]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   
   -- Insert statements for trigger here
   IF EXISTS(
      SELECT * FROM DELETED D, INSERTED I
      WHERE D.RQST_RQID = I.RQST_RQID
        AND D.TYPE      <> I.TYPE
   )
   BEGIN
      RAISERROR ('مبلغ اعلام هزینه شده از حالت واریز وجه به حالت استرداد وجه و برعکس امکان پذیر نمی باشد', -- Message text.
         16, -- Severity.
         1 -- State.
         );
      ROLLBACK TRANSACTION;
   END;
   
   
   MERGE dbo.Payment T
   USING (SELECT * FROM INSERTED) S
   ON (T.RQST_RQID = S.RQST_RQID AND 
       T.CASH_CODE = S.CASH_CODE)
   WHEN MATCHED THEN
      UPDATE 
         SET MDFY_BY   = UPPER(SUSER_NAME())
            ,MDFY_DATE = GETDATE()
            ,CASH_BY   = CASE WHEN S.SUM_EXPN_PRIC = (ISNULL(S.SUM_RCPT_EXPN_PRIC, 0) + S.SUM_PYMT_DSCN_DNRM) AND S.Cash_By IS NULL THEN SUSER_NAME() WHEN S.Cash_By IS NULL THEN NULL ELSE S.Cash_By END
            ,CASH_DATE = CASE WHEN S.SUM_EXPN_PRIC = (ISNULL(S.SUM_RCPT_EXPN_PRIC, 0) + S.SUM_PYMT_DSCN_DNRM) AND S.Cash_Date IS NULL THEN GETDATE()  WHEN S.Cash_Date IS NULL THEN NULL ELSE S.Cash_Date END;

  UPDATE dbo.Service
     SET CONF_STAT = CONF_STAT
   WHERE EXISTS(
         SELECT *
           FROM INSERTED S
          WHERE File_No = S.SERV_FILE_NO
   );   
END
;
GO
ALTER TABLE [dbo].[Payment] ADD CONSTRAINT [PYMT_PK] PRIMARY KEY CLUSTERED  ([CASH_CODE], [RQST_RQID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Payment] ADD CONSTRAINT [FK_PYMT_CASH] FOREIGN KEY ([CASH_CODE]) REFERENCES [dbo].[Cash] ([CODE]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Payment] ADD CONSTRAINT [FK_PYMT_COMP] FOREIGN KEY ([COMP_CODE_DNRM]) REFERENCES [dbo].[Company] ([CODE]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Payment] ADD CONSTRAINT [FK_PYMT_RCMP] FOREIGN KEY ([REF_COMP_CODE]) REFERENCES [dbo].[Company] ([CODE])
GO
ALTER TABLE [dbo].[Payment] ADD CONSTRAINT [FK_PYMT_RQST] FOREIGN KEY ([RQST_RQID]) REFERENCES [dbo].[Request] ([RQID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Payment] ADD CONSTRAINT [FK_PYMT_RSRV] FOREIGN KEY ([REF_SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Payment] ADD CONSTRAINT [FK_PYMT_SERV] FOREIGN KEY ([SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO])
GO
ALTER TABLE [dbo].[Payment] ADD CONSTRAINT [FK_PYMT_SRPB] FOREIGN KEY ([SERV_FILE_NO], [SRPB_RWNO_DNRM], [SRPB_RECT_CODE_DNRM]) REFERENCES [dbo].[Service_Public] ([SERV_FILE_NO], [RWNO], [RECT_CODE])
GO
EXEC sp_addextendedproperty N'MS_Description', N'تاریخ معامله', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'PYMT_DATE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'عنوان معامله', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'PYMT_DESC'
GO
EXEC sp_addextendedproperty N'MS_Description', N'شرح عدم خرید مشتری', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'PYMT_LOST_DESC'
GO
EXEC sp_addextendedproperty N'MS_Description', N'دلیل نخریدن مشتری', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'PYMT_LOST_TYPE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'وضعیت معامله', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'PYMT_STAG'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نوع منبع عامل فروش', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'SINF_SORC_TYPE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نوع فروش معامله', 'SCHEMA', N'dbo', 'TABLE', N'Payment', 'COLUMN', N'SINF_TYPE'
GO
