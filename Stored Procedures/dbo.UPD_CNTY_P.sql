SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPD_CNTY_P]
	-- Add the parameters for the stored procedure here
	@Code VARCHAR(3),
	@NAME NVARCHAR(250)
AS
BEGIN
 	-- بررسی دسترسی کاربر
	DECLARE @AP BIT
	       ,@AccessString VARCHAR(250);
	SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>4</Privilege><Sub_Sys>11</Sub_Sys></AP>';	
   EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
   IF @AP = 0 
   BEGIN
      RAISERROR ( N'خطا - عدم دسترسی به ردیف 4 سطوح امینتی : شما مجوز ویرایش کردن کشور را ندارید', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   -- پایان دسترسی
   
   IF dbo.IsStringNullOrEmpty(@Code, '000') = '000'
   BEGIN
      RAISERROR ( N'کد کشور وارد نشده', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   
   IF dbo.IsStringNullOrEmpty(@NAME, '000') = '000'
   BEGIN
      RAISERROR ( N'نام کشور وارد نشده', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   
   
   UPDATE Country
      SET NAME = @NAME
    WHERE CODE = @Code;
END
GO
