SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[ShrinkLogFileDb]	
AS
BEGIN
	
   ALTER DATABASE iCRM SET RECOVERY SIMPLE;
   DBCC SHRINKFILE(N'iCRM_log', 1);
   ALTER DATABASE iCRM SET RECOVERY FULL;
   PRINT 'iCRM Log File Shrink 1 MB';
   	
END
GO
