SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[OPR_PSAV_P] @X XML
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN OPR_PSAV_T;
   /*
      <Project rqstrqid="" servfileno="" rqrorqstrqid="" rqrorwno="" rqstdesc="">
         <Service_Projects>
            <Service_Project jbprcode="" code=""/>
         </Service_Projects>
      </Project>
   */
   -- تابع ذخیره سازی مربوط به تماس های مشتری
        DECLARE @RqstRqid BIGINT ,
            @ProjInqrCode VARCHAR(50),
            @LettNo VARCHAR(15),
            @LettDate DATE,
            @ServFileNo BIGINT ,
            @RqroRqstRqid BIGINT ,
            @RqroRwno SMALLINT ,
            @RqstDesc NVARCHAR(1000),
            @Colr VARCHAR(30);
   
        SELECT  @RqstRqid = @X.query('//Project').value('(Project/@rqstrqid)[1]', 'BIGINT') ,
                @ProjInqrCode = @X.query('//Project').value('(Project/@projinqrcode)[1]', 'VARCHAR(50)') ,
                @LettNo = @X.query('//Project').value('(Project/@lettno)[1]', 'VARCHAR(15)') ,
                @LettDate = @X.query('//Project').value('(Project/@lettdate)[1]', 'DATE') ,
                @ServFileNo = @X.query('//Project').value('(Project/@servfileno)[1]', 'BIGINT') ,
                @RqroRqstRqid = @X.query('//Project').value('(Project/@rqrorqstrqid)[1]', 'BIGINT') ,
                @RqstDesc = @X.query('//Project').value('(Project/@rqstdesc)[1]', 'NVARCHAR(1000)'),
                @Colr = @X.query('//Project').value('(Project/@colr)[1]', 'VARCHAR(30)');
   
   -- اگر درخواستی وجود نداشته باشد بایستی ابتدا درخواستی ثبت گردد و با آن شماره درخواست در ادامه در جدوال مربوطه ثبت میکنیم
        IF @RqroRqstRqid IS NULL
            OR @RqroRqstRqid = 0
            BEGIN
      -- بدست آوردن اطلاعات ناحیه و استان
                DECLARE @CntyCode VARCHAR(3) ,
                    @PrvnCode VARCHAR(3) ,
                    @RegnCode VARCHAR(3);
                SELECT  @CntyCode = REGN_PRVN_CNTY_CODE ,
                        @PrvnCode = REGN_PRVN_CODE ,
                        @RegnCode = REGN_CODE
                FROM    dbo.[Service]
                WHERE   FILE_NO = @ServFileNo;
       
      -- اگر ثبت وظیفه از طریق تماس تلفنی باشد شماره درخواست تماس تلفنی را برای درخواست وظیفه ثبت میکنیم
                IF @RqstRqid IS NULL
                    OR @RqstRqid = 0
                    SET @RqstRqid = NULL;       
      
                EXEC dbo.INS_RQST_P @CntyCode, @PrvnCode, @RegnCode, @RqstRqid,
                    '013', -- ثبت پروژه
                    '004', -- به درخواست شرکت
                    @LettNo, @LettDate, NULL, @RqroRqstRqid OUT;
      -- پایان انجام ثبت درخواست
            END;
   
   -- 1396/11/19 * بررسی اینکه شماره کد سازمانی قبلا برای درخواست دیگری ثبت نشده باشد
   IF @ProjInqrCode = ''
      SET @ProjInqrCode = NULL;
      
   IF @ProjInqrCode IS NOT NULL AND EXISTS(SELECT * FROM dbo.Request WHERE RQTP_CODE = '013' AND RQID != @RqroRqstRqid AND PROJ_INQR_CODE = @ProjInqrCode)
   BEGIN
      RAISERROR(N'این شماره داخلی کد سازمانی قبلا برای شماره پروژه دیگری ثبت شده است. لطفا بررسی و اصلاح کنید', 16, 1);
      RETURN;
   END
   
   -- ثبت عنوان پروژه
        UPDATE  dbo.Request
        SET     RQST_DESC = @RqstDesc
               ,COLR = @Colr
               ,PROJ_INQR_CODE = @ProjInqrCode
               ,LETT_NO = @LettNo
               ,LETT_DATE = @LettDate
        WHERE   RQID = @RqroRqstRqid;
   
        DECLARE C$Srpr CURSOR
        FOR
        SELECT  r.query('.').value('(Service_Project/@jbprcode)[1]', 'BIGINT') ,
                r.query('.').value('(Service_Project/@recstat)[1]',
                                   'VARCHAR(3)') ,
                r.query('.').value('(Service_Project/@code)[1]', 'BIGINT') ,
                r.query('.').value('(Service_Project/@rqrorwno)[1]',
                                   'SMALLINT') ,
                r.query('.').value('(Service_Project/@servfileno)[1]',
                                   'BIGINT')
        FROM    @X.nodes('//Service_Project') t ( r );

        DECLARE @jbprcode BIGINT ,
            @code BIGINT ,
            @recstat VARCHAR(3);

        OPEN [C$Srpr];
        L$Loop:
        FETCH NEXT FROM [C$Srpr] INTO @jbprcode, @recstat, @code, @RqroRwno,
            @ServFileNo;

        IF @@FETCH_STATUS <> 0
            GOTO L$EndLoop;
   
   -- ثبت ردیف درخواست       
        SELECT  @RqroRwno = RWNO
        FROM    Request_Row
        WHERE   RQST_RQID = @RqroRqstRqid
                AND SERV_FILE_NO = @ServFileNo;
  
        IF @RqroRwno IS NULL
            OR @RqroRwno = 0
            BEGIN
                EXEC INS_RQRO_P @RqroRqstRqid, @ServFileNo, @RqroRwno OUT;
            END;
       
        IF @code = 0
            AND NOT EXISTS ( SELECT *
                             FROM   dbo.Service_Project
                             WHERE  RQRO_RQST_RQID = @RqroRqstRqid
                                    AND RQRO_RWNO = @RqroRwno
                                    AND JBPR_CODE = @jbprcode )
            INSERT  INTO dbo.Service_Project
                    ( RQRO_RQST_RQID ,
                      RQRO_RWNO ,
                      JBPR_CODE ,
                      SERV_FILE_NO_DNRM ,
                      CODE ,
                      REC_STAT
                    )
            VALUES  ( @RqroRqstRqid ,
                      @RqroRwno ,
                      @jbprcode ,
                      @ServFileNo ,
                      0 ,
                      '002'
                    );
        ELSE
            IF @code != 0
                UPDATE  dbo.Service_Project
                SET     REC_STAT = @recstat
                WHERE   CODE = @code; 

        GOTO L$Loop;
        L$EndLoop:
        CLOSE [C$Srpr];
        DEALLOCATE [C$Srpr];
      
        COMMIT TRAN OPR_PSAV_T;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        SET @ErrorMessage = ERROR_MESSAGE();
        RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
        ROLLBACK TRAN OPR_PSAV_T;   
    END CATCH;	
END;
GO
