CREATE TABLE [dbo].[Base_Tariff_Detail]
(
[BTRF_CODE] [bigint] NULL,
[CODE] [bigint] NOT NULL CONSTRAINT [DF_TRFD_CODE] DEFAULT ((0)),
[NAME] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRFD_DESC] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ORDR] [smallint] NULL CONSTRAINT [DF_TRFD_ORDR] DEFAULT ((1)),
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
CREATE TRIGGER [dbo].[CG$AINS_TRFD]
   ON  [dbo].[Base_Tariff_Detail]
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Base_Tariff_Detail T
   USING (SELECT * FROM INSERTED) S
   ON (T.CODE = S.CODE)
   WHEN MATCHED THEN
      UPDATE
         SET CRET_BY   = UPPER(SUSER_NAME())
            ,CRET_DATE = GETDATE()
            ,CODE      = dbo.Gnrt_Nvid_U()
            ,ORDR      = CASE WHEN S.Ordr IS NULL THEN (SELECT COUNT(*) FROM dbo.Base_Tariff_Detail c WHERE c.BTRF_CODE = S.BTRF_CODE) ELSE S.Ordr END;
   
   
   DECLARE C$NewTariff_Detail CURSOR FOR
      SELECT DISTINCT BTRF_CODE FROM INSERTED;
   
   DECLARE @Code     BIGINT
          ,@BTRFCode BIGINT;
   
   OPEN C$NewTariff_Detail;
   L$NextTRFDRow:
   FETCH NEXT FROM C$NewTariff_Detail INTO @BTRFCode;
   
   IF @@FETCH_STATUS <> 0
      GOTO L$EndTRFDFetch;
   
   EXEC CRET_EXPN_P @ExtpCode = NULL, @BTRFCode = @BTRFCode, @TRFDCode = NULL;
   
   GOTO L$NextTRFDRow;
   L$EndTRFDFetch:
   CLOSE C$NewTariff_Detail;
   DEALLOCATE C$NewTariff_Detail;    
END
;
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[CG$AUPD_TRFD]
   ON  [dbo].[Base_Tariff_Detail]
   AFTER UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   -- Insert statements for trigger here
   MERGE dbo.Base_Tariff_Detail T
   USING (SELECT * FROM INSERTED) S
   ON (T.CODE = S.CODE)
   WHEN MATCHED THEN
      UPDATE
         SET MDFY_BY   = UPPER(SUSER_NAME())
            ,MDFY_DATE = GETDATE();
            
   /*DECLARE @TRFDCode BIGINT;
   DECLARE C$NewTRFD CURSOR FOR
      SELECT CODE FROM INSERTED
      WHERE MDFY_DATE IS NULL;
   OPEN C$NewTRFD;   
   L$NextRow:
   FETCH NEXT FROM C$NewTRFD INTO @TRFDCode
   
   IF @@FETCH_STATUS <> 0
      GOTO L$EndFetch;
   
	EXEC CRET_EXPN_P
	     @ExtpCode = NULL,
	     @BTRFCode = NULL,
	     @TRFDCode = @TRFDCode;
	
	GOTO L$NextRow;     
   
   L$EndFetch:
   CLOSE C$NewTRFD;
   DEALLOCATE C$NewTRFD;*/
            
END
;
GO
ALTER TABLE [dbo].[Base_Tariff_Detail] ADD CONSTRAINT [TRFD_PK] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Base_Tariff_Detail] ADD CONSTRAINT [FK_TRFD_BTRF] FOREIGN KEY ([BTRF_CODE]) REFERENCES [dbo].[Base_Tariff] ([CODE]) ON DELETE SET NULL
GO
EXEC sp_addextendedproperty N'MS_Description', N'کد بین المللی', 'SCHEMA', N'dbo', 'TABLE', N'Base_Tariff_Detail', 'COLUMN', N'NATL_CODE'
GO
