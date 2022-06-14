SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CRET_EXPN_P]
	-- Add the parameters for the stored procedure here
	@ExtpCode BIGINT = NULL,
   @BTRFCode BIGINT = NULL,
   @TRFDCode BIGINT = NULL
AS
BEGIN
   --PRINT 'CRET_EXPN_P';
	DECLARE @ReglYear INT
	       ,@ReglCode SMALLINT;
	
	DECLARE @Code BIGINT;
	       
	BEGIN TRY
      SELECT @ReglCode = CODE
            ,@ReglYear = YEAR
        FROM Regulation
       WHERE TYPE = '001' -- آیین نامه هزینه
         AND REGL_STAT = '002'; -- فعال
   END TRY
   BEGIN CATCH
      RAISERROR ( N'آیین نامه هزینه فعالی درون سیستم وجود ندارد', -- Message text.
            16, -- Severity.
            1 -- State.
            );
      GOTO L$End;
   END CATCH  
   
   DECLARE C$EXTPS CURSOR FOR
            SELECT Extp.Code 
        FROM Regulation Regl
            ,Request_Requester Rqrq
            ,Expense_Type Extp
       WHERE Regl.YEAR = Rqrq.REGL_YEAR
         AND Regl.YEAR = @ReglYear
         AND Regl.CODE = Rqrq.REGL_CODE
         AND Regl.CODE = @ReglCode
         AND Rqrq.CODE = Extp.RQRQ_CODE 
         AND ((@ExtpCode IS NULL) OR (Extp.Code = @ExtpCode))
    ORDER BY RQRQ.Rqtp_Code;
   
   DECLARE C$BTRFS CURSOR FOR
      SELECT Code
        FROM dbo.Base_Tariff
       WHERE ((@BTRFCode IS NULL) OR (Code = @BTRFCode));

   OPEN C$BTRFS;
   L$NextBTRF:
   FETCH NEXT FROM C$BTRFS INTO @BTRFCode;
   
   IF @@FETCH_STATUS <> 0
      GOTO L$EndBTRF;

   DECLARE C$TRFDS CURSOR FOR
      SELECT Code
        FROM dbo.Base_Tariff_Detail
       WHERE ((@TRFDCode IS NULL) OR (Code = @TRFDCode))
         AND ((@BTRFCode IS NULL) OR (BTRF_Code = @BTRFCode))
    ORDER BY Ordr;
         
   OPEN C$TRFDS;
   L$NextTRFD:
   FETCH NEXT FROM C$TRFDS INTO @TRFDCode;
   
   IF @@FETCH_STATUS <> 0
      GOTO L$EndTRFD;
   
   OPEN C$EXTPS;
   L$NextExtp:
   FETCH NEXT FROM C$EXTPS INTO @ExtpCode;
   
   IF @@FETCH_STATUS <> 0
      GOTO L$EndExtp;
   
   IF NOT EXISTS(
      SELECT *
        FROM dbo.Expense
       WHERE REGL_YEAR = @ReglYear
         AND REGL_CODE = @ReglCode
         AND TRFD_CODE = @TRFDCode
         AND BTRF_CODE = @BTRFCode
         AND EXTP_CODE = @ExtpCode
   )
   BEGIN
      L$GNRTNWID:
      SET @Code = dbo.GNRT_NWID_U();
      IF EXISTS(SELECT * FROM Expense WHERE CODE = @Code)
      BEGIN
         --PRINT 'Duplicate Key';
         GOTO L$GNRTNWID;
      END
      INSERT INTO dbo.Expense (CODE, REGL_YEAR, REGL_CODE, TRFD_CODE, BTRF_CODE, EXTP_CODE, PRIC, EXTR_PRCT, EXPN_STAT, ADD_QUTS, COVR_DSCT, EXPN_TYPE, AUTO_ADD, COVR_TAX)
                        VALUES(@Code, @ReglYear, @ReglCode, @TRFDCode, @BTRFCode, @ExtpCode, 0, 0, '001', '001', '002', '001', '001', '002');
   END
   GOTO L$NextExtp;
   L$EndExtp:
   CLOSE C$EXTPS;
   
   GOTO L$NextTRFD;
   L$EndTRFD:
   CLOSE C$TRFDS;      
   DEALLOCATE C$TRFDS;
   SET @TRFDCode = NULL;

   GOTO L$NextBTRF;
   L$EndBTRF:
   CLOSE C$BTRFS;      

   DEALLOCATE C$BTRFS;
   DEALLOCATE C$EXTPS;
   
   L$End:
   RETURN;
END
GO
