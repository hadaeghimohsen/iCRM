CREATE TABLE [dbo].[Check_List_Detial]
(
[CKLS_CKID] [bigint] NULL,
[CDID] [bigint] NOT NULL IDENTITY(1, 1),
[FROM_DATE_TIME] [datetime] NULL,
[TO_DATE_TIME] [datetime] NULL,
[LONG_TIME] [int] NULL,
[CMNT_DESC] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_CKLD]
   ON  [dbo].[Check_List_Detial]
   AFTER INSERT   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Check_List_Detial T
   USING (SELECT * FROM Inserted) S
   ON (t.CDID = s.CDID)
   WHEN MATCHED THEN
      UPDATE SET
         T.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE();
      
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
CREATE TRIGGER [dbo].[CG$AUPD_CKLD]
   ON  [dbo].[Check_List_Detial]
   AFTER UPDATE 
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Check_List_Detial T
   USING (SELECT * FROM Inserted) S
   ON (t.CDID = s.CDID)
   WHEN MATCHED THEN
      UPDATE SET
         T.MDFY_BY = UPPER(SUSER_NAME())
        ,T.MDFY_DATE = GETDATE()
        ,T.LONG_TIME = DATEDIFF(HOUR, ISNULL(s.FROM_DATE_TIME, GETDATE()), ISNULL(s.TO_DATE_TIME, GETDATE()));
      
END
GO
ALTER TABLE [dbo].[Check_List_Detial] ADD CONSTRAINT [PK_CKLD] PRIMARY KEY CLUSTERED  ([CDID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Check_List_Detial] ADD CONSTRAINT [FK_CKLD_CKLS] FOREIGN KEY ([CKLS_CKID]) REFERENCES [dbo].[Check_List] ([CKID]) ON DELETE CASCADE
GO
