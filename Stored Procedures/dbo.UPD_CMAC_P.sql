SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPD_CMAC_P]
	-- Add the parameters for the stored procedure here`
	@Comp_Code BIGINT,
   @Code     BIGINT,
	@Iscp_Isca_Iscg_Code VARCHAR(2),
	@Iscp_Isca_Code VARCHAR(2),
	@Iscp_Code VARCHAR(6),
	@Desc NVARCHAR(500),
	@Stat VARCHAR(3)
AS
BEGIN
 	-- بررسی دسترسی کاربر
	--DECLARE @AP BIT
	--       ,@AccessString VARCHAR(250);
	--SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>43</Privilege><Sub_Sys>5</Sub_Sys></AP>';	
 --  EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
 --  IF @AP = 0 
 --  BEGIN
 --     RAISERROR ( N'خطا - عدم دسترسی به ردیف 43 سطوح امینتی : شما مجوز ویرایش کردن باشگاه را ندارید', -- Message text.
 --              16, -- Severity.
 --              1 -- State.
 --              );
 --     RETURN;
 --  END
   -- پایان دسترسی
   
   UPDATE dbo.Company_Activity
      SET ISCP_ISCA_ISCG_CODE = @Iscp_Isca_Iscg_Code
         ,ISCP_ISCA_CODE = @Iscp_Isca_Code
         ,ISCP_CODE = @Iscp_Code
         ,[DESC] = @Desc
         ,STAT = @Stat
    WHERE CODE = @Code
      AND COMP_CODE = @Comp_Code;
END
GO
