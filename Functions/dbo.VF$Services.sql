SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[VF$Services]
(	
	@X XML
)
RETURNS TABLE 
AS
RETURN 
(
   /*
    <Service fileno=""/>
    */
   WITH QXML AS
   (
      SELECT @X.query('//Service').value('(Service/@fileno)[1]', 'BIGINT') AS File_No
            ,@X.query('//Service').value('(Service/@onoftag)[1]', 'VARCHAR(3)') AS Onof_Tag
            ,@X.query('//Service').value('(Service/@srpbtype)[1]', 'VARCHAR(3)') AS Srpb_Type
            
            ,@X.query('//Service').value('(Service/@frstname)[1]', 'NVARCHAR(250)') AS Frst_Name
            ,@X.query('//Service').value('(Service/@lastname)[1]', 'NVARCHAR(250)') AS Last_Name
            ,@X.query('//Service').value('(Service/@sextype)[1]', 'VARCHAR(3)') AS Sex_Type
            ,@X.query('//Service').value('(Service/@cellphon)[1]', 'VARCHAR(11)') AS Cell_Phon
            ,@X.query('//Service').value('(Service/@tellphon)[1]', 'VARCHAR(11)') AS Tell_Phon
            ,@X.query('//Service').value('(Service/@natlcode)[1]', 'VARCHAR(10)') AS Natl_Code
            ,@X.query('//Service').value('(Service/@servno)[1]', 'VARCHAR(10)') AS Serv_No
            ,@X.query('//Service').value('(Service/@postaddr)[1]', 'NVARCHAR(1000)') AS Post_Addr
            ,@X.query('//Service').value('(Service/@cordx)[1]', 'FLOAT') AS Cord_X
            ,@X.query('//Service').value('(Service/@cordy)[1]', 'FLOAT') AS Cord_Y
            ,@X.query('//Service').value('(Service/@radsnumb)[1]', 'INT') AS Rads_Numb
            ,@X.query('//Service').value('(Service/@emaladdr)[1]', 'VARCHAR(250)') AS Emal_Addr
            ,@X.query('//Service').value('(Service/@confdate)[1]', 'DATE') AS Conf_Date
            
            ,@X.query('//Requests').value('(Requests/@cont)[1]', 'BIGINT') AS PROJ_RQST_CONT
            ,@X.query('//Requests').value('(Requests/@allany)[1]', 'VARCHAR(3)') AS PROJ_RQST_ALLANY
            
            ,@X.query('//Company').value('(Company/@code)[1]', 'BIGINT') AS Comp_Code
            ,@X.query('//Tags').value('(Tags/@cont)[1]', 'BIGINT') AS TAG_CONT
            ,@X.query('//Tags').value('(Tags/@allany)[1]', 'VARCHAR(3)') AS TAG_ALLANY
            ,@X.query('//Regions').value('(Regions/@cont)[1]', 'BIGINT') AS REGN_CONT
            ,@X.query('//Extra_Infos').value('(Extra_Infos/@cont)[1]', 'BIGINT') AS EXTR_CONT
            ,@X.query('//Extra_Infos').value('(Extra_Infos/@allany)[1]', 'VARCHAR(3)') AS EXTR_ALLANY
            ,@X.query('//Contact_Infos').value('(Contact_Infos/@cont)[1]', 'BIGINT') AS CNTC_CONT
            ,@X.query('//Contact_Infos').value('(Contact_Infos/@allany)[1]', 'VARCHAR(3)') AS CNTC_ALLANY
   )
	SELECT S.FILE_NO, s.FRST_NAME_DNRM, s.LAST_NAME_DNRM, s.CELL_PHON_DNRM, s.TELL_PHON_DNRM, 
	       c.NAME AS COMP_NAME, rt.RQTP_DESC, s.CRET_BY, S.SERV_STAG_CODE, S.SRPB_TYPE_DNRM,
	       s.ONOF_TAG_DNRM, s.EMAL_ADRS_DNRM, s.DEBT_DNRM, S.SERV_NO_DNRM, S.SERV_STAT, s.NAME_DNRM,
	       s.CORD_X_DNRM, s.CORD_Y_DNRM, s.NATL_CODE_DNRM
	  FROM dbo.Country co, dbo.Province pr, dbo.Region rg, Service S, dbo.Request R, dbo.Request_Type Rt, dbo.Company c , QXML QX
	 WHERE co.CODE = pr.Cnty_Code
	   AND pr.cnty_code = rg.PRVN_CNTY_CODE
	   AND pr.Code = rg.PRVN_CODE
	   AND s.REGN_PRVN_CNTY_CODE = rg.PRVN_CNTY_CODE
	   AND s.REGN_PRVN_CODE = rg.PRVN_CODE
	   AND s.REGN_CODE = rg.CODE	   
	   AND (
	         (Qx.Post_Addr IS NULL OR Qx.Post_Addr = '' OR Co.NAME LIKE N'%' + REPLACE(Qx.Post_Addr, N' ', N'%') + N'%')
	      OR (Qx.Post_Addr IS NULL OR Qx.Post_Addr = '' OR Pr.NAME LIKE N'%' + REPLACE(Qx.Post_Addr, N' ', N'%') + N'%')
	      OR (Qx.Post_Addr IS NULL OR Qx.Post_Addr = '' OR Rg.NAME LIKE N'%' + REPLACE(Qx.Post_Addr, N' ', N'%') + N'%')
	      OR (Qx.Post_Addr IS NULL OR Qx.Post_Addr = '' OR C.NAME LIKE N'%' + REPLACE(Qx.Post_Addr, N' ', N'%') + N'%')
	      OR (Qx.Post_Addr IS NULL OR Qx.Post_Addr = '' OR C.POST_ADRS LIKE N'%' + REPLACE(Qx.Post_Addr, N' ', N'%') + N'%')
	      OR (Qx.Post_Addr IS NULL OR Qx.Post_Addr = '' OR S.POST_ADRS_DNRM LIKE N'%' + Qx.Post_Addr + N'%')
	   )
	   AND S.LAST_RQST_RQID_DNRM = R.RQID
	   AND r.RQTP_CODE = rt.CODE
	   AND s.COMP_CODE_DNRM = c.CODE
	   --AND s.SRPB_TYPE_DNRM = qx.Srpb_Type
	   AND (Qx.Frst_Name IS NULL OR Qx.Frst_Name = '' OR S.FRST_NAME_DNRM LIKE N'%' + Qx.Frst_Name + N'%')
	   AND (Qx.Last_Name IS NULL OR Qx.Last_Name = '' OR S.LAST_NAME_DNRM LIKE N'%' + Qx.Last_Name + N'%')
	   AND (Qx.Sex_Type  IS NULL OR Qx.Sex_Type  = '' OR S.SEX_TYPE_DNRM  LIKE Qx.Sex_Type )
	   AND (Qx.Cell_Phon IS NULL OR Qx.Cell_Phon = '' OR S.CELL_PHON_DNRM LIKE N'%' + Qx.Cell_Phon + N'%')
	   AND (Qx.Tell_Phon IS NULL OR Qx.Tell_Phon = '' OR S.TELL_PHON_DNRM LIKE N'%' + Qx.Tell_Phon + N'%')
	   AND (Qx.Natl_Code IS NULL OR Qx.Natl_Code = '' OR S.NATL_CODE_DNRM LIKE N'%' + Qx.Natl_Code + N'%')
	   AND (Qx.Serv_No   IS NULL OR Qx.Serv_No   = '' OR S.SERV_NO_DNRM   LIKE Qx.Serv_No)
	   
	   AND (Qx.Emal_Addr IS NULL OR Qx.Emal_Addr = '' OR S.EMAL_ADRS_DNRM LIKE N'%' + Qx.Emal_Addr + N'%')
	   AND (Qx.Conf_Date IS NULL OR QX.Conf_Date = '1900-01-01' OR CAST(S.CONF_DATE AS DATE) = Qx.Conf_Date)
	   
	   AND (Qx.PROJ_RQST_CONT = 0 OR Qx.PROJ_RQST_CONT IS NULL OR
	      (
	         ( 
	            Qx.PROJ_RQST_ALLANY = 'ANY' AND 
               EXISTS(
		            SELECT *
		              FROM dbo.Request pr, dbo.Request_Row rr, dbo.Step_History_Summery shs, dbo.Step_History_Detail shd, @x.nodes('//Request') tx(r)
		             WHERE pr.RQID = rr.RQST_RQID
		               AND rr.SERV_FILE_NO = s.FILE_NO
		               AND pr.RQTP_CODE = '013'
		               AND pr.RQID = shs.RQST_RQID
		               AND shs.RQST_RQID = shd.SHIS_RQST_RQID
		               AND shs.RWNO = shd.SHIS_RWNO
		               
		               --AND pr.SSTT_MSTT_CODE = CASE tx.r.query('.').value('(Request/@mainstat)[1]', 'SMALLINT') WHEN 0 THEN pr.SSTT_MSTT_CODE ELSE tx.r.query('.').value('(Request/@mainstat)[1]', 'SMALLINT') END
		               --AND pr.SSTT_CODE = CASE tx.r.query('.').value('(Request/@substat)[1]', 'SMALLINT') WHEN 0 THEN pr.SSTT_CODE ELSE tx.r.query('.').value('(Request/@substat)[1]', 'SMALLINT') END 
		               
		               AND shd.SSTT_MSTT_CODE = CASE tx.r.query('.').value('(Request/@mainstat)[1]', 'SMALLINT') WHEN 0 THEN pr.SSTT_MSTT_CODE ELSE tx.r.query('.').value('(Request/@mainstat)[1]', 'SMALLINT') END
		               AND shd.SSTT_CODE = CASE tx.r.query('.').value('(Request/@substat)[1]', 'SMALLINT') WHEN 0 THEN pr.SSTT_CODE ELSE tx.r.query('.').value('(Request/@substat)[1]', 'SMALLINT') END 
	            )
	         ) OR
	         (
	            Qx.PROJ_RQST_ALLANY = 'ALL' AND 
               Qx.PROJ_RQST_CONT = (
		            SELECT COUNT(*)
		              FROM dbo.Request pr, dbo.Request_Row rr, dbo.Step_History_Summery shs, dbo.Step_History_Detail shd, @x.nodes('//Request') tx(r)
		             WHERE pr.RQID = rr.RQST_RQID
		               AND rr.SERV_FILE_NO = s.FILE_NO
		               AND pr.RQTP_CODE = '013'
		               AND pr.RQID = shs.RQST_RQID
		               AND shs.RQST_RQID = shd.SHIS_RQST_RQID
		               AND shs.RWNO = shd.SHIS_RWNO
		               
		               --AND pr.SSTT_MSTT_CODE = CASE tx.r.query('.').value('(Request/@mainstat)[1]', 'SMALLINT') WHEN 0 THEN pr.SSTT_MSTT_CODE ELSE tx.r.query('.').value('(Request/@mainstat)[1]', 'SMALLINT') END
		               --AND pr.SSTT_CODE = CASE tx.r.query('.').value('(Request/@substat)[1]', 'SMALLINT') WHEN 0 THEN pr.SSTT_CODE ELSE tx.r.query('.').value('(Request/@substat)[1]', 'SMALLINT') END 
		               
		               AND shd.SSTT_MSTT_CODE = CASE tx.r.query('.').value('(Request/@mainstat)[1]', 'SMALLINT') WHEN 0 THEN pr.SSTT_MSTT_CODE ELSE tx.r.query('.').value('(Request/@mainstat)[1]', 'SMALLINT') END
		               AND shd.SSTT_CODE = CASE tx.r.query('.').value('(Request/@substat)[1]', 'SMALLINT') WHEN 0 THEN pr.SSTT_CODE ELSE tx.r.query('.').value('(Request/@substat)[1]', 'SMALLINT') END 
	            )
	         )
	      )
	   
	   )
	   
	   
	   AND (Qx.Comp_Code = 0 OR S.COMP_CODE_DNRM = Qx.Comp_Code)
	   AND (
	      (QX.Onof_Tag = 'on' AND ISNULL(S.ONOF_TAG_DNRM, '101') >= '101') OR
	      (QX.Onof_Tag != 'on' AND ISNULL(S.ONOF_TAG_DNRM, '001') <= '100')
	   )
	   AND (QX.File_No IS NULL OR QX.File_No = 0 OR S.FILE_NO = QX.File_No)
	   
	   AND  (Qx.TAG_CONT = 0 OR Qx.TAG_CONT IS NULL OR
	      (
	         ( 
	            Qx.TAG_ALLANY = 'ANY' AND 
               EXISTS(
		            SELECT *
		              FROM Tag t, @x.nodes('//Tag') tx(r)
		             WHERE t.APBS_CODE = tx.r.query('.').value('(Tag/@apbscode)[1]', 'BIGINT')
		               AND (
			               (T.SERV_FILE_NO = S.FILE_NO) OR
			               (T.COMP_CODE_DNRM = c.CODE)			
		               )
	            )
	         ) OR
	         (
	            Qx.TAG_ALLANY = 'ALL' AND 
               Qx.TAG_CONT = (
		            SELECT COUNT(T.APBS_CODE)
		              FROM Tag t, @x.nodes('//Tag') tx(r)
		             WHERE t.APBS_CODE = tx.r.query('.').value('(Tag/@apbscode)[1]', 'BIGINT')
		               AND (
			               (T.SERV_FILE_NO = S.FILE_NO) OR
			               (T.COMP_CODE_DNRM = c.CODE)			
		               )
	            )
	         )
	      )
     )
     AND  (Qx.REGN_CONT = 0 OR Qx.REGN_CONT IS NULL OR
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
     
     AND  (Qx.EXTR_CONT = 0 OR Qx.EXTR_CONT IS NULL OR
         ( 
            (  
               Qx.EXTR_ALLANY = 'ANY' AND
               EXISTS(
		            SELECT *
		              FROM dbo.Extra_Info t, @x.nodes('//Sub_Extra_Info') tx(r)
		             WHERE t.APBS_CODE_DNRM = tx.r.query('.').value('(Sub_Extra_Info/@apbscode)[1]', 'BIGINT')
		               AND t.APBS_CODE = tx.r.query('.').value('(Sub_Extra_Info/@sapbcode)[1]', 'BIGINT')
		               AND (
			            (T.SERV_FILE_NO = S.FILE_NO) OR
			            (T.COMP_CODE = c.CODE)			
		               )
	            )
	         ) /*OR
	         (
	            Qx.EXTR_ALLANY = 'ALL' AND
               Qx.EXTR_CONT = (
		            SELECT COUNT(t.CODE)
		              FROM dbo.Extra_Info t, @x.nodes('//Sub_Extra_Info') tx(r)
		             WHERE t.APBS_CODE_DNRM = tx.r.query('.').value('(Sub_Extra_Info/@apbscode)[1]', 'BIGINT')
		               AND t.APBS_CODE = tx.r.query('.').value('(Sub_Extra_Info/@sapbcode)[1]', 'BIGINT')
		               AND (
			               (T.SERV_FILE_NO = S.FILE_NO) OR
			               (T.COMP_CODE = c.CODE)			
		               )
	            )
	         )*/
	      )
     )
     AND  (Qx.CNTC_CONT = 0 OR Qx.CNTC_CONT IS NULL OR
         (
            (
               Qx.CNTC_ALLANY = 'ANY' AND
               EXISTS(
                  SELECT * 
                    FROM dbo.Contact_Info r, @x.nodes('//Contact_Info') rx(r)
                   WHERE r.APBS_CODE = rx.r.query('.').value('(Contact_Info/@apbscode)[1]', 'BIGINT')
                     AND r.CONT_DESC LIKE rx.r.query('.').value('(Contact_Info/@contdesc)[1]', 'NVARCHAR(500)')
                     AND (
                        (r.SERV_FILE_NO = S.FILE_NO) OR
			               (r.COMP_CODE = c.CODE)			
                     )
               )
            ) OR
            (
               Qx.CNTC_ALLANY = 'ALL' AND
               Qx.CNTC_CONT = (
                  SELECT COUNT(r.CODE)
                    FROM dbo.Contact_Info r, @x.nodes('//Contact_Info') rx(r)
                   WHERE r.APBS_CODE = rx.r.query('.').value('(Contact_Info/@apbscode)[1]', 'BIGINT')
                     AND r.CONT_DESC LIKE rx.r.query('.').value('(Contact_Info/@contdesc)[1]', 'NVARCHAR(500)')
                     AND (
                        (r.SERV_FILE_NO = S.FILE_NO) OR
			               (r.COMP_CODE = c.CODE)			
                     )
               )
            )
         )         
     )
)
GO
