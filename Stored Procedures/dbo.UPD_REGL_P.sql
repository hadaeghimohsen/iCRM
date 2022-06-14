SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPD_REGL_P]
	@Year SMALLINT
  ,@Code INT
  ,@Type VARCHAR(3)
  ,@Regl_Stat VARCHAR(3)
  ,@Lett_No VARCHAR(15)
  ,@Lett_Date DATETIME
  ,@Lett_Ownr NVARCHAR(250)
  ,@Strt_Date DATETIME
  ,@End_Date  DATETIME
  ,@Tax_Prct  REAL
  ,@Duty_Prct REAL
  ,@Amnt_Type VARCHAR(3)
AS
BEGIN
   -- بررسی دسترسی کاربر
	DECLARE @AP BIT
	       ,@AccessString VARCHAR(250);
	SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>29</Privilege><Sub_Sys>11</Sub_Sys></AP>';	
   EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
   IF @AP = 0 
   BEGIN
      RAISERROR ( N'خطا - عدم دسترسی به ردیف 29 سطوح امینتی', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      GOTO L$End;
   END
   -- پایان دسترسی
   
	UPDATE Regulation
	   SET TYPE = @Type
	      ,REGL_STAT = @Regl_Stat
	      ,LETT_NO = @Lett_No
	      ,LETT_DATE = @Lett_Date
	      ,LETT_OWNR = @Lett_Ownr
	      ,STRT_DATE = @Strt_Date
	      ,END_DATE = @End_Date
	      ,TAX_PRCT = @Tax_Prct
	      ,DUTY_PRCT = @Duty_Prct
	      ,AMNT_TYPE = @Amnt_Type
	 WHERE YEAR = @Year
	   AND CODE = @Code;
	
	L$End:
	RETURN;
END
GO
