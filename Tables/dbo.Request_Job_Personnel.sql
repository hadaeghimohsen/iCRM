CREATE TABLE [dbo].[Request_Job_Personnel]
(
[RQST_RQID] [bigint] NOT NULL,
[RWNO] [int] NOT NULL CONSTRAINT [DF_Request_Job_Personnel_RWNO] DEFAULT ((0)),
[RQST_JOBP_CODE] [bigint] NULL,
[RQST_JOBP_DESC] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_RQJP]
   ON  [dbo].[Request_Job_Personnel]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Request_Job_Personnel T   
   USING (SELECT * FROM INSERTED) S
   ON (T.RQST_RQID = S.RQST_RQID AND 
       T.RWNO      = S.RWNO)
   WHEN MATCHED THEN
      UPDATE 
         SET CRET_BY   = UPPER(SUSER_NAME())
            ,CRET_DATE = GETDATE()
            ,RWNO      = (SELECT ISNULL(MAX(RWNO), 0) + 1 FROM dbo.Request_Job_Personnel WHERE RQST_RQID = S.RQST_RQID);
   
   MERGE dbo.Request T
   USING (SELECT * FROM Inserted) S
   ON(T.Rqid = S.Rqst_Rqid)
   WHEN MATCHED THEN
      UPDATE SET T.LAST_JOBP_CODE_DNRM = (
         SELECT TOP 1 S.RQST_JOBP_CODE 
           FROM dbo.Request_Job_Personnel
          WHERE RQST_RQID = S.RQST_RQID
          ORDER BY CRET_DATE DESC          
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
CREATE TRIGGER [dbo].[CG$AUPD_RQJP]
   ON  [dbo].[Request_Job_Personnel]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Request_Job_Personnel T   
   USING (SELECT * FROM INSERTED) S
   ON (T.RQST_RQID = S.RQST_RQID AND 
       T.RWNO      = S.RWNO)
   WHEN MATCHED THEN
      UPDATE 
         SET MDFY_BY   = UPPER(SUSER_NAME())
            ,MDFY_DATE = GETDATE();
END
GO
ALTER TABLE [dbo].[Request_Job_Personnel] ADD CONSTRAINT [PK_RQJP] PRIMARY KEY CLUSTERED  ([RQST_RQID], [RWNO]) ON [PRIMARY]
GO
