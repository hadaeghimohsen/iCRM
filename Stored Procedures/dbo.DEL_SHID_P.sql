SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[DEL_SHID_P]
	-- Add the parameters for the stored procedure here
	@Shis_Rqst_Rqid BIGINT
  ,@Shis_Rwno SMALLINT
  ,@Rwno SMALLINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DELETE dbo.Step_History_Detail
     WHERE SHIS_RQST_RQID = @Shis_Rqst_Rqid
       AND SHIS_RWNO = @Shis_Rwno
       AND RWNO = @Rwno;
END
GO
