CREATE TABLE [dbo].[Service_Public]
(
[REGN_PRVN_CNTY_CODE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SRPB_REGN_PRVN_CNTY_CODE] DEFAULT ('001'),
[REGN_PRVN_CODE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SRPB_REGN_PRVN_CODE] DEFAULT ('001'),
[REGN_CODE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SRPB_REGN_CODE] DEFAULT ('999'),
[BTRF_CODE] [bigint] NULL,
[TRFD_CODE] [bigint] NULL,
[EXPN_CODE] [bigint] NULL,
[COMP_CODE] [bigint] NULL,
[OWNR_CODE] [bigint] NULL,
[RQRO_RQST_RQID] [bigint] NULL,
[RQRO_RWNO] [smallint] NULL,
[SERV_FILE_NO] [bigint] NOT NULL,
[RWNO] [int] NOT NULL CONSTRAINT [DF_SRPB_RWNO] DEFAULT ((0)),
[RECT_CODE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FRST_NAME] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SRPB_FRST_NAME] DEFAULT ('FRST_NAME'),
[LAST_NAME] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SRPB_LAST_NAME] DEFAULT ('LAST_NAME'),
[FATH_NAME] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SRPB_FATH_NAME] DEFAULT ('FATH_NAME'),
[SEX_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SRPB_SEX_TYPE] DEFAULT ('001'),
[NATL_CODE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BRTH_DATE] [datetime] NULL,
[CELL_PHON] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TELL_PHON] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EDUC_DEG] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SRPB_TYPE] DEFAULT ('001'),
[IDTY_CODE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OWNR_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[USER_NAME] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PASS_WORD] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TELG_CHAT_CODE] [bigint] NULL,
[FRST_NAME_OWNR_LINE] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LAST_NAME_OWNR_LINE] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NATL_CODE_OWNR_LINE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LINE_NUMB_SERV] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POST_ADRS] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMAL_ADRS] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ONOF_TAG] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Service_Public_ACTV_TAG] DEFAULT ('101'),
[SUNT_BUNT_DEPT_ORGN_CODE] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUNT_BUNT_DEPT_CODE] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUNT_BUNT_CODE] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUNT_CODE] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ISCP_ISCA_ISCG_CODE] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ISCP_ISCA_CODE] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ISCP_CODE] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CORD_X] [float] NULL,
[CORD_Y] [float] NULL,
[MOST_DEBT_CLNG] [bigint] NULL,
[MRID_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RLGN_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETHN_CITY] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CUST_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STIF_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JOB_TITL] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FACE_BOOK_URL] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LINK_IN_URL] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TWTR_URL] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SERV_NO] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CONT_MTOD] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ALOW_EMAL] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ALOW_BULK_EMAL] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ALOW_PHON] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ALOW_FAX] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ALOW_LETT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHIP_MTOD] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHIP_CHRG] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRCB_TCID] [bigint] NULL,
[CRDT_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRDT_AMNT] [bigint] NULL,
[PYMT_TERM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRET_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRET_DATE] [datetime] NULL,
[MDFY_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MDFY_DATE] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[CG$ADEL_SRPB]
   ON  [dbo].[Service_Public]
   AFTER DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   
   -- Insert statements for trigger here
   
   DECLARE C$SRPB CURSOR FOR
      SELECT RQRO_RQST_RQID, RQRO_RWNO, SERV_FILE_NO FROM DELETED D 
       WHERE D.Rect_Code = '004';

   DECLARE @RqroRqstRqid      BIGINT
          ,@RqroRwno          SMALLINT            
          ,@SERVFileNo        BIGINT;
   
   OPEN C$SRPB;
   NextFromSRPB:
   FETCH NEXT FROM C$SRPB INTO @RqroRqstRqid, @RqroRwno, @SERVFileNo;
   
   -- UPDATE Service TABLE
   MERGE dbo.Service T
   USING (SELECT * FROM Service_Public I 
           WHERE I.SERV_FILE_NO = @SERVFileNo
             AND I.RWNO = (SELECT MAX(RWNO) FROM Service_PUBLIC M 
                            WHERE M.SERV_FILE_NO = I.SERV_FILE_NO AND 
                                  M.RECT_CODE    = '004')) S
   ON (T.FILE_NO   = S.SERV_FILE_NO AND
       S.RECT_CODE = '004')
   WHEN MATCHED THEN
      UPDATE 
         SET SRPB_RWNO_DNRM = S.RWNO
            ,REGN_PRVN_CNTY_CODE = S.REGN_PRVN_CNTY_CODE
            ,REGN_PRVN_CODE = S.REGN_PRVN_CODE
            ,REGN_CODE = S.REGN_CODE
            ,FRST_NAME_DNRM = S.FRST_NAME
            ,LAST_NAME_DNRM = S.LAST_NAME
            ,NAME_DNRM      = S.FRST_NAME + ', ' + S.LAST_NAME
            ,FATH_NAME_DNRM = S.FATH_NAME
            ,POST_ADRS_DNRM = S.POST_ADRS
            ,SEX_TYPE_DNRM  = S.SEX_TYPE
            ,BRTH_DATE_DNRM = S.BRTH_DATE
            ,CELL_PHON_DNRM = S.CELL_PHON
            ,TELL_PHON_DNRM = S.TELL_PHON
            ,SRPB_TYPE_DNRM = S.[TYPE]
            ,TRFD_CODE_DNRM = S.TRFD_CODE
            ,BTRF_CODE_DNRM = S.BTRF_CODE
            ,COMP_CODE_DNRM = S.COMP_CODE
            ,ONOF_TAG_DNRM  = S.ONOF_TAG
            ,SUNT_BUNT_DEPT_ORGN_CODE_DNRM = S.SUNT_BUNT_DEPT_ORGN_CODE
            ,SUNT_BUNT_DEPT_CODE_DNRM = S.SUNT_BUNT_DEPT_CODE
            ,SUNT_BUNT_CODE_DNRM = S.SUNT_BUNT_CODE
            ,SUNT_CODE_DNRM = S.SUNT_CODE
            ,ISCP_ISCA_ISCG_CODE_DNRM = S.ISCP_ISCA_ISCG_CODE
            ,ISCP_ISCA_CODE_DNRM = S.ISCP_ISCA_CODE
            ,ISCP_CODE_DNRM = S.ISCP_CODE
            ,CORD_X_DNRM = S.CORD_X
            ,CORD_Y_DNRM = S.CORD_Y
            ,MOST_DEBT_CLNG_DNRM = S.MOST_DEBT_CLNG
            ,MRID_TYPE_DNRM = S.MRID_TYPE
            ,RLGN_TYPE_DNRM = S.RLGN_TYPE
            ,ETHN_CITY_DNRM = S.ETHN_CITY
            ,CUST_TYPE_DNRM = S.CUST_TYPE
            ,STIF_TYPE_DNRM = S.STIF_TYPE
            ,JOB_TITL_DNRM  = S.JOB_TITL
            ,FACE_BOOK_URL_DNRM = s.FACE_BOOK_URL
            ,LINK_IN_URL_DNRM = s.LINK_IN_URL
            ,TWTR_URL_DNRM = s.TWTR_URL
            ,NATL_CODE_DNRM = s.NATL_CODE
            ,SERV_NO_DNRM = s.SERV_NO;
   
   IF NOT EXISTS(SELECT * FROM Service_Public
                  WHERE SERV_FILE_NO = @SERVFileNo
                    AND RECT_CODE = '004'
                )
      UPDATE Service
         SET SRPB_RWNO_DNRM = NULL
            ,REGN_PRVN_CNTY_CODE = NULL
            ,REGN_PRVN_CODE = NULL
            ,REGN_CODE = NULL
            ,FRST_NAME_DNRM = NULL 
            ,LAST_NAME_DNRM = NULL 
            ,NAME_DNRM      = NULL
            ,FATH_NAME_DNRM = NULL
            ,POST_ADRS_DNRM = NULL
            ,SEX_TYPE_DNRM  = NULL
            ,BRTH_DATE_DNRM = NULL
            ,CELL_PHON_DNRM = NULL
            ,TELL_PHON_DNRM = NULL
            ,SRPB_TYPE_DNRM = NULL
            ,TRFD_CODE_DNRM = NULL
            ,BTRF_CODE_DNRM = NULL
            ,COMP_CODE_DNRM = NULL
            ,ONOF_TAG_DNRM  = NULL
            ,SUNT_BUNT_DEPT_ORGN_CODE_DNRM = NULL
            ,SUNT_BUNT_DEPT_CODE_DNRM = NULL
            ,SUNT_BUNT_CODE_DNRM = NULL
            ,SUNT_CODE_DNRM = NULL
            ,ISCP_ISCA_ISCG_CODE_DNRM = NULL
            ,ISCP_ISCA_CODE_DNRM = NULL
      ,ISCP_CODE_DNRM = NULL
            ,CORD_X_DNRM = NULL
            ,CORD_Y_DNRM = NULL
            ,MOST_DEBT_CLNG_DNRM = NULL
            ,MRID_TYPE_DNRM = NULL
            ,RLGN_TYPE_DNRM = NULL
            ,ETHN_CITY_DNRM = NULL
            ,CUST_TYPE_DNRM = NULL
            ,STIF_TYPE_DNRM = NULL
            ,JOB_TITL_DNRM = NULL
            ,FACE_BOOK_URL_DNRM = null
            ,LINK_IN_URL_DNRM = null
            ,TWTR_URL_DNRM = null
            ,NATL_CODE_DNRM = NULL
            ,SERV_NO_DNRM = NULL
      WHERE FILE_NO = @ServFileNo;

   CLOSE C$SRPB;
   DEALLOCATE C$SRPB;         
END
;
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[CG$AINS_SRPB]
   ON  [dbo].[Service_Public]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   
   -- Insert statements for trigger here
   MERGE dbo.Service_Public T
   USING (SELECT * FROM INSERTED) S
   ON (T.RQRO_RQST_RQID = S.RQRO_RQST_RQID AND
       T.SERV_FILE_NO   = S.SERV_FILE_NO   AND
       T.RECT_CODE      = S.RECT_CODE)
   WHEN MATCHED THEN
      UPDATE
         SET CRET_BY             = UPPER(SUSER_NAME())
            ,CRET_DATE           = GETDATE()
            ,RWNO                = (SELECT ISNULL(MAX(RWNO), 0) + 1 FROM dbo.Service_Public WHERE SERV_FILE_NO = S.SERV_FILE_NO AND RECT_CODE = S.RECT_CODE /*RQRO_RQST_RQID < S.RQRO_RQST_RQID*/);
END
;
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[CG$AUPD_SRPB]
   ON  [dbo].[Service_Public]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   --BEGIN TRAN TCG$AUPD_SRPB;
   -- Insert statements for trigger here
   
   DECLARE @REGN_PRVN_CNTY_CODE VARCHAR(3)          ,@REGN_PRVN_CODE      VARCHAR(3)
          ,@REGN_CODE           VARCHAR(3)          
          ,@TRFD_CODE           BIGINT              ,@COMP_CODE           BIGINT
          ,@BTRF_CODE           BIGINT              ,@RQRO_RQST_RQID      BIGINT
          ,@RQRO_RWNO           SMALLINT            ,@SERV_FILE_NO        BIGINT
          ,@RWNO                INT                 ,@RECT_CODE           VARCHAR(3)
          ,@FRST_NAME           NVARCHAR(250)       ,@LAST_NAME           NVARCHAR(250)
          ,@FATH_NAME           NVARCHAR(250)       ,@SEX_TYPE            VARCHAR(3)
          ,@NATL_CODE           VARCHAR(10)         ,@BRTH_DATE           DATETIME
          ,@CELL_PHON           VARCHAR(11)         ,@TELL_PHON           VARCHAR(11)
          ,@TYPE                VARCHAR(3)
          ,@POST_ADRS           NVARCHAR(1000)      ,@EMAL_ADRS           VARCHAR(250)
          ,@ONOF_TAG            VARCHAR(3)          
          ,@SUNT_BUNT_DEPT_ORGN_CODE VARCHAR(2)     ,@SUNT_BUNT_DEPT_CODE VARCHAR(2)
          ,@SUNT_BUNT_CODE      VARCHAR(2)          ,@SUNT_CODE           VARCHAR(4)
          ,@ISCP_ISCA_ISCG_CODE VARCHAR(2)          ,@ISCP_ISCA_CODE      VARCHAR(2)
          ,@ISCP_CODE           VARCHAR(6)          
          ,@CORD_X              REAL                ,@CORD_Y              REAL
          ,@MOST_DEBT_CLNG      BIGINT
          ,@MRID_TYPE           VARCHAR(3)          ,@RLGN_TYPE           VARCHAR(3)
          ,@ETHN_CITY           VARCHAR(3)          ,@CUST_TYPE           VARCHAR(3)
          ,@STIF_TYPE           VARCHAR(3)          ,@JOB_TITL            VARCHAR(3)
          ,@FACE_BOOK_URL       NVARCHAR(1000)      ,@LINK_IN_URL         NVARCHAR(1000)
          ,@TWTR_URL            NVARCHAR(1000)      ,@SERV_NO             VARCHAR(10);
   -- FETCH LAST INFORMATION;
   SELECT TOP 1
          @REGN_PRVN_CNTY_CODE = T.[REGN_PRVN_CNTY_CODE]          , @REGN_PRVN_CODE = T.[REGN_PRVN_CODE]
         ,@REGN_CODE           = T.[REGN_CODE]                    
         ,@TRFD_CODE           = T.[TRFD_CODE]                    , @COMP_CODE      = T.[COMP_CODE]
         ,@BTRF_CODE           = T.[BTRF_CODE]                    , @RQRO_RQST_RQID = T.[RQRO_RQST_RQID]
         ,@RQRO_RWNO           = T.[RQRO_RWNO]                    , @SERV_FILE_NO   = T.[SERV_FILE_NO]
         ,@RWNO                = T.[RWNO]                         , @RECT_CODE      = T.[RECT_CODE]
         ,@FRST_NAME           = T.[FRST_NAME]                    , @LAST_NAME      = T.[LAST_NAME]
         ,@FATH_NAME           = T.[FATH_NAME]                    , @SEX_TYPE       = T.[SEX_TYPE]
         ,@NATL_CODE           = T.[NATL_CODE]                    , @BRTH_DATE      = T.[BRTH_DATE]
         ,@CELL_PHON           = T.[CELL_PHON]                    , @TELL_PHON      = T.[TELL_PHON]
         ,@TYPE                = T.[TYPE]
         ,@POST_ADRS           = T.[POST_ADRS]                    , @EMAL_ADRS      = T.[EMAL_ADRS]
         ,@ONOF_TAG            = T.[ONOF_TAG]          
         ,@SUNT_BUNT_DEPT_ORGN_CODE = T.SUNT_BUNT_DEPT_ORGN_CODE  
         ,@SUNT_BUNT_DEPT_CODE = T.SUNT_BUNT_DEPT_CODE
         ,@SUNT_BUNT_CODE      = T.SUNT_BUNT_CODE                 , @SUNT_CODE      = T.SUNT_CODE
         ,@ISCP_ISCA_ISCG_CODE = T.ISCP_ISCA_ISCG_CODE            , @ISCP_ISCA_CODE = T.ISCP_ISCA_CODE
         ,@ISCP_CODE           = T.ISCP_CODE
         ,@CORD_X              = T.CORD_X                         , @CORD_Y         = T.CORD_Y
         ,@MOST_DEBT_CLNG      = T.MOST_DEBT_CLNG                 , @MRID_TYPE      = T.MRID_TYPE
         ,@RLGN_TYPE     = T.RLGN_TYPE , @ETHN_CITY      = T.ETHN_CITY
         ,@CUST_TYPE           = T.CUST_TYPE                      , @STIF_TYPE      = T.STIF_TYPE
         ,@JOB_TITL            = T.JOB_TITL                       , @FACE_BOOK_URL  = T.FACE_BOOK_URL
         ,@LINK_IN_URL         = T.LINK_IN_URL                    , @TWTR_URL       = T.TWTR_URL
         ,@SERV_NO             = T.SERV_NO
     FROM [dbo].[Service_Public] T , INSERTED S
     WHERE T.SERV_FILE_NO   = S.SERV_FILE_NO
     ORDER BY T.RQRO_RQST_RQID DESC, T.CRET_DATE DESC;
   
   -- ثبت میزان سقف بدهی در تاریخ 1395/05/15
   IF @Rwno = 1 AND @Rect_Code = '001' AND @Most_Debt_Clng = 0
   BEGIN            
      SET @Most_Debt_Clng = ISNULL(@Most_Debt_Clng, 0);
   END
   
   MERGE dbo.Service_Public T
   USING (SELECT * FROM INSERTED) S
   ON (T.RQRO_RQST_RQID = S.RQRO_RQST_RQID AND
       T.SERV_FILE_NO   = S.SERV_FILE_NO   AND
       T.RECT_CODE      = S.RECT_CODE)
   WHEN MATCHED THEN
      UPDATE
         SET MDFY_BY             = UPPER(SUSER_NAME())
            ,MDFY_DATE           = GETDATE()
            ,REGN_PRVN_CNTY_CODE = CASE S.REGN_PRVN_CNTY_CODE WHEN NULL THEN @REGN_PRVN_CNTY_CODE ELSE S.REGN_PRVN_CNTY_CODE END
            ,REGN_PRVN_CODE      = CASE S.REGN_PRVN_CODE      WHEN NULL THEN @REGN_PRVN_CODE      ELSE S.REGN_PRVN_CODE      END
            ,REGN_CODE           = CASE S.REGN_CODE           WHEN NULL THEN @REGN_CODE           ELSE S.REGN_CODE           END
            ,TRFD_CODE           = CASE S.TRFD_CODE           WHEN NULL THEN @TRFD_CODE           ELSE S.TRFD_CODE           END
            ,COMP_CODE           = CASE S.COMP_CODE           WHEN NULL THEN @COMP_CODE           ELSE S.COMP_CODE           END
            ,BTRF_CODE           = CASE S.BTRF_CODE           WHEN NULL THEN @BTRF_CODE           ELSE S.BTRF_CODE           END
            ,FRST_NAME           = CASE S.FRST_NAME           WHEN NULL THEN @FRST_NAME           ELSE S.FRST_NAME           END
            ,LAST_NAME           = CASE S.LAST_NAME           WHEN NULL THEN @LAST_NAME           ELSE S.LAST_NAME           END
            ,FATH_NAME           = CASE S.FATH_NAME           WHEN NULL THEN @FATH_NAME           ELSE S.FATH_NAME           END
            ,SEX_TYPE            = CASE S.SEX_TYPE            WHEN NULL THEN @SEX_TYPE            ELSE S.SEX_TYPE            END
            ,NATL_CODE           = CASE S.NATL_CODE           WHEN NULL THEN @NATL_CODE           ELSE S.NATL_CODE           END
            ,BRTH_DATE           = CASE S.BRTH_DATE           WHEN NULL THEN @BRTH_DATE           ELSE S.BRTH_DATE           END
            ,CELL_PHON           = CASE S.CELL_PHON           WHEN NULL THEN @CELL_PHON           ELSE S.CELL_PHON           END
            ,TELL_PHON           = CASE S.TELL_PHON           WHEN NULL THEN @TELL_PHON           ELSE S.TELL_PHON           END
            ,[TYPE]              = CASE S.[TYPE]              WHEN NULL THEN @TYPE                ELSE S.[TYPE]              END
            ,POST_ADRS           = CASE S.POST_ADRS           WHEN NULL THEN @POST_ADRS           ELSE S.POST_ADRS           END
            ,EMAL_ADRS           = CASE S.EMAL_ADRS           WHEN NULL THEN @EMAL_ADRS           ELSE S.EMAL_ADRS           END
            ,ONOF_TAG            = CASE S.ONOF_TAG            WHEN NULL THEN @ONOF_TAG            ELSE S.ONOF_TAG            END
            ,SUNT_BUNT_DEPT_ORGN_CODE = CASE S.SUNT_BUNT_DEPT_ORGN_CODE WHEN NULL THEN @SUNT_BUNT_DEPT_ORGN_CODE ELSE S.SUNT_BUNT_DEPT_ORGN_CODE END
            ,SUNT_BUNT_DEPT_CODE = CASE S.SUNT_BUNT_DEPT_CODE WHEN NULL THEN @SUNT_BUNT_DEPT_CODE ELSE S.SUNT_BUNT_DEPT_CODE END
            ,SUNT_BUNT_CODE      = CASE S.SUNT_BUNT_CODE      WHEN NULL THEN @SUNT_BUNT_CODE      ELSE S.SUNT_BUNT_CODE      END
            ,SUNT_CODE           = CASE S.SUNT_CODE           WHEN NULL THEN @SUNT_CODE           ELSE S.SUNT_CODE           END
            ,ISCP_ISCA_ISCG_CODE = CASE S.ISCP_ISCA_ISCG_CODE WHEN NULL THEN @ISCP_ISCA_ISCG_CODE ELSE S.ISCP_ISCA_ISCG_CODE END
            ,ISCP_ISCA_CODE      = CASE S.ISCP_ISCA_CODE      WHEN NULL THEN @ISCP_ISCA_CODE      ELSE S.ISCP_ISCA_CODE      END
            ,ISCP_CODE           = CASE S.ISCP_CODE           WHEN NULL THEN @ISCP_CODE           ELSE S.ISCP_CODE           END
            ,CORD_X              = CASE S.CORD_X              WHEN NULL THEN @CORD_X              ELSE S.CORD_X              END
            ,CORD_Y              = CASE S.CORD_Y              WHEN NULL THEN @CORD_Y              ELSE S.CORD_Y              END
            ,MOST_DEBT_CLNG      = CASE S.MOST_DEBT_CLNG      WHEN 0    THEN @MOST_DEBT_CLNG      ELSE S.MOST_DEBT_CLNG      END
            ,MRID_TYPE           = CASE S.MRID_TYPE           WHEN NULL THEN @MRID_TYPE           ELSE S.MRID_TYPE           END
            ,RLGN_TYPE           = CASE S.RLGN_TYPE           WHEN NULL THEN @RLGN_TYPE           ELSE S.RLGN_TYPE           END
            ,ETHN_CITY           = CASE S.ETHN_CITY           WHEN NULL THEN @ETHN_CITY           ELSE s.ETHN_CITY           END
            ,CUST_TYPE           = CASE s.CUST_TYPE           WHEN NULL THEN @CUST_TYPE           ELSE s.CUST_TYPE           END
            ,STIF_TYPE           = CASE s.STIF_TYPE           WHEN NULL THEN @STIF_TYPE           ELSE s.STIF_TYPE           END
            ,JOB_TITL            = CASE s.JOB_TITL            WHEN NULL THEN @JOB_TITL            ELSE s.JOB_TITL            END
            ,FACE_BOOK_URL       = CASE s.FACE_BOOK_URL       WHEN NULL THEN @FACE_BOOK_URL       ELSE s.FACE_BOOK_URL       END
            ,LINK_IN_URL         = CASE s.LINK_IN_URL         WHEN NULL THEN @LINK_IN_URL         ELSE s.LINK_IN_URL         END            
            ,TWTR_URL            = CASE s.TWTR_URL            WHEN NULL THEN @TWTR_URL            ELSE s.TWTR_URL            END
            ,T.SERV_NO           = CASE s.SERV_NO             WHEN NULL THEN @SERV_NO             ELSE s.SERV_NO             END;
   -- UPDATE Service TABLE
   MERGE dbo.Service T
   USING (SELECT * FROM INSERTED I 
           WHERE I.RWNO = (SELECT MAX(RWNO) FROM Service_PUBLIC M 
                            WHERE M.SERV_FILE_NO = I.SERV_FILE_NO AND 
                                  M.RECT_CODE    = '004')) S
   ON (T.FILE_NO   = S.SERV_FILE_NO AND
       S.RECT_CODE = '004')
   WHEN MATCHED THEN
      UPDATE 
         SET SRPB_RWNO_DNRM = S.RWNO
            ,REGN_PRVN_CNTY_CODE = S.REGN_PRVN_CNTY_CODE
            ,REGN_PRVN_CODE = S.REGN_PRVN_CODE
            ,REGN_CODE = S.REGN_CODE
            ,FRST_NAME_DNRM = S.FRST_NAME
            ,LAST_NAME_DNRM = S.LAST_NAME
            ,NAME_DNRM      = S.LAST_NAME + ', ' + S.FRST_NAME
            ,FATH_NAME_DNRM = S.FATH_NAME
            ,POST_ADRS_DNRM = S.POST_ADRS
            ,EMAL_ADRS_DNRM = S.EMAL_ADRS
            ,SEX_TYPE_DNRM  = S.SEX_TYPE
            ,BRTH_DATE_DNRM = S.BRTH_DATE
            ,CELL_PHON_DNRM = S.CELL_PHON
            ,TELL_PHON_DNRM = S.TELL_PHON
            ,SRPB_TYPE_DNRM = S.[TYPE]
            ,TRFD_CODE_DNRM = S.TRFD_CODE
            ,BTRF_CODE_DNRM = S.BTRF_CODE
            ,COMP_CODE_DNRM = S.COMP_CODE
            ,ONOF_TAG_DNRM  = S.ONOF_TAG
            ,SUNT_BUNT_DEPT_ORGN_CODE_DNRM = S.SUNT_BUNT_DEPT_ORGN_CODE
            ,SUNT_BUNT_DEPT_CODE_DNRM = S.SUNT_BUNT_DEPT_CODE
            ,SUNT_BUNT_CODE_DNRM = S.SUNT_BUNT_CODE
            ,SUNT_CODE_DNRM = S.SUNT_CODE
            ,ISCP_ISCA_ISCG_CODE_DNRM = S.ISCP_ISCA_ISCG_CODE
            ,ISCP_ISCA_CODE_DNRM = S.ISCP_ISCA_CODE
            ,ISCP_CODE_DNRM = S.ISCP_CODE
            ,CORD_X_DNRM = S.CORD_X
            ,CORD_Y_DNRM = S.CORD_Y
            ,MOST_DEBT_CLNG_DNRM = S.MOST_DEBT_CLNG
            ,MRID_TYPE_DNRM = S.MRID_TYPE
            ,RLGN_TYPE_DNRM = S.RLGN_TYPE
            ,ETHN_CITY_DNRM = S.ETHN_CITY
            ,CUST_TYPE_DNRM = S.CUST_TYPE
    ,STIF_TYPE_DNRM = S.STIF_TYPE
            ,JOB_TITL_DNRM = S.JOB_TITL
            ,FACE_BOOK_URL_DNRM = s.FACE_BOOK_URL
            ,LINK_IN_URL_DNRM = s.LINK_IN_URL
            ,TWTR_URL_DNRM = s.TWTR_URL
            ,NATL_CODE_DNRM = s.NATL_CODE
            ,SERV_NO_DNRM = S.SERV_NO;
END;
GO
ALTER TABLE [dbo].[Service_Public] ADD CONSTRAINT [CK_SRPB_RECT_CODE] CHECK (([RECT_CODE]='004' OR [RECT_CODE]='003' OR [RECT_CODE]='002' OR [RECT_CODE]='001'))
GO
ALTER TABLE [dbo].[Service_Public] ADD CONSTRAINT [SRPB_PK] PRIMARY KEY CLUSTERED  ([SERV_FILE_NO], [RWNO], [RECT_CODE]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Service_Public] ADD CONSTRAINT [FK_SRPB_BTRF] FOREIGN KEY ([BTRF_CODE]) REFERENCES [dbo].[Base_Tariff] ([CODE]) ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Service_Public] ADD CONSTRAINT [FK_SRPB_COMP] FOREIGN KEY ([COMP_CODE]) REFERENCES [dbo].[Company] ([CODE]) ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Service_Public] ADD CONSTRAINT [FK_SRPB_EXPN] FOREIGN KEY ([EXPN_CODE]) REFERENCES [dbo].[Expense] ([CODE])
GO
ALTER TABLE [dbo].[Service_Public] ADD CONSTRAINT [FK_SRPB_ISCP] FOREIGN KEY ([ISCP_ISCA_ISCG_CODE], [ISCP_ISCA_CODE], [ISCP_CODE]) REFERENCES [dbo].[Isic_Product] ([ISCA_ISCG_CODE], [ISCA_CODE], [CODE]) ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Service_Public] ADD CONSTRAINT [FK_SRPB_JBPR] FOREIGN KEY ([OWNR_CODE]) REFERENCES [dbo].[Job_Personnel] ([CODE])
GO
ALTER TABLE [dbo].[Service_Public] ADD CONSTRAINT [FK_SRPB_REGN] FOREIGN KEY ([REGN_PRVN_CNTY_CODE], [REGN_PRVN_CODE], [REGN_CODE]) REFERENCES [dbo].[Region] ([PRVN_CNTY_CODE], [PRVN_CODE], [CODE]) ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Service_Public] ADD CONSTRAINT [FK_SRPB_RQRO] FOREIGN KEY ([RQRO_RQST_RQID], [RQRO_RWNO]) REFERENCES [dbo].[Request_Row] ([RQST_RQID], [RWNO]) ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Service_Public] ADD CONSTRAINT [FK_SRPB_SERV] FOREIGN KEY ([SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Service_Public] WITH NOCHECK ADD CONSTRAINT [FK_SRPB_SUNT] FOREIGN KEY ([SUNT_BUNT_DEPT_ORGN_CODE], [SUNT_BUNT_DEPT_CODE], [SUNT_BUNT_CODE], [SUNT_CODE]) REFERENCES [dbo].[Sub_Unit] ([BUNT_DEPT_ORGN_CODE], [BUNT_DEPT_CODE], [BUNT_CODE], [CODE])
GO
ALTER TABLE [dbo].[Service_Public] ADD CONSTRAINT [FK_SRPB_TRCB] FOREIGN KEY ([TRCB_TCID]) REFERENCES [dbo].[Transaction_Currency_Base] ([TCID])
GO
ALTER TABLE [dbo].[Service_Public] ADD CONSTRAINT [FK_SRPB_TRFD] FOREIGN KEY ([TRFD_CODE]) REFERENCES [dbo].[Base_Tariff_Detail] ([CODE]) ON DELETE SET NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'پست الکترونیک گروهی', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'ALOW_BULK_EMAL'
GO
EXEC sp_addextendedproperty N'MS_Description', N'پست الکترونیک', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'ALOW_EMAL'
GO
EXEC sp_addextendedproperty N'MS_Description', N'فکس', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'ALOW_FAX'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نامه', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'ALOW_LETT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'تلفن', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'ALOW_PHON'
GO
EXEC sp_addextendedproperty N'MS_Description', N'تاریخ تولد', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'BRTH_DATE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نوع سرویس', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'BTRF_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'شماره همراه', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'CELL_PHON'
GO
EXEC sp_addextendedproperty N'MS_Description', N'کد نمایندگی', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'COMP_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'شیوه تماس', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'CONT_MTOD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'آدرس افقی جغرافیایی', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'CORD_X'
GO
EXEC sp_addextendedproperty N'MS_Description', N'آدرس عمودی جغرافیایی', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'CORD_Y'
GO
EXEC sp_addextendedproperty N'MS_Description', N'میزان مبلغ اعتبار', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'CRDT_AMNT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'وضعیت اعتبار', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'CRDT_STAT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نوع مشتری گرم سرد', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'CUST_TYPE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'مدرک تحصیلی', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'EDUC_DEG'
GO
EXEC sp_addextendedproperty N'MS_Description', N'آدرس ایمیل', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'EMAL_ADRS'
GO
EXEC sp_addextendedproperty N'MS_Description', N'قومیت', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'ETHN_CITY'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نوع سرویس انتخابی', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'EXPN_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نام پدر', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'FATH_NAME'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نام', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'FRST_NAME'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نام مالک تلفن', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'FRST_NAME_OWNR_LINE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'شماره شناسنامه', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'IDTY_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'سمت شغلی', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'JOB_TITL'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نام خانوادگی', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'LAST_NAME'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نام خانوادگی مالک تلفن', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'LAST_NAME_OWNR_LINE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'شماره تلفن سرویس', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'LINE_NUMB_SERV'
GO
EXEC sp_addextendedproperty N'MS_Description', N'سقف بدهی مشترک', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'MOST_DEBT_CLNG'
GO
EXEC sp_addextendedproperty N'MS_Description', N'وضعیت تاهل', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'MRID_TYPE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'کد ملی', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'NATL_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'کد ملی مالک تلفن', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'NATL_CODE_OWNR_LINE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'شاخص قطع و وصل', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'ONOF_TAG'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نوع مالکیت', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'OWNR_TYPE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'رمز عبور', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'PASS_WORD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'آدرس پستی', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'POST_ADRS'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ضوابط پرداخت', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'PYMT_TERM'
GO
EXEC sp_addextendedproperty N'MS_Description', N'کد رکورد', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'RECT_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'کد ناحیه', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'REGN_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'کد کشور', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'REGN_PRVN_CNTY_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'کد استان', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'REGN_PRVN_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'دین / مذهب', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'RLGN_TYPE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'شماره درخواست', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'RQRO_RQST_RQID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ردیف درخواست', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'RQRO_RWNO'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ردیف اطلاعات عمومی', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'RWNO'
GO
EXEC sp_addextendedproperty N'MS_Description', N'شماره پرونده', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'SERV_FILE_NO'
GO
EXEC sp_addextendedproperty N'MS_Description', N'کد حساب ، حسابداری مشتری', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'SERV_NO'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نوع جنسیت', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'SEX_TYPE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'شرایط حمل', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'SHIP_CHRG'
GO
EXEC sp_addextendedproperty N'MS_Description', N'روش حمل کالا', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'SHIP_MTOD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'میزان رضایت مندی', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'STIF_TYPE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'کد مجموعه اصلی', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'SUNT_BUNT_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'کد موسسه', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'SUNT_BUNT_DEPT_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'کد ارگان', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'SUNT_BUNT_DEPT_ORGN_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'کد مجموعه فرعی', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'SUNT_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'کد تلگرام', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'TELG_CHAT_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'تلفن ثابت', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'TELL_PHON'
GO
EXEC sp_addextendedproperty N'MS_Description', N'پول', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'TRCB_TCID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نوع تعرفه', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'TRFD_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نوع مشترک', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'TYPE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نام کاربری پنل', 'SCHEMA', N'dbo', 'TABLE', N'Service_Public', 'COLUMN', N'USER_NAME'
GO
