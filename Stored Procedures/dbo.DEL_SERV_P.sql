SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[DEL_SERV_P]
	-- Add the parameters for the stored procedure here
	@X XML
AS
BEGIN
   BEGIN TRY
   BEGIN TRAN DEL_SERV_T
	   DECLARE @ServFileNo  BIGINT;
	          
   	
	   SELECT @ServFileNo = @X.query('//Service').value('(Service/@fileno)[1]', 'BIGINT')
   	
	   DECLARE @XP XML;
   	
	   SELECT @XP = (
	      SELECT 0 AS '@rqid'
	            ,'003' AS '@rqtpcode'
	            ,'004' AS '@rqttcode'
	            ,REGN_PRVN_CNTY_CODE AS '@cntycode'
	            ,REGN_PRVN_CODE AS '@prvncode'
	            ,REGN_CODE AS '@regncode'
	            ,FILE_NO AS 'Service/@fileno'
	            ,'001' AS 'Service/Service_Public/Onof_Tag'
	            ,SRPB_TYPE_DNRM AS 'Service/Service_Public/Type'
	        FROM dbo.Service
	       WHERE FILE_NO = @ServFileNo
	       FOR XML PATH('Request'), ROOT('Process')
	   );
      
      EXEC dbo.ADM_ARQT_F @X = @XP -- xml
      
      SELECT @XP = (
         SELECT TOP 1 
                R.RQID AS '@rqid'
               ,rr.RWNO AS 'Request_Row/@rwno'
               ,rr.SERV_FILE_NO AS 'Request_Row/@servfileno'
           FROM dbo.Request r, dbo.Request_Row rr
          WHERE r.RQID = rr.RQST_RQID
            AND R.CRET_BY = UPPER(SUSER_NAME())
            AND R.RQTP_CODE = '003'
            AND R.RQTT_CODE = '004'
            AND r.RQST_STAT = '001'
            AND CAST(r.RQST_DATE AS DATE) = CAST(GETDATE() AS DATE)
            AND rr.SERV_FILE_NO = @ServFileNo
            ORDER BY r.RQST_DATE DESC 
            FOR XML PATH('Request'), ROOT('Process')         
      );
      
      EXEC dbo.ADM_ASAV_F @X = @XP -- xml
      COMMIT TRAN DEL_SERV_T;
      RETURN 0;
   END TRY
   BEGIN CATCH
      DECLARE @ErrorMessage NVARCHAR(MAX);
      SET @ErrorMessage = ERROR_MESSAGE();
      RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN DEL_SERV_T;
      RETURN -1;
   END CATCH  	
END
GO
