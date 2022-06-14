SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[OPR_DRQT_F]
	-- Add the parameters for the stored procedure here
	@X XML
AS
BEGIN
	DECLARE @ErrorMessage NVARCHAR(MAX);
	BEGIN TRAN OPR_DRQT_T;
	BEGIN TRY
	   DECLARE @Rqid     BIGINT,
	           @CashCode BIGINT,
	           @RqstRqid BIGINT,
	           @ProjRqstRqid BIGINT,
	           @RqtpCode VARCHAR(3) = '011',
	           @RqttCode VARCHAR(3) = '001',
	           @RegnCode VARCHAR(3),
	           @PrvnCode VARCHAR(3),
	           @CntyCode VARCHAR(3),
	           @PymtDesc NVARCHAR(250),
	           @PymtStag VARCHAR(3),
	           @SinfSorcType VARCHAR(3),
	           @RefServFileNo BIGINT,
	           @RefCompCode BIGINT,
	           @RefOthrDesc NVARCHAR(250),
	           @PymtDate DATETIME,
	           @PymtLostType VARCHAR(3),
	           @PymtLostDesc NVARCHAR(1000),
	           @Colr VARCHAR(30);
   	
   	DECLARE @FileNo BIGINT;
	   SELECT @Rqid     = @X.query('//Payment').value('(Payment/@rqid)[1]', 'BIGINT')
	         ,@CashCode = @X.query('//Payment').value('(Payment/@cashcode)[1]', 'BIGINT')
	         ,@RqstRqid = @X.query('//Payment').value('(Payment/@rqstrqid)[1]', 'BIGINT')
	         ,@ProjRqstRqid = @X.query('//Payment').value('(Payment/@projrqstrqid)[1]', 'BIGINT')
	         ,@FileNo   = @X.query('//Payment').value('(Payment/@servfileno)[1]'  , 'BIGINT')
	         ,@PymtDesc = @X.query('//Payment').value('(Payment/@pymtdesc)[1]', 'NVARCHAR(250)')
	         ,@PymtStag = @X.query('//Payment').value('(Payment/@pymtstag)[1]', 'VARCHAR(3)')
	         ,@SinfSorcType = @X.query('//Payment').value('(Payment/@sinfsorctype)[1]', 'VARCHAR(3)')
	         ,@RefServFileNo = @X.query('//Payment').value('(Payment/@refservfileno)[1]', 'BIGINT')
	         ,@RefCompCode = @X.query('//Payment').value('(Payment/@refcompcode)[1]', 'BIGINT')
	         ,@RefOthrDesc = @X.query('//Payment').value('(Payment/@refothrdesc)[1]', 'NVARCHAR(250)')
	         ,@PymtDate = @X.query('//Payment').value('(Payment/@pymtdate)[1]', 'DATE')
	         ,@PymtLostType = @X.query('//Payment').value('(Payment/@pymtlosttype)[1]', 'VARCHAR(3)')
	         ,@PymtLostDesc = @X.query('//Payment').value('(Payment/@pymtlostdesc)[1]', 'NVARCHAR(1000)')
	         ,@Colr = @X.query('//Payment').value('(Payment/@colr)[1]', 'VARCHAR(30)');
      
      IF @FileNo = 0 OR @FileNo IS NULL BEGIN RAISERROR(N'شماره پرونده برای مشتری وارد نشده', 16, 1); RETURN; END
      IF LEN(@RqttCode) <> 3 BEGIN RAISERROR(N'نوع متقاضی برای درخواست وارد نشده', 16, 1); RETURN; END      
      
      IF @RefCompCode = 0
         SET @RefCompCode = NULL;
      IF @RefServFileNo = 0
         SET @RefServFileNo = NULL;
      
      SELECT @RegnCode = Regn_Code, @PrvnCode = Regn_Prvn_Code, @CntyCode = REGN_PRVN_CNTY_CODE
        FROM dbo.Service
       WHERE FILE_NO = @FileNo;
      
      IF @RqstRqid IS NULL OR @RqstRqid = 0
         SET @RqstRqid = NULL;

      -- ثبت شماره درخواست 
      IF @Rqid IS NULL OR @Rqid = 0
      BEGIN
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
      END
      
      UPDATE dbo.Request
         SET PROJ_RQST_RQID = @ProjRqstRqid
       WHERE RQID = @Rqid;
       
      -- ثبت ردیف درخواست 
      DECLARE @RqroRwno SMALLINT;
      SELECT @RqroRwno = Rwno
         FROM Request_Row
         WHERE RQST_RQID = @Rqid
           AND SERV_FILE_NO = @FileNo;
           
      IF @RqroRwno IS NULL
      BEGIN
         EXEC INS_RQRO_P
            @Rqid
           ,@FileNo
           ,@RqroRwno OUT;
      END
      
      UPDATE dbo.Request
        SET COLR = @Colr
       WHERE Rqid = @Rqid;       
      
      -- اگر در ثبت موقت باشیم و برای نوع درخواست و متقاضی آیین نامه هزینه داری داشته باشیم درخواست را به فرم اعلام هزینه ارسال میکنیم            
      IF EXISTS(
         SELECT *
           FROM Request_Row Rr, dbo.Service F
          WHERE Rr.SERV_FILE_NO = F
          .FILE_NO
            AND Rr.RQST_RQID = @Rqid
            AND EXISTS(
               SELECT *
                 FROM dbo.VF$All_Expense_Detail(
                  @PrvnCode, 
                  @RegnCode, 
                  NULL, 
                  @RqtpCode, 
                  @RqttCode, 
                  NULL, 
                  NULL, 
                  NULL , 
                  NULL)
            )
      )
      BEGIN
         IF NOT EXISTS(SELECT * FROM Request WHERE RQID = @Rqid AND SSTT_MSTT_CODE = 2 AND SSTT_CODE = 2 )
         BEGIN
            IF EXISTS(
               SELECT *
                 FROM dbo.Request
                WHERE RQID = @Rqid
                  AND RQST_STAT = '001'
            )
            BEGIN
               SELECT @X = (
                  SELECT @Rqid '@rqid'          
                        ,@RqtpCode '@rqtpcode'
                        ,@RqttCode '@rqttcode'
                        ,@RegnCode '@regncode'  
                        ,@PrvnCode '@prvncode'
                        ,@FileNo '@fileno'
                  FOR XML PATH('Request'), ROOT('Process')
               );
               EXEC INS_SEXP_P @X;             

               UPDATE Request
                  SET SEND_EXPN = '002'
                     ,SSTT_MSTT_CODE = 2
                     ,SSTT_CODE = 2
                WHERE RQID = @Rqid;
            END
        END
        
        UPDATE dbo.Payment
           SET SERV_FILE_NO = @FileNo
              ,PYMT_DESC = @PymtDesc
              ,PYMT_STAG = @PymtStag
              ,SINF_SORC_TYPE = @SinfSorcType
              ,REF_SERV_FILE_NO = @RefServFileNo
              ,REF_COMP_CODE = @RefCompCode
              ,REF_OTHR_DESC = @RefOthrDesc
              ,PYMT_DATE = @PymtDate
              ,PYMT_LOST_TYPE = @PymtLostType
              ,PYMT_LOST_DESC = @PymtLostDesc
         WHERE RQST_RQID = @Rqid;
      END
      ELSE
      BEGIN
         UPDATE Request
            SET SEND_EXPN = '001'
               ,SSTT_MSTT_CODE = 1
               ,SSTT_CODE = 1
          WHERE RQID = @Rqid;                
         
         DELETE Payment_Detail 
          WHERE PYMT_RQST_RQID = @Rqid;          
         DELETE Payment
          WHERE RQST_RQID = @Rqid;            
      END  
      COMMIT TRAN OPR_DRQT_T;
   END TRY
   BEGIN CATCH
      SET @ErrorMessage = ERROR_MESSAGE();
      RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN OPR_DRQT_T;
   END CATCH;   
END
GO
