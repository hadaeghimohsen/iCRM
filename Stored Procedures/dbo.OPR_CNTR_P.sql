SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[OPR_CNTR_P]
   @X XML
AS
BEGIN
   BEGIN TRY
      BEGIN TRANSACTION T_OPR_CNTR_P;
      DECLARE @Rqid     BIGINT,
              @RqstRqid BIGINT,
              @ProjRqstRqid BIGINT,
              @RqtpCode VARCHAR(3) = '016',
              @RqttCode VARCHAR(3) = '004',
              @RegnCode VARCHAR(3),
              @PrvnCode VARCHAR(3),
              @CntyCode VARCHAR(3),
              @CntrType VARCHAR(30),
   	        @FileNo BIGINT,
   	        @CompCode BIGINT,
   	        @OwnrCode BIGINT;
   	        
      SELECT @FileNo = @X.query('//Request_Row').value('(Request_Row/@servfileno)[1]', 'BIGINT')
            ,@CompCode = @X.query('//Request_Row').value('(Request_Row/@compcode)[1]', 'BIGINT')
            ,@OwnrCode = @X.query('//Contract').value('(Contract/@ownrcode)[1]', 'BIGINT');

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
	         ,@CntrType = @X.query('//Request').value('(Request/@cntrtype)[1]', 'VARCHAR(30)');
      
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
              @Name NVARCHAR(250),
              @StrtDate DATE,
              @EndDate DATE,
              @TempApbsCode BIGINT,
              @DscnType VARCHAR(3),
              @ServLevl VARCHAR(3),
              @Cmnt NVARCHAR(500),
              @BillStrtDate DATE,
              @BillEndDate DATE,
              @BillCnclDate DATE,
              @BillFerq VARCHAR(3),
              @TrcbTcid BIGINT,
              @TotlPric BIGINT,
              @TotlDscn BIGINT,
              @Stat VARCHAR(3);
      
      SELECT @Name = @X.query('//Contract').value('(Contract/@name)[1]','NVARCHAR(250)')
            ,@StrtDate = @X.query('//Contract').value('(Contract/@strtdate)[1]','DATE')
            ,@EndDate = @X.query('//Contract').value('(Contract/@enddate)[1]','DATE')
            ,@TempApbsCode = @X.query('//Contract').value('(Contract/@tempapbscode)[1]','BIGINT')
            ,@DscnType = @X.query('//Contract').value('(Contract/@dscntype)[1]','VARCHAR(3)')
            ,@ServLevl = @X.query('//Contract').value('(Contract/@servlevl)[1]','VARCHAR(3)')
            ,@Cmnt = @X.query('//Contract').value('(Contract/@cmnt)[1]','NVARCHAR(250)')
            ,@BillStrtDate = @X.query('//Contract').value('(Contract/@billstrtdate)[1]','DATE')
            ,@BillEndDate = @X.query('//Contract').value('(Contract/@billenddate)[1]','DATE')
            ,@BillCnclDate = @X.query('//Contract').value('(Contract/@billcncladte)[1]','DATE')
            ,@BillFerq = @X.query('//Contract').value('(Contract/@billferq)[1]','VARCHAR(3)')
            ,@TrcbTcid = @X.query('//Contract').value('(Contract/@trcbtcid)[1]','BIGINT')
            ,@TotlPric = @X.query('//Contract').value('(Contract/@totlpric)[1]','BIGINT')
            ,@TotlDscn = @X.query('//Contract').value('(Contract/@totldscn)[1]','BIGINT')
            ,@Stat = @X.query('//Contract').value('(Contract/@stat)[1]','VARCHAR(3)');
      
      IF @TempApbsCode = 0 SET @TempApbsCode = NULL;
      IF @TrcbTcid = 0 SET @TrcbTcid = NULL;
      
      SELECT @SrpbRwno = SRPB_RWNO_DNRM
        FROM dbo.Service
       WHERE FILE_NO = @FileNo;
      
      IF @Stat = '' OR @Stat IS NULL SET @Stat = '015'
      
      IF NOT EXISTS(
         SELECT *
           FROM dbo.[Contract]
          WHERE RQRO_RQST_RQID = @Rqid
            AND RQRO_RWNO = @RqroRwno            
      )
      BEGIN          
         INSERT INTO dbo.[Contract]
                 ( RQRO_RQST_RQID ,RQRO_RWNO ,OWNR_CODE ,COMP_CODE ,SRPB_SERV_FILE_NO ,SRPB_RWNO ,
                   SRPB_RECT_CODE , CNID, NAME, STRT_DATE, END_DATE, TEMP_APBS_CODE, DSCN_TYPE, 
                   SERV_LEVL, CMNT, BILL_STRT_DATE, BILL_END_DATE, BILL_CNCL_DATE, BILL_FERQ, 
                   TRCB_TCID, TOTL_PRIC, TOTL_DSCN, STAT)
         VALUES  ( @Rqid , @RqroRwno , @OwnrCode ,@CompCode ,@FileNo ,@SrpbRwno , 
                   '004' , 0 , @Name, @StrtDate, @EndDate, @TempApbsCode, @DscnType,
                   @ServLevl, @Cmnt, @BillStrtDate, @BillEndDate, @BillCnclDate, @BillFerq,
                   @TrcbTcid, @TotlPric, @TotlDscn, @Stat );
      END 
      ELSE
      BEGIN
         UPDATE dbo.[Contract]
            SET COMP_CODE = @CompCode
               ,SRPB_SERV_FILE_NO = @FileNo
               ,SRPB_RWNO = @SrpbRwno
               ,OWNR_CODE = @OwnrCode
               ,NAME = @Name
               ,STRT_DATE = @StrtDate
               ,END_DATE = @EndDate
               ,TEMP_APBS_CODE = @TempApbsCode
               ,DSCN_TYPE = @DscnType
               ,SERV_LEVL = @ServLevl
               ,Cmnt = @Cmnt
               ,BILL_STRT_DATE = @BillStrtDate
               ,BILL_END_DATE = @BillEndDate
               ,BILL_CNCL_DATE = @BillCnclDate
               ,BILL_FERQ = @BillFerq
               ,TRCB_TCID = @TrcbTcid
               ,TOTL_PRIC = @TotlPric
               ,TOTL_DSCN = @TotlDscn
               ,STAT = @Stat
          WHERE RQRO_RQST_RQID = @Rqid
            AND RQRO_RWNO = @RqroRwno;
      END;     
      
      COMMIT TRANSACTION T_OPR_CNTR_P;
      RETURN 0;
   END TRY
   BEGIN CATCH
      DECLARE @ErrorMessage NVARCHAR(MAX);
      SET @ErrorMessage = ERROR_MESSAGE();
      RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN T_OPR_CNTR_P;
      RETURN -1;
   END CATCH;
END;
GO
