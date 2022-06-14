CREATE TABLE [dbo].[Extra_Info]
(
[COMP_CODE] [bigint] NULL,
[SERV_FILE_NO] [bigint] NULL,
[APBS_CODE] [bigint] NULL,
[APBS_CODE_DNRM] [bigint] NULL,
[EXIF_CODE] [bigint] NULL,
[CODE] [bigint] NOT NULL,
[RWNO] [int] NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_EXIF]
   ON  [dbo].[Extra_Info]
   AFTER INSERT 
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Extra_Info T
   USING (SELECT * FROM Inserted) S
   ON (T.CODE = S.CODE)
   WHEN MATCHED THEN
      UPDATE SET
         T.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE()
        ,T.CODE = dbo.GNRT_NVID_U()
        ,T.APBS_CODE_DNRM = CASE WHEN S.EXIF_CODE IS NULL THEN NULL
                                 WHEN S.EXIF_CODE IS NOT NULL THEN (SELECT a.APBS_CODE FROM dbo.Extra_Info a WHERE a.code = s.EXIF_CODE)
                            END;
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
CREATE TRIGGER [dbo].[CG$AUPD_EXIF]
   ON  [dbo].[Extra_Info]
   AFTER UPDATE   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Extra_Info T
   USING (SELECT * FROM Inserted) S
   ON (T.CODE = S.CODE)
   WHEN MATCHED THEN
      UPDATE SET
         T.MDFY_BY = UPPER(SUSER_NAME())
        ,T.MDFY_DATE = GETDATE();
END
GO
ALTER TABLE [dbo].[Extra_Info] ADD CONSTRAINT [PK_EXIF] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Extra_Info] ADD CONSTRAINT [FK_EXID_EXIF] FOREIGN KEY ([EXIF_CODE]) REFERENCES [dbo].[Extra_Info] ([CODE])
GO
ALTER TABLE [dbo].[Extra_Info] ADD CONSTRAINT [FK_EXIF_APBS] FOREIGN KEY ([APBS_CODE]) REFERENCES [dbo].[App_Base_Define] ([CODE])
GO
ALTER TABLE [dbo].[Extra_Info] ADD CONSTRAINT [FK_EXIF_COMP] FOREIGN KEY ([COMP_CODE]) REFERENCES [dbo].[Company] ([CODE]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Extra_Info] ADD CONSTRAINT [FK_EXIF_SAPB] FOREIGN KEY ([APBS_CODE_DNRM]) REFERENCES [dbo].[App_Base_Define] ([CODE])
GO
ALTER TABLE [dbo].[Extra_Info] ADD CONSTRAINT [FK_EXIF_SERV] FOREIGN KEY ([SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO]) ON DELETE CASCADE
GO
