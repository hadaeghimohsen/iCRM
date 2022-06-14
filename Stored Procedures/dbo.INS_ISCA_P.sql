SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [dbo].[INS_ISCA_P]
	-- Add the parameters for the stored procedure here
	@Frsi_Desc NVARCHAR(250),
	@Iscg_Code VARCHAR(2),
	@Code VARCHAR(2)
AS
BEGIN
 	-- بررسی دسترسی کاربر
	DECLARE @AP BIT
	       ,@AccessString VARCHAR(250);
	SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>69</Privilege><Sub_Sys>11</Sub_Sys></AP>';	
   EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
   IF @AP = 0 
   BEGIN
      RAISERROR ( N'خطا - عدم دسترسی به ردیف 69 سطوح امینتی : شما مجوز اضافه کردن سبک جدید را ندارید', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   -- پایان دسترسی
   
   INSERT INTO dbo.Isic_Activity
           ( ISCG_CODE ,
             CODE ,
             FRSI_DESC 
           )
   VALUES  ( @Iscg_Code , -- ISCG_CODE - varchar(2)
             @Code , -- CODE - varchar(2)
             @Frsi_Desc  -- FRSI_DESC - nvarchar(255)
           );
END
GO
