SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_SRPR_P]
	@Rqro_Rqst_Rqid BIGINT
  ,@Rqro_Rwno SMALLINT	
  ,@Jbpr_Code BIGINT
  ,@Rajp_Desc NVARCHAR(500)
AS
BEGIN	
	-- بررسی دسترسی
	
	MERGE dbo.Service_Project T
	USING (SELECT @Rqro_Rqst_Rqid AS RQRO_RQST_RQID, @Rqro_Rwno AS RQRO_RWNO, @Jbpr_Code AS JBPR_CODE) S
	ON (T.RQRO_RQST_RQID = S.RQRO_RQST_RQID AND
	    T.RQRO_RWNO = S.RQRO_RWNO AND
	    T.JBPR_CODE = S.JBPR_CODE)
	WHEN NOT MATCHED THEN
	   INSERT (RQRO_RQST_RQID, RQRO_RWNO, JBPR_CODE, CODE, REC_STAT, RAJP_DESC)
	   VALUES (s.RQRO_RQST_RQID, S.RQRO_RWNO, s.JBPR_CODE, 0, '002', @Rajp_Desc);
END
GO
