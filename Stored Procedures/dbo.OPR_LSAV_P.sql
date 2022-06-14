SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[OPR_LSAV_P]
	-- Add the parameters for the stored procedure here
	@X XML
	/*
	<LogCall type="" servfileno="" datetime="" rqrorqstrqid="" rqrorwno="" lcid="">
	   <Comment subject=""></Comment>
   </LogCall>
	*/
AS
BEGIN
   BEGIN TRY
   BEGIN TRAN OPR_LSAV_T
   -- تابع ذخیره سازی مربوط به تماس های مشتری
	DECLARE @Type VARCHAR(3)
	       ,@ServFileNo BIGINT
	       ,@DateTime DATETIME
	       ,@RqroRqstRqid BIGINT
	       ,@RqroRwno SMALLINT
	       ,@Lcid BIGINT
	       ,@RqstRqid BIGINT
	       ,@ProjRqstRqid BIGINT
	       ,@RsltStat VARCHAR(3)
	       ,@Subject NVARCHAR(250)
	       ,@Comment NVARCHAR(1000)
	       ,@Colr VARCHAR(30);
   
   SELECT @Type = @X.query('//LogCall').value('(LogCall/@type)[1]', 'VARCHAR(3)')
         ,@ServFileNo = @X.query('//LogCall').value('(LogCall/@servfileno)[1]', 'BIGINT')
         ,@DateTime = @X.query('//LogCall').value('(LogCall/@datetime)[1]', 'DATETIME')
         ,@RqroRqstRqid = @X.query('//LogCall').value('(LogCall/@rqrorqstrqid)[1]', 'BIGINT')
         ,@RqroRwno = @X.query('//LogCall').value('(LogCall/@rqrorwno)[1]', 'SMALLINT')
         ,@Lcid = @X.query('//LogCall').value('(LogCall/@lcid)[1]', 'BIGINT')         
         ,@RqstRqid = @X.query('//LogCall').value('(LogCall/@rqstrqid)[1]', 'BIGINT')
         ,@ProjRqstRqid = @X.query('//LogCall').value('(LogCall/@projrqstrqid)[1]', 'BIGINT')
         ,@RsltStat = @X.query('//LogCall').value('(LogCall/@rsltstat)[1]', 'VARCHAR(3)')
         ,@Subject = @X.query('//Comment').value('(Comment/@subject)[1]', 'NVARCHAR(250)')
         ,@Comment = @X.query('//Comment').value('.', 'NVARCHAR(1000)')
         ,@Colr = @X.query('//LogCall').value('(LogCall/@colr)[1]', 'VARCHAR(30)');
   
   -- اگر درخواستی وجود نداشته باشد بایستی ابتدا درخواستی ثبت گردد و با آن شماره درخواست در ادامه در جدوال مربوطه ثبت میکنیم
   IF @RqroRqstRqid IS NULL OR @RqroRqstRqid = 0
   BEGIN
      -- بدست آوردن اطلاعات ناحیه و استان
      DECLARE @CntyCode VARCHAR(3)
             ,@PrvnCode VARCHAR(3)
             ,@RegnCode VARCHAR(3);
      
      SELECT @CntyCode = REGN_PRVN_CNTY_CODE
            ,@PrvnCode = REGN_PRVN_CODE
            ,@RegnCode = REGN_CODE
        FROM dbo.[Service]
       WHERE FILE_NO = @ServFileNo;
      
      -- اگر این درخواست پیرو درخواست دیگری ایجاد شده باشد
      IF @RqstRqid IS NULL OR @RqstRqid = 0
         SET @RqstRqid = NULL;      
      
      EXEC dbo.INS_RQST_P
           @CntyCode,
           @PrvnCode,
           @RegnCode,
           @RqstRqid,
           '005', -- تماس تلفنی
           '004', -- به درخواست شرکت
           NULL,
           NULL,
           NULL,
           @RqroRqstRqid OUT;
      -- پایان انجام ثبت درخواست
      
      UPDATE dbo.Request
         SET PROJ_RQST_RQID = @ProjRqstRqid
       WHERE RQID = @RqroRqstRqid;
      
      -- ثبت ردیف درخواست       
      SELECT @RqroRwno = Rwno
         FROM Request_Row
         WHERE RQST_RQID = @RqroRqstRqid
           AND SERV_FILE_NO = @ServFileNo;
           
      IF @RqroRwno IS NULL OR @RqroRwno = 0
      BEGIN
         EXEC INS_RQRO_P
            @RqroRqstRqid
           ,@ServFileNo
           ,@RqroRwno OUT;
      END
      -- پایان ثبت ردیف درخواست     
   END
   
   UPDATE dbo.Request
     SET COLR = @Colr
   WHERE RQID = @RqroRqstRqid;
   
   IF NOT EXISTS(
      SELECT *
        FROM dbo.Log_Call
       WHERE RQRO_RQST_RQID = @RqroRqstRqid
         AND RQRO_RWNO = @RqroRwno
         AND SERV_FILE_NO = @ServFileNo        
   )
   BEGIN
      UPDATE dbo.Request
         SET RQST_STAT = '002'
       WHERE RQID = @RqroRqstRqid;

      INSERT INTO dbo.Log_Call
              ( RQRO_RQST_RQID ,
                RQRO_RWNO ,
                SERV_FILE_NO ,
                LOG_TYPE ,
                SUBJ_DESC ,
                LOG_CMNT ,
                LOG_DATE ,
                RSLT_STAT
              )
      VALUES  ( @RqroRqstRqid , -- RQRO_RQST_RQID - bigint
                @RqroRwno , -- RQRO_RWNO - smallint
                @ServFileNo , -- SERV_FILE_NO - bigint
                @Type , -- LOG_TYPE - varchar(3)
                @Subject , -- SUBJ_DESC - nvarchar(250)
                @Comment , -- LOG_CMNT - nvarchar(1000)
                @DateTime ,  -- LOG_DATE - datetime                
                @RsltStat
              );              
   END
   ELSE
   BEGIN
      UPDATE dbo.Log_Call
         SET LOG_TYPE = @Type
            ,SUBJ_DESC = @Subject
            ,LOG_CMNT = @Comment
            ,LOG_DATE = @DateTime
            ,RSLT_STAT = @RsltStat
       WHERE RQRO_RQST_RQID = @RqroRqstRqid
         AND RQRO_RWNO = @RqroRwno
         AND SERV_FILE_NO = @ServFileNo
         AND LCID = @Lcid;
   END
   COMMIT TRAN OPR_LSAV_T;
   END TRY
   BEGIN CATCH
      DECLARE @ErrorMessage NVARCHAR(4000);
      SET @ErrorMessage = ERROR_MESSAGE();
      RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN OPR_LSAV_T;
   END CATCH;      
END
GO
