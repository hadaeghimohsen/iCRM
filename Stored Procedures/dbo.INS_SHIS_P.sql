SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_SHIS_P]
	-- Add the parameters for the stored procedure here
	@Rqst_Rqid BIGINT
  ,@Sstt_Mstt_Code SMALLINT
  ,@Sstt_Mstt_Sub_Sys SMALLINT
  ,@From_Date DATETIME
  ,@To_Date DATETIME
  ,@Mstt_Desc NVARCHAR(500)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO dbo.Step_History_Summery
	        ( RQST_RQID ,
	          RWNO ,
	          SSTT_MSTT_CODE ,
	          SSTT_MSTT_SUB_SYS ,
	          FROM_DATE ,
	          TO_DATE ,
	          MSTT_DESC 
	        )
	VALUES  ( @Rqst_Rqid , -- RQST_RQID - bigint
	          0 , -- RWNO - smallint
	          @Sstt_Mstt_Code , -- SSTT_MSTT_CODE - smallint
	          @Sstt_Mstt_Sub_Sys , -- SSTT_MSTT_SUB_SYS - smallint
	          @From_Date , -- FROM_DATE - datetime
	          @To_Date , -- TO_DATE - datetime
	          @Mstt_Desc  -- MSTT_DESC - nvarchar(500)
	        );
END
GO
