SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[INS_EXIF_P]
   @Comp_Code BIGINT
  ,@Serv_File_No BIGINT
  ,@Apbs_Code BIGINT
  ,@Exif_Code BIGINT
  ,@Rwno INT
AS
BEGIN
   IF @Comp_Code = 0
      SET @Comp_Code = NULL;
   IF @Serv_File_No = 0
      SET @Serv_File_No = NULL;
   IF @Exif_Code = 0
      SET @Exif_Code = NULL;

   INSERT INTO dbo.Extra_Info
           ( COMP_CODE ,
             SERV_FILE_NO ,
             APBS_CODE ,
             EXIF_CODE ,
             CODE ,
             RWNO 
           )
   VALUES  ( @Comp_Code , -- COMP_CODE - bigint
             @Serv_File_No , -- SERV_FILE_NO - bigint
             @Apbs_Code , -- APBS_CODE - bigint
             @Exif_Code , -- EXIF_CODE - bigint
             0 , -- CODE - bigint
             @Rwno  -- RWNO - int
           );
END;
GO
