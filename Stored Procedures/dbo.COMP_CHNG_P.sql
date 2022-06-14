SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[COMP_CHNG_P]
	-- Add the parameters for the stored procedure here
	@X XML
AS
BEGIN
   BEGIN TRY
   BEGIN TRAN COMP_CHNG_T
	   DECLARE @REGN_PRVN_CNTY_CODE [varchar](3) ,
	           @REGN_PRVN_CODE [varchar](3) ,
	           @REGN_CODE [varchar](3) ,
	           @ISCP_ISCA_ISCG_CODE [varchar](2) ,
	           @ISCP_ISCA_CODE [varchar](2) ,
	           @ISCP_CODE [varchar](6) ,
	           @CODE [bigint] ,
	           @DEBT_DNRM [bigint] ,
	           @NAME [nvarchar](250) ,
	           @Cord_X FLOAT,
	           @Cord_Y FLOAT,
	           @Post_Addr_Zoom FLOAT,
	           @POST_ADRS [nvarchar](1000) ,
	           @EMAL_ADRS [varchar](250) ,
	           @WEB_SITE [varchar](500) ,
	           @COMP_CODE [bigint] ,
	           @COMP_DESC [nvarchar](max) ,
	           @REGS_DATE [date] ,
	           @ZIP_CODE [varchar](20) ,
	           @ECON_CODE [varchar](20) ,
	           @STRT_TIME [datetime] ,
	           @END_TIME [datetime] ,
	           @TYPE [varchar](3) ,
	           @EMPY_NUMB_DNRM [int] ,
	           @BILL_ADDR_X [float] ,
	           @BILL_ADDR_Y [float] ,
	           @BILL_ADDR_ZOOM [float] ,
	           @Bill_Addr NVARCHAR(1000),
	           @SHIP_ADDR_X [float] ,
	           @SHIP_ADDR_Y [float] ,
	           @SHIP_ADDR_ZOOM [float] ,
	           @Ship_Addr NVARCHAR(1000),
	           @DFLT_STAT [varchar](3) ,
	           @Host_Stat VARCHAR(3),
	           @FACE_BOOK_URL [nvarchar](1000) ,
	           @LINK_IN_URL [nvarchar](1000) ,
	           @TWTR_URL [nvarchar](1000) ,
	           @Cell_Phon VARCHAR(11),
	           @Tell_Phon VARCHAR(11),
	           @LAST_SERV_FILE_NO_DNRM [bigint] ,
	           @LAST_RQST_RQID_DNRM [bigint] ,
	           @RECD_STAT [varchar](3),
	           @Ownr_Code BIGINT,
	           @Fax_Numb VARCHAR(15),
	           @Prim_Serv_File_No BIGINT,
	           @Trcb_Tcid BIGINT,
	           @Crdt_Stat VARCHAR(3),
	           @Crdt_Amnt BIGINT,
	           @Pymt_Term VARCHAR(3),
	           @Ownr_Ship VARCHAR(3),
	           @Get_Know_Us VARCHAR(3),
	           @Get_Know_Cust VARCHAR(3),
	           @Cont_Mtod VARCHAR(3),
	           @Alow_Emal VARCHAR(3),
	           @Alow_Bulk_Emal VARCHAR(3),
	           @Alow_Phon VARCHAR(3),
	           @Alow_Fax VARCHAR(3),
	           @Alow_Lett VARCHAR(3),
	           @Ship_Mtod VARCHAR(3),
	           @Ship_Chrg VARCHAR(3),
	           @Revn_Amnt BIGINT,
	           @Empy_Numb INT ;
   	
	   SELECT @REGN_PRVN_CNTY_CODE = @X.query('//Company').value('(Company/@cntycode)[1]', 'VARCHAR(3)'),
	           @REGN_PRVN_CODE = @X.query('//Company').value('(Company/@prvncode)[1]', 'VARCHAR(3)'),
	           @REGN_CODE = @X.query('//Company').value('(Company/@regncode)[1]', 'VARCHAR(3)'),
	           @ISCP_ISCA_ISCG_CODE = @X.query('//Company').value('(Company/@iscgcode)[1]', 'VARCHAR(2)'),
	           @ISCP_ISCA_CODE = @X.query('//Company').value('(Company/@iscacode)[1]', 'VARCHAR(2)'),
	           @ISCP_CODE = @X.query('//Company').value('(Company/@iscpcode)[1]', 'VARCHAR(6)'),
	           @CODE = @X.query('//Company').value('(Company/@code)[1]', 'BIGINT'),
	           @NAME = @X.query('//Company').value('(Company/@name)[1]', 'NVARCHAR(250)'),
	           @Cord_X = @X.query('//Company').value('(Company/@cordx)[1]', 'FLOAT'),
	           @Cord_Y = @X.query('//Company').value('(Company/@cordy)[1]', 'FLOAT'),
	           @Post_Addr_Zoom = @X.query('//Company').value('(Company/@postaddrzoom)[1]', 'FLOAT'),
	           @POST_ADRS = @X.query('//Company').value('(Company/@postadrs)[1]', 'NVARCHAR(1000)'),
	           @EMAL_ADRS = @X.query('//Company').value('(Company/@emaladrs)[1]', 'VARCHAR(250)'),
	           @WEB_SITE = @X.query('//Company').value('(Company/@website)[1]', 'VARCHAR(500)'),
	           @COMP_CODE = @X.query('//Company').value('(Company/@compcode)[1]', 'BIGINT'),
	           @COMP_DESC = @X.query('//Company').value('(Company/@twtrurl)[1]', 'NVARCHAR(MAX)'),
	           @REGS_DATE = @X.query('//Company').value('(Company/@regsdate)[1]', 'DATE'),
	           @ZIP_CODE = @X.query('//Company').value('(Company/@zipcode)[1]', 'VARCHAR(20)'),
	           @ECON_CODE = @X.query('//Company').value('(Company/@econcode)[1]', 'VARCHAR(20)'),
	           @STRT_TIME = @X.query('//Company').value('(Company/@strttime)[1]', 'TIME(0)'),
	           @END_TIME = @X.query('//Company').value('(Company/@endtime)[1]', 'TIME(0)'),
	           @TYPE = @X.query('//Company').value('(Company/@type)[1]', 'VARCHAR(3)'),
	           @BILL_ADDR_X = @X.query('//Company').value('(Company/@billaddrx)[1]', 'FLOAT'),
	           @BILL_ADDR_Y = @X.query('//Company').value('(Company/@billaddry)[1]', 'FLOAT'),
	           @BILL_ADDR_ZOOM = @X.query('//Company').value('(Company/@billaddrzoom)[1]', 'FLOAT'),
	           @BILL_ADDR = @X.query('//Company').value('(Company/@billaddr)[1]', 'NVARCHAR(1000)'),
	           @SHIP_ADDR_X = @X.query('//Company').value('(Company/@shipaddrx)[1]', 'FLOAT'),
	           @SHIP_ADDR_Y = @X.query('//Company').value('(Company/@shipaddry)[1]', 'FLOAT'),
	           @SHIP_ADDR_ZOOM = @X.query('//Company').value('(Company/@shipaddrzoom)[1]', 'FLOAT'),
	           @SHIP_ADDR = @X.query('//Company').value('(Company/@shipaddr)[1]', 'NVARCHAR(1000)'),
	           @DFLT_STAT = @X.query('//Company').value('(Company/@dfltstat)[1]', 'VARCHAR(3)'),
	           @HOST_STAT = @X.query('//Company').value('(Company/@hoststat)[1]', 'VARCHAR(3)'),
	           @FACE_BOOK_URL = @X.query('//Company').value('(Company/@facebookurl)[1]', 'NVARCHAR(1000)'),
	           @LINK_IN_URL = @X.query('//Company').value('(Company/@linkinurl)[1]', 'NVARCHAR(1000)'),
	           @TWTR_URL = @X.query('//Company').value('(Company/@twtrurl)[1]', 'NVARCHAR(1000)'),
	           @Cell_Phon = @X.query('//Company').value('(Company/@cellphon)[1]', 'VARCHAR(11)'),
	           @Tell_Phon = @X.query('//Company').value('(Company/@tellphon)[1]', 'VARCHAR(11)'),	           
	           @Fax_Numb = @X.query('//Company').value('(Company/@faxnumb)[1]', 'VARCHAR(15)'),	           
	           @RECD_STAT = @X.query('//Company').value('(Company/@recdstat)[1]', 'VARCHAR(3)'),
	           @Ownr_Code = @X.query('//Company').value('(Company/@ownrcode)[1]', 'BIGINT'),	           
	           @Prim_Serv_File_No = @X.query('//Company').value('(Company/@primservfileno)[1]', 'BIGINT'),
	           @Trcb_Tcid = @X.query('//Company').value('(Company/@trcbtcid)[1]', 'BIGINT'),
	           @Crdt_Stat = @X.query('//Company').value('(Company/@crdtstat)[1]', 'VARCHAR(3)'),
	           @Crdt_Amnt = @X.query('//Company').value('(Company/@crdtamnt)[1]', 'BIGINT'),
	           @Pymt_Term = @X.query('//Company').value('(Company/@pymtterm)[1]', 'VARCHAR(3)'),
	           @Ownr_Ship = @X.query('//Company').value('(Company/@ownrship)[1]', 'VARCHAR(3)'),
	           @Get_Know_Us = @X.query('//Company').value('(Company/@getknowus)[1]', 'VARCHAR(3)'),
	           @Get_Know_Cust = @X.query('//Company').value('(Company/@getknowcust)[1]', 'VARCHAR(3)'),
	           @Cont_Mtod = @X.query('//Company').value('(Company/@contmtod)[1]', 'VARCHAR(3)'),
	           @Alow_Emal = @X.query('//Company').value('(Company/@alowemal)[1]', 'VARCHAR(3)'),
	           @Alow_Bulk_Emal = @X.query('//Company').value('(Company/@alowbulkemal)[1]', 'VARCHAR(3)'),
	           @Alow_Phon = @X.query('//Company').value('(Company/@alowphon)[1]', 'VARCHAR(3)'),
	           @Alow_Fax = @X.query('//Company').value('(Company/@alowfax)[1]', 'VARCHAR(3)'),
	           @Alow_Lett = @X.query('//Company').value('(Company/@alowlett)[1]', 'VARCHAR(3)'),
	           @Ship_Mtod = @X.query('//Company').value('(Company/@shipmtod)[1]', 'VARCHAR(3)'),
	           @Ship_Chrg = @X.query('//Company').value('(Company/@shipchrg)[1]', 'VARCHAR(3)'),
	           @Revn_Amnt = @X.query('//Company').value('(Company/@revnamnt)[1]', 'BIGINT'),
	           @Empy_Numb = @X.query('//Company').value('(Company/@empynumb)[1]', 'INT');

      IF @REGN_PRVN_CNTY_CODE = ''
         SELECT @REGN_PRVN_CNTY_CODE = NULL
               ,@REGN_PRVN_CODE = NULL
               ,@REGN_CODE = NULL;
      
      IF @ISCP_ISCA_ISCG_CODE = ''
         SELECT @ISCP_ISCA_ISCG_CODE = NULL
               ,@ISCP_ISCA_CODE = NULL
               ,@ISCP_CODE = NULL;
      
      IF @Trcb_Tcid = 0 
         SELECT @Trcb_Tcid = NULL;
   	
   	IF @CODE = 0
   	BEGIN
   	   EXEC dbo.INS_COMP_P 
             @Regn_Prvn_Cnty_Code = @Regn_Prvn_Cnty_Code, -- varchar(3)
             @Regn_Prvn_Code = @Regn_Prvn_Code, -- varchar(3)
             @Regn_Code = @Regn_Code, -- varchar(3)
             @Iscp_Isca_Iscg_Code = @Iscp_Isca_Iscg_Code, -- varchar(2)
             @Iscp_Isca_Code = @Iscp_Isca_Code, -- varchar(2)
             @Iscp_Code = @Iscp_Code, -- varchar(6)
             @Name = @Name, -- nvarchar(250)
             @Cord_X = @Cord_X,
             @Cord_Y = @Cord_Y,
             @Post_Addr_Zoom = @Post_Addr_Zoom,
             @Post_Adrs = @Post_Adrs, -- nvarchar(1000)
             @Emal_Adrs = @Emal_Adrs, -- varchar(250)
             @Web_Site = @Web_Site, -- varchar(500)
             @Comp_Code = @Comp_Code, -- bigint
             @Comp_Desc = @Comp_Desc, -- nvarchar(max)
             @Regs_Date = @Regs_Date, -- date
             @Zip_Code = @Zip_Code, -- varchar(20)
             @Logo = NULL, -- varchar(max)
             @Econ_Code = @Econ_Code, -- varchar(20)
             @Strt_Time = @Strt_Time, -- datetime
             @End_Time = @End_Time, -- datetime
             @Type = @TYPE, -- varchar(3)
             @Empy_Numb = 0, -- int
             @Bill_Addr_X = @Bill_Addr_X, -- float
             @Bill_Addr_Y = @Bill_Addr_Y, -- float
             @Bill_Addr_Zoom = @Bill_Addr_Zoom, -- float
             @Bill_Addr = @Bill_Addr,
             @Ship_Addr_X = @Ship_Addr_X, -- float
             @Ship_Addr_Y = @Ship_Addr_Y, -- float
             @Ship_Addr_Zoom = @Ship_Addr_Zoom, -- float
             @Ship_Addr = @Ship_Addr,
             @Dflt_Stat = @Dflt_Stat, -- varchar(3)
             @Host_Stat = @Host_Stat,
             @Face_Book_Url = @FACE_BOOK_URL,
             @Twtr_Url = @TWTR_URL,
             @Cell_Phon = @Cell_Phon,
             @Tell_Phon = @Tell_Phon,
             @Fax_Numb = @Fax_Numb,
             @Link_In_Url = @LINK_IN_URL,
	          @Ownr_Code = @Ownr_Code,
	          @Prim_Serv_File_No = @Prim_Serv_File_No,
	          @Trcb_Tcid = @Trcb_Tcid,
	          @Crdt_Stat = @Crdt_Stat,
	          @Crdt_Amnt = @Crdt_Amnt,
	          @Pymt_Term = @Pymt_Term,
	          @Ownr_Ship = @Ownr_Ship,
	          @Get_Know_Us = @Get_Know_Us,
	          @Get_Know_Cust = @Get_Know_Cust,
	          @Cont_Mtod = @Cont_Mtod,
	          @Alow_Emal = @Alow_Emal,
	          @Alow_Bulk_Emal = @Alow_Bulk_Emal,
	          @Alow_Phon = @Alow_Phon,
	          @Alow_Fax = @Alow_Fax,
	          @Alow_Lett = @Alow_Lett,
	          @Ship_Mtod = @Ship_Mtod,
	          @Ship_Chrg = @Ship_Chrg,
	          @Revn_Amnt = @Revn_Amnt;
         SELECT @Code = CODE
           FROM dbo.Company
          WHERE NAME = @NAME
            AND POST_ADRS = @POST_ADRS
            AND CRET_BY = UPPER(SUSER_NAME())
            AND CAST(CRET_DATE AS DATE) = CAST(GETDATE() AS DATE);
   	END
   	ELSE 
   	BEGIN  	
         EXEC dbo.UPD_COMP_P 
             @Code = @CODE,
             @Regn_Prvn_Cnty_Code = @Regn_Prvn_Cnty_Code, -- varchar(3)
             @Regn_Prvn_Code = @Regn_Prvn_Code, -- varchar(3)
             @Regn_Code = @Regn_Code, -- varchar(3)
             @Iscp_Isca_Iscg_Code = @Iscp_Isca_Iscg_Code, -- varchar(2)
             @Iscp_Isca_Code = @Iscp_Isca_Code, -- varchar(2)
             @Iscp_Code = @Iscp_Code, -- varchar(6)
             @Name = @Name, -- nvarchar(250)
             @Cord_X = @Cord_X,
             @Cord_Y = @Cord_Y,
             @Post_Addr_Zoom = @Post_Addr_Zoom,
             @Post_Adrs = @Post_Adrs, -- nvarchar(1000)
             @Emal_Adrs = @Emal_Adrs, -- varchar(250)
             @Web_Site = @Web_Site, -- varchar(500)
             @Comp_Code = @Comp_Code, -- bigint
             @Comp_Desc = @Comp_Desc, -- nvarchar(max)
             @Regs_Date = @Regs_Date, -- date
             @Zip_Code = @Zip_Code, -- varchar(20)
             @Logo = NULL, -- varchar(max)
             @Econ_Code = @Econ_Code, -- varchar(20)
             @Strt_Time = @Strt_Time, -- datetime
             @End_Time = @End_Time, -- datetime
             @Type = @TYPE, -- varchar(3)
             @Empy_Numb = @Empy_Numb, -- int
             @Bill_Addr_X = @Bill_Addr_X, -- float
             @Bill_Addr_Y = @Bill_Addr_Y, -- float
             @Bill_Addr_Zoom = @Bill_Addr_Zoom, -- float
             @Bill_Addr = @Bill_Addr,
             @Ship_Addr_X = @Ship_Addr_X, -- float
             @Ship_Addr_Y = @Ship_Addr_Y, -- float
             @Ship_Addr_Zoom = @Ship_Addr_Zoom, -- float
             @Ship_Addr = @Ship_Addr,
             @Dflt_Stat = @Dflt_Stat, -- varchar(3)
             @Host_Stat = @Host_Stat,
             @Face_Book_Url = @FACE_BOOK_URL,
             @Twtr_Url = @TWTR_URL,
             @Cell_Phon = @Cell_Phon,
             @Tell_Phon = @Tell_Phon,
             @Fax_Numb = @Fax_Numb,
             @Link_In_Url = @LINK_IN_URL,	          
	          @Ownr_Code = @Ownr_Code,	          
	          @Prim_Serv_File_No = @Prim_Serv_File_No,
	          @Trcb_Tcid = @Trcb_Tcid,
	          @Crdt_Stat = @Crdt_Stat,
	          @Crdt_Amnt = @Crdt_Amnt,
	          @Pymt_Term = @Pymt_Term,
	          @Ownr_Ship = @Ownr_Ship,
	          @Get_Know_Us = @Get_Know_Us,
	          @Get_Know_Cust = @Get_Know_Cust,
	          @Cont_Mtod = @Cont_Mtod,
	          @Alow_Emal = @Alow_Emal,
	          @Alow_Bulk_Emal = @Alow_Bulk_Emal,
	          @Alow_Phon = @Alow_Phon,
	          @Alow_Fax = @Alow_Fax,
	          @Alow_Lett = @Alow_Lett,
	          @Ship_Mtod = @Ship_Mtod,
	          @Ship_Chrg = @Ship_Chrg,
	          @Revn_Amnt = @Revn_Amnt;
      END;
      
      -- ایام هفتگی شرکت یا رقیب
      
      DECLARE C$CompWkdy CURSOR FOR
        SELECT r.query('.').value('(WeekDay/@code)[1]', 'VARCHAR(3)')
              ,r.query('.').value('(WeekDay/@stat)[1]', 'VARCHAR(3)')
          FROM @X.nodes('//WeekDay') T(r)
      
      DECLARE @WkdyCode VARCHAR(3)
             ,@WkdyStat VARCHAR(3);
      
      OPEN [C$CompWkdy];
      L$FETCH:
      FETCH NEXT FROM [C$CompWkdy] INTO @WkdyCode, @WkdyStat;
      
      IF @@FETCH_STATUS <> 0
         GOTO L$END;
     
      UPDATE dbo.Weekday_Info
         SET STAT = @WkdyStat
       WHERE COMP_CODE = @CODE
         AND WEEK_DAY = @WkdyCode;
      
      GOTO L$FETCH;
      L$END:
      CLOSE [C$CompWkdy];
      DEALLOCATE [C$CompWkdy];         
      
      -- نقاط قوت و ضعف
      DECLARE C$CmptDiff CURSOR FOR
        SELECT r.query('.').value('(Competitor_Difference/@code)[1]', 'BIGINT')
              ,r.query('.').value('(Competitor_Difference/@type)[1]', 'VARCHAR(3)')
              ,r.query('.').value('(Competitor_Difference/@cmnt)[1]', 'NVARCHAR(500)')
          FROM @X.nodes('//Competitor_Difference') T(r)
      
      DECLARE @CmdfCode BIGINT
             ,@CmdfType VARCHAR(3)
             ,@CmdfCmnt NVARCHAR(500);
      
      OPEN C$CmptDiff;
      L$CMDFFETCH:
      FETCH NEXT FROM C$CmptDiff INTO @CmdfCode, @CmdfType, @CmdfCmnt;
      
      IF @@FETCH_STATUS <> 0
         GOTO L$CMDFEND;
     
      MERGE dbo.Competitor_Difference T
      USING (SELECT @CmdfCode AS Code ) S
      ON (T.CODE = S.Code)
      WHEN NOT MATCHED THEN
         INSERT (COMP_CODE, Code, TYPE, CMNT)
         VALUES (@CODE, 0, @CmdfType, @CmdfCmnt)
      WHEN MATCHED THEN
         UPDATE SET T.TYPE = @CmdfType, t.CMNT = @CmdfCmnt;
      
      GOTO L$CMDFFETCH;
      L$CMDFEND:
      CLOSE C$CmptDiff;
      DEALLOCATE C$CmptDiff;         
      COMMIT TRAN COMP_CHNG_T;
      RETURN 0;
   END TRY
   BEGIN CATCH
      DECLARE @ErrorMessage NVARCHAR(MAX);
      SET @ErrorMessage = ERROR_MESSAGE();
      RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN COMP_CHNG_T;
      RETURN -1;
   END CATCH  	
END
GO
