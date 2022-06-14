SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CLON_COMP_P]
	-- Add the parameters for the stored procedure here
	@X XML
AS
BEGIN
   BEGIN TRY
   BEGIN TRAN CLON_COMP_T
	   DECLARE @REGN_PRVN_CNTY_CODE [varchar](3) ,
	           @REGN_PRVN_CODE [varchar](3) ,
	           @REGN_CODE [varchar](3) ,
	           @ISCP_ISCA_ISCG_CODE [varchar](2) ,
	           @ISCP_ISCA_CODE [varchar](2) ,
	           @ISCP_CODE [varchar](6) ,
	           @CODE [bigint] ,
	           @DEBT_DNRM [bigint] ,
	           @NAME [nvarchar](250) ,
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
	           @SHIP_ADDR_X [float] ,
	           @SHIP_ADDR_Y [float] ,
	           @SHIP_ADDR_ZOOM [float] ,
	           @DFLT_STAT [varchar](3) ,
	           @FACE_BOOK_URL [nvarchar](1000) ,
	           @LINK_IN_URL [nvarchar](1000) ,
	           @TWTR_URL [nvarchar](1000) ,
	           @LAST_SERV_FILE_NO_DNRM [bigint] ,
	           @LAST_RQST_RQID_DNRM [bigint] ,
	           @RECD_STAT [varchar](3) ;
   	
	   SELECT @REGN_PRVN_CNTY_CODE = @X.query('//Company').value('(Company/@cntycode)[1]', 'VARCHAR(3)'),
	           @REGN_PRVN_CODE = @X.query('//Company').value('(Company/@prvncode)[1]', 'VARCHAR(3)'),
	           @REGN_CODE = @X.query('//Company').value('(Company/@regncode)[1]', 'VARCHAR(3)'),
	           @ISCP_ISCA_ISCG_CODE = @X.query('//Company').value('(Company/@iscgcode)[1]', 'VARCHAR(2)'),
	           @ISCP_ISCA_CODE = @X.query('//Company').value('(Company/@iscacode)[1]', 'VARCHAR(2)'),
	           @ISCP_CODE = @X.query('//Company').value('(Company/@iscpcode)[1]', 'VARCHAR(6)'),
	           @NAME = @X.query('//Company').value('(Company/@name)[1]', 'NVARCHAR(250)'),
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
	           @BILL_ADDR_X = @X.query('//Company').value('(Company/@billaddrx)[1]', 'FLOAT'),
	           @BILL_ADDR_Y = @X.query('//Company').value('(Company/@billaddry)[1]', 'FLOAT'),
	           @BILL_ADDR_ZOOM = @X.query('//Company').value('(Company/@billaddrzoom)[1]', 'FLOAT'),
	           @SHIP_ADDR_X = @X.query('//Company').value('(Company/@shipaddrx)[1]', 'FLOAT'),
	           @SHIP_ADDR_Y = @X.query('//Company').value('(Company/@shipaddry)[1]', 'FLOAT'),
	           @SHIP_ADDR_ZOOM = @X.query('//Company').value('(Company/@shipaddrzoom)[1]', 'FLOAT'),
	           @DFLT_STAT = @X.query('//Company').value('(Company/@dfltstat)[1]', 'VARCHAR(3)'),
	           @FACE_BOOK_URL = @X.query('//Company').value('(Company/@facebookurl)[1]', 'NVARCHAR(1000)'),
	           @LINK_IN_URL = @X.query('//Company').value('(Company/@linkinurl)[1]', 'NVARCHAR(1000)'),
	           @TWTR_URL = @X.query('//Company').value('(Company/@twtrurl)[1]', 'NVARCHAR(1000)'),
	           @RECD_STAT = @X.query('//Company').value('(Company/@recdstat)[1]', 'VARCHAR(3)');
	   
	   SELECT @REGN_PRVN_CNTY_CODE = dbo.IsStringNullOrEmpty(@REGN_PRVN_CNTY_CODE, REGN_PRVN_CNTY_CODE)
	         ,@REGN_PRVN_CODE = dbo.IsStringNullOrEmpty(@REGN_PRVN_CODE, REGN_PRVN_CODE)
	         ,@REGN_CODE = dbo.IsStringNullOrEmpty(@REGN_CODE, REGN_CODE)
	         ,@ISCP_ISCA_ISCG_CODE = dbo.IsStringNullOrEmpty(@ISCP_ISCA_ISCG_CODE, ISCP_ISCA_ISCG_CODE)
	         ,@ISCP_ISCA_CODE = dbo.IsStringNullOrEmpty(@ISCP_ISCA_CODE, ISCP_ISCA_CODE)
	         ,@ISCP_CODE = dbo.IsStringNullOrEmpty(@ISCP_CODE, ISCP_CODE)
	         ,@EMAL_ADRS = dbo.IsStringNullOrEmpty(@EMAL_ADRS, EMAL_ADRS)
	         ,@WEB_SITE = dbo.IsStringNullOrEmpty(@WEB_SITE, WEB_SITE)
	         ,@REGS_DATE = dbo.IsDateTimeNullOrEmpty(@REGS_DATE, REGS_DATE)
	         ,@ZIP_CODE = dbo.IsStringNullOrEmpty(@ZIP_CODE, ZIP_CODE)
	         ,@ECON_CODE = dbo.IsStringNullOrEmpty(@ECON_CODE, ECON_CODE)
	         ,@STRT_TIME = dbo.IsDateTimeNullOrEmpty(@STRT_TIME, STRT_TIME)
	         ,@END_TIME = dbo.IsDateTimeNullOrEmpty(@END_TIME, END_TIME)
	         ,@BILL_ADDR_X = ISNULL(@BILL_ADDR_X, BILL_ADDR_X)
	         ,@BILL_ADDR_Y = ISNULL(@BILL_ADDR_Y, BILL_ADDR_Y)
	         ,@BILL_ADDR_ZOOM = ISNULL(@BILL_ADDR_ZOOM, BILL_ADDR_ZOOM)
	         ,@SHIP_ADDR_X = ISNULL(@SHIP_ADDR_X, SHIP_ADDR_X)
	         ,@SHIP_ADDR_Y = ISNULL(@SHIP_ADDR_Y, SHIP_ADDR_Y)
	         ,@SHIP_ADDR_ZOOM = ISNULL(@SHIP_ADDR_ZOOM, SHIP_ADDR_ZOOM)
	         ,@DFLT_STAT = dbo.IsStringNullOrEmpty(@DFLT_STAT, DFLT_STAT)
	         ,@FACE_BOOK_URL = dbo.IsStringNullOrEmpty(@FACE_BOOK_URL, FACE_BOOK_URL)
	         ,@LINK_IN_URL = dbo.IsStringNullOrEmpty(@LINK_IN_URL, LINK_IN_URL)
	         ,@TWTR_URL = dbo.IsStringNullOrEmpty(@TWTR_URL, TWTR_URL)
	         ,@RECD_STAT = dbo.IsStringNullOrEmpty(@RECD_STAT, RECD_STAT)
	     FROM dbo.Company
	    WHERE CODE = @COMP_CODE;      
   	
      EXEC dbo.INS_COMP_P 
          @Regn_Prvn_Cnty_Code = @Regn_Prvn_Cnty_Code, -- varchar(3)
          @Regn_Prvn_Code = @Regn_Prvn_Code, -- varchar(3)
          @Regn_Code = @Regn_Code, -- varchar(3)
          @Iscp_Isca_Iscg_Code = @Iscp_Isca_Iscg_Code, -- varchar(2)
          @Iscp_Isca_Code = @Iscp_Isca_Code, -- varchar(2)
          @Iscp_Code = @Iscp_Code, -- varchar(6)
          @Name = @Name, -- nvarchar(250)
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
          @Type = '', -- varchar(3)
          @Empy_Numb = 0, -- int
          @Bill_Addr_X = @Bill_Addr_X, -- float
          @Bill_Addr_Y = @Bill_Addr_Y, -- float
          @Bill_Addr_Zoom = @Bill_Addr_Zoom, -- float
          @Ship_Addr_X = @Ship_Addr_X, -- float
          @Ship_Addr_Y = @Ship_Addr_Y, -- float
          @Ship_Addr_Zoom = @Ship_Addr_Zoom, -- float
          @Dflt_Stat = @Dflt_Stat, -- varchar(3)
          @Face_Book_Url = @FACE_BOOK_URL,
          @Twtr_Url = @TWTR_URL,
          @Link_In_Url = @LINK_IN_URL;
      
      SELECT @CODE
        FROM dbo.Company
       WHERE COMP_CODE = @COMP_CODE
         AND CRET_BY = UPPER(SUSER_NAME()) 
         AND CAST(CRET_DATE AS DATE) = CAST(GETDATE() AS DATE)
         AND NAME = @NAME
         AND REGN_CODE = @REGN_CODE
         AND REGN_PRVN_CODE = @REGN_PRVN_CODE
         AND REGN_PRVN_CNTY_CODE = @REGN_PRVN_CNTY_CODE;
      
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
     
      UPDATE dbo.Company_Weekday
         SET STAT = @WkdyStat
       WHERE COMP_CODE = @CODE
         AND WEEK_DAY = @WkdyCode;
      
      GOTO L$FETCH;
      L$END:
      CLOSE [C$CompWkdy];
      DEALLOCATE [C$CompWkdy];         
      
      COMMIT TRAN CLON_COMP_T;
      RETURN 0;
   END TRY
   BEGIN CATCH
      DECLARE @ErrorMessage NVARCHAR(MAX);
      SET @ErrorMessage = ERROR_MESSAGE();
      RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN CLON_COMP_T;
      RETURN -1;
   END CATCH  	
END
GO
