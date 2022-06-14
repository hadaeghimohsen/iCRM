CREATE TABLE [dbo].[Marketing_List]
(
[MLID] [bigint] NOT NULL,
[OWNR_CODE] [bigint] NULL,
[LOCK_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NAME] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LIST_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRPS_DESC] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRGT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SORC] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRCB_TCID] [bigint] NULL,
[COST_AMNT] [bigint] NULL,
[CMNT] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_MKLT]
   ON  [dbo].[Marketing_List]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Marketing_List T
   USING (SELECT * FROM Inserted) S
   ON (t.MLID = s.MLID)
   WHEN MATCHED THEN
      UPDATE SET
         T.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE()
        ,t.MLID = CASE WHEN s.MLID = 0 THEN dbo.GNRT_NWID_U() ELSE s.MLID END;
        

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
CREATE TRIGGER [dbo].[CG$AUPD_MKLT]
   ON  [dbo].[Marketing_List]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Marketing_List T
   USING (SELECT * FROM Inserted) S
   ON (t.MLID = s.MLID)
   WHEN MATCHED THEN
      UPDATE SET
         T.MDFY_BY = UPPER(SUSER_NAME())
        ,T.MDFY_DATE = GETDATE();
END
GO
ALTER TABLE [dbo].[Marketing_List] ADD CONSTRAINT [PK_MKLT] PRIMARY KEY CLUSTERED  ([MLID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Marketing_List] ADD CONSTRAINT [FK_MKLT_JOBP] FOREIGN KEY ([OWNR_CODE]) REFERENCES [dbo].[Job_Personnel] ([CODE])
GO
ALTER TABLE [dbo].[Marketing_List] ADD CONSTRAINT [FK_MKLT_TRCB] FOREIGN KEY ([TRCB_TCID]) REFERENCES [dbo].[Transaction_Currency_Base] ([TCID])
GO
