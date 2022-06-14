CREATE TABLE [dbo].[Template_Attachment]
(
[TEMP_TMID] [bigint] NULL,
[TAID] [bigint] NOT NULL,
[FILE_PATH] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FILE_SRVR_LINK] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUBJ_DESC] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHER_TEAM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_TMAT]
   ON  [dbo].[Template_Attachment]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Template_Attachment T
   USING (SELECT * FROM Inserted) S
   ON (T.TEMP_TMID = S.TEMP_TMID AND 
       T.TAID = S.TAID)
   WHEN MATCHED THEN
      UPDATE SET
         T.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE()
        ,T.TAID = dbo.GNRT_NWID_U();

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
CREATE TRIGGER [dbo].[CG$AUPD_TMAT]
   ON  [dbo].[Template_Attachment]
   AFTER UPDATE   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Template_Attachment T
   USING (SELECT * FROM Inserted) S
   ON (T.TEMP_TMID = S.TEMP_TMID AND 
       T.TAID = S.TAID)
   WHEN MATCHED THEN
      UPDATE SET
         T.MDFY_BY = UPPER(SUSER_NAME())
        ,T.MDFY_DATE = GETDATE();
END
GO
ALTER TABLE [dbo].[Template_Attachment] ADD CONSTRAINT [PK_TMAT] PRIMARY KEY CLUSTERED  ([TAID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Template_Attachment] ADD CONSTRAINT [FK_TMAT_TEMP] FOREIGN KEY ([TEMP_TMID]) REFERENCES [dbo].[Template] ([TMID])
GO
