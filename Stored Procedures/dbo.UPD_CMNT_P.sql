SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPD_CMNT_P]
	-- Add the parameters for the stored procedure here
   @Cmid BIGINT,
   @Cmnt NVARCHAR(MAX)
AS
BEGIN
 	UPDATE dbo.Comment
 	   SET CMNT = @Cmnt
 	 WHERE CMID = @Cmid;
   RETURN 0;
END
GO
