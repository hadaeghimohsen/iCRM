SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPD_PDCS_P]
	-- Add the parameters for the stored procedure here
	@Pydt_Code BIGINT
  ,@Code BIGINT
  ,@Serl_No_Bar_Code VARCHAR(50)
  ,@Cmsl_Desc NVARCHAR(500)
AS
BEGIN
	UPDATE dbo.Payment_Detail_Commodity_Sales
	   SET SERL_NO_BAR_CODE = @Serl_No_Bar_Code
	      ,CMSL_DESC = @Cmsl_Desc
	 WHERE PYDT_CODE = @Pydt_Code
	   AND CODE = @Code;
END
GO
