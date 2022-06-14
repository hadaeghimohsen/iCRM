SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_CKLS_P]
	-- Add the parameters for the stored procedure here
   @Colb_Clid BIGINT,
   @Ckls_Desc NVARCHAR(250),
   @Stat VARCHAR(3),
   @Prct_Valu INT
AS
BEGIN
 	INSERT dbo.Check_List
 	        ( COLB_CLID ,
 	          CKLS_DESC ,
 	          STAT ,
 	          PRCT_VALU 
 	        )
 	VALUES  ( @Colb_Clid , -- COLB_CLID - bigint
 	          @Ckls_Desc , -- CKLS_DESC - nvarchar(250)
 	          @Stat , -- STAT - varchar(3)
 	          @Prct_Valu  -- PRCT_VALU - int
 	        );
   RETURN 0;
END
GO
