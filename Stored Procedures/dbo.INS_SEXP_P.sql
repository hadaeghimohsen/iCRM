SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_SEXP_P]
	@X XML
AS
BEGIN
	DECLARE @Rqid BIGINT
	       ,@RqroRwno SMALLINT
	       ,@RqtpCode VARCHAR(3)
	       ,@RqtpType VARCHAR(3)
	       ,@RqttCode VARCHAR(3)
	       ,@PrvnCode VARCHAR(3)
	       ,@RegnCode VARCHAR(3)
	       ,@FileNo   BIGINT
	       ,@BTRFCode BIGINT
	       ,@TRFDCode BIGINT
	       ,@Qnty SMALLINT;
   
   SELECT @Rqid     = @X.query('//Request').value('(Request/@rqid)[1]'    , 'BIGINT')
         ,@RqtpCode = @X.query('//Request').value('(Request/@rqtpcode)[1]', 'VARCHAR(3)')
         ,@RqttCode = @X.query('//Request').value('(Request/@rqttcode)[1]', 'VARCHAR(3)')
         ,@PrvnCode = @X.query('//Request').value('(Request/@prvncode)[1]', 'VARCHAR(3)')
         ,@RegnCode = @X.query('//Request').value('(Request/@regncode)[1]', 'VARCHAR(3)')
         ,@FileNo   = @X.query('//Request').value('(Request/@fileno)[1]',   'BIGINT')
         ,@Qnty = 1;
         
   IF LEN(@RqtpCode) = 0 OR
      LEN(@RqttCode) = 0 OR
      LEN(@PrvnCode) = 0 OR
      LEN(@RegnCode) = 0 OR
--          @BTRFCode  = 0 OR
--          @TRFDCode  = 0 OR
          @Rqid      = 0
    BEGIN
      RAISERROR('با اطلاعات وارد شده نمی توان هزینه ثبت کرد' , 16, 1);
      RETURN;
    END
    
    DELETE Payment_Detail 
     WHERE PYMT_RQST_RQID = @Rqid
       AND ADD_QUTS = '001';
    
    DELETE Payment
     WHERE RQST_RQID = @Rqid
       AND (
		   NOT EXISTS (
			  SELECT * 
				FROM Payment_Detail
			   WHERE PYMT_RQST_RQID = @Rqid
		   )
		   AND
		   NOT EXISTS (
			  SELECT * 
			    FROM Payment_Discount
			   WHERE PYMT_RQST_RQID = @Rqid
		   )
	   );    
   
    IF NOT EXISTS(SELECT * FROM Payment WHERE RQST_RQID = @Rqid)
    BEGIN
		INSERT INTO Payment (RQST_RQID, CASH_CODE, TYPE) 
		SELECT DISTINCT @Rqid, Cash_Code, '002'
		FROM VF$All_Expense_Detail(@PrvnCode, @RegnCode, NULL, @RqtpCode, @RqttCode, NULL, NULL, @BTRFCode, @TRFDCode)
		WHERE ADD_QUTS = '001';
	 END	 

END
GO
