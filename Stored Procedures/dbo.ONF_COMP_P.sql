SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ONF_COMP_P]
	-- Add the parameters for the stored procedure here
	@X XML
AS
BEGIN
   BEGIN TRY
   BEGIN TRAN ONF_COMP_T
	   DECLARE @CompCode  BIGINT;          
   	
	   SELECT @CompCode = @X.query('//Company').value('(Company/@code)[1]', 'BIGINT')
   	
	   UPDATE dbo.Company
	      SET RECD_STAT = CASE RECD_STAT 
	                           WHEN '001' THEN '002'
	                           WHEN '002' THEN '001'
	                      END
       WHERE Code = @CompCode;
      COMMIT TRAN ONF_COMP_T;
      RETURN 0;
   END TRY
   BEGIN CATCH
      DECLARE @ErrorMessage NVARCHAR(MAX);
      SET @ErrorMessage = ERROR_MESSAGE();
      RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN ONF_COMP_T;
      RETURN -1;
   END CATCH  	
END
GO
