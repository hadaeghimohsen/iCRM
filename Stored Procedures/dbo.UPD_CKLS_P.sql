SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPD_CKLS_P]
	-- Add the parameters for the stored procedure here
   @Ckid BIGINT,
   @Colb_Clid BIGINT,
   @Ckls_Desc NVARCHAR(250),
   @Stat VARCHAR(3),
   @Prct_Valu INT
AS
BEGIN
 	UPDATE dbo.Check_List
 	   SET CKLS_DESC = @Ckls_Desc
 	      ,STAT = @Stat
 	      ,PRCT_VALU = @Prct_Valu
 	 WHERE CKID = @Ckid
 	   AND COLB_CLID = @Colb_Clid;
   RETURN 0;
END
GO
