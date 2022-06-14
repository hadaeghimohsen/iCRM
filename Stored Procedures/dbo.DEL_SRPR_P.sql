SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[DEL_SRPR_P]
	@Code BIGINT
AS
BEGIN	
	-- بررسی دسترسی
	
	DELETE dbo.Service_Project
	 WHERE CODE = @Code;
END
GO
