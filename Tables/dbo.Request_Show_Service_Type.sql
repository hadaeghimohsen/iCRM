CREATE TABLE [dbo].[Request_Show_Service_Type]
(
[RQRO_RQST_RQID] [bigint] NULL,
[RQRO_RWNO] [smallint] NULL,
[SERV_FILE_NO] [bigint] NULL,
[SRTP_CODE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RSID] [bigint] NOT NULL,
[RECD_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_RSST]
   ON  [dbo].[Request_Show_Service_Type]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Request_Show_Service_Type T
   USING (SELECT * FROM Inserted) S
   ON ( T.RQRO_RQST_RQID = S.RQRO_RQST_RQID AND
        T.RQRO_RWNO = S.RQRO_RWNO AND
        T.SERV_FILE_NO = S.SERV_FILE_NO AND
        T.SRTP_CODE = S.SRTP_CODE AND
        T.RSID = S.RSID
   )
   WHEN MATCHED THEN
      UPDATE SET
         T.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE()
        ,T.RSID = dbo.GNRT_NVID_U()
        ,T.RECD_STAT = '002';
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
CREATE TRIGGER [dbo].[CG$AUPD_RSST]
   ON  [dbo].[Request_Show_Service_Type]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Request_Show_Service_Type T
   USING (SELECT * FROM Inserted) S
   ON ( T.RSID = S.RSID )
   WHEN MATCHED THEN
      UPDATE SET
         T.MDFY_BY = UPPER(SUSER_NAME())
        ,T.MDFY_DATE = GETDATE();
END
GO
ALTER TABLE [dbo].[Request_Show_Service_Type] ADD CONSTRAINT [PK_RSST] PRIMARY KEY CLUSTERED  ([RSID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Request_Show_Service_Type] ADD CONSTRAINT [FK_RSST_RQRO] FOREIGN KEY ([RQRO_RQST_RQID], [RQRO_RWNO]) REFERENCES [dbo].[Request_Row] ([RQST_RQID], [RWNO]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Request_Show_Service_Type] ADD CONSTRAINT [FK_RSST_SERV] FOREIGN KEY ([SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Request_Show_Service_Type] ADD CONSTRAINT [FK_RSST_SRTP] FOREIGN KEY ([SRTP_CODE]) REFERENCES [dbo].[Service_Type] ([CODE]) ON DELETE CASCADE
GO
