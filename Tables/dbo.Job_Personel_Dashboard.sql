CREATE TABLE [dbo].[Job_Personel_Dashboard]
(
[JOBP_CODE] [bigint] NULL,
[SSTT_MSTT_SUB_SYS] [smallint] NULL,
[SSTT_MSTT_CODE] [smallint] NULL,
[SSTT_CODE] [smallint] NULL,
[CODE] [bigint] NOT NULL,
[REC_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_JBPD]
   ON  [dbo].[Job_Personel_Dashboard]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Job_Personel_Dashboard T
   USING (SELECT * FROM Inserted) S
   ON (T.CODE = S.CODE)
   WHEN MATCHED THEN
      UPDATE SET
         T.CRET_BY = UPPER(SUSER_NAME())
        ,t.CRET_DATE = GETDATE()
        ,t.CODE = dbo.GNRT_NVID_U();
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
CREATE TRIGGER [dbo].[CG$AUPD_JBPD]
   ON  [dbo].[Job_Personel_Dashboard]
   AFTER UPDATE 
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Job_Personel_Dashboard T
   USING (SELECT * FROM Inserted) S
   ON (T.CODE = S.CODE)
   WHEN MATCHED THEN
      UPDATE SET
         T.MDFY_BY = UPPER(SUSER_NAME())
        ,t.MDFY_DATE = GETDATE();        
END
GO
ALTER TABLE [dbo].[Job_Personel_Dashboard] ADD CONSTRAINT [PK_JBPD] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Job_Personel_Dashboard] ADD CONSTRAINT [FK_JBPD_JOBP] FOREIGN KEY ([JOBP_CODE]) REFERENCES [dbo].[Job_Personnel] ([CODE])
GO
ALTER TABLE [dbo].[Job_Personel_Dashboard] WITH NOCHECK ADD CONSTRAINT [FK_JBPD_SSTT] FOREIGN KEY ([SSTT_MSTT_CODE], [SSTT_MSTT_SUB_SYS], [SSTT_CODE]) REFERENCES [dbo].[Sub_State] ([MSTT_CODE], [MSTT_SUB_SYS], [CODE])
GO
