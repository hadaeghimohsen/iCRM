SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[VF$TrackAttendances]
(	
	@X XML
)
RETURNS TABLE 
AS
RETURN 
(
   /*
    <Region code="" prvncode=""/>
    */
   WITH QXML AS
   (
      SELECT @X.query('TrackAttendance').value('(TrackAttendance/@fileno)[1]',         'BIGINT') AS FILE_NO
   )
	SELECT R.REGN_PRVN_CNTY_CODE ,
         R.REGN_PRVN_CODE ,
         R.REGN_CODE ,
         R.RQID ,
         R.RQST_RQID,
         R.RQST_STAT,
         R.JOBP_CODE ,
         R.JOBP_DESC ,
         R.RQST_DATE ,
         R.SAVE_DATE ,
         R.YEAR ,
         R.CYCL ,
         S.FILE_NO ,
         A.ACTV_DATE ,
         L.SUBJ_DESC ,
         L.ATTN_DATE ,
         L.ATTN_RSLT ,
         L.ATTN_ADDR ,
         L.ATTN_TYPE 
FROM     dbo.Request r,
         dbo.Request_Row rr,
         dbo.Service s,
         dbo.Activity a,
         dbo.Track_Attendance l,
         QXML q         
WHERE R.RQID = rr.RQST_RQID
  AND rr.SERV_FILE_NO = s.FILE_NO
  AND rr.RQST_RQID = a.RQRO_RQST_RQID
  AND rr.RWNO = a.RQRO_RWNO
  AND a.CODE = l.ACTV_CODE   
  AND  R.RQTP_CODE = '007' 
  AND  R.RQST_STAT = '002' 
  AND ( Q.FILE_NO IS NULL OR s.FILE_NO = q.FILE_NO) 
)
GO
