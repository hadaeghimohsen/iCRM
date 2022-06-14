SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPD_CMDF_P]
	-- Add the parameters for the stored procedure here
   @Code BIGINT	
  ,@Type VARCHAR(3)
  ,@Cmnt NVARCHAR(500)
AS
BEGIN
	UPDATE dbo.Competitor_Difference
	   SET TYPE = @Type
	      ,CMNT = @Cmnt
	 WHERE CODE = @Code;
END
GO
