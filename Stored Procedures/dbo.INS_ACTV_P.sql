SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_ACTV_P]
	-- Add the parameters for the stored procedure here
	@Rqst_Rqid BIGINT,
	@Rqro_Rwno SMALLINT,
	@Actv_Code BIGINT OUT
AS
BEGIN

	INSERT INTO dbo.Activity
	        ( CODE ,
	          RQRO_RQST_RQID ,
	          RQRO_RWNO ,
	          ACTV_DATE 
	        )
	VALUES  ( 0 , -- CODE - bigint
	          @Rqst_Rqid , -- RQRO_RQST_RQID - bigint
	          @Rqro_Rwno,  -- RQRO_RWNO - smallint
	          GETDATE()
	        );
	
	SELECT @Actv_Code = Code
	FROM dbo.Activity
	WHERE Rqro_RQST_RQID = @Rqst_Rqid
	  AND RQRO_RWNO = @Rqro_Rwno;	  
END
GO
