SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[IsDateTimeNullOrEmpty]
(
	@Expr1 DATETIME,
	@Expr2 DATETIME
)
RETURNS DATETIME
AS
BEGIN
	RETURN CASE @Expr1
	         WHEN '1900-01-01' THEN @Expr2
	         ELSE @Expr1
	       END;
END
GO
