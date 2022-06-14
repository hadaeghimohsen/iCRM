CREATE TABLE [dbo].[Lead]
(
[RQRO_RQST_RQID] [bigint] NULL,
[RQRO_RWNO] [smallint] NULL,
[OWNR_CODE] [bigint] NULL,
[CAMP_CMID] [bigint] NULL,
[COMP_CODE] [bigint] NULL,
[SRPB_SERV_FILE_NO] [bigint] NULL,
[SRPB_RWNO] [int] NULL,
[SRPB_RECT_CODE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LDID] [bigint] NOT NULL,
[TOPC] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRCH_TIME] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BDGT_AMNT] [bigint] NULL,
[PRCH_PROC] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IDCM_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CAPT_SMRY] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMNT] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRNT_SITU] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CUST_NEED] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROP_SOLT] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IDTY_STAK_HLDR] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IDTY_CMPT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IDTY_SALE_TEAM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DEVL_PROP] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMPL_INTR_REVW] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRES_PROP] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMPL_FINL_PROP] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRES_FINL_PROP] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CONF_DATE] [datetime] NULL,
[SEND_THNK_YOU] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FILE_DBRF] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMST_CLOS_DATE] [datetime] NULL,
[EMST_REVN_AMNT] [bigint] NULL,
[EXPN_COST_AMNT] [bigint] NULL,
[STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SORC] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RTNG] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SEND_CAMP_INFO] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSBL_NUMB] [smallint] NULL,
[TRCB_TCID] [bigint] NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_LEAD]
   ON  [dbo].[Lead]
   AFTER INSERT   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Lead T
   USING (SELECT * FROM Inserted) S
   ON (t.LDID = s.LDID)
   WHEN MATCHED THEN
      UPDATE SET
         T.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE()
        ,T.LDID = CASE WHEN s.LDID = 0 THEN dbo.GNRT_NWID_U() ELSE s.LDID END;
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
CREATE TRIGGER [dbo].[CG$AUPD_LEAD]
   ON  [dbo].[Lead]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Lead T
   USING (SELECT * FROM Inserted) S
   ON (t.LDID = s.LDID)
   WHEN MATCHED THEN
      UPDATE SET
         T.MDFY_BY = UPPER(SUSER_NAME())
        ,T.MDFY_DATE = GETDATE();        
END
GO
ALTER TABLE [dbo].[Lead] ADD CONSTRAINT [PK_LEAD] PRIMARY KEY CLUSTERED  ([LDID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Lead] ADD CONSTRAINT [FK_LEAD_CAMP] FOREIGN KEY ([CAMP_CMID]) REFERENCES [dbo].[Campaign] ([CMID])
GO
ALTER TABLE [dbo].[Lead] ADD CONSTRAINT [FK_LEAD_COMP] FOREIGN KEY ([COMP_CODE]) REFERENCES [dbo].[Company] ([CODE])
GO
ALTER TABLE [dbo].[Lead] ADD CONSTRAINT [FK_LEAD_JOBP] FOREIGN KEY ([OWNR_CODE]) REFERENCES [dbo].[Job_Personnel] ([CODE])
GO
ALTER TABLE [dbo].[Lead] ADD CONSTRAINT [FK_LEAD_RQRO] FOREIGN KEY ([RQRO_RQST_RQID], [RQRO_RWNO]) REFERENCES [dbo].[Request_Row] ([RQST_RQID], [RWNO])
GO
ALTER TABLE [dbo].[Lead] ADD CONSTRAINT [FK_LEAD_SRPB] FOREIGN KEY ([SRPB_SERV_FILE_NO], [SRPB_RWNO], [SRPB_RECT_CODE]) REFERENCES [dbo].[Service_Public] ([SERV_FILE_NO], [RWNO], [RECT_CODE])
GO
ALTER TABLE [dbo].[Lead] ADD CONSTRAINT [FK_LEAD_TRCB] FOREIGN KEY ([TRCB_TCID]) REFERENCES [dbo].[Transaction_Currency_Base] ([TCID])
GO
EXEC sp_addextendedproperty N'MS_Description', N'بودجه برآورد شده', 'SCHEMA', N'dbo', 'TABLE', N'Lead', 'COLUMN', N'BDGT_AMNT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'خلاصه ضبط', 'SCHEMA', N'dbo', 'TABLE', N'Lead', 'COLUMN', N'CAPT_SMRY'
GO
EXEC sp_addextendedproperty N'MS_Description', N'توضیحات', 'SCHEMA', N'dbo', 'TABLE', N'Lead', 'COLUMN', N'CMNT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'وضعیت فعلی', 'SCHEMA', N'dbo', 'TABLE', N'Lead', 'COLUMN', N'CRNT_SITU'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نیاز مشتری', 'SCHEMA', N'dbo', 'TABLE', N'Lead', 'COLUMN', N'CUST_NEED'
GO
EXEC sp_addextendedproperty N'MS_Description', N'هزینه ها', 'SCHEMA', N'dbo', 'TABLE', N'Lead', 'COLUMN', N'EXPN_COST_AMNT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'شناسایی تصمیم ساز', 'SCHEMA', N'dbo', 'TABLE', N'Lead', 'COLUMN', N'IDCM_STAT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'شناسایی صاحبان سهام', 'SCHEMA', N'dbo', 'TABLE', N'Lead', 'COLUMN', N'IDTY_STAK_HLDR'
GO
EXEC sp_addextendedproperty N'MS_Description', N'این شرکت متعلق به چه کسی می باشد. کاربری که این شرکت را ثبت کرده و مالکش می باشد کیست', 'SCHEMA', N'dbo', 'TABLE', N'Lead', 'COLUMN', N'OWNR_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'فرآیند خرید', 'SCHEMA', N'dbo', 'TABLE', N'Lead', 'COLUMN', N'PRCH_PROC'
GO
EXEC sp_addextendedproperty N'MS_Description', N'چارچوب زمانی خرید', 'SCHEMA', N'dbo', 'TABLE', N'Lead', 'COLUMN', N'PRCH_TIME'
GO
EXEC sp_addextendedproperty N'MS_Description', N'راهکار پیشنهادی', 'SCHEMA', N'dbo', 'TABLE', N'Lead', 'COLUMN', N'PROP_SOLT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'احتمال', 'SCHEMA', N'dbo', 'TABLE', N'Lead', 'COLUMN', N'PSBL_NUMB'
GO
EXEC sp_addextendedproperty N'MS_Description', N'عنوان سرنخ تجاری', 'SCHEMA', N'dbo', 'TABLE', N'Lead', 'COLUMN', N'TOPC'
GO
