SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[INS_MKLC_P]
   @Mcid BIGINT,
   @Mklt_Mlid BIGINT,
   @Camp_Cmid BIGINT
AS 
BEGIN
   BEGIN TRY
      BEGIN TRAN T_INS_MKLC_P;
      
      IF EXISTS(SELECT * FROM dbo.Marketing_List_Campaign m WHERE m.MKLT_MLID = @Mklt_Mlid AND m.CAMP_CMID = @Camp_Cmid) RETURN 0;
      
      INSERT INTO dbo.Marketing_List_Campaign
              ( MKLT_MLID ,
                CAMP_CMID ,
                MCID 
              )
      VALUES  ( @Mklt_Mlid , -- MKLT_MLID - bigint
                @Camp_Cmid , -- CAMP_CMID - bigint
                @Mcid  -- MCID - bigint                
              );      
      
      COMMIT TRAN T_INS_MKLC_P;
      RETURN 0;
   END TRY
   BEGIN CATCH
      DECLARE @ErorMesg NVARCHAR(MAX);
      SELECT @ErorMesg = ERROR_MESSAGE();
      RAISERROR(@ErorMesg, 16, 1);
      ROLLBACK TRAN T_INS_MKLC_P;
      RETURN -1;   
   END CATCH;   
END;
GO
