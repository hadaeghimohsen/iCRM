SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[OPR_TSAV_P]
	-- Add the parameters for the stored procedure here
	@X XML
	/*
	<Task servfileno="" duedate="" rqrorqstrqid="" rqrorwno="" tkid="">
	   <Comment subject=""></Comment>
	   <Collaborators>
	      <Collaborator jobpcode=""/>
	   </Collaborators>
   </Task>
	*/
AS
BEGIN
   BEGIN TRY
   BEGIN TRAN OPR_TSAV_T
   -- تابع ذخیره سازی مربوط به تماس های مشتری
	DECLARE @ServFileNo BIGINT
	       ,@RqroRqstRqid BIGINT
	       ,@RqroRwno SMALLINT
	       ,@Tkid BIGINT
	       ,@Subject NVARCHAR(250)
	       ,@DueDate DATETIME
	       ,@Comment NVARCHAR(1000)
	       ,@RqstRqid BIGINT
	       ,@ProjRqstRqid BIGINT
	       ,@TaskStat VARCHAR(3)
	       ,@DeadLineStat VARCHAR(3)
	       ,@DeadLine DATETIME
	       ,@Colr VARCHAR(30)
	       ,@ArchStat VARCHAR(3)
	       ,@InsertMode VARCHAR(3) = '001';
   
   SELECT @ServFileNo = @X.query('//Task').value('(Task/@servfileno)[1]', 'BIGINT')
         ,@RqroRqstRqid = @X.query('//Task').value('(Task/@rqrorqstrqid)[1]', 'BIGINT')
         ,@RqroRwno = @X.query('//Task').value('(Task/@rqrorwno)[1]', 'SMALLINT')
         ,@Tkid = @X.query('//Task').value('(Task/@tkid)[1]', 'BIGINT')
         ,@RqstRqid = @X.query('//Task').value('(Task/@rqstrqid)[1]', 'BIGINT')
         ,@ProjRqstRqid = @X.query('//Task').value('(Task/@projrqstrqid)[1]', 'BIGINT')
         ,@TaskStat = @X.query('//Task').value('(Task/@taskstat)[1]', 'VARCHAR(3)')
         ,@DeadLineStat = @X.query('//Task').value('(Task/@deadlinestat)[1]', 'VARCHAR(3)')
         ,@DeadLine = @X.query('//Task').value('(Task/@deadline)[1]', 'DATETIME')
         ,@Colr = @X.query('//Task').value('(Task/@colr)[1]', 'VARCHAR(30)')
         ,@ArchStat = @X.query('//Task').value('(Task/@archstat)[1]', 'VARCHAR(3)')
         ,@DueDate = @X.query('//Task').value('(Task/@duedate)[1]', 'DATETIME')
         ,@Subject = @X.query('//Comment').value('(Comment/@subject)[1]', 'NVARCHAR(250)')
         ,@Comment = @X.query('//Comment').value('.', 'NVARCHAR(1000)');
   
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
      
      -- اگر ثبت وظیفه از طریق تماس تلفنی باشد شماره درخواست تماس تلفنی را برای درخواست وظیفه ثبت میکنیم
      IF @RqstRqid IS NULL OR @RqstRqid = 0
         SET @RqstRqid = NULL;
          
      EXEC dbo.INS_RQST_P
           @CntyCode,
           @PrvnCode,
           @RegnCode,
           @RqstRqid,
           '009', -- وظیفه
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
   
   -- ثبت رنگ درخواست
   UPDATE dbo.Request
      SET COLR = @Colr
    WHERE RQID = @RqroRqstRqid;
   
   IF NOT EXISTS(
      SELECT *
        FROM dbo.Task
       WHERE RQRO_RQST_RQID = @RqroRqstRqid
         AND RQRO_RWNO = @RqroRwno
         AND SERV_FILE_NO = @ServFileNo        
   )
   BEGIN
      UPDATE dbo.Request
         SET RQST_STAT = '002'
       WHERE RQID = @RqroRqstRqid;

      INSERT INTO dbo.Task
              ( RQRO_RQST_RQID ,
                RQRO_RWNO ,
                SERV_FILE_NO ,
                SUBJ_DESC, 
                DUE_DATE,
                TASK_CMNT,
                TASK_STAT,
                DEAD_LINE_STAT,
                DEAD_LINE, 
                --COLR,
                ARCH_STAT
              )
      VALUES  ( @RqroRqstRqid , -- RQRO_RQST_RQID - bigint
                @RqroRwno , -- RQRO_RWNO - smallint
                @ServFileNo , -- SERV_FILE_NO - bigint
                @Subject ,
                @DueDate,
                @Comment,  -- LOG_CMNT - nvarchar(1000)                
                @TaskStat,
                @DeadLineStat,
                @DeadLine,
                --@Colr,
                @ArchStat
              );              
   END
   ELSE
   BEGIN
      UPDATE dbo.Task
         SET TASK_CMNT = @Comment
            ,DUE_DATE = @DueDate
            ,SUBJ_DESC = @Subject
            ,TASK_STAT = @TaskStat
            ,DEAD_LINE_STAT = @DeadLineStat
            ,DEAD_LINE = @DeadLine
            --,COLR = @Colr
            ,ARCH_STAT = @ArchStat
       WHERE RQRO_RQST_RQID = @RqroRqstRqid
         AND RQRO_RWNO = @RqroRwno
         AND SERV_FILE_NO = @ServFileNo
         AND TKID = @Tkid;
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
      UPDATE dbo.Task
         SET MDFY_DATE = GETDATE()
       WHERE RQRO_RQST_RQID = @RqroRqstRqid;         
   END   
   
   COMMIT TRAN OPR_TSAV_T;
   END TRY
   BEGIN CATCH
      DECLARE @ErrorMessage NVARCHAR(4000);
      SET @ErrorMessage = ERROR_MESSAGE();
      RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN OPR_TSAV_T;
   END CATCH;      
END
GO
