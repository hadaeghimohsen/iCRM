SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[INS_CAMA_P]
   @Caid BIGINT,
   @Camp_Cmid BIGINT,
   @Ownr_Code BIGINT,
   @Subj_Desc NVARCHAR(500),
   @Type VARCHAR(3),
   @Chnl_Type VARCHAR(3),
   @Cmnt NVARCHAR(4000),
   @Schd_Strt_Date DATE,
   @Schd_End_Date DATE,
   @Actl_Strt_Date DATE,
   @Actl_End_Date DATE,
   @Trcb_Tcid BIGINT,
   @Aloc_Budg_Amnt BIGINT,
   @Anti_Spam_Numb_Day INT,
   @Prio_Type VARCHAR(3),
   @Stat VARCHAR(3)
AS
BEGIN
   BEGIN TRY   
      BEGIN TRAN T_INS_CAMA_P;
      IF EXISTS(SELECT * FROM dbo.Campaign_Activity WHERE CAMP_CMID = @Camp_Cmid AND OWNR_CODE = @Ownr_Code AND SUBJ_DESC = @Subj_Desc)
         RAISERROR(N'این عنوان فعالیت تبلیغاتی قبلا برای این تبلیغات ثبت شده است، لطفا اصلاح کنید', 16, 1);
      
      INSERT INTO dbo.Campaign_Activity
              ( CAMP_CMID ,
                OWNR_CODE ,
                CAID ,
                SUBJ_DESC ,
                TYPE ,
                CHNL_TYPE ,
                CMNT ,
                SCHD_STRT_DATE ,
                SCHD_END_DATE ,
                ACTL_STRT_DATE ,
                ACTL_END_DATE ,
                TRCB_TCID ,
                ALOC_BUDG_AMNT ,
                ANTI_SPAM_NUMB_DAY ,
                PRIO_TYPE ,
                STAT 
              )
      VALUES  ( @Camp_Cmid , -- CAMP_CMID - bigint
                @Ownr_Code , -- OWNR_CODE - bigint
                @Caid , -- CAID - bigint
                @Subj_Desc , -- SUBJ_DESC - nvarchar(500)
                @Type , -- TYPE - varchar(3)
                @Chnl_Type , -- CHNL_TYPE - varchar(3)
                @Cmnt , -- CMNT - nvarchar(4000)
                @Schd_Strt_Date , -- SCHD_STRT_DATE - date
                @Schd_End_Date , -- SCHD_END_DATE - date
                @Actl_Strt_Date , -- ACTL_STRT_DATE - date
                @Actl_End_Date , -- ACTL_END_DATE - date
                @Trcb_Tcid , -- TRCB_TCID - bigint
                @Aloc_Budg_Amnt , -- ALOC_BUDG_AMNT - bigint
                @Anti_Spam_Numb_Day , -- ANTI_SPAM_NUMB_DAY - int
                @Prio_Type , -- PRIO_TYPE - varchar(3)
                @Stat  -- STAT - varchar(3)                
              );
      
      COMMIT TRAN T_INS_CAMA_P;
      RETURN 0;
   END TRY 
   BEGIN CATCH
      DECLARE @ErorMesg NVARCHAR(MAX);
      SELECT @ErorMesg = ERROR_MESSAGE();
      RAISERROR(@ErorMesg, 16, 1);
      ROLLBACK TRAN T_INS_CAMA_P;
      RETURN -1;
   END CATCH;
END;
GO
