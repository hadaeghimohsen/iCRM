CREATE TABLE [dbo].[Send_File]
(
[RQRO_RQST_RQID] [bigint] NULL,
[RQRO_RWNO] [smallint] NULL,
[SERV_FILE_NO] [bigint] NULL,
[SRPB_RWNO_DNRM] [int] NULL,
[SRPB_RECT_CODE_DNRM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COMP_CODE_DNRM] [bigint] NULL,
[CMNT_CMID] [bigint] NULL,
[SFID] [bigint] NOT NULL IDENTITY(1, 1),
[SUBJ_DESC] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SEND_DATE] [datetime] NULL,
[SEND_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SEND_TYPE] [bigint] NULL,
[SDRC_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FILE_PATH] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHER_TEAM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UPLD_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FILE_SRVR_LINK] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[URL_LINK] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[URL_NAME] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_SNDF]
   ON  [dbo].[Send_File]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
    MERGE dbo.Send_File T
    USING (SELECT * FROM Inserted) S
    ON (t.RQRO_RQST_RQID = s.RQRO_RQST_RQID AND 
        t.RQRO_RWNO = s.RQRO_RWNO AND 
        t.SFID = s.SFID)
    WHEN MATCHED THEN
        UPDATE 
           SET T.CRET_BY = UPPER(SUSER_NAME())
              ,T.CRET_DATE = GETDATE()
              ,T.SRPB_RECT_CODE_DNRM = '004'
              ,T.SRPB_RWNO_DNRM = (SELECT SRPB_RWNO_DNRM FROM Service WHERE FILE_NO = S.SERV_FILE_NO);
              /*t.SERV_FILE_NO = (
                 SELECT SERV_FILE_NO
                   FROM dbo.Request_Row
                  WHERE RQST_RQID = s.RQRO_RQST_RQID
                    AND RWNO = s.RQRO_RWNO
              );*/
        
    
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
CREATE TRIGGER [dbo].[CG$AUPD_SNDF]
   ON  [dbo].[Send_File]
   AFTER UPDATE   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
    MERGE dbo.Send_File T
    USING (SELECT * FROM Inserted) S
    ON (t.RQRO_RQST_RQID = s.RQRO_RQST_RQID AND 
        t.RQRO_RWNO = s.RQRO_RWNO AND 
        t.SFID = s.SFID)
    WHEN MATCHED THEN
        UPDATE 
           SET T.MDFY_BY = UPPER(SUSER_NAME())
              ,T.MDFY_DATE = GETDATE()
              ,T.COMP_CODE_DNRM = 
                  CASE
                     WHEN S.COMP_CODE_DNRM IS NULL THEN (SELECT COMP_CODE FROM dbo.Request_Row WHERE RQST_RQID = S.RQRO_RQST_RQID AND RWNO = S.RQRO_RWNO)
                     ELSE S.COMP_CODE_DNRM
                  END;
   
    -- ساخت اطلاعات یادآوری
    -- 1396/03/20 * برای ثبت ردیف یادآوری درون سیستم از این گزینه استفاده میکنیم    
    IF EXISTS(
       SELECT * 
         FROM Inserted S, dbo.Request r, dbo.Request_Type rt
        WHERE S.RQRO_RQST_RQID = R.RQID
          AND r.RQTP_CODE = Rt.CODE
          AND Rt.RMND_STAT = '002'
    )
    BEGIN
       DECLARE @XP XML;
       SELECT @XP = (
          SELECT R.RQID AS '@rqstrqid'
                ,R.RQTP_CODE AS '@rqtpcode'
                ,R.RQST_STAT AS '@rqststat'
                ,Rr.SERV_FILE_NO AS '@servfileno'
                ,R.JOBP_CODE AS '@jobpcode'
                ,rt.COLB_STAT AS '@colbstat'
            FROM Inserted S, dbo.Request r, dbo.Request_Row rr,dbo.Request_Type rt
           WHERE S.RQRO_RQST_RQID = R.RQID
             AND r.RQID = RR.RQST_RQID
             AND r.RQTP_CODE = rt.CODE
             FOR XML PATH('Reminder')
       );
       EXEC dbo.IUD_RMND_P @X = @XP -- xml
    END

END
GO
ALTER TABLE [dbo].[Send_File] ADD CONSTRAINT [PK_Send_File] PRIMARY KEY CLUSTERED  ([SFID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Send_File] ADD CONSTRAINT [FK_SNDF_CMNT] FOREIGN KEY ([CMNT_CMID]) REFERENCES [dbo].[Comment] ([CMID])
GO
ALTER TABLE [dbo].[Send_File] ADD CONSTRAINT [FK_SNDF_COMP] FOREIGN KEY ([COMP_CODE_DNRM]) REFERENCES [dbo].[Company] ([CODE]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Send_File] ADD CONSTRAINT [FK_SNDF_RQRO] FOREIGN KEY ([RQRO_RQST_RQID], [RQRO_RWNO]) REFERENCES [dbo].[Request_Row] ([RQST_RQID], [RWNO]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Send_File] ADD CONSTRAINT [FK_SNDF_SERV] FOREIGN KEY ([SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Send_File] ADD CONSTRAINT [FK_SNDF_SRPB] FOREIGN KEY ([SERV_FILE_NO], [SRPB_RWNO_DNRM], [SRPB_RECT_CODE_DNRM]) REFERENCES [dbo].[Service_Public] ([SERV_FILE_NO], [RWNO], [RECT_CODE])
GO
EXEC sp_addextendedproperty N'MS_Description', N'مسیر فایل', 'SCHEMA', N'dbo', 'TABLE', N'Send_File', 'COLUMN', N'FILE_PATH'
GO
EXEC sp_addextendedproperty N'MS_Description', N'آدرس فایل سرور', 'SCHEMA', N'dbo', 'TABLE', N'Send_File', 'COLUMN', N'FILE_SRVR_LINK'
GO
EXEC sp_addextendedproperty N'MS_Description', N'فایل ارسالی به مشتری / فایل دریافتی از مشتری', 'SCHEMA', N'dbo', 'TABLE', N'Send_File', 'COLUMN', N'SDRC_TYPE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'تاریخ ارسال', 'SCHEMA', N'dbo', 'TABLE', N'Send_File', 'COLUMN', N'SEND_DATE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'وضعیت ارسال فایل', 'SCHEMA', N'dbo', 'TABLE', N'Send_File', 'COLUMN', N'SEND_STAT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نوع ارسال', 'SCHEMA', N'dbo', 'TABLE', N'Send_File', 'COLUMN', N'SEND_TYPE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ایا این فایل ارسالی به صورت اشتراکی برای بقیه اعضای تیم قابل نمایش باشد؟', 'SCHEMA', N'dbo', 'TABLE', N'Send_File', 'COLUMN', N'SHER_TEAM'
GO
EXEC sp_addextendedproperty N'MS_Description', N'موضوع ارسال فایل', 'SCHEMA', N'dbo', 'TABLE', N'Send_File', 'COLUMN', N'SUBJ_DESC'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نوع مسیر ارسال فایل * سیستم محلی یا آدرس درایو های مجازی اینترنتی', 'SCHEMA', N'dbo', 'TABLE', N'Send_File', 'COLUMN', N'UPLD_TYPE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'آدرس اینترنتی درایو های مجازی', 'SCHEMA', N'dbo', 'TABLE', N'Send_File', 'COLUMN', N'URL_LINK'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نام فایل سرور مجازی', 'SCHEMA', N'dbo', 'TABLE', N'Send_File', 'COLUMN', N'URL_NAME'
GO
