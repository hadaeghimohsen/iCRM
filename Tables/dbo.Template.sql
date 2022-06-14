CREATE TABLE [dbo].[Template]
(
[JOBP_CODE] [bigint] NULL,
[TMID] [bigint] NOT NULL IDENTITY(1, 1),
[TEMP_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TEMP_SECT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TEMP_SUBJ] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TEMP_TEXT] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHER_TEAM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TEMP_NAME] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USER_NAME] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_TEMP]
   ON  [dbo].[Template]
   AFTER INSERT
AS 
BEGIN
	MERGE dbo.Template T
	USING (SELECT * FROM Inserted) S
	ON (T.TMID = S.TMID)
	WHEN MATCHED THEN
	   UPDATE SET
	      T.CRET_BY = UPPER(SUSER_NAME())
	     ,T.CRET_DATE = GETDATE();
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
CREATE TRIGGER [dbo].[CG$AUPD_TEMP]
   ON  [dbo].[Template]
   AFTER UPDATE   
AS 
BEGIN
	MERGE dbo.Template T
	USING (SELECT * FROM Inserted) S
	ON (T.TMID = S.TMID)
	WHEN MATCHED THEN
	   UPDATE SET
	      T.MDFY_BY = UPPER(SUSER_NAME())
	     ,T.MDFY_DATE = GETDATE();
END
GO
ALTER TABLE [dbo].[Template] ADD CONSTRAINT [PK_TMPL] PRIMARY KEY CLUSTERED  ([TMID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Template] ADD CONSTRAINT [FK_TEMP_JOBP] FOREIGN KEY ([JOBP_CODE]) REFERENCES [dbo].[Job_Personnel] ([CODE])
GO
EXEC sp_addextendedproperty N'MS_Description', N'برای کدام قسمت بیشتر مورد استفاده قرار میگیرد.
مثلا برای سرنخ ها
شرکت ها
مشتریان
....', 'SCHEMA', N'dbo', 'TABLE', N'Template', 'COLUMN', N'TEMP_SECT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'انواع قالب', 'SCHEMA', N'dbo', 'TABLE', N'Template', 'COLUMN', N'TEMP_TYPE'
GO
