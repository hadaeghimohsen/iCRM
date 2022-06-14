SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_LIKE_P]
	-- Add the parameters for the stored procedure here
   @Cmnt_Cmid BIGINT,
   @Like_Cmnt NVARCHAR(MAX)
AS
BEGIN
 	INSERT INTO dbo.[Like]
 	        ( CMNT_CMID ,
 	          LIKE_CMNT 
 	        )
 	VALUES  ( @Cmnt_Cmid , -- CMNT_CMID - bigint
 	          @Like_Cmnt  -- LIKE_CMNT - nvarchar(max) 	          
 	        );
   RETURN 0;
END
GO
