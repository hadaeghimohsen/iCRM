SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE PROCEDURE [dbo].[SET_MNTN_P]
	@X XML
AS
BEGIN
   /*
      <TemplateToText fileno="" tmid=""/>
   */
	DECLARE @FileNo BIGINT
	       ,@Rqid BIGINT
	       ,@JobpCode BIGINT
	       ,@Text NVARCHAR(4000);
	
	SELECT @FileNo = @X.query('//Mention').value('(Mention/@fileno)[1]', 'BIGINT')
	      ,@Rqid = @X.query('//Mention').value('(Mention/@rqid)[1]', 'BIGINT')
	      ,@Text = @X.query('//Text').value('.', 'NVARCHAR(4000)');
	
   -- Process on Text Template
   DECLARE @PlaceHolder VARCHAR(2)
          ,@NumbOfPlaceHolder INT
          ,@Xp XML;
   
   SET @PlaceHolder = N'@{';
   SELECT @NumbOfPlaceHolder = (len(@Text) - len(replace(@Text,@PlaceHolder,''))) / LEN(@PlaceHolder);
   
   DECLARE @i INT = 0;
   
   DECLARE @PlaceHolderItem NVARCHAR(100)
          ,@StartOpenPosition INT = 0
          ,@StartClosePosition INT = 0;
   WHILE @i < @NumbOfPlaceHolder
   BEGIN
      SELECT @PlaceHolderItem = 
         SUBSTRING(
            @Text,
            CHARINDEX(N'@{', @Text, @StartOpenPosition),
            CHARINDEX(N'}', @Text, @StartClosePosition) - CHARINDEX(N'@{', @Text, @StartOpenPosition) + 1
         );
      
      SELECT @JobpCode = CODE
        FROM dbo.Job_Personnel
       WHERE N'@{' + USER_DESC_DNRM + N'}' = @PlaceHolderItem;
      
      MERGE dbo.Mention T
      USING (SELECT @Rqid AS RQST_RQID, @FileNo AS SERV_FILE_NO, @JobpCode AS JOBP_CODE) S
      ON (T.RQST_RQID = S.RQST_RQID AND 
          T.SERV_FILE_NO = S.SERV_FILE_NO AND
          T.JOBP_CODE = S.JOBP_CODE)
      WHEN NOT MATCHED THEN
         INSERT (RQST_RQID, SERV_FILE_NO, JOBP_CODE, CODE, READ_MNTN, READ_NOTF, MNTN_DATE) 
         VALUES (S.RQST_RQID, S.SERV_FILE_NO, S.JOBP_CODE, 0, '001', '001', GETDATE())
      WHEN MATCHED THEN
         UPDATE SET
            T.MDFY_STAT = '001';      
      
      -- Get Next Position Start {
      SET @StartOpenPosition = CHARINDEX(N'@{', @Text, @StartOpenPosition) + 1;
      -- Get Next Position Start }
      SET @StartClosePosition = CHARINDEX(N'}', @Text, @StartClosePosition) + 1;
      SET @i += 1;
   END;  
END
GO
