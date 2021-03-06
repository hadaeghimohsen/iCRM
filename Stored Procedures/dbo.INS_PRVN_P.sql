SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_PRVN_P]
	-- Add the parameters for the stored procedure here
	@Cnty_Code VARCHAR(3),
	@Code VARCHAR(3),
	@Name NVARCHAR(250)
AS
BEGIN
 	-- بررسی دسترسی کاربر
	DECLARE @AP BIT
	       ,@AccessString VARCHAR(250);
	SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>6</Privilege><Sub_Sys>11</Sub_Sys></AP>';	
   EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
   IF @AP = 0 
   BEGIN
      RAISERROR ( N'خطا - عدم دسترسی به ردیف 6 سطوح امینتی : شما مجوز اضافه کردن استان جدید را ندارید', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   -- پایان دسترسی
   
   IF dbo.IsStringNullOrEmpty(@Cnty_Code, '000') = '000'
   BEGIN
      RAISERROR ( N'کد کشور وارد نشده', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   
   IF dbo.IsStringNullOrEmpty(@Code, '000') = '000'
   BEGIN
      RAISERROR ( N'کد استان وارد نشده', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   
   IF dbo.IsStringNullOrEmpty(@NAME, '000') = '000'
   BEGIN
      RAISERROR ( N'نام استان وارد نشده', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   
   INSERT INTO Province (CNTY_CODE, CODE, NAME)
   VALUES (@Cnty_Code, @Code, @Name);
END
GO
