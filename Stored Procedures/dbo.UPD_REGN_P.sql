SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPD_REGN_P]
	-- Add the parameters for the stored procedure here
	@Prvn_Cnty_Code VARCHAR(3),
	@Prvn_Code VARCHAR(3),
	@Code VARCHAR(3),
	@Name NVARCHAR(250),
	@Regn_Code VARCHAR(3)
AS
BEGIN
 	-- بررسی دسترسی کاربر
	DECLARE @AP BIT
	       ,@AccessString VARCHAR(250);
	SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>10</Privilege><Sub_Sys>11</Sub_Sys></AP>';	
   EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
   IF @AP = 0 
   BEGIN
      RAISERROR ( N'خطا - عدم دسترسی به ردیف 10 سطوح امینتی : شما مجوز ویرایش کردن ناحیه را ندارید', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   -- پایان دسترسی
   
   IF dbo.IsStringNullOrEmpty(@Prvn_Cnty_Code, '000') = '000'
   BEGIN
      RAISERROR ( N'کد کشور وارد نشده', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   
   IF dbo.IsStringNullOrEmpty(@Prvn_Code, '000') = '000'
   BEGIN
      RAISERROR ( N'کد استان وارد نشده', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   
   IF dbo.IsStringNullOrEmpty(@Code, '000') = '000'
   BEGIN
      RAISERROR ( N'کد کد ناحیه وارد نشده', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   
   IF dbo.IsStringNullOrEmpty(@NAME, '000') = '000'
   BEGIN
      RAISERROR ( N'نام ناحیه وارد نشده', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
      
   UPDATE Region
      SET NAME = @Name
         ,REGN_CODE = @Regn_Code
    WHERE CODE = @Code
      AND PRVN_CODE = @Prvn_Code
      AND PRVN_CNTY_CODE = @Prvn_Cnty_Code;
END
GO
