SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPD_RQRO_P]
	@Rqst_Rqid BIGINT,
	@SERV_File_No BIGINT,
	@Recd_Stat VARCHAR(3)
AS
BEGIN
	UPDATE Request_Row
	   SET RECD_STAT = @Recd_Stat
	 WHERE RQST_RQID = @Rqst_Rqid
	   AND SERV_FILE_NO = @SERV_File_No;
END
GO
