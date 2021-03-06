SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_SSTT_P]
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
	SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>51</Privilege><Sub_Sys>5</Sub_Sys></AP>';	
   EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
   IF @AP = 0 
   BEGIN
      RAISERROR ( N'خطا - عدم دسترسی به ردیف 51 سطوح امینتی : شما مجوز اضافه کردن وضعیت فرعی را ندارید', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   -- پایان دسترسی
   
   INSERT INTO Sub_State (MSTT_SUB_SYS, MSTT_CODE, CODE, SSTT_DESC, SSTT_COLR)
   VALUES (1, @Mstt_Code, @Code, @Sstt_Desc, @Sstt_Colr);
END
GO
