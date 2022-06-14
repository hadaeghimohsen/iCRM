CREATE TABLE [dbo].[Goal]
(
[GOAL_GLID] [bigint] NULL,
[GLID] [bigint] NOT NULL,
[NAME] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GLMT_GMID] [bigint] NULL,
[OWNR_CODE] [bigint] NULL,
[MANG_CODE] [bigint] NULL,
[CYCL_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FROM_REGL_YEAR] [smallint] NULL,
[FROM_REGL_CODE] [int] NULL,
[TO_REGL_YEAR] [smallint] NULL,
[TO_REGL_CODE] [int] NULL,
[FROM_DATE] [date] NULL,
[TO_DATE] [date] NULL,
[MONY_VALU] [bigint] NULL,
[EXTN_MONY_INDX] [bigint] NULL,
[CONT_VALU] [bigint] NULL,
[EXTN_CONT_INDX] [bigint] NULL,
[FLOT_VALU] [float] NULL,
[EXTN_FLOT_INDX] [float] NULL,
[ACTL_WORK_VALU] [float] NULL,
[INPR_WORK_VALU] [float] NULL,
[CUSF_WORK_VALU] [float] NULL,
[PRCT_WORK_VALU] [float] NULL,
[LAST_CALC_DATE] [datetime] NULL,
[CALC_CHLD_GOAL_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FTCH_OWNR_RECD_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACTL_RLUP_QURY] [bigint] NULL,
[INPR_RULP_QURY] [bigint] NULL,
[CUST_RLUP_QURY] [bigint] NULL,
[STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRET_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRET_DATE] [datetime] NULL,
[MDFY_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MDFY_DATE] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Goal] ADD CONSTRAINT [PK_Goal] PRIMARY KEY CLUSTERED  ([GLID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Goal] ADD CONSTRAINT [FK_GOAL_FRGL] FOREIGN KEY ([FROM_REGL_YEAR], [FROM_REGL_CODE]) REFERENCES [dbo].[Regulation] ([YEAR], [CODE])
GO
ALTER TABLE [dbo].[Goal] ADD CONSTRAINT [FK_GOAL_GLMT] FOREIGN KEY ([GLMT_GMID]) REFERENCES [dbo].[Goal_Metric] ([GMID])
GO
ALTER TABLE [dbo].[Goal] ADD CONSTRAINT [FK_GOAL_GOAL] FOREIGN KEY ([GOAL_GLID]) REFERENCES [dbo].[Goal] ([GLID])
GO
ALTER TABLE [dbo].[Goal] ADD CONSTRAINT [FK_GOAL_JBPR] FOREIGN KEY ([OWNR_CODE]) REFERENCES [dbo].[Job_Personnel] ([CODE])
GO
ALTER TABLE [dbo].[Goal] ADD CONSTRAINT [FK_GOAL_MJBP] FOREIGN KEY ([MANG_CODE]) REFERENCES [dbo].[Job_Personnel] ([CODE])
GO
ALTER TABLE [dbo].[Goal] ADD CONSTRAINT [FK_GOAL_PGOL] FOREIGN KEY ([GOAL_GLID]) REFERENCES [dbo].[Goal] ([GLID])
GO
ALTER TABLE [dbo].[Goal] ADD CONSTRAINT [FK_GOAL_TRGL] FOREIGN KEY ([TO_REGL_YEAR], [TO_REGL_CODE]) REFERENCES [dbo].[Regulation] ([YEAR], [CODE])
GO
EXEC sp_addextendedproperty N'MS_Description', N'اطلاعات واقعی به دست آمده', 'SCHEMA', N'dbo', 'TABLE', N'Goal', 'COLUMN', N'ACTL_WORK_VALU'
GO
EXEC sp_addextendedproperty N'MS_Description', N'انتخاب کنید که آیا داده ها تنها باید از اهداف فرزند جمع آوری شوند', 'SCHEMA', N'dbo', 'TABLE', N'Goal', 'COLUMN', N'CALC_CHLD_GOAL_STAT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'اطلاعات فیلد سفارشی معیار جستجو', 'SCHEMA', N'dbo', 'TABLE', N'Goal', 'COLUMN', N'CUSF_WORK_VALU'
GO
EXEC sp_addextendedproperty N'MS_Description', N'انتخاب کنید که آیا فقط رکورد های مالکان هدف ، یا تمامی رکوردها، می بایست برای نتایج هدف جمع آوری شود', 'SCHEMA', N'dbo', 'TABLE', N'Goal', 'COLUMN', N'FTCH_OWNR_RECD_STAT'
GO
EXEC sp_addextendedproperty N'MS_Description', N'معیار ارزیابی هدف', 'SCHEMA', N'dbo', 'TABLE', N'Goal', 'COLUMN', N'GLMT_GMID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'هدف پدر', 'SCHEMA', N'dbo', 'TABLE', N'Goal', 'COLUMN', N'GOAL_GLID'
GO
EXEC sp_addextendedproperty N'MS_Description', N'اطلاعات در حال پیشرفت به دست آمده', 'SCHEMA', N'dbo', 'TABLE', N'Goal', 'COLUMN', N'INPR_WORK_VALU'
GO
EXEC sp_addextendedproperty N'MS_Description', N'مدیر', 'SCHEMA', N'dbo', 'TABLE', N'Goal', 'COLUMN', N'MANG_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'مالک هدف', 'SCHEMA', N'dbo', 'TABLE', N'Goal', 'COLUMN', N'OWNR_CODE'
GO
EXEC sp_addextendedproperty N'MS_Description', N'درصد محاسبه شده', 'SCHEMA', N'dbo', 'TABLE', N'Goal', 'COLUMN', N'PRCT_WORK_VALU'
GO
