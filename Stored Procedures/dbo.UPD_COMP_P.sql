SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPD_COMP_P]
	-- Add the parameters for the stored procedure here
   @Code     BIGINT,
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
	@Revn_Amnt BIGINT
AS
BEGIN
 	-- بررسی دسترسی کاربر
	DECLARE @AP BIT
	       ,@AccessString VARCHAR(250);
	SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>76</Privilege><Sub_Sys>11</Sub_Sys></AP>';	
   EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
   IF @AP = 0 
   BEGIN
      RAISERROR ( N'خطا - عدم دسترسی به ردیف 76 سطوح امینتی : شما مجوز ویرایش کردن شرکت مشتری / شرکت رقیب را ندارید', -- Message text.
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
   
   UPDATE Company
      SET NAME = @Name
         ,CORD_X = @Cord_X
         ,CORD_Y = @Cord_Y
         ,POST_ADDR_ZOOM = @Post_Addr_Zoom
         ,POST_ADRS = @Post_Adrs
         ,EMAL_ADRS = @Emal_Adrs
         ,WEB_SITE = @Web_Site
         ,REGN_PRVN_CNTY_CODE = @Regn_Prvn_Cnty_Code
         ,REGN_PRVN_CODE = @Regn_Prvn_Code
         ,REGN_CODE = @Regn_Code
         ,ISCP_ISCA_ISCG_CODE = @Iscp_Isca_Iscg_Code
         ,ISCP_ISCA_CODE = @Iscp_Isca_Code
         ,ISCP_CODE = @Iscp_Code
         ,COMP_CODE = @Comp_Code
         ,COMP_DESC = @Comp_Desc
         ,REGS_DATE = @Regs_Date
         ,ZIP_CODE = @Zip_Code
         ,LOGO = @Logo
         ,ECON_CODE = @Econ_Code
         ,STRT_TIME = @Strt_Time
         ,END_TIME = @End_Time
         ,[TYPE] = @Type
         --,EMPY_NUMB_DNRM = @Empy_Numb
         ,BILL_ADDR_X = @Bill_Addr_X
         ,BILL_ADDR_Y = @Bill_Addr_Y
         ,BILL_ADDR_ZOOM = @Bill_Addr_Zoom
         ,BILL_ADDR = @Bill_Addr
         ,SHIP_ADDR_X = @Ship_Addr_X
         ,SHIP_ADDR_Y = @Ship_Addr_Y
         ,SHIP_ADDR_ZOOM = @Ship_Addr_Zoom
         ,SHIP_ADDR = @Ship_Addr
         ,FACE_BOOK_URL = @Face_Book_Url
         ,LINK_IN_URL = @Link_In_Url
         ,TWTR_URL = @Twtr_Url
         ,CELL_PHON = @Cell_Phon
         ,TELL_PHON = @Tell_Phon
         ,DFLT_STAT = @Dflt_Stat
         ,HOST_STAT = @Host_Stat
         ,RECD_STAT = ISNULL(RECD_STAT, '002')
         ,OWNR_CODE = @Ownr_Code
         ,FAX_NUMB = @Fax_Numb
         ,PRIM_SERV_FILE_NO = @Prim_Serv_File_No
         ,TRCB_TCID = @Trcb_Tcid
         ,CRDT_STAT = @Crdt_Stat
         ,CRDT_AMNT = @Crdt_Amnt
         ,PYMT_TERM = @Pymt_Term
         ,OWNR_SHIP = @Ownr_Ship
         ,GET_KNOW_US = @Get_Know_Us
         ,GET_KNOW_CUST = @GET_KNOW_CUST
         ,CONT_MTOD = @Cont_Mtod
         ,ALOW_EMAL = @Alow_Emal
         ,ALOW_BULK_EMAL = @Alow_Bulk_Emal
         ,ALOW_PHON = @ALOW_PHON
         ,ALOW_FAX = @Alow_Fax
         ,ALOW_LETT = @Alow_Lett
         ,SHIP_MTOD = @Ship_Mtod
         ,SHIP_CHRG = @Ship_Chrg
         ,REVN_AMNT = @Revn_Amnt
         ,EMPY_NUMB = @Empy_Numb
    WHERE CODE = @Code;
END
GO
