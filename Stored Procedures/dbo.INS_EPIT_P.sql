SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_EPIT_P]
	-- Add the parameters for the stored procedure here
	@Epit_Desc NVARCHAR(250),
	@Type     VARCHAR(3),
	@Rqtp_Code VARCHAR(3),
	@Rqtt_Code VARCHAR(3),
	@Auto_Gnrt VARCHAR(3)
AS
BEGIN
 	-- بررسی دسترسی کاربر
	DECLARE @AP BIT
	       ,@AccessString VARCHAR(250);
	SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>13</Privilege><Sub_Sys>10</Sub_Sys></AP>';	
   EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
   IF @AP = 0 
   BEGIN
      RAISERROR ( N'خطا - عدم دسترسی به ردیف 13 سطوح امینتی : شما مجوز اضافه کردن آیتم هزینه جدید را ندارید', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   -- پایان دسترسی
   
   IF @Rqtp_Code = '' SET @Rqtp_Code = NULL
   IF @Rqtt_Code = '' SET @Rqtt_Code = NULL
   
   INSERT INTO Expense_Item (EPIT_DESC, TYPE, AUTO_GNRT, RQTP_CODE, RQTT_CODE)
   VALUES (@Epit_Desc, @Type, @Auto_Gnrt, @Rqtp_Code, @Rqtt_Code);
END
GO
