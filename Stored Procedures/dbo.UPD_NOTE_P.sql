SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[UPD_NOTE_P]
   @Ntid BIGINT,
   @Rqro_Rqst_Rqid BIGINT,
   @Rqro_Rwno SMALLINT,
   @Serv_File_No BIGINT,
   @Srpb_Rwno_Dnrm INT,
   @Srpb_Rect_Code_Dnrm VARCHAR(3),
   @Comp_Code_Dnrm BIGINT,
   @Mklt_Mlid BIGINT,
   @Camp_Cmid BIGINT,
   @Camq_Qcid BIGINT,
   @Cnln_Clid BIGINT,
   @Cmpt_Code BIGINT,
   @Note_Date DATETIME,
   @Note_Subj NVARCHAR(250),
   @Note_Cmnt NVARCHAR(1000)
AS
BEGIN
   BEGIN TRY
      BEGIN TRAN T_UPD_NOTE_P;
      
      UPDATE dbo.Note
         SET RQRO_RQST_RQID = @Rqro_Rqst_Rqid
            ,RQRO_RWNO = @Rqro_Rwno
            ,SERV_FILE_NO = @Serv_File_No
            ,SRPB_RWNO_DNRM = @Srpb_Rwno_Dnrm
            ,SRPB_RECT_CODE_DNRM = @Srpb_Rect_Code_Dnrm
            ,COMP_CODE_DNRM = @Comp_Code_Dnrm
            ,MKLT_MLID = @Mklt_Mlid
            ,CAMP_CMID = @Camp_Cmid
            ,CAMQ_QCID = @Camq_Qcid
            ,CNLN_CLID = @Cnln_Clid
            ,CMPT_CODE = @Cmpt_Code
            ,NOTE_DATE = @Note_Date
            ,NOTE_SUBJ = @Note_Subj
            ,NOTE_CMNT = @Note_Cmnt
       WHERE NTID = @Ntid;
      
      COMMIT TRAN T_UPD_NOTE_P;
      RETURN 0;   
   END TRY
   BEGIN CATCH
      DECLARE @ErorMesg NVARCHAR(MAX);
      SET @ErorMesg = ERROR_MESSAGE();
      RAISERROR ( @ErorMesg, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN T_UPD_NOTE_P;
      RETURN -1;
   END CATCH;   
END;
   
GO
