SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPD_TAG_P]
	-- Add the parameters for the stored procedure here
   @Tgid BIGINT,
   @Apbs_Code BIGINT
AS
BEGIN
   UPDATE dbo.Tag
      SET APBS_CODE = @Apbs_Code
    WHERE TGID = @Tgid;
   RETURN 0;
END
GO
