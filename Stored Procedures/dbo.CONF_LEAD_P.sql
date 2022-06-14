SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CONF_LEAD_P]
	-- Add the parameters for the stored procedure here
    @X XML
AS
    BEGIN
        BEGIN TRY
            BEGIN TRAN T_CONF_LEAD_P;
	   
            DECLARE @Rqid BIGINT ,
                @Colr VARCHAR(30) ,
                @FileNo BIGINT ,
                @ConfType VARCHAR(3),
                @EmstRevnAmnt BIGINT,
                @EmstClosDate DATE,
                @Cmnt NVARCHAR(4000),
                @Ldid BIGINT;
            SELECT  @Rqid = @X.query('Lead').value('(Lead/@rqid)[1]', 'BIGINT') ,
                    @Ldid = @X.query('Lead').value('(Lead/@ldid)[1]', 'BIGINT') ,
                    @Colr = @X.query('Lead').value('(Lead/@colr)[1]', 'VARCHAR(30)') ,
                    @ConfType = @X.query('Lead').value('(Lead/@conftype)[1]', 'VARCHAR(3)'),
                    @EmstRevnAmnt = @X.query('Lead').value('(Lead/@emstrevnamnt)[1]', 'BIGINT'),
                    @EmstClosDate = @X.query('Lead').value('(Lead/@emstclosdate)[1]', 'DATE'),
                    @Cmnt = @X.query('Lead').value('(Lead/@cmnt)[1]', 'NVARCHAR(4000)');
	   
            SELECT  @FileNo = SERV_FILE_NO
            FROM    dbo.Request_Row
            WHERE   RQST_RQID = @Rqid;
      
            IF @ConfType = '001'
                BEGIN
         -- Disapprove * عدم تایید صلاحیت
                    UPDATE  dbo.Request
                    SET     SSTT_CODE = 4 ,
                            COLR = @Colr
                    WHERE   RQID = @Rqid;
                END;
            ELSE
                IF @ConfType = '002'
                    BEGIN
         -- Approve * تایید صلاحیت
                        UPDATE  dbo.Request
                        SET     SSTT_CODE = 3 ,
                                COLR = @Colr
                        WHERE   RQID = @Rqid;
                    END;      
                ELSE
                    IF @ConfType IN ( '003', '004' )
                        BEGIN
                            UPDATE dbo.Request
                               SET COLR = @Colr
                                  ,RQST_STAT = '002'
                             WHERE RQID = @Rqid;
                             
                            UPDATE  dbo.Service
                            SET     CONF_STAT = '002'
                            WHERE   FILE_NO = @FileNo
                                    AND CONF_STAT = '001';
                            
                            UPDATE dbo.Lead
                               SET STAT = CASE @ConfType WHEN '003' THEN '009' WHEN '004' THEN '010' END 
                                  ,CMNT = @Cmnt
                                  ,EMST_CLOS_DATE = @EmstClosDate
                                  ,EMST_REVN_AMNT = @EmstRevnAmnt
                             WHERE LDID = @Ldid;
                              
                            DECLARE @Cnty_Code VARCHAR(3) ,
                                @Prvn_Code VARCHAR(3) ,
                                @Regn_Code VARCHAR(3) ,
                                @Rqro_Rwno SMALLINT ,
                                @SrpbRectCode VARCHAR(3) ,
                                @SrpbRwno INT ,
                                @Btrf_Code BIGINT ,
                                @Trfd_Code BIGINT ,
                                @COMP_Code BIGINT ,
                                @Expn_Code BIGINT ,
                                @Rect_Code VARCHAR(3) ,
                                @Frst_Name NVARCHAR(250) ,
                                @Last_Name NVARCHAR(250) ,
                                @Fath_Name NVARCHAR(250) ,
                                @Natl_Code VARCHAR(10) ,
                                @Brth_Date DATE ,
                                @Cell_Phon VARCHAR(11) ,
                                @Tell_Phon VARCHAR(11) ,
                                @Educ_Deg VARCHAR(3) ,
                                @Idty_Code VARCHAR(10) ,
                                @Ownr_Type VARCHAR(3) ,
                                @User_Name VARCHAR(250) ,
                                @Pass_Word VARCHAR(250) ,
                                @Telg_Chat_Code BIGINT ,
                                @Frst_Name_Ownr_Line NVARCHAR(250) ,
                                @Last_Name_Ownr_Line NVARCHAR(250) ,
                                @Natl_Code_Ownr_Line VARCHAR(10) ,
                                @Line_Numb_Serv VARCHAR(10) ,
                                @Post_Adrs NVARCHAR(1000) ,
                                @Emal_Adrs NVARCHAR(250) ,
                                @OnOf_Tag VARCHAR(3) = '101' ,
                                @Sunt_Bunt_Dept_Orgn_Code VARCHAR(2) ,
                                @Sunt_Bunt_Dept_Code VARCHAR(2) ,
                                @Sunt_Bunt_Code VARCHAR(2) ,
                                @Sunt_Code VARCHAR(4) ,
                                @Iscp_Isca_Iscg_Code VARCHAR(2) ,
                                @Iscp_Isca_Code VARCHAR(2) ,
                                @Iscp_Code VARCHAR(6) ,
                                @Cord_X REAL ,
                                @Cord_Y REAL ,
                                @Most_Debt_Clng BIGINT ,
                                @Sex_Type VARCHAR(3) ,
                                @Mrid_Type VARCHAR(3) ,
                                @Rlgn_Type VARCHAR(3) ,
                                @Ethn_City VARCHAR(3) ,
                                @Cust_Type VARCHAR(3) ,
                                @Stif_Type VARCHAR(3) ,
                                @Job_Titl VARCHAR(3) ,
                                @Type VARCHAR(3) ,
                                @Face_Book_Url NVARCHAR(1000) ,
                                @Link_In_Url NVARCHAR(1000) ,
                                @Twtr_Url NVARCHAR(1000) ,
                                @Serv_No VARCHAR(10);
            
                            SELECT  @Cnty_Code = sp.REGN_PRVN_CNTY_CODE ,
                                    @Prvn_Code = sp.REGN_PRVN_CODE ,
                                    @Regn_Code = sp.REGN_CODE ,
                                    @COMP_Code = sp.COMP_CODE ,
                                    @Rqro_Rwno = sp.RQRO_RWNO ,
                                    @Btrf_Code = sp.BTRF_CODE ,
                                    @Trfd_Code = sp.TRFD_CODE ,
                                    @Expn_Code = sp.EXPN_CODE ,
                                    @Frst_Name = sp.FRST_NAME ,
                                    @Last_Name = sp.LAST_NAME ,
                                    @Fath_Name = sp.FATH_NAME ,
                                    @Sex_Type = sp.SEX_TYPE ,
                                    @Natl_Code = sp.NATL_CODE ,
                                    @Brth_Date = sp.BRTH_DATE ,
                                    @Cell_Phon = sp.CELL_PHON ,
                                    @Tell_Phon = sp.TELL_PHON ,
                                    @Educ_Deg = sp.EDUC_DEG ,
                                    @Type = sp.TYPE ,
                                    @Idty_Code = sp.IDTY_CODE ,
                                    @Ownr_Type = sp.OWNR_TYPE ,
                                    @User_Name = sp.USER_NAME ,
                                    @Pass_Word = sp.PASS_WORD ,
                                    @Telg_Chat_Code = sp.TELG_CHAT_CODE ,
                                    @Frst_Name_Ownr_Line = sp.FRST_NAME_OWNR_LINE ,
                                    @Last_Name_Ownr_Line = sp.LAST_NAME_OWNR_LINE ,
                                    @Natl_Code_Ownr_Line = sp.NATL_CODE_OWNR_LINE ,
                                    @Line_Numb_Serv = sp.LINE_NUMB_SERV ,
                                    @Post_Adrs = sp.POST_ADRS ,
                                    @Emal_Adrs = sp.EMAL_ADRS ,
                                    @OnOf_Tag = sp.ONOF_TAG ,
                                    @Sunt_Bunt_Dept_Orgn_Code = sp.SUNT_BUNT_DEPT_ORGN_CODE ,
                                    @Sunt_Bunt_Dept_Code = sp.SUNT_BUNT_DEPT_CODE ,
                                    @Sunt_Bunt_Code = sp.SUNT_BUNT_CODE ,
                                    @Sunt_Code = sp.SUNT_CODE ,
                                    @Iscp_Isca_Iscg_Code = sp.ISCP_ISCA_ISCG_CODE ,
                                    @Iscp_Isca_Code = sp.ISCP_ISCA_CODE ,
                                    @Iscp_Code = sp.ISCP_CODE ,
                                    @Cord_X = sp.CORD_X ,
                                    @Cord_Y = sp.CORD_Y ,
                                    @Most_Debt_Clng = sp.MOST_DEBT_CLNG ,
                                    @Mrid_Type = sp.MRID_TYPE ,
                                    @Rlgn_Type = sp.RLGN_TYPE ,
                                    @Ethn_City = sp.ETHN_CITY ,
                                    @Cust_Type = sp.CUST_TYPE ,
                                    @Stif_Type = sp.STIF_TYPE ,
                                    @Job_Titl = sp.JOB_TITL ,
                                    @Face_Book_Url = sp.FACE_BOOK_URL ,
                                    @Link_In_Url = sp.LINK_IN_URL ,
                                    @Twtr_Url = sp.TWTR_URL ,
                                    @Serv_No = sp.SERV_NO
                            FROM    dbo.Service_Public sp
                            WHERE   sp.SERV_FILE_NO = @FileNo
                                    AND sp.RECT_CODE = '001'
                                    AND sp.RQRO_RQST_RQID = @Rqid;
                            
                            -- 1397/08/26 * بررسی اینکه آیا اطلاعات مشتری تغییر داشته است
                            IF EXISTS (
                               SELECT *
                                 FROM dbo.Service
                                WHERE FILE_NO = @FileNo
                                  AND CONF_STAT = '002'
                                  AND SRPB_RWNO_DNRM >= 1
                                  AND (
                                      FRST_NAME_DNRM = @Frst_Name AND 
                                      LAST_NAME_DNRM = @Last_Name AND 
                                      CELL_PHON_DNRM = @Cell_Phon AND
                                      TELL_PHON_DNRM = @Tell_Phon AND 
                                      EMAL_ADRS_DNRM = @Emal_Adrs                                      
                                  )
                            )
                            BEGIN
                              GOTO L$Finalization;
                            END
   	   
                            IF NOT EXISTS ( SELECT  *
                                            FROM    dbo.Service_Public
                                            WHERE   RQRO_RQST_RQID = @Rqid
                                                    AND SERV_FILE_NO = @FileNo
                                                    AND RECT_CODE = '004' )
                                BEGIN
                                    EXEC dbo.INS_SRPB_P @Cnty_Code = @Cnty_Code, -- varchar(3)
                                        @Prvn_Code = @Prvn_Code, -- varchar(3)
                                        @Regn_Code = @Regn_Code, -- varchar(3)
                                        @File_No = @FileNo, -- bigint
                                        @Btrf_Code = @Btrf_Code, -- bigint
                                        @Trfd_Code = @Trfd_Code, -- bigint
                                        @COMP_Code = @COMP_Code, -- bigint
                                        @Expn_Code = @Expn_Code, -- bigint
                                        @Rqro_Rqst_Rqid = @Rqid, -- bigint
                                        @Rqro_Rwno = @Rqro_Rwno, -- smallint
                                        @Rect_Code = '004', -- varchar(3)
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
                                END;                             
                           
                           L$Finalization:
                           --IF NOT EXISTS(SELECT * FROM dbo.Request WHERE RQID = @Rqid AND PROJ_RQST_RQID IS NULL)     
                           BEGIN                           
                              -- 1396/07/21 * اضافه شدن گزینه آیتم مربوط به جدول مشتریان که مشخص کننده ماهیت آنها می باشد 
                              MERGE dbo.Service_Join_Service_Type T
                              USING (SELECT @FileNo AS File_No) S
                              ON (T.SERV_FILE_NO = S.File_No AND
                                  t.SRTP_CODE = @Type)
                              WHEN NOT MATCHED THEN
                                 INSERT (SERV_FILE_NO, SRTP_CODE, SJID)
                                 VALUES(s.File_No, @Type, 0);
                              
                              UPDATE dbo.Request_Row
                                 SET COMP_CODE = @COMP_Code
                               WHERE RQST_RQID = @Rqid;
                              
                              -- 1396/09/24 * اضافه کردن گزینه ثبت پروژه برای مشترکین که هیچ پروژه ای ندارند
                              /*BEGIN
                                 SELECT @X = (
                                    SELECT 0 AS '@rqstrqid'
                                          ,@FileNo AS '@servfileno'
                                          ,0 AS '@rqrorqstrqid'
                                          ,0 AS '@rqrorwno'
                                          ,(SELECT TOPC FROM dbo.Lead WHERE LDID = @Ldid) AS '@rqstdesc'
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
                                 SELECT TOP 1 @ProjRqstRqid = RQST_RQID
                                   FROM dbo.Request_Row 
                                  WHERE SERV_FILE_NO = @FileNo
                                    AND RQTP_CODE = '013'
                                    AND CRET_BY = UPPER(SUSER_NAME())
                                    AND CAST(CRET_DATE AS DATE) = CAST(GETDATE() AS DATE)
                               ORDER BY CRET_DATE DESC;
                                 
                                 -- ثبت درخواست های ثبت شده بودن پروژه در پروژه پیش فرض
                                 UPDATE r
                                    SET r.PROJ_RQST_RQID = @ProjRqstRqid
                                   FROM Request r, Request_Row rr
                                  WHERE r.RQID = rr.RQST_RQID
                                    AND rr.SERV_FILE_NO = @FileNo
                                    AND r.PROJ_RQST_RQID IS NULL
                                    AND r.RQID = @Rqid
                                    AND r.RQTP_CODE != '013';
                              END;*/
                           END;        
                     END;
            COMMIT TRAN T_CONF_LEAD_P;
            RETURN 0;
        END TRY
        BEGIN CATCH
            DECLARE @ErrorMessage NVARCHAR(MAX);
            SET @ErrorMessage = ERROR_MESSAGE();
            RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
            ROLLBACK TRAN T_CONF_LEAD_P;
            RETURN -1;
        END CATCH;
    END;
GO
