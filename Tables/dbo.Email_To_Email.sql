CREATE TABLE [dbo].[Email_To_Email]
(
[SERV_FILE_NO] [bigint] NULL,
[EMAL_EMID] [bigint] NULL,
[ETID] [bigint] NOT NULL IDENTITY(1, 1),
[TO_MAIL] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_ETOE]
   ON  [dbo].[Email_To_Email]
   AFTER INSERT 
AS 
BEGIN
	MERGE dbo.Email_To_Email T
	USING (SELECT * FROM Inserted) S
	ON (T.EMAL_EMID = S.EMAL_EMID AND 
	    T.ETID = S.ETID)
	WHEN MATCHED THEN
	   UPDATE SET
	      T.CRET_BY = UPPER(SUSER_NAME())
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
CREATE TRIGGER [dbo].[CG$AUPD_ETOE]
   ON  [dbo].[Email_To_Email]
   AFTER UPDATE    
AS 
BEGIN
	MERGE dbo.Email_To_Email T
	USING (SELECT * FROM Inserted) S
	ON (T.EMAL_EMID = S.EMAL_EMID AND 
	    T.ETID = S.ETID)
	WHEN MATCHED THEN
	   UPDATE SET
	      T.MDFY_BY = UPPER(SUSER_NAME())
	     ,T.MDFY_DATE = GETDATE()
	     ,T.SERV_FILE_NO = 
	        CASE WHEN S.SERV_FILE_NO IS NULL THEN
	           (
	              SELECT TOP 1 FILE_NO
	                FROM dbo.Service
	               WHERE (
	                  UPPER(EMAL_ADRS_DNRM) = UPPER(S.TO_MAIL) OR 
      	            EXISTS(
      	               SELECT *
      	                 FROM dbo.Contact_Info
      	                WHERE SERV_FILE_NO = FILE_NO
      	                  AND UPPER(CONT_DESC) = UPPER(S.TO_MAIL)
      	            )
	               )
	           )
	        ELSE S.SERV_FILE_NO
	        END;
END
GO
ALTER TABLE [dbo].[Email_To_Email] ADD CONSTRAINT [PK_ETOE] PRIMARY KEY CLUSTERED  ([ETID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Email_To_Email] ADD CONSTRAINT [FK_ETOE_EMAL] FOREIGN KEY ([EMAL_EMID]) REFERENCES [dbo].[Email] ([EMID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Email_To_Email] ADD CONSTRAINT [FK_ETOE_SERV] FOREIGN KEY ([SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO]) ON DELETE CASCADE
GO
EXEC sp_addextendedproperty N'MS_Description', N'ادرس ایمیل مشتری که ارسال شده', 'SCHEMA', N'dbo', 'TABLE', N'Email_To_Email', 'COLUMN', N'SERV_FILE_NO'
GO
