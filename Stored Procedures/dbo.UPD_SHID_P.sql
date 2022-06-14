SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPD_SHID_P]
	-- Add the parameters for the stored procedure here
	@Shis_Rqst_Rqid BIGINT
  ,@Shis_Rwno SMALLINT
  ,@Rwno SMALLINT
  ,@From_Date DATETIME
  ,@To_Date DATETIME
  ,@Sstt_Desc NVARCHAR(500)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    UPDATE dbo.Step_History_Detail
       SET FROM_DATE = @From_Date
          ,TO_DATE = @To_Date
          ,SSTT_DESC = @Sstt_Desc
     WHERE SHIS_RQST_RQID = @Shis_Rqst_Rqid
       AND SHIS_RWNO = @Shis_Rwno
       AND RWNO = @Rwno;
END
GO
