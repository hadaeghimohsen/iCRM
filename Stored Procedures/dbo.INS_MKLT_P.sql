SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_MKLT_P]
	-- Add the parameters for the stored procedure here
	@Mlid BIGINT,
	@Ownr_Code BIGINT,
	@Lock_Stat VARCHAR(3),
	@Name NVARCHAR(250),
	@List_Type VARCHAR(3),
	@Prps_Desc NVARCHAR(100),
	@Trgt VARCHAR(3),
	@Sorc NVARCHAR(100),
	@Trcb_Tcid BIGINT,
	@Cost_Amnt BIGINT,
	@Cmnt NVARCHAR(500)
AS
BEGIN
	BEGIN TRY
	   BEGIN TRAN T_INS_MKLT_P
	   
	   IF EXISTS(SELECT *FROM dbo.Marketing_List WHERE OWNR_CODE = @Ownr_Code AND NAME = @Name)	   
	      RAISERROR (N'این لیست قبلا برای شما تعریف شده، لطفا نام لیست خود را اصلاح کنید', 16, 1);
	   
	   INSERT INTO dbo.Marketing_List
	           ( MLID ,
	             OWNR_CODE ,
	             LOCK_STAT ,
	             NAME ,
	             LIST_TYPE ,
	             PRPS_DESC ,
	             TRGT ,
	             SORC ,
	             TRCB_TCID ,
	             COST_AMNT ,
	             CMNT 
	           )
	   VALUES  ( @Mlid , -- MLID - bigint
	             @Ownr_Code , -- OWNR_CODE - bigint
	             @Lock_Stat , -- LOCK_STAT - varchar(3)
	             @Name , -- NAME - nvarchar(250)
	             @List_Type , -- LIST_TYPE - varchar(3)
	             @Prps_Desc , -- PRPS_DESC - nvarchar(100)
	             @Trgt , -- TRGT - varchar(3)
	             @Sorc , -- SORC - nvarchar(100)
	             @Trcb_Tcid , -- TRCB_TCID - bigint
	             @Cost_Amnt , -- COST_AMNT - bigint
	             @Cmnt  -- CMNT - nvarchar(500)
	           );
	   
	   COMMIT TRAN T_INS_MKLT_P;
	   RETURN 0;
	END TRY
	BEGIN CATCH 
	   DECLARE @ErorMesg NVARCHAR(Max);
	   SET @ErorMesg = ERROR_MESSAGE();
      RAISERROR ( @ErorMesg, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN T_INS_MKLT_P;
      RETURN -1;
	END CATCH;
END
GO
