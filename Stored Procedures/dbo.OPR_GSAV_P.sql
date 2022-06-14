SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[OPR_GSAV_P]
	-- Add the parameters for the stored procedure here
	@X XML
	/*
	<Message servfileno="" rqrorqstrqid="" rqrorwno="" Msid="" frommail="" senddate="">
	   <Comment subject=""></Comment>
	   <MessageTos>
	      <MessageTo servfileno="" to="" etid=""/>
	   </MessageTos>
   </Message>
	*/
AS
BEGIN
   BEGIN TRY
   BEGIN TRAN OPR_GSAV_T
   -- تابع ذخیره سازی مربوط به تماس های مشتری
	DECLARE @ServFileNo BIGINT
	       ,@RqroRqstRqid BIGINT
	       ,@RqroRwno SMALLINT
	       ,@Msid BIGINT
	       ,@RqstRqid BIGINT
	       ,@ProjRqstRqid BIGINT
	       ,@MesgCmnt NVARCHAR(1000)
	       ,@MesgDate DATETIME
	       ,@MesgStat VARCHAR(3)
	       ,@MesgType VARCHAR(3)
	       ,@CellPhon VARCHAR(11)
	       ,@SendStat VARCHAR(3)
	       ,@Colr VARCHAR(30);
	       
   
   SELECT @ServFileNo = @X.query('//Message').value('(Message/@servfileno)[1]', 'BIGINT')
         ,@RqroRqstRqid = @X.query('//Message').value('(Message/@rqrorqstrqid)[1]', 'BIGINT')
         ,@RqroRwno = @X.query('//Message').value('(Message/@rqrorwno)[1]', 'SMALLINT')
         ,@Msid = @X.query('//Message').value('(Message/@msid)[1]', 'BIGINT')         
         ,@RqstRqid = @X.query('//Message').value('(Message/@rqstrqid)[1]', 'BIGINT')         
         ,@ProjRqstRqid = @X.query('//Message').value('(Message/@projrqstrqid)[1]', 'BIGINT')         
         ,@CellPhon = @X.query('//Message').value('(Message/@cellphon)[1]', 'VARCHAR(11)')
         ,@MesgDate = @X.query('//Message').value('(Message/@mesgdate)[1]', 'DATETIME')
         ,@MesgCmnt = @X.query('//Comment').value('.', 'NVARCHAR(1000)')
         ,@MesgStat = @X.query('//Message').value('(Message/@mesgstat)[1]', 'VARCHAR(3)')
         ,@MesgType = @X.query('//Message').value('(Message/@mesgtype)[1]', 'VARCHAR(3)')
         ,@SendStat = @X.query('//Message').value('(Message/@sendstat)[1]', 'VARCHAR(3)')
         ,@Colr = @X.query('//Message').value('(Message/@colr)[1]', 'VARCHAR(30)');
   
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
           '012', -- ارسال پیامک
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
        FROM dbo.[Message]
       WHERE RQRO_RQST_RQID = @RqroRqstRqid
         AND RQRO_RWNO = @RqroRwno
         AND SERV_FILE_NO = @ServFileNo        
   )
   BEGIN
      UPDATE dbo.Request
         SET RQST_STAT = '002'
       WHERE RQID = @RqroRqstRqid;

      INSERT dbo.Message
              ( RQRO_RQST_RQID ,
                RQRO_RWNO ,
                SERV_FILE_NO ,
                MESG_DATE ,
                MESG_CMNT ,
                CELL_PHON ,
                MESG_TYPE ,
                MESG_STAT ,
                SEND_STAT
              )
      VALUES  ( @RqroRqstRqid , -- RQRO_RQST_RQID - bigint
                @RqroRwno , -- RQRO_RWNO - smallint
                @ServFileNo , -- SERV_FILE_NO - bigint
                @MesgDate , -- MESG_DATE - datetime
                @MesgCmnt , -- MESG_CMNT - nvarchar(1000)
                @CellPhon , -- CELL_PHON - varchar(11)
                @MesgType , -- MESG_TYPE - varchar(3)
                @MesgStat , -- MESG_STAT - varchar(3)
                @SendStat
              );
      
      SELECT @Msid = Msid
        FROM dbo.Message
       WHERE RQRO_RQST_RQID = @RqroRqstRqid
         AND RQRO_RWNO = @RqroRwno
         AND SERV_FILE_NO = @ServFileNo;              
   END
   ELSE
   BEGIN
      IF EXISTS(
         SELECT *
           FROM dbo.Message
          WHERE MSID = @Msid
            AND SEND_STAT = '002' -- آیا پیامک از سامانه ارسال شده
      )
      BEGIN
         RAISERROR ( N'پیامک هایی که از طریق سامانه ارسال شده باشند قادر به ویرایش نیستید', -- Message text.
               16, -- Severity.
               1 -- State.
               );      
         RETURN;
      END 
      UPDATE dbo.Message
         SET MESG_DATE = @MesgDate
            ,MESG_CMNT = @MesgCmnt
            ,MESG_STAT = @MesgStat
            ,MESG_TYPE = @MesgType
            ,CELL_PHON = @CellPhon
            ,SEND_STAT = CASE SEND_STAT WHEN '001' THEN @SendStat ELSE SEND_STAT END
       WHERE RQRO_RQST_RQID = @RqroRqstRqid
         AND RQRO_RWNO = @RqroRwno
         AND SERV_FILE_NO = @ServFileNo
         AND Msid = @Msid;
   END
   
   COMMIT TRAN OPR_GSAV_T;
   END TRY
   BEGIN CATCH
      DECLARE @ErrorMessage NVARCHAR(4000);
      SET @ErrorMessage = ERROR_MESSAGE();
      RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN OPR_GSAV_T;
   END CATCH;      
END
GO
