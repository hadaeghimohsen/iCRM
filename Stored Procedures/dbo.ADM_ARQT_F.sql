SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ADM_ARQT_F]
	-- Add the parameters for the stored procedure here
	@X XML
AS
BEGIN
   DECLARE @AP BIT
          ,@AccessString VARCHAR(250);
   SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>59</Privilege><Sub_Sys>11</Sub_Sys></AP>';	
   EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
   IF @AP = 0 
   BEGIN
      RAISERROR ( N'خطا - عدم دسترسی به ردیف 59 سطوح امینتی', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   
	DECLARE @ErrorMessage NVARCHAR(MAX);
	BEGIN TRAN T1;
	BEGIN TRY
	   DECLARE @Rqid     BIGINT,
	           @RqstRqid BIGINT,
	           @RqtpCode VARCHAR(3),
	           @RqttCode VARCHAR(3),
	           @RegnCode VARCHAR(3),
	           @PrvnCode VARCHAR(3),
	           @CntyCode VARCHAR(3);
   	
   	DECLARE @FileNo BIGINT;
      SELECT @FileNo = @X.query('//Service').value('(Service/@fileno)[1]', 'BIGINT');
      
	   SELECT @Rqid     = @X.query('//Request').value('(Request/@rqid)[1]'    , 'BIGINT')
	         ,@RqstRqid = @X.query('//Request').value('(Request/@rqstrqid)[1]'    , 'BIGINT')
	         ,@RqtpCode = @X.query('//Request').value('(Request/@rqtpcode)[1]', 'VARCHAR(3)')
	         ,@RqttCode = @X.query('//Request').value('(Request/@rqttcode)[1]', 'VARCHAR(3)')
	         ,@RegnCode = @X.query('//Request').value('(Request/@regncode)[1]', 'VARCHAR(3)')
	         ,@PrvnCode = @X.query('//Request').value('(Request/@prvncode)[1]', 'VARCHAR(3)')
	         ,@CntyCode = @X.query('//Request').value('(Request/@cntycode)[1]', 'VARCHAR(3)');
      
      IF @RqtpCode = '001' AND ( @RegnCode IS NULL OR @PrvnCode IS NULL )
         SELECT TOP 1 @RegnCode = CODE
                     ,@PrvnCode = PRVN_CODE
                     ,@CntyCode = PRVN_CNTY_CODE
           FROM Region;

      ELSE IF @RqtpCode != '001' AND ( @RegnCode IS NULL OR @PrvnCode IS NULL )
         SELECT @RegnCode = s.REGN_CODE
               ,@PrvnCode = s.REGN_PRVN_CODE
               ,@CntyCode = s.REGN_PRVN_CNTY_CODE
           FROM dbo.Service s
          WHERE FILE_NO = @FileNo;      
      
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
      END
      ELSE
      BEGIN
         UPDATE dbo.Request
            SET SSTT_MSTT_CODE = 1
               ,SSTT_CODE = 1
          WHERE RQID = @Rqid;
          
         EXEC UPD_RQST_P
            @Rqid,
            @CntyCode,
            @PrvnCode,
            @RegnCode,
            @RqtpCode,
            @RqttCode,
            NULL,
            NULL,
            NULL;            
      END      
      
      -- ثبت شماره پرونده 
      IF @FileNo IS NULL OR @FileNo = 0
      BEGIN
         EXEC dbo.INS_SERV_P @Rqid, @CntyCode, @PrvnCode, @RegnCode, @FileNo OUT;
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
      
      DECLARE
        @CompCode BIGINT
       ,@BtrfCode BIGINT
       ,@TrfdCode BIGINT
       ,@ExpnCode BIGINT
       ,@FrstName NVARCHAR(250)
       ,@LastName NVARCHAR(250)
       ,@FathName NVARCHAR(250)
       ,@NatlCode VARCHAR(10)
       ,@BrthDate DATE
       ,@CellPhon VARCHAR(11)
       ,@TellPhon VARCHAR(11)
       ,@IdtyCode VARCHAR(10)
       ,@OwnrType VARCHAR(3)
       ,@UserName VARCHAR(250)
       ,@PassWord VARCHAR(250)
       ,@TelgChatCode BIGINT
       ,@FrstNameOwnrLine NVARCHAR(250)
       ,@LastNameOwnrLine NVARCHAR(250)
       ,@NatlCodeOwnrLine VARCHAR(10)
       ,@LineNumbServ VARCHAR(11)             
       ,@PostAdrs NVARCHAR(1000)
       ,@EmalAdrs NVARCHAR(250)
       ,@OnOfTag VARCHAR(3)
       ,@SuntBuntDeptOrgnCode VARCHAR(2)
       ,@SuntBuntDeptCode VARCHAR(2)
       ,@SuntBuntCode VARCHAR(2)
       ,@SuntCode VARCHAR(4)
       ,@IscpIscaIscgCode VARCHAR(2)
       ,@IscpIscaCode VARCHAR(2)
       ,@IscpCode VARCHAR(6)
       ,@CordX FLOAT
       ,@CordY FLOAT
       ,@MostDebtClng BIGINT
       ,@SexType VARCHAR(3)
       ,@MridType VARCHAR(3)
       ,@RlgnType VARCHAR(3)
       ,@EthnCity VARCHAR(3)
       ,@CustType VARCHAR(3)
       ,@JobTitl VARCHAR(3)
       ,@Type VARCHAR(3)
       ,@ServStagCode VARCHAR(3)
       ,@FaceBookUrl NVARCHAR(1000)
       ,@LinkInUrl NVARCHAR(1000)
       ,@TwtrUrl NVARCHAR(1000)
       ,@ServNo VARCHAR(10);
             
      SELECT @CompCode = @X.query('//Comp_Code').value('.', 'BIGINT')
            ,@BtrfCode = @X.query('//Btrf_Code').value('.', 'BIGINT')
            ,@TrfdCode = @X.query('//Trfd_Code').value('.', 'BIGINT')
            ,@OnOfTag = @X.query('//Onof_Tag').value('.', 'VARCHAR(3)')
            ,@FrstName = @X.query('//Frst_Name').value('.', 'NVARCHAR(250)')
            ,@LastName = @X.query('//Last_Name').value('.', 'NVARCHAR(250)')
            ,@FathName = @X.query('//Fath_Name').value('.', 'NVARCHAR(250)')
            ,@NatlCode = @X.query('//Natl_Code').value('.', 'VARCHAR(10)')
            ,@BrthDate = @X.query('//Brth_Date').value('.', 'Date')
            ,@CellPhon = @X.query('//Cell_Phon').value('.', 'VARCHAR(11)')
            ,@TellPhon = @X.query('//Tell_Phon').value('.', 'VARCHAR(11)')
            ,@IdtyCode = @X.query('//Idty_Code').value('.', 'VARCHAR(10)')
            ,@OwnrType = @X.query('//Ownr_Type').value('.', 'VARCHAR(3)')
            ,@UserName = @X.query('//User_Name').value('.', 'VARCHAR(250)')
            ,@PassWord = @X.query('//Pass_Word').value('.', 'VARCHAR(250)')
            ,@TelgChatCode = @X.query('//Telg_Chat_Code').value('.', 'BIGINT')
            ,@FrstNameOwnrLine = @X.query('//Frst_Name_Ownr_Line').value('.', 'NVARCHAR(250)')
            ,@LastNameOwnrLine = @X.query('//Last_Name_Ownr_Line').value('.', 'NVARCHAR(250)')
            ,@NatlCodeOwnrLine = @X.query('//Natl_Code_Ownr_Line').value('.', 'VARCHAR(10)')
            ,@LineNumbServ = @X.query('//Line_Numb_Serv').value('.', 'NVARCHAR(11)')            
            ,@PostAdrs = @X.query('//Post_Adrs').value('.', 'NVARCHAR(1000)')
            ,@EmalAdrs = @X.query('//Emal_Adrs').value('.', 'VARCHAR(250)')
            ,@SuntBuntDeptOrgnCode = @x.query('//Sunt_Bunt_Dept_Orgn_Code').value('.', 'VARCHAR(2)')
            ,@SuntBuntDeptCode = @x.query('//Sunt_Bunt_Dept_Code').value('.', 'VARCHAR(2)')
            ,@SuntBuntCode = @x.query('//Sunt_Bunt_Code').value('.', 'VARCHAR(2)')
            ,@SuntCode = @x.query('//Sunt_Code').value('.', 'VARCHAR(4)')
            ,@IscpIscaIscgCode = @x.query('//Iscp_Isca_Iscg_Code').value('.', 'VARCHAR(2)')
            ,@IscpIscaCode = @x.query('//Iscp_Isca_Code').value('.', 'VARCHAR(2)')
            ,@IscpCode = @x.query('//Iscp_Code').value('.', 'VARCHAR(6)')
            ,@CordX = @x.query('//Cord_X').value('.', 'FLOAT')
            ,@CordY = @x.query('//Cord_Y').value('.', 'FLOAT')
            ,@MostDebtClng = @x.query('//Most_Debt_Clng').value('.', 'BIGINT')
            ,@SexType = @x.query('//Sex_Type').value('.', 'VARCHAR(3)')
            ,@MridType = @x.query('//Mrid_Type').value('.', 'VARCHAR(3)')
            ,@RlgnType = @x.query('//Rlgn_Type').value('.', 'VARCHAR(3)')
            ,@EthnCity = @x.query('//Ethn_City').value('.', 'VARCHAR(3)')
            ,@CustType = @x.query('//Cust_Type').value('.', 'VARCHAR(3)')
            ,@JobTitl = @x.query('//Job_Titl').value('.', 'VARCHAR(3)')
            ,@Type = @x.query('//Type').value('.', 'VARCHAR(3)')
            ,@ServStagCode = @x.query('//Serv_Stag_Code').value('.', 'VARCHAR(3)')
            ,@FaceBookUrl = @x.query('//Face_Book_Url').value('.', 'NVARCHAR(1000)')
            ,@LinkInUrl = @x.query('//Link_In_Url').value('.', 'NVARCHAR(1000)')
            ,@TwtrUrl = @x.query('//Twtr_Url').value('.', 'NVARCHAR(1000)')
            ,@ServNo = @x.query('//Serv_No').value('.', 'VARCHAR(10)');
            
      -- Begin Check Validate
      --IF ISNULL(@CompCode, 0)  = 0 RAISERROR (N'فیلد "دفتر نمایندگی" وارد نشده' , 16, 1);
      IF @RqtpCode = '001'
      BEGIN
         IF LEN(@FrstName)        = 0 RAISERROR (N'فیلد "نام" وارد نشده' , 16, 1);
         IF LEN(@LastName)        = 0 RAISERROR (N'فیلد "نام خانوداگی" وارد نشده' , 16, 1);
         --IF LEN(@FathName)        = 0 RAISERROR (N'فیلد "نام پدر" وارد نشده' , 16, 1);
      END
      --IF LEN(@OwnrType)        = 0 RAISERROR (N'فیلد "نوع مالکیت" وارد نشده' , 16, 1);
      --IF @BrthDate             = '1900-01-01' RAISERROR (N'فیلد "تاریخ تولد" وارد نشده' , 16, 1);      
      --IF LEN(@NatlCode)        = 0 RAISERROR (N'فیلد "کد ملی" وارد نشده' , 16, 1);
      --IF LEN(@IdtyCode)        = 0 RAISERROR (N'فیلد "ش.ش" وارد نشده' , 16, 1);
      --IF LEN(@CellPhon)        = 0 RAISERROR (N'فیلد "شماره همراه" وارد نشده' , 16, 1);
      --IF LEN(@TellPhon)        = 0 RAISERROR (N'فیلد "تلفن ثابت" وارد نشده' , 16, 1);
      --IF LEN(@PostAdrs)        = 0 RAISERROR (N'فیلد "ش.ش" وارد نشده' , 16, 1);
      --IF ISNULL(@BtrfCode, 0)  = 0 RAISERROR (N'فیلد "انتخاب سرویس" وارد نشده' , 16, 1);
      --IF ISNULL(@TrfdCode ,0)  = 0 RAISERROR (N'فیلد "انتخاب تعرفه" وارد نشده' , 16, 1);
      --IF @StrtDate             = '1900-01-01' RAISERROR (N'فیلد "تاریخ شروع" وارد نشده' , 16, 1);      
      --IF @EndDate              = '1900-01-01' RAISERROR (N'فیلد "تاریخ پایان" وارد نشده' , 16, 1);      
      --IF ISNULL(@VolmOfTrfc ,0)  = 0 RAISERROR (N'فیلد "حجم دانلود" وارد نشده' , 16, 1);
      --IF LEN(@UserName)        = 0 RAISERROR (N'فیلد "نام کاربری" وارد نشده' , 16, 1);
      --IF LEN(@PassWord)        = 0 RAISERROR (N'فیلد "رمز عبور" وارد نشده' , 16, 1);
      --IF LEN(@LineNumbServ)    = 0 RAISERROR (N'فیلد "خط تلفن جهت ارائه سرویس" وارد نشده' , 16, 1);
      
      SET @SuntBuntDeptOrgnCode = CASE LEN(@SuntBuntDeptOrgnCode) WHEN 2 THEN @SuntBuntDeptOrgnCode ELSE '00'   END;
      SET @SuntBuntDeptCode     = CASE LEN(@SuntBuntDeptCode)     WHEN 2 THEN @SuntBuntDeptCode     ELSE '00'   END;
      SET @SuntBuntCode         = CASE LEN(@SuntBuntCode)         WHEN 2 THEN @SuntBuntCode         ELSE '00'   END;
      SET @SuntCode             = CASE LEN(@SuntCode)             WHEN 4 THEN @SuntCode             ELSE '0000' END;
      
      SET @IscpIscaIscgCode     = CASE LEN(@IscpIscaIscgCode)     WHEN 2 THEN @IscpIscaIscgCode     ELSE '00'       END;
      SET @IscpIscaCode         = CASE LEN(@IscpIscaCode)         WHEN 2 THEN @IscpIscaCode         ELSE '00'       END;
      SET @IscpCode             = CASE LEN(@IscpCode)             WHEN 6 THEN @IscpCode             ELSE '000000'   END;
      
      SET @OnOfTag = CASE LEN(@OnOfTag) WHEN 3 THEN @OnOfTag ELSE '101' END;
      
      -- End Check Validate
      IF NOT EXISTS(SELECT * FROM dbo.Company WHERE code = @CompCode AND REGN_PRVN_CNTY_CODE = @CntyCode AND REGN_PRVN_CODE = @PrvnCode AND REGN_CODE = @RegnCode)
         SET @CompCode = NULL;
      
      -- 1396/02/25 * اگر مشتری احتمالی باشه شاید برای انتخاب شرکت از شرکت پیش فرض ناحیه استفاده می کنیم
      IF @CompCode IS NULL
         SELECT TOP 1 @CompCode = CODE
           FROM dbo.Company
          WHERE REGN_PRVN_CNTY_CODE = @CntyCode
            AND REGN_PRVN_CODE = @PrvnCode
            AND REGN_CODE = @RegnCode
            AND DFLT_STAT = '002';

      IF @BtrfCode = 0
         SET @BtrfCode = NULL;
      IF @TrfdCode = 0
         SET @TrfdCode = NULL;
      IF @CordX = 0
         SET @CordX = NULL;
      IF @CordY = 0
         SET @CordY = NULL;
      
      
      IF @RqtpCode != '001' AND NOT EXISTS(
         SELECT *
           FROM dbo.Service_Public
          WHERE RQRO_RQST_RQID = @Rqid
            AND SERV_FILE_NO = @FileNo
            AND RECT_CODE = '001'
      )
      BEGIN
         SELECT 
             @CntyCode = P.REGN_PRVN_CNTY_CODE
            ,@PrvnCode = p.REGN_PRVN_CODE
            ,@RegnCode = p.REGN_CODE
            ,@FileNo   = p.SERV_FILE_NO
            ,@CompCode = ISNULL(@CompCode,  COMP_CODE)
            ,@BtrfCode = ISNULL(@BtrfCode, P.BTRF_CODE)
            ,@TrfdCode = ISNULL(@TrfdCode, P.TRFD_CODE)
            ,@FrstName = FRST_NAME
            ,@LastName = LAST_NAME
            ,@FathName = FATH_NAME
            ,@NatlCode = NATL_CODE
            ,@BrthDate = BRTH_DATE
            ,@CellPhon = dbo.IsStringNullOrEmpty(@CellPhon, CELL_PHON)
            ,@TellPhon = TELL_PHON
            ,@IdtyCode = IDTY_CODE
            ,@TelgChatCode = TELG_CHAT_CODE
            ,@PostAdrs = POST_ADRS
            ,@EmalAdrs = CASE ISNULL(@EmalAdrs, EMAL_ADRS) WHEN '' THEN P.EMAL_ADRS ELSE ISNULL(@EmalAdrs, EMAL_ADRS) END
            ,@OnOfTag = ISNULL(@OnOfTag, ONOF_TAG)
            ,@SuntBuntDeptOrgnCode = SUNT_BUNT_DEPT_ORGN_CODE
            ,@SuntBuntDeptCode = SUNT_BUNT_DEPT_CODE
            ,@SuntBuntCode = SUNT_BUNT_CODE
            ,@SuntCode = SUNT_CODE
            ,@IscpIscaIscgCode = ISCP_ISCA_ISCG_CODE
            ,@IscpIscaCode = ISCP_ISCA_CODE
            ,@IscpCode = ISCP_CODE
            ,@CordX = ISNULL(@CordX, CORD_X)
            ,@CordY = ISNULL(@CordY, CORD_Y)
            ,@SexType = SEX_TYPE
            ,@MridType = MRID_TYPE
            ,@RlgnType = RLGN_TYPE
            ,@EthnCity = ETHN_CITY
            ,@CustType = CUST_TYPE            
            ,@JobTitl = JOB_TITL
            ,@Type = dbo.IsStringNullOrEmpty(@Type, P.TYPE)
            ,@FaceBookUrl = P.FACE_BOOK_URL
            ,@LinkInUrl = P.LINK_IN_URL
            ,@TwtrUrl = P.TWTR_URL
            ,@ServStagCode = S.SERV_STAG_CODE
            ,@ServNo = P.SERV_NO
        FROM dbo.Service S, dbo.Service_Public P
       WHERE S.FILE_NO = P.SERV_FILE_NO
         AND S.SRPB_RWNO_DNRM = P.RWNO
         AND P.RECT_CODE = '004'
         AND S.FILE_NO = @FileNo;      
      END      
      
      -- 1396/04/03 * نگهداری اطلاعات سرویس و تعرفه خریدار اگر مقدار خالی باشد
      IF @RqtpCode != '001' AND @Type IN ('002') AND @BtrfCode IS NULL AND @TrfdCode IS NULL
      BEGIN
         SELECT @BtrfCode = BTRF_CODE_DNRM
               ,@TrfdCode = TRFD_CODE_DNRM
           FROM dbo.Service
          WHERE FILE_NO = @FileNo;         
      END
      
      -- ثبت اطلاعات عمومی پرونده 
      IF NOT EXISTS(
         SELECT * 
         FROM dbo.Service_Public
         WHERE SERV_FILE_NO = @FileNo
           AND RQRO_RQST_RQID = @Rqid
           AND RQRO_RWNO = @RqroRwno
      )
      BEGIN
         EXEC INS_SRPB_P
            @Cnty_Code = @CntyCode
           ,@Prvn_Code = @PrvnCode
           ,@Regn_Code = @RegnCode
           ,@File_No   = @FileNo           
           ,@Btrf_Code = @BtrfCode
           ,@Trfd_Code = @TrfdCode
           ,@COMP_Code = @CompCode
           ,@Expn_Code = NULL
           ,@Rqro_Rqst_Rqid = @Rqid
           ,@Rqro_Rwno = @RqroRwno
           ,@Rect_Code = '001'
           ,@Frst_Name = @FrstName
           ,@Last_Name = @LastName
           ,@Fath_Name = @FathName
           ,@Natl_Code = @NatlCode
           ,@Brth_Date = @BrthDate
           ,@Cell_Phon = @CellPhon
           ,@Tell_Phon = @TellPhon
           ,@Idty_Code = @IdtyCode
           ,@Ownr_Type = NULL
           ,@User_Name = NULL
           ,@Pass_Word = NULL
           ,@Telg_Chat_Code = @TelgChatCode
           ,@Frst_Name_Ownr_Line = NULL
           ,@Last_Name_Ownr_Line = NULL
           ,@Natl_Code_Ownr_Line = NULL
           ,@Line_Numb_Serv = NULL
           ,@Post_Adrs = @PostAdrs
           ,@Emal_Adrs = @EmalAdrs
           ,@OnOf_Tag = @OnOfTag
           ,@Sunt_Bunt_Dept_Orgn_Code = @SuntBuntDeptOrgnCode
           ,@Sunt_Bunt_Dept_Code = @SuntBuntDeptCode
           ,@Sunt_Bunt_Code = @SuntBuntCode
           ,@Sunt_Code = @SuntCode
           ,@Iscp_Isca_Iscg_Code = @IscpIscaIscgCode
           ,@Iscp_Isca_Code = @IscpIscaCode
           ,@Iscp_Code = @IscpCode
           ,@Cord_X = @CordX
           ,@Cord_Y = @CordY           
           ,@Most_Debt_Clng = NULL
           ,@Sex_Type = @SexType
           ,@Mrid_Type = @MridType
           ,@Rlgn_Type = @RlgnType
           ,@Ethn_City = @EthnCity
           ,@Cust_Type = @CustType
           ,@Stif_Type = NULL
           ,@Job_Titl = @JobTitl
           ,@Type = @Type
           ,@Face_Book_Url = @FaceBookUrl
           ,@Link_In_Url = @LinkInUrl
           ,@Twtr_Url = @TwtrUrl
           ,@Serv_No = @ServNo;         
      END
      ELSE
      BEGIN
         EXEC [UPD_SRPB_P]
            @Cnty_Code = @CntyCode
           ,@Prvn_Code = @PrvnCode
           ,@Regn_Code = @RegnCode
           ,@File_No   = @FileNo           
           ,@Btrf_Code = @BtrfCode
           ,@Trfd_Code = @TrfdCode
           ,@COMP_Code = @CompCode           
           ,@Expn_Code = NULL
           ,@Rqro_Rqst_Rqid = @Rqid
           ,@Rqro_Rwno = @RqroRwno
           ,@Rect_Code = '001'
           ,@Frst_Name = @FrstName
           ,@Last_Name = @LastName
           ,@Fath_Name = @FathName
           ,@Natl_Code = @NatlCode
           ,@Brth_Date = @BrthDate
           ,@Cell_Phon = @CellPhon
           ,@Tell_Phon = @TellPhon
           ,@Idty_Code = @IdtyCode
           ,@Ownr_Type = NULL
           ,@User_Name = NULL
           ,@Pass_Word = NULL
           ,@Telg_Chat_Code = @TelgChatCode
           ,@Frst_Name_Ownr_Line = NULL
           ,@Last_Name_Ownr_Line = NULL
           ,@Natl_Code_Ownr_Line = NULL
           ,@Line_Numb_Serv = NULL
           ,@Post_Adrs = @PostAdrs
           ,@Emal_Adrs = @EmalAdrs
           ,@OnOf_Tag = @OnOfTag
           ,@Sunt_Bunt_Dept_Orgn_Code = @SuntBuntDeptOrgnCode
           ,@Sunt_Bunt_Dept_Code = @SuntBuntDeptCode
           ,@Sunt_Bunt_Code = @SuntBuntCode
           ,@Sunt_Code = @SuntCode
           ,@Iscp_Isca_Iscg_Code = @IscpIscaIscgCode
           ,@Iscp_Isca_Code = @IscpIscaCode
           ,@Iscp_Code = @IscpCode
           ,@Cord_X = @CordX
           ,@Cord_Y = @CordY
           ,@Most_Debt_Clng = NULL
           ,@Sex_Type = @SexType
           ,@Mrid_Type = @MridType
           ,@Rlgn_Type = @RlgnType
           ,@Ethn_City = @EthnCity
           ,@Cust_Type = @CustType
           ,@Stif_Type = NULL
           ,@Job_Titl = @JobTitl
           ,@Type = @Type
           ,@Face_Book_Url = @FaceBookUrl
           ,@Link_In_Url = @LinkInUrl
           ,@Twtr_Url = @TwtrUrl
           ,@Serv_No = @ServNo;
      END
      
      UPDATE dbo.Service
         SET SERV_STAG_CODE = COALESCE(@ServStagCode, '001')
       WHERE FILE_NO = @FileNo;
      
      COMMIT TRAN T1;
      RETURN 0;      
   END TRY
   BEGIN CATCH
      SET @ErrorMessage = ERROR_MESSAGE();
      RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN T1;
      RETURN -1;
   END CATCH;   
END
GO
