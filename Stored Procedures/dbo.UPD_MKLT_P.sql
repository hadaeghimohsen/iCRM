SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPD_MKLT_P]
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
	   BEGIN TRAN T_UPD_MKLT_P
	   
	   IF EXISTS(SELECT * FROM dbo.Marketing_List WHERE OWNR_CODE = @Ownr_Code AND NAME = @Name AND MLID != @Mlid)
	      RAISERROR (N'این لیست قبلا برای شما تعریف شده، لطفا نام لیست خود را اصلاح کنید', 16, 1);
	   
	   UPDATE dbo.Marketing_List
	      SET OWNR_CODE = @Ownr_Code
	         ,LOCK_STAT = @Lock_Stat
	         ,NAME = @Name
	         ,LIST_TYPE = @List_Type
	         ,PRPS_DESC = @Prps_Desc
	         ,TRGT = @Trgt
	         ,SORC = @Sorc
	         ,TRCB_TCID = @Trcb_Tcid
	         ,COST_AMNT = @Cost_Amnt
	         ,CMNT = @Cmnt
	    WHERE MLID = @Mlid;
	   
	   COMMIT TRAN T_UPD_MKLT_P;
	   RETURN 0;
	END TRY
	BEGIN CATCH 
	   DECLARE @ErorMesg NVARCHAR(Max);
	   SET @ErorMesg = ERROR_MESSAGE();
      RAISERROR ( @ErorMesg, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN T_UPD_MKLT_P;
      RETURN -1;
	END CATCH;
END
GO
