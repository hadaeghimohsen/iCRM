SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[DEL_CMNT_P]
	-- Add the parameters for the stored procedure here
	@Cmid     BIGINT
AS
BEGIN
 	DELETE dbo.Comment
    WHERE CMID = @Cmid;
   RETURN 0;
END
GO
