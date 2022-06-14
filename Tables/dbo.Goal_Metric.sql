CREATE TABLE [dbo].[Goal_Metric]
(
[GMID] [bigint] NOT NULL,
[NAME] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MTRC_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AMNT_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRAC_TRGT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CMNT] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRET_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRET_DATE] [datetime] NULL,
[MDFY_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MDFY_DATE] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Goal_Metric] ADD CONSTRAINT [PK_Goal_Metric] PRIMARY KEY CLUSTERED  ([GMID]) ON [PRIMARY]
GO
