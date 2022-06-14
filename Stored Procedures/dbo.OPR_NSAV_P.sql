SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[OPR_NSAV_P]
	-- Add the parameters for the stored procedure here
	@X XML
	/*
	<Note servfileno="" datetime="" rqrorqstrqid="" rqrorwno="" ntid="">
	   <Comment></Comment>
   </Note>
	*/
AS
BEGIN
   BEGIN TRY
   BEGIN TRAN OPR_NSAV_T
   -- تابع ذخیره سازی مربوط به تماس های مشتری
	DECLARE @RqstRqid BIGINT
	       ,@ProjRqstRqid BIGINT
	       ,@ServFileNo BIGINT
	       ,@RqroRqstRqid BIGINT
	       ,@RqroRwno SMALLINT
	       ,@Ntid BIGINT
	       ,@NoteDate DATETIME
	       ,@Colr VARCHAR(30)
	       ,@Subject NVARCHAR(250)
	       ,@Comment NVARCHAR(1000);
   
   SELECT @RqstRqid = @X.query('//Note').value('(Note/@rqstrqid)[1]', 'BIGINT')
         ,@ProjRqstRqid = @X.query('//Note').value('(Note/@projrqstrqid)[1]', 'BIGINT')
         ,@ServFileNo = @X.query('//Note').value('(Note/@servfileno)[1]', 'BIGINT')
         ,@RqroRqstRqid = @X.query('//Note').value('(Note/@rqrorqstrqid)[1]', 'BIGINT')
         ,@RqroRwno = @X.query('//Note').value('(Note/@rqrorwno)[1]', 'SMALLINT')
         ,@Ntid = @X.query('//Note').value('(Note/@ntid)[1]', 'BIGINT')
         ,@NoteDate = @X.query('//Note').value('(Note/@notedate)[1]', 'DATETIME')
         ,@Colr = @X.query('//Note').value('(Note/@colr)[1]', 'VARCHAR(30)')
         ,@Subject = @X.query('//Note').value('(Note/@subj)[1]', 'NVARCHAR(250)')
         ,@Comment = @X.query('//Comment').value('.', 'NVARCHAR(1000)');
   
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
       
      -- اگر ثبت وظیفه از طریق تماس تلفنی باشد شماره درخواست تماس تلفنی را برای درخواست وظیفه ثبت میکنیم
      IF @RqstRqid IS NULL OR @RqstRqid = 0
         SET @RqstRqid = NULL;       
      
      EXEC dbo.INS_RQST_P
           @CntyCode,
           @PrvnCode,
           @RegnCode,
           @RqstRqid,
           '008', -- یادداشت روزانه
           '004', -- به درخواست شرکت
           NULL,
           NULL,
           NULL,
           @RqroRqstRqid OUT;
      -- پایان انجام ثبت درخواست
      
      -- انتصاب شماره درخواست پروژه به درخواست
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
        FROM dbo.Note
       WHERE RQRO_RQST_RQID = @RqroRqstRqid
         AND RQRO_RWNO = @RqroRwno
         AND SERV_FILE_NO = @ServFileNo        
   )
   BEGIN
      INSERT INTO dbo.Note
              ( RQRO_RQST_RQID ,
                RQRO_RWNO ,
                SERV_FILE_NO ,
                NOTE_DATE ,
                NOTE_SUBJ ,
                NOTE_CMNT
              )
      VALUES  ( @RqroRqstRqid , -- RQRO_RQST_RQID - bigint
                @RqroRwno , -- RQRO_RWNO - smallint
                @ServFileNo , -- SERV_FILE_NO - bigint
                @NoteDate ,
                @Subject ,
                @Comment  -- LOG_CMNT - nvarchar(1000)                
              );
              
      UPDATE dbo.Request
         SET RQST_STAT = '002'
       WHERE RQID = @RqroRqstRqid;
   END
   ELSE
   BEGIN
      UPDATE dbo.Note
         SET NOTE_CMNT = @Comment
            ,NOTE_DATE = @NoteDate
            ,NOTE_SUBJ = @Subject
       WHERE RQRO_RQST_RQID = @RqroRqstRqid
         AND RQRO_RWNO = @RqroRwno
         AND SERV_FILE_NO = @ServFileNo
         AND NTID = @Ntid;
   END
   COMMIT TRAN OPR_NSAV_T;
   END TRY
   BEGIN CATCH
      DECLARE @ErrorMessage NVARCHAR(4000);
      SET @ErrorMessage = ERROR_MESSAGE();
      RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN OPR_NSAV_T;
   END CATCH;      
END
GO
