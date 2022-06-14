SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[UPD_MKLC_P]
   @Mcid BIGINT,
   @Mklt_Mlid BIGINT,
   @Camp_Cmid BIGINT
AS 
BEGIN
   BEGIN TRY
      BEGIN TRAN T_UPD_MKLC_P;
      
      IF EXISTS(SELECT * FROM dbo.Marketing_List_Campaign WHERE MKLT_MLID = @Mklt_Mlid AND CAMP_CMID = @Camp_Cmid AND MCID != @Mcid) RETURN 0;
      
      UPDATE dbo.Marketing_List_Campaign
         SET CAMP_CMID = @Camp_Cmid
       WHERE MCID = @Mcid;
      
      COMMIT TRAN T_UPD_MKLC_P;
      RETURN 0;
   END TRY
   BEGIN CATCH
      DECLARE @ErorMesg NVARCHAR(MAX);
      SELECT @ErorMesg = ERROR_MESSAGE();
      RAISERROR(@ErorMesg, 16, 1);
      ROLLBACK TRAN T_UPD_MKLC_P;
      RETURN -1;   
   END CATCH;   
END;
GO
