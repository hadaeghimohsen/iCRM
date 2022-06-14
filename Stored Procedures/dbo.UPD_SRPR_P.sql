SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPD_SRPR_P]
	@Code BIGINT
  ,@Rec_Stat VARCHAR(3)
  ,@Rajp_Desc NVARCHAR(500)
AS
BEGIN	
	-- بررسی دسترسی
	
	UPDATE dbo.Service_Project
	   SET REC_STAT = @Rec_Stat
	      ,RAJP_DESC = @Rajp_Desc
	 WHERE CODE = @Code;	
END
GO
