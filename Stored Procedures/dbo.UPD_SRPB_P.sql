SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[UPD_SRPB_P]
	-- Add the parameters for the stored procedure here
	@Cnty_Code VARCHAR(3),
	@Prvn_Code VARCHAR(3),
	@Regn_Code VARCHAR(3),
	@File_No   BIGINT,
	@Btrf_Code BIGINT,
	@Trfd_Code BIGINT,
	@COMP_Code BIGINT,
	@Expn_Code BIGINT,
	@Rqro_Rqst_Rqid BIGINT,
	@Rqro_Rwno smallint,
	@Rect_Code VARCHAR(3),
	@Frst_Name NVARCHAR(250),
	@Last_Name NVARCHAR(250),
	@Fath_Name NVARCHAR(250),
	@Natl_Code VARCHAR(10),
	@Brth_Date DATE,
	@Cell_Phon VARCHAR(11),
	@Tell_Phon VARCHAR(11),
   @Idty_Code VARCHAR(10),
   @Ownr_Type VARCHAR(3),
   @User_Name VARCHAR(250),
   @Pass_Word VARCHAR(250),
   @Telg_Chat_Code BIGINT,
   @Frst_Name_Ownr_Line NVARCHAR(250),
   @Last_Name_Ownr_Line NVARCHAR(250),
   @Natl_Code_Ownr_Line VARCHAR(10),
   @Line_Numb_Serv VARCHAR(10),
	@Post_Adrs NVARCHAR(1000),
	@Emal_Adrs NVARCHAR(250),
	@OnOf_Tag  VARCHAR(3) = '101',
	@Sunt_Bunt_Dept_Orgn_Code VARCHAR(2),
	@Sunt_Bunt_Dept_Code VARCHAR(2),
	@Sunt_Bunt_Code VARCHAR(2),
	@Sunt_Code VARCHAR(4),
   @Iscp_Isca_Iscg_Code VARCHAR(2),
	@Iscp_Isca_Code VARCHAR(2),
	@Iscp_Code VARCHAR(6),
	@Cord_X REAL,
	@Cord_Y REAL,
	@Most_Debt_Clng BIGINT,
	@Sex_Type VARCHAR(3),
	@Mrid_Type VARCHAR(3),
	@Rlgn_Type VARCHAR(3),
	@Ethn_City VARCHAR(3),
	@Cust_Type VARCHAR(3),
	@Stif_Type VARCHAR(3),
	@Job_Titl VARCHAR(3),
   @Type VARCHAR(3),
	@Face_Book_Url NVARCHAR(1000),
	@Link_In_Url NVARCHAR(1000),
	@Twtr_Url NVARCHAR(1000),
	@Serv_No VARCHAR(10)
AS
BEGIN
	UPDATE [dbo].[Service_Public]
	   SET [REGN_PRVN_CNTY_CODE] = @Cnty_Code
	      ,[REGN_PRVN_CODE] = @Prvn_Code
	      ,[REGN_CODE] = @Regn_Code
	      ,[BTRF_CODE] = @BTRF_Code
	      ,[TRFD_CODE] = @TRFD_Code
         ,[COMP_CODE] = @COMP_CODE
         ,[EXPN_CODE] = @Expn_Code
         ,[RECT_CODE] = @Rect_Code
         ,[FRST_NAME] = @Frst_Name
         ,[LAST_NAME] = @Last_Name
         ,[FATH_NAME] = @Fath_Name
         ,[NATL_CODE] = @Natl_Code
         ,[BRTH_DATE] = @Brth_Date
         ,[CELL_PHON] = @Cell_Phon
         ,[TELL_PHON] = @Tell_Phon
         ,[IDTY_CODE] = @Idty_Code
         ,[OWNR_TYPE] = @Ownr_Type
         ,[USER_NAME] = @User_Name
         ,[PASS_WORD] = @Pass_Word
         ,[TELG_CHAT_CODE] = @Telg_Chat_Code
         ,[FRST_NAME_OWNR_LINE] = @Frst_Name_Ownr_Line
         ,[LAST_NAME_OWNR_LINE] = @Last_Name_Ownr_Line
         ,[NATL_CODE_OWNR_LINE] = @Natl_Code_Ownr_Line
         ,[LINE_NUMB_SERV] = @Line_Numb_Serv
         ,[POST_ADRS] = @Post_Adrs
         ,[EMAL_ADRS] = @Emal_Adrs
         ,[ONOF_TAG] = @OnOf_Tag
         ,[SUNT_BUNT_DEPT_ORGN_CODE] = @SUNT_BUNT_DEPT_ORGN_CODE
         ,[SUNT_BUNT_DEPT_CODE] = @SUNT_BUNT_DEPT_CODE
         ,[SUNT_BUNT_CODE] = @SUNT_BUNT_CODE
         ,[SUNT_CODE] = @SUNT_CODE
         ,[ISCP_ISCA_ISCG_CODE] = @Iscp_Isca_Iscg_Code
         ,[ISCP_ISCA_CODE] = @Iscp_Isca_Code
         ,[ISCP_CODE] = @Iscp_Code
         ,[CORD_X] = @CORD_X
         ,[CORD_Y] = @CORD_Y
         ,[MOST_DEBT_CLNG] = @Most_Debt_Clng
         ,SEX_TYPE = @Sex_Type
         ,MRID_TYPE = @Mrid_Type
         ,RLGN_TYPE = @Rlgn_Type
         ,ETHN_CITY = @Ethn_City
         ,CUST_TYPE = @Cust_Type
         ,STIF_TYPE = @Stif_Type
         ,JOB_TITL = @Job_Titl
         ,[TYPE] = @Type
         ,FACE_BOOK_URL = @Face_Book_Url
         ,LINK_IN_URL = @Link_In_Url
         ,TWTR_URL = @Twtr_Url
         ,SERV_NO = @Serv_No
     WHERE SERV_File_No = @File_No
       AND [RQRO_RQST_RQID] = @Rqro_Rqst_Rqid
       AND [RQRO_RWNO] = @Rqro_Rwno;
END
GO
