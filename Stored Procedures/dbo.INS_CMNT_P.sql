SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_CMNT_P]
	-- Add the parameters for the stored procedure here
   @Rqro_Rqst_Rqid BIGINT,
   @Rqro_Rwno SMALLINT,
   @Cmnt NVARCHAR(MAX)
AS
BEGIN
 	INSERT dbo.Comment
 	        ( RQRO_RQST_RQID ,
 	          RQRO_RWNO ,
 	          CMNT 
 	        )
 	VALUES  ( @Rqro_Rqst_Rqid , -- RQRO_RQST_RQID - bigint
 	          @Rqro_Rwno , -- RQRO_RWNO - smallint
 	          @Cmnt  -- CMNT - nvarchar(max)
 	        );
   RETURN 0;
END
GO
