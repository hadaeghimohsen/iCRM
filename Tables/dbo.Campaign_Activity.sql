CREATE TABLE [dbo].[Campaign_Activity]
(
[CAMP_CMID] [bigint] NULL,
[OWNR_CODE] [bigint] NULL,
[CAID] [bigint] NOT NULL,
[SUBJ_DESC] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHNL_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMNT] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SCHD_STRT_DATE] [date] NULL,
[SCHD_END_DATE] [date] NULL,
[ACTL_STRT_DATE] [date] NULL,
[ACTL_END_DATE] [date] NULL,
[TRCB_TCID] [bigint] NULL,
[ALOC_BUDG_AMNT] [bigint] NULL,
[ANTI_SPAM_NUMB_DAY] [int] NULL,
[PRIO_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_CAMA]
   ON  [dbo].[Campaign_Activity]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Campaign_Activity T
   USING (SELECT * FROM Inserted) S
   ON (t.CAID = s.CAID)
   WHEN MATCHED THEN
      UPDATE SET
         T.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE()
        ,T.CAID = CASE WHEN S.CAID = 0 THEN dbo.GNRT_NWID_U() ELSE S.CAID END;
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
CREATE TRIGGER [dbo].[CG$AUPD_CAMA]
   ON  [dbo].[Campaign_Activity]
   AFTER UPDATE   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Campaign_Activity T
   USING (SELECT * FROM Inserted) S
   ON (t.CAID = s.CAID)
   WHEN MATCHED THEN
      UPDATE SET
         T.MDFY_BY = UPPER(SUSER_NAME())
        ,T.MDFY_DATE = GETDATE();
END
GO
ALTER TABLE [dbo].[Campaign_Activity] ADD CONSTRAINT [PK_CAMA] PRIMARY KEY CLUSTERED  ([CAID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Campaign_Activity] ADD CONSTRAINT [FK_CAMA_CAMP] FOREIGN KEY ([CAMP_CMID]) REFERENCES [dbo].[Campaign] ([CMID])
GO
ALTER TABLE [dbo].[Campaign_Activity] ADD CONSTRAINT [FK_CAMA_JOBP] FOREIGN KEY ([OWNR_CODE]) REFERENCES [dbo].[Job_Personnel] ([CODE])
GO
ALTER TABLE [dbo].[Campaign_Activity] ADD CONSTRAINT [FK_CAMA_TRCB] FOREIGN KEY ([TRCB_TCID]) REFERENCES [dbo].[Transaction_Currency_Base] ([TCID])
GO
