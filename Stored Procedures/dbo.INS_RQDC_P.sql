SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_RQDC_P]
	-- Add the parameters for the stored procedure here
	@Dcmt_Dsid BIGINT,
	@Rqrq_Code BIGINT,
	@Need_Type VARCHAR(3),
	@Orig_Type VARCHAR(3),
	@Frst_Need VARCHAR(3)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	-- بررسی دسترسی کاربر
	DECLARE @AP BIT
	       ,@AccessString VARCHAR(250);
	SET @AccessString = N'<AP><UserName>' + SUSER_NAME() + '</UserName><Privilege>44</Privilege><Sub_Sys>11</Sub_Sys></AP>';	
   EXEC iProject.dbo.SP_EXECUTESQL N'SELECT @ap = DataGuard.AccessPrivilege(@P1)',N'@P1 ntext, @ap BIT OUTPUT',@AccessString , @ap = @ap output
   IF @AP = 0 
   BEGIN
      RAISERROR ( N'خطا - عدم دسترسی به ردیف 44 سطوح امینتی', -- Message text.
               16, -- Severity.
               1 -- State.
               );
      RETURN;
   END
   -- پایان دسترسی
   
	INSERT Request_Document (DCMT_DSID, RQRQ_CODE, NEED_TYPE, ORIG_TYPE, FRST_NEED)
	VALUES(@Dcmt_Dsid, @Rqrq_Code, @Need_Type, @Orig_Type, @Frst_Need);
END
GO
