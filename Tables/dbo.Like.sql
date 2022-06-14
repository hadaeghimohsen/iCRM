CREATE TABLE [dbo].[Like]
(
[CMNT_CMID] [bigint] NULL,
[JOBP_CODE_DNRM] [bigint] NULL,
[LKID] [bigint] NOT NULL IDENTITY(1, 1),
[LIKE_CMNT] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_LIKE]
   ON  [dbo].[Like]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.[Like] T
   USING (SELECT * FROM Inserted) S
   ON (T.LKID = S.LKID)
   WHEN MATCHED THEN
      UPDATE SET
         T.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE()
        ,T.JOBP_CODE_DNRM = (
           SELECT CODE
             FROM dbo.Job_Personnel
            WHERE UPPER(USER_NAME) = UPPER(SUSER_NAME())
              AND STAT = '002'
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
CREATE TRIGGER [dbo].[CG$AUPD_LIKE]
   ON  [dbo].[Like]
   AFTER UPDATE   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.[Like] T
   USING (SELECT * FROM Inserted) S
   ON (T.LKID = S.LKID)
   WHEN MATCHED THEN
      UPDATE SET
         T.MDFY_BY = UPPER(SUSER_NAME())
        ,T.MDFY_DATE = GETDATE();
END
GO
ALTER TABLE [dbo].[Like] ADD CONSTRAINT [PK_Like] PRIMARY KEY CLUSTERED  ([LKID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Like] ADD CONSTRAINT [FK_LIKE_CMNT] FOREIGN KEY ([CMNT_CMID]) REFERENCES [dbo].[Comment] ([CMID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Like] WITH NOCHECK ADD CONSTRAINT [FK_LIKE_JOBP] FOREIGN KEY ([JOBP_CODE_DNRM]) REFERENCES [dbo].[Job_Personnel] ([CODE])
GO
