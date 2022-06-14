CREATE TABLE [dbo].[Campaign_Quick]
(
[OWNR_CODE] [bigint] NULL,
[MKLT_MLID] [bigint] NULL,
[QCID] [bigint] NOT NULL,
[SUBJ_DESC] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NUMB_SUCS] [int] NULL,
[NUMB_FAIL] [int] NULL,
[EROR_DESC] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEMB_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACTV_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STAT_RESN] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_CAMQ]
   ON  [dbo].[Campaign_Quick]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Campaign_Quick T
   USING (SELECT * FROM Inserted) S
   ON (t.QCID = s.QCID)
   WHEN MATCHED THEN
      UPDATE SET
         T.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE()
        ,T.QCID = CASE WHEN s.QCID = 0 THEN dbo.GNRT_NWID_U() ELSE s.QCID END;
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
CREATE TRIGGER [dbo].[CG$AUPD_CAMQ]
   ON  [dbo].[Campaign_Quick]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Campaign_Quick T
   USING (SELECT * FROM Inserted) S
   ON (t.QCID = s.QCID)
   WHEN MATCHED THEN
      UPDATE SET
         T.MDFY_BY = UPPER(SUSER_NAME())
        ,T.MDFY_DATE = GETDATE();        
END
GO
ALTER TABLE [dbo].[Campaign_Quick] ADD CONSTRAINT [PK_CAMQ] PRIMARY KEY CLUSTERED  ([QCID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Campaign_Quick] ADD CONSTRAINT [FK_CAMQ_JOBP] FOREIGN KEY ([OWNR_CODE]) REFERENCES [dbo].[Job_Personnel] ([CODE])
GO
ALTER TABLE [dbo].[Campaign_Quick] ADD CONSTRAINT [FK_CAMQ_MKLT] FOREIGN KEY ([MKLT_MLID]) REFERENCES [dbo].[Marketing_List] ([MLID])
GO
