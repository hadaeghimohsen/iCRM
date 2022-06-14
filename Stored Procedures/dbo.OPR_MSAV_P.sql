SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[OPR_MSAV_P]
	-- Add the parameters for the stored procedure here
	@X XML
	/*
	<Email servfileno="" rqrorqstrqid="" rqrorwno="" emid="" frommail="" senddate="">
	   <Comment subject=""></Comment>
	   <EmailTos>
	      <EmailTo servfileno="" to="" etid=""/>
	   </EmailTos>
   </Email>
	*/
AS
BEGIN
   BEGIN TRY
   BEGIN TRAN OPR_MSAV_T
   -- تابع ذخیره سازی مربوط به تماس های مشتری
	DECLARE @ServFileNo BIGINT
	       ,@RqroRqstRqid BIGINT
	       ,@RqroRwno SMALLINT
	       ,@Emid BIGINT
	       ,@RqstRqid BIGINT
	       ,@ProjRqstRqid BIGINT
	       ,@Subject NVARCHAR(250)
	       ,@Comment NVARCHAR(4000)
	       ,@SendDate DATETIME
	       ,@SendStat VARCHAR(3)
	       ,@FromMail VARCHAR(250)
	       ,@Colr VARCHAR(30);
   
   SELECT @ServFileNo = @X.query('//Email').value('(Email/@servfileno)[1]', 'BIGINT')
         ,@RqroRqstRqid = @X.query('//Email').value('(Email/@rqrorqstrqid)[1]', 'BIGINT')
         ,@RqroRwno = @X.query('//Email').value('(Email/@rqrorwno)[1]', 'SMALLINT')
         ,@Emid = @X.query('//Email').value('(Email/@emid)[1]', 'BIGINT')         
         ,@RqstRqid = @X.query('//Email').value('(Email/@rqstrqid)[1]', 'BIGINT')         
         ,@ProjRqstRqid = @X.query('//Email').value('(Email/@projrqstrqid)[1]', 'BIGINT')         
         ,@SendDate = @X.query('//Email').value('(Email/@senddate)[1]', 'DATETIME')
         ,@SendStat = @X.query('//Email').value('(Email/@sendstat)[1]', 'VARCHAR(3)')
         ,@Subject = @X.query('//Comment').value('(Comment/@subject)[1]', 'NVARCHAR(250)')
         ,@Comment = @X.query('//Comment').value('.', 'NVARCHAR(4000)')
         ,@Colr = @X.query('//Email').value('(Email/@colr)[1]', 'VARCHAR(30)');
   
   SELECT @FromMail = EMAL_ADRS
     FROM dbo.V#Users
    WHERE USER_DB = UPPER(SUSER_NAME())
   
   IF @FromMail IS NULL OR @FromMail = '' OR LEN(@FromMail) <= 8
   BEGIN
      RAISERROR(N'کاربر گرامی ایمیل شما در قسمت تنظیمات کاربری مشخص نشده لطفا با وارد شدن به پروفایل خود در قسمت ایمیل آدرس خود را وارد کنید', 16, 1);
      RETURN;
   END
   
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
      
      -- اگر درخواست معامله داشته باشیم که بخواهیم ایمیلی پیرو آن ارسال کنیم
      IF @RqstRqid IS NULL OR @RqstRqid = 0
         SET @RqstRqid = NULL;
      
      EXEC dbo.INS_RQST_P
           @CntyCode,
           @PrvnCode,
           @RegnCode,
           @RqstRqid,
           '010', -- ارسال ایمیل
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
        FROM dbo.Email
       WHERE RQRO_RQST_RQID = @RqroRqstRqid
         AND RQRO_RWNO = @RqroRwno
         AND SERV_FILE_NO = @ServFileNo        
   )
   BEGIN
      UPDATE dbo.Request
         SET RQST_STAT = '002'
       WHERE RQID = @RqroRqstRqid;

      INSERT INTO dbo.Email
              ( RQRO_RQST_RQID ,
                RQRO_RWNO ,
                SERV_FILE_NO ,
                FROM_MAIL ,
                SUBJ_DESC ,
                EMAL_CMNT ,
                SEND_DATE ,
                SEND_STAT
              )
      VALUES  ( @RqroRqstRqid , -- RQRO_RQST_RQID - bigint
                @RqroRwno , -- RQRO_RWNO - smallint
                @ServFileNo , -- SERV_FILE_NO - bigint
                @FromMail , -- FROM_MAIL - varchar(250)
                @Subject , -- SUBJ_DESC - nvarchar(250)
                @Comment , -- EMAL_CMNT - nvarchar(4000)
                @SendDate ,  -- SEND_DATE - datetime
                @SendStat
              );
      
      SELECT @Emid = EMID
        FROM dbo.Email
       WHERE RQRO_RQST_RQID = @RqroRqstRqid
         AND RQRO_RWNO = @RqroRwno
         AND SERV_FILE_NO = @ServFileNo;              
   END
   ELSE
   BEGIN
      UPDATE dbo.Email
         SET FROM_MAIL = @FromMail
            ,SUBJ_DESC = @Subject
            ,EMAL_CMNT = @Comment
            ,SEND_DATE = @SendDate
            ,SEND_STAT = @SendStat
       WHERE RQRO_RQST_RQID = @RqroRqstRqid
         AND RQRO_RWNO = @RqroRwno
         AND SERV_FILE_NO = @ServFileNo
         AND EMID = @Emid;
   END
   
   -- ذخیره سازی ایمیل های مقصد
   Declare C$EmailTos Cursor For
       Select r.query('.').value('.', 'VARCHAR(250)')
         from @x.nodes('//EmailTo') t(r);
   
   Declare @ToMail VARCHAR(250);
   
   OPEN C$EmailTos;
   L$FETCH$1:
   FETCH NEXT FROM C$EmailTos INTO @ToMail;
   
   IF @@FETCH_STATUS <> 0
      GOTO L$CLOSE$1;
   
   IF NOT EXISTS(
      SELECT *
        FROM dbo.Email_To_Email
       WHERE EMAL_EMID = @Emid
         AND UPPER(TO_MAIL) = UPPER(@ToMail)
   )   
   BEGIN
      INSERT INTO dbo.Email_To_Email
              ( EMAL_EMID ,
                TO_MAIL
              )
      VALUES  ( 
                @Emid , -- EMAL_EMID - bigint
                @ToMail  -- TO_MAIL - varchar(250)
              );
   END
   
   GOTO L$FETCH$1;
   L$CLOSE$1:
   CLOSE C$EmailTos;
   DEALLOCATE C$EmailTos;
   
   COMMIT TRAN OPR_MSAV_T;
   END TRY
   BEGIN CATCH
      DECLARE @ErrorMessage NVARCHAR(4000);
      SET @ErrorMessage = ERROR_MESSAGE();
      RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN OPR_MSAV_T;
   END CATCH;      
END
GO
