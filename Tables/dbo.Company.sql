CREATE TABLE [dbo].[Company]
(
[REGN_PRVN_CNTY_CODE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_COMP_REGN_PRVN_CNTY_CODE] DEFAULT ('001'),
[REGN_PRVN_CODE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_COMP_REGN_PRVN_CODE] DEFAULT ('001'),
[REGN_CODE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ISCP_ISCA_ISCG_CODE] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ISCP_ISCA_CODE] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ISCP_CODE] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CODE] [bigint] NOT NULL CONSTRAINT [DF_COMP_CODE] DEFAULT ((0)),
[DEBT_DNRM] [bigint] NULL,
[NAME] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CORD_X] [float] NULL,
[CORD_Y] [float] NULL,
[POST_ADDR_ZOOM] [float] NULL,
[POST_ADRS] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EMAL_ADRS] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WEB_SITE] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COMP_CODE] [bigint] NULL,
[COMP_DESC] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REGS_DATE] [date] NULL,
[ZIP_CODE] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LOGO] [image] NULL,
[ECON_CODE] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STRT_TIME] [datetime] NULL,
[END_TIME] [datetime] NULL,
[TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMPY_NUMB_DNRM] [int] NULL,
[BILL_ADDR_X] [float] NULL,
[BILL_ADDR_Y] [float] NULL,
[BILL_ADDR_ZOOM] [float] NULL,
[BILL_ADDR] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHIP_ADDR_X] [float] NULL,
[SHIP_ADDR_Y] [float] NULL,
[SHIP_ADDR_ZOOM] [float] NULL,
[SHIP_ADDR] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DFLT_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FACE_BOOK_URL] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LINK_IN_URL] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TWTR_URL] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CELL_PHON] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TELL_PHON] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FAX_NUMB] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LAST_SERV_FILE_NO_DNRM] [bigint] NULL,
[LAST_RQST_RQID_DNRM] [bigint] NULL,
[RECD_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_COMP_RECD_STAT] DEFAULT ('002'),
[HOST_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OWNR_CODE] [bigint] NULL,
[PRIM_SERV_FILE_NO] [bigint] NULL,
[TRCB_TCID] [bigint] NULL,
[CRDT_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRDT_AMNT] [bigint] NULL,
[PYMT_TERM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OWNR_SHIP] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GET_KNOW_US] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GET_KNOW_CUST] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CONT_MTOD] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ALOW_EMAL] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ALOW_BULK_EMAL] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ALOW_PHON] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ALOW_FAX] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ALOW_LETT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHIP_MTOD] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHIP_CHRG] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REVN_AMNT] [bigint] NULL,
[EMPY_NUMB] [int] NULL,
[CRET_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRET_DATE] [datetime] NULL,
[MDFY_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MDFY_DATE] [datetime] NULL
) ON [BLOB] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[CG$AINS_COMP]
   ON  [dbo].[Company]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   -- چک کردن تعداد نسخه های نرم افزار خریداری شده
   --IF (SELECT COUNT(*) FROM COMP) > dbo.NumberInstanceForUser()
   --BEGIN
   --   RAISERROR(N'با توجه به تعداد نسخه خریداری شده شما قادر به اضافه کردن مکان جدید به نرم افزار را ندارید. لطفا با پشتیبانی 09333617031 تماس بگیرید', 16, 1);
   --   RETURN;
   --END
   L$GnrtCode:
   DECLARE @Code BIGINT;
   SET @Code = dbo.GNRT_NVID_U();
   IF EXISTS(SELECT * FROM dbo.Company WHERE CODE = @Code)
   BEGIN
      PRINT 'Found'
      GOTO L$GnrtCode;
   END

   
   MERGE dbo.Company T
   USING (SELECT CODE FROM INSERTED) S
   ON (T.CODE                = S.CODE)
   WHEN MATCHED THEN
      UPDATE
         SET CRET_BY   = UPPER(SUSER_NAME())
            ,CRET_DATE = GETDATE()
            ,CODE      = @Code;
   
   INSERT INTO dbo.Weekday_Info( CODE, COMP_CODE, WEEK_DAY, STAT ) 
   VALUES  ( dbo.GNRT_NVID_U() ,@Code , '001' ,'002' ),
           ( dbo.GNRT_NVID_U() ,@Code , '002' ,'002' ),
           ( dbo.GNRT_NVID_U() ,@Code , '003' ,'002' ),
           ( dbo.GNRT_NVID_U() ,@Code , '004' ,'002' ),
           ( dbo.GNRT_NVID_U() ,@Code , '005' ,'002' ),
           ( dbo.GNRT_NVID_U() ,@Code , '006' ,'002' ),
           ( dbo.GNRT_NVID_U() ,@Code , '007' ,'002' );

END
;
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[CG$AUPD_COMP]
   ON  [dbo].[Company]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   
   MERGE dbo.Company T
   USING (SELECT CODE FROM INSERTED) S
   ON (T.CODE                = S.CODE)
   WHEN MATCHED THEN
      UPDATE
         SET MDFY_BY   = UPPER(SUSER_NAME())
            ,MDFY_DATE = GETDATE()
            ,T.DEBT_DNRM = dbo.GET_DBTF_U(NULL, s.CODE)
            ,T.EMPY_NUMB_DNRM = (SELECT COUNT(*) FROM dbo.Service st WHERE st.COMP_CODE_DNRM = S.CODE AND st.CONF_STAT = '002');
END
;
GO
ALTER TABLE [dbo].[Company] ADD CONSTRAINT [COMP_PK] PRIMARY KEY CLUSTERED  ([CODE]) ON [BLOB]
GO
ALTER TABLE [dbo].[Company] ADD CONSTRAINT [FK_COMP_COMP] FOREIGN KEY ([COMP_CODE]) REFERENCES [dbo].[Company] ([CODE])
GO
ALTER TABLE [dbo].[Company] ADD CONSTRAINT [FK_COMP_ISCP] FOREIGN KEY ([ISCP_ISCA_ISCG_CODE], [ISCP_ISCA_CODE], [ISCP_CODE]) REFERENCES [dbo].[Isic_Product] ([ISCA_ISCG_CODE], [ISCA_CODE], [CODE]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Company] ADD CONSTRAINT [FK_COMP_JOBP] FOREIGN KEY ([OWNR_CODE]) REFERENCES [dbo].[Job_Personnel] ([CODE])
GO
ALTER TABLE [dbo].[Company] ADD CONSTRAINT [FK_COMP_PSRV] FOREIGN KEY ([PRIM_SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO])
GO
ALTER TABLE [dbo].[Company] ADD CONSTRAINT [FK_COMP_REGN] FOREIGN KEY ([REGN_PRVN_CNTY_CODE], [REGN_PRVN_CODE], [REGN_CODE]) REFERENCES [dbo].[Region] ([PRVN_CNTY_CODE], [PRVN_CODE], [CODE]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Company] ADD CONSTRAINT [FK_COMP_RQST] FOREIGN KEY ([LAST_RQST_RQID_DNRM]) REFERENCES [dbo].[Request] ([RQID])
GO
ALTER TABLE [dbo].[Company] ADD CONSTRAINT [FK_COMP_SERV] FOREIGN KEY ([LAST_SERV_FILE_NO_DNRM]) REFERENCES [dbo].[Service] ([FILE_NO])
GO
ALTER TABLE [dbo].[Company] ADD CONSTRAINT [FK_COMP_TRCB] FOREIGN KEY ([TRCB_TCID]) REFERENCES [dbo].[Transaction_Currency_Base] ([TCID])
GO
EXEC sp_addextendedproperty N'MS_Description', N'توضیحات', 'SCHEMA', N'dbo', 'TABLE', N'Company', 'COLUMN', N'COMP_DESC'
GO
EXEC sp_addextendedproperty N'MS_Description', N'میزان مبلغ اعتبار', 'SCHEMA', N'dbo', 'TABLE', N'Company', 'COLUMN', N'CRDT_AMNT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'وضعیت اعتبار', 'SCHEMA', N'dbo', 'TABLE', N'Company', 'COLUMN', N'CRDT_STAT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'کد اقتصادی', 'SCHEMA', N'dbo', 'TABLE', N'Company', 'COLUMN', N'ECON_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'تعداد کارمندان', 'SCHEMA', N'dbo', 'TABLE', N'Company', 'COLUMN', N'EMPY_NUMB'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ساعت پایان کار', 'SCHEMA', N'dbo', 'TABLE', N'Company', 'COLUMN', N'END_TIME'
GO
EXEC sp_addextendedproperty N'MS_Description', N'شماره فکس شرکت', 'SCHEMA', N'dbo', 'TABLE', N'Company', 'COLUMN', N'FAX_NUMB'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نحوه آشنایی با مشتری', 'SCHEMA', N'dbo', 'TABLE', N'Company', 'COLUMN', N'GET_KNOW_CUST'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نحوه آشنایی با ما', 'SCHEMA', N'dbo', 'TABLE', N'Company', 'COLUMN', N'GET_KNOW_US'
GO
EXEC sp_addextendedproperty N'MS_Description', N'شرکت میزبان', 'SCHEMA', N'dbo', 'TABLE', N'Company', 'COLUMN', N'HOST_STAT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'آخرین درخواستی که برای پرسنلهای آن شرکت انجام شده', 'SCHEMA', N'dbo', 'TABLE', N'Company', 'COLUMN', N'LAST_RQST_RQID_DNRM'
GO
EXEC sp_addextendedproperty N'MS_Description', N'آخرین مشتری از شرکت مربوطه که با آن در ارتباط بوده ایم', 'SCHEMA', N'dbo', 'TABLE', N'Company', 'COLUMN', N'LAST_SERV_FILE_NO_DNRM'
GO
EXEC sp_addextendedproperty N'MS_Description', N'این شرکت متعلق به چه کسی می باشد. کاربری که این شرکت را ثبت کرده و مالکش می باشد کیست', 'SCHEMA', N'dbo', 'TABLE', N'Company', 'COLUMN', N'OWNR_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'شخص اصلی شرکت', 'SCHEMA', N'dbo', 'TABLE', N'Company', 'COLUMN', N'PRIM_SERV_FILE_NO'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ضوابط پرداخت', 'SCHEMA', N'dbo', 'TABLE', N'Company', 'COLUMN', N'PYMT_TERM'
GO
EXEC sp_addextendedproperty N'MS_Description', N'وضعیت ردیف * فعال * غیرفعال', 'SCHEMA', N'dbo', 'TABLE', N'Company', 'COLUMN', N'RECD_STAT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'تاریخ تاسیس', 'SCHEMA', N'dbo', 'TABLE', N'Company', 'COLUMN', N'REGS_DATE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'درآمد شرکت', 'SCHEMA', N'dbo', 'TABLE', N'Company', 'COLUMN', N'REVN_AMNT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'شرایط حمل', 'SCHEMA', N'dbo', 'TABLE', N'Company', 'COLUMN', N'SHIP_CHRG'
GO
EXEC sp_addextendedproperty N'MS_Description', N'روش حمل و نقل', 'SCHEMA', N'dbo', 'TABLE', N'Company', 'COLUMN', N'SHIP_MTOD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ساعت شروع کار', 'SCHEMA', N'dbo', 'TABLE', N'Company', 'COLUMN', N'STRT_TIME'
GO
EXEC sp_addextendedproperty N'MS_Description', N'واحد پولی', 'SCHEMA', N'dbo', 'TABLE', N'Company', 'COLUMN', N'TRCB_TCID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'کد پستی', 'SCHEMA', N'dbo', 'TABLE', N'Company', 'COLUMN', N'ZIP_CODE'
GO
