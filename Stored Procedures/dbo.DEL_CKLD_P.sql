SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[DEL_CKLD_P]
	-- Add the parameters for the stored procedure here
	@Cdid     BIGINT
AS
BEGIN
 	DELETE dbo.Check_List_Detial
    WHERE CDID = @Cdid;
   RETURN 0;
END
GO
