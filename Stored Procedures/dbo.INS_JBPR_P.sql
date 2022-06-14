SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_JBPR_P]
	@Jobp_Code BIGINT
  ,@Rlat_Jobp_Code BIGINT
  ,@Apbs_Code BIGINT
AS
BEGIN
	-- بررسی دسترسی کاربر
	DECLARE @AP BIT
	       ,@AccessString VARCHAR(250);
	SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>81</Privilege><Sub_Sys>11</Sub_Sys></AP>';	
   EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
   IF @AP = 0 
   BEGIN
      RAISERROR ( N'خطا - عدم دسترسی به ردیف 81 سطوح امینتی : شما مجوز حدف کردن حساب را ندارید', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   -- پایان دسترسی
   
   IF EXISTS(
      SELECT * 
        FROM dbo.Job_Personnel_Relation
       WHERE JOBP_CODE = @Jobp_Code
         AND RLAT_JOBP_CODE = @Rlat_Jobp_Code
         AND APBS_CODE = @Apbs_Code
   )
   BEGIN
      RAISERROR (N'رکورد تکراری می باشد', 16, 1);
      RETURN;
   END
      
      
   
   INSERT INTO dbo.Job_Personnel_Relation
           ( JOBP_CODE ,
             RLAT_JOBP_CODE ,
             APBS_CODE ,
             CODE ,
             REC_STAT 
           )
   VALUES  ( @Jobp_Code , -- JOBP_CODE - bigint
             @Rlat_Jobp_Code , -- RLAT_JOBP_CODE - bigint
             @Apbs_Code , -- APBS_CODE - bigint
             0 , -- CODE - bigint
             '002' 
           );
END
GO
