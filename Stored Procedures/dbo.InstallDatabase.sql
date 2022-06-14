SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[InstallDatabase]
	-- Add the parameters for the stored procedure here
	@X XML
AS
BEGIN
   DECLARE @Emptydb VARCHAR(3);
   SELECT @Emptydb = @X.query('//Params').value('(Params/@emptydb)[1]', 'VARCHAR(3)');

   BEGIN TRY   
   IF @Emptydb = '002'
   BEGIN
   -- Delete Record From Database
   DELETE dbo.Template
   DELETE dbo.Template_Attachment
   DELETE dbo.Weekday_Info
   DELETE dbo.Task
   DELETE dbo.Step_History_Detail
   DELETE dbo.Step_History_Summery
   DELETE dbo.Similar_Case
   DELETE dbo.Send_File
   DELETE dbo.Reminder
   DELETE dbo.Reason_Request
   DELETE dbo.Outsource_Vendor
   DELETE dbo.Message
   DELETE dbo.Mention
   DELETE dbo.Log_Call
   DELETE dbo.[Like]
   DELETE dbo.Goal_Metric_Rollup_Field
   DELETE dbo.Goal_Metric
   DELETE dbo.Goal
   DELETE dbo.Finance_Document
   DELETE dbo.Event
   DELETE dbo.Email_To_Email
   DELETE dbo.Email
   DELETE dbo.Note
   DELETE dbo.Contract_Line
   DELETE dbo.Contract
   DELETE dbo.Service_Project
   DELETE dbo.Job_Personnel_Relation
   DELETE dbo.Tag
   DELETE dbo.Contact_Info
   DELETE dbo.Relation_Info
   DELETE dbo.Extra_Info
   DELETE dbo.App_Base_Define
   DELETE dbo.Appointment
   DELETE dbo.Final_Result
   DELETE dbo.Stakeholder
   DELETE dbo.Sale_Team
   DELETE dbo.Lead_Competitor
   DELETE dbo.Lead
   DELETE dbo.Service_Public
   DELETE dbo.Payment_Detail_Commodity_Sales
   DELETE dbo.Payment_Detail
   DELETE dbo.Payment_Check
   DELETE dbo.Payment_Discount
   DELETE dbo.Payment_Method
   DELETE dbo.Payment
   DELETE dbo.Request_Row
   UPDATE dbo.Company SET LAST_SERV_FILE_NO_DNRM = NULL, LAST_RQST_RQID_DNRM = NULL, PRIM_SERV_FILE_NO = NULL, OWNR_CODE = NULL
   UPDATE dbo.Service SET LAST_RQST_RQID_DNRM = NULL
   DELETE dbo.Request_Show_Service_Type
   DELETE dbo.Request_Letter
   DELETE dbo.Request_Job_Personnel
   DELETE dbo.Request
   DELETE dbo.Job_Personel_Dashboard
   UPDATE dbo.Campaign SET OWNR_CODE = NULL
   DELETE dbo.Campaign_Activity
   DELETE dbo.Campaign_Quick
   DELETE dbo.Member
   DELETE dbo.Marketing_List_Campaign
   DELETE dbo.Marketing_List
   DELETE dbo.Job_Personnel
   DELETE dbo.Service
   DELETE dbo.Competitor_Difference
   DELETE dbo.Company
   DELETE dbo.Base_Tariff_Detail
   DELETE dbo.Base_Tariff
   DELETE dbo.App_Base_Define
   DELETE dbo.Campaign
   DELETE dbo.Sub_State WHERE NOT (MSTT_CODE IN ( 1, 2, 3, 90, 95, 99 ) )
   DELETE dbo.Main_State WHERE NOT (CODE IN ( 1, 2, 3, 90, 95, 99 ) )
   END;
   
   -- Save Host Info
   IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'iProject')
	BEGIN
	   RAISERROR (N'iProject Database is not install, Please First Install iProject', 16, 1);
	   RETURN -1;
	END 
   /*
   '<Request Rqtp_Code="ManualSaveHostInfo">
      <Database>iProject</Database>
      <Dbms>SqlServer</Dbms>
      <User>scott</User>
      <Computer name="DESKTOP-LB0GKTR" 
                ip="192.168.158.1" 
                mac="00:50:56:C0:00:01" 
                cpu="BFEBFBFF000206A7" />
    </Request>'
   */
   BEGIN TRAN T_INSTALLDB
   IF @Emptydb = '002'
   BEGIN   
      INSERT INTO dbo.Company
              ( REGN_PRVN_CNTY_CODE ,
                REGN_PRVN_CODE ,
                REGN_CODE ,
                CODE ,
                NAME ,
                POST_ADRS ,
                HOST_STAT ,
                DFLT_STAT
              )
      VALUES  ( '001' , -- REGN_PRVN_CNTY_CODE - varchar(3)
                '017' , -- REGN_PRVN_CODE - varchar(3)
                '001' , -- REGN_CODE - varchar(3)
                0 , -- CODE - bigint
                N'شرکت میزبان' , -- POST_ADRS - nvarchar(1000)
                N'آدرس شرکت میزبان' ,
                '002' ,
                '002'
              );
      
      INSERT INTO dbo.App_Base_Define
              ( CODE ,
                RWNO ,
                TITL_DESC ,
                ENTY_NAME ,
                REF_CODE              
              )
      VALUES  ( 0 , -- CODE - bigint
                0 , -- RWNO - int
                N'کارکنان' , -- TITL_DESC - nvarchar(250)
                'COMPANYCHART_INFO' , -- ENTY_NAME - varchar(250)
                NULL  -- REF_CODE - bigint
              );
   END;
   
   DECLARE  @RqtpCode      VARCHAR(30)
           ,@ComputerName VARCHAR(50)
           ,@IPAddress    VARCHAR(15)
           ,@MacAddress   VARCHAR(17)
           ,@Cpu      VARCHAR(30)
           ,@UserName     VARCHAR(250)
           ,@UserId       BIGINT
           ,@DatabaseTest VARCHAR(3)
           ,@InstallLicenseKey NVARCHAR(4000);
   
   SELECT @ComputerName = @X.query('//Computer').value('(Computer/@name)[1]', 'VARCHAR(50)')
         ,@Cpu = @X.query('//Computer').value('(Computer/@cpu)[1]', 'VARCHAR(30)')
         ,@DatabaseTest = @X.query('//Params').value('(Params/@databasetest)[1]', 'VARCHAR(3)')
         ,@InstallLicenseKey = @X.query('//Params').value('(Params/@licensekey)[1]', 'NVARCHAR(4000)');
   
   -- Save Datasource and Connection
   IF NOT EXISTS(
      SELECT * 
        FROM iProject.Report.DataSource 
       WHERE (
         (@DatabaseTest = '002' AND Database_Alias = 'iCRM001') OR 
         (@DatabaseTest = '001' AND Database_Alias = 'iCRM')
       )
   )   
   BEGIN   
      IF @DatabaseTest = '001'
         INSERT INTO iProject.Report.DataSource
         ( ID ,ShortCut ,DatabaseServer ,IPAddress ,Port ,
           Database_Alias ,[Database] ,UserID ,Password ,TitleFa ,
           IsDefault ,IsActive ,IsVisible ,SUB_SYS 
         )
         VALUES  
         ( 4 ,4 ,1 ,@ComputerName,0 , 
           'iCRM' ,'iCRM' ,'' , '' , N'اطلاعات اصلی' , 
           1 , 1 , 1 , 11  );
      ELSE
         INSERT INTO iProject.Report.DataSource
         ( ID ,ShortCut ,DatabaseServer ,IPAddress ,Port ,
           Database_Alias ,[Database] ,UserID ,Password ,TitleFa ,
           IsDefault ,IsActive ,IsVisible ,SUB_SYS 
         )
         VALUES  
         ( 5 ,5 ,1 ,@ComputerName,0 , 
           'iCRM' ,'iCRM001' ,'' , '' , N'اطلاعات تستی' , 
           1 , 1 , 1 , 11  ); 
   END 
   
   COMMIT TRANSACTION T_INSTALLDB;
   
   DECLARE @XT XML;
   IF @DatabaseTest = '001'
   begin
      SELECT @XT = (
         SELECT 'ManualSaveHostInfo' AS '@Rqtp_Code'
               ,'installing' AS '@SystemStatus'
               ,'iCRM' AS 'Database'
               ,'SqlServer' AS 'Dbms'
               ,'artauser' AS 'User'               
               ,@X.query('//Computer').value('(Computer/@name)[1]', 'VARCHAR(50)') AS 'Computer/@name'
               ,@X.query('//Computer').value('(Computer/@mac)[1]', 'VARCHAR(17)') AS 'Computer/@mac'
               ,@X.query('//Computer').value('(Computer/@ip)[1]', 'VARCHAR(15)') AS 'Computer/@ip'
               ,@X.query('//Computer').value('(Computer/@cpu)[1]', 'VARCHAR(30)') AS 'Computer/@cpu'
           FOR XML PATH('Request')
      );
      
      EXEC iProject.DataGuard.SaveHostInfo @X = @XT;
   END    
   ELSE 
   BEGIN
      SELECT @XT = (
         SELECT 'ManualSaveHostInfo' AS '@Rqtp_Code'
               ,'installing' AS '@SystemStatus'
               ,'iCRM' AS 'Database'
               ,'SqlServer' AS 'Dbms'
               ,'demo' AS 'User'               
               ,@X.query('//Computer').value('(Computer/@name)[1]', 'VARCHAR(50)') AS 'Computer/@name'
               ,@X.query('//Computer').value('(Computer/@mac)[1]', 'VARCHAR(17)') AS 'Computer/@mac'
               ,@X.query('//Computer').value('(Computer/@ip)[1]', 'VARCHAR(15)') AS 'Computer/@ip'
               ,@X.query('//Computer').value('(Computer/@cpu)[1]', 'VARCHAR(30)') AS 'Computer/@cpu'
           FOR XML PATH('Request')
      );
      
      EXEC iProject.DataGuard.SaveHostInfo @X = @XT;
   END;
   
   BEGIN TRAN T_INSTALLDB;
   UPDATE iProject.DataGuard.Sub_System SET STAT = '002', INST_STAT = '002', CLNT_LICN_DESC = NULL, SRVR_LICN_DESC = NULL, LICN_TYPE = NULL, LICN_TRIL_DATE = NULL, INST_LICN_DESC = @InstallLicenseKey WHERE SUB_SYS IN (11);   
   
   IF @DatabaseTest = '001'
      INSERT INTO iProject.Global.Access_User_Datasource
      ( USER_ID ,DSRC_ID ,STAT ,ACES_TYPE ,
        HOST_NAME )
      SELECT id, 4, '002', '001', @Cpu
        FROM iProject.DataGuard.[User] u
       WHERE ShortCut IN (16, 21)
         AND NOT EXISTS(
             SELECT *
               FROM iProject.Global.Access_User_Datasource a
              WHERE a.USER_ID = u.ID
                AND a.DSRC_ID = 4
         );
   ELSE
      INSERT INTO iProject.Global.Access_User_Datasource
      ( USER_ID ,DSRC_ID ,STAT ,ACES_TYPE ,
        HOST_NAME )
      SELECT id, 5, '002', '001', @Cpu
        FROM iProject.DataGuard.[User] u
       WHERE ShortCut IN (22)
         AND NOT EXISTS(
             SELECT *
               FROM iProject.Global.Access_User_Datasource a
              WHERE a.USER_ID = u.ID
                AND a.DSRC_ID = 5
         );
       
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
   END CATCH;   
END
GO
