SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[OPR_LDSV_P]
	-- Add the parameters for the stored procedure here
	@X XML
	/*
	<Lead type="" servfileno="" datetime="" rqrorqstrqid="" rqrorwno="" lcid="">
	   <Comment subject=""></Comment>
   </Lead>
	*/
AS
BEGIN
   BEGIN TRY
   BEGIN TRAN OPR_LDSV_T
   -- تابع ذخیره سازی مربوط به تماس های مشتری
	DECLARE @ServFileNo BIGINT
	       ,@CompCode BIGINT
	       ,@RqroRqstRqid BIGINT
	       ,@RqroRwno SMALLINT
	       ,@Ldid BIGINT	       
	       ,@Colr VARCHAR(30);
   
   SELECT @ServFileNo = @X.query('//Lead').value('(Lead/@servfileno)[1]', 'BIGINT')
         ,@CompCode = @X.query('//Lead').value('(Lead/@compcode)[1]', 'BIGINT')
         ,@RqroRqstRqid = @X.query('//Lead').value('(Lead/@rqrorqstrqid)[1]', 'BIGINT')
         ,@RqroRwno = @X.query('//Lead').value('(Lead/@rqrorwno)[1]', 'SMALLINT')
         ,@Ldid = @X.query('//Lead').value('(Lead/@ldid)[1]', 'BIGINT')
         ,@Colr = @X.query('//Lead').value('(Lead/@colr)[1]', 'VARCHAR(30)');
   
   -- اگر درخواستی وجود نداشته باشد بایستی ابتدا درخواستی ثبت گردد و با آن شماره درخواست در ادامه در جدوال مربوطه ثبت میکنیم
   IF @RqroRqstRqid IS NULL OR @RqroRqstRqid = 0
   BEGIN
      -- بدست آوردن اطلاعات ناحیه و استان
      DECLARE @CntyCode VARCHAR(3)
             ,@PrvnCode VARCHAR(3)
             ,@RegnCode VARCHAR(3);
      
      IF @ServFileNo IS NULL OR @ServFileNo = 0
      BEGIN
         SELECT @ServFileNo = NULL
               ,@CntyCode = NULL
               ,@PrvnCode = NULL
               ,@RegnCode = NULL;
      END
      
      SELECT @CntyCode = REGN_PRVN_CNTY_CODE
            ,@PrvnCode = REGN_PRVN_CODE
            ,@RegnCode = REGN_CODE
        FROM dbo.[Service]
       WHERE FILE_NO = @ServFileNo;
      
      -- اگر این درخواست پیرو درخواست دیگری ایجاد شده باشد
      --IF @RqstRqid IS NULL OR @RqstRqid = 0
      --   SET @RqstRqid = NULL;      
      
      EXEC dbo.INS_RQST_P
           @CntyCode,
           @PrvnCode,
           @RegnCode,
           NULL,
           '014', -- تماس تلفنی
           '004', -- به درخواست شرکت
           NULL,
           NULL,
           NULL,
           @RqroRqstRqid OUT;
      -- پایان انجام ثبت درخواست
      
      --UPDATE dbo.Request
      --   SET PROJ_RQST_RQID = @ProjRqstRqid
      -- WHERE RQID = @RqroRqstRqid;
      
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
   
   
   
   COMMIT TRAN OPR_LDSV_T;
   END TRY
   BEGIN CATCH
      DECLARE @ErrorMessage NVARCHAR(4000);
      SET @ErrorMessage = ERROR_MESSAGE();
      RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN OPR_LDSV_T;
   END CATCH;      
END
GO
