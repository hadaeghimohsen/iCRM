SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPD_LIKE_P]
	-- Add the parameters for the stored procedure here
   @Lkid BIGINT,
   @Like_Cmnt NVARCHAR(MAX)
AS
BEGIN
 	UPDATE dbo.[Like]
 	   SET LIKE_CMNT = @Like_Cmnt
 	 WHERE LKID = @Lkid;
   RETURN 0;
END
GO
