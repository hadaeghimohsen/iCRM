SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[DEL_SHIS_P]
	-- Add the parameters for the stored procedure here
	@Rqst_Rqid BIGINT
  ,@Rwno SMALLINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DELETE dbo.Step_History_Summery
     WHERE RQST_RQID = @Rqst_Rqid
       AND RWNO = @Rwno;
END
GO
