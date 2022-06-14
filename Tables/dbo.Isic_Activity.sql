CREATE TABLE [dbo].[Isic_Activity]
(
[ISCG_CODE] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CODE] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FRSI_DESC] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ENGL_DESC] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_ISCA]
   ON  [dbo].[Isic_Activity]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Isic_Activity T
   USING (SELECT * FROM Inserted) S
   ON (T.Code = S.Code AND 
       T.ISCG_CODE = S.ISCG_CODE)
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
CREATE TRIGGER [dbo].[CG$AUPD_ISCA]
   ON  [dbo].[Isic_Activity]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Isic_Activity T
   USING (SELECT * FROM Inserted) S
   ON (T.Code = S.Code AND 
       T.ISCG_CODE = S.ISCG_CODE)
   WHEN MATCHED THEN
      UPDATE 
         SET MDFY_BY = UPPER(SUSER_NAME())
            ,MDFY_DATE = GETDATE();
END
GO
ALTER TABLE [dbo].[Isic_Activity] ADD CONSTRAINT [PK_ISCA] PRIMARY KEY CLUSTERED  ([ISCG_CODE], [CODE]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Isic_Activity] ADD CONSTRAINT [FK_ISCA_ISCG] FOREIGN KEY ([ISCG_CODE]) REFERENCES [dbo].[Isic_Group] ([CODE]) ON DELETE CASCADE ON UPDATE CASCADE
GO
