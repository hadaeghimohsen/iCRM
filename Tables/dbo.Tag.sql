CREATE TABLE [dbo].[Tag]
(
[RQRO_RQST_RQID] [bigint] NULL,
[RQRO_RWNO] [smallint] NULL,
[SERV_FILE_NO] [bigint] NULL,
[SRPB_RWNO_DNRM] [int] NULL,
[SRPB_RECT_CODE_DNRM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COMP_CODE_DNRM] [bigint] NULL,
[TGID] [bigint] NOT NULL IDENTITY(1, 1),
[APBS_CODE] [bigint] NULL,
[TAG_DESC] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_TAG]
   ON  [dbo].[Tag]
   AFTER INSERT   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Tag T
   USING (SELECT * FROM Inserted) S
   ON (T.TGID = S.TGID)
   WHEN MATCHED THEN
      UPDATE SET
          T.CRET_BY = UPPER(SUSER_NAME())
         ,T.CRET_DATE = GETDATE()
         ,T.SRPB_RECT_CODE_DNRM = '004'
         ,T.SRPB_RWNO_DNRM = (SELECT SRPB_RWNO_DNRM FROM Service WHERE FILE_NO = S.SERV_FILE_NO);

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
CREATE TRIGGER [dbo].[CG$AUPD_TAG]
   ON  [dbo].[Tag]
   AFTER UPDATE   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Tag T
   USING (SELECT * FROM Inserted) S
   ON (T.TGID = S.TGID)
   WHEN MATCHED THEN
      UPDATE SET
          T.MDFY_BY = UPPER(SUSER_NAME())
         ,T.MDFY_DATE = GETDATE()
         /*,T.COMP_CODE_DNRM = 
               CASE
                  WHEN S.COMP_CODE_DNRM IS NULL AND S.RQRO_RQST_RQID IS NOT NULL THEN (SELECT COMP_CODE FROM dbo.Request_Row WHERE RQST_RQID = S.RQRO_RQST_RQID AND RWNO = S.RQRO_RWNO)
                  WHEN S.COMP_CODE_DNRM IS NULL AND S.SERV_FILE_NO IS NOT NULL THEN (SELECT COMP_CODE_DNRM FROM Service WHERE FILE_NO = S.SERV_FILE_NO)
                  ELSE S.COMP_CODE_DNRM
               END*/;

END
GO
ALTER TABLE [dbo].[Tag] ADD CONSTRAINT [PK_Tag] PRIMARY KEY CLUSTERED  ([TGID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Tag] ADD CONSTRAINT [FK_TAG_APBS] FOREIGN KEY ([APBS_CODE]) REFERENCES [dbo].[App_Base_Define] ([CODE])
GO
ALTER TABLE [dbo].[Tag] ADD CONSTRAINT [FK_TAG_COMP] FOREIGN KEY ([COMP_CODE_DNRM]) REFERENCES [dbo].[Company] ([CODE]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Tag] ADD CONSTRAINT [FK_TAG_RQRO] FOREIGN KEY ([RQRO_RQST_RQID], [RQRO_RWNO]) REFERENCES [dbo].[Request_Row] ([RQST_RQID], [RWNO]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Tag] ADD CONSTRAINT [FK_TAG_SERV] FOREIGN KEY ([SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Tag] ADD CONSTRAINT [FK_TAG_SRPB] FOREIGN KEY ([SERV_FILE_NO], [SRPB_RWNO_DNRM], [SRPB_RECT_CODE_DNRM]) REFERENCES [dbo].[Service_Public] ([SERV_FILE_NO], [RWNO], [RECT_CODE])
GO
