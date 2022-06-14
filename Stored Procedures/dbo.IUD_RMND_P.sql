SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[IUD_RMND_P]
   @X XML
AS
   /*
      <Reminder rqstrqid="" rqtpcode=""  rqststat="" servfileno="" jobpcode="" />
   */
BEGIN 
   DECLARE @RqstRqid BIGINT,
           @RqtpCode VARCHAR(3),
           @RqstStat VARCHAR(3),
           @ServFileNo BIGINT,
           @FromJobpCode BIGINT,
           @ColbStat VARCHAR(3);
   
   SELECT @RqstRqid = @X.query('//Reminder').value('(Reminder/@rqstrqid)[1]', 'BIGINT')
         ,@RqtpCode = @X.query('//Reminder').value('(Reminder/@rqtpcode)[1]', 'VARCHAR(3)')
         ,@RqstStat = @X.query('//Reminder').value('(Reminder/@rqststat)[1]', 'VARCHAR(3)')
         ,@ServFileNo = @X.query('//Reminder').value('(Reminder/@servfileno)[1]', 'BIGINT')
         ,@FromJobpCode = @X.query('//Reminder').value('(Reminder/@jobpcode)[1]', 'BIGINT')
         ,@ColbStat = @X.query('//Reminder').value('(Reminder/@colbstat)[1]', 'VARCHAR(3)');
   
   -- بدست آوردن تاریخ هشدار و یادآوری
   DECLARE @AlrmDate DATETIME;
   IF @RqtpCode = '005' -- ثبت تماس تلفنی
   BEGIN
      -- در این قسمت اگر تماس تلفنی توسط شرکت انجام شده باشد می توانیم به صورت رخداد و یادآوری ذخیره کنیم در غیر اینصورت نیازی به ثبت یادآوری نیست
      DECLARE @LogType VARCHAR(3);
      SELECT @LogType = LOG_TYPE
            ,@AlrmDate = LOG_DATE            
        FROM dbo.Log_Call
       WHERE RQRO_RQST_RQID = @RqstRqid
         AND SERV_FILE_NO = @ServFileNo;
      
      -- تماس توسط خوده مشتری بوده و نیازی به ثبت یادآوری نیست
      -- OR تماس توسط شرکت بوده و نیازی به یادآوری نیست      
      IF @LogType = '001' 
      BEGIN
         -- اگر گزینه یادآوری در سیستم به اشتباه ذخیره شده حذف گردد
         UPDATE dbo.Reminder SET RECD_STAT = '001' WHERE RQST_RQID = @RqstRqid AND SERV_FILE_NO = @ServFileNo;
         RETURN 0;       
      END
   END
   ELSE IF @RqtpCode = '006' -- ارسال فایل
   BEGIN
      -- ارسال فایل
      SELECT @AlrmDate = SEND_DATE
        FROM dbo.Send_File
       WHERE RQRO_RQST_RQID = @RqstRqid
         AND SERV_FILE_NO = @ServFileNo;
   END
   ELSE IF @RqtpCode = '007' -- ثبت جلسه حضوری
   BEGIN
      -- ثبت جلسه حضوری
      SELECT @AlrmDate = FROM_DATE
        FROM dbo.Appointment
       WHERE RQRO_RQST_RQID = @RqstRqid
         AND SERV_FILE_NO = @ServFileNo;
   END
   ELSE IF @RqtpCode = '008' -- ثبت یادداشت روزانه
   BEGIN
      -- یادداشت
      SELECT @AlrmDate = NOTE_DATE
        FROM dbo.Note
       WHERE RQRO_RQST_RQID = @RqstRqid
         AND SERV_FILE_NO = @ServFileNo;
   END   
   ELSE IF @RqtpCode = '009' -- ثبت وظیفه
   BEGIN
      -- ثبت وظیفه
      SELECT @AlrmDate = DUE_DATE
        FROM dbo.Task
       WHERE RQRO_RQST_RQID = @RqstRqid
         AND SERV_FILE_NO = @ServFileNo;
   END
   ELSE IF @RqtpCode = '010' -- ارسال ایمیل
   BEGIN
      -- ارسال ایمیل
      SELECT @AlrmDate = SEND_DATE
        FROM dbo.Email
       WHERE RQRO_RQST_RQID = @RqstRqid
         AND SERV_FILE_NO = @ServFileNo;
   END
   
   IF @RqstStat = '002'
   BEGIN   
      -- نیازی به ثبت یادآوری نمی باشد
      IF @AlrmDate < GETDATE() 
      BEGIN
         -- اگر گزینه یادآوری در سیستم به اشتباه ذخیره شده حذف گردد
         UPDATE dbo.Reminder SET ALRM_DATE = @AlrmDate WHERE RQST_RQID = @RqstRqid AND SERV_FILE_NO = @ServFileNo AND RECD_STAT = '002';
         RETURN 0;       
      END

      IF @ColbStat = '001'
      BEGIN
         -- در این حالت فقط یک گزینه برای جدول یادآوری وجود دارد آن هم خود ثبت کننده درخواست می باشد
         -- FROM_JOBP_CODE = TO_JOBP_CODE
         
         -- آیا قبلا برای این گزینه یادآوری اطلاعاتی ثبت شده یا خیر
         IF NOT EXISTS(
            SELECT *
              FROM dbo.Reminder
             WHERE RQST_RQID = @RqstRqid
               AND SERV_FILE_NO = @ServFileNo
               AND RECD_STAT = '002'
         )
         BEGIN
            -- اکر ثبت نشده باشد نیاز هست که درج جدید وارد کنیم
            INSERT INTO dbo.Reminder
                    ( RQST_RQID ,
                      SERV_FILE_NO ,
                      FROM_JOBP_CODE ,
                      TO_JOBP_CODE ,
                      READ_RMND ,
                      READ_NOTF ,
                      ALRM_DATE ,
                      RECD_STAT 
                    )
            VALUES  ( @RqstRqid , -- RQST_RQID - bigint
                      @ServFileNo , -- SERV_FILE_NO - bigint
                      @FromJobpCode , -- FROM_JOBP_CODE - bigint
                      @FromJobpCode , -- TO_JOBP_CODE - bigint
                      '001' , -- READ_RMND - varchar(3)
                      '001' , -- READ_NOTF - varchar(3)
                      @AlrmDate , -- ALRM_DATE - datetime
                      '002' -- RECD_STAT - varchar(3)                   
                    );
         END
         ELSE
         BEGIN
            -- اگر ثبت شده باشد نیاز هست که اطلاعات را به بروز کنیم
            UPDATE dbo.Reminder
               SET ALRM_DATE = @AlrmDate
             WHERE RQST_RQID = @RqstRqid
               AND SERV_FILE_NO =  @ServFileNo
               AND RECD_STAT = '002';         
         END
         
      END
      ELSE IF @ColbStat = '002'
      BEGIN
         DECLARE C$ColbJobp CURSOR FOR
            SELECT JOBP_CODE
              FROM dbo.Collaborator
             WHERE RQRO_RQST_RQID = @RqstRqid;
         
         DECLARE @ToJobpCode BIGINT;
         
         OPEN [C$ColbJobp];
         FETCH NEXT FROM [C$ColbJobp] INTO @ToJobpCode;
         
         WHILE @@FETCH_STATUS = 0
         BEGIN
            -- آیا قبلا برای این گزینه یادآوری اطلاعاتی ثبت شده یا خیر
            IF NOT EXISTS(
               SELECT *
                 FROM dbo.Reminder
                WHERE RQST_RQID = @RqstRqid
                  AND SERV_FILE_NO = @ServFileNo
                  AND TO_JOBP_CODE = @ToJobpCode
                  AND RECD_STAT = '002'
            )
            BEGIN
               -- اکر ثبت نشده باشد نیاز هست که درج جدید وارد کنیم
               INSERT INTO dbo.Reminder
                       ( RQST_RQID ,
                         SERV_FILE_NO ,
                         FROM_JOBP_CODE ,
                         TO_JOBP_CODE ,
                         READ_RMND ,
                         READ_NOTF ,
                         ALRM_DATE ,
                         RECD_STAT 
                       )
               VALUES  ( @RqstRqid , -- RQST_RQID - bigint
                         @ServFileNo , -- SERV_FILE_NO - bigint
                         @FromJobpCode , -- FROM_JOBP_CODE - bigint
                         @ToJobpCode , -- TO_JOBP_CODE - bigint
                         '001' , -- READ_RMND - varchar(3)
                         '001' , -- READ_NOTF - varchar(3)
                         @AlrmDate , -- ALRM_DATE - datetime
                         '002' -- RECD_STAT - varchar(3)                   
                       );
            END
            ELSE
            BEGIN
               -- اگر ثبت شده باشد نیاز هست که اطلاعات را به بروز کنیم
               UPDATE dbo.Reminder
                  SET ALRM_DATE = @AlrmDate
                WHERE RQST_RQID = @RqstRqid
                  AND SERV_FILE_NO =  @ServFileNo
                  AND TO_JOBP_CODE = @ToJobpCode
                  AND RECD_STAT = '002';         
            END
            
            FETCH NEXT FROM [C$ColbJobp] INTO @ToJobpCode;
         END
         
         CLOSE [C$ColbJobp];
         DEALLOCATE [C$ColbJobp];
      END      
   END
   ELSE IF @RqstStat = '003'
   BEGIN
      -- اگر درخواست حذف شود در جدول یادآوری هم باید اطلاعات حذف گردد
      UPDATE dbo.Reminder
         SET RECD_STAT = '001'
       WHERE RQST_RQID = @RqstRqid
         AND SERV_FILE_NO =  @ServFileNo
         AND RECD_STAT = '002';
   END
   
END
GO
