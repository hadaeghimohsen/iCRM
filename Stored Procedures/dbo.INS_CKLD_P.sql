SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_CKLD_P]
	-- Add the parameters for the stored procedure here
   @Ckls_Ckid BIGINT,
   @From_Date_Time DATETIME,
   @To_Date_Time DATETIME,
   @Cmnt_Desc NVARCHAR(1000)
AS
BEGIN
 	INSERT INTO dbo.Check_List_Detial
 	        ( CKLS_CKID ,
 	          FROM_DATE_TIME ,
 	          TO_DATE_TIME ,
 	          CMNT_DESC 
 	        )
 	VALUES  ( @Ckls_Ckid , -- CKLS_CKID - bigint
 	          @From_Date_Time , -- FROM_DATE_TIME - datetime
 	          @To_Date_Time , -- TO_DATE_TIME - datetime
 	          @Cmnt_Desc  -- CMNT_DESC - nvarchar(1000)
 	        );
   RETURN 0;
END
GO
