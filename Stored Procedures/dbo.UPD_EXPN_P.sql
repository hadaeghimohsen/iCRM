SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPD_EXPN_P]
   @CODE BIGINT
  ,@PRIC INT
  ,@EXPN_STAT VARCHAR(3)
  ,@ADD_QUTS VARCHAR(3)
  ,@COVR_DSCT VARCHAR(3)
  ,@EXPN_TYPE VARCHAR(3)
  ,@BUY_PRIC INT
  ,@BUY_EXTR_PRCT INT
  ,@NUMB_OF_STOK INT
  ,@NUMB_OF_SALE INT
  ,@ORDR_ITEM BIGINT
  ,@NUMB_OF_MONT INT
  ,@VOLM_OF_TRFC INT
  ,@AUTO_ADD VARCHAR(3)
  ,@Modl_Numb_Bar_Code VARCHAR(50)
  ,@Covr_Tax VARCHAR(3)
  ,@EXPN_DESC NVARCHAR(250)
AS
BEGIN
	-- بررسی دسترسی کاربر
	DECLARE @AP BIT
	       ,@AccessString VARCHAR(250);
	SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>39</Privilege><Sub_Sys>10</Sub_Sys></AP>';	
   EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
   IF @AP = 0 
   BEGIN
      RAISERROR ( N'خطا - عدم دسترسی به ردیف 39 سطوح امینتی', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      GOTO L$End;
   END
   -- پایان دسترسی
   
   UPDATE Expense
      SET EXPN_STAT = @EXPN_STAT
         ,PRIC = @PRIC
         ,EXPN_DESC = @Expn_Desc
         ,ADD_QUTS = @Add_Quts
         ,COVR_DSCT = @Covr_DSCT
         ,EXPN_TYPE = @EXPN_TYPE
         ,BUY_PRIC = @BUY_PRIC
         ,BUY_EXTR_PRCT = @BUY_EXTR_PRCT
         ,NUMB_OF_STOK = @NUMB_OF_STOK
         ,NUMB_OF_SALE = @NUMB_OF_SALE
         ,ORDR_ITEM = @ORDR_ITEM
         ,NUMB_OF_MONT = @NUMB_OF_MONT
         ,VOLM_OF_TRFC = @VOLM_OF_TRFC
         ,AUTO_ADD = @AUTO_ADD
         ,MODL_NUMB_BAR_CODE = @Modl_Numb_Bar_Code
         ,COVR_TAX = @Covr_Tax
    WHERE CODE = @CODE;
   
   L$End:
   RETURN;
END
GO
