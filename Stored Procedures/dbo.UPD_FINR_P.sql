SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPD_FINR_P]
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
   UPDATE dbo.Final_Result
      SET FINR_STAT = @Finr_Stat
         ,FINR_TYPE = @Finr_Type
         ,FINR_TYPE_STAT = ISNULL(@Finr_Type_Stat, '001')
         ,FINR_CMNT = @Finr_Cmnt
    WHERE RQRO_RQST_RQID = @Rqro_Rqst_Rqid
      AND RQRO_RWNO = @Rqro_Rwno;
END
GO
