SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPD_CTIF_P]
	-- Add the parameters for the stored procedure here
	@Code BIGINT,
	@Cont_Desc NVARCHAR(500)
AS
BEGIN	
   UPDATE dbo.Contact_Info
      SET CONT_DESC = @Cont_Desc
    WHERE CODE = @Code;
END
GO
