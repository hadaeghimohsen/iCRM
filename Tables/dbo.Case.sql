CREATE TABLE [dbo].[Case]
(
[RQRO_RQST_RQID] [bigint] NULL,
[RQRO_RWNO] [smallint] NULL,
[OWNR_CODE] [bigint] NULL,
[COMP_CODE] [bigint] NULL,
[SRPB_SERV_FILE_NO] [bigint] NULL,
[SRPB_RWNO] [int] NULL,
[SRPB_RECT_CODE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CSID] [bigint] NOT NULL,
[TITL] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUBJ_APBS_CODE] [bigint] NULL,
[ORGN_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRIO_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMNT] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRNT_CASE_CSID] [bigint] NULL,
[ESCL_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ESCL_DATE] [datetime] NULL,
[FLOW_UP_DATE] [datetime] NULL,
[SENT_FRST_RESP] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SERL_NUMB] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SERV_LEVL] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RESP_DESC] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TOTL_MIN_TIME] [int] NULL,
[RMRK_DESC] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_CASE]
   ON  [dbo].[Case]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.[Case] T
   USING (SELECT * FROM Inserted) S
   ON (T.RQRO_RQST_RQID = S.RQRO_RQST_RQID AND 
       T.RQRO_RWNO = S.RQRO_RWNO AND 
       T.OWNR_CODE = S.OWNR_CODE)
   WHEN MATCHED THEN 
      UPDATE SET 
         T.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE()
        ,T.CSID = dbo.GNRT_NVID_U();
   
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
CREATE TRIGGER [dbo].[CG$AUPD_CASE]
   ON  [dbo].[Case]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.[Case] T
   USING (SELECT * FROM Inserted) S
   ON (T.CSID = S.CSID)
   WHEN MATCHED THEN 
      UPDATE SET 
         T.MDFY_BY = UPPER(SUSER_NAME())
        ,T.MDFY_DATE = GETDATE();
   
END
GO
ALTER TABLE [dbo].[Case] ADD CONSTRAINT [PK_CASE] PRIMARY KEY CLUSTERED  ([CSID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Case] ADD CONSTRAINT [FK_CASE_APBS] FOREIGN KEY ([SUBJ_APBS_CODE]) REFERENCES [dbo].[App_Base_Define] ([CODE])
GO
ALTER TABLE [dbo].[Case] ADD CONSTRAINT [FK_CASE_CASE] FOREIGN KEY ([PRNT_CASE_CSID]) REFERENCES [dbo].[Case] ([CSID])
GO
ALTER TABLE [dbo].[Case] ADD CONSTRAINT [FK_CASE_COMP] FOREIGN KEY ([COMP_CODE]) REFERENCES [dbo].[Company] ([CODE])
GO
ALTER TABLE [dbo].[Case] ADD CONSTRAINT [FK_CASE_JBPR] FOREIGN KEY ([OWNR_CODE]) REFERENCES [dbo].[Job_Personnel] ([CODE])
GO
ALTER TABLE [dbo].[Case] ADD CONSTRAINT [FK_CASE_RQRO] FOREIGN KEY ([RQRO_RQST_RQID], [RQRO_RWNO]) REFERENCES [dbo].[Request_Row] ([RQST_RQID], [RWNO])
GO
ALTER TABLE [dbo].[Case] ADD CONSTRAINT [FK_CASE_SRPB] FOREIGN KEY ([SRPB_SERV_FILE_NO], [SRPB_RWNO], [SRPB_RECT_CODE]) REFERENCES [dbo].[Service_Public] ([SERV_FILE_NO], [RWNO], [RECT_CODE])
GO
EXEC sp_addextendedproperty N'MS_Description', N'توضیحات', 'SCHEMA', N'dbo', 'TABLE', N'Case', 'COLUMN', N'CMNT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'تاریخ گسترش', 'SCHEMA', N'dbo', 'TABLE', N'Case', 'COLUMN', N'ESCL_DATE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'گسترش یافته', 'SCHEMA', N'dbo', 'TABLE', N'Case', 'COLUMN', N'ESCL_TYPE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'تاریخ پیگیری توسط کاربر برای مشتری', 'SCHEMA', N'dbo', 'TABLE', N'Case', 'COLUMN', N'FLOW_UP_DATE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'منشا', 'SCHEMA', N'dbo', 'TABLE', N'Case', 'COLUMN', N'ORGN_TYPE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'اولویت', 'SCHEMA', N'dbo', 'TABLE', N'Case', 'COLUMN', N'PRIO_TYPE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'پرونده بالاسری', 'SCHEMA', N'dbo', 'TABLE', N'Case', 'COLUMN', N'PRNT_CASE_CSID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'حل', 'SCHEMA', N'dbo', 'TABLE', N'Case', 'COLUMN', N'RESP_DESC'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ملاحظات', 'SCHEMA', N'dbo', 'TABLE', N'Case', 'COLUMN', N'RMRK_DESC'
GO
EXEC sp_addextendedproperty N'MS_Description', N'پاسخ اولیه ارسال شده است', 'SCHEMA', N'dbo', 'TABLE', N'Case', 'COLUMN', N'SENT_FRST_RESP'
GO
EXEC sp_addextendedproperty N'MS_Description', N'شماره سریال', 'SCHEMA', N'dbo', 'TABLE', N'Case', 'COLUMN', N'SERL_NUMB'
GO
EXEC sp_addextendedproperty N'MS_Description', N'سطح سرویس', 'SCHEMA', N'dbo', 'TABLE', N'Case', 'COLUMN', N'SERV_LEVL'
GO
EXEC sp_addextendedproperty N'MS_Description', N'وضعیت پرونده', 'SCHEMA', N'dbo', 'TABLE', N'Case', 'COLUMN', N'STAT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'موضوع پرونده', 'SCHEMA', N'dbo', 'TABLE', N'Case', 'COLUMN', N'SUBJ_APBS_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'عنوان', 'SCHEMA', N'dbo', 'TABLE', N'Case', 'COLUMN', N'TITL'
GO
EXEC sp_addextendedproperty N'MS_Description', N'مدت زمان', 'SCHEMA', N'dbo', 'TABLE', N'Case', 'COLUMN', N'TOTL_MIN_TIME'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نوع پرونده', 'SCHEMA', N'dbo', 'TABLE', N'Case', 'COLUMN', N'TYPE'
GO
