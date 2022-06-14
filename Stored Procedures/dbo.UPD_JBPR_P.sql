SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPD_JBPR_P]
   @Code BIGINT
  ,@Rec_Stat VARCHAR(3)
  ,@Jbpr_Desc NVARCHAR(250)
AS
BEGIN
   UPDATE dbo.Job_Personnel_Relation
      SET REC_STAT = @Rec_Stat
         ,JBPR_DESC = @Jbpr_Desc
    WHERE CODE = @Code;
END
GO
