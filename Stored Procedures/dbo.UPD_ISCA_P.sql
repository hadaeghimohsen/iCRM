SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[UPD_ISCA_P]
	-- Add the parameters for the stored procedure here
	@Frsi_Desc NVARCHAR(250),
	@Iscg_Code VARCHAR(2),
	@Code varchar(2)
AS
BEGIN
 	-- بررسی دسترسی کاربر
	DECLARE @AP BIT
	       ,@AccessString VARCHAR(250);
	SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>70</Privilege><Sub_Sys>11</Sub_Sys></AP>';	
   EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
   IF @AP = 0 
   BEGIN
      RAISERROR ( N'خطا - عدم دسترسی به ردیف 70 سطوح امینتی : شما مجوز اضافه کردن سبک جدید را ندارید', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   -- پایان دسترسی
   
   UPDATE dbo.Isic_Activity
      SET FRSI_DESC = @Frsi_Desc
    WHERE CODE = @Code
      AND ISCG_CODE = @Iscg_Code;
END
GO
