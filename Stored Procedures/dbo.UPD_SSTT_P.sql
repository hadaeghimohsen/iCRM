SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPD_SSTT_P]
	-- Add the parameters for the stored procedure here
	@Mstt_Code SMALLINT,
	@Code SMALLINT,
	@Sstt_Desc NVARCHAR(250),
	@Sstt_Colr VARCHAR(30)
AS
BEGIN
 	-- بررسی دسترسی کاربر
	DECLARE @AP BIT
	       ,@AccessString VARCHAR(250);
	SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>52</Privilege><Sub_Sys>5</Sub_Sys></AP>';	
   EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
   IF @AP = 0 
   BEGIN
      RAISERROR ( N'خطا - عدم دسترسی به ردیف 52 سطوح امینتی : شما مجوز ویرایش کردن وضعیت فرعی را ندارید', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   -- پایان دسترسی
   
   UPDATE Sub_State
      SET SSTT_DESC = @Sstt_Desc
         ,SSTT_COLR = @Sstt_Colr
    WHERE CODE = @Code
    AND MSTT_CODE = @Mstt_Code;
END
GO
