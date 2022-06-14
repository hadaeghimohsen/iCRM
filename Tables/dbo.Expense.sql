CREATE TABLE [dbo].[Expense]
(
[REGL_YEAR] [smallint] NULL,
[REGL_CODE] [int] NULL,
[EXTP_CODE] [bigint] NULL,
[TRFD_CODE] [bigint] NULL,
[BTRF_CODE] [bigint] NULL,
[CODE] [bigint] NOT NULL CONSTRAINT [DF_EXPN_CODE] DEFAULT ((0)),
[EXPN_DESC] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRIC] [int] NOT NULL CONSTRAINT [DF_EXPN_PRIC] DEFAULT ((0)),
[EXTR_PRCT] [int] NOT NULL CONSTRAINT [DF_EXPN_EXTR_PRCT] DEFAULT ((0)),
[EXPN_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_EXPN_EXPN_STAT] DEFAULT ('002'),
[ADD_QUTS] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Expense_ADD_QUTS] DEFAULT ('001'),
[COVR_DSCT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Expense_COVR_DSCT] DEFAULT ('002'),
[EXPN_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BUY_PRIC] [int] NULL,
[BUY_EXTR_PRCT] [int] NULL,
[NUMB_OF_STOK] [int] NULL,
[NUMB_OF_SALE] [int] NULL,
[NUMB_OF_REMN_DNRM] [int] NULL,
[ORDR_ITEM] [bigint] NULL,
[NUMB_OF_MONT] [int] NULL,
[VOLM_OF_TRFC] [int] NULL,
[AUTO_ADD] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MODL_NUMB_BAR_CODE] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COVR_TAX] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_EXPN]
   ON [dbo].[Expense]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   
   --SELECT * FROM inserted;
   -- Insert statements for trigger here
   
   -- نوع های آیین نامه
   -- 001 = هزینه
   -- 002 = حساب
   -- آیین نامه فعال
   -- 001 = غیرفعال
   -- 002 = فعال
   
   MERGE dbo.Expense T
   USING (SELECT * FROM INSERTED) S
   ON (T.REGL_YEAR = S.REGL_YEAR AND
       T.REGL_CODE = S.REGL_CODE AND
       T.EXTP_CODE = S.EXTP_CODE AND
       T.TRFD_CODE = S.TRFD_CODE AND
       T.BTRF_CODE = S.BTRF_CODE)
   WHEN MATCHED THEN
      UPDATE 
         SET CRET_BY   = UPPER(SUSER_NAME())
            ,CRET_DATE = GETDATE();
            --,CODE      = DBO.GNRT_NVID_U();
END
;
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[CG$AUPD_EXPN]
   ON [dbo].[Expense]
   AFTER UPDATE
AS 
BEGIN
   BEGIN TRY
   BEGIN TRAN CG$AUPD_EXPN_T
   
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   
   -- نوع های آیین نامه
   -- 001 = هزینه
   -- 002 = حساب
   -- آیین نامه فعال
   -- 001 = غیرفعال
   -- 002 = فعال
   
   DELETE Expense 
   WHERE EXISTS(
      SELECT *
        FROM INSERTED I
       WHERE I.EXTP_CODE IS NULL
       AND Expense.CODE = I.CODE
       AND NOT EXISTS(
         SELECT *
           FROM Payment_Detail pd
          WHERE pd.EXPN_CODE = I.CODE
       )
   );

   -- اگر مبلغ هزینه خواستیم تغییر دهیم باید چک کنیم که قبلا هیچ مبلغ واریزی با نرخ قدیم نداشته باشیم.
   IF EXISTS(SELECT * FROM Payment_Detail Pd, INSERTED I WHERE Pd.EXPN_CODE = I.CODE AND Pd.PAY_STAT = '002' AND Pd.EXPN_PRIC <> I.PRIC AND Pd.EXPN_EXTR_PRCT <> I.EXTR_PRCT)
   BEGIN
      RAISERROR(N'از این نرخ قبلا مورد وصولی داشته اید، شما بایستی آیین نامه درآمد جدیدی ثبت کنید و نرخ جدید را درآن لحاظ کنید', 16, 1);
      RETURN;
   END
   
   MERGE dbo.Expense T
   USING (SELECT E.Code, E.Regl_Year, E.Regl_Code, I.Extp_Code, I.TRFD_Code, I.BTRF_Code, I.Pric, I.Expn_Desc, I.EXPN_TYPE, I.Numb_Of_Stok, I.Numb_Of_Sale, I.Numb_Of_Remn_Dnrm, I.Covr_tax FROM INSERTED I, Expense E WHERE I.Code = E.Code) S
   ON (T.REGL_YEAR = S.REGL_YEAR AND
       T.REGL_CODE = S.REGL_CODE AND
       T.EXTP_CODE = S.EXTP_CODE AND
       T.TRFD_CODE = S.TRFD_CODE AND
       T.BTRF_CODE = S.BTRF_CODE AND
       T.CODE      = S.CODE)
   WHEN MATCHED THEN
      UPDATE 
         SET MDFY_BY   = UPPER(SUSER_NAME())
            ,MDFY_DATE = GETDATE()            
            ,EXTR_PRCT = CASE S.COVR_TAX WHEN '002' THEN (SELECT (S.PRIC * (TAX_PRCT + DUTY_PRCT)) / 100 FROM dbo.Regulation WHERE [YEAR] = S.REGL_YEAR AND CODE = S.REGL_CODE AND [TYPE] = '001') ELSE 0 END
            ,EXPN_DESC = CASE WHEN LEN(S.EXPN_DESC) = 0 OR S.EXPN_DESC IS NULL THEN (SELECT EPIT_DESC FROM Expense_Type Et, Expense_Item Ei WHERE Et.Code = S.Extp_Code AND Et.Epit_Code = Ei.Code) ELSE S.Expn_Desc END
            ,NUMB_OF_REMN_DNRM = CASE S.EXPN_TYPE WHEN '001' /* خدمت */ THEN S.NUMB_OF_REMN_DNRM WHEN '002' /* کالا */ THEN ISNULL(S.NUMB_OF_STOK, 0) - ISNULL(S.NUMB_OF_SALE, 0) END
            /*,EXPN_DESC = (SELECT EXTP.EXTP_DESC + N' به سبک ' + BTRF.BTRF_DESC + N' با رسته ' + TRFD.TRFD_DESC
                            FROM dbo.Expense_Type EXTP, dbo.Tariff_Detail_Belt TRFD, dbo.Base_Tariff BTRF
                           WHERE EXTP.CODE = S.EXTP_CODE
                             AND TRFD.CODE = S.TRFD_CODE
                             AND BTRF.CODE = S.BTRF_CODE)*/;

   
   COMMIT TRAN CG$AUPD_EXPN_T;
   END TRY
   BEGIN CATCH
      DECLARE @ErrorMessage NVARCHAR(MAX);
      SET @ErrorMessage = ERROR_MESSAGE();
      RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN T1;
   END CATCH;
END
;
GO
ALTER TABLE [dbo].[Expense] ADD CONSTRAINT [CK_EXPN_EXPN_STAT] CHECK (([EXPN_STAT]='002' OR [EXPN_STAT]='001'))
GO
ALTER TABLE [dbo].[Expense] ADD CONSTRAINT [EXPN_PK] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Expense] ADD CONSTRAINT [FK_EXPN_BTRF] FOREIGN KEY ([BTRF_CODE]) REFERENCES [dbo].[Base_Tariff] ([CODE]) ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Expense] ADD CONSTRAINT [FK_EXPN_EXTP] FOREIGN KEY ([EXTP_CODE]) REFERENCES [dbo].[Expense_Type] ([CODE]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Expense] ADD CONSTRAINT [FK_EXPN_REGL] FOREIGN KEY ([REGL_YEAR], [REGL_CODE]) REFERENCES [dbo].[Regulation] ([YEAR], [CODE]) ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Expense] ADD CONSTRAINT [FK_EXPN_TRFD] FOREIGN KEY ([TRFD_CODE]) REFERENCES [dbo].[Base_Tariff_Detail] ([CODE]) ON DELETE SET NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'درآمدهای اضافی خارج از برنامه', 'SCHEMA', N'dbo', 'TABLE', N'Expense', 'COLUMN', N'ADD_QUTS'
GO
EXEC sp_addextendedproperty N'MS_Description', N'آیا به صورت اتوماتیک اضافه گردد؟', 'SCHEMA', N'dbo', 'TABLE', N'Expense', 'COLUMN', N'AUTO_ADD'
GO
EXEC sp_addextendedproperty N'MS_Description', N'سبک مشترک', 'SCHEMA', N'dbo', 'TABLE', N'Expense', 'COLUMN', N'BTRF_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ارزش افزوده خرید', 'SCHEMA', N'dbo', 'TABLE', N'Expense', 'COLUMN', N'BUY_EXTR_PRCT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'مبلغ خرید', 'SCHEMA', N'dbo', 'TABLE', N'Expense', 'COLUMN', N'BUY_PRIC'
GO
EXEC sp_addextendedproperty N'MS_Description', N'کد', 'SCHEMA', N'dbo', 'TABLE', N'Expense', 'COLUMN', N'CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'شامل محاسبه تخفیف می شود یا خیر', 'SCHEMA', N'dbo', 'TABLE', N'Expense', 'COLUMN', N'COVR_DSCT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'هزینه شامل ارزش افزوده می باشد؟', 'SCHEMA', N'dbo', 'TABLE', N'Expense', 'COLUMN', N'COVR_TAX'
GO
EXEC sp_addextendedproperty N'MS_Description', N'شرح هزینه', 'SCHEMA', N'dbo', 'TABLE', N'Expense', 'COLUMN', N'EXPN_DESC'
GO
EXEC sp_addextendedproperty N'MS_Description', N'وضعیت هزینه', 'SCHEMA', N'dbo', 'TABLE', N'Expense', 'COLUMN', N'EXPN_STAT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نوع هزینه', 'SCHEMA', N'dbo', 'TABLE', N'Expense', 'COLUMN', N'EXPN_TYPE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نوع هزینه', 'SCHEMA', N'dbo', 'TABLE', N'Expense', 'COLUMN', N'EXTP_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ارزش افزوده', 'SCHEMA', N'dbo', 'TABLE', N'Expense', 'COLUMN', N'EXTR_PRCT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'بارکد مدل محصول', 'SCHEMA', N'dbo', 'TABLE', N'Expense', 'COLUMN', N'MODL_NUMB_BAR_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'تعداد ماه های سرویس', 'SCHEMA', N'dbo', 'TABLE', N'Expense', 'COLUMN', N'NUMB_OF_MONT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'تعداد کالای باقیمانده', 'SCHEMA', N'dbo', 'TABLE', N'Expense', 'COLUMN', N'NUMB_OF_REMN_DNRM'
GO
EXEC sp_addextendedproperty N'MS_Description', N'تعداد کالای فروخته شده', 'SCHEMA', N'dbo', 'TABLE', N'Expense', 'COLUMN', N'NUMB_OF_SALE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'تعداد کل موجودی کالای', 'SCHEMA', N'dbo', 'TABLE', N'Expense', 'COLUMN', N'NUMB_OF_STOK'
GO
EXEC sp_addextendedproperty N'MS_Description', N'مبلغ', 'SCHEMA', N'dbo', 'TABLE', N'Expense', 'COLUMN', N'PRIC'
GO
EXEC sp_addextendedproperty N'MS_Description', N'کد آیین نامه', 'SCHEMA', N'dbo', 'TABLE', N'Expense', 'COLUMN', N'REGL_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'سال آیین نامه', 'SCHEMA', N'dbo', 'TABLE', N'Expense', 'COLUMN', N'REGL_YEAR'
GO
EXEC sp_addextendedproperty N'MS_Description', N'رسته مشترک', 'SCHEMA', N'dbo', 'TABLE', N'Expense', 'COLUMN', N'TRFD_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'میزان حجم ترافیک', 'SCHEMA', N'dbo', 'TABLE', N'Expense', 'COLUMN', N'VOLM_OF_TRFC'
GO
