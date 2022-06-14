CREATE TABLE [dbo].[Isic_Product]
(
[ISCA_ISCG_CODE] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ISCA_CODE] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CODE] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ISCP_DESC] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CRET_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRET_DATE] [date] NULL,
[MDFY_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MDFY_DATE] [date] NULL
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
CREATE TRIGGER [dbo].[CG$AINS_ISCP]
   ON  [dbo].[Isic_Product]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Isic_Product T
   USING (SELECT * FROM Inserted) S
   ON (T.Code = S.Code AND 
       T.ISCA_CODE = S.ISCA_CODE AND
       T.ISCA_ISCG_CODE = S.ISCA_ISCG_CODE)
   WHEN MATCHED THEN
      UPDATE 
         SET CRET_BY = UPPER(SUSER_NAME())
            ,CRET_DATE = GETDATE();
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
CREATE TRIGGER [dbo].[CG$AUPD_ISCP]
   ON  [dbo].[Isic_Product]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Isic_Product T
   USING (SELECT * FROM Inserted) S
   ON (T.Code = S.Code AND 
       T.ISCA_CODE = S.ISCA_CODE AND
       T.ISCA_ISCG_CODE = S.ISCA_ISCG_CODE)
   WHEN MATCHED THEN
      UPDATE 
         SET MDFY_BY = UPPER(SUSER_NAME())
            ,MDFY_DATE = GETDATE();
END
GO
ALTER TABLE [dbo].[Isic_Product] ADD CONSTRAINT [PK_ISCP] PRIMARY KEY CLUSTERED  ([ISCA_ISCG_CODE], [ISCA_CODE], [CODE]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Isic_Product] ADD CONSTRAINT [FK_ISCP_ISCA] FOREIGN KEY ([ISCA_ISCG_CODE], [ISCA_CODE]) REFERENCES [dbo].[Isic_Activity] ([ISCG_CODE], [CODE]) ON DELETE CASCADE ON UPDATE CASCADE
GO
