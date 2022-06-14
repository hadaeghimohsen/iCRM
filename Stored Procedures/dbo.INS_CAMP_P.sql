SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[INS_CAMP_P]
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
      BEGIN TRAN T_INS_CAMP_P;
      
      IF EXISTS(SELECT * FROM dbo.Campaign WHERE OWNR_CODE = @Ownr_Code AND NAME = @Name)
         RAISERROR (N'این عنوان تبلیغات قبلا برای شما تعریف شده، لطفا عنوان تبلیغات خود را اصلاح کنید', 16, 1);
      
      INSERT INTO dbo.Campaign
              ( OWNR_CODE ,
                CMID ,
                ESTM_REVN_AMNT ,
                STAT ,
                TEMP ,
                NAME ,
                TRCB_TCID ,
                TYPE ,
                EXPT_RESP ,
                PROP_STRT_DATE ,
                PROP_END_DATE ,
                ACTL_STRT_DATE ,
                ACTL_END_DATE ,
                OFER_DESC ,
                ACTV_COST_AMNT ,
                MISC_COST_AMNT ,
                ALOC_BUDG_AMNT ,
                TOTL_COST_AMNT ,
                CMNT 
              )
      VALUES  ( @Ownr_Code, -- OWNR_CODE - bigint
                @Cmid , -- CMID - bigint
                @Estm_Revn_Amnt , -- ESTM_REVN_AMNT - bigint
                @Stat , -- STAT - varchar(3)
                @Temp , -- TEMP - varchar(3)
                @Name , -- NAME - nvarchar(250)
                @Trcb_Tcid , -- TRCB_TCID - bigint
                @Type , -- TYPE - varchar(3)
                @Expt_Resp , -- EXPT_RESP - smallint
                @Prop_Strt_Date , -- PROP_STRT_DATE - date
                @Prop_End_Date , -- PROP_END_DATE - date
                @Actl_Strt_Date , -- ACTL_STRT_DATE - date
                @Actl_End_Date , -- ACTL_END_DATE - date
                @Ofer_Desc , -- OFER_DESC - nvarchar(4000)
                @Actv_Cost_Amnt , -- ACTV_COST_AMNT - bigint
                @Misc_Cost_Amnt , -- MISC_COST_AMNT - bigint
                @Aloc_Budg_Amnt , -- ALOC_BUDG_AMNT - bigint
                @Totl_Cost_Amnt , -- TOTL_COST_AMNT - bigint
                @Cmnt  -- CMNT - nvarchar(4000)
              );
      
      COMMIT TRAN T_INS_CAMP_P;
      RETURN 0;
   END TRY
   BEGIN CATCH 
      DECLARE @ErorMesg NVARCHAR(Max);
	   SET @ErorMesg = ERROR_MESSAGE();
      RAISERROR ( @ErorMesg, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN T_INS_CAMP_P;
      RETURN -1;
   END CATCH;
END;

   
GO
