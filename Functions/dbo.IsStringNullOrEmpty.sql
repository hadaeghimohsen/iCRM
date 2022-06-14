SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[IsStringNullOrEmpty]
(
	@Expr1 NVARCHAR(MAX),
	@Expr2 NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	RETURN CASE ISNULL(@Expr1, '')
	         WHEN '' THEN @Expr2
	         ELSE @Expr1
	       END;
END
GO
