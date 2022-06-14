SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_TRFD_P]
	-- Add the parameters for the stored procedure here
	@BTRFCode BIGINT,
	@Name     NVARCHAR(250),
	@TRFDDesc NVARCHAR(250),
	@Order    SMALLINT
AS
BEGIN
 	-- بررسی دسترسی کاربر
	DECLARE @AP BIT
	       ,@AccessString VARCHAR(250);
	SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>20</Privilege><Sub_Sys>10</Sub_Sys></AP>';	
   EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
   IF @AP = 0 
   BEGIN
      RAISERROR ( N'خطا - عدم دسترسی به ردیف 20 سطوح امینتی : شما مجوز اضافه کردن رده کمربند را ندارید', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   -- پایان دسترسی
   
   INSERT INTO Base_Tariff_Detail (BTRF_CODE, NAME, TRFD_DESC, ORDR)
   VALUES (@BTRFCode, @TRFDDesc, @TRFDDesc, @Order);
END
GO
