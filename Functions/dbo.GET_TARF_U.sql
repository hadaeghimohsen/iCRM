SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GET_TARF_U]
(
	@FileNo BIGINT
)
RETURNS VARCHAR(11)
AS
BEGIN
   DECLARE @TarfCode VARCHAR(11);
   
	DECLARE @SexType VARCHAR(3)
	       ,@SERVType VARCHAR(3)
	       ,@BTRFCode BIGINT
	       ,@TRFDCode BIGINT
	       ,@ActvTag VARCHAR(3)
	       ,@DebtAmnt BIGINT
	       ,@InsrNumb VARCHAR(10)
	       ,@InsrDate DATE
	       ,@ConfStat VARCHAR(3);
	
	SELECT @SexType = SEX_TYPE_DNRM
	      ,@SERVType = SRPB_TYPE_DNRM
	      ,@BTRFCode = BTRF_CODE_DNRM
	      ,@TRFDCode = TRFD_CODE_DNRM
	      ,@ActvTag = ONOF_TAG_DNRM
	      ,@DebtAmnt = DEBT_DNRM
	      ,@ConfStat = CONF_STAT
	  FROM dbo.Service F
	 WHERE FILE_NO = @FileNo;
	
	IF @ConfStat = '001'
	   RETURN NULL;	   
	
	-- اولین رقم نوع جنسیت
	IF @SexType = '001'
	   SET @TarfCode = '1'
	ELSE
	   SET @TarfCode = '2';
	
	-- دومین رقم نوع هنرجو
	IF @SERVType = '001'
	   SET @TarfCode += '1';
	ELSE IF @SERVType = '002'
	   SET @TarfCode += '2';
   ELSE IF @SERVType = '003'
	   SET @TarfCode += '3';
   ELSE IF @SERVType = '005'
	   SET @TarfCode += '5';
	ELSE IF @SERVType = '006'
	   SET @TarfCode += '6';
	ELSE IF @SERVType = '007'
	   SET @TarfCode += '7';
   ELSE IF @SERVType = '008'
	   SET @TarfCode += '8';	   
	ELSE IF @SERVType = '009'
	   SET @TarfCode += '9';
   
   -- سوم و چهارمین رقم نوع سبک هنرجو
   IF @BTRFCode IS NULL OR NOT EXISTS(SELECT * FROM dbo.Base_Tariff WHERE CODE = @BTRFCode)
      SET @TarfCode += '00'
   ELSE
      SET @TarfCode += (SELECT NATL_CODE FROM dbo.Base_Tariff WHERE CODE = @BTRFCode);
   
   -- پنجم و ششمین رقم نوع رسته هنرجو
   IF @TRFDCode IS NULL OR NOT EXISTS(SELECT * FROM dbo.Base_Tariff_Detail WHERE Code = @TRFDCode AND BTRF_CODE = @BTRFCode)
      SET @TarfCode += '00';
   ELSE
      SET @TarfCode += (SELECT NATL_CODE FROM dbo.Base_Tariff_Detail WHERE Code = @TRFDCode AND BTRF_CODE = @BTRFCode)
   
   -- هفتمین رقم شاخص فعالیت
   IF CAST(@ActvTag AS INT) >= 101
      SET @TarfCode += '1';
   ELSE 
      SET @TarfCode += '0';
   
   -- هشتیم رقم نوع بدهی / بستانکاری
   IF @DebtAmnt > 0
      SET @TarfCode += '1';
   ELSE IF @DebtAmnt = 0
      SET @TarfCode += '0';
   ELSE 
      SET @TarfCode += '2';
   
   -- نهمین رقم نیاز به تمدید
   SET @TarfCode += '0';
   
   -- دهمین رقم دارا بودن کارت عضویت سبک
   SET @TarfCode += '0';
   
   -- معتبر بودن کارت بیمه
   SET @TarfCode += '0';
  
      
   RETURN @TarfCode;
	   
END
GO
