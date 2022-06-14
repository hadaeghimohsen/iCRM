SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[VF$Request_Changing](
   @Rqid BIGINT,
   @FileNo BIGINT,
   @CompCode BIGINT,
   @ProjRqstRqid BIGINT
)
RETURNS TABLE
AS RETURN
(
SELECT  dbo.Request_Type.CODE AS RQTP_CODE, 
        dbo.Request_Type.RQTP_DESC, 
        dbo.Request.RQID, 
        dbo.Requester_Type.CODE AS RQTT_CODE,
        dbo.Requester_Type.RQTT_DESC,
        dbo.Request.RQST_DATE, 
        dbo.Request.SAVE_DATE,
        dbo.Request.CRET_BY,
        dbo.Service.FILE_NO,
        dbo.Service.NAME_DNRM,
        dbo.Service.CELL_PHON_DNRM,
        dbo.Request_Row.COMP_CODE,
        dbo.Company.NAME AS COMP_NAME,
        dbo.Company.POST_ADRS AS COMP_POST_ADRS
  FROM  dbo.Request INNER JOIN
        dbo.Request_Row ON dbo.Request.RQID = dbo.Request_Row.RQST_RQID INNER JOIN
        dbo.Request_Type ON dbo.Request.RQTP_CODE = dbo.Request_Type.CODE INNER JOIN
        dbo.Requester_Type ON dbo.Request.RQTT_CODE = dbo.Requester_Type.CODE INNER JOIN
        dbo.Service ON dbo.Request_Row.SERV_FILE_NO = dbo.Service.FILE_NO LEFT OUTER JOIN
        dbo.Company ON Company.CODE = Request_Row.COMP_CODE
WHERE  (dbo.Request_Row.RECD_STAT = '002') 
  AND  (dbo.Request.RQST_STAT = '002')
  AND  (dbo.Service.CONF_STAT = '002')
  AND  (@Rqid IS NULL OR dbo.Request.RQID = @Rqid)
  AND  (@FileNo IS NULL OR dbo.Service.FILE_NO = @FileNo)
  AND  (@CompCode IS NULL OR dbo.Request_Row.COMP_CODE = @CompCode)
  AND  (@ProjRqstRqid IS NULL OR dbo.Request.PROJ_RQST_RQID = @ProjRqstRqid)
)
GO
