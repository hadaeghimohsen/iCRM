CREATE TABLE [dbo].[Relation_Info]
(
[SERV_FILE_NO] [bigint] NULL,
[COMP_CODE] [bigint] NULL,
[RLAT_SERV_FILE_NO] [bigint] NULL,
[RLAT_COMP_CODE] [bigint] NULL,
[APBS_CODE] [bigint] NULL,
[REF_CODE] [bigint] NULL,
[CODE] [bigint] NOT NULL,
[RLAT_DESC] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RLAT_DATE] [datetime] NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_RLAT]
   ON  [dbo].[Relation_Info]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Relation_Info T
   USING (SELECT * FROM Inserted) S
   ON (T.CODE = S.CODE)
   WHEN MATCHED THEN
      UPDATE SET
         t.CRET_BY = UPPER(SUSER_NAME())
        ,t.CRET_DATE = GETDATE()
        ,t.CODE = dbo.GNRT_NVID_U();
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
CREATE TRIGGER [dbo].[CG$AUPD_RLAT]
   ON  [dbo].[Relation_Info]
   AFTER UPDATE   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Relation_Info T
   USING (SELECT * FROM Inserted) S
   ON (T.CODE = S.CODE)
   WHEN MATCHED THEN
      UPDATE SET
         t.MDFY_BY = UPPER(SUSER_NAME())
        ,t.MDFY_DATE = GETDATE();
END
GO
ALTER TABLE [dbo].[Relation_Info] ADD CONSTRAINT [PK_RLAT] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Relation_Info] ADD CONSTRAINT [FK_RLAT_APBS] FOREIGN KEY ([APBS_CODE]) REFERENCES [dbo].[App_Base_Define] ([CODE])
GO
ALTER TABLE [dbo].[Relation_Info] ADD CONSTRAINT [FK_RLAT_COMP] FOREIGN KEY ([COMP_CODE]) REFERENCES [dbo].[Company] ([CODE]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Relation_Info] ADD CONSTRAINT [FK_RLAT_RCMP] FOREIGN KEY ([RLAT_COMP_CODE]) REFERENCES [dbo].[Company] ([CODE])
GO
ALTER TABLE [dbo].[Relation_Info] ADD CONSTRAINT [FK_RLAT_RLAT] FOREIGN KEY ([REF_CODE]) REFERENCES [dbo].[Relation_Info] ([CODE])
GO
ALTER TABLE [dbo].[Relation_Info] ADD CONSTRAINT [FK_RLAT_RSRV] FOREIGN KEY ([RLAT_SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO])
GO
ALTER TABLE [dbo].[Relation_Info] ADD CONSTRAINT [FK_RLAT_SERV] FOREIGN KEY ([SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO]) ON DELETE CASCADE
GO
EXEC sp_addextendedproperty N'MS_Description', N'زمان برقراری ارتباط', 'SCHEMA', N'dbo', 'TABLE', N'Relation_Info', 'COLUMN', N'RLAT_DATE'
GO
