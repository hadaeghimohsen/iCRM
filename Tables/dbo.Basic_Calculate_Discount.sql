CREATE TABLE [dbo].[Basic_Calculate_Discount]
(
[SUNT_BUNT_DEPT_ORGN_CODE] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SUNT_BUNT_DEPT_CODE] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SUNT_BUNT_CODE] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SUNT_CODE] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[REGL_YEAR] [smallint] NOT NULL,
[REGL_CODE] [int] NOT NULL,
[RWNO] [int] NOT NULL CONSTRAINT [DF_Basic_Calculate_Discount_RWNO] DEFAULT ((0)),
[EPIT_CODE] [bigint] NULL,
[AMNT_DSCT] [int] NULL,
[PRCT_DSCT] [int] NULL,
[DSCT_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Basic_Calculate_Discount_STAT] DEFAULT ('002'),
[CRET_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRET_DATE] [datetime] NULL,
[MDFY_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MDFY_DATE] [datetime] NULL,
[ACTN_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSCT_DESC] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FROM_DATE] [date] NULL,
[TO_DATE] [date] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Basic_Calculate_Discount] ADD CONSTRAINT [PK_BCDS] PRIMARY KEY CLUSTERED  ([SUNT_BUNT_DEPT_ORGN_CODE], [SUNT_BUNT_DEPT_CODE], [SUNT_BUNT_CODE], [SUNT_CODE], [REGL_YEAR], [REGL_CODE], [RWNO]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Basic_Calculate_Discount] ADD CONSTRAINT [FK_BCDS_EPIT] FOREIGN KEY ([EPIT_CODE]) REFERENCES [dbo].[Expense_Item] ([CODE])
GO
ALTER TABLE [dbo].[Basic_Calculate_Discount] ADD CONSTRAINT [FK_BCDS_REGL] FOREIGN KEY ([REGL_YEAR], [REGL_CODE]) REFERENCES [dbo].[Regulation] ([YEAR], [CODE]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Basic_Calculate_Discount] ADD CONSTRAINT [FK_BCDS_SUNT] FOREIGN KEY ([SUNT_BUNT_DEPT_ORGN_CODE], [SUNT_BUNT_DEPT_CODE], [SUNT_BUNT_CODE], [SUNT_CODE]) REFERENCES [dbo].[Sub_Unit] ([BUNT_DEPT_ORGN_CODE], [BUNT_DEPT_CODE], [BUNT_CODE], [CODE])
GO
EXEC sp_addextendedproperty N'MS_Description', N'?????? ???????????? ??????????', 'SCHEMA', N'dbo', 'TABLE', N'Basic_Calculate_Discount', 'COLUMN', N'ACTN_TYPE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'?????????? ???????? ??????????', 'SCHEMA', N'dbo', 'TABLE', N'Basic_Calculate_Discount', 'COLUMN', N'AMNT_DSCT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'?????? ??????????', 'SCHEMA', N'dbo', 'TABLE', N'Basic_Calculate_Discount', 'COLUMN', N'DSCT_DESC'
GO
EXEC sp_addextendedproperty N'MS_Description', N'?????? ?????????? ???????????? ??????????(?????????? / ??????????)', 'SCHEMA', N'dbo', 'TABLE', N'Basic_Calculate_Discount', 'COLUMN', N'DSCT_TYPE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'??????????', 'SCHEMA', N'dbo', 'TABLE', N'Basic_Calculate_Discount', 'COLUMN', N'EPIT_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'???? ??????????', 'SCHEMA', N'dbo', 'TABLE', N'Basic_Calculate_Discount', 'COLUMN', N'FROM_DATE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'?????????? ???????? ??????????', 'SCHEMA', N'dbo', 'TABLE', N'Basic_Calculate_Discount', 'COLUMN', N'PRCT_DSCT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'???? ???????? ????????', 'SCHEMA', N'dbo', 'TABLE', N'Basic_Calculate_Discount', 'COLUMN', N'REGL_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'?????? ???????? ????????', 'SCHEMA', N'dbo', 'TABLE', N'Basic_Calculate_Discount', 'COLUMN', N'REGL_YEAR'
GO
EXEC sp_addextendedproperty N'MS_Description', N'????????', 'SCHEMA', N'dbo', 'TABLE', N'Basic_Calculate_Discount', 'COLUMN', N'RWNO'
GO
EXEC sp_addextendedproperty N'MS_Description', N'??????????', 'SCHEMA', N'dbo', 'TABLE', N'Basic_Calculate_Discount', 'COLUMN', N'STAT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'???????????? ????????', 'SCHEMA', N'dbo', 'TABLE', N'Basic_Calculate_Discount', 'COLUMN', N'SUNT_BUNT_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'???? ??????????', 'SCHEMA', N'dbo', 'TABLE', N'Basic_Calculate_Discount', 'COLUMN', N'SUNT_BUNT_DEPT_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'???? ??????????', 'SCHEMA', N'dbo', 'TABLE', N'Basic_Calculate_Discount', 'COLUMN', N'SUNT_BUNT_DEPT_ORGN_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'???????????? ????????', 'SCHEMA', N'dbo', 'TABLE', N'Basic_Calculate_Discount', 'COLUMN', N'SUNT_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'???? ??????????', 'SCHEMA', N'dbo', 'TABLE', N'Basic_Calculate_Discount', 'COLUMN', N'TO_DATE'
GO
