CREATE TABLE [dbo].[Message]
(
[RQRO_RQST_RQID] [bigint] NULL,
[RQRO_RWNO] [smallint] NULL,
[SERV_FILE_NO] [bigint] NULL,
[SRPB_RWNO_DNRM] [int] NULL,
[SRPB_RECT_CODE_DNRM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COMP_CODE_DNRM] [bigint] NULL,
[MSID] [bigint] NOT NULL IDENTITY(1, 1),
[MESG_DATE] [datetime] NULL,
[MESG_CMNT] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CELL_PHON] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MESG_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MESG_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SEND_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MBST_MBID] [bigint] NULL,
[SMSC_CODE] [bigint] NULL,
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
CREATE  TRIGGER [dbo].[CG$AINS_MESG]
   ON  [dbo].[Message]
   AFTER INSERT   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Message T
   USING (SELECT * FROM Inserted) S
   ON (t.RQRO_RQST_RQID = s.RQRO_RQST_RQID AND 
       t.RQRO_RWNO = s.RQRO_RWNO AND 
       t.MSID = s.MSID)
   WHEN MATCHED THEN
      UPDATE 
         SET T.CRET_BY = UPPER(SUSER_NAME())
            ,t.CRET_DATE = GETDATE()
            ,T.SRPB_RECT_CODE_DNRM = '004',
             T.SRPB_RWNO_DNRM = (
               SELECT SRPB_RWNO_DNRM FROM dbo.Service WHERE FILE_NO = S.SERV_FILE_NO                 
             )
            ,T.MBST_MBID = (SELECT MBID FROM dbo.V#Message_Broad_Settings WHERE DFLT_STAT = '002' );
      
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
CREATE  TRIGGER [dbo].[CG$AUPD_MESG]
   ON  [dbo].[Message]
   AFTER UPDATE   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Message T
   USING (SELECT * FROM Inserted) S
   ON (t.RQRO_RQST_RQID = s.RQRO_RQST_RQID AND 
       t.RQRO_RWNO = s.RQRO_RWNO AND 
       t.MSID = s.MSID)
   WHEN MATCHED THEN
      UPDATE 
         SET T.MDFY_BY = UPPER(SUSER_NAME())
            ,T.MDFY_DATE = GETDATE()
            ,T.COMP_CODE_DNRM = 
               CASE
                  WHEN S.COMP_CODE_DNRM IS NULL THEN (SELECT COMP_CODE FROM dbo.Request_Row WHERE RQST_RQID = S.RQRO_RQST_RQID AND RWNO = S.RQRO_RWNO)
                  ELSE S.COMP_CODE_DNRM
               END;
               
   -- Check Mentioned User
   DECLARE @X XML;
   SELECT @X = (
      SELECT (
            SELECT s.RQRO_RQST_RQID AS '@rqid'
                  ,s.SERV_FILE_NO AS '@fileno'
                  ,s.MESG_CMNT AS 'Text'
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
ALTER TABLE [dbo].[Message] ADD CONSTRAINT [PK_MESG] PRIMARY KEY CLUSTERED  ([MSID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Message] ADD CONSTRAINT [FK_MESG_COMP] FOREIGN KEY ([COMP_CODE_DNRM]) REFERENCES [dbo].[Company] ([CODE]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Message] ADD CONSTRAINT [FK_MESG_RQRO] FOREIGN KEY ([RQRO_RQST_RQID], [RQRO_RWNO]) REFERENCES [dbo].[Request_Row] ([RQST_RQID], [RWNO]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Message] ADD CONSTRAINT [FK_MESG_SERV] FOREIGN KEY ([SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Message] ADD CONSTRAINT [FK_MESG_SRPB] FOREIGN KEY ([SERV_FILE_NO], [SRPB_RWNO_DNRM], [SRPB_RECT_CODE_DNRM]) REFERENCES [dbo].[Service_Public] ([SERV_FILE_NO], [RWNO], [RECT_CODE])
GO
EXEC sp_addextendedproperty N'MS_Description', N'اطلاعات مربوط به سامانه ارسال پیامکی', 'SCHEMA', N'dbo', 'TABLE', N'Message', 'COLUMN', N'MBST_MBID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'ایا پیامک از طریق سامانه ارسال پیامک گذشته و ارسال شده یا خیر', 'SCHEMA', N'dbo', 'TABLE', N'Message', 'COLUMN', N'SEND_STAT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'کد برگشتی از سامانه SmsCall.ir', 'SCHEMA', N'dbo', 'TABLE', N'Message', 'COLUMN', N'SMSC_CODE'
GO
