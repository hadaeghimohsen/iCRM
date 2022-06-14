SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[SERV_FLTR_U]
(
	@X XML
)
RETURNS INT
AS
BEGIN
	DECLARE @FileNo BIGINT;
	
	SELECT @FileNo = @X.query('//Service').value('(Service/@fileno)[1]', 'BIGINT');
	
	IF EXISTS(
	   SELECT *
	     FROM dbo.Service S
	    WHERE s.FILE_NO = @FileNo
	      AND ( @x.query('//Tags').value('(Tags/@cont)[1]', 'BIGINT') = 0 OR 
	         EXISTS(
		         SELECT *
		           FROM Tag t, @x.nodes('//Tag') tx(r)
		          WHERE t.TGID = tx.r.query('.').value('(Tag/@tgid)[1]', 'BIGINT')
		            AND (T.SERV_FILE_NO = S.FILE_NO)
	         )
	      )
	      AND ( @x.query('//Regions').value('(Regions/@cont)[1]', 'BIGINT') = 0 OR 
	         EXISTS(
		         SELECT *
		           FROM @x.nodes('//Region') tx(r)
		          WHERE s.REGN_CODE = rx.r.query('.').value('(Region/@code)[1]', 'VARCHAR(3)')
                  AND s.REGN_PRVN_CODE = rx.r.query('.').value('(Region/@prvncode)[1]', 'VARCHAR(3)')
                  AND s.REGN_PRVN_CNTY_CODE = rx.r.query('.').value('(Region/@cntycode)[1]', 'VARCHAR(3)')
	         )
	      )	   
	)
	BEGIN
	   RETURN 1;
	END
	ELSE
	BEGIN
	   RETURN 0;
	END
	
	RETURN 0;
END
GO
