CREATE TABLE [dbo].[Payment_Detail_Commodity_Sales]
(
[PYDT_CODE] [bigint] NULL,
[CODE] [bigint] NOT NULL,
[SERL_NO_BAR_CODE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMSL_DESC] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_PDCS]
   ON  [dbo].[Payment_Detail_Commodity_Sales]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   
   MERGE dbo.Payment_Detail_Commodity_Sales T
   USING (SELECT * FROM INSERTED) S
   ON (T.PYDT_CODE = S.PYDT_CODE AND
       T.CODE = S.CODE)
   WHEN MATCHED THEN
      UPDATE
         SET CRET_BY = UPPER(SUSER_NAME())
            ,CRET_DATE = GETDATE()
            ,CODE = dbo.GNRT_NVID_U();
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
CREATE TRIGGER [dbo].[CG$AUPD_PDCS]
   ON  [dbo].[Payment_Detail_Commodity_Sales]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   
   MERGE dbo.Payment_Detail_Commodity_Sales T
   USING (SELECT * FROM INSERTED) S
   ON (T.PYDT_CODE = S.PYDT_CODE AND
       T.CODE = S.CODE)
   WHEN MATCHED THEN
      UPDATE
         SET MDFY_BY = UPPER(SUSER_NAME())
            ,MDFY_DATE = GETDATE();
END
GO
ALTER TABLE [dbo].[Payment_Detail_Commodity_Sales] ADD CONSTRAINT [PK_PDCS] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Payment_Detail_Commodity_Sales] ADD CONSTRAINT [FK_PDCS_PYDT] FOREIGN KEY ([PYDT_CODE]) REFERENCES [dbo].[Payment_Detail] ([CODE]) ON DELETE CASCADE
GO
EXEC sp_addextendedproperty N'MS_Description', N'PDCS', 'SCHEMA', N'dbo', 'TABLE', N'Payment_Detail_Commodity_Sales', NULL, NULL
GO
