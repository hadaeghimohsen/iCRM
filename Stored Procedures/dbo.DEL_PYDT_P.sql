SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[DEL_PYDT_P]
   @CODE BIGINT
  ,@PYMT_CASH_CODE BIGINT
  ,@PYMT_RQST_RQID BIGINT
  ,@RQRO_RWNO SMALLINT
  ,@EXPN_CODE BIGINT  

AS
BEGIN

DELETE dbo.Payment_Detail
 WHERE PYMT_RQST_RQID = ISNULL(@PYMT_RQST_RQID, PYMT_RQST_RQID)
   AND PYMT_CASH_CODE = ISNULL(@PYMT_CASH_CODE, PYMT_CASH_CODE)
   AND RQRO_RWNO = ISNULL(@RQRO_RWNO, RQRO_RWNO)
   AND EXPN_CODE = ISNULL(@EXPN_CODE, EXPN_CODE)
   AND CODE = @CODE; 
END;



GO