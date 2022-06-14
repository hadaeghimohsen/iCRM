SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[UPD_OSVN_P]
   @Ovid BIGINT,
   @Cama_Caid BIGINT,
   @Serv_File_No BIGINT,
   @Comp_Code BIGINT   
AS
BEGIN
   BEGIN TRY   
      BEGIN TRAN T_UPD_OSVN_P;
      IF EXISTS(SELECT * FROM dbo.Outsource_Vendor WHERE CAMA_CAID = @Cama_Caid AND (SERV_FILE_NO = @Serv_File_No OR COMP_CODE = @Comp_Code) AND OVID != @Ovid)RETURN 0;
      
      UPDATE dbo.Outsource_Vendor
         SET CAMA_CAID = @Cama_Caid
            ,SERV_FILE_NO = @Serv_File_No
            ,COMP_CODE = @Comp_Code
       WHERE OVID = @Ovid;      
      
      COMMIT TRAN T_UPD_OSVN_P;
      RETURN 0;
   END TRY 
   BEGIN CATCH
      DECLARE @ErorMesg NVARCHAR(MAX);
      SELECT @ErorMesg = ERROR_MESSAGE();
      RAISERROR(@ErorMesg, 16, 1);
      ROLLBACK TRAN T_UPD_OSVN_P;
      RETURN -1;
   END CATCH;
END;
GO
