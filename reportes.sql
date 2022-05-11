
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
	TypesOutput INT,
	ModoMapeo INT,--Si es 1, Solo Mantiene las columnas que esten mapeadas, 2. No realiza ningún mapeo y  0.[default] Coloca Todas las columnas, con el orden indicado, además incluye todas las demas que se encuentren en el sp y no en el mapeo.
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
(4,'date','dd/mm/yyyy'),
(5,'money','##.##')
)Q(a,b,c)

--drop table CAT_ReportesParametros
CREATE TABLE CAT_ReportesParametros(
	IdParametro INT PRIMARY KEY,
	Nombre NVARCHAR(100),
	Descripcion NVARCHAR(500),
	IdTipoDato INT REFERENCES CAT_TipoDato(IdTipoDato),
	Obligatorio BIT,
	Val_Default NVARCHAR(500),
	TieneMapeo BIT,
	Mapeo nvarchar(max)
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
INSERT INTO CAT_Reportes(IdReporte,	Nombre,	Descripcion,Entregable,ScriptValidacion,ScriptSQl,Estatus,IdNotificacion,TypesOutput)
SELECT * FROM (VALUES
(1,'Archivo Completo','.','ArchivoCompleto@Month@Year','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;','EXEC sp_LEG_getLavadoDinero_Encapsulado_Largo @Branch,@Region,@Month,@Year',1,1,1),
(2,'EmpeñosMayores100Mil + Mes.','.','EmpeñosMayores100Mil@Month@Year','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;','EXEC sp_LEG_getLavadoDinero_Encapsulado_Mayor_noventa_mil @Branch,@Region,@Month,@Year',1,1,1),
(3,'Encapsulado Corto DistritoFederal.','.','DistritoFederal@Month@Year','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;','EXEC sp_LEG_getLavadoDinero_Encapsulado_Corto @Branch,@Region,@Month,@Year',1,1,2),
(4,'Encapsulado Corto Nuevo Formato Entregable.','.','EstadoMexicoNuevoFormatoEntregable@Month@Year','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;','EXEC sp_LEG_getLavadoDinero_Encapsulado_CortoNuevoFormato @Branch,@Region,@Month,@Year',1,1,1),
(5,'Encapsulado Largo Nuevo Formato.','.','EstadoMexicoNuevoFormato@Month@Year','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;','EXEC sp_LEG_getLavadoDinero_Encapsulado_LargoNuevoFormato @Branch,@Region,@Month,@Year',1,1,1),
(6,'SP de congelamiento para ventas de Metales.','.','Proceso de Congelamiento Ventas por Período de Metales','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;','EXEC sp_REP_setVentasXPeriodo @Branch,@Region,1',NULL,1,4),
(7,'SP de congelamiento para ventas de vehículos.','.','Proceso de Congelamiento Ventas por Período de Vehículos','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;','EXEC sp_REP_setVentasXPeriodo @Branch,@Region,2',NULL,1,4),
(8,'Reporte Ventas 50Mil Metales.','.','ReporteVentas50MilMetales@InitialDate_@FinalDate','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;',' EXEC sp_REP_getReporteMetales @InitialDate, @FinalDate',1,1,1),
(9,'Reporte Ventas 100Mil Vehículos.','.','ReporteVentas100MilVehiculos@InitialDate_@FinalDate','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;',' EXEC sp_REP_getReporteVehiculo @InitialDate, @FinalDate',1,1,1),
(10,'Proceso de Congelamiento para Lavado de Dinero.','.','ProcesoCongelamientoLavadoDinero@InitialDate_@FinalDate','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;','SET dateformat=dmy; EXEC sp_LEG_setAntiLavado 0, 0, @InitialDate, @FinalDate',NULL,1,4),
(11,'Reporte Cierre de Sucursal.','.','ReporteCierreSucursal@IdBranch-@InitialDate_@FinalDate','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;',' EXEC sp_REP_getCierresSucursal @IdBranch, @InitialDate, @FinalDate',1,1,1),
(12,'Reporte Ventas','.','ReporteVentas@IdBranch-@InitialDate_@FinalDate','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;',' EXEC sp_REP_getVentas @InitialDate, @FinalDate, @IdBranch',1,1,1),
(13,'Reporte de Almoneda','.','ReporteAlmoneda@IdBranch-@InitialDate_@FinalDate','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;',' EXEC sp_REP_getAlmoneda @IdBranch, @InitialDate, @FinalDate, @IdType',1,1,1),
(14,'Reporte Empeños','.','ReporteEmpeños@IdBranch-@InitialDate_@FinalDate','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;',' EXEC sp_REP_getEmpeno @IdBranch, @InitialDate, @FinalDate, @IdType',1,1,1),
(15,'Reporte Refrendos','.','ReporteRefrendos@IdBranch-@InitialDate_@FinalDate','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;',' EXEC sp_REP_getRefrendo @IdBranch, @InitialDate, @FinalDate, @IdType',1,1,1),
(16,'Reporte Desempeños','.','ReporteDesempeños@IdBranch-@InitialDate_@FinalDate','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;',' EXEC sp_REP_getDesempeno @IdBranch, @InitialDate, @FinalDate, @IdType',1,1,1),
(17,'Reporte Saldos Historicos','.','ReporteSaldosHistorico@IdBranch','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;',' EXEC sp_FDE_getSaldosHistorico @IdBranch',1,1,1),
(18,'Reporte Profeco','.','ReporteProfeco@IdBranch-@InitialDate_@FinalDate','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;',' EXEC sp_REP_Profeco @InitialDate, @FinalDate, @IdBranch',1,1,1),
(19,'Reporte Gasto','.','ReporteGasto@IdBranch-@InitialDate_@FinalDate','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;',' EXEC sp_REP_getGasto @InitialDate, @FinalDate, @IdBranch, @All',1,1,1),
(20,'Reporte Apartado','.','ReporteApartado@Branch-@InitialDate_@FinalDate','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;','EXEC  sp_REP_getApartados @InitialDate, @FinalDate, @IdBranch',1,1,1),
(21,'Empeños por Vencer','.','EmpeñosXVencer@IdBranch','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;','EXEC sp_REP_getEmpeXVencer @IdBranch , @Days',1,1,1),
(22,'Movimientos por Caja','.','MovimientosXCaja@IdBranch-@IdComputer-@Date','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;','EXEC sp_REP_getMovimientosPorCaja @IdBranch, @IdComputer, @Date',1,1,1),
(23,'Reporte Legal Clientes','.','ReporteLegalClientes@IdClient','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;','EXEC sp_leg_getClientes @IdClient, @Month, @Year',1,1,1),
(24,'Monitoreo Mix','.','monitoreoMix@IdBranch','SELECT CONVERT(BIT,1) estatus, ''Prerequisitos Completados.'' message;','EXEC sp_EMP_getMonitoreoMIX @IdBranch',1,1,1)
)Q(a,b,c,d,e,f,g,h,i)
--falta mayores a 100Mil
UPDATE CAT_Reportes SET ModoMapeo=1 WHERE IdReporte=3

--DELETE FROM CAT_ReportesParametros;
INSERT INTO CAT_ReportesParametros
SELECT * FROM (VALUES
 (1,'Month','Month',1,1,NULL,1,'SELECT dbo.Fn_ObtenerMesTexto(@Month)'),
 (2,'Year','Year',1,1,NULL,NULL,NULL),
 (3,'InitialDate','InitialDate',2,1,NULL,1, 'Select dbo.fn_GetFecha23(@InitialDate)'),
 (4,'FinalDate','FinalDate',2,1,NULL,1, 'Select dbo.fn_GetFecha23(@FinalDate)'),
 (5,'Branch','Branch',2,1,NULL,NULL,NULL),
 (6,'Region','Region',2,1,NULL,NULL,NULL),
 (7,'IdType','IdType',1,1,NULL,NULL,NULL),
 (8,'All','All',1,1,NULL,NULL,NULL),
 (9,'IdBranch','IdBranch',1,1,NULL,NULL,NULL),
 (10,'Days','Days',1,1,NULL,NULL,NULL),
 (11,'Date','Date',2,1,NULL,NULL,NULL),
 (12,'IdComputer','IdComputer',1,1,NULL,NULL,NULL),
 (13,'IdClient','IdClient',2,1,NULL,NULL,NULL)
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
 -- 15 y 16 nollevan parametros(ahora 7 y 8)
 (6,3),(6,4),
 (8,3),(8,4),
 (9,3),(9,4),
 (10,3),(10,4),
 (11,9),(11,3),(11,4),
 (12,3),(12,4),(12,9),
 (13,9),(13,3),(13,4),(13,7),
 (14,9),(14,3),(14,4),(14,7),
 (15,9),(15,3),(15,4),(15,7),
 (16,9),(16,3),(16,4),(16,7),
 (17,9),
 (18,3),(18,4),(18,9),
 (19,3),(19,4),(19,9),(19,8),
 (20,3),(20,4),(20,9),
 (21,9),(21,10),
 (22,9),(22,12),(22,11),
 (23,13),(23,1),(23,2),
 (24,9)
 )Q(a,b)

 
CREATE TABLE CAT_ReportesMapeoColumnas(
	IdColumna INT IDENTITY PRIMARY KEY,
	IdReporte INT REFERENCES CAT_Reportes(IDReporte),
	Quitar BIT,
	TipoDato INT,
	EsAgrupacion BIT,
	Formula NVARCHAR(MAX),
	CampoDB NVARCHAR(100),
	Alias NVARCHAR(100)
)
SELECT * FROM CAT_ReportesMapeoColumnas WHERE IdReporte=1
  --TRUNCATE table CAT_ReportesMapeoColumnas
  --DELETE FROM CAT_ReportesMapeoColumnas WHERE IdReporte=1
  --Reporte 1
INSERT INTO CAT_ReportesMapeoColumnas(IdReporte,Quitar,CampoDB,Alias)
SELECT * FROM (VALUES
 (1,0,'ApellidoPaterno','Apellido Paterno'),	
 (1,0,'ApellidoMaterno','Apellido Materno'),	
 (1,0,'NombredelCliente','Nombre'),	
 (1,0,'NombreCompleto','Nombre Completo'),	
 (1,0,'Calle','Calle'),	
 (1,0,'NumeroExterior','Número Exterior'),	
 (1,0,'Interior','Interior'),	
 (1,0,'Colonia','Colonia'),	
 (1,0,'DelegacionMunicipio','Delegación Municipio'),	
 (1,0,'EntidadFederativa','Entidad Federativa'),	
 (1,0,'TipoComprobanteDomicilio','Tipo Comprobante Domicilio'),	
 (1,0,'TipoIdentificacion','Tipo Identificacion'),	
 (1,0,'NumeroSucural','Numero Sucural'),	
 (1,0,'ClaveSucursal','Clave Sucursal'),	
 (1,0,'Calle_Sucursal','Calle Sucursal'),	
 (1,0,'Colonia_Sucursal','Colonia Sucursal'),	
 (1,0,'DelegacionMunicipio_Sucursal','Delegación Municipio Sucursal'),	
 (1,0,'EntidadFederativa_Sucursal','Entidad Federativa Sucursal'),	
 (1,0,'NumeroContrato','Numero Contrato'),	
 (1,0,'FechaOperacion','Fecha Operacion'),
 (1,0,'PrestamoContrato','Prestamo Contrato'),	
 (1,0,'descripcion','Descripción Prenda'),	
 (1,0,'observaciones','Observaciones'),	
 (1,0,'PrestamoPrenda','Prestamo Prenda'),	
 (1,0,'Tipo','Tipo'),	
 (1,0,'subfamilia','SubFamilia'),	
 (1,0,'Marca','Marca'),	
 (1,0,'Modelo','Modelo'),	
 (1,0,'Color','Color'),	
 (1,0,'Serie','Serie'),	
 (1,0,'IMEI','IMEI'),	
 (1,0,'Kilates','Kilates'),	
 (1,0,'Peso','Peso'),	
 (1,0,'IMSS','IMSS'),	
 (1,0,'Sistema','Sistema'),	
 (1,0,'RangoPrestamo','Rango Prestamo'),	
 (1,0,'ArticulosSemejantes3','3 Artículos Semejantes'),	
 (1,0,'MultiplesOperaciones','Multiples Operaciones'),	
 (1,0,'Pignoracion30_100mil','Pignoracion 30-100 mil'),	
 (1,0,'ArticulosSemejantes10','10 Artículos Semejantes'),	
 (1,0,'NombreOperador','Nombre Operador'),	
 (1,0,'ApellidoPaternoOperador','Apellido Paterno Operador'),	
 (1,0,'ApellidoMaternoOperador','Apellido Materno Operador'),	
 (1,0,'PlazoPrestamo','Plazo Prestamo'),	
 (1,0,'NumeroRefrendos','Numero Refrendos'),
 (1,0,'Destino','Destino'),
 (1,0,'LadaTelefonoParticular','Lada Teléfono Particular'),	
 (1,0,'TelefonoParticular','Teléfono Particular'),	
 (1,1,'CodigoPostal','Codigo Postal'),	
 (1,0,'ActividadEconomica','Actividad Economica'),	
 (1,0,'FormaPago','Forma de Pago')
)Q(a,b,c,d)
--reporte 2
INSERT INTO CAT_ReportesMapeoColumnas
SELECT * FROM (VALUES
(3,0,NULL,1,NULL,'NombreCompleto','Nombre Completo'),	
(3,0,NULL,0,NULL,'Calle','Calle'),	
(3,0,NULL,0,NULL,'NumeroExterior','Numero Exterior'),	
(3,0,NULL,0,NULL,'Interior','Interior'),	
(3,0,NULL,0,NULL,'Colonia','Colonia'),	
(3,0,NULL,0,NULL,'DelegacionMunicipio','Delegación Municipio'),	
(3,0,NULL,0,NULL,'EntidadFederativa','Entidad'),	
(3,0,NULL,0,NULL,'TipoComprobanteDomicilio','Tipo Comprobante Domicilio'),	
(3,0,NULL,0,NULL,'TipoIdentificacion','Tipo Identificacion'),	
(3,0,NULL,0,NULL,'ClaveSucursal','Clave Sucursal'),	
(3,0,1,0,NULL,'NumeroContrato','Numero Contrato'),	
(3,0,NULL,0,NULL,'FechaOperacion','Fecha Operacion'),	
(3,0,NULL,0,NULL,'descripcion','Descripción'),	
(3,0,5,0,'SUMA','PrestamoPrenda','Prestamo por prenda'),	
(3,0,NULL,0,'CONTARA','Tipo','Tipo'),	
(3,0,NULL,0,NULL,'Marca','Marca'),	
(3,0,NULL,0,NULL,'NombreEmpresa','Nombre de la empresa'),	
(3,0,NULL,0,NULL,'LadaTelefonoParticular','Lada Télefono Particular'),	
(3,0,NULL,0,NULL,'TelefonoParticular','Teléfono Particular'),	
(3,0,NULL,0,NULL,'CodigoPostal','Codigo Postal'),	
(3,0,NULL,0,NULL,'ActividadEconomica','Actividad Economica'),	
(3,0,5,0,NULL,'Avaluo','Avalúo'),	
(3,0,NULL,0,NULL,'FormaPago','Forma de Pago')
)Q(a,b,c,d,e,f,g)
--contrato 3
INSERT INTO CAT_ReportesMapeoColumnas(IdReporte,Quitar,CampoDB,Alias)
SELECT * FROM (VALUES
(4,0,'Sucursal','Sucursal'),	
(4,0,'Contrato','Contrato'),	
(4,0,'FechaEmpeño','FechaEmpeño'),	
(4,0,'FechaVencimiento','FechaVencimiento'),	
(4,0,'Cliente','Cliente'),	
(4,0,'Avaluo','Avaluo'),	
(4,0,'PrestamoInicial','PrestamoInicial'),	
(4,0,'PrestamoSaldo','PrestamoSaldo'),	
(4,0,'Refrendo','Refrendo'),	
(4,0,'Desempeno','Desempeno'),	
(4,0,'Garantia','Garantia'),	
(4,0,'dias','dias'),	
(4,0,'TelefonoMovil','TelefonoMovil'),	
(4,0,'TelefonoParticular','TelefonoParticular'),	
(4,0,'TelefonoTrabajo','TelefonoTrabajo'),	
(4,0,'cotitular','cotitular'),	
(4,0,'NombrePromocion','NombrePromocion'),	
(4,0,'NumeroPromocion','NumeroPromocion'),	
(4,0,'DeseaRecibirNotificaciones','DeseaRecibirNotificaciones')
)Q(a,b,c,d)


SELECT * FROM CAT_ReportesMapeoColumnas

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
