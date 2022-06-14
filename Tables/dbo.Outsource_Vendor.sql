CREATE TABLE [dbo].[Outsource_Vendor]
(
[CAMA_CAID] [bigint] NULL,
[SERV_FILE_NO] [bigint] NULL,
[COMP_CODE] [bigint] NULL,
[OVID] [bigint] NOT NULL,
[CRET_BY] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CRET_DATE] [datetime] NULL
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
CREATE TRIGGER [dbo].[CG$AINS_OSVN]
   ON  [dbo].[Outsource_Vendor]
   AFTER INSERT 
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Outsource_Vendor T
   USING (SELECT * FROM Inserted) S
   ON (T.OVID = S.OVID)
   WHEN MATCHED THEN
      UPDATE SET
         T.CRET_BY = UPPER(SUSER_NAME())
        ,T.CRET_DATE = GETDATE()
        ,T.OVID = CASE WHEN S.OVID = 0 THEN dbo.GNRT_NWID_U() ELSE s.OVID END;
END
GO
ALTER TABLE [dbo].[Outsource_Vendor] ADD CONSTRAINT [PK_OSVN] PRIMARY KEY CLUSTERED  ([OVID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Outsource_Vendor] ADD CONSTRAINT [FK_OSVN_CAMA] FOREIGN KEY ([CAMA_CAID]) REFERENCES [dbo].[Campaign_Activity] ([CAID])
GO
ALTER TABLE [dbo].[Outsource_Vendor] ADD CONSTRAINT [FK_OSVN_COMP] FOREIGN KEY ([COMP_CODE]) REFERENCES [dbo].[Company] ([CODE])
GO
ALTER TABLE [dbo].[Outsource_Vendor] ADD CONSTRAINT [FK_OSVN_SERV] FOREIGN KEY ([SERV_FILE_NO]) REFERENCES [dbo].[Service] ([FILE_NO])
GO
