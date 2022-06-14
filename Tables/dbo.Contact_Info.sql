CREATE TABLE [dbo].[Contact_Info]
(
[COMP_CODE] [bigint] NULL,
[SERV_FILE_NO] [bigint] NULL,
[APBS_CODE] [bigint] NULL,
[CODE] [bigint] NOT NULL,
[CONT_DESC] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
create TRIGGER [dbo].[CG$AINS_CTIF]
   ON  [dbo].[Contact_Info]
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
   
   MERGE dbo.Contact_Info T
   USING (SELECT * FROM INSERTED) S
   ON (T.CODE      = S.CODE)
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
create TRIGGER [dbo].[CG$AUPD_CTIF]
   ON  [dbo].[Contact_Info]
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
   
   MERGE dbo.Contact_Info T
   USING (SELECT * FROM INSERTED) S
   ON (T.CODE      = S.CODE)
   WHEN MATCHED THEN
      UPDATE
         SET MDFY_BY   = UPPER(SUSER_NAME())
            ,MDFY_DATE = GETDATE();
END
;
GO
ALTER TABLE [dbo].[Contact_Info] ADD CONSTRAINT [PK_SRVC] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Contact_Info] ADD CONSTRAINT [FK_SRVC_APBS] FOREIGN KEY ([APBS_CODE]) REFERENCES [dbo].[App_Base_Define] ([CODE])
GO
ALTER TABLE [dbo].[Contact_Info] ADD CONSTRAINT [FK_SRVC_COMP] FOREIGN KEY ([COMP_CODE]) REFERENCES [dbo].[Company] ([CODE]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Contact_Info] ADD CONSTRAINT [FK_SRVC_SERV] FOREIGN KEY ([SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO]) ON DELETE CASCADE
GO
