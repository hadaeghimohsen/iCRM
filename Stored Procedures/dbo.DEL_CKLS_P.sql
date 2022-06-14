SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[DEL_CKLS_P]
	-- Add the parameters for the stored procedure here
	@Ckid     BIGINT
AS
BEGIN
 	DELETE dbo.Check_List
    WHERE CKID = @Ckid;
   RETURN 0;
END
GO
