SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[DEL_TAG_P]
	-- Add the parameters for the stored procedure here
	@Tgid     BIGINT
AS
BEGIN
 	DELETE dbo.Tag
    WHERE TGID = @Tgid;
   RETURN 0;
END
GO
