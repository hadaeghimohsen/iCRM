CREATE TABLE [dbo].[Mention]
(
[RQST_RQID] [bigint] NULL,
[SERV_FILE_NO] [bigint] NULL,
[JOBP_CODE] [bigint] NULL,
[CODE] [bigint] NOT NULL CONSTRAINT [DF_Mention_CODE] DEFAULT ((0)),
[READ_MNTN] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[READ_NOTF] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MNTN_DATE] [datetime] NULL,
[MDFY_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[CG$AINS_MNTN]
   ON  [dbo].[Mention]
   AFTER INSERT   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Mention T
   USING (SELECT * FROM Inserted) S
   ON (T.CODE = S.CODE)
   WHEN MATCHED THEN
      UPDATE SET
         T.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE()
        ,T.CODE = dbo.GNRT_NVID_U();
   
   
   -- 1396/04/29 * اگر رخداد جدیدی در جدول یادآوری قرار گرفت باید علامت نرم افزار به صورت قرمز رنگ قرار گیرد     
   UPDATE dbo.Job_Personnel
      SET MNTN_STAT = '002'
    WHERE [USER_NAME] = UPPER(SUSER_NAME())
      AND CODE IN (
          SELECT r.JOBP_CODE
            FROM Inserted r
           WHERE r.READ_MNTN = '001'
    );
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[CG$AUPD_MNTN]
   ON  [dbo].[Mention]
   AFTER UPDATE  
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Mention T
   USING (SELECT * FROM Inserted) S
   ON (T.CODE = S.CODE)
   WHEN MATCHED THEN
      UPDATE SET
         T.MDFY_BY = UPPER(SUSER_NAME())
        ,T.MDFY_DATE = GETDATE();
   
   -- 1396/04/29 *  امروز 9 روز از تولد آدرین گذشته و ساعت 12 شب هست و الینا و مادرش دارن با آدرین بازی میکنن و پشت کمرشون گذاشتن و گاراش بعد شیر خوردن رو دارن می گیرن. آدرین هم داره سکسکه میکنه.
   -- بروز رسانی جدول مربوط به پرسنل که نشون بدیم چند پیام خوانده نشده داره
   MERGE dbo.Job_Personnel T
   USING (SELECT * FROM inserted) S
   ON (T.CODE = S.JOBP_CODE)
   WHEN MATCHED THEN
      UPDATE SET 
         T.MNTN_NOT_READ_DNRM = (
            SELECT COUNT(*)
              FROM dbo.Mention r
             WHERE r.JOBP_CODE = S.JOBP_CODE
               AND r.READ_MNTN = '001'
         );
END
GO
ALTER TABLE [dbo].[Mention] ADD CONSTRAINT [PK_Mention] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Mention] ADD CONSTRAINT [FK_MNTN_JOBP] FOREIGN KEY ([JOBP_CODE]) REFERENCES [dbo].[Job_Personnel] ([CODE])
GO
ALTER TABLE [dbo].[Mention] ADD CONSTRAINT [FK_MNTN_RQST] FOREIGN KEY ([RQST_RQID]) REFERENCES [dbo].[Request] ([RQID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Mention] ADD CONSTRAINT [FK_MNTN_SERV] FOREIGN KEY ([SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO]) ON DELETE CASCADE
GO
