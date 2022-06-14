SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[VF$Companies]
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
      SELECT @X.query('//Company').value('(Company/@recdstat)[1]', 'VARCHAR(3)') AS Recd_Stat
            ,@X.query('//Company').value('(Company/@type)[1]', 'VARCHAR(3)') AS [Type]
            ,@X.query('//Company').value('(Company/@dfltstat)[1]', 'VARCHAR(3)') AS Dflt_Stat
            ,@X.query('//Company').value('(Company/@hoststat)[1]', 'VARCHAR(3)') AS Host_Stat
            ,@X.query('//Company').value('(Company/@empynumb)[1]', 'VARCHAR(3)') AS Empy_Numb
            ,@X.query('//Company').value('(Company/@code)[1]', 'BIGINT') AS Comp_Code
            ,@X.query('//Tags').value('(Tags/@cont)[1]', 'BIGINT') AS TAG_CONT
            ,@X.query('//Tags').value('(Tags/@allany)[1]', 'VARCHAR(3)') AS TAG_ALLANY
            ,@X.query('//Regions').value('(Regions/@cont)[1]', 'BIGINT') AS REGN_CONT
            ,@X.query('//Extra_Infos').value('(Extra_Infos/@cont)[1]', 'BIGINT') AS EXTR_CONT
            ,@X.query('//Extra_Infos').value('(Extra_Infos/@allany)[1]', 'VARCHAR(3)') AS EXTR_ALLANY
            ,@X.query('//Contact_Infos').value('(Contact_Infos/@cont)[1]', 'BIGINT') AS CNTC_CONT
            ,@X.query('//Contact_Infos').value('(Contact_Infos/@allany)[1]', 'VARCHAR(3)') AS CNTC_ALLANY
   )
	SELECT cn.NAME AS CNTY_NAME, p.NAME AS PRVN_NAME, rg.NAME AS REGN_NAME, 
	       c.NAME AS COMP_NAME, c.DEBT_DNRM, rt.RQTP_DESC, s.NAME_DNRM AS SERV_NAME, 
	       c.CRET_BY, c.CODE, c.LAST_SERV_FILE_NO_DNRM, c.RECD_STAT, c.EMAL_ADRS, c.LOGO, c.HOST_STAT, c.WEB_SITE, c.POST_ADRS
	  FROM dbo.Region rg, dbo.Province p, dbo.Country cn , dbo.Company c /*, V#URFGA UR, V#UCFGA UC*/
	       LEFT OUTER JOIN dbo.Request R ON r.rqid = c.LAST_RQST_RQID_DNRM 
	       LEFT OUTER JOIN dbo.Request_Type Rt ON r.RQTP_CODE = rt.CODE
	       LEFT OUTER JOIN dbo.Service s ON s.FILE_NO = c.LAST_SERV_FILE_NO_DNRM
	       , QXML QX
	 WHERE /*UPPER(SUSER_NAME()) = UR.SYS_USER
	   AND UR.SYS_USER         = UC.SYS_USER
	   AND UR.REGN_PRVN_CODE   = F.REGN_PRVN_CODE
	   AND UR.REGN_CODE        = F.REGN_CODE
	   AND UC.COMP_CODE        = F.COMP_CODE_DNRM*/
	       c.REGN_CODE = rg.CODE
	   AND c.REGN_PRVN_CODE = rg.PRVN_CODE
	   AND c.REGN_PRVN_CNTY_CODE = rg.PRVN_CNTY_CODE
	   AND rg.PRVN_CODE = p.CODE
	   AND rg.PRVN_CNTY_CODE = p.CNTY_CODE	   
	   AND p.CNTY_CODE = cn.CODE	   
	   AND (ISNULL(Qx.Comp_Code, 0) = 0 OR C.CODE = Qx.Comp_Code)	   
	   AND (QX.Recd_Stat IS NULL OR ISNULL(c.RECD_STAT, '002') = Qx.Recd_Stat)
	   AND (QX.Type IS NULL OR ISNULL(c.TYPE, '001') = Qx.Type)
	   AND (QX.Dflt_Stat IS NULL OR ISNULL(c.DFLT_STAT, '002') = Qx.Dflt_Stat)
	   AND (QX.Host_Stat IS NULL OR ISNULL(c.Host_STAT, '002') = Qx.Host_Stat)
	   AND (QX.Empy_Numb IS NULL OR ((Qx.Empy_Numb = '001' AND C.EMPY_NUMB_DNRM = 0) OR  (Qx.Empy_Numb = '002' AND C.EMPY_NUMB_DNRM > 0)))
	   
	   AND  (Qx.TAG_CONT = 0 OR Qx.TAG_CONT IS NULL OR
	      (
	         ( 
	            Qx.TAG_ALLANY = 'ANY' AND 
               EXISTS(
		            SELECT *
		              FROM Tag t, @x.nodes('//Tag') tx(r)
		             WHERE t.APBS_CODE = tx.r.query('.').value('(Tag/@apbscode)[1]', 'BIGINT')
		               AND (T.COMP_CODE_DNRM = c.CODE)
	            )
	         ) OR
	         (
	            Qx.TAG_ALLANY = 'ALL' AND 
               Qx.TAG_CONT = (
		            SELECT COUNT(T.APBS_CODE)
		              FROM Tag t, @x.nodes('//Tag') tx(r)
		             WHERE t.APBS_CODE = tx.r.query('.').value('(Tag/@apbscode)[1]', 'BIGINT')
		               AND (T.COMP_CODE_DNRM = c.CODE)
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
               AND (c.REGN_PRVN_CNTY_CODE = r.PRVN_CNTY_CODE AND c.REGN_PRVN_CODE = r.PRVN_CODE AND c.REGN_CODE = r.CODE)
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
		               AND (T.COMP_CODE = c.CODE)
	            )
	         ) 
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
                     AND (r.COMP_CODE = c.CODE)
               )
            ) OR
            (
               Qx.CNTC_ALLANY = 'ALL' AND
               Qx.CNTC_CONT = (
                  SELECT COUNT(r.CODE)
                    FROM dbo.Contact_Info r, @x.nodes('//Contact_Info') rx(r)
                   WHERE r.APBS_CODE = rx.r.query('.').value('(Contact_Info/@apbscode)[1]', 'BIGINT')
                     AND r.CONT_DESC LIKE rx.r.query('.').value('(Contact_Info/@contdesc)[1]', 'NVARCHAR(500)')
                     AND (r.COMP_CODE = c.CODE)
               )
            )
         )
     )
)
GO
