SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPD_CKLD_P]
	-- Add the parameters for the stored procedure here
   @Cdid BIGINT,
   @From_Date_Time DATETIME,
   @To_Date_Time DATETIME,
   @Cmnt_Desc NVARCHAR(1000)
AS
BEGIN
 	UPDATE dbo.Check_List_Detial
 	   SET FROM_DATE_TIME = @From_Date_Time
 	      ,TO_DATE_TIME = @To_Date_Time
 	      ,CMNT_DESC = @Cmnt_Desc
 	 WHERE CDID = @Cdid;
   RETURN 0;
END
GO
