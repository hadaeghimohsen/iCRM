SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CHNG_SRTP_P]
	-- Add the parameters for the stored procedure here
	@X XML
AS
BEGIN
   BEGIN TRY
   BEGIN TRAN CHNG_SRTP_T
	   DECLARE @ServFileNo  BIGINT
	          ,@Type VARCHAR(3)
	          ,@FrstName NVARCHAR(250)
	          ,@LastName NVARCHAR(250)
	          ,@EmalAddr VARCHAR(250)
	          ,@CellPhon VARCHAR(11)
	          ,@CompCode BIGINT
	          ,@BtrfCode BIGINT
	          ,@TrfdCode BIGINT;
   	
	   SELECT @ServFileNo = @X.query('//Service').value('(Service/@fileno)[1]', 'BIGINT')
	         ,@Type = @X.query('//Service').value('(Service/@type)[1]', 'VARCHAR(3)')
	         ,@FrstName = @X.query('//Service').value('(Service/@frstname)[1]', 'NVARCHAR(250)')
	         ,@LastName = @X.query('//Service').value('(Service/@lastname)[1]', 'NVARCHAR(250)')
	         ,@EmalAddr = @X.query('//Service').value('(Service/@emaladdr)[1]', 'VARCHAR(250)')
	         ,@CellPhon = @X.query('//Service').value('(Service/@cellphon)[1]', 'VARCHAR(11)')
	         ,@CompCode = @X.query('//Service').value('(Service/@compcode)[1]', 'BIGINT')
	         ,@BtrfCode = @X.query('//Service').value('(Service/@btrfcode)[1]', 'BIGINT')
	         ,@TrfdCode = @X.query('//Service').value('(Service/@trfdcode)[1]', 'BIGINT');
   	
	   DECLARE @XP XML;
   	
	   SELECT @XP = (
	      SELECT 0 AS '@rqid'
	            ,'002' AS '@rqtpcode'
	            ,'004' AS '@rqttcode'
	            ,S.REGN_PRVN_CNTY_CODE AS '@cntycode'
	            ,REGN_PRVN_CODE AS '@prvncode'
	            ,REGN_CODE AS '@regncode'
	            ,FILE_NO AS 'Service/@fileno'
	            ,@Type AS 'Service/Service_Public/Type'	            
	            ,@FrstName AS 'Service/Service_Public/Frst_Name'
	            ,@LastName AS 'Service/Service_Public/Last_Name'
	            ,@EmalAddr AS 'Service/Service_Public/Emal_Adrs'
	            ,@CellPhon AS 'Service/Service_Public/Cell_Phon'
	            ,@CompCode AS 'Service/Service_Public/Comp_Code'
	            ,@BtrfCode AS 'Service/Service_Public/Btrf_Code'
	            ,@TrfdCode AS 'Service/Service_Public/Trfd_Code'
	        FROM dbo.SERVICE S
	       WHERE S.FILE_NO = @ServFileNo
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
            AND R.RQTP_CODE = '002'
            AND R.RQTT_CODE = '004'
            AND r.RQST_STAT = '001'
            AND CAST(r.RQST_DATE AS DATE) = CAST(GETDATE() AS DATE)
            AND rr.SERV_FILE_NO = @ServFileNo
            ORDER BY r.RQST_DATE DESC 
            FOR XML PATH('Request'), ROOT('Process')         
      );
      
      EXEC dbo.ADM_ASAV_F @X = @XP -- xml
      COMMIT TRAN CHNG_SRTP_T;
      RETURN 0;
   END TRY
   BEGIN CATCH
      DECLARE @ErrorMessage NVARCHAR(MAX);
      SET @ErrorMessage = ERROR_MESSAGE();
      RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN CHNG_SRTP_T;
      RETURN -1;
   END CATCH  	
END
GO
