CREATE TABLE [dbo].[Company_Activity]
(
[COMP_CODE] [bigint] NULL,
[ISCP_ISCA_ISCG_CODE] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ISCP_ISCA_CODE] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ISCP_CODE] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CODE] [bigint] NOT NULL,
[DESC] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_CMAC]
   ON  [dbo].[Company_Activity]
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
   
   MERGE dbo.Company_Activity T
   USING (SELECT * FROM INSERTED) S
   ON (T.COMP_CODE = S.COMP_CODE AND
       T.CODE      = S.CODE)
   WHEN MATCHED THEN
      UPDATE
         SET CRET_BY   = UPPER(SUSER_NAME())
            ,CRET_DATE = GETDATE()
            ,CODE      = dbo.Gnrt_Nvid_U();
END
;
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[CG$AUPD_CMAC]
   ON  [dbo].[Company_Activity]
   AFTER UPDATE   
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
   
   MERGE dbo.Company_Activity T
   USING (SELECT * FROM INSERTED) S
   ON (T.COMP_CODE = S.COMP_CODE AND
       T.CODE      = S.CODE)
   WHEN MATCHED THEN
      UPDATE
         SET MDFY_BY   = UPPER(SUSER_NAME())
            ,MDFY_DATE = GETDATE();
END
;
GO
ALTER TABLE [dbo].[Company_Activity] ADD CONSTRAINT [PK_CMAC] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Company_Activity] ADD CONSTRAINT [FK_CMAC_COMP] FOREIGN KEY ([COMP_CODE]) REFERENCES [dbo].[Company] ([CODE]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Company_Activity] ADD CONSTRAINT [FK_CMAC_ISCP] FOREIGN KEY ([ISCP_ISCA_ISCG_CODE], [ISCP_ISCA_CODE], [ISCP_CODE]) REFERENCES [dbo].[Isic_Product] ([ISCA_ISCG_CODE], [ISCA_CODE], [CODE])
GO
