CREATE TABLE [dbo].[Check_List]
(
[COLB_CLID] [bigint] NULL,
[CKID] [bigint] NOT NULL IDENTITY(1, 1),
[CKLS_DESC] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[STAT] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRCT_VALU] [int] NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_CKLS]
   ON  [dbo].[Check_List]
   AFTER INSERT
AS 
BEGIN
	MERGE dbo.Check_List T
	USING (SELECT * FROM Inserted) S
	ON (T.COLB_CLID = S.COLB_CLID AND
	    T.CKID = S.CKID)
	WHEN MATCHED THEN
	   UPDATE SET
	      T.CRET_BY = UPPER(SUSER_NAME())
	     ,T.CRET_DATE = GETDATE()
	     ,T.PRCT_VALU = ISNULL(s.PRCT_VALU, 0);
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
CREATE TRIGGER [dbo].[CG$AUPD_CKLS]
   ON  [dbo].[Check_List]
   AFTER UPDATE
AS 
BEGIN
	MERGE dbo.Check_List T
	USING (SELECT * FROM Inserted) S
	ON (T.COLB_CLID = S.COLB_CLID AND
	    T.CKID = S.CKID)
	WHEN MATCHED THEN
	   UPDATE SET
	      T.MDFY_BY = UPPER(SUSER_NAME())
	     ,T.MDFY_DATE = GETDATE()
	     ,t.PRCT_VALU = ISNULL(s.PRCT_VALU, 0);
	     
   UPDATE dbo.Collaborator
      SET PRCT_VALU_DNRM = (
         SELECT SUM(ISNULL(c.PRCT_VALU, 0)) / COUNT(c.CKID)
           FROM dbo.Check_List c, Inserted s
          WHERE c.COLB_CLID = s.COLB_CLID
      )
     FROM Inserted s
    WHERE CLID = s.COLB_CLID;
END
GO
ALTER TABLE [dbo].[Check_List] ADD CONSTRAINT [PK_CKLS] PRIMARY KEY CLUSTERED  ([CKID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Check_List] ADD CONSTRAINT [FK_CKLS_COLB] FOREIGN KEY ([COLB_CLID]) REFERENCES [dbo].[Collaborator] ([CLID]) ON DELETE CASCADE
GO
