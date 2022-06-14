CREATE TABLE [dbo].[Service_Join_Service_Type]
(
[SERV_FILE_NO] [bigint] NULL,
[SRTP_CODE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SJID] [bigint] NOT NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_SJST]
   ON  [dbo].[Service_Join_Service_Type]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Service_Join_Service_Type T
   USING (SELECT * FROM Inserted) S
   ON (T.SERV_FILE_NO = S.SERV_FILE_NO AND
       T.SRTP_CODE = S.SRTP_CODE AND
       T.SJID = S.SJID)
   WHEN MATCHED THEN
      UPDATE SET
         T.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE()
        ,T.RECD_STAT = '002'
        ,T.SJID = dbo.GNRT_NVID_U();
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
CREATE TRIGGER [dbo].[CG$AUPD_SJST]
   ON  [dbo].[Service_Join_Service_Type]
   AFTER UPDATE   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Service_Join_Service_Type T
   USING (SELECT * FROM Inserted) S
   ON (T.SJID = S.SJID)
   WHEN MATCHED THEN
      UPDATE SET
         T.MDFY_BY = UPPER(SUSER_NAME())
        ,T.MDFY_DATE = GETDATE();        
END
GO
ALTER TABLE [dbo].[Service_Join_Service_Type] ADD CONSTRAINT [PK_SJST] PRIMARY KEY CLUSTERED  ([SJID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Service_Join_Service_Type] ADD CONSTRAINT [FK_SJST_SERV] FOREIGN KEY ([SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Service_Join_Service_Type] ADD CONSTRAINT [FK_SJST_SRTP] FOREIGN KEY ([SRTP_CODE]) REFERENCES [dbo].[Service_Type] ([CODE]) ON DELETE CASCADE
GO
