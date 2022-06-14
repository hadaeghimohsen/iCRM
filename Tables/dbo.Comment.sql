CREATE TABLE [dbo].[Comment]
(
[RQRO_RQST_RQID] [bigint] NULL,
[RQRO_RWNO] [smallint] NULL,
[SERV_FILE_NO_DNRM] [bigint] NULL,
[JOBP_CODE_DNRM] [bigint] NULL,
[CMID] [bigint] NOT NULL IDENTITY(1, 1),
[CMNT] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRET_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRET_DATE] [datetime] NULL,
[MDFY_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MDFY_DATE] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
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
CREATE TRIGGER [dbo].[CG$AINS_CMNT]
   ON  [dbo].[Comment]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Comment T
   USING (SELECT * FROM Inserted) S
   ON (T.CMID = S.CMID)
   WHEN MATCHED THEN
      UPDATE SET
        T.CRET_BY = UPPER(SUSER_NAME())
       ,T.CRET_DATE = GETDATE()
       ,T.JOBP_CODE_DNRM = (
           SELECT CODE
             FROM dbo.Job_Personnel
            WHERE UPPER(USER_NAME) = UPPER(SUSER_NAME())
              AND STAT = '002'
       )
       ,T.SERV_FILE_NO_DNRM = (
           SELECT rr.SERV_FILE_NO
             FROM dbo.Request_Row rr
            WHERE rr.RQST_RQID = s.RQRO_RQST_RQID 
              AND rr.RWNO = s.RQRO_RWNO
       );
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
CREATE TRIGGER [dbo].[CG$AUPD_CMNT]
   ON  [dbo].[Comment]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Comment T
   USING (SELECT * FROM Inserted) S
   ON (T.CMID = S.CMID)
   WHEN MATCHED THEN
      UPDATE SET
        T.MDFY_BY = UPPER(SUSER_NAME())
       ,T.MDFY_DATE = GETDATE();
       
   -- Check Mentioned User
   DECLARE @X XML;
   SELECT @X = (
      SELECT (
            SELECT s.RQRO_RQST_RQID AS '@rqid'
                  ,s.SERV_FILE_NO_DNRM AS '@fileno'
                  ,s.CMNT AS 'Text'
              FROM Inserted s
               FOR XML PATH('Mention'), TYPE
         )
         FOR XML PATH('Mentions')
   );
   EXEC SET_MNTN_P @X = @X;
   
   DELETE dbo.Mention
    WHERE EXISTS(
      SELECT * 
        FROM Inserted s
       WHERE s.RQRO_RQST_RQID = dbo.Mention.RQST_RQID
    )
    AND MDFY_STAT = '002';
END
GO
ALTER TABLE [dbo].[Comment] ADD CONSTRAINT [PK_Comment] PRIMARY KEY CLUSTERED  ([CMID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Comment] ADD CONSTRAINT [FK_CMNT_JOBP] FOREIGN KEY ([JOBP_CODE_DNRM]) REFERENCES [dbo].[Job_Personnel] ([CODE])
GO
ALTER TABLE [dbo].[Comment] ADD CONSTRAINT [FK_CMNT_RQRO] FOREIGN KEY ([RQRO_RQST_RQID], [RQRO_RWNO]) REFERENCES [dbo].[Request_Row] ([RQST_RQID], [RWNO]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Comment] ADD CONSTRAINT [FK_CMNT_SERV] FOREIGN KEY ([SERV_FILE_NO_DNRM]) REFERENCES [dbo].[Service] ([FILE_NO]) ON DELETE CASCADE
GO
