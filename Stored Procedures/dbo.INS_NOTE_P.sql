SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[INS_NOTE_P]
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
      BEGIN TRAN T_INS_NOTE_P;
      
      INSERT INTO dbo.Note
              ( RQRO_RQST_RQID ,
                RQRO_RWNO ,
                SERV_FILE_NO ,
                SRPB_RWNO_DNRM ,
                SRPB_RECT_CODE_DNRM ,
                COMP_CODE_DNRM ,
                MKLT_MLID ,
                CAMP_CMID ,
                CAMQ_QCID ,
                CNLN_CLID ,
                CMPT_CODE ,
                NOTE_DATE ,
                NOTE_SUBJ ,
                NOTE_CMNT 
              )
      VALUES  ( @Rqro_Rqst_Rqid , -- RQRO_RQST_RQID - bigint
                @Rqro_Rwno , -- RQRO_RWNO - smallint
                @Serv_File_No , -- SERV_FILE_NO - bigint
                @Srpb_Rwno_Dnrm , -- SRPB_RWNO_DNRM - int
                @Srpb_Rect_Code_Dnrm , -- SRPB_RECT_CODE_DNRM - varchar(3)
                @Comp_Code_Dnrm , -- COMP_CODE_DNRM - bigint
                @Mklt_Mlid , -- MKLT_MLID - bigint
                @Camp_Cmid , -- CAMP_CMID - bigint
                @Camq_Qcid , -- CAMQ_QCID - bigint
                @Cnln_Clid , -- LEAD_LDID - bigint
                @Cmpt_Code , -- CMPT_CODE - bigint
                @Note_Date , -- NOTE_DATE - datetime
                @Note_Subj ,
                @Note_Cmnt  -- NOTE_CMNT - nvarchar(1000)
              );
      
      COMMIT TRAN T_INS_NOTE_P;
      RETURN 0;   
   END TRY
   BEGIN CATCH
      DECLARE @ErorMesg NVARCHAR(MAX);
      SET @ErorMesg = ERROR_MESSAGE();
      RAISERROR ( @ErorMesg, -- Message text.
               16, -- Severity.
               1 -- State.
               );
      ROLLBACK TRAN T_INS_NOTE_P;
      RETURN -1;
   END CATCH;   
END;
   
GO
