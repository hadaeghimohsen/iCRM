SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[DEL_CAMP_P]
   @Cmid BIGINT   
AS 
BEGIN
   BEGIN TRY
      BEGIN TRAN T_DEL_CAMP_P;
      DELETE dbo.Campaign      
       WHERE CMID = @Cmid;
      
      COMMIT TRAN T_DEL_CAMP_P;
      RETURN 0;
   END TRY
   BEGIN CATCH 
      DECLARE @ErorMesg NVARCHAR(Max);
	   SET @ErorMesg = ERROR_MESSAGE();
      RAISERROR ( @ErorMesg, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN T_DEL_CAMP_P;
      RETURN -1;
   END CATCH;
END;

   
GO
