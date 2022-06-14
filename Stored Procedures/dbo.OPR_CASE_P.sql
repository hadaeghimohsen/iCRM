SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[OPR_CASE_P]
   @X XML
AS
BEGIN
   BEGIN TRY
      BEGIN TRANSACTION T_OPR_CASE_P;
      DECLARE @Rqid     BIGINT,
              @RqstRqid BIGINT,
              @ProjRqstRqid BIGINT,
              @RqtpCode VARCHAR(3) = '015',
              @RqttCode VARCHAR(3) = '004',
              @RegnCode VARCHAR(3),
              @PrvnCode VARCHAR(3),
              @CntyCode VARCHAR(3),
              @CaseType VARCHAR(30),
   	        @FileNo BIGINT,
   	        @CompCode BIGINT,
   	        @OwnrCode BIGINT;
   	        
      SELECT @FileNo = @X.query('//Request_Row').value('(Request_Row/@servfileno)[1]', 'BIGINT')
            ,@CompCode = @X.query('//Request_Row').value('(Request_Row/@compcode)[1]', 'BIGINT')
            ,@OwnrCode = @X.query('//Case').value('(Case/@ownrcode)[1]', 'BIGINT');

      IF @OwnrCode = 0 OR @OwnrCode IS NULL
         SELECT @OwnrCode = CODE
           FROM dbo.Job_Personnel
          WHERE STAT = '002'
            AND [USER_NAME] = UPPER(SUSER_NAME());
      
      SELECT @CntyCode = REGN_PRVN_CNTY_CODE
            ,@PrvnCode = REGN_PRVN_CODE
            ,@RegnCode = REGN_CODE
        FROM dbo.Company
       WHERE CODE = @CompCode;
      
	   SELECT @Rqid     = @X.query('//Request').value('(Request/@rqid)[1]'    , 'BIGINT')
	         ,@RqstRqid = @X.query('//Request').value('(Request/@rqstrqid)[1]'    , 'BIGINT')
	         ,@ProjRqstRqid = @X.query('//Request').value('(Request/@projrqstrqid)[1]'    , 'BIGINT')
	         --,@RegnCode = @X.query('//Request').value('(Request/@regncode)[1]', 'VARCHAR(3)')
	         --,@PrvnCode = @X.query('//Request').value('(Request/@prvncode)[1]', 'VARCHAR(3)')
	         --,@CntyCode = @X.query('//Request').value('(Request/@cntycode)[1]', 'VARCHAR(3)')
	         ,@CaseType = @X.query('//Request').value('(Request/@casetype)[1]', 'VARCHAR(30)');
      
      IF ( @RegnCode IS NULL OR @PrvnCode IS NULL )
         SELECT TOP 1 @RegnCode = CODE
                     ,@PrvnCode = PRVN_CODE
                     ,@CntyCode = PRVN_CNTY_CODE
           FROM Region;
      
      IF @ProjRqstRqid = 0 SET @ProjRqstRqid = NULL;
      
      -- ثبت شماره درخواست 
      IF @Rqid IS NULL OR @Rqid = 0
      BEGIN
         IF @RqstRqid IS NULL OR @RqstRqid = 0
            SET @RqstRqid = NULL;
            
         EXEC dbo.INS_RQST_P
            @CntyCode,
            @PrvnCode,
            @RegnCode,
            @RqstRqid,
            @RqtpCode,
            @RqttCode,
            NULL,
            NULL,
            NULL,
            @Rqid OUT; 
         
         UPDATE dbo.Request
            SET COLR = 'Gold'
               ,PROJ_RQST_RQID = @ProjRqstRqid
          WHERE RQID = @Rqid;        
      END      
      
      -- ثبت ردیف درخواست 
      DECLARE @RqroRwno SMALLINT;
      SELECT @RqroRwno = Rwno
        FROM Request_Row
       WHERE RQST_RQID = @Rqid;         
           
      IF @RqroRwno IS NULL
      BEGIN
         EXEC INS_RQRO_P
            @Rqid
           ,@FileNo
           ,@RqroRwno OUT;           
      END
      
      -- بروزرسانی اطلاعات ردیف درخواست برای شرکت
      UPDATE dbo.Request_Row
         SET COMP_CODE = @CompCode
            ,SERV_FILE_NO = @FileNo
       WHERE RQST_RQID = @Rqid;


      DECLARE @SrpbRwno INT,
              @Titl NVARCHAR(250),
              @SubjApbsCode BIGINT,
              @OrgnType VARCHAR(3),
              @PrioType VARCHAR(3),
              @Stat VARCHAR(3),
              @Cmnt NVARCHAR(500),
              @Type VARCHAR(3),
              @PrntCaseCsid BIGINT,
              @EsclType VARCHAR(3),
              @EsclDate DATETIME,
              @FlowUpDate DATETIME,
              @SentFrstResp VARCHAR(3),
              @SerlNumb NVARCHAR(50),
              @ServLevl VARCHAR(3);
      
      SELECT @Titl = @X.query('//Case').value('(Case/@titl)[1]','NVARCHAR(250)')
            ,@SubjApbsCode = @X.query('//Case').value('(Case/@subjapbscode)[1]','BIGINT')
            ,@OrgnType = @X.query('//Case').value('(Case/@orgntype)[1]','VARCHAR(3)')
            ,@PrioType = @X.query('//Case').value('(Case/@priotype)[1]','VARCHAR(3)')
            ,@Stat = @X.query('//Case').value('(Case/@stat)[1]','VARCHAR(3)')
            ,@Cmnt = @X.query('//Case').value('(Case/@cmnt)[1]','NVARCHAR(500)')
            ,@Type = @X.query('//Case').value('(Case/@type)[1]','VARCHAR(3)')
            ,@PrntCaseCsid = @X.query('//Case').value('(Case/@prntcasecsid)[1]','BIGINT')
            ,@EsclType = @X.query('//Case').value('(Case/@escltype)[1]','VARCHAR(3)')
            ,@EsclDate = @X.query('//Case').value('(Case/@escldate)[1]','DATETIME')
            ,@FlowUpDate = @X.query('//Case').value('(Case/@flowupdate)[1]','DATETIME')
            ,@SentFrstResp = @X.query('//Case').value('(Case/@sentfrstresp)[1]','VARCHAR(3)')
            ,@SerlNumb = @X.query('//Case').value('(Case/@serlnumb)[1]','NVARCHAR(50)')
            ,@ServLevl = @X.query('//Case').value('(Case/@servlevl)[1]','VARCHAR(3)');
      
      IF @SubjApbsCode = 0 SET @SubjApbsCode = NULL;
      IF @PrntCaseCsid = 0 SET @PrntCaseCsid = NULL;
      
      SELECT @SrpbRwno = SRPB_RWNO_DNRM
        FROM dbo.Service
       WHERE FILE_NO = @FileNo;
      
      IF @Stat = '' OR @Stat IS NULL SET @Stat = '008';
      
      IF NOT EXISTS(
         SELECT *
           FROM dbo.[Case]
          WHERE RQRO_RQST_RQID = @Rqid
            AND RQRO_RWNO = @RqroRwno            
      )
      BEGIN          
         INSERT INTO dbo.[Case]
                 ( RQRO_RQST_RQID ,RQRO_RWNO ,OWNR_CODE ,COMP_CODE ,SRPB_SERV_FILE_NO ,SRPB_RWNO ,
                   SRPB_RECT_CODE ,CSID ,TITL ,SUBJ_APBS_CODE ,ORGN_TYPE ,PRIO_TYPE ,STAT ,CMNT ,TYPE ,
                   PRNT_CASE_CSID ,ESCL_TYPE ,ESCL_DATE ,FLOW_UP_DATE ,SENT_FRST_RESP ,SERL_NUMB ,
                   SERV_LEVL )
         VALUES  ( @Rqid , @RqroRwno , @OwnrCode ,@CompCode ,@FileNo ,@SrpbRwno , 
                   '004' , 0 , @Titl , @SubjApbsCode ,@OrgnType ,@PrioType ,@Stat , @Cmnt , @Type , 
                   @PrntCaseCsid , @EsclType , @EsclDate , @FlowUpDate , @SentFrstResp , @SerlNumb , 
                   @ServLevl );
      END 
      ELSE
      BEGIN
         UPDATE dbo.[Case]
            SET COMP_CODE = @CompCode
               ,SRPB_SERV_FILE_NO = @FileNo
               ,SRPB_RWNO = @SrpbRwno
               ,OWNR_CODE = @OwnrCode
               ,TITL = @Titl
               ,SUBJ_APBS_CODE = @SubjApbsCode
               ,ORGN_TYPE = @OrgnType
               ,PRIO_TYPE = @PrioType
               ,STAT = @Stat
               ,CMNT = @Cmnt
               ,TYPE = @Type
               ,PRNT_CASE_CSID = @PrntCaseCsid
               ,ESCL_TYPE = @EsclType
               ,ESCL_DATE = @EsclDate
               ,FLOW_UP_DATE = @FlowUpDate
               ,SENT_FRST_RESP = @SentFrstResp
               ,SERL_NUMB = @SerlNumb
               ,SERV_LEVL = @ServLevl
          WHERE RQRO_RQST_RQID = @Rqid
            AND RQRO_RWNO = @RqroRwno;
      END;     
      
      COMMIT TRANSACTION T_OPR_CASE_P;
      RETURN 0;
   END TRY
   BEGIN CATCH
      DECLARE @ErrorMessage NVARCHAR(MAX);
      SET @ErrorMessage = ERROR_MESSAGE();
      RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN T_OPR_CASE_P;
      RETURN -1;
   END CATCH;
END;
GO
