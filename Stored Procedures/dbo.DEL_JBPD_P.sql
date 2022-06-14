SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[DEL_JBPD_P]
   @Code BIGINT
AS
BEGIN
   -- بررسی دسترسی اطلاعات
   
   DELETE dbo.Job_Personel_Dashboard
    WHERE CODE = @Code;
END
GO
