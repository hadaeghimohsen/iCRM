SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[V#Columns] as
select 
     st.object_id AS OBJC_ID,
     st.name TABL_NAME,
     sc.column_id AS CLMN_ID,
     sc.name CLMN_NAME,
     sep.value [DESC],
     isc.DATA_TYPE
 from sys.tables st
 inner join sys.columns sc on st.object_id = sc.object_id
 INNER JOIN INFORMATION_SCHEMA.COLUMNS isc ON (isc.TABLE_NAME = st.name AND isc.COLUMN_NAME = sc.name)
 left join sys.extended_properties sep on st.object_id = sep.major_id
                                      and sc.column_id = sep.minor_id
                                      and sep.name = 'MS_Description';
GO
