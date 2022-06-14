SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_FINR_P]
	-- Add the parameters for the stored procedure here
	@Rqro_Rqst_Rqid BIGINT,
	@Rqro_Rwno SMALLINT,
	@Serv_File_No BIGINT,
	@Finr_Stat VARCHAR(3),
	@Finr_Type VARCHAR(3),
	@Finr_Type_Stat VARCHAR(3),
	@Finr_Cmnt NVARCHAR(4000)
AS
BEGIN
   IF @Serv_File_No IS NULL OR @Serv_File_No = 0
      SELECT @Serv_File_No = SERV_FILE_NO
        FROM dbo.Request_Row
       WHERE RQST_RQID = @Rqro_Rqst_Rqid
         AND RWNO = @Rqro_Rwno;
         
   INSERT INTO dbo.Final_Result
           ( RQRO_RQST_RQID ,
             RQRO_RWNO ,
             SERV_FILE_NO ,
             FINR_STAT ,
             FINR_TYPE ,
             FINR_TYPE_STAT ,
             FINR_CMNT              
           )
   VALUES  ( @Rqro_Rqst_Rqid , -- RQRO_RQST_RQID - bigint
             @Rqro_Rwno , -- RQRO_RWNO - smallint
             @Serv_File_No , -- SERV_FILE_NO - bigint
             @Finr_Stat , -- FINR_STAT - varchar(3)
             @Finr_Type ,
             ISNULL(@Finr_Type_Stat, '001') ,
             @Finr_Cmnt  -- FINR_CMNT - nvarchar(1000)
           );
END
GO
