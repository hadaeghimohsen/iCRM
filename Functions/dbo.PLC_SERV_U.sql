SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[PLC_SERV_U]
(
	@X XML
)
RETURNS VARCHAR(3)
AS
BEGIN
	DECLARE @FileNo BIGINT;
	SELECT @FileNo = @X.query('Service').value('(Service/@fileno)[1]', 'BIGINT');
	
	DECLARE @Rslt VARCHAR(3); -- DOMAIN YSNO
	
	IF EXISTS(SELECT * FROM Service WHERE FILE_NO = @FileNo AND SRPB_TYPE_DNRM IN ('002', '003'))
	   RETURN '002'
	ELSE
	   SELECT @Rslt = CASE COUNT(*) WHEN 0 THEN '001' WHEN 1 THEN '002' END
	     FROM Service F, V#URFGA P, V#UCFGA C
	    WHERE F.REGN_PRVN_CODE = P.REGN_PRVN_CODE
	      AND F.REGN_CODE = P.REGN_CODE
	      AND F.FILE_NO = @FileNo
	      AND F.COMP_CODE_DNRM = C.COMP_CODE 
	      AND C.SYS_USER = UPPER(SUSER_NAME())
	      AND P.SYS_USER = UPPER(SUSER_NAME());
	
	RETURN @Rslt;
END
GO
