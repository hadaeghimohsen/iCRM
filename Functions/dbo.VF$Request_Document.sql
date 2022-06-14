SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[VF$Request_Document](
   @FileNo BIGINT
)
RETURNS TABLE
AS RETURN
(
SELECT  dbo.Request_Type.CODE AS RQTP_CODE, 
        dbo.Request_Type.RQTP_DESC, 
        dbo.Requester_Type.CODE AS RQTT_CODE,
        dbo.Requester_Type.RQTT_DESC,
        dbo.Request.RQID, 
        dbo.Request_Row.RWNO,
        dbo.Request.RQST_DATE, 
        dbo.Request.SAVE_DATE
  FROM  dbo.Request INNER JOIN
        dbo.Request_Row ON dbo.Request.RQID = dbo.Request_Row.RQST_RQID INNER JOIN
        dbo.Request_Type ON dbo.Request.RQTP_CODE = dbo.Request_Type.CODE INNER JOIN        
        dbo.Requester_Type ON dbo.Request.RQTT_CODE = dbo.Requester_Type.CODE INNER JOIN
        dbo.Service ON dbo.Request_Row.SERV_FILE_NO = dbo.Service.FILE_NO         
WHERE  (dbo.Request_Row.RECD_STAT = '002') 
  AND  (dbo.Request.RQST_STAT = '002')
  AND  (dbo.Service.CONF_STAT = '002')
  AND  (@FileNo IS NULL OR dbo.Service.FILE_NO = @FileNo)
  AND  EXISTS(
   SELECT * 
     FROM dbo.Receive_Document 
    WHERE dbo.Request_Row.RQST_RQID = dbo.Receive_Document.RQRO_RQST_RQID 
      AND dbo.Request_Row.RWNO = dbo.Receive_Document.RQRO_RWNO
  )
)
GO
