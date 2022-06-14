SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_CMDF_P]
	-- Add the parameters for the stored procedure here
	@Comp_Code BIGINT
  ,@Type VARCHAR(3)
  ,@Cmnt NVARCHAR(500)
AS
BEGIN
	INSERT INTO dbo.Competitor_Difference
	        ( COMP_CODE ,
	          CODE ,
	          TYPE ,
	          CMNT 
	        )
	VALUES  ( @Comp_Code , -- COMP_CODE - bigint
	          0 , -- CODE - bigint
	          @Type , -- TYPE - varchar(3)
	          @Cmnt  -- CMNT - nvarchar(500)
	        );
END
GO
