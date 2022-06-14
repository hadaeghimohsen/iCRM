SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[DEL_SRTP_P]
   @Code VARCHAR(3)
AS 
BEGIN
   IF EXISTS(
      SELECT * 
        FROM dbo.Service_Join_Service_Type
       WHERE SRTP_CODE = @Code
         AND RECD_STAT = '002'
   ) OR 
   EXISTS (
      SELECT *
        FROM dbo.Personnel_Access_Service_Type
       WHERE SRTP_CODE = @Code
         AND RECD_STAT = '002'
   )
   BEGIN
      RAISERROR (N'شما قادر به حذف این ماهیت نیستید، بخاطر اینکه از این ماهیت در جدول مشتریان', 16, 1);
      RETURN;
   END
   
   DELETE dbo.Service_Join_Service_Type
    WHERE SRTP_CODE = @Code
      AND RECD_STAT = '001';
  
   DELETE dbo.Personnel_Access_Service_Type
    WHERE SRTP_CODE = @Code
      AND RECD_STAT = '001';
   
   DELETE dbo.Service_Type
    WHERE CODE = @Code;
END;
GO
