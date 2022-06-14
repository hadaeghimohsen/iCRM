SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[OPR_DSAV_F]
	-- Add the parameters for the stored procedure here
	@X XML
AS
BEGIN
	DECLARE @ErrorMessage NVARCHAR(MAX);
	BEGIN TRAN OPR_DSAV_T;
	BEGIN TRY
	   DECLARE @Rqid     BIGINT;
	   
	   SELECT @Rqid     = @X.query('//Payment').value('(Payment/@rqstrqid)[1]', 'BIGINT');

      UPDATE Request
         SET RQST_STAT = '002'
       WHERE RQID = @Rqid
         AND RQST_STAT = '001';
         
      COMMIT TRAN OPR_DSAV_T;
   END TRY
   BEGIN CATCH
      SET @ErrorMessage = ERROR_MESSAGE();
      RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN OPR_DSAV_T;
   END CATCH;   
END
GO
