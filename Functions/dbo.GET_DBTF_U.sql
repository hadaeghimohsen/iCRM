SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GET_DBTF_U]
(
	@FileNo BIGINT,
	@CompCode BIGINT
)
RETURNS BIGINT
AS
BEGIN
   DECLARE @DebtDnrm BIGINT,
           @DiscAmnt BIGINT,
           @ConfPay BIGINT;
           
	SELECT @DebtDnrm = SUM((D.EXPN_PRIC + ISNULL(D.EXPN_EXTR_PRCT, 0)) * D.QNTY) 
     FROM Request R, Request_Row Rr, Service F, Payment P, Payment_Detail D
    WHERE R.RQID = Rr.RQST_RQID
      AND Rr.SERV_FILE_NO = F.FILE_NO
      AND R.RQID = P.RQST_RQID
      AND P.RQST_RQID = D.PYMT_RQST_RQID
      AND D.PYMT_RQST_RQID = Rr.RQST_RQID
      AND D.RQRO_RWNO = Rr.RWNO
      AND R.RQST_STAT IN ('002')
      AND F.CONF_STAT = '002'
      AND P.PYMT_STAG != '007' -- نوع پرداخت ناموفق باشه
      --AND D.PAY_STAT = '001'
      AND (@FileNo IS NULL OR F.FILE_NO = @FileNo)
      AND (@CompCode IS NULL OR P.COMP_CODE_DNRM = @CompCode);
   
   
   SELECT @DiscAmnt = ISNULL(SUM(D.AMNT), 0) 
     FROM Request R, Request_Row Rr, Service F, Payment P, Payment_Discount D
    WHERE R.RQID = Rr.RQST_RQID
      AND Rr.SERV_FILE_NO = F.FILE_NO
      AND R.RQID = P.RQST_RQID
      AND P.RQST_RQID = D.PYMT_RQST_RQID
      AND D.PYMT_RQST_RQID = Rr.RQST_RQID
      AND D.RQRO_RWNO = Rr.RWNO
      AND R.RQST_STAT IN ('002')
      AND F.CONF_STAT = '002'
      AND D.STAT = '002'
      --AND D.PAY_STAT = '001'
      AND P.PYMT_STAG != '007' -- نوع پرداخت ناموفق باشه
      AND (@FileNo IS NULL OR F.FILE_NO = @FileNo)
      AND (@CompCode IS NULL OR P.COMP_CODE_DNRM = @CompCode);

   
   
   SELECT @ConfPay = ISNULL(SUM(D.AMNT) ,0)
     FROM Request R, Request_Row Rr, Service F, Payment P, dbo.Payment_Method D
    WHERE R.RQID = Rr.RQST_RQID
      AND Rr.SERV_FILE_NO = F.FILE_NO
      AND R.RQID = P.RQST_RQID
      AND P.RQST_RQID = D.PYMT_RQST_RQID
      AND D.PYMT_RQST_RQID = Rr.RQST_RQID
      AND D.RQRO_RWNO = Rr.RWNO
      AND R.RQST_STAT IN ('002')
      AND F.CONF_STAT = '002'
      --AND D.PAY_STAT = '001'
      AND P.PYMT_STAG != '007' -- نوع پرداخت ناموفق باشه
      AND (@FileNo IS NULL OR F.FILE_NO = @FileNo)
      AND (@CompCode IS NULL OR P.COMP_CODE_DNRM = @CompCode);

   
   
   SET @DebtDnrm = COALESCE(@DebtDnrm, 0)- COALESCE(@DiscAmnt, 0) - COALESCE(@ConfPay, 0);

   RETURN COALESCE(@DebtDnrm, 0);
END
GO
