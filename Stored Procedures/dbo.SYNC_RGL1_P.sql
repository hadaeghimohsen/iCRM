SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SYNC_RGL1_P]
	@NewReglYear SMALLINT
  ,@NewReglCode INT
  ,@OldReglYear SMALLINT
  ,@OldReglCode INT
AS
BEGIN
   IF (@OldReglCode >= @NewReglCode AND @OldReglYear >= @NewReglYear) RETURN ;   
   
   DECLARE @RqtpCode VARCHAR(3)
          ,@RqttCode VARCHAR(3)
          ,@PermStat VARCHAR(3);
          	
	DECLARE C$SyncRqrq CURSOR FOR
	   SELECT Rqtp_Code, Rqtt_Code, Perm_Stat
	     FROM dbo.Request_Requester
	    WHERE Regl_Year = @OldReglYear
	      AND Regl_Code = @OldReglCode;
	      
	OPEN C$SyncRqrq;
	NextSyncRqrq:
	FETCH NEXT FROM C$SyncRqrq INTO @RqtpCode, @RqttCode, @PermStat;
	
	IF @@FETCH_STATUS <> 0
	   GOTO EndSyncRqrq;
	
	UPDATE dbo.Request_Requester
	   SET PERM_STAT = @PermStat
	 WHERE REGL_YEAR = @NewReglYear
	   AND REGL_CODE = @NewReglCode
	   AND RQTP_CODE = @RqtpCode
	   AND RQTT_CODE = @RqttCode;
	   
	GOTO NextSyncRqrq;
	EndSyncRqrq:
	CLOSE C$SyncRqrq;
	DEALLOCATE C$SyncRqrq;	   
	
	MERGE dbo.Expense_Cash T
	USING (
	   SELECT *
	     FROM dbo.Expense_Cash S
	    WHERE S.Regl_Year = @OldReglYear
	      AND S.Regl_Code = @OldReglCode
	      AND S.Excs_Stat = '002'
	) S
	ON (T.Regl_Year = @NewReglYear AND T.Regl_Code = @NewReglCode
	AND T.Cash_Code = S.Cash_Code 
	AND T.Regn_Code = S.Regn_Code 
	AND T.Regn_Prvn_Code = S.Regn_Prvn_Code)
	WHEN MATCHED THEN
	   UPDATE
	      SET Excs_Stat = S.Excs_Stat;


   DECLARE C$OldRegl CURSOR FOR
      SELECT Rqrq.Rqtp_Code, 
             Rqrq.Rqtt_Code, 
             Extp.Epit_Code, 
             Extp.Code, 
             Expn.Pric, 
             Expn.BTRF_Code, 
             Expn.TRFD_Code, 
             Expn.Expn_Stat, 
             Expn.Expn_Desc,
             Expn.ADD_QUTS,
             Expn.COVR_DSCT,
             Expn.EXPN_TYPE,
             Expn.BUY_PRIC,
             Expn.BUY_EXTR_PRCT,
             Expn.NUMB_OF_STOK,
             Expn.NUMB_OF_SALE,
             Expn.NUMB_OF_REMN_DNRM,
             Expn.Ordr_Item,
             Expn.NUMB_OF_MONT,
             Expn.VOLM_OF_TRFC,
             Expn.AUTO_ADD,
             Expn.MODL_NUMB_BAR_CODE,
             Expn.COVR_TAX
        FROM Request_Requester Rqrq
            ,Expense_Type Extp
            ,Expense Expn
       WHERE Rqrq.CODE = Extp.RQRQ_CODE
         AND Extp.CODE = Expn.EXTP_CODE
         AND Rqrq.REGL_YEAR = @OldReglYear
         AND Rqrq.REGL_CODE = @OldReglCode
         --AND Expn.EXPN_STAT = '002'
         AND Expn.Pric > 0;
    
    DECLARE @EpitCode BIGINT
           ,@ExtpCode BIGINT
           ,@Pric     INT
           ,@ExpnStat VARCHAR(3)
           ,@ExpnDesc NVARCHAR(250)
           ,@BTRFCode BIGINT
           ,@TRFDCode BIGINT
           ,@AddQuts  VARCHAR(3)
           ,@CovrDsct VARCHAR(3)
           ,@ExpnType VARCHAR(3)
           ,@BuyPric INT
           ,@BuyExtrPrct INT
           ,@NumbOfStok INT
           ,@NumbOfSale INT
           ,@NumbOfRemnDnrm INT
           ,@OrdrItem BIGINT
           ,@NumbOfMont INT
           ,@VolmOfTrfc INT -- MB
           ,@AutoAdd VARCHAR(3)
           ,@ModlNumbBarCode VARCHAR(50)
           ,@CovrTax VARCHAR(3);
    
    OPEN C$OldRegl;
    NextOldRegl:
    FETCH NEXT FROM C$OldRegl INTO @RqtpCode, @RqttCode, @EpitCode, @ExtpCode, @Pric, @BTRFCode, @TRFDCode, @ExpnStat, @ExpnDesc, @AddQuts, @CovrDsct, @ExpnType, @BuyPric, @BuyExtrPrct, @NumbOfStok, @NumbOfSale, @NumbOfRemnDnrm, @OrdrItem, @NumbOfMont, @VolmOfTrfc, @AutoAdd, @ModlNumbBarCode, @CovrTax;
    
    IF @@FETCH_STATUS <> 0
      GOTO EndFetchOldRegl;
    
    UPDATE Expense
       SET PRIC = @Pric
          ,EXPN_STAT = @ExpnStat
          ,EXPN_DESC = /*(SELECT EPIT_DESC FROM Expense_Item WHERE CODE = @EpitCode)--*/@ExpnDesc           
          ,ADD_QUTS = @AddQuts
          ,COVR_DSCT = @CovrDsct
          ,EXPN_TYPE = @ExpnType
          ,BUY_PRIC = @BuyPric
          ,BUY_EXTR_PRCT = @BuyExtrPrct
          ,NUMB_OF_STOK = @NumbOfStok
          ,NUMB_OF_SALE = @NumbOfSale
          ,NUMB_OF_REMN_DNRM = @NumbOfRemnDnrm
          ,ORDR_ITEM = @OrdrItem
          ,NUMB_OF_MONT = @NumbOfMont
          ,VOLM_OF_TRFC = @VolmOfTrfc
          ,AUTO_ADD = @AutoAdd
          ,MODL_NUMB_BAR_CODE = @ModlNumbBarCode
          ,COVR_TAX = @CovrTax
     WHERE Extp_Code IN (
      SELECT Expn.EXTP_CODE
        FROM Request_Requester Rqrq
            ,Expense_Type Extp
            ,Expense Expn
       WHERE Rqrq.CODE = Extp.RQRQ_CODE
         AND Extp.CODE = Expn.EXTP_CODE
         AND Rqrq.REGL_YEAR = @NewReglYear
         AND Rqrq.REGL_CODE = @NewReglCode
         AND Rqrq.RQTP_CODE = @RqtpCode
         AND Rqrq.RQTT_CODE = @RqttCode
         AND Extp.EPIT_CODE = @EpitCode
         AND Expn.BTRF_CODE = @BTRFCode
         AND Expn.TRFD_CODE = @TRFDCode
     )
     AND BTRF_CODE = @BTRFCode
     AND TRFD_CODE = @TRFDCode
     AND REGL_YEAR = @NewReglYear
     AND REGL_CODE = @NewReglCode;
    
    GOTO NextOldRegl;
    EndFetchOldRegl:
    CLOSE C$OldRegl;
    DEALLOCATE C$OldRegl;
    
    DECLARE C$SyncRqdc CURSOR FOR
      SELECT Code, Rqtp_Code, Rqtt_Code
        FROM Request_Requester
       WHERE Regl_Year = @NewReglYear
         AND Regl_Code = @NewReglCode;
    
    DECLARE @RqrqCode BIGINT;
    
    OPEN C$SyncRqdc;
    NEXTC$SYNCRQDC:
    FETCH NEXT FROM C$SyncRqdc INTO @RqrqCode, @RqtpCode, @RqttCode;
    
    IF @@FETCH_STATUS <> 0
      GOTO ENDC$SYNCRQDC;
    EXEC CRET_RQDC_P @RqrqCode, @RqtpCode, @RqttCode;
    
    GOTO NEXTC$SYNCRQDC;
    ENDC$SYNCRQDC:
    CLOSE C$SyncRqdc;
    DEALLOCATE C$SyncRqdc;
    
    --RAISERROR('Error', 16, 1);
    
    -- 1395/03/17 * اضافه کردن رقم های تخفیفات آیین نامه برای سازمانها و موسسات
    MERGE dbo.Basic_Calculate_Discount T
    USING(
      SELECT *
        FROM dbo.Basic_Calculate_Discount 
       WHERE REGL_YEAR = @OldReglYear
         AND REGL_CODE = @OldReglCode
    ) S
    ON (
      T.SUNT_BUNT_DEPT_ORGN_CODE = S.SUNT_BUNT_DEPT_ORGN_CODE AND
      T.SUNT_BUNT_DEPT_CODE = S.SUNT_BUNT_DEPT_CODE AND
      T.SUNT_BUNT_CODE = S.SUNT_BUNT_CODE AND
      T.SUNT_CODE = S.SUNT_CODE AND
      T.REGL_YEAR = @NewReglYear AND
      T.REGL_CODE = @NewReglCode AND
      T.EPIT_CODE = S.EPIT_CODE AND
      T.ACTN_TYPE = S.ACTN_TYPE
    )
    WHEN NOT MATCHED THEN
      INSERT (SUNT_BUNT_DEPT_ORGN_CODE, SUNT_BUNT_DEPT_CODE, SUNT_BUNT_CODE, SUNT_CODE, REGL_YEAR, REGL_CODE, EPIT_CODE, AMNT_DSCT, PRCT_DSCT, DSCT_TYPE, STAT, ACTN_TYPE, DSCT_DESC, FROM_DATE, TO_DATE )
      VALUES (S.SUNT_BUNT_DEPT_ORGN_CODE, S.SUNT_BUNT_DEPT_CODE, S.SUNT_BUNT_CODE, S.SUNT_CODE, @NewReglYear, @NewReglCode, S.EPIT_CODE, S.AMNT_DSCT, S.PRCT_DSCT, S.DSCT_TYPE, S.STAT, S.ACTN_TYPE, S.DSCT_DESC, S.FROM_DATE, S.TO_DATE );
    
    -- 1395/06/07 * اضافه کردن مدارک و اسناد مورد نیاز ارگان ها و موسسه ها
    /*MERGE dbo.Organ_Document T
    USING (
      SELECT *
        FROM dbo.Organ_Document
       WHERE REGL_YEAR = @OldReglYear
         AND REGL_CODE = @OldReglCode
    ) S
    ON (
      T.SUNT_BUNT_DEPT_ORGN_CODE = S.SUNT_BUNT_DEPT_ORGN_CODE AND
      T.SUNT_BUNT_DEPT_CODE = S.SUNT_BUNT_DEPT_CODE AND
      T.SUNT_BUNT_CODE = S.SUNT_BUNT_CODE AND
      T.SUNT_CODE = S.SUNT_CODE AND
      T.REGL_YEAR = @NewReglYear AND
      T.REGL_CODE = @NewReglCode AND
      T.DCMT_DSID = S.DCMT_DSID
    )
    WHEN NOT MATCHED THEN
      INSERT (ODID, Sunt_Bunt_Dept_Orgn_Code, Sunt_Bunt_Dept_Code, Sunt_Bunt_Code, Sunt_Code, Regl_Year, Regl_Code, Rqdc_Rdid, NEED_TYPE, STAT)
           VALUES (0, S.Sunt_Bunt_Dept_Orgn_Code, S.Sunt_Bunt_Dept_Code, S.Sunt_Bunt_Code, S.Sunt_Code, @NewReglYear, @NewReglCode, S.Rqdc_Rdid, S.NEED_TYPE, S.STAT);
*/
END
GO
