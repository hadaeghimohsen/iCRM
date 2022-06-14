SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[DEL_MKLT_P]
	-- Add the parameters for the stored procedure here
	@Mlid BIGINT
AS
BEGIN
	BEGIN TRY
	   BEGIN TRAN T_DEL_MKLT_P	   
	   
	   DELETE dbo.Marketing_List
	    WHERE MLID = @Mlid;
	   
	   COMMIT TRAN T_DEL_MKLT_P;
	   RETURN 0;
	END TRY
	BEGIN CATCH 
	   DECLARE @ErorMesg NVARCHAR(Max);
	   SET @ErorMesg = ERROR_MESSAGE();
      RAISERROR ( @ErorMesg, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN T_DEL_MKLT_P;
      RETURN -1;
	END CATCH;
END
GO
