SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPD_TRFD_P]
	-- Add the parameters for the stored procedure here
	@Code     BIGINT,
	@Name     NVARCHAR(250),
	@TRFDDesc NVARCHAR(250),
	@Order    SMALLINT
AS
BEGIN
 	-- بررسی دسترسی کاربر
	DECLARE @AP BIT
	       ,@AccessString VARCHAR(250);
	SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>21</Privilege><Sub_Sys>10</Sub_Sys></AP>';	
   EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
   IF @AP = 0 
   BEGIN
      RAISERROR ( N'خطا - عدم دسترسی به ردیف 21 سطوح امینتی : شما مجوز ویرایش کردن رده کمربند را ندارید', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   -- پایان دسترسی
   
   UPDATE Base_Tariff_Detail
      SET NAME = @TRFDDesc
         ,TRFD_DESC = @TRFDDesc
         ,ORDR = @Order
    WHERE CODE = @Code;
END
GO
