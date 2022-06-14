CREATE TABLE [dbo].[Campaign]
(
[OWNR_CODE] [bigint] NULL,
[CMID] [bigint] NOT NULL,
[ESTM_REVN_AMNT] [bigint] NULL,
[STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TEMP] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NAME] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRCB_TCID] [bigint] NULL,
[TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXPT_RESP] [smallint] NULL,
[PROP_STRT_DATE] [date] NULL,
[PROP_END_DATE] [date] NULL,
[ACTL_STRT_DATE] [date] NULL,
[ACTL_END_DATE] [date] NULL,
[OFER_DESC] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACTV_COST_AMNT] [bigint] NULL,
[MISC_COST_AMNT] [bigint] NULL,
[ALOC_BUDG_AMNT] [bigint] NULL,
[TOTL_COST_AMNT] [bigint] NULL,
[CMNT] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_CAMP]
   ON  [dbo].[Campaign]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Campaign T
   USING (SELECT * FROM Inserted) S
   ON (t.CMID = s.CMID)
   WHEN MATCHED THEN
      UPDATE SET 
         T.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE()
        ,T.CMID = CASE WHEN S.CMID = 0 THEN dbo.GNRT_NWID_U() ELSE s.CMID END;
             
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
CREATE TRIGGER [dbo].[CG$AUPD_CAMP]
   ON  [dbo].[Campaign]
   AFTER UPDATE   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Campaign T
   USING (SELECT * FROM Inserted) S
   ON (t.CMID = s.CMID)
   WHEN MATCHED THEN
      UPDATE SET 
         T.MDFY_BY = UPPER(SUSER_NAME())
        ,T.MDFY_DATE = GETDATE();
END
GO
ALTER TABLE [dbo].[Campaign] ADD CONSTRAINT [PK_CAMP] PRIMARY KEY CLUSTERED  ([CMID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Campaign] ADD CONSTRAINT [FK_CAMP_JOBP] FOREIGN KEY ([OWNR_CODE]) REFERENCES [dbo].[Job_Personnel] ([CODE])
GO
ALTER TABLE [dbo].[Campaign] ADD CONSTRAINT [FK_CAMP_TRCB] FOREIGN KEY ([TRCB_TCID]) REFERENCES [dbo].[Transaction_Currency_Base] ([TCID])
GO
