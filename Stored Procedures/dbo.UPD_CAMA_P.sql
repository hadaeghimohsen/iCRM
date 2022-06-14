SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[UPD_CAMA_P]
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
      BEGIN TRAN T_UPD_CAMA_P;
      IF EXISTS(SELECT * FROM dbo.Campaign_Activity WHERE CAMP_CMID = @Camp_Cmid AND OWNR_CODE = @Ownr_Code AND SUBJ_DESC = @Subj_Desc AND CAID != @Caid)
         RAISERROR(N'این عنوان فعالیت تبلیغاتی قبلا برای این تبلیغات ثبت شده است، لطفا اصلاح کنید', 16, 1);
      
      UPDATE dbo.Campaign_Activity
         SET CAMP_CMID = @Camp_Cmid
            ,OWNR_CODE = @Ownr_Code
            ,SUBJ_DESC = @Subj_Desc
            ,TYPE = @Type
            ,CHNL_TYPE = @Chnl_Type
            ,CMNT = @Cmnt
            ,SCHD_STRT_DATE = @Schd_Strt_Date
            ,SCHD_END_DATE = @Schd_End_Date
            ,ACTL_STRT_DATE = @Actl_Strt_Date
            ,ACTL_END_DATE = @Actl_End_Date
            ,TRCB_TCID = @Trcb_Tcid
            ,ALOC_BUDG_AMNT = @Aloc_Budg_Amnt
            ,ANTI_SPAM_NUMB_DAY = @Anti_Spam_Numb_Day
            ,PRIO_TYPE = @Prio_Type
            ,STAT = @Stat
       WHERE CAID = @Caid;      
      
      COMMIT TRAN T_UPD_CAMA_P;
      RETURN 0;
   END TRY 
   BEGIN CATCH
      DECLARE @ErorMesg NVARCHAR(MAX);
      SELECT @ErorMesg = ERROR_MESSAGE();
      RAISERROR(@ErorMesg, 16, 1);
      ROLLBACK TRAN T_UPD_CAMA_P;
      RETURN -1;
   END CATCH;
END;
GO
