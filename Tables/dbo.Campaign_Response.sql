CREATE TABLE [dbo].[Campaign_Response]
(
[CAMP_CMID] [bigint] NULL,
[OWNR_CODE] [bigint] NULL,
[RSID] [bigint] NOT NULL,
[TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUBJ_DESC] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SERV_FILE_NO] [bigint] NULL,
[COMP_NAME] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FRST_NAME] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LAST_NAME] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CELL_PHON] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TELL_PHON] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FAX_NUMB] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMAL_ADRS] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMNT] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROM_CODE] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHNL_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OUTS_VNDR_SERV_FILE_NO] [bigint] NULL,
[OUTS_VNDR_COMP_CODE] [bigint] NULL,
[PRIO_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RECV_DATE] [datetime] NULL,
[CLOS_DATE] [datetime] NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_CMRS]
   ON  [dbo].[Campaign_Response]
   AFTER INSERT   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Campaign_Response T
   USING (SELECT * FROM Inserted) S
   ON (t.RSID = s.RSID)
   WHEN MATCHED THEN
      UPDATE SET
         T.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE()
        ,T.RSID = CASE WHEN s.RSID = 0 THEN dbo.GNRT_NWID_U() ELSE s.RSID END;
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
CREATE TRIGGER [dbo].[CG$AUPD_CMRS]
   ON  [dbo].[Campaign_Response]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Campaign_Response T
   USING (SELECT * FROM Inserted) S
   ON (t.RSID = s.RSID)
   WHEN MATCHED THEN
      UPDATE SET
         T.MDFY_BY = UPPER(SUSER_NAME())
        ,T.MDFY_DATE = GETDATE();        
END
GO
ALTER TABLE [dbo].[Campaign_Response] ADD CONSTRAINT [PK_CMRS] PRIMARY KEY CLUSTERED  ([RSID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Campaign_Response] ADD CONSTRAINT [FK_CMRS_CAMP] FOREIGN KEY ([CAMP_CMID]) REFERENCES [dbo].[Campaign] ([CMID])
GO
ALTER TABLE [dbo].[Campaign_Response] ADD CONSTRAINT [FK_CMRS_JOBP] FOREIGN KEY ([OWNR_CODE]) REFERENCES [dbo].[Job_Personnel] ([CODE])
GO
