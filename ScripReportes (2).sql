
/*****************************************************************************************/
--	Diseño de base de datos para Obtención de Reportes 
--	Etapa 1. Reportes operativos
/*****************************************************************************************/
--drop table CAT_NotificacionesEmail
CREATE TABLE CAT_NotificacionesEmail(
	IdNotificacion INT PRIMARY KEY,
	IdRol INT REFERENCES CAT_Roles(IdRol),
	IdArea INT REFERENCES CAT_Areas(IdArea),
	IdUsuario INT REFERENCES CAT_Usuarios(IdUsuario),
	extras NVARCHAR(2000)
)

INSERT INTO CAT_NotificacionesEmail
SELECT * FROM (VALUES
(1,NULL,NULL,NULL,'misael.mayen@prestalana.com,emmanuel.hernandez@prestalana.com')
)Q(a,b,c,d,e)

--drop table CAT_Reportes
CREATE TABLE CAT_Reportes(
	IdReporte INT PRIMARY KEY,
	Nombre NVARCHAR(300),
	Descripcion NVARCHAR(2000),
	Entregable NVARCHAR(500),
	ScriptValidacion NVARCHAR(MAX),
	ScriptSQL NVARCHAR(MAX),
	Estatus BIT,--//NULLL para scripts de operación, true Reportes Activos, false para Reportes inactivos,
	IdNotificacion INT REFERENCES CAT_NotificacionesEmail(IdNotificacion),
	TypesOutput INT
)

--drop table CAT_TipoDato
CREATE TABLE CAT_TipoDato(
	IdTipoDato INT PRIMARY KEY,
	Descripcion NVARCHAR(100),
	Observaciones NVARCHAR(500)
) 

INSERT INTO CAT_TipoDato
SELECT * FROM (VALUES
(1,'int',''),
(2,'string',''),
(3,'bool','true/false'),
(4,'date','dd/mm/yyyy')
)Q(a,b,c)

--drop table CAT_ReportesParametros
CREATE TABLE CAT_ReportesParametros(
	IdParametro INT PRIMARY KEY,
	Nombre NVARCHAR(100),
	Descripcion NVARCHAR(500),
	IdTipoDato INT REFERENCES CAT_TipoDato(IdTipoDato),
	Obligatorio BIT,
	Val_Default NVARCHAR(500)
)

--ALTER TABLE CAT_ReportesParametros 
--ADD TieneMapeo BIT
--ALTER TABLE CAT_ReportesParametros
--ADD Mapeo nvarchar(max)

--drop table REL_Parametros_Reporte
CREATE TABLE REL_Parametros_Reporte(	
	IdReporte INT REFERENCES CAT_Reportes(IdReporte),
	IdParametro INT REFERENCES CAT_ReportesParametros(IdParametro),
	PRIMARY KEY(IdReporte,IdParametro)
)


exec sp_helptext sp_LEG_getLavadoDinero_Encapsulado_CortoNuevoFormato
select * from Leg_PrevencionLavadoDinero
EXEC sp_LEG_getLavadoDinero_Encapsulado_CortoNuevoFormato 'Todas','México',01,2022
EXEC sp_LEG_getLavadoDinero_Encapsulado_LargoNuevoFormato 'Todas','México',01,2022


--DELETE FROM CAT_Reportes;
INSERT INTO CAT_Reportes
SELECT * FROM (VALUES
(1,'Archivo Completo','.','ArchivoCompleto@Month@Year','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;','EXEC sp_LEG_getLavadoDinero_Encapsulado_Largo @Branch,@Region,@Month,@Year',1,1),
(2,'EmpeñosMayores100Mil + Mes.','.','EmpeñosMayores100Mil@Month@Year','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;','EXEC sp_LEG_getLavadoDinero_Encapsulado_Mayor_noventa_mil @Branch,@Region,@Month,@Year',1,1),
(3,'Encapsulado Corto DistritoFederal.','.','DistritoFederal@Month@Year','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;','EXEC sp_LEG_getLavadoDinero_Encapsulado_Corto @Branch,@Region,@Month,@Year',1,1),
(4,'Encapsulado Corto Nuevo Formato Entregable.','.','EstadoMexicoNuevoFormatoEntregable@Month@Year','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;','EXEC sp_LEG_getLavadoDinero_Encapsulado_CortoNuevoFormato @Branch,@Region,@Month,@Year',1,1),
(5,'Encapsulado Largo Nuevo Formato.','.','EstadoMexicoNuevoFormato@Month@Year','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;','EXEC sp_LEG_getLavadoDinero_Encapsulado_LargoNuevoFormato @Branch,@Region,@Month,@Year',1,1),
(6,'SP de congelamiento para ventas de Metales.','.','Proceso de Congelamiento Ventas por Período de Metales','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;','EXEC sp_REP_setVentasXPeriodo @SBranch,@Region,1',NULL,1),
(7,'SP de congelamiento para ventas de vehículos.','.','Proceso de Congelamiento Ventas por Período de Vehículos','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;','EXEC sp_REP_setVentasXPeriodo @Branch,@Region,2',NULL,1),
(8,'Reporte Ventas 50Mil Metales.','.','ReporteVentas50MilMetales@Month@Year','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;','SET dateformat=dmy; EXEC sp_REP_getReporteMetales @InitialDate, @FinalDate',1,1),
(9,'Reporte Ventas 100Mil Vehículos.','.','ReporteVentas100MilVehiculos@Month@Year','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;','SET dateformat=dmy; EXEC sp_REP_getReporteVehiculo @InitialDate, @FinalDate',1,1),
(10,'Proceso de Congelamiento para Lavado de Dinero.','.','Proceso de congelamiento de datos.','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;','SET dateformat=dmy; EXEC sp_LEG_setAntiLavado 0, 0, @InitialDate, @FinalDate',NULL,1)
)Q(a,b,c,d,e,f,g,h)
--falta mayores a 100Mil

--DELETE FROM CAT_ReportesParametros;
INSERT INTO CAT_ReportesParametros
SELECT * FROM (VALUES
 (1,'Month','Month',1,1,NULL,1,'SELECT dbo.Fn_ObtenerMesTexto(@Month)'),
 (2,'Year','Year',1,1,NULL,NULL,NULL),
 (3,'InitialDate','InitialDate',2,1,NULL,NULL,NULL),
 (4,'FinalDate','FinalDate',2,1,NULL,NULL,NULL),
 (5,'Branch','Branch',2,1,NULL,NULL,NULL),
 (6,'Region','Region',2,1,NULL,NULL,NULL)
)Q(a,b,c,d,e,f,g,h)

--SELECT dbo.Fn_ObtenerMesTexto(1) 

--CREATE FUNCTION Fn_ObtenerMesTexto
--(@Mes INT)
--RETURNS NVARCHAR(12) AS 
--BEGIN
--DECLARE @Resultado NVARCHAR(12)
--	SELECT @Resultado = CASE 
--		WHEN @Mes=1 THEN 'Enero'
--		WHEN @Mes=2 THEN 'Febrero'
--		WHEN @Mes=3 THEN 'Marzo'
--		WHEN @Mes=4 THEN 'Abril'
--		WHEN @Mes=5 THEN 'Mayo'
--		WHEN @Mes=6 THEN 'Junio'
--		WHEN @Mes=7 THEN 'Julio'
--		WHEN @Mes=8 THEN 'Agosto'
--		WHEN @Mes=9 THEN 'Septiembre'
--		WHEN @Mes=10 THEN 'Octubre'
--		WHEN @Mes=11 THEN 'Noviembre'
--		WHEN @Mes=12 THEN 'Diciembre'
--	END
--	RETURN @Resultado;
--END

--DELETE FROM REL_Parametros_Reporte;
INSERT INTO REL_Parametros_Reporte
SELECT * FROM (VALUES
 (1,1),(1,2),(1,5),(1,6),
 (2,1),(2,2),(2,5),(2,6),
 (3,1),(3,2),(3,5),(3,6),
 (4,1),(4,2),(4,5),(4,6),
 (5,1),(5,2),(5,5),(5,6),
 -- 15 y 16 nollevan parametros
 (6,3),(6,4),
 (9,3),(7,4),
 (10,3),(8,4)
  )Q(a,b)

  CREATE TABLE CAT_ReportesMapeoColumnas(
	IdColumna INT IDENTITY PRIMARY KEY,
	CampoDB NVARCHAR(100),
	Alias NVARCHAR(100)
  )

  --DELETE FROM CAT_ReportesMapeoColumnas;
INSERT INTO CAT_ReportesMapeoColumnas
SELECT * FROM (VALUES
 (1,'ApellidoPaterno','Apellido Paterno'),	
 (2,'ApellidoMaterno','Apellido Materno'),	
 (3,'NombredelCliente','Nombre'),	
 (4,'NombreCompleto','Nombre Completo'),	
 (5,'Calle','Calle'),	
 (6,'NumeroExterior','Número Exterior'),	
 (7,'Interior','Interior'),	
 (8,'Colonia','Colonia'),	
 (9,'DelegacionMunicipio','Delegación Municipio'),	
 (10,'EntidadFederativa','Entidad Federativa'),	
 (11,'TipoComprobanteDomicilio','Tipo Comprobante Domicilio'),	
 (12,'TipoIdentificacion','Tipo Identificacion'),	
 (13,'NumeroSucural','Numero Sucural'),	
 (14,'ClaveSucursal','Clave Sucursal'),	
 (15,'Calle_Sucursal','Calle Sucursal'),	
 (16,'Colonia_Sucursal','Colonia Sucursal'),	
 (17,'DelegacionMunicipio_Sucursal','Delegación Municipio Sucursal'),	
 (18,'EntidadFederativa_Sucursal','Entidad Federativa Sucursal'),	
 (19,'NumeroContrato','Numero Contrato'),	
 (20,'FechaOperacion','Fecha Operacion'),	
 (21,'PrestamoContrato','Prestamo Contrato'),	
 (22,'descripcion','Descripción Prenda'),	
 (23,'observaciones','Observaciones'),	
 (24,'PrestamoPrenda','Prestamo Prenda'),	
 (25,'Tipo','Tipo'),	
 (26,'subfamilia','SubFamilia'),	
 (27,'Marca','Marca'),	
 (28,'Modelo','Modelo'),	
 (29,'Color','Color'),	
 (30,'Serie','Serie'),	
 (31,'IMEI','IMEI'),	
 (32,'Kilates','Kilates'),	
 (33,'Peso','Peso'),	
 (34,'IMSS','IMSS'),	
 (35,'Sistema','Sistema'),	
 (36,'RangoPrestamo','Rango Prestamo'),	
 (37,'ArticulosSemejantes3','3 Artículos Semejantes'),	
 (38,'MultiplesOperaciones','Multiples Operaciones'),	
 (39,'Pignoracion30_100mil','Pignoracion 30-100 mil'),	
 (40,'ArticulosSemejantes10','10 Artículos Semejantes'),	
 (41,'NombreOperador','Nombre Operador'),	
 (42,'ApellidoPaternoOperador','Apellido Paterno Operador'),	
 (43,'ApellidoMaternoOperador','Apellido Materno Operador'),	
 (44,'PlazoPrestamo','Plazo Prestamo'),	
 (45,'NumeroRefrendos','Numero Refrendos'),	
 (46,'Destino','Destino'),	
 (47,'LadaTelefonoParticular','Lada Teléfono Particular'),	
 (48,'TelefonoParticular','Teléfono Particular'),	
 (49,'CodigoPostal','Codigo Postal'),	
 (50,'ActividadEconomica','Actividad Economica'),	
 (51,'FormaPago','Forma de Pago')
)Q(a,	b,	c)

	--select * from CAT_ReportesMapeoColumnas
--DROP TABLE REL_Reporte_MapeoColumnas
CREATE TABLE REL_Reporte_MapeoColumnas(
	IdColumna INT REFERENCES CAT_ReportesMapeoColumnas(IdColumna),
	IdReporte INT REFERENCES CAT_Reportes(IdReporte),
	Orden INT,
	PRIMARY KEY (IdColumna,IdReporte)
)

INSERT INTO REL_Reporte_MapeoColumnas
SELECT * FROM (VALUES
(1,1,1),	(1,2,2),	(1,3,3),	(1,4,4),	(1,5,5),	(1,6,6),	(1,7,7),	(1,8,8),	
(1,9,9),	(1,10,10),	(1,11,11),	(1,12,12),	(1,13,13),	(1,14,14),	(1,15,15),	(1,16,16),	
(1,17,17),	(1,18,18),	(1,19,19),	(1,20,20),	(1,21,21),	(1,22,22),	(1,23,23),	(1,24,24),	
(1,25,25),	(1,26,26),	(1,27,27),	(1,28,28),	(1,29,29),	(1,30,30),	(1,31,31),	(1,32,32),	
(1,33,33),	(1,34,34),	(1,35,35),	(1,36,36),	(1,37,37),	(1,38,38),	(1,39,39),	(1,40,40),	
(1,41,41),	(1,42,42),	(1,43,43),	(1,44,44),	(1,45,45),	(1,46,46),	(1,47,47),	(1,48,48),	
(1,49,49),	(1,50,50),	(1,51,51)
)Q(a,b,c)


  create table TypesOutput(
		Formato VARCHAR(250) ,
		IDGrupo INT,
  )

  select * from Typesoutput 
  INSERT INTO TypesOutput
	SELECT * FROM (VALUES
	('xlsx',1),
	('xlsx',2),
	('pdf',2),
	('pdf',3),
	('process',4)
  )Q(a,b)
