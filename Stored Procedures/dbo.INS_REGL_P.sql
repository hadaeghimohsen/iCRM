SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_REGL_P]
	@Year SMALLINT
  ,@Type VARCHAR(3)
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
	SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>28</Privilege><Sub_Sys>11</Sub_Sys></AP>';	
   EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
   IF @AP = 0 
   BEGIN
      RAISERROR ( N'خطا - عدم دسترسی به ردیف 28 سطوح امینتی', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      GOTO L$End;
   END;
   -- پایان دسترسی
   
  
	INSERT INTO Regulation ( YEAR, TYPE, SUB_SYS,  REGL_STAT, LETT_NO, LETT_DATE, LETT_OWNR, STRT_DATE, END_DATE, TAX_PRCT, DUTY_PRCT, AMNT_TYPE)
	VALUES                 (@Year, @Type, 1      , '001'    , @Lett_No, @Lett_Date, @Lett_Ownr, @Strt_Date, @End_Date, @Tax_Prct, @Duty_Prct, @Amnt_Type);
	
	L$End:
	RETURN;
END
GO
