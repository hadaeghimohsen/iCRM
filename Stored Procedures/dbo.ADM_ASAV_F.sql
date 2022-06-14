SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ADM_ASAV_F]
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
	           @FileNo   BIGINT,
	           @RqroRwno SMALLINT;
   	
	   SELECT @Rqid     = @X.query('//Request').value('(Request/@rqid)[1]'    , 'BIGINT')
	         ,@RqroRwno = @X.query('//Request_Row').value('(Request_Row/@rwno)[1]', 'SMALLINT')
	         ,@FileNo   = @X.query('//Request_Row').value('(Request_Row/@servfileno)[1]', 'BIGINT');      
      
      DECLARE
        @CntyCode VARCHAR(3)
       ,@PrvnCode VARCHAR(3)
       ,@RegnCode VARCHAR(3)
       ,@CompCode BIGINT
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
             
      SELECT @CntyCode = REGN_PRVN_CNTY_CODE
            ,@PrvnCode = REGN_PRVN_CODE
            ,@RegnCode = REGN_CODE
            ,@FileNo   = SERV_FILE_NO
            ,@BtrfCode = BTRF_CODE
            ,@TrfdCode = TRFD_CODE
            ,@CompCode = COMP_CODE
            ,@FrstName = FRST_NAME
            ,@LastName = LAST_NAME
            ,@FathName = FATH_NAME
            ,@NatlCode = NATL_CODE
            ,@BrthDate = BRTH_DATE
            ,@CellPhon = CELL_PHON
            ,@TellPhon = TELL_PHON
            ,@IdtyCode = IDTY_CODE
            ,@TelgChatCode = TELG_CHAT_CODE
            ,@PostAdrs = POST_ADRS
            ,@EmalAdrs = EMAL_ADRS
            ,@OnOfTag = ONOF_TAG
            ,@SuntBuntDeptOrgnCode = SUNT_BUNT_DEPT_ORGN_CODE
            ,@SuntBuntDeptCode = SUNT_BUNT_DEPT_CODE
            ,@SuntBuntCode = SUNT_BUNT_CODE
            ,@SuntCode = SUNT_CODE
            ,@IscpIscaIscgCode = ISCP_ISCA_ISCG_CODE
            ,@IscpIscaCode = ISCP_ISCA_CODE
            ,@IscpCode = ISCP_CODE
            ,@CordX = CORD_X
            ,@CordY = CORD_Y
            ,@SexType = SEX_TYPE
            ,@MridType = MRID_TYPE
            ,@RlgnType = RLGN_TYPE
            ,@EthnCity = ETHN_CITY
            ,@CustType = CUST_TYPE            
            ,@JobTitl = JOB_TITL
            ,@Type = TYPE
            ,@FaceBookUrl = FACE_BOOK_URL
            ,@LinkInUrl = LINK_IN_URL
            ,@TwtrUrl = TWTR_URL
            ,@ServNo = SERV_NO
        FROM dbo.Service_Public
       WHERE RQRO_RQST_RQID = @Rqid
         AND SERV_FILE_NO = @FileNo
         AND RECT_CODE = '001';
      
      -- ثبت اطلاعات عمومی پرونده 
      IF NOT EXISTS(
         SELECT * 
         FROM dbo.Service_Public
         WHERE SERV_FILE_NO = @FileNo
           AND RQRO_RQST_RQID = @Rqid
           AND RQRO_RWNO = @RqroRwno
           AND RECT_CODE = '004'
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
           ,@Rect_Code = '004'
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
         SET CONF_STAT = '002'
       WHERE FILE_NO = @FileNo;
      
      -- 1397/08/25 * ثبت شماره کد شرکت در اطلاعات ردیف ثبت مشتری
      UPDATE dbo.Request_Row
        SET COMP_CODE = @CompCode
       WHERE RQST_RQID = @Rqid;
      
      UPDATE Request
         SET RQST_STAT = '002'
       WHERE RQID = @Rqid;
      
      -- 1396/07/21 * اضافه شدن گزینه آیتم مربوط به جدول مشتریان که مشخص کننده ماهیت آنها می باشد 
      MERGE dbo.Service_Join_Service_Type T
      USING (SELECT @FileNo AS File_No) S
      ON (T.SERV_FILE_NO = S.File_No AND
          t.SRTP_CODE = @Type)
      WHEN NOT MATCHED THEN
         INSERT (SERV_FILE_NO, SRTP_CODE, SJID)
         VALUES(s.File_No, @Type, 0);
      
      -- 1396/09/24 * اضافه کردن گزینه ثبت پروژه برای مشترکین که هیچ پروژه ای ندارند
      IF NOT EXISTS(
         SELECT * 
         FROM dbo.Request_Row
        WHERE RQTP_CODE = '013'
          AND SERV_FILE_NO = @FileNo
      )
      BEGIN
         SELECT @X = (
            SELECT 0 AS '@rqstrqid'
                  ,@FileNo AS '@servfileno'
                  ,0 AS '@rqrorqstrqid'
                  ,0 AS '@rqrorwno'
                  ,N'پروژه آغازین' AS '@rqstdesc'
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
         EXEC dbo.OPR_PSAV_P @X = @X -- xml
         
         -- بدست آوردن شماره درخواست پروژه پیش فرض
         DECLARE @ProjRqstRqid BIGINT;
         SELECT @ProjRqstRqid = RQST_RQID
           FROM dbo.Request_Row 
          WHERE SERV_FILE_NO = @FileNo
            AND RQTP_CODE = '013';
         
         -- ثبت درخواست های ثبت شده بودن پروژه در پروژه پیش فرض
         UPDATE r
            SET r.PROJ_RQST_RQID = @ProjRqstRqid
           FROM Request r, Request_Row rr
          WHERE r.RQID = rr.RQST_RQID
            AND rr.SERV_FILE_NO = @FileNo
            AND r.PROJ_RQST_RQID IS NULL
            AND r.RQTP_CODE != '013';
      END
      
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
