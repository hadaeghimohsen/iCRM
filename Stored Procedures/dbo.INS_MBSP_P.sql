SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_MBSP_P]
	@Rqid BIGINT
  ,@RqroRwno SMALLINT
  ,@FileNo BIGINT
  ,@RectCode VARCHAR(3)
  ,@Type     VARCHAR(3)
  ,@StrtDate DATE
  ,@EndDate  DATE
  ,@NumbMontOfer INT
  ,@VolmOfTrfc INT
AS
BEGIN 
   DECLARE @ERORMESG  NVARCHAR(250);
   IF EXISTS(SELECT * FROM Request WHERE RQID = @Rqid AND RQTT_CODE != '004' ) AND 
      (SELECT COUNT(*) 
         FROM Service F, Member_Ship Mb 
        WHERE F.FILE_NO = Mb.SERV_FILE_NO 
          AND Mb.SERV_FILE_NO = @FileNo 
          AND Mb.RECT_CODE = '004' 
          AND F.MBSP_RWNO_DNRM = Mb.RWNO 
          AND TYPE = @Type 
          AND END_DATE >= @StrtDate) >= 1
   BEGIN
      SET @ERORMESG = N' تاریخ اعتبار شماره ردیف ' + CAST(@RqroRwno AS VARCHAR(3)) + N' درخواست همچنان معتبر می باشد. نیازی به تمدید مجدد نیست';      
      RAISERROR(@ERORMESG, 16, 1);
      RETURN;
   END
   INSERT INTO Member_Ship (RQRO_RQST_RQID, RQRO_RWNO, SERV_FILE_NO, RECT_CODE, TYPE, STRT_DATE, END_DATE, NUMB_MONT_OFER, [VOLM_OF_TRFC])
   VALUES                  (@Rqid,          @RqroRwno, @FileNo     , @RectCode, @Type, @StrtDate, @EndDate, @NumbMontOfer, @VolmOfTrfc);
END
GO
