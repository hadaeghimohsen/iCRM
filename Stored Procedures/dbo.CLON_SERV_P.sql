SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CLON_SERV_P]
	-- Add the parameters for the stored procedure here
	@X XML
AS
BEGIN
   BEGIN TRY
   BEGIN TRAN CLON_SERV_T
	   DECLARE @ServFileNo  BIGINT
	          ,@FrstName NVARCHAR(250)
	          ,@LastName NVARCHAR(250)
	          ,@CellPhon VARCHAR(11)
	          ,@TellPhon VARCHAR(11)
	          ,@EmalAdrs VARCHAR(250)
	          ,@PostAdrs NVARCHAR(1000)
	          ,@CompCode BIGINT
	          ,@CntyCode VARCHAR(3) = NULL
	          ,@PrvnCode VARCHAR(3) = NULL
	          ,@RegnCode VARCHAR(3) = NULL;
   	
	   SELECT @ServFileNo = @X.query('//Service').value('(Service/@fileno)[1]', 'BIGINT')
	         ,@FrstName = @X.query('//Service').value('(Service/@frstname)[1]', 'NVARCHAR(250)')
	         ,@LastName = @X.query('//Service').value('(Service/@lastname)[1]', 'NVARCHAR(250)')
	         ,@CellPhon = @X.query('//Service').value('(Service/@cellphon)[1]', 'VARCHAR(11)')
	         ,@TellPhon = @X.query('//Service').value('(Service/@tellphon)[1]', 'VARCHAR(11)')
	         ,@EmalAdrs = @X.query('//Service').value('(Service/@emaladrs)[1]', 'VARCHAR(250)')
	         ,@PostAdrs = @X.query('//Service').value('(Service/@postadrs)[1]', 'NVARCHAR(1000)')
	         ,@CompCode = @X.query('//Service').value('(Service/@compcode)[1]', 'BIGINT');
   	
	   IF @CompCode IS NULL OR @CompCode = 0
	      SET @CompCode = NULL;
	   ELSE
	   BEGIN
	      SELECT @CntyCode = REGN_PRVN_CNTY_CODE
	            ,@PrvnCode = REGN_PRVN_CODE
	            ,@RegnCode = REGN_CODE
	        FROM dbo.Company
	       WHERE CODE = @CompCode;
	   END 
	   DECLARE @XP XML;
   	
	   SELECT @XP = (
	      SELECT 0 AS '@rqid'
	            ,'001' AS '@rqtpcode'
	            ,'004' AS '@rqttcode'
	            ,ISNULL(@CntyCode, REGN_PRVN_CNTY_CODE) AS '@cntycode'
	            ,ISNULL(@PrvnCode, REGN_PRVN_CODE) AS '@prvncode'
	            ,ISNULL(@RegnCode, REGN_CODE) AS '@regncode'
	            ,0 AS 'Service/@fileno'
	            ,ISNULL(@CompCode, COMP_CODE_DNRM) AS 'Service/Service_Public/Comp_Code'
	            ,@FrstName AS 'Service/Service_Public/Frst_Name'
	            ,@LastName AS 'Service/Service_Public/Last_Name'
	            ,SUNT_BUNT_DEPT_ORGN_CODE_DNRM AS 'Service/Service_Public/Sunt_Bunt_Dept_Orgn_Code'
	            ,SUNT_BUNT_DEPT_CODE_DNRM AS 'Service/Service_Public/Sunt_Bunt_Dept_Code'
	            ,SUNT_BUNT_CODE_DNRM AS 'Service/Service_Public/Sunt_Bunt_Code'
	            ,SUNT_CODE_DNRM AS 'Service/Service_Public/Sunt_Code'
	            ,ISCP_ISCA_ISCG_CODE_DNRM AS 'Service/Service_Public/Iscp_Isca_Iscg_Code'
	            ,ISCP_ISCA_CODE_DNRM AS 'Service/Service_Public/Iscp_Isca_Code'
	            ,ISCP_CODE_DNRM AS 'Service/Service_Public/Iscp_Code'
	            ,SRPB_TYPE_DNRM AS 'Service/Service_Public/Type'
	            ,SERV_STAG_CODE AS 'Service/Service_Public/Serv_Stag_Code'
	            ,@EmalAdrs AS 'Service/Service_Public/Emal_Adrs'
	            ,@PostAdrs AS 'Service/Service_Public/Post_Adrs'
	            ,@CellPhon AS 'Service/Service_Public/Cell_Phon'
	            ,@TellPhon AS 'Service/Service_Public/Tell_Phon'
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
            AND R.RQTP_CODE = '001'
            AND R.RQTT_CODE = '004'
            AND r.RQST_STAT = '001'
            AND CAST(r.RQST_DATE AS DATE) = CAST(GETDATE() AS DATE)
            ORDER BY r.RQST_DATE DESC 
            FOR XML PATH('Request'), ROOT('Process')         
      );
      
      EXEC dbo.ADM_ASAV_F @X = @XP -- xml
      COMMIT TRAN CLON_SERV_T;
      RETURN 0;
   END TRY
   BEGIN CATCH
      DECLARE @ErrorMessage NVARCHAR(MAX);
      SET @ErrorMessage = ERROR_MESSAGE();
      RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN CLON_SERV_T;
      RETURN -1;
   END CATCH  	
END
GO
