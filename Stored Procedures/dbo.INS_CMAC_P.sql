SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_CMAC_P]
	-- Add the parameters for the stored procedure here
	@Comp_Code BIGINT,
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
   
   INSERT INTO dbo.Company_Activity
           ( COMP_CODE ,
             ISCP_ISCA_ISCG_CODE ,
             ISCP_ISCA_CODE ,
             ISCP_CODE ,
             Code,
             [DESC] ,
             STAT )
   VALUES  ( @Comp_Code , -- COMP_CODE - bigint
             @Iscp_Isca_Iscg_Code , -- ISCP_ISCA_ISCG_CODE - varchar(2)
             @Iscp_Isca_Code , -- ISCP_ISCA_CODE - varchar(2)
             @Iscp_Code , -- ISCP_CODE - varchar(6)
             0 , -- CODE - bigint
             @Desc, 
             @Stat
           );
END
GO
