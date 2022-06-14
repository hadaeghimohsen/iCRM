CREATE TABLE [dbo].[Goal_Metric_Rollup_Field]
(
[GLMT_GMID] [bigint] NULL,
[RFID] [bigint] NOT NULL,
[TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SORC_RECD_TYPE] [bigint] NULL,
[SORC_RECD_TYPE_STAT] [bigint] NULL,
[SORC_RECD_TYPE_STUS] [bigint] NULL,
[SORC_RECD_TYPE_DATE] [bigint] NULL,
[CRET_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRET_DATE] [datetime] NULL,
[MDFY_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MDFY_DATE] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Goal_Metric_Rollup_Field] ADD CONSTRAINT [PK_Rollup_Field] PRIMARY KEY CLUSTERED  ([RFID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Goal_Metric_Rollup_Field] ADD CONSTRAINT [FK_GMRF_GLMT] FOREIGN KEY ([GLMT_GMID]) REFERENCES [dbo].[Goal_Metric] ([GMID])
GO
