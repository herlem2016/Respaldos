DECLARE @sobject NVARCHAR(50)='BankStatementStatus';
DECLARE @tEstructura AS TABLE( gindex INT,propiedad NVARCHAR(100),tipo NVARCHAR(50),data_type NVARCHAR(50), tabla_ref NVARCHAR(50),campo_ref NVARCHAR(50),longitud INT, requerido BIT);
INSERT INTO @tEstructura 
SELECT ORDINAL_POSITION gindex, column_name propiedad, CASE WHEN data_type like 'uniqueidentifier' THEN 'Guid' WHEN data_type like 'datetime' THEN 'DateTime' WHEN data_type like 'date' THEN 'Date'  WHEN data_type like '%char' /*OR data_type like 'varbinary'*/ THEN 'string' WHEN data_type like 'bit' THEN 'bool' WHEN DATA_TYPE like 'money' THEN 'decimal' ELSE data_type END tipo, DATA_TYPE,FK.table_ref,FK.campo_ref,
ISNULL(CHARACTER_MAXIMUM_LENGTH,0) longitud,CONVERT(BIT,CASE WHEN IS_NULLABLE='YES' THEN 0 ELSE 1 END) requerido 
FROM INFORMATION_SCHEMA.COLUMNS Campo 
LEFT OUTER JOIN (	
	SELECT
		OBJECT_NAME(referenced_object_id) as 'table_ref',
		COL_NAME(referenced_object_id, referenced_column_id) as 'campo_ref',
		COL_NAME(parent_object_id, parent_column_id) as 'campo',
		OBJECT_NAME(constraint_object_id) 'Constraint Name'
	FROM sys.foreign_key_columns
	WHERE OBJECT_NAME(parent_object_id) = @sobject
)FK ON FK.campo=campo.COLUMN_NAME
WHERE TABLE_NAME=@sobject;


--SELECT * FROM @tEstructura


SELECT REPLACE(
CASE WHEN requerido=1 THEN '[Required]\n' ELSE '' END + 
CASE WHEN tipo like 'string' THEN '[StringLength(' + CONVERT(NVARCHAR(10),longitud) + ')]\n' ELSE '' END + 
CASE WHEN tipo like 'datetime' THEN '[Column(TypeName = "datetime")]\n' 
	 WHEN tipo like 'date' THEN '[Column(TypeName = "date")]\n'
	 WHEN data_type like 'money' THEN '[Column(TypeName = "money")]\n'
ELSE '' END + 
'public ' + 
CASE WHEN tipo like 'date' THEN 'DateTime' ELSE tipo END +
+ CASE WHEN requerido=1 THEN '' ELSE '? ' END + ' ' + 
propiedad +
+ ' { get; set; }'+ 
CASE WHEN propiedad like 'CreatedBy' THEN '= null!;' ELSE '' END + 
'\n','\n',CHAR(13)) properties
FROM @tEstructura



--DECLARE @sobject NVARCHAR(50)='DocumentPerson';
				
--				SELECT ORDINAL_POSITION gindex, column_name propiedad, CASE WHEN data_type like '%char' THEN 'string' WHEN data_type like 'bit' THEN 'bool' ELSE data_type END tipo, 
--				FK.table_ref,FK.campo_ref,
--				ISNULL(CASE WHEN data_type like '%char' AND CHARACTER_MAXIMUM_LENGTH=-1 THEN 8000 ELSE CHARACTER_MAXIMUM_LENGTH END,0) longitud,CONVERT(BIT,CASE WHEN IS_NULLABLE='YES' THEN 0 ELSE 1 END) requerido 
--				FROM INFORMATION_SCHEMA.COLUMNS Campo 
--				LEFT OUTER JOIN (	
--					SELECT
--						OBJECT_NAME(referenced_object_id) as 'table_ref',
--						COL_NAME(referenced_object_id, referenced_column_id) as 'campo_ref',
--						COL_NAME(parent_object_id, parent_column_id) as 'campo',
--						OBJECT_NAME(constraint_object_id) 'Constraint Name'
--					FROM sys.foreign_key_columns
--					WHERE OBJECT_NAME(parent_object_id) = @sobject
--				)FK ON FK.campo=campo.COLUMN_NAME
--				WHERE TABLE_NAME=@sobject;		