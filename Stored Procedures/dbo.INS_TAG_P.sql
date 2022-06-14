SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_TAG_P]
	-- Add the parameters for the stored procedure here
   @Rqro_Rqst_Rqid BIGINT,
   @Rqro_Rwno SMALLINT,
   @Serv_File_No BIGINT,
   @Comp_Code_Dnrm BIGINT,
   @Apbs_Code BIGINT
AS
BEGIN
   IF @Serv_File_No IS NULL   
      SELECT @Serv_File_No = Serv_File_No
        FROM dbo.Request_Row
       WHERE RQST_RQID = @Rqro_Rqst_Rqid
         AND RWNO = @Rqro_Rwno;
   
   IF @Comp_Code_Dnrm = 0
      SET @Comp_Code_Dnrm = NULL;   
      
 	INSERT dbo.Tag
 	        ( RQRO_RQST_RQID ,
 	          RQRO_RWNO ,
 	          SERV_FILE_NO, 
 	          COMP_CODE_DNRM,
 	          APBS_CODE
 	        )
 	VALUES  ( @Rqro_Rqst_Rqid , -- RQRO_RQST_RQID - bigint
 	          @Rqro_Rwno , -- RQRO_RWNO - smallint
 	          @Serv_File_No,
 	          @Comp_Code_Dnrm,
 	          @Apbs_Code
 	        );
   RETURN 0;
END
GO
