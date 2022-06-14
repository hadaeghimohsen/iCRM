CREATE TABLE [dbo].[Email]
(
[RQRO_RQST_RQID] [bigint] NULL,
[RQRO_RWNO] [smallint] NULL,
[SERV_FILE_NO] [bigint] NULL,
[SRPB_RWNO_DNRM] [int] NULL,
[SRPB_RECT_CODE_DNRM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COMP_CODE_DNRM] [bigint] NULL,
[EMID] [bigint] NOT NULL IDENTITY(1, 1),
[FROM_MAIL] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUBJ_DESC] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMAL_CMNT] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SEND_DATE] [datetime] NULL,
[SEND_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MAIL_ITEM_NO] [bigint] NULL,
[CRET_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRET_DATE] [datetime] NULL,
[MDFY_BY] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_EMAL]
   ON  [dbo].[Email]
   AFTER INSERT
AS 
BEGIN
	MERGE dbo.Email T
	USING (SELECT * FROM Inserted) S
	ON(T.RQRO_RQST_RQID = S.RQRO_RQST_RQID AND 
	   T.RQRO_RWNO = S.RQRO_RWNO AND
	   T.EMID = S.EMID)
	WHEN MATCHED THEN
      UPDATE SET
             T.CRET_BY = UPPER(SUSER_NAME()),
             T.CRET_DATE = GETDATE(),
             T.SRPB_RECT_CODE_DNRM = '004',
             T.SRPB_RWNO_DNRM = (
               SELECT SRPB_RWNO_DNRM FROM dbo.Service WHERE FILE_NO = S.SERV_FILE_NO                 
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
CREATE TRIGGER [dbo].[CG$AUPD_EMAL]
   ON  [dbo].[Email]
   AFTER UPDATE
AS 
BEGIN
	MERGE dbo.Email T
	USING (SELECT * FROM Inserted) S
	ON(T.RQRO_RQST_RQID = S.RQRO_RQST_RQID AND 
	   T.RQRO_RWNO = S.RQRO_RWNO AND
	   T.EMID = S.EMID)
	WHEN MATCHED THEN
      UPDATE SET
          T.MDFY_BY = UPPER(SUSER_NAME()),
          T.MDFY_DATE = GETDATE(),
          T.COMP_CODE_DNRM = 
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
   
   -- Check Mentioned User
   DECLARE @X XML;
   SELECT @X = (
      SELECT (
            SELECT s.RQRO_RQST_RQID AS '@rqid'
                  ,s.SERV_FILE_NO AS '@fileno'
                  ,s.EMAL_CMNT AS 'Text'
              FROM Inserted s
               FOR XML PATH('Mention'), TYPE
         )
         FOR XML PATH('Mentions')
   );
   EXEC SET_MNTN_P @X = @X;
   
   DELETE dbo.Mention
    WHERE EXISTS(
      SELECT * 
        FROM Inserted s
       WHERE s.RQRO_RQST_RQID = dbo.Mention.RQST_RQID
    )
    AND MDFY_STAT = '002';
END
GO
ALTER TABLE [dbo].[Email] ADD CONSTRAINT [PK_EMAL] PRIMARY KEY CLUSTERED  ([EMID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Email] ADD CONSTRAINT [FK_EMAL_COMP] FOREIGN KEY ([COMP_CODE_DNRM]) REFERENCES [dbo].[Company] ([CODE])
GO
ALTER TABLE [dbo].[Email] ADD CONSTRAINT [FK_EMAL_RQRO] FOREIGN KEY ([RQRO_RQST_RQID], [RQRO_RWNO]) REFERENCES [dbo].[Request_Row] ([RQST_RQID], [RWNO])
GO
ALTER TABLE [dbo].[Email] ADD CONSTRAINT [FK_EMAL_SERV] FOREIGN KEY ([SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO])
GO
ALTER TABLE [dbo].[Email] ADD CONSTRAINT [FK_EMAL_SRPB] FOREIGN KEY ([SERV_FILE_NO], [SRPB_RWNO_DNRM], [SRPB_RECT_CODE_DNRM]) REFERENCES [dbo].[Service_Public] ([SERV_FILE_NO], [RWNO], [RECT_CODE])
GO
EXEC sp_addextendedproperty N'MS_Description', N'کد ایمیل ارسال شده توسط ایمیل سرور پایگاه داده', 'SCHEMA', N'dbo', 'TABLE', N'Email', 'COLUMN', N'MAIL_ITEM_NO'
GO
EXEC sp_addextendedproperty N'MS_Description', N'آیا ایمیل ارسال شده', 'SCHEMA', N'dbo', 'TABLE', N'Email', 'COLUMN', N'SEND_STAT'
GO
