CREATE TABLE [dbo].[Contract_Line]
(
[CONT_CNID] [bigint] NULL,
[CLID] [bigint] NOT NULL,
[TITL] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STRT_DATE] [date] NULL,
[END_DATE] [date] NULL,
[QNTY] [int] NULL,
[RATE] [float] NULL,
[TOTL_PRIC] [bigint] NULL,
[DSCN_AMNT] [bigint] NULL,
[DSCN_PRCT_DNRM] [int] NULL,
[NET_AMNT_DNRM] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SERL_NUMB] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TOTL_CASE_MINT] [int] NULL,
[ALOT_USED] [int] NULL,
[ALOT_REMN] [int] NULL,
[CRET_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRET_DATE] [date] NULL,
[MDFY_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MDFY_DATE] [date] NULL
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
CREATE TRIGGER [dbo].[CG$AINS_CNLN]
   ON  [dbo].[Contract_Line]
   AFTER INSERT   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Contract_Line T
   USING (SELECT * FROM Inserted) S
   ON (t.CONT_CNID = s.CONT_CNID AND 
       t.CLID = s.CLID)
   WHEN MATCHED THEN
      UPDATE SET
         T.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE()
        ,T.CLID = dbo.GNRT_NVID_U();
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
CREATE TRIGGER [dbo].[CG$AUPD_CNLN]
   ON  [dbo].[Contract_Line]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Contract_Line T
   USING (SELECT * FROM Inserted) S
   ON (t.CONT_CNID = s.CONT_CNID AND 
       t.CLID = s.CLID)
   WHEN MATCHED THEN
      UPDATE SET
         T.MDFY_BY = UPPER(SUSER_NAME())
        ,T.MDFY_DATE = GETDATE();
        
END
GO
ALTER TABLE [dbo].[Contract_Line] ADD CONSTRAINT [PK_Contract_Line] PRIMARY KEY CLUSTERED  ([CLID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Contract_Line] ADD CONSTRAINT [FK_CNLN_CONT] FOREIGN KEY ([CONT_CNID]) REFERENCES [dbo].[Contract] ([CNID])
GO
