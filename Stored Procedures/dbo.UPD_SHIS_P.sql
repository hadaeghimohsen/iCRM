SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPD_SHIS_P]
	-- Add the parameters for the stored procedure here
	@Rqst_Rqid BIGINT
  ,@Rwno SMALLINT
  ,@From_Date DATETIME
  ,@To_Date DATETIME
  ,@Mstt_Desc NVARCHAR(500)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    UPDATE dbo.Step_History_Summery
       SET FROM_DATE = @From_Date
          ,TO_DATE = @To_Date
          ,MSTT_DESC = @Mstt_Desc
     WHERE RQST_RQID = @Rqst_Rqid
       AND RWNO = @Rwno;
END
GO
