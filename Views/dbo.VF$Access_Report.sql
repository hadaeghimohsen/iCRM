SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[VF$Access_Report]
AS
SELECT     ROLE_ID, ROLE_NAME, SERV_ID, SERV_NAME, SERV_FILE_PATH, USER_NAME, UNIT_ID, TYPE_ID, SUB_SYS
FROM         iProject.Report.v$AccessReports
WHERE     (UPPER(USER_NAME) = UPPER(SUSER_NAME()))
GO
