SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[IntegrationSystems]	
AS
BEGIN
	BEGIN TRY
	   BEGIN TRAN T_INSTALLDB;
	   DECLARE @Code BIGINT
	          ,@DatabaseName VARCHAR(100);
	   
	   SELECT @DatabaseName = DB_NAME();
	   
	   --SELECT @Code = CODE	   
	   --  FROM dbo.Company
	   -- WHERE HOST_STAT = '002'
	   --   AND DFLT_STAT = '002';
	      
	   DECLARE C$User CURSOR FOR
	      SELECT USER_DB, USER_NAME
	        FROM dbo.V#Users
	       WHERE (
	               @DatabaseName = 'iCRM' AND ShortCut != 22 OR
	               @DatabaseName = 'iCRM001' AND ShortCut = 22	               
	             )	       
	   
	   DECLARE @UserDb NVARCHAR(255)
	          ,@UserName NVARCHAR(MAX)
	          ,@JobCode BIGINT;

	   
	   SELECT TOP 1 @JobCode = CODE FROM dbo.Job;
	   
	   OPEN [C$User];
	   L$LOOP_C$USER:
	   FETCH [C$User] INTO @UserDb, @UserName;	   
	   
	   IF @@FETCH_STATUS <> 0
	      GOTO L$EndLoop_C$User;
	   
	   IF EXISTS(SELECT * FROM dbo.Job_Personnel WHERE USER_NAME = @UserDb)
	      GOTO L$LOOP_C$USER;
	   
	   INSERT INTO dbo.Job_Personnel
	           ( SERV_FILE_NO ,
	             JOB_CODE ,
	             USER_NAME ,
	             CODE ,
	             USER_DESC_DNRM ,
	             STAT ,
	             DFLT_STAT, 
	             RUN_QURY
	           )
	   VALUES  ( NULL , -- SERV_FILE_NO - bigint
	             @JobCode , -- JOB_CODE - bigint
	             @UserDb , -- USER_NAME - varchar(250)
	             0 , -- CODE - bigint
	             @UserName , -- USER_DESC_DNRM - nvarchar(250)
	             '002' , -- STAT - varchar(3)
	             '002' ,
	             '002'
	           );
	      
	   GOTO L$Loop_C$User;
	   L$EndLoop_C$User:
	   CLOSE [C$User];
	   DEALLOCATE [C$User];
	   
	   COMMIT TRAN T_INSTALLDB;	   
	END TRY
	BEGIN CATCH
      DECLARE @ErrorMessage NVARCHAR(MAX);
      SET @ErrorMessage = ERROR_MESSAGE();
      RAISERROR ( @ErrorMessage, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN T_INSTALLDB;
	END CATCH
END
GO
