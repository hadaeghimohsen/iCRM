CREATE TABLE [dbo].[Transaction_Currency_Base]
(
[TCID] [bigint] NOT NULL,
[ISO_CURN_CODE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CURN_NAME] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CURN_SYMB] [nvarchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXCH_RATE] [decimal] (23, 10) NULL,
[CURN_PREC] [int] NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_TRCB]
   ON  [dbo].[Transaction_Currency_Base]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Transaction_Currency_Base T
   USING (SELECT * FROM Inserted) S
   ON (T.TCID = S.TCID)
   WHEN MATCHED THEN
      UPDATE SET
         T.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE()
        ,T.TCID = CASE WHEN s.TCID = 0 THEN dbo.GNRT_NWID_U() ELSE s.TCID END;
END;
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
CREATE TRIGGER [dbo].[CG$AUPD_TRCB]
   ON  [dbo].[Transaction_Currency_Base]
   AFTER UPDATE   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Transaction_Currency_Base T
   USING (SELECT * FROM Inserted) S
   ON (T.TCID = S.TCID)
   WHEN MATCHED THEN
      UPDATE SET
         T.MDFY_BY = UPPER(SUSER_NAME())
        ,T.MDFY_DATE = GETDATE();

END;
GO
ALTER TABLE [dbo].[Transaction_Currency_Base] ADD CONSTRAINT [PK_TRCB] PRIMARY KEY CLUSTERED  ([TCID]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'تعداد اعشار', 'SCHEMA', N'dbo', 'TABLE', N'Transaction_Currency_Base', 'COLUMN', N'CURN_PREC'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نرخ مبادله', 'SCHEMA', N'dbo', 'TABLE', N'Transaction_Currency_Base', 'COLUMN', N'EXCH_RATE'
GO
