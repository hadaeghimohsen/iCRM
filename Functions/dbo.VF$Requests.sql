SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[VF$Requests]
(	
	@X XML
)
RETURNS TABLE 
AS
RETURN 
(
   /*
    <Region code="" prvncode=""/>
    */
   WITH QXML AS
   (
      SELECT @X.query('Request').value('(Request/@rqid)[1]',         'BIGINT') AS RQID
            ,@X.query('Request').value('(Request/@rqtpcode)[1]',     'VARCHAR(3)') AS RQTP_CODE
            ,@X.query('Request').value('(Request/@rqttcode)[1]',     'VARCHAR(3)') AS RQTT_CODE
            ,@X.query('Request').value('(Request/@rqstrqid)[1]',     'BIGINT') AS RQST_RQID
            ,@X.query('Request').value('(Request/@regncode)[1]',     'VARCHAR(3)') AS REGN_CODE
            ,@X.query('Request').value('(Request/@prvncode)[1]',     'VARCHAR(3)') AS PRVN_CODE
            ,@X.query('Request').value('(Request/@subsys)[1]',       'SMALLINT') AS SUB_SYS
            ,@X.query('Request').value('(Request/@ssttmsttcode)[1]', 'SMALLINT') AS SSTT_MSTT_CODE
            ,@X.query('Request').value('(Request/@ssttcode)[1]',     'SMALLINT') AS SSTT_CODE
            ,@X.query('Request').value('(Request/@year)[1]',         'SMALLINT') AS [YEAR]
            ,@X.query('Request').value('(Request/@cycl)[1]',         'VARCHAR(3)') AS CYCL
            ,@X.query('Request').value('(Request/@cretby)[1]',       'VARCHAR(250)') AS CRET_BY
            ,@X.query('Request').value('(Request/@mdfyby)[1]',       'VARCHAR(250)') AS MDFY_BY
            ,@X.query('//Request_Row').value('(Request_Row/@servfileno)[1]', 'BIGINT') AS SERV_FILE_NO
   )
	SELECT R.REGN_PRVN_CNTY_CODE ,
          R.REGN_PRVN_CODE ,
          R.REGN_CODE ,
          R.RQST_RQID ,
          R.RQID ,
          R.RQTP_CODE ,
          R.RQTT_CODE ,
          R.JOBP_CODE ,
          R.JOBP_DESC ,
          R.SUB_SYS ,
          R.RQST_STAT ,
          R.RQST_DATE ,
          R.SAVE_DATE ,
          R.LETT_NO ,
          R.LETT_DATE ,
          R.LETT_OWNR ,
          R.SSTT_MSTT_SUB_SYS ,
          R.SSTT_MSTT_CODE ,
          R.SSTT_CODE ,
          R.YEAR ,
          R.CYCL ,
          R.SEND_EXPN ,
          R.MDUL_NAME ,
          R.SECT_NAME ,
          R.RQST_DESC ,
          R.CRET_BY ,
          R.CRET_DATE ,
          R.MDFY_BY ,
          R.MDFY_DATE
	  FROM Request R 
	       LEFT OUTER JOIN Request_Row Rr ON (R.RQID = RR.RQST_RQID) 
	       LEFT OUTER JOIN Service F ON (Rr.SERV_FILE_NO = F.FILE_NO) 
	       LEFT OUTER JOIN V#URFGA UR ON (UPPER(SUSER_NAME()) = UR.SYS_USER AND UR.REGN_PRVN_CODE = F.REGN_PRVN_CODE AND UR.REGN_CODE = F.REGN_CODE) 
	       LEFT OUTER JOIN V#UCFGA UC ON (UR.SYS_USER = UC.SYS_USER AND UC.COMP_CODE = CASE WHEN R.RQTP_CODE IN ('001', '002') AND R.RQST_STAT = '001' THEN (SELECT P.COMP_CODE FROM Service_Public P WHERE P.RQRO_RQST_RQID = R.RQID AND P.SERV_FILE_NO = F.FILE_NO AND P.RECT_CODE = '001') ELSE F.COMP_CODE_DNRM END)
	       , QXML QX
	 WHERE /*R.RQID = Rr.RQST_RQID
	   AND Rr.SERV_FILE_NO = F.FILE_NO
	   AND UPPER(SUSER_NAME()) = UR.SYS_USER
	   AND UR.SYS_USER         = UC.SYS_USER
	   AND UR.REGN_PRVN_CODE   = F.REGN_PRVN_CODE
	   AND UR.REGN_CODE        = F.REGN_CODE
	   AND UC.COMP_CODE        = CASE WHEN R.RQTP_CODE IN ('001', '002') AND R.RQST_STAT = '001' THEN (SELECT P.COMP_CODE FROM Service_Public P WHERE P.RQRO_RQST_RQID = R.RQID AND P.SERV_FILE_NO = F.FILE_NO AND P.RECT_CODE = '001') ELSE F.COMP_CODE_DNRM END*/
	   (QX.RQID IS NULL OR QX.RQID = 0 OR R.RQID = QX.RQID)
	   AND (QX.RQTP_CODE IS NULL OR LEN(QX.RQTP_CODE) <> 3 OR R.RQTP_CODE = QX.RQTP_CODE)
	   AND (QX.RQTT_CODE IS NULL OR LEN(QX.RQTT_CODE) <> 3 OR R.RQTT_CODE = QX.RQTT_CODE)
	   AND (QX.RQST_RQID IS NULL OR QX.RQST_RQID = 0 OR R.RQST_RQID = QX.RQST_RQID)
	   AND (QX.REGN_CODE IS NULL OR LEN(QX.REGN_CODE) <> 3 OR R.REGN_CODE = QX.REGN_CODE)
	   AND (QX.PRVN_CODE IS NULL OR LEN(QX.PRVN_CODE) <> 3 OR R.REGN_PRVN_CODE = QX.PRVN_CODE)
	   AND (QX.SUB_SYS IS NULL OR Qx.SUB_SYS = 0 OR R.SUB_SYS = QX.SUB_SYS)
	   AND (QX.SSTT_MSTT_CODE IS NULL OR QX.SSTT_MSTT_CODE = 0 OR R.SSTT_MSTT_CODE = QX.SSTT_MSTT_CODE)
	   AND (QX.SSTT_CODE IS NULL OR QX.SSTT_CODE = 0 OR R.SSTT_CODE = QX.SSTT_CODE)
	   AND (QX.[YEAR] IS NULL OR QX.[YEAR] = 0 OR R.[YEAR] = QX.[YEAR])
	   AND (QX.CYCL IS NULL OR QX.CYCL = 0 OR R.CYCL = QX.CYCL)
	   AND (QX.CRET_BY IS NULL OR Qx.CRET_BY = '' OR R.CRET_BY = QX.CRET_BY)
	   AND (QX.MDFY_BY IS NULL OR R.MDFY_BY = QX.MDFY_BY)
	   AND (QX.SERV_FILE_NO IS NULL OR RR.SERV_FILE_NO = QX.SERV_FILE_NO)
)
GO
