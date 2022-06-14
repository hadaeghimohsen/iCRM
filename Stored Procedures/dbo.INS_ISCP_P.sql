SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_ISCP_P]
	-- Add the parameters for the stored procedure here
	@Iscp_Desc NVARCHAR(250),
	@Isca_Iscg_Code VARCHAR(2),
	@Isca_Code VARCHAR(2),
	@Code VARCHAR(6)
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
   
   INSERT INTO dbo.Isic_Product
           ( ISCA_ISCG_CODE ,
             ISCA_CODE ,
             CODE ,
             ISCP_DESC 
           )
   VALUES  ( @Isca_Iscg_Code , -- ISCA_ISCG_CODE - varchar(2)
             @Isca_Code , -- ISCA_CODE - varchar(2)
             @Code , -- CODE - varchar(6)
             @Iscp_Desc  -- ISCP_DESC - nvarchar(255)
           );
END
GO
