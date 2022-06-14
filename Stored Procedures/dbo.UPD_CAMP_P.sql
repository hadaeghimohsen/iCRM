SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[UPD_CAMP_P]
   @Cmid BIGINT,
   @Ownr_Code BIGINT,
   @Estm_Revn_Amnt BIGINT,
   @Stat VARCHAR(3),
   @Temp VARCHAR(3),
   @Name NVARCHAR(250),
   @Trcb_Tcid BIGINT,
   @Type VARCHAR(3),
   @Expt_Resp SMALLINT,
   @Prop_Strt_Date DATE,
   @Prop_End_Date DATE,
   @Actl_Strt_Date DATE,
   @Actl_End_Date DATE,
   @Ofer_Desc NVARCHAR(4000),
   @Actv_Cost_Amnt BIGINT,
   @Misc_Cost_Amnt BIGINT,
   @Aloc_Budg_Amnt BIGINT,
   @Totl_Cost_Amnt BIGINT,
   @Cmnt NVARCHAR(4000)
AS 
BEGIN
   BEGIN TRY
      BEGIN TRAN T_UPD_CAMP_P;
      
      IF EXISTS(SELECT * FROM dbo.Campaign WHERE OWNR_CODE = @Ownr_Code AND NAME = @Name AND CMID != @Cmid)
         RAISERROR (N'این عنوان تبلیغات قبلا برای شما تعریف شده، لطفا عنوان تبلیغات خود را اصلاح کنید', 16, 1);
      
      UPDATE dbo.Campaign
         SET OWNR_CODE = @Ownr_Code
            ,ESTM_REVN_AMNT = @Estm_Revn_Amnt
            ,STAT = @Stat
            ,TEMP = @Temp
            ,NAME = @Name
            ,TRCB_TCID = @Trcb_Tcid
            ,TYPE = @Type
            ,EXPT_RESP = @Expt_Resp
            ,PROP_STRT_DATE = @Prop_Strt_Date
            ,PROP_END_DATE = @Prop_End_Date
            ,ACTL_STRT_DATE = @Actl_Strt_Date
            ,ACTL_END_DATE = @Actl_End_Date
            ,OFER_DESC = @Ofer_Desc
            ,ACTV_COST_AMNT = @Actv_Cost_Amnt
            ,MISC_COST_AMNT = @Misc_Cost_Amnt
            ,ALOC_BUDG_AMNT = @Aloc_Budg_Amnt
            ,TOTL_COST_AMNT = @Totl_Cost_Amnt
            ,CMNT = @Cmnt
       WHERE CMID = @Cmid;
      
      COMMIT TRAN T_UPD_CAMP_P;
      RETURN 0;
   END TRY
   BEGIN CATCH 
      DECLARE @ErorMesg NVARCHAR(Max);
	   SET @ErorMesg = ERROR_MESSAGE();
      RAISERROR ( @ErorMesg, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN T_UPD_CAMP_P;
      RETURN -1;
   END CATCH;
END;

   
GO
