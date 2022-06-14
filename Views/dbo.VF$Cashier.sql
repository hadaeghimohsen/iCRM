SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[VF$Cashier] AS
  SELECT DISTINCT [CASH_BY]
    FROM [dbo].[Payment] P
   WHERE [CASH_BY] IS NOT NULL
     AND [DELV_BY] IS NULL
GO