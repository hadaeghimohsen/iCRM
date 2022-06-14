SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_CASH_P]
	-- Add the parameters for the stored procedure here
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
	SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>24</Privilege><Sub_Sys>10</Sub_Sys></AP>';	
   EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
   IF @AP = 0 
   BEGIN
      RAISERROR ( N'خطا - عدم دسترسی به ردیف 24 سطوح امینتی : شما مجوز اضافه کردن حساب را ندارید', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   -- پایان دسترسی
   
   INSERT INTO dbo.Cash
           ( NAME ,
             BANK_NAME ,
             BANK_BRNC_CODE ,
             BANK_ACNT_NUMB ,
             SHBA_ACNT ,
             CARD_NUMB ,
             TYPE ,
             CASH_STAT              
           )
   VALUES  ( '' , -- NAME - nvarchar(250)
             @Bank_Name , -- BANK_NAME - nvarchar(250)
             @Bank_Brnc_Code , -- BANK_BRNC_CODE - varchar(50)
             @Bank_Acnt_Numb , -- BANK_ACNT_NUMB - varchar(50)
             @Shba_Acnt , -- SHBA_ACNT - varchar(26)
             @Card_Numb , -- CARD_NUMB - varchar(19)
             @Type , -- TYPE - varchar(3)
             @Cash_Stat -- CASH_STAT - varchar(3)             
           );
END
GO
