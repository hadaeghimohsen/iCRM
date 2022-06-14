SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[VF$Advance_Search_Request_Changing](
   /*@Rqid BIGINT,
   @FileNo BIGINT,
   @CompCode BIGINT,
   @RqtpCode VARCHAR(3),
   @TextSearch NVARCHAR(MAX)*/
   @X XML
)
RETURNS TABLE
AS RETURN
(
WITH QXML AS
   (
      SELECT @X.query('//Request').value('(Request/@rqid)[1]',         'BIGINT') AS RQID
            ,@X.query('//Request').value('(Request/@rqtpcode)[1]',     'VARCHAR(3)') AS RQTP_CODE
            ,@X.query('//Request').value('(Request/@rqttcode)[1]',     'VARCHAR(3)') AS RQTT_CODE
            ,@X.query('//Request').value('(Request/@rqstrqid)[1]',     'BIGINT') AS RQST_RQID
            ,@X.query('//Request').value('(Request/@regncode)[1]',     'VARCHAR(3)') AS REGN_CODE
            ,@X.query('//Request').value('(Request/@prvncode)[1]',     'VARCHAR(3)') AS PRVN_CODE
            ,@X.query('//Request').value('(Request/@subsys)[1]',       'SMALLINT') AS SUB_SYS
            ,@X.query('//Request').value('(Request/@ssttmsttcode)[1]', 'SMALLINT') AS SSTT_MSTT_CODE
            ,@X.query('//Request').value('(Request/@ssttcode)[1]',     'SMALLINT') AS SSTT_CODE
            ,@X.query('//Request').value('(Request/@year)[1]',         'SMALLINT') AS [YEAR]
            ,@X.query('//Request').value('(Request/@cycl)[1]',         'VARCHAR(3)') AS CYCL
            ,@X.query('//Request').value('(Request/@cretby)[1]',       'VARCHAR(250)') AS CRET_BY
            ,@X.query('//Request').value('(Request/@mdfyby)[1]',       'VARCHAR(250)') AS MDFY_BY
            ,@X.query('//Request_Row').value('(Request_Row/@servfileno)[1]', 'BIGINT') AS SERV_FILE_NO
            ,@X.query('//Company').value('(Company/@code)[1]', 'BIGINT') AS COMP_CODE
            ,@X.query('//Query_String').value('(Query_String/@textsrch)[1]', 'NVARCHAR(MAX)') AS TEXT_SRCH
            ,@X.query('//Tags').value('(Tags/@cont)[1]', 'BIGINT') AS TAG_CONT
            ,@X.query('//Regions').value('(Regions/@cont)[1]', 'BIGINT') AS REGION_CONT
   )
SELECT  Rqtp.CODE AS RQTP_CODE, 
        Rqtp.RQTP_DESC, 
        R.RQID, 
        Rqtt.CODE AS RQTT_CODE,
        Rqtt.RQTT_DESC,
        R.RQST_DATE, 
        R.SAVE_DATE,
        R.CRET_BY,
        S.FILE_NO,
        S.NAME_DNRM,
        S.CELL_PHON_DNRM,
        Rr.COMP_CODE,
        C.NAME AS COMP_NAME,
        C.POST_ADRS AS COMP_POST_ADRS
  FROM  dbo.Request R INNER JOIN
        dbo.Request_Row Rr ON R.RQID = Rr.RQST_RQID INNER JOIN
        dbo.Request_Type Rqtp ON R.RQTP_CODE = Rqtp.CODE INNER JOIN
        dbo.Requester_Type Rqtt ON R.RQTT_CODE = Rqtt.CODE INNER JOIN
        dbo.Service S ON Rr.SERV_FILE_NO = S.FILE_NO LEFT OUTER JOIN
        dbo.Company C ON C.CODE = Rr.COMP_CODE ,
        QXML Qx
WHERE  (Rr.RECD_STAT = '002') 
  AND  (R.RQST_STAT = '002')
  AND  (S.CONF_STAT = '002')
  AND  (Qx.RQID IS NULL OR R.RQID = QX.RQID)
  AND  (Qx.SERV_FILE_NO IS NULL OR S.FILE_NO = Qx.SERV_FILE_NO)
  AND  (Qx.COMP_CODE IS NULL OR Rr.COMP_CODE = Qx.COMP_CODE)
  AND  (Qx.RQTP_CODE IS NULL OR R.RQTP_CODE = Qx.RQTP_CODE)
  AND  (
         -- Request_Type
         Rqtp.RQTP_DESC LIKE qx.TEXT_SRCH OR 
         -- Service
         S.NAME_DNRM LIKE qx.TEXT_SRCH OR
         s.CELL_PHON_DNRM LIKE qx.TEXT_SRCH OR
         s.TELL_PHON_DNRM LIKE qx.TEXT_SRCH OR
         s.EMAL_ADRS_DNRM LIKE qx.TEXT_SRCH OR
         s.FACE_BOOK_URL_DNRM LIKE qx.TEXT_SRCH OR
         s.LINK_IN_URL_DNRM LIKE qx.TEXT_SRCH OR
         s.TWTR_URL_DNRM LIKE Qx.TEXT_SRCH OR
         s.NATL_CODE_DNRM LIKE qx.TEXT_SRCH OR          
         -- Company
         c.NAME LIKE qx.TEXT_SRCH OR
         c.POST_ADRS LIKE qx.TEXT_SRCH OR 
         c.EMAL_ADRS LIKE qx.TEXT_SRCH OR
         c.WEB_SITE LIKE qx.TEXT_SRCH OR
         c.ZIP_CODE LIKE qx.TEXT_SRCH OR
         c.ECON_CODE LIKE qx.TEXT_SRCH OR 
         c.FACE_BOOK_URL LIKE qx.TEXT_SRCH OR 
         c.LINK_IN_URL LIKE qx.TEXT_SRCH OR
         c.TWTR_URL LIKE qx.TEXT_SRCH OR 
         -- Contact Info
         EXISTS (
            SELECT *
              FROM dbo.Contact_Info ci
             WHERE (SERV_FILE_NO = s.FILE_NO OR ci.COMP_CODE = c.CODE)
               AND ci.CONT_DESC LIKE qx.TEXT_SRCH            
         ) 
       )
  
  AND  (Qx.REGION_CONT = 0 OR
      EXISTS(
         SELECT * 
           FROM dbo.Region r, @x.nodes('//Region') rx(r)
          WHERE r.CODE = rx.r.query('.').value('(Region/@code)[1]', 'VARCHAR(3)')
            AND r.PRVN_CODE = rx.r.query('.').value('(Region/@prvncode)[1]', 'VARCHAR(3)')
            AND r.PRVN_CNTY_CODE = rx.r.query('.').value('(Region/@cntycode)[1]', 'VARCHAR(3)')
            AND (
               (s.REGN_PRVN_CNTY_CODE = r.PRVN_CNTY_CODE AND s.REGN_PRVN_CODE = r.PRVN_CODE AND s.REGN_CODE = r.CODE) OR
               (c.REGN_PRVN_CNTY_CODE = r.PRVN_CNTY_CODE AND c.REGN_PRVN_CODE = r.PRVN_CODE AND c.REGN_CODE = r.CODE)
            )
      )
  )
  AND  (Qx.TAG_CONT = 0 OR 
      EXISTS(
		   SELECT *
		     FROM Tag t, @x.nodes('//Tag') tx(r)
		    WHERE t.TGID = tx.r.query('.').value('(Tag/@tgid)[1]', 'BIGINT')
		      AND (
			   (/*T.SERV_FILE_NO IS NULL OR */T.SERV_FILE_NO = S.FILE_NO) OR
			   (/*T.COMP_CODE_DNRM IS NULL OR */T.COMP_CODE_DNRM = c.CODE)			
		      )
	   )
  )
  AND  (
         (
            R.RQTP_CODE IN ( '001', '002', '003', '004' ) AND
            EXISTS(
               SELECT *
                 FROM dbo.Service_Public a
                WHERE a.RQRO_RQST_RQID = R.RQID
                  AND a.RQRO_RWNO = Rr.RWNO
                  AND a.RECT_CODE = '004'                  
                  AND ( a.FRST_NAME LIKE Qx.TEXT_SRCH OR
                        a.LAST_NAME LIKE Qx.TEXT_SRCH OR
                        a.FATH_NAME LIKE Qx.TEXT_SRCH OR
                        a.NATL_CODE LIKE Qx.TEXT_SRCH OR
                        a.CELL_PHON LIKE Qx.TEXT_SRCH OR
                        a.TELL_PHON LIKE Qx.TEXT_SRCH OR 
                        a.IDTY_CODE LIKE Qx.TEXT_SRCH OR 
                        a.POST_ADRS LIKE Qx.TEXT_SRCH OR
                        a.EMAL_ADRS LIKE Qx.TEXT_SRCH OR
                        a.FACE_BOOK_URL LIKE Qx.TEXT_SRCH OR
                        a.LINK_IN_URL LIKE Qx.TEXT_SRCH OR
                        a.TWTR_URL LIKE Qx.TEXT_SRCH
                  )
            )
         ) OR
         (
            R.RQTP_CODE = '005' AND
            EXISTS(
               SELECT *
                 FROM dbo.Log_Call a
                WHERE a.RQRO_RQST_RQID = R.RQID
                  AND a.RQRO_RWNO = Rr.RWNO
                  AND ( a.SUBJ_DESC LIKE Qx.TEXT_SRCH OR
                        a.LOG_CMNT LIKE Qx.TEXT_SRCH )
            )
         ) OR
         (
            R.RQTP_CODE = '006' AND
            EXISTS(
               SELECT *
                 FROM dbo.Send_File a
                WHERE a.RQRO_RQST_RQID = R.RQID
                  AND a.RQRO_RWNO = Rr.RWNO
                  AND ( a.SUBJ_DESC LIKE Qx.TEXT_SRCH OR
                        a.URL_NAME LIKE Qx.TEXT_SRCH )
            )
         ) OR
         (
            R.RQTP_CODE = '007' AND
            EXISTS(
               SELECT *
                 FROM dbo.Appointment a
                WHERE a.RQRO_RQST_RQID = R.RQID
                  AND a.RQRO_RWNO = Rr.RWNO
                  AND ( a.SUBJ_DESC LIKE Qx.TEXT_SRCH OR
                        a.APON_CMNT LIKE Qx.TEXT_SRCH OR
                        a.APON_WHER LIKE Qx.TEXT_SRCH )
            )
         ) OR
         (
            R.RQTP_CODE = '008' AND
            EXISTS(
               SELECT *
                 FROM dbo.Note a
                WHERE a.RQRO_RQST_RQID = R.RQID
                  AND a.RQRO_RWNO = Rr.RWNO
                  AND a.NOTE_CMNT LIKE Qx.TEXT_SRCH
            )
         ) OR
         (
            R.RQTP_CODE = '009' AND
            EXISTS(
               SELECT *
                 FROM dbo.Task a
                WHERE a.RQRO_RQST_RQID = R.RQID
                  AND a.RQRO_RWNO = Rr.RWNO
                  AND ( a.SUBJ_DESC LIKE Qx.TEXT_SRCH OR
                        a.TASK_CMNT LIKE Qx.TEXT_SRCH )
            )
         ) OR
         (
            R.RQTP_CODE = '010' AND
            EXISTS(
               SELECT *
                 FROM dbo.Email a
                WHERE a.RQRO_RQST_RQID = R.RQID
                  AND a.RQRO_RWNO = Rr.RWNO
                  AND ( a.SUBJ_DESC LIKE Qx.TEXT_SRCH OR
                        a.EMAL_CMNT LIKE Qx.TEXT_SRCH )
            )
         ) OR
         (
            R.RQTP_CODE = '011' AND
            EXISTS(
               SELECT *
                 FROM dbo.Payment a
                WHERE a.RQST_RQID = R.RQID
                  AND ( a.PYMT_DESC LIKE Qx.TEXT_SRCH OR
                        a.PYMT_LOST_DESC LIKE Qx.TEXT_SRCH )
            )
         ) OR
         (
            R.RQTP_CODE = '012' AND
            EXISTS(
               SELECT *
                 FROM dbo.[Message] a
                WHERE a.RQRO_RQST_RQID = R.RQID
                  AND a.RQRO_RWNO = Rr.RWNO
                  AND ( a.MESG_CMNT LIKE Qx.TEXT_SRCH OR
                        a.CELL_PHON LIKE Qx.TEXT_SRCH )
            )
         ) 
       )
)
GO
