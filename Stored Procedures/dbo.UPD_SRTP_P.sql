SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[UPD_SRTP_P]
   @Code VARCHAR(3),
   @Srtp_Desc NVARCHAR(50)
AS 
BEGIN
   MERGE dbo.Service_Type T
   USING (SELECT @Code AS Code, @Srtp_Desc AS Srtp_Desc) S
   ON (T.CODE = S.Code)
   WHEN MATCHED THEN
      UPDATE SET
         T.SRTP_DESC = S.Srtp_Desc;   
END;
GO
