SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPD_EXCS_P]
	@REGN_PRVN_CNTY_CODE VARCHAR(3)
  ,@REGN_PRVN_CODE VARCHAR(3)
  ,@REGN_CODE VARCHAR(3)
  ,@REGL_YEAR SMALLINT
  ,@REGL_CODE INT
  ,@EXTP_CODE BIGINT
  ,@CASH_CODE BIGINT
  ,@EXCS_STAT VARCHAR(3)
AS
BEGIN
	-- بررسی دسترسی کاربر
	DECLARE @AP BIT
	       ,@AccessString VARCHAR(250);
	SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>42</Privilege><Sub_Sys>10</Sub_Sys></AP>';	
   EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
   IF @AP = 0 
   BEGIN
      RAISERROR ( N'خطا - عدم دسترسی به ردیف 42 سطوح امینتی', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      GOTO L$End;
   END
   -- پایان دسترسی
   
   UPDATE Expense_Cash
      SET EXCS_STAT = @Excs_Stat--CASE CASH_CODE WHEN @CASH_CODE THEN '002' ELSE '001' END
    WHERE REGN_PRVN_CNTY_CODE = @REGN_PRVN_CNTY_CODE
      AND REGN_PRVN_CODE = @REGN_PRVN_CODE
      AND REGN_CODE = @REGN_CODE
      AND REGL_CODE = @REGL_CODE
      AND REGL_YEAR = @REGL_YEAR
      AND EXTP_CODE = @EXTP_CODE
      AND CASH_CODE = @CASH_CODE;
   L$End:
   RETURN;
END
GO
