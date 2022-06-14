CREATE TABLE [dbo].[Similar_Case]
(
[FRST_CASE_CSID] [bigint] NULL,
[SCND_CASE_CSID] [bigint] NULL,
[SCID] [bigint] NOT NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_SMCS]
   ON  [dbo].[Similar_Case]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.[Similar_Case] T
   USING (SELECT * FROM Inserted) S
   ON (T.FRST_CASE_CSID = S.FRST_CASE_CSID AND 
       T.SCND_CASE_CSID = S.SCND_CASE_CSID)
   WHEN MATCHED THEN 
      UPDATE SET 
         T.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE()
        ,T.SCID = dbo.GNRT_NVID_U();
   
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
CREATE TRIGGER [dbo].[CG$AUPD_SMCS]
   ON  [dbo].[Similar_Case]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.[Similar_Case] T
   USING (SELECT * FROM Inserted) S
   ON (T.SCID = S.SCID)
   WHEN MATCHED THEN 
      UPDATE SET 
         T.MDFY_BY = UPPER(SUSER_NAME())
        ,T.MDFY_DATE = GETDATE();   
END
GO
ALTER TABLE [dbo].[Similar_Case] ADD CONSTRAINT [PK_SMCS] PRIMARY KEY CLUSTERED  ([SCID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Similar_Case] ADD CONSTRAINT [FK_FSMC_CASE] FOREIGN KEY ([FRST_CASE_CSID]) REFERENCES [dbo].[Case] ([CSID])
GO
ALTER TABLE [dbo].[Similar_Case] ADD CONSTRAINT [FK_SSMC_CASE] FOREIGN KEY ([SCND_CASE_CSID]) REFERENCES [dbo].[Case] ([CSID])
GO
