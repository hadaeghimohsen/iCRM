CREATE TABLE [dbo].[Xcell_Import]
(
[SERV_NO] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FRST_NAME] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LAST_NAME] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POST_ADRS] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CLMN_APBS_COD1] [bigint] NULL,
[CLMN_DSC1] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CLMN_APBS_COD2] [bigint] NULL,
[CLMN_DSC2] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CLMN_APBS_COD3] [bigint] NULL,
[CLMN_DSC3] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CLMN_APBS_COD4] [bigint] NULL,
[CLMN_DSC4] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
