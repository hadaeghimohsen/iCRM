SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SET_PIMG_P]
   @X XML
AS
BEGIN
   DECLARE @FileNo BIGINT
          ,@RcdcRcid BIGINT
          ,@Rwno SMALLINT;
   SELECT @FileNo = @X.query('Service').value('(Service/@fileno)[1]', 'BIGINT')
         ,@RcdcRcid = @X.query('Service/Image').value('(Image/@rcdcrcid)[1]', 'BIGINT')
         ,@Rwno = @X.query('Service/Image').value('(Image/@rwno)[1]', 'SMALLINT');
   
   UPDATE Service
      SET IMAG_RCDC_RCID_DNRM = @RcdcRcid
         ,IMAG_RWNO_DNRM = @Rwno
    WHERE FILE_NO = @FileNo;
END;
GO
