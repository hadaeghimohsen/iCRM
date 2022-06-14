CREATE TABLE [dbo].[Service_Relation]
(
[SERV_FILE_NO] [bigint] NULL,
[RLID] [bigint] NOT NULL IDENTITY(1, 1),
[SRLT_SERV_FILE_NO] [bigint] NULL,
[FRST_NAME] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LAST_NAME] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SEX_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BRTH_DATE] [date] NULL,
[RELT_TYPE] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CONF_STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CONF_DATE] [datetime] NULL,
[IMAG] [image] NULL,
[CRET_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRET_DATE] [datetime] NULL,
[MDFY_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MDFY_DATE] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
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
CREATE TRIGGER [dbo].[CG$AINS_SRLT]
   ON  [dbo].[Service_Relation]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   Merge Service_Relation T
   USING (SELECT Serv_File_No, Rlid FROM Inserted) S
   ON (T.Serv_File_No = S.Serv_File_No AND
       T.RLID = S.RLID)
   WHEN MATCHED THEN
      UPDATE 
         SET CRET_BY = UPPER(SUSER_NAME())
            ,CRET_DATE = GETDATE();
      
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
CREATE TRIGGER [dbo].[CG$AUPD_SRLT]
   ON  [dbo].[Service_Relation]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   Merge Service_Relation T
   USING (SELECT Serv_File_No, Rlid FROM Inserted) S
   ON (T.Serv_File_No = S.Serv_File_No AND
       T.RLID = S.RLID)
   WHEN MATCHED THEN
      UPDATE 
         SET MDFY_BY = UPPER(SUSER_NAME())
            ,MDFY_DATE = GETDATE();
      
END
GO
ALTER TABLE [dbo].[Service_Relation] ADD CONSTRAINT [PK_Service_Relation_1] PRIMARY KEY CLUSTERED  ([RLID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Service_Relation] ADD CONSTRAINT [FK_SRLT_SERV] FOREIGN KEY ([SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO])
GO
ALTER TABLE [dbo].[Service_Relation] ADD CONSTRAINT [FK_SRLT_SRLT_SERV] FOREIGN KEY ([SRLT_SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO])
GO
