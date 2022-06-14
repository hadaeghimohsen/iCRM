CREATE TABLE [dbo].[Personnel_Access_Service_Type]
(
[JOBP_CODE] [bigint] NULL,
[SERV_FILE_NO_DNRM] [bigint] NULL,
[USER_NAME_DNRM] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SRTP_CODE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PAID] [bigint] NOT NULL,
[RECD_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_PAST]
   ON  [dbo].[Personnel_Access_Service_Type]
   AFTER INSERT   
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Personnel_Access_Service_Type T
   USING (SELECT * FROM Inserted) S
   ON (T.JOBP_CODE = S.JOBP_CODE AND
       T.SRTP_CODE = S.SRTP_CODE AND
       T.PAID = S.PAID)
   WHEN MATCHED THEN
      UPDATE SET
         T.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE()
        ,T.PAID = dbo.GNRT_NVID_U()
        ,T.SERV_FILE_NO_DNRM = (SELECT jp.SERV_FILE_NO FROM dbo.Job_Personnel jp WHERE jp.CODE = s.JOBP_CODE)
        ,t.USER_NAME_DNRM = (SELECT jp.USER_NAME FROM dbo.Job_Personnel jp WHERE jp.CODE = s.JOBP_CODE)
        ,T.RECD_STAT = '002';
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
CREATE TRIGGER [dbo].[CG$AUPD_PAST]
   ON  [dbo].[Personnel_Access_Service_Type]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
   MERGE dbo.Personnel_Access_Service_Type T
   USING (SELECT * FROM Inserted) S
   ON (T.PAID = S.PAID)
   WHEN MATCHED THEN
      UPDATE SET
         T.MDFY_BY = UPPER(SUSER_NAME())
        ,T.MDFY_DATE = GETDATE();
END
GO
ALTER TABLE [dbo].[Personnel_Access_Service_Type] ADD CONSTRAINT [PK_PAST] PRIMARY KEY CLUSTERED  ([PAID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Personnel_Access_Service_Type] ADD CONSTRAINT [FK_PAST_JOBP] FOREIGN KEY ([JOBP_CODE]) REFERENCES [dbo].[Job_Personnel] ([CODE]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Personnel_Access_Service_Type] ADD CONSTRAINT [FK_PAST_SERV] FOREIGN KEY ([SERV_FILE_NO_DNRM]) REFERENCES [dbo].[Service] ([FILE_NO]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Personnel_Access_Service_Type] ADD CONSTRAINT [FK_PAST_SRTP] FOREIGN KEY ([SRTP_CODE]) REFERENCES [dbo].[Service_Type] ([CODE]) ON DELETE CASCADE
GO
