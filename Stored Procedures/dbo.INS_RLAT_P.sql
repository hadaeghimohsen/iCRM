SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_RLAT_P]
	-- Add the parameters for the stored procedure here
	@Serv_File_No BIGINT,
	@Comp_Code BIGINT,
	@Rlat_Serv_File_No BIGINT,
	@Rlat_Comp_Code BIGINT,
	@Rlt1_Apbs_Code BIGINT,
	@Rlt2_Apbs_Code BIGINT
AS
BEGIN	
   DECLARE @RefCode BIGINT = NULL;
   L$INSRLAT:
   INSERT INTO dbo.Relation_Info
           ( SERV_FILE_NO ,
             COMP_CODE ,
             RLAT_SERV_FILE_NO ,
             RLAT_COMP_CODE ,
             APBS_CODE ,
             REF_CODE ,
             CODE              
           )
   VALUES  ( @Serv_File_No , -- SERV_FILE_NO - bigint
             @Comp_Code , -- COMP_CODE - bigint
             @Rlat_Serv_File_No , -- RLAT_SERV_FILE_NO - bigint
             @Rlat_Comp_Code , -- RLAT_COMP_CODE - bigint
             @Rlt1_Apbs_Code , -- APBS_CODE - bigint
             @RefCode,
             0  -- CODE - bigint
           );
   -- اگر رابطه دو طرف مشخص شده باشد
   DECLARE @Tmp BIGINT;
   IF @Rlt2_Apbs_Code IS NOT NULL
   BEGIN
      SELECT TOP 1 
             @RefCode = CODE
        FROM dbo.Relation_Info
       WHERE CRET_BY = UPPER(SUSER_NAME())
    ORDER BY CRET_DATE DESC;
    
      IF @Serv_File_No IS NOT NULL 
      BEGIN
         -- Service Relation         
         IF @Rlat_Serv_File_No IS NOT NULL
         BEGIN
            SET @Tmp = @Rlat_Serv_File_No;
            SET @Rlat_Serv_File_No = @Serv_File_No;
            SET @Serv_File_No = @Tmp;
         END
         -- Company Relation
         ELSE IF @Rlat_Comp_Code IS NOT NULL
         BEGIN            
            SET @Comp_Code = @Rlat_Comp_Code;
            SET @Rlat_Serv_File_No = @Serv_File_No;
            SET @Serv_File_No = NULL;
            SET @Rlat_Comp_Code = NULL;
         END         
      END
      ELSE IF @Comp_Code IS NOT NULL
      BEGIN
         -- Service Relation         
         IF @Rlat_Serv_File_No IS NOT NULL
         BEGIN            
            SET @Serv_File_No = @Rlat_Serv_File_No;
            SET @Rlat_Comp_Code = @Comp_Code;
            SET @Comp_Code = NULL;
            SET @Rlat_Serv_File_No = NULL;
         END
         -- Company Relation
         ELSE IF @Rlat_Comp_Code IS NOT NULL
         BEGIN            
            SET @Tmp = @Rlat_Comp_Code;
            SET @Rlat_Comp_Code = @Comp_Code;
            SET @Comp_Code = @Tmp;
         END         
      END
      
      SET @Rlt1_Apbs_Code = @Rlt2_Apbs_Code;
      SET @Rlt2_Apbs_Code = NULL;
      GOTO L$INSRLAT;
   END
END
GO
