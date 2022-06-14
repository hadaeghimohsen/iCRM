SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_PDCS_P]
	-- Add the parameters for the stored procedure here
	@Pydt_Code BIGINT
  ,@Serl_No_Bar_Code VARCHAR(50)
  ,@Cmsl_Desc NVARCHAR(500)
AS
BEGIN
	INSERT INTO dbo.Payment_Detail_Commodity_Sales
	        ( PYDT_CODE ,
	          CODE ,
	          SERL_NO_BAR_CODE ,
	          CMSL_DESC 
	        )
	VALUES  ( @Pydt_Code , -- PYDT_CODE - bigint
	          0 , -- CODE - nchar(10)
	          @Serl_No_Bar_Code , -- SERL_NO_BAR_CODE - varchar(50)
	          @Cmsl_Desc
	        );
END
GO
