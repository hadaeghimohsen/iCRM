SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[INS_JBPD_P]
   @Jobp_Code BIGINT
  ,@sstt_mstt_sub_sys SMALLINT
  ,@sstt_mstt_code SMALLINT
  ,@sstt_code SMALLINT
AS
BEGIN
   -- بررسی دسترسی اطلاعات
   
   IF EXISTS(
      SELECT *
        FROM dbo.Job_Personel_Dashboard
       WHERE JOBP_CODE = @Jobp_Code
         AND SSTT_MSTT_SUB_SYS = @sstt_mstt_sub_sys
         AND SSTT_MSTT_CODE = @sstt_mstt_code
         AND SSTT_CODE = @sstt_code
   )
   BEGIN
      RAISERROR(N'وضعیت برای این کاربر تکراری می باشد', 16, 1);
      RETURN;
   END
   
   INSERT INTO dbo.Job_Personel_Dashboard
           ( JOBP_CODE ,
             SSTT_MSTT_SUB_SYS ,
             SSTT_MSTT_CODE ,
             SSTT_CODE ,
             CODE ,
             REC_STAT 
           )
   VALUES  ( @Jobp_Code , -- JOBP_CODE - bigint
             @sstt_mstt_sub_sys , -- SSTT_MSTT_SUB_SYS - smallint
             @sstt_mstt_code , -- SSTT_MSTT_CODE - smallint
             @sstt_code , -- SSTT_CODE - smallint
             0 , -- CODE - bigint
             '002'  -- REC_STAT - varchar(3)
           );
END
GO
