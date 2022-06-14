SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[UPD_CAMQ_P]
   @Qcid BIGINT,
   @Ownr_Code BIGINT,
   @Mklt_Mlid BIGINT,
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
      BEGIN TRAN T_UPD_CAMQ_P;
      
      IF EXISTS(SELECT * FROM dbo.Campaign_Quick WHERE OWNR_CODE = @Ownr_Code AND MKLT_MLID = @Mklt_Mlid AND SUBJ_DESC = @Subj_Desc AND QCID != @Qcid)
         RAISERROR (N'این عنوان تبلیغات سریع قبلا برای شما تعریف شده، لطفا عنوان تبلیغات سریع خود را اصلاح کنید', 16, 1);
      
      UPDATE dbo.Campaign_Quick
         SET OWNR_CODE = @Ownr_Code
            ,MKLT_MLID = @Mklt_Mlid
            ,SUBJ_DESC = @Subj_Desc
            ,NUMB_SUCS = @Numb_Sucs
            ,NUMB_FAIL = @Numb_Fail
            ,EROR_DESC = @Eror_Desc
            ,MEMB_TYPE = @Memb_Type
            ,ACTV_TYPE = @Actv_Type
            ,STAT_RESN = @Stat_Resn
       WHERE QCID = @Qcid;
      
      COMMIT TRAN T_UPD_CAMQ_P;
      RETURN 0;
   END TRY
   BEGIN CATCH
      DECLARE @ErorMesg NVARCHAR(Max);
	   SET @ErorMesg = ERROR_MESSAGE();
      RAISERROR ( @ErorMesg, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN T_UPD_CAMQ_P;
      RETURN -1;
   END CATCH;    
END;   
GO
