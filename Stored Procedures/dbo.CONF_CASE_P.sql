SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CONF_CASE_P]
   @X XML
AS
BEGIN
   BEGIN TRY
      BEGIN TRANSACTION T_CONF_CASE_P;

      DECLARE @Rqid BIGINT ,
              @Colr VARCHAR(30) ,
              @FileNo BIGINT ,
              @Stat VARCHAR(3),
              @RespDesc NVARCHAR(250),
              @TotlMinTime INT,
              @RmrkDesc NVARCHAR(500),
              @Csid BIGINT;
          
      SELECT  @Rqid = @X.query('Case').value('(Case/@rqid)[1]', 'BIGINT') ,
              @Csid = @X.query('Case').value('(Case/@csid)[1]', 'BIGINT') ,
              @Colr = @X.query('Case').value('(Case/@colr)[1]', 'VARCHAR(30)') ,
              @Stat = @X.query('Case').value('(Case/@stat)[1]', 'VARCHAR(3)') ,
              @RespDesc = @X.query('Case').value('(Case/@respdesc)[1]', 'NVARCHAR(250)'),
              @TotlMinTime = @X.query('Case').value('(Case/@totlmintime)[1]', 'INT'),
              @RmrkDesc = @X.query('Case').value('(Case/@rmrkdesc)[1]', 'NVARCHAR(500)');

      SELECT  @FileNo = SERV_FILE_NO
      FROM    dbo.Request_Row
      WHERE   RQST_RQID = @Rqid;
      
      UPDATE dbo.[Case]
         SET STAT = @Stat
            ,RESP_DESC = @RespDesc
            ,TOTL_MIN_TIME = @TotlMinTime
            ,RMRK_DESC = @RmrkDesc
       WHERE CSID = @Csid;
      
      UPDATE dbo.Request
         SET RQST_STAT = '002'
            ,COLR = @Colr
       WHERE RQID = @Rqid;
      
      COMMIT TRANSACTION T_CONF_CASE_P;
      RETURN 0;
   END TRY
   BEGIN CATCH
      DECLARE @ErrorMessage NVARCHAR(MAX);
      SET @ErrorMessage = ERROR_MESSAGE();
      RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN T_CONF_CASE_P;
      RETURN -1;
   END CATCH;
END;
GO
