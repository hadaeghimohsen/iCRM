CREATE TABLE [dbo].[Reminder]
(
[RQST_RQID] [bigint] NULL,
[SERV_FILE_NO] [bigint] NULL,
[FROM_JOBP_CODE] [bigint] NULL,
[TO_JOBP_CODE] [bigint] NULL,
[CODE] [bigint] NOT NULL IDENTITY(1, 1),
[READ_RMND] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[READ_NOTF] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ALRM_DATE] [datetime] NULL,
[RECD_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Reminder_RECD_STAT] DEFAULT ('002'),
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
CREATE TRIGGER [dbo].[CG$AINS_RMND]
   ON  [dbo].[Reminder]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Reminder T
   USING (SELECT * FROM Inserted) S
   ON (T.CODE = S.CODE)
   WHEN MATCHED THEN
      UPDATE SET
         T.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE();
   
   -- 1396/03/21 * اگر رخداد جدیدی در جدول یادآوری قرار گرفت باید علامت نرم افزار به صورت قرمز رنگ قرار گیرد     
   UPDATE dbo.Job_Personnel
      SET RMND_STAT = '002'
    WHERE [USER_NAME] = UPPER(SUSER_NAME())
      AND CODE IN (
          SELECT r.TO_JOBP_CODE
            FROM Inserted r
           WHERE r.READ_RMND = '001'
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
CREATE TRIGGER [dbo].[CG$AUPD_RMND]
   ON  [dbo].[Reminder]
   AFTER UPDATE   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Reminder T
   USING (SELECT * FROM Inserted) S
   ON (T.CODE = S.CODE)
   WHEN MATCHED THEN
      UPDATE SET
         T.MDFY_BY = UPPER(SUSER_NAME())
        ,T.MDFY_DATE = GETDATE();
   
   -- 1396/03/22 *  امروز تولد الینا هست به مریم زنگ زدم گفتم ببین چی بخرم براش
   -- بروز رسانی جدول مربوط به پرسنل که نشون بدیم چند پیام خوانده نشده داره
   MERGE dbo.Job_Personnel T
   USING (SELECT * FROM inserted) S
   ON (T.CODE = S.TO_JOBP_CODE)
   WHEN MATCHED THEN
      UPDATE SET 
         T.RMND_NOT_READ_DNRM = (
            SELECT COUNT(*)
              FROM dbo.Reminder r
             WHERE r.TO_JOBP_CODE = S.TO_JOBP_CODE
               AND r.READ_RMND = '001'
         );
   
END
GO
ALTER TABLE [dbo].[Reminder] ADD CONSTRAINT [PK_RMND] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Reminder] ADD CONSTRAINT [FK_RMND_FJBP] FOREIGN KEY ([FROM_JOBP_CODE]) REFERENCES [dbo].[Job_Personnel] ([CODE])
GO
ALTER TABLE [dbo].[Reminder] ADD CONSTRAINT [FK_RMND_RQST] FOREIGN KEY ([RQST_RQID]) REFERENCES [dbo].[Request] ([RQID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Reminder] ADD CONSTRAINT [FK_RMND_SERV] FOREIGN KEY ([SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Reminder] ADD CONSTRAINT [FK_RMND_TJBP] FOREIGN KEY ([TO_JOBP_CODE]) REFERENCES [dbo].[Job_Personnel] ([CODE])
GO
