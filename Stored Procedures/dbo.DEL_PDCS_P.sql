SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[DEL_PDCS_P]
	-- Add the parameters for the stored procedure here
	@Pydt_Code BIGINT
  ,@Code BIGINT
AS
BEGIN
	DELETE dbo.Payment_Detail_Commodity_Sales
	 WHERE PYDT_CODE = @Pydt_Code
	   AND CODE = @Code;
END
GO
