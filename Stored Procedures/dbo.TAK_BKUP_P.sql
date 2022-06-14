SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TAK_BKUP_P]
	@X XML
AS
BEGIN
   DECLARE @BackUp BIT
          ,@BackupAppExit BIT
          ,@BackupOptnPathAdrs NVARCHAR(MAX);
   DECLARE @BackupType VARCHAR(20);
   
   SELECT @BackupType = @X.query('//Backup').value('(Backup/@type)[1]', 'VARCHAR(20)')

   SELECT @Backup = BACK_UP_STAT
         ,@BackupAppExit = BACK_UP_APP_EXIT
         ,@BackupOptnPathAdrs = BACK_UP_PATH_ADRS
     FROM dbo.V#ConfigurationSystem;
    

   
   ---------------------
   SET NOCOUNT ON

   -- 1 - Variable declaration
   DECLARE @DBName sysname
   DECLARE @DataPath nvarchar(500)
   DECLARE @LogPath nvarchar(500)
   DECLARE @DirTree TABLE (subdirectory nvarchar(255), depth INT)

   SET @DBName = 'iCrm_' + @BackupType + '_' + UPPER(SUSER_NAME()) + '_' + REPLACE(dbo.GET_MTOS_U(GETDATE()), '/', '') + '_' + REPLACE(SUBSTRING(dbo.GET_CDTD_U(), LEN(dbo.GET_CDTD_U()) - 7, 10 ), ':', '') + '.bak';
   -- 2 - Initialize variables
   SET @DataPath = @BackupOptnPathAdrs + '\Backup'

   -- 3 - @DataPath values
   INSERT INTO @DirTree(subdirectory, depth)
   EXEC master.sys.xp_dirtree @DataPath

   -- 4 - Create the @DataPath directory
   IF NOT EXISTS (SELECT 1 FROM @DirTree)
   EXEC master.dbo.xp_create_subdir @DataPath
   
   SET @DataPath = @DataPath + '\' + @DBName;
   SET NOCOUNT OFF
   ---------------------
   BACKUP DATABASE [iCRM] TO  DISK = @DataPath WITH NOFORMAT, INIT,  NAME = N'iScsc-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
	
END
GO
