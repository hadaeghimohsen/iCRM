CREATE TABLE [dbo].[Isic_Group]
(
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
CREATE TRIGGER [dbo].[CG$AINS_ISCG]
   ON  [dbo].[Isic_Group]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Isic_Group T
   USING (SELECT * FROM Inserted) S
   ON (T.Code = S.Code)
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
CREATE TRIGGER [dbo].[CG$AUPD_ISCG]
   ON  [dbo].[Isic_Group]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Isic_Group T
   USING (SELECT * FROM Inserted) S
   ON (T.Code = S.Code)
   WHEN MATCHED THEN
      UPDATE 
         SET MDFY_BY = UPPER(SUSER_NAME())
            ,MDFY_DATE = GETDATE();
END
GO
ALTER TABLE [dbo].[Isic_Group] ADD CONSTRAINT [PK_ISCG] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO
