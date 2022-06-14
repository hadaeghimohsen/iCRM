SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[V#TopNRelatedServicesOfCompany]
AS 
SELECT DISTINCT TResult.FILE_NO, TResult.COMP_CODE
  FROM (
       SELECT TOP 100 PERCENT s.FILE_NO, rr.COMP_CODE
         FROM dbo.Request r, dbo.Request_Row rr, dbo.Service s
        WHERE r.RQID = rr.RQST_RQID
          AND rr.SERV_FILE_NO = s.FILE_NO
          AND r.RQST_STAT = '002'
          AND rr.COMP_CODE IS NOT NULL
     ORDER BY r.SAVE_DATE DESC
  ) TResult
GO
