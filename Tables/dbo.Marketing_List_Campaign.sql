CREATE TABLE [dbo].[Marketing_List_Campaign]
(
[MKLT_MLID] [bigint] NULL,
[CAMP_CMID] [bigint] NULL,
[MCID] [bigint] NOT NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_MKLC]
   ON  [dbo].[Marketing_List_Campaign]
   AFTER INSERT   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Marketing_List_Campaign T
   USING (SELECT * FROM Inserted) S
   ON (t.MCID = s.MCID)
   WHEN MATCHED THEN
      UPDATE SET
         T.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE()
        ,T.MCID = CASE WHEN s.MCID = 0 THEN dbo.GNRT_NWID_U() ELSE s.MCID END;
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
CREATE TRIGGER [dbo].[CG$AUPD_MKLC]
   ON  [dbo].[Marketing_List_Campaign]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Marketing_List_Campaign T
   USING (SELECT * FROM Inserted) S
   ON (t.MCID = s.MCID)
   WHEN MATCHED THEN
      UPDATE SET
         T.MDFY_BY = UPPER(SUSER_NAME())
        ,T.MDFY_DATE = GETDATE();        
END
GO
ALTER TABLE [dbo].[Marketing_List_Campaign] ADD CONSTRAINT [PK_MKLC] PRIMARY KEY CLUSTERED  ([MCID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Marketing_List_Campaign] ADD CONSTRAINT [FK_MKLC_CAMP] FOREIGN KEY ([CAMP_CMID]) REFERENCES [dbo].[Campaign] ([CMID])
GO
ALTER TABLE [dbo].[Marketing_List_Campaign] ADD CONSTRAINT [FK_MKLC_MKLT] FOREIGN KEY ([MKLT_MLID]) REFERENCES [dbo].[Marketing_List] ([MLID])
GO
