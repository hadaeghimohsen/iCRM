SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[UPD_JBPD_P]
   @Code BIGINT
  ,@Rec_Stat VARCHAR(3)
AS
BEGIN
   -- بررسی دسترسی اطلاعات
   
   UPDATE dbo.Job_Personel_Dashboard
      SET REC_STAT = @Rec_Stat
    WHERE CODE = @Code;
END
GO
