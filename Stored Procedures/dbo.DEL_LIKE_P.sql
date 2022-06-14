SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[DEL_LIKE_P]
	-- Add the parameters for the stored procedure here
	@Cmnt_Cmid  BIGINT
AS
BEGIN
 	DELETE dbo.[Like]
    WHERE CMNT_CMID = @Cmnt_Cmid
      AND JOBP_CODE_DNRM = (
         SELECT CODE
           FROM dbo.Job_Personnel
          WHERE UPPER(USER_NAME) = UPPER(SUSER_NAME())
            AND STAT = '002'
      );
   RETURN 0;
END
GO
