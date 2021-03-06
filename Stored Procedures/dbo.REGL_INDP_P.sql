SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[REGL_INDP_P]
	@X XML
AS
BEGIN
   BEGIN TRY
   BEGIN TRAN REGL_INDP_P_T
 	   -- بررسی دسترسی کاربر
	   DECLARE @AP BIT
	          ,@AccessString VARCHAR(250);
	   SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>116</Privilege><Sub_Sys>5</Sub_Sys></AP>';	
      EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
      IF @AP = 0 
      BEGIN
         RAISERROR ( N'خطا - عدم دسترسی به ردیف 116 سطوح امینتی : شما مجوز افزایش کاهش هزینه آیین نامه به صورت گروهی را ندارید', -- Message text.
                  16, -- Severity.
                  1 -- State.
                  );
         RETURN;
      END
      -- پایان دسترسی
      
      --SELECT @X;   
      DECLARE @ReglYear SMALLINT
             ,@ReglCode INT
             ,@ActnType VARCHAR(3)
             ,@PricType BIT
             ,@Prct INT
             ,@Pric INT
             ,@RqtpCode VARCHAR(3)
             ,@RqttCode VARCHAR(3)
             ,@EpitCode BIGINT
             ,@BTRFCode BIGINT
             ,@TRFDCode BIGINT
             ,@EnblTRFD BIT;          
       
       SELECT @ReglYear = @X.query('//Regulation').value('(Regulation/@year)[1]', 'SMALLINT')
             ,@ReglCode = @X.query('//Regulation').value('(Regulation/@code)[1]', 'SMALLINT')
             ,@ActnType = @X.query('//Regulation').value('(Regulation/@actntype)[1]', 'VARCHAR(3)')
             ,@PricType = @X.query('//Regulation').value('(Regulation/@prictype)[1]', 'BIT')
             ,@Prct     = @X.query('//Regulation').value('(Regulation/@prct)[1]', 'SMALLINT')
             ,@Pric     = @X.query('//Regulation').value('(Regulation/@pric)[1]', 'INT')
             ,@EnblTRFD = @X.query('//Regulation').value('(Regulation/@enblTRFD)[1]', 'BIT');
       
       DECLARE C$REGLRQTP CURSOR FOR
         SELECT r.query('.').value('(Request_Type/@code)[1]','VARCHAR(3)')
           FROM @X.nodes('//Request_Type') RQTPV(r);
       
       DECLARE C$REGLRQTT CURSOR FOR
         SELECT r.query('.').value('(Requester_Type/@code)[1]','VARCHAR(3)')
           FROM @X.nodes('//Requester_Type') RQTTV(r);
       
       DECLARE C$REGLEPIT CURSOR FOR
         SELECT r.query('.').value('(Expense_Item/@code)[1]','BIGINT')
           FROM @X.nodes('//Expense_Item') EPITV(r);
       
       DECLARE C$REGLBTRF CURSOR FOR
         SELECT r.query('.').value('(Base_Tariff/@code)[1]','BIGINT')
           FROM @X.nodes('//Base_Tariff') BTRFV(r);
       
       DECLARE C$REGLTRFD CURSOR FOR
         SELECT r.query('.').value('(Category/@code)[1]','BIGINT')
           FROM @X.nodes('//Category') TRFDV(r);
       
       OPEN C$REGLRQTP;
       NEXTC$REGLRQTP:
       FETCH NEXT FROM C$REGLRQTP INTO @RqtpCode;
       
       IF @@FETCH_STATUS <> 0
         GOTO ENDC$REGLRQTP;
       
       OPEN C$REGLRQTT;
       NEXTC$REGLRQTT:
       FETCH NEXT FROM C$REGLRQTT INTO @RqttCode;
       
       IF @@FETCH_STATUS <> 0
         GOTO ENDC$REGLRQTT;

       OPEN C$REGLEPIT;
       NEXTC$REGLEPIT:
       FETCH NEXT FROM C$REGLEPIT INTO @EpitCode;
       
       IF @@FETCH_STATUS <> 0
         GOTO ENDC$REGLEPIT;
       
       OPEN C$REGLBTRF;
       NEXTC$REGLBTRF:
       FETCH NEXT FROM C$REGLBTRF INTO @BTRFCode;
       
       IF @@FETCH_STATUS <> 0
         GOTO ENDC$REGLBTRF;
        
       OPEN C$REGLTRFD;
       NEXTC$REGLTRFD:
       FETCH NEXT FROM C$REGLTRFD INTO @TRFDCode;
       
       IF @@FETCH_STATUS <> 0
         GOTO ENDC$REGLTRFD;
       
       UPDATE Expense
          SET PRIC = PRIC + 
                     CASE @ActnType
                        WHEN '001' THEN -- افزایش
                           CASE @PricType
                              WHEN 1 THEN -- درصدی
                                 (PRIC * @Prct) / 100
                              WHEN 0 THEN -- مبلغی
                                 @Pric
                           END
                        WHEN '002' THEN -- کاهش
                           CASE @PricType
                              WHEN 1 THEN -- درصدی
                                 -1 * (PRIC * @Prct) / 100
                              WHEN 0 THEN -- مبلغی
                                 -1 * @Pric
                           END
                        WHEN '003' THEN -- ثابت
                           @Pric - PRIC
                     END
              ,EXPN_STAT = CASE @EnblTRFD
                              WHEN 1 THEN
                                 '002'
                              WHEN 0 THEN
                                 '001'
                           END
        WHERE EXTP_CODE IN (
         SELECT E.CODE
           FROM Request_Requester R, Expense_Type E
          WHERE R.CODE = E.RQRQ_CODE
            AND R.RQTP_CODE = @RqtpCode
            AND R.RQTT_CODE = @RqttCode
            AND E.EPIT_CODE = @EpitCode
        )
        AND BTRF_CODE = @BTRFCode
        AND TRFD_CODE = @TRFDCode
        AND (@EnblTRFD = 1 OR EXPN_STAT = '002');
       
       GOTO NEXTC$REGLTRFD;
       ENDC$REGLTRFD:
       CLOSE C$REGLTRFD;
         
       GOTO NEXTC$REGLBTRF;
       ENDC$REGLBTRF:
       CLOSE C$REGLBTRF;
       
         
       GOTO NEXTC$REGLEPIT;
       ENDC$REGLEPIT:
       CLOSE C$REGLEPIT;


       GOTO NEXTC$REGLRQTT;
       ENDC$REGLRQTT:
       CLOSE C$REGLRQTT;

         
       GOTO NEXTC$REGLRQTP;
       ENDC$REGLRQTP:
       CLOSE C$REGLRQTP;       
       
       DEALLOCATE C$REGLRQTP;
       DEALLOCATE C$REGLBTRF;
       DEALLOCATE C$REGLTRFD;
       DEALLOCATE C$REGLEPIT;
       DEALLOCATE C$REGLRQTT;    
    COMMIT TRAN REGL_INDP_P_T;
    END TRY
    BEGIN CATCH
       IF (SELECT CURSOR_STATUS('local','C$REGLBTRF')) >= -1
       BEGIN
         IF (SELECT CURSOR_STATUS('local','C$REGLBTRF')) > -1
          BEGIN
           CLOSE C$REGLBTRF
          END
        DEALLOCATE C$REGLBTRF
       END               
       
       IF (SELECT CURSOR_STATUS('local','C$REGLTRFD')) >= -1
       BEGIN
         IF (SELECT CURSOR_STATUS('local','C$REGLTRFD')) > -1
          BEGIN
           CLOSE C$REGLTRFD
          END
        DEALLOCATE C$REGLTRFD
       END               
       
       IF (SELECT CURSOR_STATUS('local','C$REGLEPIT')) >= -1
       BEGIN
         IF (SELECT CURSOR_STATUS('local','C$REGLEPIT')) > -1
          BEGIN
           CLOSE C$REGLEPIT
          END
        DEALLOCATE C$REGLEPIT
       END               
       
       IF (SELECT CURSOR_STATUS('local','C$REGLRQTT')) >= -1
       BEGIN
         IF (SELECT CURSOR_STATUS('local','C$REGLRQTT')) > -1
          BEGIN
           CLOSE C$REGLRQTT
          END
        DEALLOCATE C$REGLRQTT
       END               
       
       IF (SELECT CURSOR_STATUS('local','C$REGLRQTP')) >= -1
       BEGIN
         IF (SELECT CURSOR_STATUS('local','C$REGLRQTP')) > -1
          BEGIN
           CLOSE C$REGLRQTP
          END
        DEALLOCATE C$REGLRQTP
       END               
       
       DECLARE @ErrorMessage NVARCHAR(MAX);
       SET @ErrorMessage = ERROR_MESSAGE() ;
       RAISERROR ( @ErrorMessage, -- Message text.
          16, -- Severity.
         1 -- State.
       );
       ROLLBACK TRAN;
    END CATCH
END
GO
