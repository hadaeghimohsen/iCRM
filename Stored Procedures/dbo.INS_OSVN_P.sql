SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[INS_OSVN_P]
   @Ovid BIGINT,
   @Cama_Caid BIGINT,
   @Serv_File_No BIGINT,
   @Comp_Code BIGINT   
AS
BEGIN
   BEGIN TRY   
      BEGIN TRAN T_INS_OSVN_P;
      IF EXISTS(SELECT * FROM dbo.Outsource_Vendor WHERE CAMA_CAID = @Cama_Caid AND (SERV_FILE_NO = @Serv_File_No OR COMP_CODE = @Comp_Code))RETURN 0;
      
      INSERT INTO dbo.Outsource_Vendor
              ( CAMA_CAID ,
                SERV_FILE_NO ,
                COMP_CODE ,
                OVID 
              )
      VALUES  ( @Cama_Caid , -- CAMA_CAID - bigint
                @Serv_File_No , -- SERV_FILE_NO - bigint
                @Comp_Code , -- COMP_CODE - bigint
                @Ovid  -- OVID - bigint                
              );
      
      COMMIT TRAN T_INS_OSVN_P;
      RETURN 0;
   END TRY 
   BEGIN CATCH
      DECLARE @ErorMesg NVARCHAR(MAX);
      SELECT @ErorMesg = ERROR_MESSAGE();
      RAISERROR(@ErorMesg, 16, 1);
      ROLLBACK TRAN T_INS_OSVN_P;
      RETURN -1;
   END CATCH;
END;
GO
