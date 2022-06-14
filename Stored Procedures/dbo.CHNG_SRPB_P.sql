SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CHNG_SRPB_P]
	-- Add the parameters for the stored procedure here
	@X XML
AS
BEGIN
   BEGIN TRY
   BEGIN TRAN CHNG_SRPB_T
	   DECLARE @ServFileNo  BIGINT
	          ,@ActnType VARCHAR(3)
	          ,@CntyCode VARCHAR(3)
	          ,@PrvnCode VARCHAR(3)
	          ,@RegnCode VARCHAR(3)
	          ,@CompCode BIGINT
	          ,@CordX FLOAT
	          ,@CordY FLOAT;
   	
	   SELECT @ServFileNo = @X.query('//Service').value('(Service/@fileno)[1]', 'BIGINT')
	         ,@ActnType = @X.query('//Service').value('(Service/@actntype)[1]', 'VARCHAR(3)');
   	
   	DECLARE @XP XML;
   	
   	IF @ActnType = '001' -- CordX, CordY
   	BEGIN
   	   SELECT @CordX = @X.query('//Service').value('(Service/@cordx)[1]', 'FLOAT')
	            ,@CordY = @X.query('//Service').value('(Service/@cordy)[1]', 'FLOAT');
         
         -- اگر تغییری در آدرس جغرافیایی اتفاق نیوفتاده باشد
         IF EXISTS(
            SELECT *
              FROM dbo.Service
             WHERE FILE_NO = @ServFileNo
               AND CORD_X_DNRM = @CordX
               AND CORD_Y_DNRM = @CordY
         )
         BEGIN
            GOTO L$End;            
         END
         
		   SELECT @XP = (
            SELECT 0 AS '@rqid'
                  ,'002' AS '@rqtpcode'
                  ,'004' AS '@rqttcode'
                  ,S.REGN_PRVN_CNTY_CODE AS '@cntycode'
                  ,s.REGN_PRVN_CODE AS '@prvncode'
                  ,s.REGN_CODE AS '@regncode'
                  ,s.FILE_NO AS 'Service/@fileno'
                  ,S.SRPB_TYPE_DNRM AS 'Service/Service_Public/Type'	            
                  ,s.FRST_NAME_DNRM AS 'Service/Service_Public/Frst_Name'
                  ,s.LAST_NAME_DNRM AS 'Service/Service_Public/Last_Name'
                  ,s.EMAL_ADRS_DNRM AS 'Service/Service_Public/Emal_Adrs'
                  ,s.CELL_PHON_DNRM AS 'Service/Service_Public/Cell_Phon'
                  ,s.COMP_CODE_DNRM AS 'Service/Service_Public/Comp_Code'
                  ,s.BTRF_CODE_DNRM AS 'Service/Service_Public/Btrf_Code'
                  ,s.TRFD_CODE_DNRM AS 'Service/Service_Public/Trfd_Code'
                  ,@CordX AS 'Service/Service_Public/Cord_X'
                  ,@CordY AS 'Service/Service_Public/Cord_Y'
              FROM dbo.SERVICE S
             WHERE S.FILE_NO = @ServFileNo
             FOR XML PATH('Request'), ROOT('Process')
         );
         

   	END
   	ELSE IF @ActnType = '002' -- Comp_Code
   	BEGIN
   	   SELECT @CompCode = @X.query('//Service').value('(Service/@compcode)[1]', 'BIGINT');
   	   SELECT @CntyCode = REGN_PRVN_CNTY_CODE
   	         ,@PrvnCode = REGN_PRVN_CODE
   	         ,@RegnCode = REGN_CODE
   	     FROM dbo.Company
   	    WHERE CODE = @CompCode;         
         -- اگر تغییری در نوع شرکت اتفاق نیوفتاده باشد
         IF EXISTS(
            SELECT *
              FROM dbo.Service
             WHERE FILE_NO = @ServFileNo
               AND COMP_CODE_DNRM = @CompCode
         )
         BEGIN
            GOTO L$End;            
         END
         
         
		   SELECT @XP = (
            SELECT 0 AS '@rqid'
                  ,'002' AS '@rqtpcode'
                  ,'004' AS '@rqttcode'
                  ,@CntyCode AS '@cntycode'
                  ,@PrvnCode AS '@prvncode'
                  ,@RegnCode AS '@regncode'
                  ,s.FILE_NO AS 'Service/@fileno'
                  ,S.SRPB_TYPE_DNRM AS 'Service/Service_Public/Type'	            
                  ,s.FRST_NAME_DNRM AS 'Service/Service_Public/Frst_Name'
                  ,s.LAST_NAME_DNRM AS 'Service/Service_Public/Last_Name'
                  ,s.EMAL_ADRS_DNRM AS 'Service/Service_Public/Emal_Adrs'
                  ,s.CELL_PHON_DNRM AS 'Service/Service_Public/Cell_Phon'
                  --,s.COMP_CODE_DNRM AS 'Service/Service_Public/Comp_Code'
                  ,s.BTRF_CODE_DNRM AS 'Service/Service_Public/Btrf_Code'
                  ,s.TRFD_CODE_DNRM AS 'Service/Service_Public/Trfd_Code'
                  ,@CompCode AS 'Service/Service_Public/Comp_Code'
              FROM dbo.SERVICE S
             WHERE S.FILE_NO = @ServFileNo
             FOR XML PATH('Request'), ROOT('Process')
         );         
   	END

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

      COMMIT TRAN CHNG_SRPB_T;
      L$End:
      RETURN 0;
   END TRY
   BEGIN CATCH
      DECLARE @ErrorMessage NVARCHAR(MAX);
      SET @ErrorMessage = ERROR_MESSAGE();
      RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN CHNG_SRPB_T;
      RETURN -1;
   END CATCH  	
END
GO
