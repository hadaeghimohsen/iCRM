CREATE TABLE [dbo].[Weekday_Info]
(
[COMP_CODE] [bigint] NULL,
[SERV_FILE_NO] [bigint] NULL,
[CODE] [bigint] NOT NULL CONSTRAINT [DF_Service_Weekday_CODE] DEFAULT ((0)),
[WEEK_DAY] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STRT_TIME] [datetime] NULL,
[END_TIME] [datetime] NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_WKIF]
   ON  [dbo].[Weekday_Info]
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
   
   MERGE dbo.Weekday_Info T
   USING (SELECT * FROM INSERTED) S
   ON (T.CODE      = S.CODE)
   WHEN MATCHED THEN
      UPDATE
         SET CRET_BY   = UPPER(SUSER_NAME())
            ,CRET_DATE = GETDATE()
            ,CODE      = dbo.GNRT_NVID_U();
END
;
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create TRIGGER [dbo].[CG$AUPD_WKIF]
   ON  [dbo].[Weekday_Info]
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
   
   MERGE dbo.Weekday_Info T
   USING (SELECT * FROM INSERTED) S
   ON (T.CODE      = S.CODE)
   WHEN MATCHED THEN
      UPDATE
         SET MDFY_BY   = UPPER(SUSER_NAME())
            ,MDFY_DATE = GETDATE();
END
;
GO
ALTER TABLE [dbo].[Weekday_Info] ADD CONSTRAINT [PK_SRVW] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Weekday_Info] ADD CONSTRAINT [FK_WKIF_COMP] FOREIGN KEY ([COMP_CODE]) REFERENCES [dbo].[Company] ([CODE]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Weekday_Info] ADD CONSTRAINT [FK_WKIF_SERV] FOREIGN KEY ([SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO]) ON DELETE CASCADE
GO
