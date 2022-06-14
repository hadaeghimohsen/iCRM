SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[OPR_ASAV_P]
	-- Add the parameters for the stored procedure here
	@X XML
	/*
	<Appointment servfileno="" allday="" fromdate="" todate="" rqrorqstrqid="" rqrorwno="" apid="">
	   <Where cordx="" cord=""></Where>
	   <Comment subject=""></Comment>
	   <Collaborators>
	      <Collaborator jobpcode=""/>
	   </Collaborators>
   </Task>
	*/
AS
BEGIN
   BEGIN TRY
   BEGIN TRAN OPR_ASAV_T
   -- تابع ذخیره سازی مربوط به تماس های مشتری
	DECLARE @ServFileNo BIGINT
	       ,@RqroRqstRqid BIGINT
	       ,@RqroRwno SMALLINT
	       ,@Apid BIGINT
	       ,@Allday VARCHAR(3)
	       ,@FromDate DATETIME
	       ,@ToDate DATETIME
	       ,@Subject NVARCHAR(250)	       
	       ,@Comment NVARCHAR(1000)
	       ,@Where NVARCHAR(1000)
	       ,@CordX FLOAT
	       ,@CordY FLOAT	       
	       ,@RqstRqid BIGINT
	       ,@ProjRqstRqid BIGINT
	       ,@InsertMode VARCHAR(3) = '001'
	       ,@Colr VARCHAR(30);
   
   SELECT @ServFileNo = @X.query('//Appointment').value('(Appointment/@servfileno)[1]', 'BIGINT')
         ,@RqroRqstRqid = @X.query('//Appointment').value('(Appointment/@rqrorqstrqid)[1]', 'BIGINT')
         ,@RqroRwno = @X.query('//Appointment').value('(Appointment/@rqrorwno)[1]', 'SMALLINT')
         ,@Apid = @X.query('//Appointment').value('(Appointment/@apid)[1]', 'BIGINT')
         ,@RqstRqid = @X.query('//Appointment').value('(Appointment/@rqstrqid)[1]', 'BIGINT')
         ,@ProjRqstRqid = @X.query('//Appointment').value('(Appointment/@projrqstrqid)[1]', 'BIGINT')
         ,@AllDay = @X.query('//Appointment').value('(Appointment/@allday)[1]', 'VARCHAR(3)')
         ,@FromDate = @X.query('//Appointment').value('(Appointment/@fromdate)[1]', 'DATETIME')
         ,@ToDate = @X.query('//Appointment').value('(Appointment/@todate)[1]', 'DATETIME')
         ,@Colr = @X.query('//Appointment').value('(Appointment/@colr)[1]', 'VARCHAR(30)')         
         ,@Subject = @X.query('//Comment').value('(Comment/@subject)[1]', 'NVARCHAR(250)')
         ,@Comment = @X.query('//Comment').value('.', 'NVARCHAR(1000)')
         ,@CordX = @X.query('//Where').value('(Where/@cordx)[1]', 'FLOAT')
         ,@CordY = @X.query('//Where').value('(Where/@cordy)[1]', 'FLOAT')
         ,@Where = @X.query('//Where').value('.', 'NVARCHAR(1000)');
   
   -- اگر درخواستی وجود نداشته باشد بایستی ابتدا درخواستی ثبت گردد و با آن شماره درخواست در ادامه در جدوال مربوطه ثبت میکنیم
   IF @RqroRqstRqid IS NULL OR @RqroRqstRqid = 0
   BEGIN
      SET @InsertMode = '002';
      -- بدست آوردن اطلاعات ناحیه و استان
      DECLARE @CntyCode VARCHAR(3)
             ,@PrvnCode VARCHAR(3)
             ,@RegnCode VARCHAR(3);

      SELECT @CntyCode = REGN_PRVN_CNTY_CODE
            ,@PrvnCode = REGN_PRVN_CODE
            ,@RegnCode = REGN_CODE
        FROM dbo.[Service]
       WHERE FILE_NO = @ServFileNo;
      
      -- اگر درخواست پیرویی نیاز به ثبت این درخواست باشد
      IF @RqstRqid IS NULL OR @RqstRqid = 0
         SET @RqstRqid = NULL;
      
      EXEC dbo.INS_RQST_P
           @CntyCode,
           @PrvnCode,
           @RegnCode,
           @RqstRqid,
           '007', -- جلسه حضوری
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
        FROM dbo.Appointment
       WHERE RQRO_RQST_RQID = @RqroRqstRqid
         AND RQRO_RWNO = @RqroRwno
         AND SERV_FILE_NO = @ServFileNo        
   )
   BEGIN
      UPDATE dbo.Request
         SET RQST_STAT = '002'
       WHERE RQID = @RqroRqstRqid;

      INSERT INTO dbo.Appointment
              ( SERV_FILE_NO ,
                RQRO_RQST_RQID ,
                RQRO_RWNO ,
                SUBJ_DESC ,
                ALL_DAY ,
                FROM_DATE ,
                TO_DATE ,
                APON_WHER ,
                CORD_X ,
                CORD_Y ,
                APON_CMNT 
              )
      VALUES  ( @ServFileNo , -- SERV_FILE_NO - bigint
                @RqroRqstRqid , -- RQRO_RQST_RQID - bigint
                @RqroRwno , -- RQRO_RWNO - smallint
                @Subject , -- SUBJ_DESC - nvarchar(250)
                @Allday , -- ALL_DAY - varchar(3)
                @FromDate , -- FROM_DATE - datetime
                @ToDate , -- TO_DATE - datetime
                @Where , -- APON_WHER - nvarchar(1000)
                @CordX , -- CORD_X - float
                @CordY, -- CORD_Y - float
                @Comment  -- APON_CMNT - nvarchar(1000)
              );              
   END
   ELSE
   BEGIN
      PRINT @RqroRqstRqid
      PRINT @RqroRwno
      PRINT @Apid
      
      UPDATE dbo.Appointment
         SET ALL_DAY = @Allday
            ,FROM_DATE = @FromDate
            ,TO_DATE = @ToDate
            ,APON_WHER = @Where
            ,CORD_X = @CordX
            ,CORD_Y = @CordY
            ,SUBJ_DESC = @Subject
            ,APON_CMNT = @Comment
       WHERE RQRO_RQST_RQID = @RqroRqstRqid
         AND RQRO_RWNO = @RqroRwno
         AND APID = @Apid;
   END
   
   -- ذخیره سازی همکاران در این وظیفه
   Declare C$Collaborator Cursor For
       Select r.query('.').value('(Collaborator/@jobpcode)[1]', 'BIGINT')
         from @x.nodes('//Collaborator') t(r);
   
   Declare @JobpCode Bigint;
   
   OPEN C$Collaborator;
   L$FETCH$1:
   FETCH NEXT FROM C$Collaborator INTO @JobpCode;
   
   IF @@FETCH_STATUS <> 0
      GOTO L$CLOSE$1;
   
   IF NOT EXISTS(
      SELECT *
        FROM Collaborator
       WHERE RQRO_RQST_RQID = @RqroRqstRqid
         AND RQRO_RWNO = @RqroRwno
         AND JOBP_CODE = @JobpCode
   )   
   BEGIN
      INSERT INTO Collaborator (RQRO_RQST_RQID, RQRO_RWNO, JOBP_CODE)
      VALUES (@RqroRqstRqid, @RqroRwno, @JobpCode);
   END
   
   GOTO L$FETCH$1;
   L$CLOSE$1:
   CLOSE C$Collaborator;
   DEALLOCATE C$Collaborator;
   
   -- این قسمت برای ثبت اطلاعات یادآوری در جدول اصلی می باشد
   IF @InsertMode = '002'
   BEGIN
      UPDATE dbo.Appointment
         SET MDFY_DATE = GETDATE()
       WHERE RQRO_RQST_RQID = @RqroRqstRqid;         
   END
   
   COMMIT TRAN OPR_ASAV_T;
   END TRY
   BEGIN CATCH
      DECLARE @ErrorMessage NVARCHAR(4000);
      SET @ErrorMessage = ERROR_MESSAGE();
      RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN OPR_ASAV_T;
   END CATCH;      
END
GO
