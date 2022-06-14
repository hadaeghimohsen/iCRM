CREATE TABLE [dbo].[Contract]
(
[RQRO_RQST_RQID] [bigint] NULL,
[RQRO_RWNO] [smallint] NULL,
[OWNR_CODE] [bigint] NULL,
[COMP_CODE] [bigint] NULL,
[SRPB_SERV_FILE_NO] [bigint] NULL,
[SRPB_RWNO] [int] NULL,
[SRPB_RECT_CODE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CNID] [bigint] NOT NULL,
[NAME] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STRT_DATE] [date] NULL,
[END_DATE] [date] NULL,
[DURN_DAY_DNRM] [int] NULL,
[TEMP_APBS_CODE] [bigint] NULL,
[DSCN_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SERV_LEVL] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMNT] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BILL_STRT_DATE] [date] NULL,
[BILL_END_DATE] [date] NULL,
[BILL_CNCL_DATE] [date] NULL,
[BILL_FERQ] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRCB_TCID] [bigint] NULL,
[TOTL_PRIC] [bigint] NULL,
[TOTL_DSCN] [bigint] NULL,
[NET_PRIC_DNRM] [bigint] NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_CNTR]
   ON  [dbo].[Contract]
   AFTER INSERT 
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Contract T
   USING (SELECT * FROM Inserted) S
   ON (T.RQRO_RQST_RQID = s.RQRO_RQST_RQID AND
       T.RQRO_RWNO = S.RQRO_RWNO AND 
       T.OWNR_CODE = S.OWNR_CODE)
   WHEN MATCHED THEN
      UPDATE SET
         t.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE()
        ,t.CNID = dbo.GNRT_NVID_U();
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
CREATE TRIGGER [dbo].[CG$AUPD_CNTR]
   ON  [dbo].[Contract]
   AFTER UPDATE   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Contract T
   USING (SELECT * FROM Inserted) S
   ON (T.CNID = S.CNID)
   WHEN MATCHED THEN
      UPDATE SET
         t.MDFY_BY = UPPER(SUSER_NAME())
        ,T.MDFY_DATE = GETDATE()
        ,t.DURN_DAY_DNRM = DATEDIFF(d, S.STRT_DATE, S.END_DATE)
        ,T.NET_PRIC_DNRM = S.TOTL_PRIC - S.TOTL_DSCN;

END
GO
ALTER TABLE [dbo].[Contract] ADD CONSTRAINT [PK_CONT] PRIMARY KEY CLUSTERED  ([CNID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Contract] ADD CONSTRAINT [FK_CONT_APBS] FOREIGN KEY ([TEMP_APBS_CODE]) REFERENCES [dbo].[App_Base_Define] ([CODE])
GO
ALTER TABLE [dbo].[Contract] ADD CONSTRAINT [FK_CONT_COMP] FOREIGN KEY ([COMP_CODE]) REFERENCES [dbo].[Company] ([CODE])
GO
ALTER TABLE [dbo].[Contract] ADD CONSTRAINT [FK_CONT_JOBP] FOREIGN KEY ([OWNR_CODE]) REFERENCES [dbo].[Job_Personnel] ([CODE])
GO
ALTER TABLE [dbo].[Contract] ADD CONSTRAINT [FK_CONT_RQRO] FOREIGN KEY ([RQRO_RQST_RQID], [RQRO_RWNO]) REFERENCES [dbo].[Request_Row] ([RQST_RQID], [RWNO])
GO
ALTER TABLE [dbo].[Contract] ADD CONSTRAINT [FK_CONT_SRPB] FOREIGN KEY ([SRPB_SERV_FILE_NO], [SRPB_RWNO], [SRPB_RECT_CODE]) REFERENCES [dbo].[Service_Public] ([SERV_FILE_NO], [RWNO], [RECT_CODE])
GO
ALTER TABLE [dbo].[Contract] ADD CONSTRAINT [FK_CONT_TRCB] FOREIGN KEY ([TRCB_TCID]) REFERENCES [dbo].[Transaction_Currency_Base] ([TCID])
GO
