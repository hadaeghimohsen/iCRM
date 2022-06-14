CREATE TABLE [dbo].[Sale_Team]
(
[LEAD_LDID] [bigint] NULL,
[JOBP_CODE] [bigint] NULL,
[STID] [bigint] NOT NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_SLTM]
   ON  [dbo].[Sale_Team]
   AFTER INSERT   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Sale_Team T
   USING (SELECT * FROM Inserted) S
   ON (t.STID = s.STID)
   WHEN MATCHED THEN
      UPDATE SET
         T.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE()
        ,T.STID = CASE WHEN s.STID = 0 THEN dbo.GNRT_NWID_U() ELSE s.STID END;
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
CREATE TRIGGER [dbo].[CG$AUPD_SLTM]
   ON  [dbo].[Sale_Team]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Sale_Team T
   USING (SELECT * FROM Inserted) S
   ON (t.STID = s.STID)
   WHEN MATCHED THEN
      UPDATE SET
         T.MDFY_BY = UPPER(SUSER_NAME())
        ,T.MDFY_DATE = GETDATE();        
END
GO
ALTER TABLE [dbo].[Sale_Team] ADD CONSTRAINT [PK_SLTM] PRIMARY KEY CLUSTERED  ([STID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Sale_Team] ADD CONSTRAINT [FK_SLTM_JOBP] FOREIGN KEY ([JOBP_CODE]) REFERENCES [dbo].[Job_Personnel] ([CODE])
GO
ALTER TABLE [dbo].[Sale_Team] ADD CONSTRAINT [FK_SLTM_LEAD] FOREIGN KEY ([LEAD_LDID]) REFERENCES [dbo].[Lead] ([LDID])
GO
