SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[DEL_CMAC_P]
	-- Add the parameters for the stored procedure here
   @Code     BIGINT
AS
BEGIN
 	-- بررسی دسترسی کاربر
	--DECLARE @AP BIT
	--       ,@AccessString VARCHAR(250);
	--SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>44</Privilege><Sub_Sys>5</Sub_Sys></AP>';	
 --  EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
 --  IF @AP = 0 
 --  BEGIN
 --     RAISERROR ( N'خطا - عدم دسترسی به ردیف 44 سطوح امینتی : شما مجوز حذف باشگاه را ندارید', -- Message text.
 --              16, -- Severity.
 --              1 -- State.
 --              );
 --     RETURN;
 --  END
   -- پایان دسترسی
   
   DELETE dbo.Company_Activity
    WHERE CODE = @Code;
END
GO
