CREATE TABLE [dbo].[Member]
(
[SERV_FILE_NO] [bigint] NULL,
[COMP_CODE] [bigint] NULL,
[LEAD_LDID] [bigint] NULL,
[MKLT_MLID] [bigint] NULL,
[MBID] [bigint] NOT NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_MEMB]
   ON  [dbo].[Member]
   AFTER INSERT   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Member T
   USING (SELECT * FROM Inserted) S
   ON (t.MBID = s.MBID)
   WHEN MATCHED THEN
      UPDATE SET
         T.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE()
        ,T.MBID = CASE WHEN s.MBID = 0 THEN dbo.GNRT_NWID_U() ELSE s.MBID END;
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
CREATE TRIGGER [dbo].[CG$AUPD_MEMB]
   ON  [dbo].[Member]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Member T
   USING (SELECT * FROM Inserted) S
   ON (t.MBID = s.MBID)
   WHEN MATCHED THEN
      UPDATE SET
         T.MDFY_BY = UPPER(SUSER_NAME())
        ,T.MDFY_DATE = GETDATE();        
END
GO
ALTER TABLE [dbo].[Member] ADD CONSTRAINT [PK_MEMB] PRIMARY KEY CLUSTERED  ([MBID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Member] ADD CONSTRAINT [FK_MEMB_COMP] FOREIGN KEY ([COMP_CODE]) REFERENCES [dbo].[Company] ([CODE])
GO
ALTER TABLE [dbo].[Member] ADD CONSTRAINT [FK_MEMB_LEAD] FOREIGN KEY ([LEAD_LDID]) REFERENCES [dbo].[Lead] ([LDID])
GO
ALTER TABLE [dbo].[Member] ADD CONSTRAINT [FK_MEMB_MKLT] FOREIGN KEY ([MKLT_MLID]) REFERENCES [dbo].[Marketing_List] ([MLID])
GO
ALTER TABLE [dbo].[Member] ADD CONSTRAINT [FK_MEMB_SERV] FOREIGN KEY ([SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO])
GO
