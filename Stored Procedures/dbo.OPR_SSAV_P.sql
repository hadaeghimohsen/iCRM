SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[OPR_SSAV_P]
	-- Add the parameters for the stored procedure here
	@X XML
	/*
	<SendFile servfileno="" datetime="" rqrorqstrqid="" rqrorwno="" ntid="">
	   <Comment></Comment>
   </SendFile>
	*/
AS
BEGIN
   BEGIN TRY
   BEGIN TRAN OPR_SSAV_T
   -- تابع ذخیره سازی مربوط به تماس های مشتری
	DECLARE @ServFileNo BIGINT
	       ,@RqroRqstRqid BIGINT
	       ,@RqroRwno SMALLINT
	       ,@Sfid BIGINT
	       ,@Subject NVARCHAR(250)
	       ,@SendDate DATETIME
	       ,@SendType BIGINT
	       ,@UpldType VARCHAR(3)
	       ,@SdrcType VARCHAR(3)
	       ,@FilePath NVARCHAR(4000)
	       ,@FileSrvrLink NVARCHAR(4000)
	       ,@UrlLink NVARCHAR(4000)
	       ,@UrlName NVARCHAR(250)
	       ,@SherTeam NVARCHAR(3)
	       ,@RqstRqid BIGINT
	       ,@ProjRqstRqid BIGINT
	       ,@Cmid BIGINT;
   
   SELECT @ServFileNo = @X.query('//SendFile').value('(SendFile/@servfileno)[1]', 'BIGINT')
         ,@RqroRqstRqid = @X.query('//SendFile').value('(SendFile/@rqrorqstrqid)[1]', 'BIGINT')
         ,@RqroRwno = @X.query('//SendFile').value('(SendFile/@rqrorwno)[1]', 'SMALLINT')
         ,@Sfid = @X.query('//SendFile').value('(SendFile/@sfid)[1]', 'BIGINT')
         ,@RqstRqid = @X.query('//SendFile').value('(SendFile/@rqstrqid)[1]', 'BIGINT')         
         ,@ProjRqstRqid = @X.query('//SendFile').value('(SendFile/@projrqstrqid)[1]', 'BIGINT')         
         ,@Cmid = @X.query('//SendFile').value('(SendFile/@cmid)[1]', 'BIGINT')         
         ,@Subject = @X.query('//SendFile').value('(SendFile/@subject)[1]', 'NVARCHAR(250)')
         ,@SendDate = @X.query('//SendFile').value('(SendFile/@senddate)[1]', 'DATETIME')
         ,@SendType = @X.query('//SendFile').value('(SendFile/@sendtype)[1]', 'BIGINT')
         ,@SdrcType = @X.query('//SendFile').value('(SendFile/@sdrctype)[1]', 'VARCHAR(3)')
         ,@UpldType = @X.query('//SendFile').value('(SendFile/@upldtype)[1]', 'VARCHAR(3)')
         ,@FilePath = @X.query('//SendFile').value('(SendFile/@filepath)[1]', 'NVARCHAR(4000)')
         ,@FileSrvrLink = @X.query('//SendFile').value('(SendFile/@filesrvrlink)[1]', 'NVARCHAR(4000)')
         ,@UrlLink = @X.query('//SendFile').value('(SendFile/@urllink)[1]', 'NVARCHAR(4000)')
         ,@UrlName = @X.query('//SendFile').value('(SendFile/@urlname)[1]', 'NVARCHAR(250)')
         ,@SherTeam = @X.query('//SendFile').value('(SendFile/@sherteam)[1]', 'VARCHAR(3)');
   
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
         SET @RqstRqid = NULL
      
      EXEC dbo.INS_RQST_P
           @CntyCode,
           @PrvnCode,
           @RegnCode,
           @RqstRqid,
           '006', -- ارسال فایل
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
   
   IF @Cmid = 0
      SET @Cmid = NULL;
   IF @SendType = 0
      SET @SendType = NULL;   
   
   IF NOT EXISTS(
      SELECT *
        FROM dbo.Send_File
       WHERE RQRO_RQST_RQID = @RqroRqstRqid
         AND RQRO_RWNO = @RqroRwno
         AND SERV_FILE_NO = @ServFileNo        
   )
   BEGIN
      UPDATE dbo.Request
         SET RQST_STAT = '002'
       WHERE RQID = @RqroRqstRqid;
      
      INSERT INTO dbo.Send_File
              ( RQRO_RQST_RQID ,
                RQRO_RWNO ,
                SERV_FILE_NO ,
                CMNT_CMID ,
                SUBJ_DESC ,
                SEND_DATE ,
                SEND_TYPE ,
                UPLD_TYPE ,
                SEND_STAT ,
                SDRC_TYPE ,
                FILE_PATH ,
                FILE_SRVR_LINK ,
                URL_LINK ,
                URL_NAME ,
                SHER_TEAM 
              )
      VALUES  ( @RqroRqstRqid , -- RQRO_RQST_RQID - bigint
                @RqroRwno , -- RQRO_RWNO - smallint
                @ServFileNo , -- SERV_FILE_NO - bigint
                @Cmid , -- CMNT_CMID - BIGINT                
                @Subject , -- SUBJ_DESC - nvarchar(250)
                @SendDate , -- SEND_DATE - datetime
                @SendType, -- SEND_TYPE - varchar(3)
                @UpldType , -- UPLD_TYPE - varchar(3)
                '001' , -- SEND_STAT - varchar(3)
                @SdrcType , -- SDRC_TYPE - varchar(3)
                @FilePath , -- FILE_PATH - nvarchar(4000)
                @FileSrvrLink , -- FILE_SRVR_LINK - nvarchar(4000)
                @UrlLink , -- URL_LINK - nvarchar(4000)
                @UrlName , -- URL_NAME - nvarchar(250)
                @SherTeam  -- SHER_TEAM - varchar(3)
              );              
   END
   ELSE
   BEGIN
      UPDATE dbo.Send_File
         SET SUBJ_DESC = @Subject
            ,SEND_DATE = @SendDate
            ,UPLD_TYPE = @UpldType
            ,SDRC_TYPE = @SdrcType
            ,FILE_PATH = @FilePath
            ,FILE_SRVR_LINK = @FileSrvrLink
            ,URL_LINK = @UrlLink
            ,URL_NAME = @UrlName
            ,SHER_TEAM = @SherTeam
            ,CMNT_CMID = @Cmid
       WHERE RQRO_RQST_RQID = @RqroRqstRqid
         AND RQRO_RWNO = @RqroRwno
         AND SERV_FILE_NO = @ServFileNo
         AND SFID = @Sfid;
   END
   COMMIT TRAN OPR_SSAV_T;
   END TRY
   BEGIN CATCH
      DECLARE @ErrorMessage NVARCHAR(4000);
      SET @ErrorMessage = ERROR_MESSAGE();
      RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN OPR_SSAV_T;
   END CATCH;      
END
GO
