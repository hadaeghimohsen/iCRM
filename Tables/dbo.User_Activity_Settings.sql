CREATE TABLE [dbo].[User_Activity_Settings]
(
[UAID] [bigint] NOT NULL IDENTITY(1, 1),
[SYS_USER] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACTN_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHOW_ALRM] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SHOW_PRE_ALRM] [time] (0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[User_Activity_Settings] ADD CONSTRAINT [PK_User_Action_Settings] PRIMARY KEY CLUSTERED  ([UAID]) ON [PRIMARY]
GO
