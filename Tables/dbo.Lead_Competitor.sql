CREATE TABLE [dbo].[Lead_Competitor]
(
[LEAD_LDID] [bigint] NULL,
[COMP_CODE] [bigint] NULL,
[LCID] [bigint] NOT NULL,
[EFCT_LEVL] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RSLT_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMNT] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_LDCM]
   ON  [dbo].[Lead_Competitor]
   AFTER INSERT   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Lead_Competitor T
   USING (SELECT * FROM Inserted) S
   ON (t.LCID = s.LCID)
   WHEN MATCHED THEN
      UPDATE SET
         T.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE()
        ,T.LCID = CASE WHEN s.LCID = 0 THEN dbo.GNRT_NWID_U() ELSE s.LCID END;
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
CREATE TRIGGER [dbo].[CG$AUPD_LDCM]
   ON  [dbo].[Lead_Competitor]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Lead_Competitor T
   USING (SELECT * FROM Inserted) S
   ON (t.LCID = s.LCID)
   WHEN MATCHED THEN
      UPDATE SET
         T.MDFY_BY = UPPER(SUSER_NAME())
        ,T.MDFY_DATE = GETDATE();        
END
GO
ALTER TABLE [dbo].[Lead_Competitor] ADD CONSTRAINT [PK_LDCM] PRIMARY KEY CLUSTERED  ([LCID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Lead_Competitor] ADD CONSTRAINT [FK_LDCM_COMP] FOREIGN KEY ([COMP_CODE]) REFERENCES [dbo].[Company] ([CODE])
GO
ALTER TABLE [dbo].[Lead_Competitor] ADD CONSTRAINT [FK_LDCM_LEAD] FOREIGN KEY ([LEAD_LDID]) REFERENCES [dbo].[Lead] ([LDID])
GO
EXEC sp_addextendedproperty N'MS_Description', N'میزان تاثیر گذاری', 'SCHEMA', N'dbo', 'TABLE', N'Lead_Competitor', 'COLUMN', N'EFCT_LEVL'
GO
