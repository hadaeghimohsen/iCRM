SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[DEL_CMDF_P]
	-- Add the parameters for the stored procedure here
   @Code BIGINT	
AS
BEGIN
	DELETE dbo.Competitor_Difference
	 WHERE CODE = @Code;
END
GO
