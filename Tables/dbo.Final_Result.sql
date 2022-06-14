CREATE TABLE [dbo].[Final_Result]
(
[RQRO_RQST_RQID] [bigint] NULL,
[RQRO_RWNO] [smallint] NULL,
[SERV_FILE_NO] [bigint] NULL,
[SRPB_RWNO_DNRM] [int] NULL,
[SRPB_RECT_CODE_DNRM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COMP_CODE_DNRM] [bigint] NULL,
[FRID] [bigint] NOT NULL IDENTITY(1, 1),
[FINR_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FINR_CMNT] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRET_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRET_DATE] [datetime] NULL,
[MDFY_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MDFY_DATE] [datetime] NULL,
[FINR_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FINR_TYPE_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
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
CREATE TRIGGER [dbo].[CG$AINS_FINR]
   ON  [dbo].[Final_Result]
   AFTER INSERT
AS 
BEGIN
	MERGE dbo.Final_Result T
	USING (SELECT * FROM Inserted) S
	ON(T.RQRO_RQST_RQID = S.RQRO_RQST_RQID AND 
	   T.RQRO_RWNO = S.RQRO_RWNO AND
	   T.FRID = S.FRID)
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
CREATE TRIGGER [dbo].[CG$AUPD_FINR]
   ON  [dbo].[Final_Result]
   AFTER UPDATE
AS 
BEGIN
	MERGE dbo.Final_Result T
	USING (SELECT * FROM Inserted) S
	ON(T.RQRO_RQST_RQID = S.RQRO_RQST_RQID AND 
	   T.RQRO_RWNO = S.RQRO_RWNO AND
	   T.FRID = S.FRID)
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
   
END
GO
ALTER TABLE [dbo].[Final_Result] ADD CONSTRAINT [PK_FINR] PRIMARY KEY CLUSTERED  ([FRID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Final_Result] ADD CONSTRAINT [FK_FINR_COMP] FOREIGN KEY ([COMP_CODE_DNRM]) REFERENCES [dbo].[Company] ([CODE]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Final_Result] ADD CONSTRAINT [FK_FINR_RQRO] FOREIGN KEY ([RQRO_RQST_RQID], [RQRO_RWNO]) REFERENCES [dbo].[Request_Row] ([RQST_RQID], [RWNO]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Final_Result] ADD CONSTRAINT [FK_FINR_SERV] FOREIGN KEY ([SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Final_Result] ADD CONSTRAINT [FK_FINR_SRPB] FOREIGN KEY ([SERV_FILE_NO], [SRPB_RWNO_DNRM], [SRPB_RECT_CODE_DNRM]) REFERENCES [dbo].[Service_Public] ([SERV_FILE_NO], [RWNO], [RECT_CODE])
GO
EXEC sp_addextendedproperty N'MS_Description', N'دلیل ارتباط', 'SCHEMA', N'dbo', 'TABLE', N'Final_Result', 'COLUMN', N'FINR_TYPE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'نتجیه دلیل ارتباط', 'SCHEMA', N'dbo', 'TABLE', N'Final_Result', 'COLUMN', N'FINR_TYPE_STAT'
GO
