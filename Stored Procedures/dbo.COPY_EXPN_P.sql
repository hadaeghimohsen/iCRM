SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[COPY_EXPN_P]
	@REGL_YEAR SMALLINT,
	@REGL_CODE SMALLINT
AS
BEGIN
	-- بررسی اینکه آیا آیین نامه هزینه فعالی درون سیستم هست که بتوان از اطلاعات هزینه آن کپی برداری کرد یا خیر؟
   IF NOT EXISTS(
      SELECT *
        FROM Regulation
       WHERE TYPE = '001' -- آیین نامه حساب
         AND REGL_STAT = '002' -- فعال
   )   
      GOTO L$End;
      
   -- آیین نامه هزینه فعال درون سیستم وجود دارد
   DECLARE C$RegulationExpense CURSOR FOR
   SELECT * FROM V#Regulation_Expense
   WHERE TYPE = '001'
     AND REGL_STAT = '002';
   
   DECLARE @ReglYear SMALLINT
          ,@ReglCode INT
          ,@SubSys   SMALLINT
          ,@Type     VARCHAR(3)
          ,@ReglStat VARCHAR(3)
          ,@ExtpCode BIGINT
          ,@TRFDCode BIGINT
          ,@BTRFCode BIGINT
          ,@ExpnCode BIGINT
          ,@Pric     INT
          ,@ExtrPric INT
          ,@ExpnStat VARCHAR(3)
          ,@AddQust VARCHAR(3)
          ,@CovrDsct VARCHAR(3)
          ,@ExpnType VARCHAR(3)
          ,@BuyPric INT
          ,@BuyExtrPrct INT
          ,@NumbOfStok INT
          ,@NumbOfSale INT
          ,@NumbOfRemnDnrm INT
          ,@OrdrItem BIGINT
          ,@NumOfMont INT
          ,@VolmOfTrfc INT -- MB
          ,@AutoAdd VARCHAR(3)
          ,@ModlNumbBarCode VARCHAR(50)
          ,@CovrTax VARCHAR(3);
   
   OPEN C$RegulationExpense;
   L$NextRERow:
   FETCH NEXT FROM C$RegulationExpense
   INTO @ReglYear
       ,@ReglCode
       ,@SubSys
       ,@Type
       ,@ReglStat
       ,@ExtpCode
       ,@TRFDCode
       ,@BTRFCode
       ,@ExpnCode
       ,@Pric
       ,@ExtrPric
       ,@ExpnStat
       ,@AddQust
       ,@CovrDsct
       ,@ExpnType
       ,@BuyPric
       ,@BuyExtrPrct
       ,@NumbOfStok
       ,@NumbOfSale
       ,@NumbOfRemnDnrm
       ,@OrdrItem
       ,@NumOfMont
       ,@VolmOfTrfc
       ,@AutoAdd
       ,@ModlNumbBarCode
       ,@CovrTax;
       
   IF @@FETCH_STATUS <> 0
      GOTO L$EndFetchRE;

   IF NOT EXISTS(
      SELECT * 
      FROM V#Regulation_Expense
      WHERE YEAR = @REGL_YEAR
        AND CODE = @REGL_CODE
        AND SUB_SYS = @SubSys
        AND TYPE    = @Type
        AND REGL_STAT = @ReglStat
        AND EXTP_CODE = @ExtpCode
        AND TRFD_CODE = @TRFDCode
        AND BTRF_CODE = @BTRFCode
   )
   BEGIN
      --PRINT CAST(@Regl_Year AS VARCHAR(MAX)) + ', ' + CAST(@Regl_Code AS VARCHAR(MAX)) + ', ' + CAST(@TRFDCode AS VARCHAR(MAX)) + ', ' + CAST(@BTRFCode AS VARCHAR(MAX)) + ', ' + CAST(@ExtpCode AS VARCHAR(MAX));
      --PRINT dbo.Gnrt_Nvid_U();
      INSERT INTO Expense (REGL_YEAR,  REGL_CODE,  EXTP_CODE, TRFD_CODE, BTRF_CODE, PRIC,  EXPN_STAT, ADD_QUTS, COVR_DSCT, Expn_Type, Buy_Pric, Buy_Extr_Prct, Numb_Of_Stok, Numb_Of_Sale, Numb_Of_Remn_Dnrm, ORDR_ITEM, NUMB_OF_MONT, VOLM_OF_TRFC, AUTO_ADD, MODL_NUMB_BAR_CODE, COVR_TAX)
      VALUES             (@REGL_YEAR, @REGL_CODE, @ExtpCode, @TRFDCode, @BTRFCode, @Pric, @ExpnStat, @AddQust, @CovrDsct, @ExpnType, @BuyPric, @BuyExtrPrct, @NumbOfStok, @NumbOfSale, @NumbOfRemnDnrm, @OrdrItem, @NumOfMont, @VolmOfTrfc, @AutoAdd, @ModlNumbBarCode, @CovrTax);
   END
   
   GOTO L$NextRERow;
   L$EndFetchRE:
   CLOSE C$RegulationExpense;
   DEALLOCATE C$RegulationExpense;   

   L$End:
   RETURN;
END
GO
