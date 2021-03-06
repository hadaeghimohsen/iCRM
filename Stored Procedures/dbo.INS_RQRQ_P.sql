SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_RQRQ_P]
	-- Add the parameters for the stored procedure here
	@ReglCode INT,
	@ReglYear SMALLINT,
	@RqtpCode VARCHAR(3),
	@RqttCode VARCHAR(3),
	@PermStat VARCHAR(3)
AS
BEGIN

	-- بررسی دسترسی کاربر
	DECLARE @AP BIT
	       ,@AccessString VARCHAR(250);
	SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>31</Privilege><Sub_Sys>10</Sub_Sys></AP>';	
   EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
   IF @AP = 0 
   BEGIN
      RAISERROR ( N'خطا - عدم دسترسی به ردیف 31 سطوح امینتی', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   -- پایان دسترسی

   DECLARE @SubSys SMALLINT;
   SELECT @PermStat = CASE WHEN @PermStat IS NULL THEN '002' ELSE '001' END;
   SELECT @SubSys = Sub_Sys FROM Request_Type WHERE CODE = @RqtpCode;
    -- Insert statements for procedure here
	INSERT INTO Request_Requester (REGL_CODE, REGL_YEAR, RQTP_CODE, RQTT_CODE, PERM_STAT, SUB_SYS)
	VALUES(@ReglCode, @ReglYear, @RqtpCode, @RqttCode, @PermStat, @SubSys);
	
END
GO
