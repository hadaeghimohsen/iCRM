SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[OPR_LEAD_P]
   @X XML
AS 
BEGIN
   BEGIN TRY
   BEGIN TRAN T_OPR_LEAD_P
      --DECLARE @AP BIT
      --        ,@AccessString VARCHAR(250);
      --SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>59</Privilege><Sub_Sys>11</Sub_Sys></AP>';	
      --EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
      --IF @AP = 0 
      --BEGIN
      --   RAISERROR ( N'خطا - عدم دسترسی به ردیف 59 سطوح امینتی', -- Message text.
      --            16, -- Severity.
      --            1 -- State.
      --            );
      --   RETURN;
      --END
      DECLARE @Rqid     BIGINT,
	           @RqstRqid BIGINT,
	           @RqtpCode VARCHAR(3) = '014',
	           @RqttCode VARCHAR(3) = '004',
	           @RegnCode VARCHAR(3),
	           @PrvnCode VARCHAR(3),
	           @CntyCode VARCHAR(3),
	           @LeadType VARCHAR(30);
   	
   	DECLARE @FileNo BIGINT,
   	        @CompCode BIGINT,
   	        @OwnrCode BIGINT;
      SELECT @FileNo = @X.query('//Service').value('(Service/@fileno)[1]', 'BIGINT')
            ,@CompCode = @X.query('//Company').value('(Company/@code)[1]', 'BIGINT')
            ,@OwnrCode = @X.query('//Lead').value('(Lead/@ownrcode)[1]', 'BIGINT');

      IF @OwnrCode = 0 OR @OwnrCode IS NULL
         SELECT @OwnrCode = CODE
           FROM dbo.Job_Personnel
          WHERE STAT = '002'
            AND [USER_NAME] = UPPER(SUSER_NAME());
      
	   SELECT @Rqid     = @X.query('//Request').value('(Request/@rqid)[1]'    , 'BIGINT')
	         ,@RqstRqid = @X.query('//Request').value('(Request/@rqstrqid)[1]'    , 'BIGINT')
	         ,@RegnCode = @X.query('//Request').value('(Request/@regncode)[1]', 'VARCHAR(3)')
	         ,@PrvnCode = @X.query('//Request').value('(Request/@prvncode)[1]', 'VARCHAR(3)')
	         ,@CntyCode = @X.query('//Request').value('(Request/@cntycode)[1]', 'VARCHAR(3)')
	         ,@LeadType = @X.query('//Request').value('(Request/@leadtype)[1]', 'VARCHAR(30)');
      
      IF ( @RegnCode IS NULL OR @PrvnCode IS NULL )
         SELECT TOP 1 @RegnCode = CODE
                     ,@PrvnCode = PRVN_CODE
                     ,@CntyCode = PRVN_CNTY_CODE
           FROM Region;
      
      -- ثبت شماره درخواست 
      IF @Rqid IS NULL OR @Rqid = 0
      BEGIN
         IF @RqstRqid IS NULL OR @RqstRqid = 0
            SET @RqstRqid = NULL;
            
         EXEC dbo.INS_RQST_P
            @CntyCode,
            @PrvnCode,
            @RegnCode,
            @RqstRqid,
            @RqtpCode,
            @RqttCode,
            NULL,
            NULL,
            NULL,
            @Rqid OUT; 
         
         UPDATE dbo.Request
            SET COLR = 'Gold'
          WHERE RQID = @Rqid;        
      END
      
      -- تعریف ستون های جدول شرکت
      DECLARE  @Regn_Prvn_Cnty_Code VARCHAR(3),
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
	            --@Logo IMAGE,
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
	            @Revn_Amnt BIGINT;
      
      IF @LeadType NOT IN ( 'companylead', 'companyleadupdate' )
      BEGIN      
         SELECT @Regn_Prvn_Cnty_Code = c.query('Regn_Prvn_Cnty_Code').value('.', 'VARCHAR(3)')
               ,@Regn_Prvn_Code = c.query('Regn_Prvn_Code').value('.', 'VARCHAR(3)')
               ,@Regn_Code = c.query('Regn_Code').value('.', 'VARCHAR(3)')
               ,@Iscp_Isca_Iscg_Code = c.query('Iscp_Isca_Iscg_Code').value('.', 'VARCHAR(2)')
               ,@Iscp_Isca_Code = c.query('Iscp_Isca_Code').value('.', 'VARCHAR(2)')
               ,@Iscp_Code = c.query('Iscp_Code').value('.', 'VARCHAR(6)')
               ,@Name = c.query('Name').value('.', 'NVARCHAR(250)')
               ,@Cord_X = c.query('Cord_X').value('.', 'FLOAT')
               ,@Cord_Y = c.query('Cord_Y').value('.', 'FLOAT')
               ,@Post_Addr_Zoom = c.query('Post_Addr_Zoom').value('.', 'FLOAT')
               ,@Post_Adrs = c.query('Post_Adrs').value('.', 'NVARCHAR(1000)')
               ,@Emal_Adrs = c.query('Emal_Adrs').value('.', 'VARCHAR(250)')
               ,@Web_Site = c.query('Web_Site').value('.', 'VARCHAR(500)')
               ,@Comp_Code = c.query('Comp_Code').value('.', 'BIGINT')
               ,@Comp_Desc = c.query('Comp_Desc').value('.', 'NVARCHAR(MAX)')
               ,@Regs_Date = c.query('Regs_Date').value('.', 'DATE')
               ,@Zip_Code = c.query('Zip_Code').value('.', 'VARCHAR(20)')
               ,@Econ_Code = c.query('Econ_Code').value('.', 'VARCHAR(20)')
               ,@Strt_Time = c.query('Strt_Time').value('.', 'DATETIME')
               ,@End_Time = c.query('End_Time').value('.', 'DATETIME')
               ,@Type = c.query('Type').value('.', 'VARCHAR(3)')
               ,@Empy_Numb = c.query('Empy_Numb').value('.', 'INT')
               ,@Bill_Addr_X = c.query('Bill_Addr_X').value('.', 'FLOAT')
               ,@Bill_Addr_Y = c.query('Bill_Addr_Y').value('.', 'FLOAT')
               ,@Bill_Addr_Zoom = c.query('Bill_Addr_Zoom').value('.', 'FLOAT')
               ,@Ship_Addr_X = c.query('Ship_Addr_X').value('.', 'FLOAT')
               ,@Ship_Addr_Y = c.query('Ship_Addr_Y').value('.', 'FLOAT')
               ,@Ship_Addr_Zoom = c.query('Ship_Addr_Zoom').value('.', 'FLOAT')
               ,@Face_Book_Url = c.query('Face_Book_Url').value('.', 'NVARCHAR(1000)')
               ,@Link_In_Url = c.query('Link_In_Url').value('.', 'NVARCHAR(1000)')
               ,@Twtr_Url = c.query('Twtr_Url').value('.', 'NVARCHAR(1000)')
               ,@Cell_Phon = c.query('Cell_Phon').value('.', 'VARCHAR(11)')
               ,@Tell_Phon = c.query('Tell_Phon').value('.', 'VARCHAR(11)')
               ,@Dflt_Stat = c.query('Dflt_Stat').value('.', 'VARCHAR(3)')
               ,@Host_Stat = c.query('Host_Stat').value('.', 'VARCHAR(3)')
               --,@Ownr_Code = c.query('Ownr_Code').value('.', 'BIGINT')
               ,@Fax_Numb = c.query('Fax_Numb').value('.', 'VARCHAR(15)')
               ,@Prim_Serv_File_No = c.query('Prim_Serv_File_No').value('.', 'BIGINT')
               ,@Trcb_Tcid = c.query('Trcb_Tcid').value('.', 'BIGINT')
               ,@Crdt_Stat = c.query('Crdt_Stat').value('.', 'VARCHAR(3)')
               ,@Crdt_Amnt = c.query('Crdt_Amnt').value('.', 'BIGINT')
               ,@Pymt_Term = c.query('Pymt_Term').value('.', 'VARCHAR(3)')
               ,@Ownr_Ship = c.query('Ownr_Ship').value('.', 'VARCHAR(3)')
               ,@Get_Know_Us = c.query('Get_Know_Us').value('.', 'VARCHAR(3)')
               ,@Get_Know_Cust = c.query('Get_Know_Cust').value('.', 'VARCHAR(3)')
               ,@Cont_Mtod = c.query('Cont_Mtod').value('.', 'VARCHAR(3)')
               ,@Alow_Emal = c.query('Alow_Emal').value('.', 'VARCHAR(3)')
               ,@Alow_Bulk_Emal = c.query('Alow_Bulk_Emal').value('.', 'VARCHAR(3)')
               ,@Alow_Phon = c.query('Alow_Phon').value('.', 'VARCHAR(3)')
               ,@Alow_Fax = c.query('Alow_Fax').value('.', 'VARCHAR(3)')
               ,@Alow_Lett = c.query('Alow_Lett').value('.', 'VARCHAR(3)')
               ,@Ship_Mtod = c.query('Ship_Mtod').value('.', 'VARCHAR(3)')
               ,@Ship_Chrg = c.query('Ship_Chrg').value('.', 'VARCHAR(3)')
               ,@Revn_Amnt = c.query('Revn_Amnt').value('.', 'BIGINT')
           FROM @X.nodes('//Company') T(c)
      END 
      ELSE 
      BEGIN
         SELECT @CntyCode = REGN_PRVN_CNTY_CODE
               ,@PrvnCode = REGN_PRVN_CODE
               ,@RegnCode = REGN_CODE
           FROM dbo.Company
          WHERE CODE = @CompCode;
      END;
     
      IF @Trcb_Tcid = 0 OR @Trcb_Tcid IS NULL
         SELECT @Trcb_Tcid = TCID
           FROM dbo.Transaction_Currency_Base
          WHERE ISO_CURN_CODE = '364';
      
      IF @LeadType = 'newlead'
      BEGIN
         EXEC dbo.INS_SERV_P @Rqid, @CntyCode, @PrvnCode, @RegnCode, @FileNo OUT;
         IF NOT EXISTS (SELECT * FROM dbo.Company WHERE NAME = @Name AND REGN_PRVN_CNTY_CODE = @CntyCode AND REGN_PRVN_CODE = @PrvnCode AND REGN_CODE = @RegnCode)
            EXEC dbo.INS_COMP_P @CntyCode, @PrvnCode, @RegnCode, null, null, null, @Name, 0.0, 0.0, 0.0, N'بدون آدرس', '', '', null, N'', '2018-07-27 06:25:40', '', NULL, '', '2018-07-27 07:00:00', '2018-07-27 15:15:00', '', 0, 0.0, 0.0, 0.0, N'', 0.0, 0.0, 0.0, N'', N'', N'', N'', '', '', '', '', @OwnrCode, '', @FileNo, @Trcb_Tcid, '', 0, '', '', '', '', '', '', '', '', '', '', '', '', 0;
      
         SELECT TOP 1 @CompCode = CODE
           FROM dbo.Company
          WHERE CRET_BY = UPPER(SUSER_NAME())
            --AND CAST(CRET_DATE AS DATE) = CAST(GETDATE() AS DATE)
            AND NAME = @Name
            AND REGN_PRVN_CNTY_CODE = @CntyCode
            AND REGN_PRVN_CODE = @PrvnCode
            AND REGN_CODE = @RegnCode
          ORDER BY CRET_DATE DESC;    
         
         SET @Prim_Serv_File_No = @FileNo;
         EXEC dbo.Upd_COMP_P @CompCode, @Regn_Prvn_Cnty_Code, @Regn_Prvn_Code, @Regn_Code, @Iscp_Isca_Iscg_Code, @Iscp_Isca_Code, @Iscp_Code, @Name, @Cord_X, @Cord_Y, @Post_Addr_Zoom, @Post_Adrs, @Emal_Adrs, @Web_Site, @Comp_Code, @Comp_Desc, @Regs_Date, @Zip_Code, NULL, @Econ_Code, @Strt_Time, @End_Time, @Type, @Empy_Numb, @Bill_Addr_X, @Bill_Addr_Y, @Bill_Addr_Zoom, @Bill_Addr, @Ship_Addr_X, @Ship_Addr_Y, @Ship_Addr_Zoom, @Ship_Addr, @Face_Book_Url, @Link_In_Url, @Twtr_Url, @Cell_Phon, @Tell_Phon, @Dflt_Stat, @Host_Stat, @OwnrCode, @Fax_Numb, @Prim_Serv_File_No, @Trcb_Tcid, @Crdt_Stat, @Crdt_Amnt, @Pymt_Term, @Ownr_Ship, @Get_Know_Us, @Get_Know_Cust, @Cont_Mtod, @Alow_Emal, @Alow_Bulk_Emal, @Alow_Phon, @Alow_Fax, @Alow_Lett, @Ship_Mtod, @Ship_Chrg, @Revn_Amnt;
      END  
      ELSE IF @LeadType = 'newleadupdate'
      BEGIN 
         DECLARE @TName NVARCHAR(250);
         SELECT @TName = name FROM dbo.Company WHERE CODE = @CompCode;
         IF @TName = N'نامشخص' AND @Name != N'نامشخص'
         BEGIN
            IF NOT EXISTS (SELECT * FROM dbo.Company WHERE NAME = @Name AND REGN_PRVN_CNTY_CODE = @CntyCode AND REGN_PRVN_CODE = @PrvnCode AND REGN_CODE = @RegnCode)
               EXEC dbo.INS_COMP_P @CntyCode, @PrvnCode, @RegnCode, @Iscp_Isca_Iscg_Code, @Iscp_Isca_Code, @Iscp_Code, @Name, @Cord_X, @Cord_Y, @Post_Addr_Zoom, @Post_Adrs, @Emal_Adrs, @Web_Site, @Comp_Code, @Comp_Desc, @Regs_Date, @Zip_Code, NULL, @Econ_Code, @Strt_Time, @End_Time, @Type, @Empy_Numb, @Bill_Addr_X, @Bill_Addr_Y, @Bill_Addr_Zoom, @Bill_Addr, @Ship_Addr_X, @Ship_Addr_Y, @Ship_Addr_Zoom, @Ship_Addr, @Face_Book_Url, @Link_In_Url, @Twtr_Url, @Cell_Phon, @Tell_Phon, @Dflt_Stat, @Host_Stat, @OwnrCode, @Fax_Numb, @Prim_Serv_File_No, @Trcb_Tcid, @Crdt_Stat, @Crdt_Amnt, @Pymt_Term, @Ownr_Ship, @Get_Know_Us, @Get_Know_Cust, @Cont_Mtod, @Alow_Emal, @Alow_Bulk_Emal, @Alow_Phon, @Alow_Fax, @Alow_Lett, @Ship_Mtod, @Ship_Chrg, @Revn_Amnt;         
      
            SELECT TOP 1 @CompCode = CODE
              FROM dbo.Company
             WHERE CRET_BY = UPPER(SUSER_NAME())
               --AND CAST(CRET_DATE AS DATE) = CAST(GETDATE() AS DATE)
               AND NAME = @Name
               AND REGN_PRVN_CNTY_CODE = @CntyCode
               AND REGN_PRVN_CODE = @PrvnCode
               AND REGN_CODE = @RegnCode
             ORDER BY CRET_DATE DESC;                     
         END 
         EXEC dbo.Upd_COMP_P @CompCode, @Regn_Prvn_Cnty_Code, @Regn_Prvn_Code, @Regn_Code, @Iscp_Isca_Iscg_Code, @Iscp_Isca_Code, @Iscp_Code, @Name, @Cord_X, @Cord_Y, @Post_Addr_Zoom, @Post_Adrs, @Emal_Adrs, @Web_Site, @Comp_Code, @Comp_Desc, @Regs_Date, @Zip_Code, NULL, @Econ_Code, @Strt_Time, @End_Time, @Type, @Empy_Numb, @Bill_Addr_X, @Bill_Addr_Y, @Bill_Addr_Zoom, @Bill_Addr, @Ship_Addr_X, @Ship_Addr_Y, @Ship_Addr_Zoom, @Ship_Addr, @Face_Book_Url, @Link_In_Url, @Twtr_Url, @Cell_Phon, @Tell_Phon, @Dflt_Stat, @Host_Stat, @OwnrCode, @Fax_Numb, @Prim_Serv_File_No, @Trcb_Tcid, @Crdt_Stat, @Crdt_Amnt, @Pymt_Term, @Ownr_Ship, @Get_Know_Us, @Get_Know_Cust, @Cont_Mtod, @Alow_Emal, @Alow_Bulk_Emal, @Alow_Phon, @Alow_Fax, @Alow_Lett, @Ship_Mtod, @Ship_Chrg, @Revn_Amnt;         
      END 
      ELSE IF @LeadType = 'servicelead'
      BEGIN
         -- در اینجا اگر برای مشتری مستقیما درخواست سرنخ ثبت شود
         SELECT @CompCode = COMP_CODE_DNRM
           FROM dbo.Service
          WHERE FILE_NO = @FileNo;
         
         -- 1396/09/24 * اضافه کردن گزینه ثبت پروژه برای مشترکین که هیچ پروژه ای ندارند
         BEGIN
            DECLARE @XTemp XML
            SELECT @XTemp = (
               SELECT 0 AS '@rqstrqid'
                     ,@FileNo AS '@servfileno'
                     ,0 AS '@rqrorqstrqid'
                     ,0 AS '@rqrorwno'
                     ,'' AS '@rqstdesc'
                     ,(
                        SELECT CODE AS '@jbprcode'
                              ,'002' AS '@recstat'
                              ,0 AS '@code'
                              ,@FileNo AS '@servfileno'
                              ,0 AS '@rwno'
                          FROM dbo.Job_Personnel_Relation
                           FOR XML PATH('Service_Project'), ROOT('Service_Projects'), TYPE
                     )
                 FOR XML PATH('Project')
            );
            
            -- ثبت پروژه پیش فرض
            EXEC dbo.OPR_PSAV_P @X = @XTemp -- xml
            
            -- بدست آوردن شماره درخواست پروژه پیش فرض
            DECLARE @ProjRqstRqid BIGINT;
            SELECT TOP 1 @ProjRqstRqid = RQST_RQID
              FROM dbo.Request_Row 
             WHERE SERV_FILE_NO = @FileNo
               AND RQTP_CODE = '013'
               AND CRET_BY = UPPER(SUSER_NAME())
               AND CAST(CRET_DATE AS DATE) = CAST(GETDATE() AS DATE)
          ORDER BY CRET_DATE DESC;
            
            -- ثبت درخواست های ثبت شده بودن پروژه در پروژه پیش فرض
            UPDATE dbo.Request
               SET PROJ_RQST_RQID = @ProjRqstRqid
             WHERE RQID = @Rqid;

         END;
      END
      ELSE IF @LeadType = 'serviceleadupdate'
      BEGIN
         SELECT @ProjRqstRqid = PROJ_RQST_RQID
           FROM dbo.Request
          WHERE RQID = @Rqid;
         
         UPDATE dbo.Request
            SET RQST_DESC = @X.query('//Topc').value('.', 'NVARCHAR(250)')
          WHERE RQID = @ProjRqstRqid;
         
         EXEC dbo.Upd_COMP_P @CompCode, @Regn_Prvn_Cnty_Code, @Regn_Prvn_Code, @Regn_Code, @Iscp_Isca_Iscg_Code, @Iscp_Isca_Code, @Iscp_Code, @Name, @Cord_X, @Cord_Y, @Post_Addr_Zoom, @Post_Adrs, @Emal_Adrs, @Web_Site, @Comp_Code, @Comp_Desc, @Regs_Date, @Zip_Code, NULL, @Econ_Code, @Strt_Time, @End_Time, @Type, @Empy_Numb, @Bill_Addr_X, @Bill_Addr_Y, @Bill_Addr_Zoom, @Bill_Addr, @Ship_Addr_X, @Ship_Addr_Y, @Ship_Addr_Zoom, @Ship_Addr, @Face_Book_Url, @Link_In_Url, @Twtr_Url, @Cell_Phon, @Tell_Phon, @Dflt_Stat, @Host_Stat, @OwnrCode, @Fax_Numb, @Prim_Serv_File_No, @Trcb_Tcid, @Crdt_Stat, @Crdt_Amnt, @Pymt_Term, @Ownr_Ship, @Get_Know_Us, @Get_Know_Cust, @Cont_Mtod, @Alow_Emal, @Alow_Bulk_Emal, @Alow_Phon, @Alow_Fax, @Alow_Lett, @Ship_Mtod, @Ship_Chrg, @Revn_Amnt;         
      END
      ELSE IF @LeadType = 'companylead'
      BEGIN
         EXEC dbo.INS_SERV_P @Rqid, @CntyCode, @PrvnCode, @RegnCode, @FileNo OUT;
         SELECT @Regn_Prvn_Cnty_Code = @CntyCode
               ,@Regn_Prvn_Code = @PrvnCode
               ,@Regn_Code = @RegnCode;
      END 
      ELSE IF @LeadType = 'companyleadupdate'
      BEGIN
         SELECT @Regn_Prvn_Cnty_Code = @CntyCode
               ,@Regn_Prvn_Code = @PrvnCode
               ,@Regn_Code = @RegnCode;
      END 
      -- ثبت ردیف درخواست 
      DECLARE @RqroRwno SMALLINT;
      SELECT @RqroRwno = Rwno
        FROM Request_Row
       WHERE RQST_RQID = @Rqid
         AND SERV_FILE_NO = @FileNo;
           
      IF @RqroRwno IS NULL
      BEGIN
         EXEC INS_RQRO_P
            @Rqid
           ,@FileNo
           ,@RqroRwno OUT;
      END
      
      PRINT @LeadType
            
      -- 1397/08/28 * اگر درخواست از جانب شرکت ثبت شده باشد
      IF @LeadType IN ( 'companylead', 'companyleadupdate' )
      BEGIN
         UPDATE dbo.Request_Row
            SET COMP_CODE = @CompCode
          WHERE RQST_RQID = @Rqid
            AND COMP_CODE IS NULL;
      END 
	            
      -- تعریف ستون های جدول مشترک  
      DECLARE  --@Cnty_Code VARCHAR(3),
	            --@Prvn_Code VARCHAR(3),
	            --@Regn_Code VARCHAR(3),
	            --@File_No   BIGINT,
	            @SrpbRectCode VARCHAR(3),
	            @SrpbRwno INT,
	            @Btrf_Code BIGINT,
	            @Trfd_Code BIGINT,
	            --@COMP_Code BIGINT,
	            @Expn_Code BIGINT,
	            @Rect_Code VARCHAR(3),
	            @Frst_Name NVARCHAR(250),
	            @Last_Name NVARCHAR(250),
	            @Fath_Name NVARCHAR(250),
	            @Natl_Code VARCHAR(10),
	            @Brth_Date DATE,
	            --@Cell_Phon VARCHAR(11),
	            --@Tell_Phon VARCHAR(11),
	            @Educ_Deg VARCHAR(3),
               @Idty_Code VARCHAR(10),
               @Ownr_Type VARCHAR(3),
               @User_Name VARCHAR(250),
               @Pass_Word VARCHAR(250),
               @Telg_Chat_Code BIGINT,
               @Frst_Name_Ownr_Line NVARCHAR(250),
               @Last_Name_Ownr_Line NVARCHAR(250),
               @Natl_Code_Ownr_Line VARCHAR(10),
               @Line_Numb_Serv VARCHAR(10),
	            --@Post_Adrs NVARCHAR(1000),
	            --@Emal_Adrs NVARCHAR(250),
	            @OnOf_Tag  VARCHAR(3) = '101',
	            @Sunt_Bunt_Dept_Orgn_Code VARCHAR(2),
	            @Sunt_Bunt_Dept_Code VARCHAR(2),
	            @Sunt_Bunt_Code VARCHAR(2),
	            @Sunt_Code VARCHAR(4),
	            --@Iscp_Isca_Iscg_Code VARCHAR(2),
	            --@Iscp_Isca_Code VARCHAR(2),
	            --@Iscp_Code VARCHAR(6),
	            --@Cord_X REAL,
	            --@Cord_Y REAL,
	            @Most_Debt_Clng BIGINT,
	            @Sex_Type VARCHAR(3),
	            @Mrid_Type VARCHAR(3),
	            @Rlgn_Type VARCHAR(3),
	            @Ethn_City VARCHAR(3),
	            @Cust_Type VARCHAR(3),
	            @Stif_Type VARCHAR(3),
	            @Job_Titl VARCHAR(3),
	            --@Type VARCHAR(3),
	            --@Face_Book_Url NVARCHAR(1000),
	            --@Link_In_Url NVARCHAR(1000),
	            --@Twtr_Url NVARCHAR(1000),
	            @Serv_No VARCHAR(10);
   	
   	IF @LeadType IN ('newlead', 'newleadupdate', 'serviceleadupdate', 'companyleadupdate')
   	BEGIN   	
   	   -- استخراج اطلاعات عمومی مشتری
   	   SELECT @Btrf_Code = sp.query('Btrf_Code').value('.', 'BIGINT')
   	         ,@Trfd_Code = sp.query('Trfd_Code').value('.', 'BIGINT')
   	         ,@Expn_Code = sp.query('Expn_Code').value('.', 'BIGINT')
   	         ,@Frst_Name = sp.query('Frst_Name').value('.', 'NVARCHAR(250)')
   	         ,@Last_Name = sp.query('Last_Name').value('.', 'NVARCHAR(250)')
   	         ,@Fath_Name = sp.query('Fath_Name').value('.', 'NVARCHAR(250)')
   	         ,@Sex_Type = sp.query('Sex_Type').value('.', 'VARCHAR(3)')
   	         ,@Natl_Code = sp.query('Natl_Code').value('.', 'VARCHAR(10)')
   	         ,@Brth_Date = sp.query('Brth_Date').value('.', 'DATE')
   	         ,@Cell_Phon= sp.query('Cell_Phon').value('.', 'VARCHAR(11)')
   	         ,@Tell_Phon = sp.query('Tell_Phon').value('.', 'VARCHAR(11)')
   	         ,@Educ_Deg = sp.query('Educ_Deg').value('.', 'VARCHAR(3)')
   	         ,@Type = sp.query('Type').value('.', 'VARCHAR(3)')
   	         ,@Idty_Code = sp.query('Idty_Code').value('.', 'VARCHAR(10)')
   	         ,@Ownr_Type = sp.query('Ownr_Type').value('.', 'VARCHAR(3)')
   	         ,@User_Name = sp.query('User_Name').value('.', 'VARCHAR(250)')
   	         ,@Pass_Word = sp.query('Pass_Word').value('.', 'NVARCHAR(250)')
   	         ,@Telg_Chat_Code = sp.query('Telg_Chat_Code').value('.', 'BIGINT')
   	         ,@Frst_Name_Ownr_Line = sp.query('Frst_Name_Ownr_Line').value('.', 'NVARCHAR(250)')
   	         ,@Last_Name_Ownr_Line = sp.query('Last_Name_Ownr_Line').value('.', 'NVARCHAR(250)')
   	         ,@Natl_Code_Ownr_Line = sp.query('Natl_Code_Ownr_Line').value('.', 'VARCHAR(10)')
   	         ,@Line_Numb_Serv = sp.query('Line_Numb_Serv').value('.', 'VARCHAR(11)')
   	         ,@Post_Adrs = sp.query('Post_Adrs').value('.', 'NVARCHAR(1000)')
   	         ,@Emal_Adrs = sp.query('Emal_Adrs').value('.', 'NVARCHAR(250)')
   	         ,@OnOf_Tag = sp.query('Onof_Tag').value('.', 'VARCHAR(3)')
   	         ,@Sunt_Bunt_Dept_Orgn_Code = sp.query('Sunt_Bunt_Dept_Orgn_Code').value('.', 'VARCHAR(3)')
   	         ,@Sunt_Bunt_Dept_Code = sp.query('Sunt_Bunt_Dept_Code').value('.', 'VARCHAR(3)')
   	         ,@Sunt_Bunt_Code = sp.query('Sunt_Bunt_Code').value('.', 'VARCHAR(3)')
   	         ,@Sunt_Code = sp.query('Sunt_Code').value('.', 'VARCHAR(3)')
   	         ,@Iscp_Isca_Iscg_Code = sp.query('Iscp_Isca_Iscg_Code').value('.', 'VARCHAR(2)')
   	         ,@Iscp_Isca_Code = sp.query('Iscp_Isca_Code').value('.', 'VARCHAR(2)')
   	         ,@Iscp_Code = sp.query('Iscp_Code').value('.', 'VARCHAR(6)')
   	         ,@Cord_X = sp.query('Cord_X').value('.', 'FLOAT')
   	         ,@Cord_Y = sp.query('Cord_Y').value('.', 'FLOAT')
   	         ,@Most_Debt_Clng = sp.query('Most_Debt_Clng').value('.', 'BIGINT')
   	         ,@Mrid_Type = sp.query('Mrid_Type').value('.', 'VARCHAR(3)')
   	         ,@Rlgn_Type = sp.query('Rlgn_Type').value('.', 'VARCHAR(3)')
   	         ,@Ethn_City = sp.query('Ethn_City').value('.', 'VARCHAR(3)')
   	         ,@Cust_Type = sp.query('Cust_Type').value('.', 'VARCHAR(3)')
   	         ,@Stif_Type = sp.query('Stif_Type').value('.', 'VARCHAR(3)')
   	         ,@Job_Titl = sp.query('Job_Titl').value('.', 'VARCHAR(3)')
   	         ,@Face_Book_Url = sp.query('Face_Book_Url').value('.', 'VARCHAR(1000)')
   	         ,@Link_In_Url = sp.query('Link_In_Url').value('.', 'VARCHAR(1000)')
   	         ,@Twtr_Url = sp.query('Twtr_Url').value('.', 'VARCHAR(1000)')   	      
   	         ,@Serv_No = sp.query('Serv_No').value('.', 'VARCHAR(10)')
   	     FROM @x.nodes('//Service_Public') T(sp);   	
   	END 
   	ELSE IF @LeadType IN ('servicelead')
   	BEGIN
   	   -- استخراج اطلاعات عمومی مشتری
   	   SELECT @Regn_Prvn_Cnty_Code = sp.REGN_PRVN_CNTY_CODE
   	         ,@Regn_Prvn_Code = sp.REGN_PRVN_CODE
   	         ,@Regn_Code = sp.REGN_CODE
   	         ,@CompCode = sp.COMP_CODE
   	         ,@Btrf_Code = sp.BTRF_CODE
   	         ,@Trfd_Code = sp.TRFD_CODE
   	         ,@Expn_Code = sp.EXPN_CODE
   	         ,@Frst_Name = sp.FRST_NAME
   	         ,@Last_Name = sp.LAST_NAME
   	         ,@Fath_Name = sp.FATH_NAME
   	         ,@Sex_Type = sp.SEX_TYPE
   	         ,@Natl_Code = sp.NATL_CODE
   	         ,@Brth_Date = sp.BRTH_DATE
   	         ,@Cell_Phon= sp.CELL_PHON
   	         ,@Tell_Phon = sp.TELL_PHON
   	         ,@Educ_Deg = sp.EDUC_DEG
   	         ,@Type = sp.TYPE
   	         ,@Idty_Code = sp.IDTY_CODE
   	         ,@Ownr_Type = sp.OWNR_TYPE
   	         ,@User_Name = sp.USER_NAME
   	         ,@Pass_Word = sp.PASS_WORD
   	         ,@Telg_Chat_Code = sp.TELG_CHAT_CODE
   	         ,@Frst_Name_Ownr_Line = sp.FRST_NAME_OWNR_LINE
   	         ,@Last_Name_Ownr_Line = sp.LAST_NAME_OWNR_LINE
   	         ,@Natl_Code_Ownr_Line = sp.NATL_CODE_OWNR_LINE
   	         ,@Line_Numb_Serv = sp.LINE_NUMB_SERV
   	         ,@Post_Adrs = sp.POST_ADRS
   	         ,@Emal_Adrs = sp.EMAL_ADRS
   	         ,@OnOf_Tag = sp.ONOF_TAG
   	         ,@Sunt_Bunt_Dept_Orgn_Code = sp.SUNT_BUNT_DEPT_ORGN_CODE
   	         ,@Sunt_Bunt_Dept_Code = sp.SUNT_BUNT_DEPT_CODE
   	         ,@Sunt_Bunt_Code = sp.SUNT_BUNT_CODE
   	         ,@Sunt_Code = sp.SUNT_CODE
   	         ,@Iscp_Isca_Iscg_Code = sp.ISCP_ISCA_ISCG_CODE
   	         ,@Iscp_Isca_Code = sp.ISCP_ISCA_CODE
   	         ,@Iscp_Code = sp.ISCP_CODE
   	         ,@Cord_X = sp.CORD_X
   	         ,@Cord_Y = sp.CORD_Y
   	         ,@Most_Debt_Clng = sp.MOST_DEBT_CLNG
   	         ,@Mrid_Type = sp.MRID_TYPE
   	         ,@Rlgn_Type = sp.RLGN_TYPE
   	         ,@Ethn_City = sp.ETHN_CITY
   	         ,@Cust_Type = sp.CUST_TYPE
   	         ,@Stif_Type = sp.STIF_TYPE
   	         ,@Job_Titl = sp.JOB_TITL
   	         ,@Face_Book_Url = sp.FACE_BOOK_URL
   	         ,@Link_In_Url = sp.LINK_IN_URL
   	         ,@Twtr_Url = sp.TWTR_URL
   	         ,@Serv_No = sp.SERV_NO
   	     FROM dbo.Service s, dbo.Service_Public sp
   	    WHERE s.FILE_NO = sp.SERV_FILE_NO
   	      AND s.SRPB_RWNO_DNRM = sp.RWNO
   	      AND sp.RECT_CODE = '004'
   	      AND s.FILE_NO = @FileNo;
   	END
   	ELSE IF @LeadType IN ('companylead') 
   	BEGIN
   	   SELECT @Frst_Name = N''
   	         ,@Last_Name = N'';
      END
   	
      SET @Sunt_Bunt_Dept_Orgn_Code = CASE LEN(@Sunt_Bunt_Dept_Orgn_Code) WHEN 2 THEN @Sunt_Bunt_Dept_Orgn_Code ELSE '00'   END;
      SET @Sunt_Bunt_Dept_Code      = CASE LEN(@Sunt_Bunt_Dept_Code)      WHEN 2 THEN @Sunt_Bunt_Dept_Code      ELSE '00'   END;
      SET @Sunt_Bunt_Code           = CASE LEN(@Sunt_Bunt_Code)           WHEN 2 THEN @Sunt_Bunt_Code           ELSE '00'   END;
      SET @Sunt_Code                = CASE LEN(@Sunt_Code)                WHEN 4 THEN @Sunt_Code                ELSE '0000' END;   	
   	
   	SET @Btrf_Code = NULL
   	SET @Trfd_Code = NULL
   	SET @Expn_Code = NULL
   	
   	SET @Iscp_Isca_Iscg_Code = CASE LEN(@Iscp_Isca_Iscg_Code) WHEN 2 THEN @Iscp_Isca_Iscg_Code ELSE '00'     END;
      SET @Iscp_Isca_Code      = CASE LEN(@Iscp_Isca_Code)      WHEN 2 THEN @Iscp_Isca_Code      ELSE '00'     END;
      SET @Iscp_Code           = CASE LEN(@Iscp_Code)           WHEN 2 THEN @Iscp_Code           ELSE '000000' END;
   	
   	SET @OnOf_Tag = CASE LEN(@OnOf_Tag) WHEN 3 THEN @OnOf_Tag ELSE '101' END;
   	SET @Type = CASE LEN(@Type) WHEN 3 THEN @Type ELSE '002' END;
   	
   	IF NOT EXISTS(
   	   SELECT *
   	     FROM dbo.Service_Public
   	    WHERE RQRO_RQST_RQID = @Rqid
   	      AND SERV_FILE_NO = @FileNo
   	      AND RECT_CODE = '001'
   	)
   	BEGIN
   	   EXEC dbo.INS_SRPB_P @Cnty_Code = @Regn_Prvn_Cnty_Code, -- varchar(3)
   	       @Prvn_Code = @Regn_Prvn_Code, -- varchar(3)
   	       @Regn_Code = @Regn_Code, -- varchar(3)
   	       @File_No = @FileNo, -- bigint
   	       @Btrf_Code = @Btrf_Code, -- bigint
   	       @Trfd_Code = @Trfd_Code, -- bigint
   	       @COMP_Code = @CompCode, -- bigint
   	       @Expn_Code = @Expn_Code, -- bigint
   	       @Rqro_Rqst_Rqid = @Rqid, -- bigint
   	       @Rqro_Rwno = @RqroRwno, -- smallint
   	       @Rect_Code = '001', -- varchar(3)
   	       @Frst_Name = @Frst_Name, -- nvarchar(250)
   	       @Last_Name = @Last_Name, -- nvarchar(250)
   	       @Fath_Name = @Fath_Name, -- nvarchar(250)
   	       @Natl_Code = @Natl_Code, -- varchar(10)
   	       @Brth_Date = @Brth_Date, -- date
   	       @Cell_Phon = @Cell_Phon, -- varchar(11)
   	       @Tell_Phon = @Tell_Phon, -- varchar(11)
   	       @Idty_Code = @Idty_Code, -- varchar(10)
   	       @Ownr_Type = @Ownr_Type, -- varchar(3)
   	       @User_Name = @User_Name, -- varchar(250)
   	       @Pass_Word = @Pass_Word, -- varchar(250)
   	       @Telg_Chat_Code = @Telg_Chat_Code, -- bigint
   	       @Frst_Name_Ownr_Line = @Frst_Name_Ownr_Line, -- nvarchar(250)
   	       @Last_Name_Ownr_Line = @Last_Name_Ownr_Line, -- nvarchar(250)
   	       @Natl_Code_Ownr_Line = @Natl_Code_Ownr_Line, -- varchar(10)
   	       @Line_Numb_Serv = @Line_Numb_Serv, -- varchar(10)
   	       @Post_Adrs = @Post_Adrs, -- nvarchar(1000)
   	       @Emal_Adrs = @Emal_Adrs, -- nvarchar(250)
   	       @OnOf_Tag = @OnOf_Tag, -- varchar(3)
   	       @Sunt_Bunt_Dept_Orgn_Code = @Sunt_Bunt_Dept_Orgn_Code, -- varchar(2)
   	       @Sunt_Bunt_Dept_Code = @Sunt_Bunt_Dept_Code, -- varchar(2)
   	       @Sunt_Bunt_Code = @Sunt_Bunt_Code, -- varchar(2)
   	       @Sunt_Code = @Sunt_Code, -- varchar(4)
   	       @Iscp_Isca_Iscg_Code = @Iscp_Isca_Iscg_Code, -- varchar(2)
   	       @Iscp_Isca_Code = @Iscp_Isca_Code, -- varchar(2)
   	       @Iscp_Code = @Iscp_Code, -- varchar(6)
   	       @Cord_X = @Cord_X, -- real
   	       @Cord_Y = @Cord_Y, -- real
   	       @Most_Debt_Clng = @Most_Debt_Clng, -- bigint
   	       @Sex_Type = @Sex_Type, -- varchar(3)
   	       @Mrid_Type = @Mrid_Type, -- varchar(3)
   	       @Rlgn_Type = @Rlgn_Type, -- varchar(3)
   	       @Ethn_City = @Ethn_City, -- varchar(3)
   	       @Cust_Type = @Cust_Type, -- varchar(3)
   	       @Stif_Type = @Stif_Type, -- varchar(3)
   	       @Job_Titl = @Job_Titl, -- varchar(3)
   	       @Type = @Type, -- varchar(3)
   	       @Face_Book_Url = @Face_Book_Url, -- nvarchar(1000)
   	       @Link_In_Url = @Link_In_Url, -- nvarchar(1000)
   	       @Twtr_Url = @Twtr_Url, -- nvarchar(1000)
   	       @Serv_No = @Serv_No; -- varchar(10)   	   
   	END 
   	ELSE
   	BEGIN
   	   EXEC dbo.UPD_SRPB_P @Cnty_Code = @Regn_Prvn_Cnty_Code, -- varchar(3)
   	       @Prvn_Code = @Regn_Prvn_Code, -- varchar(3)
   	       @Regn_Code = @Regn_Code, -- varchar(3)
   	       @File_No = @FileNo, -- bigint
   	       @Btrf_Code = @Btrf_Code, -- bigint
   	       @Trfd_Code = @Trfd_Code, -- bigint
   	       @COMP_Code = @CompCode, -- bigint
   	       @Expn_Code = @Expn_Code, -- bigint
   	       @Rqro_Rqst_Rqid = @Rqid, -- bigint
   	       @Rqro_Rwno = @RqroRwno, -- smallint
   	       @Rect_Code = '001', -- varchar(3)
   	       @Frst_Name = @Frst_Name, -- nvarchar(250)
   	       @Last_Name = @Last_Name, -- nvarchar(250)
   	       @Fath_Name = @Fath_Name, -- nvarchar(250)
   	       @Natl_Code = @Natl_Code, -- varchar(10)
   	       @Brth_Date = @Brth_Date, -- date
   	       @Cell_Phon = @Cell_Phon, -- varchar(11)
   	       @Tell_Phon = @Tell_Phon, -- varchar(11)
   	       @Idty_Code = @Idty_Code, -- varchar(10)
   	       @Ownr_Type = @Ownr_Type, -- varchar(3)
   	       @User_Name = @User_Name, -- varchar(250)
   	       @Pass_Word = @Pass_Word, -- varchar(250)
   	       @Telg_Chat_Code = @Telg_Chat_Code, -- bigint
   	       @Frst_Name_Ownr_Line = @Frst_Name_Ownr_Line, -- nvarchar(250)
   	       @Last_Name_Ownr_Line = @Last_Name_Ownr_Line, -- nvarchar(250)
   	       @Natl_Code_Ownr_Line = @Natl_Code_Ownr_Line, -- varchar(10)
   	       @Line_Numb_Serv = @Line_Numb_Serv, -- varchar(10)
   	       @Post_Adrs = @Post_Adrs, -- nvarchar(1000)
   	       @Emal_Adrs = @Emal_Adrs, -- nvarchar(250)
   	       @OnOf_Tag = @OnOf_Tag, -- varchar(3)
   	       @Sunt_Bunt_Dept_Orgn_Code = @Sunt_Bunt_Dept_Orgn_Code, -- varchar(2)
   	       @Sunt_Bunt_Dept_Code = @Sunt_Bunt_Dept_Code, -- varchar(2)
   	       @Sunt_Bunt_Code = @Sunt_Bunt_Code, -- varchar(2)
   	       @Sunt_Code = @Sunt_Code, -- varchar(4)
   	       @Iscp_Isca_Iscg_Code = @Iscp_Isca_Iscg_Code, -- varchar(2)
   	       @Iscp_Isca_Code = @Iscp_Isca_Code, -- varchar(2)
   	       @Iscp_Code = @Iscp_Code, -- varchar(6)
   	       @Cord_X = @Cord_X, -- real
   	       @Cord_Y = @Cord_Y, -- real
   	       @Most_Debt_Clng = @Most_Debt_Clng, -- bigint
   	       @Sex_Type = @Sex_Type, -- varchar(3)
   	       @Mrid_Type = @Mrid_Type, -- varchar(3)
   	       @Rlgn_Type = @Rlgn_Type, -- varchar(3)
   	       @Ethn_City = @Ethn_City, -- varchar(3)
   	       @Cust_Type = @Cust_Type, -- varchar(3)
   	       @Stif_Type = @Stif_Type, -- varchar(3)
   	       @Job_Titl = @Job_Titl, -- varchar(3)
   	       @Type = @Type, -- varchar(3)
   	       @Face_Book_Url = @Face_Book_Url, -- nvarchar(1000)
   	       @Link_In_Url = @Link_In_Url, -- nvarchar(1000)
   	       @Twtr_Url = @Twtr_Url, -- nvarchar(1000)
   	       @Serv_No = @Serv_No; -- varchar(10)   	   
   	END
   	
   	-- ثبت اطلاعات سرنخ تجاری
   	DECLARE @Camp_Cmid BIGINT
   	       ,@Ldid BIGINT
   	       ,@Topc NVARCHAR(250)
   	       ,@Prch_Time VARCHAR(3)
   	       ,@Bdgt_Amnt BIGINT
   	       ,@Prch_Proc VARCHAR(3)
   	       ,@Idcm_Stat VARCHAR(3)
   	       ,@Capt_Smry NVARCHAR(100)
   	       ,@Cmnt NVARCHAR(4000)
   	       ,@Crnt_Situ NVARCHAR(500)
   	       ,@Cust_Need NVARCHAR(500)
   	       ,@Prop_Solt NVARCHAR(500)
   	       ,@Idty_Stak_Hldr VARCHAR(3)
   	       ,@Idty_Cmpt VARCHAR(3)
   	       ,@Idty_Sale_Team VARCHAR(3)
   	       ,@Devl_Prop VARCHAR(3)
   	       ,@Cmpl_Intr_Revw VARCHAR(3)
   	       ,@Pres_Prop VARCHAR(3)
   	       ,@Cmpl_Finl_Prop VARCHAR(3)
   	       ,@Pres_Finl_Prop VARCHAR(3)
   	       ,@Conf_Date DATETIME
   	       ,@Send_Thnk_You VARCHAR(3)
   	       ,@File_Dbrf VARCHAR(3)
   	       ,@Emst_Clos_Date DATETIME
   	       ,@Emst_Revn_Amnt BIGINT
   	       ,@Expn_Cost_Amnt BIGINT
   	       ,@Stat VARCHAR(3)
   	       ,@Sorc VARCHAR(3)
   	       ,@Rtng VARCHAR(3)
   	       ,@Send_Camp_Info VARCHAR(3)
   	       ,@Psbl_Numb SMALLINT;
   
   SELECT @Camp_Cmid = l.query('Camp_Cmid').value('.', 'BIGINT')
         ,@Ldid = l.query('Ldid').value('.', 'BIGINT')
         ,@OwnrCode = l.query('Ownr_Code').value('.', 'BIGINT')
         ,@Topc = l.query('Topc').value('.', 'NVARCHAR(250)')
         ,@Prch_Time = l.query('Prch_Time').value('.', 'VARCHAR(3)')
         ,@Bdgt_Amnt = l.query('Bdgt_Amnt').value('.', 'BIGINT')
         ,@Prch_Proc = l.query('Prch_Proc').value('.', 'VARCHAR(3)')
         ,@Idcm_Stat = l.query('Idcm_Stat').value('.', 'VARCHAR(3)')
         ,@Capt_Smry = l.query('Capt_Smry').value('.', 'NVARCHAR(100)')
         ,@Cmnt = l.query('Cmnt').value('.', 'NVARCHAR(4000)')
         ,@Crnt_Situ = l.query('Crnt_Situ').value('.', 'NVARCHAR(500)')
         ,@Cust_Need = l.query('Cust_Need').value('.', 'NVARCHAR(500)')
         ,@Prop_Solt = l.query('Prop_Solt').value('.', 'NVARCHAR(500)')
         ,@Idty_Cmpt = l.query('Idty_Cmpt').value('.', 'VARCHAR(3)')
         ,@Idty_Sale_Team = l.query('Idty_Sale_Team').value('.', 'VARCHAR(3)')
         ,@Devl_Prop = l.query('Devl_Prop').value('.', 'VARCHAR(3)')
         ,@Cmpl_Intr_Revw = l.query('Cmpl_Intr_Revw').value('.', 'VARCHAR(3)')
         ,@Pres_Prop = l.query('Pres_Prop').value('.', 'VARCHAR(3)')
         ,@Cmpl_Finl_Prop = l.query('Cmpl_Finl_Prop').value('.', 'VARCHAR(3)')
         ,@Pres_Finl_Prop = l.query('Pres_Finl_Prop').value('.', 'VARCHAR(3)')
         ,@Conf_Date = l.query('Conf_Date').value('.', 'DATETIME')
         ,@Send_Thnk_You = l.query('Send_Thnk_You').value('.', 'VARCHAR(3)')
         ,@File_Dbrf = l.query('File_Dbrf').value('.', 'VARCHAR(3)')
         ,@Emst_Revn_Amnt = l.query('Emst_Revn_Amnt').value('.', 'BIGINT')
         ,@Expn_Cost_Amnt = l.query('Expn_Cost_Amnt').value('.', 'BIGINT')
         ,@Emst_Clos_Date = l.query('Emst_Clos_Date').value('.', 'DATETIME')
         ,@Stat = l.query('Stat').value('.', 'VARCHAR(3)')
         ,@Sorc = l.query('Sorc').value('.', 'VARCHAR(3)')
         ,@Rtng = l.query('Rtng').value('.', 'VARCHAR(3)')
         ,@Send_Camp_Info = l.query('Send_Camp_Info').value('.', 'VARCHAR(3)')
         ,@Psbl_Numb = l.query('Psbl_Numb').value('.', 'SMALLINT')
     FROM @X.nodes('//Lead') T(l)
      
      IF @OwnrCode = 0 OR @OwnrCode IS NULL
         SELECT @OwnrCode = CODE
           FROM dbo.Job_Personnel
          WHERE STAT = '002'
            AND [USER_NAME] = UPPER(SUSER_NAME());
      
      SET @Camp_Cmid = CASE @Camp_Cmid WHEN 0 THEN NULL ELSE @Camp_Cmid END
      SELECT @SrpbRectCode = RECT_CODE
            ,@SrpbRwno = RWNO
        FROM dbo.Service_Public
       WHERE RQRO_RQST_RQID = @Rqid
         AND SERV_FILE_NO = @FileNo;
      
      IF (@Stat IS NULL OR @Stat = '') set @Stat = '001';
           
      MERGE dbo.Lead T
      USING (SELECT @Rqid AS RQRO_RQST_RQID, @RqroRwno AS RQRO_RWNO ) S
      ON (T.RQRO_RQST_RQID = S.RQRO_RQST_RQID AND
          T.RQRO_RWNO = S.RQRO_RWNO)
      WHEN NOT MATCHED THEN 
         INSERT (RQRO_RQST_RQID, RQRO_RWNO, COMP_CODE, SRPB_SERV_FILE_NO, SRPB_RWNO, SRPB_RECT_CODE, LDID, OWNR_CODE, CAMP_CMID, TOPC, PRCH_TIME,
                 BDGT_AMNT, PRCH_PROC, IDCM_STAT, CAPT_SMRY, CMNT, CRNT_SITU, CUST_NEED, 
                 PROP_SOLT, IDTY_STAK_HLDR, IDTY_CMPT, IDTY_SALE_TEAM, DEVL_PROP, CMPL_INTR_REVW,
                 PRES_PROP, CMPL_FINL_PROP, PRES_FINL_PROP, CONF_DATE, SEND_THNK_YOU, 
                 FILE_DBRF, EMST_CLOS_DATE, EMST_REVN_AMNT, EXPN_COST_AMNT, STAT, SORC, RTNG, SEND_CAMP_INFO, PSBL_NUMB, TRCB_TCID)
         VALUES (S.RQRO_RQST_RQID, S.RQRO_RWNO, @CompCode, @FileNo, @SrpbRwno, @SrpbRectCode, 0, @OWNRCODE, @CAMP_CMID, @TOPC, @PRCH_TIME,
                 @BDGT_AMNT, @PRCH_PROC, @IDCM_STAT, @CAPT_SMRY, @CMNT, @CRNT_SITU, @CUST_NEED, 
                 @PROP_SOLT, @IDTY_STAK_HLDR, @IDTY_CMPT, @IDTY_SALE_TEAM, @DEVL_PROP, @CMPL_INTR_REVW,
                 @PRES_PROP, @CMPL_FINL_PROP, @PRES_FINL_PROP, @CONF_DATE, @SEND_THNK_YOU, 
                 @FILE_DBRF, @EMST_CLOS_DATE, @EMST_REVN_AMNT, @Expn_Cost_Amnt, @STAT, @SORC, @RTNG, @SEND_CAMP_INFO, @Psbl_Numb, @Trcb_Tcid)
      WHEN MATCHED THEN
         UPDATE 
            SET T.OWNR_CODE = @OwnrCode
               ,T.CAMP_CMID = @Camp_Cmid
               ,T.COMP_CODE = @CompCode
               ,T.SRPB_SERV_FILE_NO = @FileNo
               ,T.SRPB_RECT_CODE = @SrpbRectCode
               ,T.SRPB_RWNO = @SrpbRwno
               ,T.TOPC = @Topc
               ,T.PRCH_TIME = @Prch_Time
               ,T.BDGT_AMNT = @Bdgt_Amnt
               ,T.PRCH_PROC = @Prch_Proc
               ,T.IDCM_STAT = @Idcm_Stat
               ,T.CAPT_SMRY = @Capt_Smry
               ,T.CMNT = @Cmnt
               ,T.CRNT_SITU = @Crnt_Situ
               ,T.CUST_NEED = @Cust_Need
               ,T.PROP_SOLT = @Prop_Solt
               ,T.IDTY_STAK_HLDR = @Idty_Stak_Hldr
               ,T.IDTY_CMPT = @Idty_Cmpt
               ,T.IDTY_SALE_TEAM = @Idty_Sale_Team
               ,T.DEVL_PROP = @Devl_Prop
               ,T.CMPL_INTR_REVW = @Cmpl_Intr_Revw  
               ,T.PRES_PROP = @Pres_Prop
               ,T.CMPL_FINL_PROP = @Cmpl_Finl_Prop
               ,T.PRES_FINL_PROP = @Pres_Finl_Prop
               ,T.CONF_DATE = @Conf_Date
               ,T.SEND_THNK_YOU = @Send_Thnk_You
               ,T.FILE_DBRF = @File_Dbrf
               ,T.EMST_CLOS_DATE = @Emst_Clos_Date
               ,T.EMST_REVN_AMNT = @Emst_Revn_Amnt
               ,T.EXPN_COST_AMNT = @Expn_Cost_Amnt
               ,T.STAT = @Stat
               ,T.SORC = @Sorc
               ,T.RTNG = @Rtng
               ,T.SEND_CAMP_INFO = @Send_Camp_Info
               ,T.PSBL_NUMB = @Psbl_Numb
               ,T.TRCB_TCID = @Trcb_Tcid;
      -- تعریف ستون های جدول اطلاعات سرنخ
   COMMIT TRAN T_OPR_LEAD_P
   RETURN 0;
   END TRY
   BEGIN CATCH 
      DECLARE @ErrorMessage NVARCHAR(MAX);
      SET @ErrorMessage = ERROR_MESSAGE();
      RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN T_OPR_LEAD_P;
      RETURN -1;
   END CATCH;
END;
GO
