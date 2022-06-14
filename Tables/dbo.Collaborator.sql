CREATE TABLE [dbo].[Collaborator]
(
[RQRO_RQST_RQID] [bigint] NULL,
[RQRO_RWNO] [smallint] NULL,
[SERV_FILE_NO] [bigint] NULL,
[JOBP_CODE] [bigint] NULL,
[CLID] [bigint] NOT NULL IDENTITY(1, 1),
[COLB_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COLB_DESC] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRCT_VALU_DNRM] [int] NULL,
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
CREATE TRIGGER [dbo].[CG$ADEL_COLB]
   ON  [dbo].[Collaborator]
   AFTER DELETE
AS 
BEGIN
   -- حذف کردن اطلاعات یاداوری برای کاربر  
  DELETE R
    FROM dbo.Reminder R, Deleted S
   WHERE R.RQST_RQID = S.RQRO_RQST_RQID
     AND R.TO_JOBP_CODE = S.JOBP_CODE;
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
CREATE TRIGGER [dbo].[CG$AINS_COLB]
   ON  [dbo].[Collaborator]
   AFTER INSERT   
AS 
BEGIN
	MERGE dbo.Collaborator T
	USING (SELECT * FROM Inserted) S
	ON (T.RQRO_RQST_RQID = S.RQRO_RQST_RQID AND 
	    T.RQRO_RWNO = S.RQRO_RWNO AND 
	    t.CLID = s.CLID
	)
	WHEN MATCHED THEN
	   UPDATE 
	      SET T.CRET_BY = UPPER(SUSER_NAME())
	         ,T.CRET_DATE = GETDATE();
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
CREATE TRIGGER [dbo].[CG$AUPD_COLB]
   ON  [dbo].[Collaborator]
   AFTER UPDATE 
AS 
BEGIN
	MERGE dbo.Collaborator T
	USING (SELECT * FROM Inserted) S
	ON (T.RQRO_RQST_RQID = S.RQRO_RQST_RQID AND 
	    T.RQRO_RWNO = S.RQRO_RWNO AND 
	    T.CLID = S.CLID
	)
	WHEN MATCHED THEN
	   UPDATE 
	      SET T.MDFY_BY = UPPER(SUSER_NAME())
	         ,T.MDFY_DATE = GETDATE();
END
GO
ALTER TABLE [dbo].[Collaborator] ADD CONSTRAINT [PK_COLB] PRIMARY KEY CLUSTERED  ([CLID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Collaborator] ADD CONSTRAINT [FK_COLB_JOBP] FOREIGN KEY ([JOBP_CODE]) REFERENCES [dbo].[Job_Personnel] ([CODE])
GO
ALTER TABLE [dbo].[Collaborator] ADD CONSTRAINT [FK_COLB_RQRO] FOREIGN KEY ([RQRO_RQST_RQID], [RQRO_RWNO]) REFERENCES [dbo].[Request_Row] ([RQST_RQID], [RWNO]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Collaborator] ADD CONSTRAINT [FK_COLB_SERV] FOREIGN KEY ([SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO]) ON DELETE CASCADE
GO
EXEC sp_addextendedproperty N'MS_Description', N'شرح و نتیجه همکاری', 'SCHEMA', N'dbo', 'TABLE', N'Collaborator', 'COLUMN', N'COLB_DESC'
GO
EXEC sp_addextendedproperty N'MS_Description', N'وضعیت همکاری', 'SCHEMA', N'dbo', 'TABLE', N'Collaborator', 'COLUMN', N'COLB_STAT'
GO
