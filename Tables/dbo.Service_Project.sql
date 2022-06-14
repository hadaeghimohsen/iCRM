CREATE TABLE [dbo].[Service_Project]
(
[RQRO_RQST_RQID] [bigint] NULL,
[RQRO_RWNO] [smallint] NULL,
[JBPR_CODE] [bigint] NULL,
[SERV_FILE_NO_DNRM] [bigint] NULL,
[CODE] [bigint] NOT NULL,
[REC_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RAJP_DESC] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UPDT_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DELT_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHAR_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
create TRIGGER [dbo].[CG$AINS_SRPR]
   ON  [dbo].[Service_Project]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Service_Project T
   USING (SELECT * FROM Inserted) S
   ON (T.CODE = S.CODE)
   WHEN MATCHED THEN
      UPDATE SET 
         T.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE()
        ,T.CODE = dbo.GNRT_NVID_U();
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
create TRIGGER [dbo].[CG$AUPD_SRPR]
   ON  [dbo].[Service_Project]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Service_Project T
   USING (SELECT * FROM Inserted) S
   ON (T.CODE = S.CODE)
   WHEN MATCHED THEN
      UPDATE SET 
         T.MDFY_BY = UPPER(SUSER_NAME())
        ,T.MDFY_DATE = GETDATE();
END
GO
ALTER TABLE [dbo].[Service_Project] ADD CONSTRAINT [PK_SRPR] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Service_Project] ADD CONSTRAINT [FK_SRPR_JBPR] FOREIGN KEY ([JBPR_CODE]) REFERENCES [dbo].[Job_Personnel_Relation] ([CODE])
GO
ALTER TABLE [dbo].[Service_Project] ADD CONSTRAINT [FK_SRPR_RQRO] FOREIGN KEY ([RQRO_RQST_RQID], [RQRO_RWNO]) REFERENCES [dbo].[Request_Row] ([RQST_RQID], [RWNO])
GO
ALTER TABLE [dbo].[Service_Project] ADD CONSTRAINT [FK_SRPR_RQST] FOREIGN KEY ([RQRO_RQST_RQID]) REFERENCES [dbo].[Request] ([RQID])
GO
ALTER TABLE [dbo].[Service_Project] ADD CONSTRAINT [FK_SRPR_SERV] FOREIGN KEY ([SERV_FILE_NO_DNRM]) REFERENCES [dbo].[Service] ([FILE_NO])
GO
EXEC sp_addextendedproperty N'MS_Description', N'قابلیت حذف اطلاعات', 'SCHEMA', N'dbo', 'TABLE', N'Service_Project', 'COLUMN', N'DELT_STAT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'قابلیت به اشتراک گذاری', 'SCHEMA', N'dbo', 'TABLE', N'Service_Project', 'COLUMN', N'SHAR_STAT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'قابلیت بروزرسانی', 'SCHEMA', N'dbo', 'TABLE', N'Service_Project', 'COLUMN', N'UPDT_STAT'
GO
