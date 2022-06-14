CREATE TABLE [dbo].[Stakeholder]
(
[LEAD_LDID] [bigint] NULL,
[SERV_FILE_NO] [bigint] NULL,
[SHID] [bigint] NOT NULL,
[ROLE_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_STKH]
   ON  [dbo].[Stakeholder]
   AFTER INSERT   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Stakeholder T
   USING (SELECT * FROM Inserted) S
   ON (t.SHID = s.SHID)
   WHEN MATCHED THEN
      UPDATE SET
         T.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE()
        ,T.SHID = CASE WHEN s.SHID = 0 THEN dbo.GNRT_NWID_U() ELSE s.SHID END;
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
CREATE TRIGGER [dbo].[CG$AUPD_STKH]
   ON  [dbo].[Stakeholder]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Stakeholder T
   USING (SELECT * FROM Inserted) S
   ON (t.SHID = s.SHID)
   WHEN MATCHED THEN
      UPDATE SET
         T.MDFY_BY = UPPER(SUSER_NAME())
        ,T.MDFY_DATE = GETDATE();        
END
GO
ALTER TABLE [dbo].[Stakeholder] ADD CONSTRAINT [PK_STKH] PRIMARY KEY CLUSTERED  ([SHID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Stakeholder] ADD CONSTRAINT [FK_STKH_LEAD] FOREIGN KEY ([LEAD_LDID]) REFERENCES [dbo].[Lead] ([LDID])
GO
ALTER TABLE [dbo].[Stakeholder] ADD CONSTRAINT [FK_STKH_SERV] FOREIGN KEY ([SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO])
GO
