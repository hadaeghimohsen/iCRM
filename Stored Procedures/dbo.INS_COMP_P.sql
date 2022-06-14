SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_COMP_P]
	-- Add the parameters for the stored procedure here
	@Regn_Prvn_Cnty_Code VARCHAR(3),
	@Regn_Prvn_Code VARCHAR(3),
	@Regn_Code VARCHAR(3),
	@Iscp_Isca_Iscg_Code VARCHAR(2),
	@Iscp_Isca_Code VARCHAR(2),
	@Iscp_Code VARCHAR(6),
	@Name     NVARCHAR(250),
	@Cord_X FLOAT,
	@Cord_Y FLOAT,	
	@Post_Addr_Zoom FLOAT,	
	@Post_Adrs NVARCHAR(1000),
	@Emal_Adrs VARCHAR(250),
	@Web_Site  VARCHAR(500),
	@Comp_Code BIGINT,
	@Comp_Desc NVARCHAR(MAX),
	@Regs_Date DATE,
	@Zip_Code VARCHAR(20),
	@Logo IMAGE,
	@Econ_Code VARCHAR(20),
	@Strt_Time DATETIME,
	@End_Time DATETIME,
	@Type VARCHAR(3),
	@Empy_Numb INT,
	@Bill_Addr_X FLOAT,
	@Bill_Addr_Y FLOAT,
	@Bill_Addr_Zoom FLOAT,
	@Bill_Addr NVARCHAR(1000),
	@Ship_Addr_X FLOAT,
	@Ship_Addr_Y FLOAT,
	@Ship_Addr_Zoom FLOAT,
	@Ship_Addr NVARCHAR(1000),
	@Face_Book_Url NVARCHAR(1000),
	@Link_In_Url NVARCHAR(1000),
	@Twtr_Url NVARCHAR(1000),
	@Cell_Phon VARCHAR(11),
	@Tell_Phon VARCHAR(11),
	@Dflt_Stat VARCHAR(3),
	@Host_Stat VARCHAR(3),
	@Ownr_Code BIGINT,
	@Fax_NUmb VARCHAR(15),
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
	@Revn_Amnt BIGINT
AS
BEGIN
 	-- بررسی دسترسی کاربر
	DECLARE @AP BIT
	       ,@AccessString VARCHAR(250);
	SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>75</Privilege><Sub_Sys>11</Sub_Sys></AP>';	
   EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
   IF @AP = 0 
   BEGIN
      RAISERROR ( N'خطا - عدم دسترسی به ردیف 75 سطوح امینتی : شما مجوز اضافه کردن شرکت مشتری / شرکت رقیب را ندارید', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   -- پایان دسترسی
   
   IF @Post_Adrs IS NULL OR LEN(@Post_Adrs) = 0
   BEGIN
      RAISERROR(N'آدرس پستی وارد نشده', 16, 1);
      RETURN;
   END

   SET @Iscp_Isca_Iscg_Code   = CASE LEN(@Iscp_Isca_Iscg_Code)  WHEN 2 THEN @Iscp_Isca_Iscg_Code   ELSE '00'       END;
   SET @Iscp_Isca_Code        = CASE LEN(@Iscp_Isca_Code)       WHEN 2 THEN @Iscp_Isca_Code        ELSE '00'       END;
   SET @Iscp_Code             = CASE LEN(@Iscp_Code)            WHEN 6 THEN @Iscp_Code             ELSE '000000'   END;
   
   SET @Comp_Code             = CASE @Comp_Code WHEN 0 THEN NULL ELSE @Comp_Code END;
   
   INSERT INTO Company (
      REGN_PRVN_CNTY_CODE, 
      REGN_PRVN_CODE, 
      REGN_CODE, 
      ISCP_ISCA_ISCG_CODE,
      ISCP_ISCA_CODE,
      ISCP_CODE,
      NAME, 
      CORD_X,
      CORD_Y,
      POST_ADDR_ZOOM,
      POST_ADRS, 
      EMAL_ADRS, 
      WEB_SITE,
      COMP_CODE,
      COMP_DESC,
      REGS_DATE,
      ZIP_CODE,
      LOGO,
      ECON_CODE,
      STRT_TIME,
      END_TIME,
      [TYPE],
      EMPY_NUMB_DNRM,
      BILL_ADDR_X,
      BILL_ADDR_Y,
      BILL_ADDR_ZOOM,
      BILL_ADDR,
      SHIP_ADDR_X,
      SHIP_ADDR_Y,
      SHIP_ADDR_ZOOM,
      SHIP_ADDR,
      FACE_BOOK_URL,
      LINK_IN_URL,
      TWTR_URL,
      CELL_PHON,
      TELL_PHON,
      DFLT_STAT,
      HOST_STAT,
      RECD_STAT,
      OWNR_CODE,
      FAX_NUMB,
      PRIM_SERV_FILE_NO,
      TRCB_TCID,
      CRDT_STAT,
      CRDT_AMNT,
      PYMT_TERM,
      OWNR_SHIP,
      GET_KNOW_US,
      GET_KNOW_CUST,
      CONT_MTOD,
      ALOW_EMAL,
      ALOW_BULK_EMAL,
      ALOW_PHON,
      ALOW_FAX,
      ALOW_LETT,
      SHIP_MTOD,
      SHIP_CHRG,
      REVN_AMNT,
      EMPY_NUMB
   )
   VALUES (@REGN_PRVN_CNTY_CODE, 
      @REGN_PRVN_CODE, 
      @REGN_CODE, 
      @ISCP_ISCA_ISCG_CODE,
      @ISCP_ISCA_CODE,
      @ISCP_CODE,
      @NAME, 
      @Cord_X,
      @Cord_Y,
      @Post_Addr_Zoom,
      @POST_ADRS, 
      @EMAL_ADRS, 
      @WEB_SITE,
      @COMP_CODE,
      @COMP_DESC,
      @REGS_DATE,
      @ZIP_CODE,
      @LOGO,
      @ECON_CODE,
      @STRT_TIME,
      @END_TIME,
      @TYPE,
      0,
      @BILL_ADDR_X,
      @BILL_ADDR_Y,
      @Bill_Addr_Zoom,
      @Bill_Addr,
      @SHIP_ADDR_X,
      @SHIP_ADDR_Y,
      @Ship_Addr_Zoom,
      @Ship_Addr,
      @Face_Book_Url,
      @Link_In_Url,
      @Twtr_Url,
      @Cell_Phon,
      @Tell_Phon,
      @Dflt_Stat,
      @Host_Stat,
      '002',
      @Ownr_Code,
      @Fax_NUmb,
      @Prim_Serv_File_No,
      @TRCB_TCID,
      @CRDT_STAT,
      @CRDT_AMNT,
      @PYMT_TERM,
      @OWNR_SHIP,
      @GET_KNOW_US,
      @GET_KNOW_CUST,
      @CONT_MTOD,
      @ALOW_EMAL,
      @ALOW_BULK_EMAL,
      @ALOW_PHON,
      @ALOW_FAX,
      @ALOW_LETT,
      @SHIP_MTOD,
      @SHIP_CHRG,
      @Revn_Amnt,
      @Empy_Numb);
END
GO
