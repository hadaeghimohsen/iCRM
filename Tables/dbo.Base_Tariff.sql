CREATE TABLE [dbo].[Base_Tariff]
(
[CODE] [bigint] NOT NULL CONSTRAINT [DF_BTRF_CODE] DEFAULT ((0)),
[BTRF_DESC] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BTRF_CODE] [bigint] NULL,
[NATL_CODE] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
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
CREATE TRIGGER [dbo].[CG$AINS_BTRF]
   ON  [dbo].[Base_Tariff]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Base_Tariff T
   USING (SELECT * FROM INSERTED) S
   ON (T.CODE = S.CODE)
   WHEN MATCHED THEN
      UPDATE
         SET CRET_BY   = UPPER(SUSER_NAME())
            ,CRET_DATE = GETDATE()
            ,CODE      = DBO.GNRT_NVID_U();
END
;
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[CG$AUPD_BTRF]
   ON  [dbo].[Base_Tariff]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Base_Tariff T
   USING (SELECT * FROM INSERTED) S
   ON (T.CODE = S.CODE)
   WHEN MATCHED THEN
      UPDATE
         SET MDFY_BY   = UPPER(SUSER_NAME())
            ,MDFY_DATE = GETDATE(); 
            
                       
   DECLARE @BTRFCode BIGINT;
   DECLARE C$NewBTRF CURSOR FOR
      SELECT CODE FROM INSERTED
      WHERE MDFY_DATE IS NULL;
   OPEN C$NewBTRF;   
   L$NextRow:
   FETCH NEXT FROM C$NewBTRF INTO @BTRFCode
   
   IF @@FETCH_STATUS <> 0
      GOTO L$EndFetch;
   
	EXEC CRET_EXPN_P
	     @ExtpCode = NULL,
	     @BTRFCode = @BTRFCode,
	     @TRFDCode = NULL;
	
	GOTO L$NextRow;     
   
   L$EndFetch:
   CLOSE C$NewBTRF;
   DEALLOCATE C$NewBTRF;
END
;
GO
ALTER TABLE [dbo].[Base_Tariff] ADD CONSTRAINT [BTRF_PK] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Base_Tariff] ADD CONSTRAINT [FK_BTRF_BTRF] FOREIGN KEY ([BTRF_CODE]) REFERENCES [dbo].[Base_Tariff] ([CODE])
GO
EXEC sp_addextendedproperty N'MS_Description', N'کد بین المللی', 'SCHEMA', N'dbo', 'TABLE', N'Base_Tariff', 'COLUMN', N'NATL_CODE'
GO
