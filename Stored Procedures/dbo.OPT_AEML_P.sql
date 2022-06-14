SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[OPT_AEML_P]
   @X XML
AS
BEGIN
   BEGIN TRY
      BEGIN TRAN OPT_AEML_T
      
      -- (1st) Frist Step : Get Service For Send Email
      DECLARE C$Serv CURSOR FOR
         SELECT FILE_NO, EMAL_ADRS_DNRM
           FROM dbo.[VF$Services](@x.query('//Filtering'));
      
      DECLARE @FileNo BIGINT
             ,@EmalAdrs VARCHAR(250);
      
      -- SendOptions
      DECLARE @ScheduleType VARCHAR(3), -- 001 : Manual, 002 : Now
              @ScheduleDateTime DATETIME,
              @Subject NVARCHAR(250),
              @Comment NVARCHAR(4000),
              @RequestSrvcType VARCHAR(3),
              @RequestSorcType VARCHAR(3),
              @FileAttachmentsCount INT;
      
      SELECT @ScheduleType = @X.query('//Schedule').value('(Schedule/@type)[1]', 'VARCHAR(3)')
            ,@ScheduleDateTime = @X.query('//Schedule').value('(Schedule/@datetime)[1]', 'DATETIME')
            ,@Subject = @X.query('//Caption').value('(Caption/@subject)[1]', 'NVARCHAR(250)')
            ,@Comment = @X.query('//Caption').value('(Caption/@comment)[1]', 'NVARCHAR(4000)')
            ,@RequestSrvcType = @X.query('//Request').value('(Request/@srvctype)[1]', 'VARCHAR(3)')
            ,@RequestSorcType = @X.query('//Request').value('(Request/@sorctype)[1]', 'VARCHAR(3)')
            ,@FileAttachmentsCount = @X.query('//FileAttachments').value('(FileAttachments/@cont)[1]', 'INT');
              
      OPEN [C$Serv];
      L$LoopC$Serv:
      FETCH NEXT FROM [C$Serv] INTO @FileNo, @EmalAdrs;
      
      IF @@FETCH_STATUS <> 0
         GOTO L$EndLoopC$Serv;
      
      -- (2nd) Second Step : Save request email for service
      BEGIN
         IF (
               (@EmalAdrs IS NULL OR @EmalAdrs = '') AND            
               NOT EXISTS(
                  SELECT *
                    FROM dbo.Contact_Info ci, @X.nodes('//Contact_Info') t(cr)
                   WHERE ci.SERV_FILE_NO = @FileNo
                     AND ci.APBS_CODE = cr.query('.').value('(Contact_Info/@code)[1]', 'BIGINT')
                     AND ci.CONT_DESC IS NOT NULL
                     AND ci.CONT_DESC LIKE '%@%'
               )
            ) OR (
               EXISTS (
                  SELECT *
                    FROM dbo.Service
                   WHERE FILE_NO = @FileNo
                     AND SERV_STAT = '001' -- قفل در فرآیند دیگر
               )               
            )
         BEGIN
            GOTO L$LoopC$Serv;
         END
         
         DECLARE @XP XML = (
            SELECT @FileNo AS '@fileno'
                  ,@Comment AS '@text'
               FOR XML PATH('TemplateToText')
         );
         
         DECLARE @ServCmnt NVARCHAR(4000);
         SET @XP = dbo.GET_TEXT_F(@XP);
         SELECT @ServCmnt = @XP.query('//Result').value('.', 'NVARCHAR(4000)');
         
         -- IF exists email for service now create request for send email
         IF @EmalAdrs IS NULL OR @EmalAdrs = ''         
            SET @XP = (
               SELECT @FileNo AS '@servfileno'
                     ,@ScheduleDateTime AS '@senddate'
                     ,0 AS '@rqrorqstrqid'
                     ,0 AS '@rqrorwno'
                     ,0 AS '@emid'
                     ,@RequestSrvcType AS '@rqstsrvctype'
                     ,@RequestSorcType AS '@rqstsorctype'
                     ,0 AS '@rqstrqid'
                     ,'005' AS '@sendstat'
                     ,@Subject AS 'Comment/@subject'
                     ,@ServCmnt AS 'Comment'
                     ,(
                        SELECT ci.CONT_DESC AS 'EmailTo'
                          FROM dbo.Contact_Info ci, @X.nodes('//Contact_Info') t(cr)
                         WHERE ci.SERV_FILE_NO = @FileNo
                           AND ci.APBS_CODE = cr.query('.').value('(Contact_Info/@code)[1]', 'BIGINT')
                           AND ci.CONT_DESC IS NOT NULL
                           AND ci.CONT_DESC LIKE '%@%'
                           FOR XML PATH(''), ROOT('EmailTos'), TYPE                           
                     )
                  FOR XML PATH('Email')
            );
         ELSE
             SET @XP = (
               SELECT @FileNo AS '@servfileno'
                     ,@ScheduleDateTime AS '@senddate'
                     ,0 AS '@rqrorqstrqid'
                     ,0 AS '@rqrorwno'
                     ,0 AS '@emid'
                     ,@RequestSrvcType AS '@rqstsrvctype'
                     ,@RequestSorcType AS '@rqstsorctype'
                     ,0 AS '@rqstrqid'
                     ,'003' AS '@sendstat'
                     ,@Subject AS 'Comment/@subject'
                     ,@ServCmnt AS 'Comment'
                     ,(
                        SELECT @EmalAdrs AS 'EmailTo'                          
                           FOR XML PATH(''), ROOT('EmailTos'), TYPE                           
                     )
                  FOR XML PATH('Email')
            );
      END
      
      -- ثبت موقت درخواست ارسال ایمیل برای مشتری
      EXEC dbo.OPR_MSAV_P @X = @XP -- xml
      
      DECLARE @EmalRqid BIGINT;
      
      SELECT TOP 1 @EmalRqid = r.RQID
        FROM dbo.Request r, dbo.Request_Row rr
       WHERE r.rqid = rr.RQST_RQID
         AND r.RQTP_CODE = '010'      
         AND r.RQTT_CODE = '004'
         AND r.RQST_STAT = '002'
         AND r.CRET_BY = UPPER(SUSER_NAME())
         AND CAST(r.CRET_DATE AS DATE) = CAST(GETDATE() AS DATE)
         AND rr.SERV_FILE_NO = @FileNo
    ORDER BY r.CRET_DATE DESC;
         
      -- بروز رسانی درخواست
      UPDATE dbo.Request
         SET SRVC_TYPE = @RequestSrvcType
            ,SORC_TYPE = @RequestSorcType
       WHERE rqid = @EmalRqid;
      
      
      IF @FileAttachmentsCount = 0
         GOTO L$LoopC$Serv;
      
      DECLARE C$Files CURSOR FOR
         SELECT f.query('.').value('(FileAttachment/@filepath)[1]', 'NVARCHAR(4000)')
               ,f.query('.').value('(FileAttachment/@fileserverlink)[1]', 'NVARCHAR(4000)')
           FROM @X.nodes('//FileAttachment') t(f);
      
      DECLARE @FilePath NVARCHAR(4000)
             ,@FileServerLink NVARCHAR(4000);
      
      OPEN [C$Files];
      L$LoopC$File:
      FETCH NEXT FROM [C$Files] INTO @FilePath, @FileServerLink;
      
      IF @@FETCH_STATUS <> 0
         GOTO L$EndLoopC$File
      
      SET @XP = (
         SELECT @FileNo AS '@servfileno'
               ,@ScheduleDateTime AS '@senddate'
               ,0 AS '@rqrorqstrqid'
               ,0 AS '@rqrorwno'
               ,0 AS '@cmid'
               ,@RequestSrvcType AS '@rqstsrvctype'
               ,@RequestSorcType AS '@rqstsorctype'
               ,@EmalRqid AS '@rqstrqid'
               ,'001' AS '@sherteam'
               ,0 AS '@sfid'
               ,@Subject AS '@subject'               
               ,'001' AS '@sendtype'
               ,'002' AS '@sdrctype'
               ,'001' AS '@upldtype'
               ,@FilePath AS '@filepath'
               ,@FileServerLink AS '@filesrvrlink'
            FOR XML PATH('SendFile')
      );
      
      EXEC dbo.OPR_SSAV_P @X = @XP -- xml
      
      DECLARE @SndfRqid BIGINT;
      
      SELECT TOP 1 @SndfRqid = r.RQID
        FROM dbo.Request r, dbo.Request_Row rr
       WHERE r.rqid = rr.RQST_RQID
         AND r.RQTP_CODE = '006'      
         AND r.RQTT_CODE = '004'
         AND r.RQST_STAT = '002'
         AND r.CRET_BY = UPPER(SUSER_NAME())
         AND CAST(r.CRET_DATE AS DATE) = CAST(GETDATE() AS DATE)
         AND rr.SERV_FILE_NO = @FileNo
    ORDER BY r.CRET_DATE DESC;
         
      -- بروز رسانی درخواست
      UPDATE dbo.Request
         SET SRVC_TYPE = @RequestSrvcType
            ,SORC_TYPE = @RequestSorcType
       WHERE rqid = @SndfRqid;
      
      GOTO L$LoopC$File;
      L$EndLoopC$File:
      CLOSE [C$Files];
      DEALLOCATE [C$Files];
         
      GOTO L$LoopC$Serv;
      L$EndLoopC$Serv:
      CLOSE [C$Serv];
      DEALLOCATE [C$Serv];
      
      COMMIT TRAN OPT_AEML_T;      
      RETURN 0;
   END TRY
   BEGIN CATCH
      DECLARE @ErrorMessage NVARCHAR(4000);
      SET @ErrorMessage = ERROR_MESSAGE();
      RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN OPT_AEML_T;
      RETURN -1;
   END CATCH;
END;
GO
