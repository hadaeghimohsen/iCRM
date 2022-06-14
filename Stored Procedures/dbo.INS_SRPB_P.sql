SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[INS_SRPB_P]
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
	INSERT INTO [dbo].[Service_Public]
           ([REGN_PRVN_CNTY_CODE], [REGN_PRVN_CODE], [REGN_CODE], [BTRF_CODE], [TRFD_CODE], [EXPN_CODE]
           ,[COMP_CODE], [RQRO_RQST_RQID], [RQRO_RWNO], [SERV_FILE_NO], [RWNO], [RECT_CODE]
           ,[FRST_NAME], [LAST_NAME], [FATH_NAME], [NATL_CODE], [BRTH_DATE]
           ,[CELL_PHON], [TELL_PHON], [IDTY_CODE], [OWNR_TYPE], [USER_NAME], [PASS_WORD]
           ,[TELG_CHAT_CODE], [FRST_NAME_OWNR_LINE], [LAST_NAME_OWNR_LINE]
           ,[NATL_CODE_OWNR_LINE], [LINE_NUMB_SERV]  
           ,[POST_ADRS], [EMAL_ADRS]
           ,[ONOF_TAG], [SUNT_BUNT_DEPT_ORGN_CODE], [SUNT_BUNT_DEPT_CODE], [SUNT_BUNT_CODE], [SUNT_CODE]
           ,[ISCP_ISCA_ISCG_CODE], [ISCP_ISCA_CODE], [ISCP_CODE]
           ,[CORD_X], [CORD_Y], [MOST_DEBT_CLNG], SEX_TYPE, MRID_TYPE, RLGN_TYPE, ETHN_CITY, CUST_TYPE, STIF_TYPE, JOB_TITL
           ,[TYPE], FACE_BOOK_URL, LINK_IN_URL, TWTR_URL, SERV_NO)
     VALUES
           (@Cnty_Code, @Prvn_Code, @Regn_Code, @Btrf_Code, @Trfd_Code ,@Expn_Code
           ,@COMP_Code, @Rqro_Rqst_Rqid, @Rqro_Rwno, @File_No, 0, @Rect_Code
           ,@Frst_Name, @Last_Name, @Fath_Name, @Natl_Code, @Brth_Date
           ,@Cell_Phon, @Tell_Phon, @Idty_Code, @Ownr_Type, @User_Name, @Pass_Word
           ,@Telg_Chat_Code, @Frst_Name_Ownr_Line, @Last_Name_Ownr_Line
           ,@Natl_Code_Ownr_Line, @Line_Numb_Serv
           ,@Post_Adrs, @Emal_Adrs
           ,@OnOf_Tag
           ,@Sunt_Bunt_Dept_Orgn_Code, @Sunt_Bunt_Dept_Code, @Sunt_Bunt_Code, @Sunt_Code
           ,@Iscp_Isca_Iscg_Code, @Iscp_Isca_Code, @Iscp_Code
           ,@Cord_X, @Cord_Y, @Most_Debt_Clng, @Sex_Type, @Mrid_Type, @Rlgn_Type, @Ethn_City, @Cust_Type, @Stif_Type, @Job_Titl
           ,@Type, @Face_Book_Url, @Link_In_Url, @Twtr_Url, @Serv_No);
END
GO
