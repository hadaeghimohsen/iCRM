SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[DEL_OSVN_P]
   @Ovid BIGINT   
AS
BEGIN
   BEGIN TRY   
      BEGIN TRAN T_DEL_OSVN_P;
      
      DELETE dbo.Outsource_Vendor
       WHERE OVID = @Ovid;      
      
      COMMIT TRAN T_DEL_OSVN_P;
      RETURN 0;
   END TRY 
   BEGIN CATCH
      DECLARE @ErorMesg NVARCHAR(MAX);
      SELECT @ErorMesg = ERROR_MESSAGE();
      RAISERROR(@ErorMesg, 16, 1);
      ROLLBACK TRAN T_DEL_OSVN_P;
      RETURN -1;
   END CATCH;
END;
GO
