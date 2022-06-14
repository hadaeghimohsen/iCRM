SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[DEL_ISCP_P]
	-- Add the parameters for the stored procedure here
	@Isca_Iscg_Code VARCHAR(2),
	@Isca_Code VARCHAR(2),
	@Code VARCHAR(6)
AS
BEGIN
 	-- بررسی دسترسی کاربر
	DECLARE @AP BIT
	       ,@AccessString VARCHAR(250);
	SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>71</Privilege><Sub_Sys>11</Sub_Sys></AP>';	
   EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
   IF @AP = 0 
   BEGIN
      RAISERROR ( N'خطا - عدم دسترسی به ردیف 71 سطوح امینتی : شما مجوز حدف کردن سبک را ندارید', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   -- پایان دسترسی
   
   DELETE dbo.Isic_Product
    WHERE CODE = @Code
      AND Isca_ISCG_CODE = @Isca_Iscg_Code
      AND ISCA_CODE = @Isca_Code;
   
   RETURN 0;
END
GO
