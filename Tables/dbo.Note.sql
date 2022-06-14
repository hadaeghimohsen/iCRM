CREATE TABLE [dbo].[Note]
(
[RQRO_RQST_RQID] [bigint] NULL,
[RQRO_RWNO] [smallint] NULL,
[SERV_FILE_NO] [bigint] NULL,
[SRPB_RWNO_DNRM] [int] NULL,
[SRPB_RECT_CODE_DNRM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COMP_CODE_DNRM] [bigint] NULL,
[MKLT_MLID] [bigint] NULL,
[CAMP_CMID] [bigint] NULL,
[CAMQ_QCID] [bigint] NULL,
[CMPT_CODE] [bigint] NULL,
[CNLN_CLID] [bigint] NULL,
[NTID] [bigint] NOT NULL IDENTITY(1, 1),
[NOTE_DATE] [datetime] NULL,
[NOTE_SUBJ] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NOTE_CMNT] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_NOTE]
   ON  [dbo].[Note]
   AFTER INSERT   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Note T
   USING (SELECT * FROM Inserted) S
   ON (t.NTID = s.NTID)
   WHEN MATCHED THEN
      UPDATE 
         SET T.CRET_BY = UPPER(SUSER_NAME())
            ,t.CRET_DATE = GETDATE()
            ,T.NOTE_DATE = CASE WHEN s.NOTE_DATE IS NULL THEN GETDATE() ELSE s.NOTE_DATE END
            ,T.SRPB_RECT_CODE_DNRM = '004'
            ,T.SRPB_RWNO_DNRM = (SELECT SRPB_RWNO_DNRM FROM service WHERE FILE_NO = S.SERV_FILE_NO);
            /*t.SERV_FILE_NO = (
               SELECT SERV_FILE_NO
                 FROM dbo.Request_Row
                WHERE RQST_RQID = s.RQRO_RQST_RQID
                  AND rwno = s.RQRO_RWNO
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
CREATE TRIGGER [dbo].[CG$AUPD_NOTE]
   ON  [dbo].[Note]
   AFTER UPDATE   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Note T
   USING (SELECT * FROM Inserted) S
   ON (t.NTID = s.NTID)
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
   
   UPDATE dbo.Mention
      SET MDFY_STAT = '002'
    WHERE EXISTS(
      SELECT *
        FROM Inserted s
       WHERE s.RQRO_RQST_RQID = dbo.Mention.RQST_RQID
    );
   -- Check Mentioned User
   DECLARE @X XML;
   SELECT @X = (
      SELECT (
            SELECT s.RQRO_RQST_RQID AS '@rqid'
                  ,s.SERV_FILE_NO AS '@fileno'
                  ,s.NOTE_CMNT AS 'Text'
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
ALTER TABLE [dbo].[Note] ADD CONSTRAINT [PK_Note] PRIMARY KEY CLUSTERED  ([NTID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Note] ADD CONSTRAINT [FK_NOTE_CAMP] FOREIGN KEY ([CAMP_CMID]) REFERENCES [dbo].[Campaign] ([CMID])
GO
ALTER TABLE [dbo].[Note] ADD CONSTRAINT [FK_NOTE_CAMQ] FOREIGN KEY ([CAMQ_QCID]) REFERENCES [dbo].[Campaign_Quick] ([QCID])
GO
ALTER TABLE [dbo].[Note] ADD CONSTRAINT [FK_NOTE_CMPT] FOREIGN KEY ([CMPT_CODE]) REFERENCES [dbo].[Company] ([CODE])
GO
ALTER TABLE [dbo].[Note] ADD CONSTRAINT [FK_NOTE_CNLN] FOREIGN KEY ([CNLN_CLID]) REFERENCES [dbo].[Contract_Line] ([CLID])
GO
ALTER TABLE [dbo].[Note] ADD CONSTRAINT [FK_NOTE_COMP] FOREIGN KEY ([COMP_CODE_DNRM]) REFERENCES [dbo].[Company] ([CODE]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Note] ADD CONSTRAINT [FK_NOTE_MKLT] FOREIGN KEY ([MKLT_MLID]) REFERENCES [dbo].[Marketing_List] ([MLID])
GO
ALTER TABLE [dbo].[Note] ADD CONSTRAINT [FK_NOTE_RQRO] FOREIGN KEY ([RQRO_RQST_RQID], [RQRO_RWNO]) REFERENCES [dbo].[Request_Row] ([RQST_RQID], [RWNO]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Note] ADD CONSTRAINT [FK_NOTE_SERV] FOREIGN KEY ([SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Note] ADD CONSTRAINT [FK_NOTE_SRPB] FOREIGN KEY ([SERV_FILE_NO], [SRPB_RWNO_DNRM], [SRPB_RECT_CODE_DNRM]) REFERENCES [dbo].[Service_Public] ([SERV_FILE_NO], [RWNO], [RECT_CODE])
GO
