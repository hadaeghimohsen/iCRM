CREATE TABLE [dbo].[Service]
(
[REGN_PRVN_CNTY_CODE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SERV_REGN_PRVN_CNTY_CODE] DEFAULT ('001'),
[REGN_PRVN_CODE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_SERV_REGN_PRVN_CODE] DEFAULT ('001'),
[REGN_CODE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FILE_NO] [bigint] NOT NULL CONSTRAINT [DF_SERV_FILE_NO] DEFAULT ((0)),
[TARF_CODE_DNRM] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MOST_DEBT_CLNG_DNRM] [bigint] NULL,
[DEBT_DNRM] [bigint] NULL,
[SRPB_RWNO_DNRM] [int] NULL,
[CONF_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SERV_CONF_STAT] DEFAULT ('001'),
[CONF_DATE] [datetime] NULL,
[SERV_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_SERV_SERV_STAT] DEFAULT ('002'),
[RQST_RQID] [bigint] NULL,
[NAME_DNRM] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FRST_NAME_DNRM] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LAST_NAME_DNRM] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FATH_NAME_DNRM] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POST_ADRS_DNRM] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SEX_TYPE_DNRM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BRTH_DATE_DNRM] [datetime] NULL,
[CELL_PHON_DNRM] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TELL_PHON_DNRM] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SRPB_TYPE_DNRM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TEST_DATE_DNRM] [datetime] NULL,
[TRFD_CODE_DNRM] [bigint] NULL,
[BTRF_CODE_DNRM] [bigint] NULL,
[COMP_CODE_DNRM] [bigint] NULL,
[ONOF_TAG_DNRM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SERV_FILE_NO] [bigint] NULL,
[IMAG_RCDC_RCID_DNRM] [bigint] NULL,
[IMAG_RWNO_DNRM] [smallint] NULL,
[SUNT_BUNT_DEPT_ORGN_CODE_DNRM] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUNT_BUNT_DEPT_CODE_DNRM] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUNT_BUNT_CODE_DNRM] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUNT_CODE_DNRM] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ISCP_ISCA_ISCG_CODE_DNRM] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ISCP_ISCA_CODE_DNRM] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ISCP_CODE_DNRM] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CORD_X_DNRM] [float] NULL,
[CORD_Y_DNRM] [float] NULL,
[MRID_TYPE_DNRM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RLGN_TYPE_DNRM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ETHN_CITY_DNRM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CUST_TYPE_DNRM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STIF_TYPE_DNRM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JOB_TITL_DNRM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LAST_RQST_RQID_DNRM] [bigint] NULL,
[SCOR_LEVL_DNRM] [int] NULL,
[SERV_STAG_CODE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMAL_ADRS_DNRM] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FACE_BOOK_URL_DNRM] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LINK_IN_URL_DNRM] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TWTR_URL_DNRM] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NATL_CODE_DNRM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SERV_NO_DNRM] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OWNR_CODE_DNRM] [bigint] NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_SERV]
   ON  [dbo].[Service]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   DECLARE @Fileno BIGINT = DBO.GNRT_NVID_U();
   
   -- Insert statements for trigger here
   MERGE dbo.Service T
   USING (SELECT * FROM INSERTED) S
   ON (T.FILE_NO = S.FILE_NO)
   WHEN MATCHED THEN
      UPDATE
         SET CRET_BY   = UPPER(SUSER_NAME())
            ,CRET_DATE = GETDATE()
            ,FILE_NO   = @Fileno;
   
   INSERT INTO dbo.Weekday_Info( CODE, SERV_FILE_NO, WEEK_DAY, STAT ) 
   VALUES  ( dbo.GNRT_NVID_U() ,@Fileno , '001' ,'002' ),
           ( dbo.GNRT_NVID_U() ,@Fileno , '002' ,'002' ),
           ( dbo.GNRT_NVID_U() ,@Fileno , '003' ,'002' ),
           ( dbo.GNRT_NVID_U() ,@Fileno , '004' ,'002' ),
           ( dbo.GNRT_NVID_U() ,@Fileno , '005' ,'002' ),
           ( dbo.GNRT_NVID_U() ,@Fileno , '006' ,'002' ),
           ( dbo.GNRT_NVID_U() ,@Fileno , '007' ,'002' );
END
;
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[CG$AUPD_SERV]
   ON  [dbo].[Service]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Service T
   USING (SELECT * FROM INSERTED) S
   ON (T.FILE_NO = S.FILE_NO)
   WHEN MATCHED THEN
      UPDATE
         SET MDFY_BY        = UPPER(SUSER_NAME())
            ,MDFY_DATE      = GETDATE()
            ,CONF_DATE      = CASE 
                                 WHEN T.CONF_STAT = '002' AND S.CONF_STAT = '002' AND T.CONF_DATE IS NULL THEN GETDATE() 
                                 WHEN T.CONF_STAT = '002' AND T.CONF_DATE IS NOT NULL THEN T.CONF_DATE 
                                 WHEN T.CONF_STAT = '001' AND S.CONF_STAT = '001' THEN NULL 
                              END
            ,DEBT_DNRM      = dbo.GET_DBTF_U(S.FILE_NO, NULL)
            ,TARF_CODE_DNRM = dbo.GET_TARF_U(S.File_No);            
END
;
GO
ALTER TABLE [dbo].[Service] ADD CONSTRAINT [SERV_PK] PRIMARY KEY CLUSTERED  ([FILE_NO]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Service] ADD CONSTRAINT [FK_SERV_BTRF] FOREIGN KEY ([BTRF_CODE_DNRM]) REFERENCES [dbo].[Base_Tariff] ([CODE])
GO
ALTER TABLE [dbo].[Service] ADD CONSTRAINT [FK_SERV_COMP] FOREIGN KEY ([COMP_CODE_DNRM]) REFERENCES [dbo].[Company] ([CODE])
GO
ALTER TABLE [dbo].[Service] ADD CONSTRAINT [FK_SERV_ISCP] FOREIGN KEY ([ISCP_ISCA_ISCG_CODE_DNRM], [ISCP_ISCA_CODE_DNRM], [ISCP_CODE_DNRM]) REFERENCES [dbo].[Isic_Product] ([ISCA_ISCG_CODE], [ISCA_CODE], [CODE])
GO
ALTER TABLE [dbo].[Service] ADD CONSTRAINT [FK_SERV_JBPR] FOREIGN KEY ([OWNR_CODE_DNRM]) REFERENCES [dbo].[Job_Personnel] ([CODE])
GO
ALTER TABLE [dbo].[Service] ADD CONSTRAINT [FK_SERV_LAST_RQID] FOREIGN KEY ([LAST_RQST_RQID_DNRM]) REFERENCES [dbo].[Request] ([RQID])
GO
ALTER TABLE [dbo].[Service] ADD CONSTRAINT [FK_SERV_REGN] FOREIGN KEY ([REGN_PRVN_CNTY_CODE], [REGN_PRVN_CODE], [REGN_CODE]) REFERENCES [dbo].[Region] ([PRVN_CNTY_CODE], [PRVN_CODE], [CODE]) ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Service] ADD CONSTRAINT [FK_SERV_RQST] FOREIGN KEY ([RQST_RQID]) REFERENCES [dbo].[Request] ([RQID])
GO
ALTER TABLE [dbo].[Service] ADD CONSTRAINT [FK_SERV_SERV] FOREIGN KEY ([SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO])
GO
ALTER TABLE [dbo].[Service] ADD CONSTRAINT [FK_SERV_SUNT] FOREIGN KEY ([SUNT_BUNT_DEPT_ORGN_CODE_DNRM], [SUNT_BUNT_DEPT_CODE_DNRM], [SUNT_BUNT_CODE_DNRM], [SUNT_CODE_DNRM]) REFERENCES [dbo].[Sub_Unit] ([BUNT_DEPT_ORGN_CODE], [BUNT_DEPT_CODE], [BUNT_CODE], [CODE])
GO
ALTER TABLE [dbo].[Service] ADD CONSTRAINT [FK_SERV_TRFD] FOREIGN KEY ([TRFD_CODE_DNRM]) REFERENCES [dbo].[Base_Tariff_Detail] ([CODE])
GO
EXEC sp_addextendedproperty N'MS_Description', N'نوع مشتری گرم سرد', 'SCHEMA', N'dbo', 'TABLE', N'Service', 'COLUMN', N'CUST_TYPE_DNRM'
GO
EXEC sp_addextendedproperty N'MS_Description', N'قومیت', 'SCHEMA', N'dbo', 'TABLE', N'Service', 'COLUMN', N'ETHN_CITY_DNRM'
GO
EXEC sp_addextendedproperty N'MS_Description', N'آخرین درخواستی که برای مشتری انجام شده', 'SCHEMA', N'dbo', 'TABLE', N'Service', 'COLUMN', N'LAST_RQST_RQID_DNRM'
GO
EXEC sp_addextendedproperty N'MS_Description', N'وضعیت تاهل', 'SCHEMA', N'dbo', 'TABLE', N'Service', 'COLUMN', N'MRID_TYPE_DNRM'
GO
EXEC sp_addextendedproperty N'MS_Description', N'دین / مذهب', 'SCHEMA', N'dbo', 'TABLE', N'Service', 'COLUMN', N'RLGN_TYPE_DNRM'
GO
EXEC sp_addextendedproperty N'MS_Description', N'امتیاز دهی به مشتریان', 'SCHEMA', N'dbo', 'TABLE', N'Service', 'COLUMN', N'SCOR_LEVL_DNRM'
GO
EXEC sp_addextendedproperty N'MS_Description', N'وضعیت رتبه ای مشترک', 'SCHEMA', N'dbo', 'TABLE', N'Service', 'COLUMN', N'SERV_STAG_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'میزان رضایت مندی', 'SCHEMA', N'dbo', 'TABLE', N'Service', 'COLUMN', N'STIF_TYPE_DNRM'
GO
