SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[DEL_NOTE_P]
   @Ntid BIGINT
AS
BEGIN
   BEGIN TRY
      BEGIN TRAN T_DEL_NOTE_P;
      
      DELETE dbo.Note
       WHERE NTID = @Ntid;
      
      COMMIT TRAN T_DEL_NOTE_P;
      RETURN 0;   
   END TRY
   BEGIN CATCH
      DECLARE @ErorMesg NVARCHAR(MAX);
      SET @ErorMesg = ERROR_MESSAGE();
      RAISERROR ( @ErorMesg, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN T_DEL_NOTE_P;
      RETURN -1;
   END CATCH;   
END;
   
GO
