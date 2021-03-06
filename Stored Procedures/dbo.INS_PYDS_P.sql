SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_PYDS_P]
	-- Add the parameters for the stored procedure here
	@Pymt_Cash_Code BIGINT,
	@Pymt_Rqst_Rqid BIGINT,
	@Rqro_Rwno SMALLINT,
	@Expn_Code BIGINT,
	@Amnt INT,
	@Amnt_Type VARCHAR(3),
	@Stat VARCHAR(3),
	@Pyds_Desc NVARCHAR(250)
AS
BEGIN
	 	-- بررسی دسترسی کاربر
	DECLARE @AP BIT
	       ,@AccessString VARCHAR(250);
	SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>63</Privilege><Sub_Sys>11</Sub_Sys></AP>';	
   EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
   IF @AP = 0 
   BEGIN
      RAISERROR ( N'خطا - عدم دسترسی به ردیف 63 سطوح امینتی', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   -- پایان دسترسی
   
   IF @Amnt = 0 RAISERROR (N'مبلغ تخفیف باید مبلغی مثبت و غیر صفر باشد', 16, 1);
   IF @Rqro_Rwno = 0 OR @Rqro_Rwno IS NULL
      SET @Rqro_Rwno = 1;
   IF @Amnt_Type IS NULL
      SET @Amnt_Type = '002';
   IF @Stat IS NULL 
      SET @Stat = '002';
      
   INSERT INTO dbo.Payment_Discount
           ( PYMT_CASH_CODE ,
             PYMT_RQST_RQID ,
             RQRO_RWNO ,
             --RWNO ,
             EXPN_CODE ,
             AMNT ,
             AMNT_TYPE ,
             STAT ,
             PYDS_DESC 
           )
   VALUES  ( @Pymt_Cash_Code , -- PYMT_CASH_CODE - bigint
             @Pymt_Rqst_Rqid , -- PYMT_RQST_RQID - bigint
             @Rqro_Rwno , -- RQRO_RWNO - smallint
             --0 , -- RWNO - smallint
             @Expn_Code , -- EXPN_CODE - bigint
             @Amnt , -- AMNT - int
             @Amnt_Type , -- AMNT_TYPE - varchar(3)
             @Stat , -- STAT - varchar(3)
             @Pyds_Desc  -- PYDS_DESC - nvarchar(250)             
           );   
END
GO
