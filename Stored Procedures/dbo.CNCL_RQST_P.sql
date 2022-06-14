SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CNCL_RQST_P]
	-- Add the parameters for the stored procedure here
	@X XML
AS
   /*
   <Process>
      <Request rqid="" rqtp="" />
   </Process>
   */
BEGIN
   BEGIN TRY
   BEGIN TRAN CNCL_RQST_P_TRAN
	   DECLARE @Rqid BIGINT
	          ,@RqtpCode VARCHAR(3);
   	       
      SELECT @Rqid     = @X.query('//Request').value('(Request/@rqid)[1]'    , 'BIGINT');
            
      
      --DECLARE @AP BIT
      --       ,@AccessString VARCHAR(250);
      --SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>61</Privilege><Sub_Sys>11</Sub_Sys></AP>';	
      --EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
      --IF @AP = 0 
      --BEGIN
      --   RAISERROR ( N'خطا - عدم دسترسی به ردیف 61 سطوح امینتی', -- Message text.
      --            16, -- Severity.
      --            1 -- State.
      --            );
      --   RETURN;
      --END
      
      UPDATE dbo.Request
         SET RQST_STAT = '003'
       WHERE RQID = @Rqid;
      
      DECLARE @ProjRqstRqid BIGINT;
      SELECT @ProjRqstRqid = PROJ_RQST_RQID
        FROM dbo.Request
       WHERE RQID = @Rqid;
      
      UPDATE dbo.Request
         SET RQST_STAT = '003' 
       WHERE RQID = @ProjRqstRqid;      
      
   COMMIT TRAN CNCL_RQST_TRAN
   END TRY
   BEGIN CATCH
      DECLARE @ErrorMessage NVARCHAR(MAX);
      SET @ErrorMessage = ERROR_MESSAGE();
      RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN CNCL_RQST_P_TRAN;
   END CATCH
END
GO
