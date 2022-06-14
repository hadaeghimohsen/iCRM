SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[INS_CAMQ_P]
   @Qcid BIGINT,
   @Mklt_Mlid BIGINT,
   @Ownr_Code BIGINT,
   @Subj_Desc NVARCHAR(500),
   @Numb_Sucs INT,
   @Numb_Fail INT,
   @Eror_Desc NVARCHAR(4000),
   @Memb_Type VARCHAR(3),
   @Actv_Type VARCHAR(3),
   @Stat_Resn VARCHAR(3)
AS    
BEGIN
   BEGIN TRY
      BEGIN TRAN T_INS_CAMQ_P;
      
      IF EXISTS(SELECT * FROM dbo.Campaign_Quick WHERE OWNR_CODE = @Ownr_Code AND MKLT_MLID = @Mklt_Mlid AND SUBJ_DESC = @Subj_Desc)
         RAISERROR (N'این عنوان تبلیغات سریع قبلا برای شما تعریف شده، لطفا عنوان تبلیغات سریع خود را اصلاح کنید', 16, 1);
      
      INSERT INTO dbo.Campaign_Quick
              ( OWNR_CODE ,
                MKLT_MLID,
                QCID ,
                SUBJ_DESC ,
                NUMB_SUCS ,
                NUMB_FAIL ,
                EROR_DESC ,
                MEMB_TYPE ,
                ACTV_TYPE ,
                STAT_RESN 
              )
      VALUES  ( @Ownr_Code , -- OWNR_CODE - bigint
                @Mklt_Mlid , -- MKLT_MLID
                @Qcid , -- QCID - bigint
                @Subj_Desc , -- SUBJ_DESC - nvarchar(500)
                @Numb_Sucs , -- NUMB_SUCS - int
                @Numb_Fail , -- NUMB_FAIL - int
                @Eror_Desc , -- EROR_DESC - nvarchar(4000)
                @Memb_Type , -- MEMB_TYPE - varchar(3)
                @Actv_Type , -- ACTV_TYPE - varchar(3)
                @Stat_Resn  -- STAT_RESN - varchar(3)
              );
      
      COMMIT TRAN T_INS_CAMQ_P;
      RETURN 0;
   END TRY
   BEGIN CATCH
      DECLARE @ErorMesg NVARCHAR(Max);
	   SET @ErorMesg = ERROR_MESSAGE();
      RAISERROR ( @ErorMesg, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN T_INS_CAMQ_P;
      RETURN -1;
   END CATCH;    
END;   
GO
