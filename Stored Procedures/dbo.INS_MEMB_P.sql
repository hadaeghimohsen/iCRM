SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[INS_MEMB_P]
   @Mbid BIGINT,
   @Mklt_Mlid BIGINT,
   @Lead_Ldid BIGINT,
   @Serv_File_No BIGINT,
   @Comp_Code BIGINT
AS
BEGIN
   BEGIN TRY 
      BEGIN TRAN T_INS_MEMB_P
         IF EXISTS(SELECT * FROM dbo.Member WHERE MKLT_MLID = @Mklt_Mlid AND (SERV_FILE_NO = @Serv_File_No OR COMP_CODE = @Comp_Code OR LEAD_LDID = @Lead_Ldid)) RETURN 0;
         
         INSERT INTO dbo.Member
                 ( SERV_FILE_NO ,
                   COMP_CODE ,
                   LEAD_LDID,
                   MKLT_MLID ,
                   MBID 
                 )
         VALUES  ( @Serv_File_No , -- SERV_FILE_NO - bigint
                   @Comp_Code , -- COMP_CODE - bigint
                   @Lead_Ldid ,
                   @Mklt_Mlid , -- MKLT_MLID - bigint
                   @Mbid  -- MBID - bigint
                 );
      COMMIT TRAN T_INS_MEMB_P
      RETURN 0;   
   END TRY
   BEGIN CATCH
      DECLARE @ErorMesg NVARCHAR(MAX);
      SELECT @ErorMesg = ERROR_MESSAGE();
      RAISERROR(@ErorMesg, 16, 1);
      ROLLBACK TRAN T_INS_MEMB_P;
      RETURN -1;
   END CATCH;   
END;
GO
