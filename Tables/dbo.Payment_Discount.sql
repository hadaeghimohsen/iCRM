CREATE TABLE [dbo].[Payment_Discount]
(
[PYMT_CASH_CODE] [bigint] NOT NULL,
[PYMT_RQST_RQID] [bigint] NOT NULL,
[RQRO_RWNO] [smallint] NOT NULL,
[RWNO] [smallint] NOT NULL CONSTRAINT [DF_Payment_Discount_RWNO] DEFAULT ((0)),
[EXPN_CODE] [bigint] NULL,
[AMNT] [int] NULL,
[AMNT_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PYDS_DESC] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$ADEL_PYDS]
   ON  [dbo].[Payment_Discount]
   AFTER DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   
   -- Insert statements for trigger here
   UPDATE Payment 
      SET SUM_PYMT_DSCN_DNRM = (SELECT SUM(ISNULL(AMNT, 0)) FROM Payment_Discount Pd WHERE Pd.PYMT_CASH_CODE = CASH_CODE AND Pd.PYMT_RQST_RQID = RQST_RQID AND STAT = '002')
         ,SUM_EXPN_PRIC = ROUND((   
            SELECT ISNULL(SUM(EXPN_PRIC * QNTY), 0)
              FROM Payment_Detail 
             WHERE PYMT_RQST_RQID = RQST_RQID
               AND PYMT_CASH_CODE = Cash_Code
      ), -3)
    WHERE EXISTS(
      SELECT *
        FROM DELETED S
       WHERE S.PYMT_CASH_CODE = CASH_CODE
         AND S.PYMT_RQST_RQID = RQST_RQID
    );
    
    -- بروز کردن مبلغ بدهی هنرجو
   UPDATE dbo.Service
      SET CONF_STAT = CONF_STAT
    WHERE FILE_NO IN (
      SELECT SERV_FILE_NO
        FROM dbo.Request_Row Rr, DELETED I
       WHERE Rr.Rqst_rqid = I.Pymt_Rqst_Rqid       
    );
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
CREATE TRIGGER [dbo].[CG$AINS_PYDS]
   ON  [dbo].[Payment_Discount]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   
   -- Insert statements for trigger here
   MERGE Payment_Discount T
   USING (SELECT * FROM INSERTED) S
   ON(T.PYMT_CASH_CODE = S.PYMT_CASH_CODE AND
      T.PYMT_RQST_RQID = S.PYMT_RQST_RQID AND
      T.RQRO_RWNO      = S.RQRO_RWNO      AND
      T.RWNO           = S.RWNO)
   WHEN MATCHED THEN
      UPDATE
         SET CRET_BY = UPPER(SUSER_NAME())
            ,CRET_DATE = GETDATE()
            ,RWNO = (SELECT ISNULL(MAX(RWNO), 0) + 1 
                       FROM Payment_Discount
                      WHERE PYMT_CASH_CODE = S.PYMT_CASH_CODE AND
                            PYMT_RQST_RQID = S.PYMT_RQST_RQID AND
                            RQRO_RWNO      = S.RQRO_RWNO      
                     );
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
CREATE TRIGGER [dbo].[CG$AUPD_PYDS]
   ON  [dbo].[Payment_Discount]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   
   -- Insert statements for trigger here
   MERGE Payment_Discount T
   USING (SELECT * FROM INSERTED) S
   ON(T.PYMT_CASH_CODE = S.PYMT_CASH_CODE AND
      T.PYMT_RQST_RQID = S.PYMT_RQST_RQID AND
      T.RQRO_RWNO      = S.RQRO_RWNO      AND
      T.RWNO           = S.RWNO)
   WHEN MATCHED THEN
      UPDATE
         SET MDFY_BY = UPPER(SUSER_NAME())
            ,MDFY_DATE = GETDATE();

   
   UPDATE Payment 
      SET SUM_PYMT_DSCN_DNRM = (SELECT SUM(ISNULL(AMNT, 0)) FROM Payment_Discount Pd WHERE Pd.PYMT_CASH_CODE = CASH_CODE AND Pd.PYMT_RQST_RQID = RQST_RQID AND STAT = '002')
         ,SUM_EXPN_PRIC = ROUND((   
            SELECT ISNULL(SUM(EXPN_PRIC * QNTY), 0)
              FROM Payment_Detail 
             WHERE PYMT_RQST_RQID = RQST_RQID
               AND PYMT_CASH_CODE = Cash_Code
         ), -3)
    WHERE EXISTS(
      SELECT *
        FROM INSERTED S
       WHERE S.PYMT_CASH_CODE = CASH_CODE
         AND S.PYMT_RQST_RQID = RQST_RQID
    );
    
   -- بروز کردن مبلغ بدهی هنرجو
   UPDATE dbo.Service
      SET CONF_STAT = CONF_STAT
    WHERE FILE_NO IN (
      SELECT SERV_FILE_NO
        FROM dbo.Request_Row Rr, INSERTED I
       WHERE Rr.Rqst_rqid = I.Pymt_Rqst_Rqid       
    );
END
GO
ALTER TABLE [dbo].[Payment_Discount] ADD CONSTRAINT [PK_PYDS] PRIMARY KEY CLUSTERED  ([PYMT_CASH_CODE], [PYMT_RQST_RQID], [RQRO_RWNO], [RWNO]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Payment_Discount] ADD CONSTRAINT [FK_PYDS_EXPN] FOREIGN KEY ([EXPN_CODE]) REFERENCES [dbo].[Expense] ([CODE])
GO
ALTER TABLE [dbo].[Payment_Discount] ADD CONSTRAINT [FK_PYDS_PYMT] FOREIGN KEY ([PYMT_CASH_CODE], [PYMT_RQST_RQID]) REFERENCES [dbo].[Payment] ([CASH_CODE], [RQST_RQID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Payment_Discount] ADD CONSTRAINT [FK_PYDS_RQRO] FOREIGN KEY ([PYMT_RQST_RQID], [RQRO_RWNO]) REFERENCES [dbo].[Request_Row] ([RQST_RQID], [RWNO])
GO
