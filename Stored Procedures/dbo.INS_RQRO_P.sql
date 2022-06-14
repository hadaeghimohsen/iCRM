SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_RQRO_P]
	-- Add the parameters for the stored procedure here
	@Rqst_Rqid BIGINT,
	@Serv_File_No BIGINT,
	@Rqro_Rwno SMALLINT OUT
AS
BEGIN

	INSERT INTO Request_Row (RQST_RQID, SERV_FILE_NO, RECD_STAT)
	VALUES (@Rqst_Rqid, @Serv_File_No, '002');
	
	SELECT @Rqro_Rwno = Rwno
	FROM Request_Row
	WHERE RQST_RQID = @Rqst_Rqid
	  AND SERV_FILE_NO = @Serv_File_No;
	  
END
GO
