SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [dbo].[V#Message_Broad_Settings] AS
SELECT [MBID]
      ,[TYPE]
      ,[BGWK_STAT]
      ,[BGWK_INTR]
      ,[CUST_BGWK_STAT]
      ,[CUST_BGWK_INTR]
      ,[USER_NAME]
      ,[PASS_WORD]
      ,[WEB_SITE_LOGN]
      ,[WEB_SITE_PSWD]
      ,[LINE_NUMB]
      ,[LINE_TYPE]
      ,[DFLT_STAT]
      ,[LAST_ROW_FTCH]
      ,[FTCH_ROW]
  FROM [iProject].[Msgb].[Message_Broad_Settings]
GO
