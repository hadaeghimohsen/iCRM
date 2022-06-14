SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_SHID_P]
	-- Add the parameters for the stored procedure here
	@Shis_Rqst_Rqid BIGINT
  ,@Shis_Rwno SMALLINT
  ,@Sstt_Mstt_Sub_Sys SMALLINT
  ,@Sstt_Mstt_Code SMALLINT
  ,@Sstt_Code SMALLINT  
  ,@From_Date DATETIME
  ,@To_Date DATETIME
  ,@Sstt_Desc NVARCHAR(500)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    INSERT INTO dbo.Step_History_Detail
            ( SHIS_RQST_RQID ,
              SHIS_RWNO ,
              RWNO ,
              SSTT_MSTT_SUB_SYS ,
              SSTT_MSTT_CODE ,
              SSTT_CODE ,
              FROM_DATE ,
              TO_DATE ,
              SSTT_DESC 
            )
    VALUES  ( @Shis_Rqst_Rqid , -- SHIS_RQST_RQID - bigint
              @Shis_Rwno , -- SHIS_RWNO - smallint
              0 , -- RWNO - smallint
              @Sstt_Mstt_Sub_Sys , -- SSTT_MSTT_SUB_SYS - smallint
              @Sstt_Mstt_Code , -- SSTT_MSTT_CODE - smallint
              @Sstt_Code , -- SSTT_CODE - smallint
              @From_Date , -- FROM_DATE - datetime
              @To_Date , -- TO_DATE - datetime
              @Sstt_Desc 
            );
    UPDATE dbo.Request
       SET SSTT_MSTT_CODE = @Sstt_Mstt_Code
          ,SSTT_CODE = @Sstt_Code
     WHERE RQID = @Shis_Rqst_Rqid;
END
GO
