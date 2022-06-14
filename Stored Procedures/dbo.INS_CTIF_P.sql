SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_CTIF_P]
	-- Add the parameters for the stored procedure here
	@Serv_File_No BIGINT,
	@Comp_Code BIGINT,
	@Apbs_Code BIGINT,
	@Cont_Desc NVARCHAR(500)
AS
BEGIN
	IF @Serv_File_No = 0
	   SET @Serv_File_No = NULL;
	IF @Comp_Code = 0
	   SET @Comp_Code = NULL;
	
	INSERT INTO dbo.Contact_Info
	        ( COMP_CODE ,
	          SERV_FILE_NO ,
	          APBS_CODE ,
	          CODE ,
	          CONT_DESC 
	        )
	VALUES  ( @Comp_Code , -- COMP_CODE - bigint
	          @Serv_File_No , -- SERV_FILE_NO - bigint
	          @Apbs_Code , -- APBS_CODE - bigint
	          0 , -- CODE - bigint
	          @Cont_Desc  -- CONT_DESC - nvarchar(500)
	        );
END
GO
