SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[VF$Service_Expense_Detail]
(	
	-- Add the parameters for the function here
	@PrvnCode VARCHAR(3),
	@RegnCode VARCHAR(3),
	@EpitType VARCHAR(3),
	@RqtpCode VARCHAR(3),
	@RqttCode VARCHAR(3),
	@CashType VARCHAR(3),
	@CashCode BIGINT,
	@FileNo BIGINT	
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT RQTP.CODE AS RQTP_CODE, RQTP.RQTP_DESC, RQTP.MUST_LOCK AS RQTP_MUST_LOCK, RQTT.RQTT_DESC, RQTT.CODE AS RQTT_CODE, RQRQ.SUB_SYS AS RQRQ_SUB_SYS, 
          RQRQ.CODE AS RQRQ_CODE, RQRQ.PERM_STAT AS RQRQ_PERM_STAT, EPIT.EPIT_DESC, EPIT.TYPE AS EPIT_TYPE, 0 AS EPIT_QNTY, EXTP.EXTP_DESC, EXTP.CODE AS EXTP_CODE, 
          CASH.CODE AS CASH_CODE, CASH.NAME AS CASH_NAME, CASH.BANK_BRNC_CODE AS CASH_BANK_BRNC_CODE, CASH.BANK_NAME AS CASH_BANK_NAME, 
          CASH.BANK_ACNT_NUMB AS CASH_BANK_ACNT_NUMB, CASH.TYPE AS CASH_TYPE, CASH.CASH_STAT, EXCS.EXCS_STAT, REGN.CODE AS REGN_CODE, REGN.NAME AS REGN_NAME, 
          REGL_EXPN.YEAR AS REGL_EXPN_YEAR, REGL_EXPN.CODE AS REGL_EXPN_CODE, REGL_EXPN.TYPE AS REGL_EXPN_TYPE, REGL_EXPN.REGL_STAT AS REGL_EXPN_STAT, 
          REGL_EXPN.TAX_PRCT AS REGL_TAX_PRCT, REGL_EXPN.DUTY_PRCT AS REGL_DUTY_PRCT, EXPN.CODE AS EXPN_CODE, EXPN.EXPN_DESC, EXPN.PRIC AS EXPN_PRIC, 
          EXPN.EXTR_PRCT AS EXPN_EXTR_PRCT, EXPN.EXPN_STAT, TRFD.NAME AS TRFD_NAME, TRFD.TRFD_DESC, TRFD.CODE AS TRFD_CODE, BTRF.CODE AS BTRF_CODE, BTRF.BTRF_DESC, 
          SERV.FILE_NO, REGL_ACNT.TYPE AS REGL_ACNT_TYPE, REGL_ACNT.REGL_STAT AS REGL_ACNT_STAT
     FROM dbo.Request_Requester AS RQRQ,
          dbo.Request_Type AS RQTP,
          dbo.Requester_Type AS RQTT,
          dbo.Expense_Type AS EXTP,
          dbo.Expense_Cash AS EXCS,
          dbo.Cash AS CASH,
          dbo.Regulation AS REGL_EXPN,
          dbo.Expense AS EXPN,
          dbo.Base_Tariff_Detail AS TRFD,
          dbo.Base_Tariff AS BTRF,
          dbo.Region AS REGN,
          dbo.Service AS SERV,
          dbo.Expense_Item AS EPIT,
          dbo.Regulation AS REGL_ACNT  
    WHERE (RQRQ.PERM_STAT      = '002') 
      AND (CASH.CASH_STAT      = '002') 
      AND (EXCS.EXCS_STAT      = '002') 
      AND (REGL_EXPN.REGL_STAT = '002') 
      AND (EXPN.EXPN_STAT      = '002') 
      AND (REGL_EXPN.TYPE      = '001') 
      AND (REGL_ACNT.TYPE      = '002') 
      AND (REGL_ACNT.REGL_STAT = '002')
      AND (RQRQ.RQTP_CODE = RQTP.CODE AND RQRQ.RQTT_CODE = RQTT.CODE AND RQRQ.CODE = EXTP.RQRQ_CODE)
      AND (EXTP.CODE = EXCS.EXTP_CODE AND EXCS.CASH_CODE = CASH.CODE)
      AND (RQRQ.REGL_YEAR = REGL_EXPN.YEAR AND RQRQ.REGL_CODE = REGL_EXPN.CODE)
      AND (EXTP.CODE = EXPN.EXTP_CODE AND REGL_EXPN.YEAR = EXPN.REGL_YEAR AND REGL_EXPN.CODE = EXPN.REGL_CODE)
      AND (EXPN.TRFD_CODE = TRFD.CODE)
      AND (EXPN.BTRF_CODE = BTRF.CODE)
      AND (EXCS.REGN_PRVN_CNTY_CODE = REGN.PRVN_CNTY_CODE AND EXCS.REGN_PRVN_CODE = REGN.PRVN_CODE AND EXCS.REGN_CODE = REGN.CODE)
      AND (REGN.PRVN_CNTY_CODE = SERV.REGN_PRVN_CNTY_CODE AND REGN.PRVN_CODE = SERV.REGN_PRVN_CODE AND REGN.CODE = SERV.REGN_CODE AND TRFD.CODE = SERV.TRFD_CODE_DNRM AND BTRF.CODE = SERV.BTRF_CODE_DNRM)
      AND (EXTP.EPIT_CODE = EPIT.CODE)
      AND (EXCS.REGL_YEAR = REGL_ACNT.YEAR AND EXCS.REGL_CODE = REGL_ACNT.CODE)
      AND (BTRF.CODE = TRFD.BTRF_CODE)
      AND (@PrvnCode IS NULL OR REGN.PRVN_CODE = @PrvnCode)
      AND (@RegnCode IS NULL OR REGN.CODE      = @RegnCode)
      AND (@EpitType IS NULL OR EPIT.TYPE      = @EpitType)
      AND (@RqtpCode IS NULL OR RQTP.CODE      = @RqtpCode)
      AND (@RqttCode IS NULL OR RQTT.CODE      = @RqttCode)
      AND (@CashType IS NULL OR CASH.TYPE      = @CashType)
      AND (@CashCode IS NULL OR CASH.CODE      = @CashCode)
      AND (@FileNo   IS NULL OR SERV.FILE_NO   = @FileNo)
)
GO
