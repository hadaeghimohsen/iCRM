CREATE TABLE [dbo].[Task]
(
[RQRO_RQST_RQID] [bigint] NULL,
[RQRO_RWNO] [smallint] NULL,
[SERV_FILE_NO] [bigint] NULL,
[SRPB_RWNO_DNRM] [int] NULL,
[SRPB_RECT_CODE_DNRM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COMP_CODE_DNRM] [bigint] NULL,
[TKID] [bigint] NOT NULL IDENTITY(1, 1),
[SUBJ_DESC] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DUE_DATE] [datetime] NULL,
[TASK_CMNT] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TASK_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRCT_VALU_DNRM] [int] NULL,
[DEAD_LINE_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DEAD_LINE] [datetime] NULL,
[ARCH_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_TASK]
   ON  [dbo].[Task]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
    MERGE dbo.Task T
    USING (SELECT * FROM Inserted) S
    ON (t.RQRO_RQST_RQID = s.RQRO_RQST_RQID AND 
        t.RQRO_RWNO = s.RQRO_RWNO AND
        t.TKID = s.TKID)
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
CREATE TRIGGER [dbo].[CG$AUPD_TASK]
   ON  [dbo].[Task]
   AFTER UPDATE   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
    MERGE dbo.Task T
    USING (SELECT * FROM Inserted) S
    ON (t.RQRO_RQST_RQID = s.RQRO_RQST_RQID AND 
        t.RQRO_RWNO = s.RQRO_RWNO AND
        t.TKID = s.TKID)
    WHEN MATCHED THEN
        UPDATE 
           SET T.MDFY_BY = UPPER(SUSER_NAME())
              ,T.MDFY_DATE = GETDATE()
              ,T.COMP_CODE_DNRM = 
               CASE
                  WHEN S.COMP_CODE_DNRM IS NULL THEN (SELECT COMP_CODE FROM dbo.Request_Row WHERE RQST_RQID = S.RQRO_RQST_RQID AND RWNO = S.RQRO_RWNO)
                  ELSE S.COMP_CODE_DNRM
               END
              ,T.PRCT_VALU_DNRM = (
                 SELECT SUM(ISNULL(c.PRCT_VALU_DNRM, 0)) / COUNT(c.CLID)
                   FROM dbo.Collaborator c, Inserted s
                  WHERE c.RQRO_RQST_RQID = s.RQRO_RQST_RQID
              );


              
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
                  ,s.TASK_CMNT AS 'Text'
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
ALTER TABLE [dbo].[Task] ADD CONSTRAINT [PK_Task] PRIMARY KEY CLUSTERED  ([TKID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Task] ADD CONSTRAINT [FK_TASK_COMP] FOREIGN KEY ([COMP_CODE_DNRM]) REFERENCES [dbo].[Company] ([CODE]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Task] ADD CONSTRAINT [FK_TASK_RQRO] FOREIGN KEY ([RQRO_RQST_RQID], [RQRO_RWNO]) REFERENCES [dbo].[Request_Row] ([RQST_RQID], [RWNO]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Task] ADD CONSTRAINT [FK_TASK_SERV] FOREIGN KEY ([SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Task] ADD CONSTRAINT [FK_TASK_SRPB] FOREIGN KEY ([SERV_FILE_NO], [SRPB_RWNO_DNRM], [SRPB_RECT_CODE_DNRM]) REFERENCES [dbo].[Service_Public] ([SERV_FILE_NO], [RWNO], [RECT_CODE])
GO
EXEC sp_addextendedproperty N'MS_Description', N'آیا وظیفه بایگانی شده', 'SCHEMA', N'dbo', 'TABLE', N'Task', 'COLUMN', N'ARCH_STAT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'تاریخ انتهای وظیفه', 'SCHEMA', N'dbo', 'TABLE', N'Task', 'COLUMN', N'DEAD_LINE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'آیا وظیفه انتها دارد', 'SCHEMA', N'dbo', 'TABLE', N'Task', 'COLUMN', N'DEAD_LINE_STAT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'وضعیت انجام وظیفه * باز و در حال انجام * پایان یافته * کنسل شده', 'SCHEMA', N'dbo', 'TABLE', N'Task', 'COLUMN', N'TASK_STAT'
GO
