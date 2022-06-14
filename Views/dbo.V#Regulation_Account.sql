SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[V#Regulation_Account]
AS
SELECT     dbo.Regulation.YEAR, dbo.Regulation.CODE, dbo.Regulation.SUB_SYS, dbo.Regulation.TYPE, dbo.Regulation.REGL_STAT, dbo.Expense_Cash.REGN_PRVN_CNTY_CODE, 
                      dbo.Expense_Cash.REGN_PRVN_CODE, dbo.Expense_Cash.REGN_CODE, dbo.Expense_Cash.EXTP_CODE, dbo.Expense_Cash.CASH_CODE, dbo.Expense_Cash.EXCS_STAT
FROM         dbo.Regulation INNER JOIN
                      dbo.Expense_Cash ON dbo.Regulation.YEAR = dbo.Expense_Cash.REGL_YEAR AND dbo.Regulation.CODE = dbo.Expense_Cash.REGL_CODE
GO
