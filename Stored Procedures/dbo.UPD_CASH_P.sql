SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPD_CASH_P]
	-- Add the parameters for the stored procedure here
	@Code BIGINT,
	@NAME NVARCHAR(250),
	@Bank_Name NVARCHAR(250),
	@Bank_Brnc_Code VARCHAR(50),
	@Bank_Acnt_Numb VARCHAR(50),
	@Shba_Acnt VARCHAR(26),
	@Card_Numb VARCHAR(19),
	@Type VARCHAR(3),
	@Cash_Stat VARCHAR(3)
AS
BEGIN
 	-- بررسی دسترسی کاربر
	DECLARE @AP BIT
	       ,@AccessString VARCHAR(250);
	SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>25</Privilege><Sub_Sys>10</Sub_Sys></AP>';	
   EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
   IF @AP = 0 
   BEGIN
      RAISERROR ( N'خطا - عدم دسترسی به ردیف 25 سطوح امینتی : شما مجوز ویرایش کردن حساب را ندارید', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   -- پایان دسترسی
   
   UPDATE dbo.Cash
      SET NAME = ''
         ,BANK_NAME = @Bank_Name
         ,BANK_BRNC_CODE = @Bank_Brnc_Code
         ,BANK_ACNT_NUMB = @Bank_Acnt_Numb
         ,SHBA_ACNT = @Shba_Acnt
         ,CARD_NUMB = @Card_Numb
         ,TYPE = @Type
         ,CASH_STAT = @Cash_Stat
    WHERE CODE = @Code;
    
END
GO
