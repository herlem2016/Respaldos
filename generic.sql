--CREATE DATABASE _ROOT_SYSTEM; 
USE _ROOT_SYSTEM;

CREATE TABLE SEG_Personas(
	indice INT PRIMARY KEY,
	fecha DATETIME,
	nombre NVARCHAR(200),
	fecha_nacimiento DATE,
	rfc NVARCHAR(10),
	curp NVARCHAR(20)
)
	CREATE DATABASE _ROOT_SYSTEM; 
USE _ROOT_SYSTEM;

CREATE TABLE SEG_Personas(
	indice INT PRIMARY KEY,
	fecha DATETIME,
	nombre NVARCHAR(200),
	fecha_nacimiento DATE,
	rfc NVARCHAR(10),
	curp NVARCHAR(20)
)
	
CREATE TABLE COM_Proyectos(
	indice INT PRIMARY KEY,
	fecha DATETIME,
	descripcion NVARCHAR(300),
	activo INT
)

CREATE TABLE SEG_PerfilUsuarios(	
	indice INT IDENTITY PRIMARY KEY,
	fecha DATETIME,
	descripcion NVARCHAR(300),
	persona INT REFERENCES SEG_Personas(indice),
	proyecto INT REFERENCES COM_Proyectos(indice)
)

CREATE TABLE SEG_LOG_(
	indice INT IDENTITY PRIMARY KEY,
	fecha DATETIME,
	descripcion NVARCHAR(300),
	perfil_usuario INT REFERENCES SEG_PerfilUsuarios(indice)
)

CREATE TABLE GEN_Archivos(
	indice INT IDENTITY PRIMARY KEY,
	url_ NVARCHAR(350),
	fecha DATETIME
)

CREATE TABLE META_TiposUnidadUI(--Se convierte en una especificacion de clase de Objeto UI.
	indice INT PRIMARY KEY,
	descripcion NVARCHAR(200),
	css NVARCHAR(MAX),
	class NVARCHAR(50),--Por defecto le da funcionalidad básica de acuerdo con lo ya existente en boostrap por ejemplo.
	atributos NVARCHAR(500),
	metodos text--Aquí se colocan los metodos de la clase de objeto UI;
)
ALTER TABLE META_TiposUnidadUI ALTER COLUMN innerHTML NVARCHAR(4000);
ALTER TABLE META_TiposUnidadUI ADD javascript NVARCHAR(MAX);

CREATE TABLE META_Componentes(
	indice INT PRIMARY KEY,
	fecha DATETIME,
	descripcion NVARCHAR(300),
	titulo NVARCHAR(300),
	tooltip NVARCHAR(300),
	layout INT REFERENCES META_TiposUnidadUI(indice)
)

CREATE TABLE META_UnidadesUI(--Que unidad ui existe en el componente
	indice INT PRIMARY KEY,
	componente INT REFERENCES META_Componentes(indice),
	tipoUnidadUI INT REFERENCES META_TiposUnidadUI(indice),
	orden NVARCHAR(50)
)

CREATE TABLE META_Navegacion(
	indice INT PRIMARY KEY,
	proyecto INT REFERENCES COM_Proyectos(indice),
	descripcion NVARCHAR(200),
	nav_padre INT NULL REFERENCES META_Navegacion(indice),
	icon INT REFERENCES GEN_Archivos(indice),
	pantalla INT REFERENCES META_Componentes(indice)
)

CREATE TABLE META_PropiedadesTiposUnidadesUI(-- que propiedades tienen los tipos de unidades ui
	indice INT IDENTITY PRIMARY KEY,
	tipoUnidadUI INT REFERENCES META_TiposUnidadUI(indice),
	descripcion NVARCHAR(200),
	css NVARCHAR(300),
	class NVARCHAR(100)
)


CREATE TABLE META_MetodosSP(
	indice INT PRIMARY KEY,
	query NVARCHAR(MAX),
	privado BIT,
	perfil_usuario INT REFERENCES SEG_PerfilUsuarios(indice),
	email_adjunto_url NVARCHAR(100),
	email_adjunto_params NVARCHAR(200)	
)

CREATE TABLE META_ParametrosSP(
	indice INT PRIMARY KEY,
	nombre NVARCHAR(50),
	var_sp NVARCHAR(50),
	obligatorio NVARCHAR(50),
	size SMALLINT,
	alias NVARCHAR(80),
	tipo NVARCHAR(20)
)


CREATE TABLE META_Entidades(
	indice INT PRIMARY KEY,
	descripcion NVARCHAR(50)
)

CREATE TABLE META_CamposEntidad(
	indice INT PRIMARY KEY,
	nombre NVARCHAR(50),
	var_sp NVARCHAR(50),
	obligatorio NVARCHAR(50),
	size SMALLINT,
	alias NVARCHAR(80),
	tipo NVARCHAR(20),
	referencia NVARCHAR(150),
	oculto BIT
)

ALTER TABLE COM_Proyectos ADD password_ NVARCHAR(20)
ALTER TABLE COM_Proyectos ADD ui INT REFERENCES META_Componentes(indice);
ALTER TABLE META_Componentes ADD proyecto INT REFERENCES COM_proyectos(indice);

CREATE TABLE META_ValoresPropiedadesUnidadesUI(
	indice INT IDENTITY PRIMARY KEY,
	unidadUI INT REFERENCES META_UnidadesUI(indice),
	propiedad INT REFERENCES META_PropiedadesTiposUnidadesUI(indice),
	valor NVARCHAR(800)
)

CREATE TABLE COM_Proyectos(
	indice INT PRIMARY KEY,
	fecha DATETIME,
	descripcion NVARCHAR(300),
	activo INT
)

CREATE TABLE SEG_PerfilUsuarios(	
	indice INT IDENTITY PRIMARY KEY,
	fecha DATETIME,
	descripcion NVARCHAR(300),
	persona INT REFERENCES SEG_Personas(indice),
	proyecto INT REFERENCES COM_Proyectos(indice)
)

CREATE TABLE SEG_LOG_(
	indice INT IDENTITY PRIMARY KEY,
	fecha DATETIME,
	descripcion NVARCHAR(300),
	perfil_usuario INT REFERENCES SEG_PerfilUsuarios(indice)
)

CREATE TABLE GEN_Archivos(
	indice INT IDENTITY PRIMARY KEY,
	url_ NVARCHAR(350),
	fecha DATETIME
)


CREATE TABLE META_Layout(
	indice INT PRIMARY KEY,
	tipoUnidadUI INT REFERENCES META_TiposUnidadUI(indice),
	orden SMALLINT
)


CREATE TABLE META_Componentes(
	indice INT PRIMARY KEY,
	fecha DATETIME,
	descripcion NVARCHAR(300),
	titulo NVARCHAR(300),
	tooltip NVARCHAR(300),
	componete_padre INT NULL REFERENCES META_Componentes(indice),
	layout INT REFERENCES META_Layout(indice)
)

CREATE TABLE META_Navegacion(
	indice INT PRIMARY KEY,
	proyecto INT REFERENCES COM_Proyectos(indice),
	descripcion NVARCHAR(200),
	nav_padre INT NULL REFERENCES META_Navegacion(indice),
	icon INT REFERENCES GEN_Archivos(indice),
	pantalla INT REFERENCES META_Componentes(indice)
)

CREATE TABLE META_TiposUnidadUI(
	indice INT PRIMARY KEY,
	descripcion NVARCHAR(200),
	tipo INT
)


CREATE TABLE META_ComponentesUnidadesUI(--Que unidad ui existe en el componente
	indice INT PRIMARY KEY,
	componente INT REFERENCES META_Componentes(indice),
	tipoUnidadUI INT REFERENCES META_TiposUnidadUI(indice),
	orden SMALLINT,

)

CREATE TABLE META_PropiedadesUnidadesUI(-- que propiedades tienen los tipos de unidades ui
	indice INT IDENTITY PRIMARY KEY,
	tipoUnidadUI INT REFERENCES META_TiposUnidadUI(indice),
	descripcion NVARCHAR(200),
	css NVARCHAR(300),
	class NVARCHAR(100)
)

CREATE TABLE META_UnidadesUI(
	indice INT IDENTITY PRIMARY KEY,
	tipo INT REFERENCES META_TiposUnidadUI(indice),
	fuente_datos_url NVARCHAR(400),
	campos_columnas NVARCHAR(400),
	campos_columnas_ocultos NVARCHAR(400),
	campo_val NVARCHAR(50),
	campo_display NVARCHAR(50),
	campos_depende NVARCHAR(200),
	regexp NVARCHAR(50),
	obligatorio BIT,
	size SMALLINT,
	css NVARCHAR(300),
	class NVARCHAR(200)
	--Se pretendía incluir campo dinámico(que se calcule al vuelo) pero mejor se decide que vengan creados desde BD.
)

CREATE TABLE META_TiposMsjsUI(
	indice SMALLINT IDENTITY PRIMARY KEY,
	descripcion NVARCHAR(100)
)

CREATE TABLE META_MsjsUnidadesUI(
	indice INT IDENTITY PRIMARY KEY,
	tipo SMALLINT REFERENCES META_TiposMsjsUI(indice),
	unidadUI INT REFERENCES META_UnidadesUI(indice),
)

CREATE TABLE META_EventosUnidadesUI(
	indice INT IDENTITY PRIMARY KEY,
	tipo NVARCHAR(20),
	valor NVARCHAR(4000),
	unidadui INT REFERENCES META_UnidadesUI(indice)
)

CREATE TABLE META_MetodosSP(
	indice INT PRIMARY KEY,
	query NVARCHAR(MAX),
	privado BIT,
	perfil_usuario INT REFERENCES SEG_PerfilUsuarios(indice),
	email_adjunto_url NVARCHAR(100),
	email_adjunto_params NVARCHAR(200)	
)

CREATE TABLE META_ParametrosSP(
	indice INT PRIMARY KEY,
	nombre NVARCHAR(50),
	var_sp NVARCHAR(50),
	obligatorio NVARCHAR(50),
	size SMALLINT,
	alias NVARCHAR(80),
	tipo NVARCHAR(20)
)


CREATE TABLE META_Entidades(
	indice INT PRIMARY KEY,
	descripcion NVARCHAR(50)
)

CREATE TABLE META_CamposEntidad(
	indice INT PRIMARY KEY,
	nombre NVARCHAR(50),
	var_sp NVARCHAR(50),
	obligatorio NVARCHAR(50),
	size SMALLINT,
	alias NVARCHAR(80),
	tipo NVARCHAR(20),
	referencia NVARCHAR(150),
	oculto BIT
)


SELECT 
    Q.indice,
	R.innerHTML,
    CONVERT(XML,(SELECT  A.indice,
				B.innerHTML,
                dbo.AnidacionUI(A.indice) UnidadesUI 
        FROM    META_UnidadesUI A INNER JOIN META_TiposUnidadUI B ON A.tipoUnidadUI=B.indice
        WHERE   unidadUI_padre = Q.indice
        FOR XML PATH('UnidadUI')))   
FROM dbo.META_UnidadesUI Q INNER JOIN META_TiposUnidadUI R ON Q.tipoUnidadUI=R.indice
WHERE Q.indice=5
FOR XML PATH ('ComponenteUI')


CREATE TABLE OP_OperacionesCX(
	indice INT PRIMARY KEY,
	nombre NVARCHAR(300),
	sql_query TEXT,
	documentacion NVARCHAR(1000),
	publico BIT,
	seg_perfil INT--REFERENCES SEG_PerfilUsuarios
)

CREATE TABLE OP_OperacionesCX_Parametros(
	indice INT PRIMARY KEY,
	operacioncx INT REFERENCES OP_OperacionesCX(indice),
	leyenda NVARCHAR(100),
	nombre NVARCHAR(50),
	nombre_db NVARCHAR(50),
	requerido BIT,
	tipo NVARCHAR(50),
	longitud SMALLINT,
	_default NVARCHAR(200)
)

ALTER TABLE [dbo].[OP_OperacionesCX] ADD UNIQUE(nombre);
ALTER TABLE [dbo].[OP_OperacionesCX] ALTER COLUMN nombre NVARCHAR(100) NOT NULL;

SELECT sql_query FROM OP_OperacionesCX

CREATE TABLE META_Help(
	indice INT IDENTITY PRIMARY KEY,
	help_usuario TEXT,
	help_admin TEXT,
	help_develop TEXT
)

CREATE TABLE META_InstanciasUI(
	indice INT PRIMARY KEY,
	referencia NVARCHAR(200),
	titulo NVARCHAR(200),
	descripcion NVARCHAR(1000),
	layout INT REFERENCES META_Layouts(indice),
	help INT 
)

CREATE TABLE META_InstanciasUI_InfoUI(
	indice INT PRIMARY KEY,
	instanciaUI INT REFERENCES META_InstanciasUI(indice),
	unidadUI INT REFERENCES META_unidadesUI(indice),
	infoUI INT REFERENCES OP_OperacionesCX(indice)
)

SELECT unidadUI.indice AS '@indice', unidadUI.orden AS '@orden',unidadUI.opx AS '@opx',unidadUI.data, tipoUnidadUI.item_repeat,tipoUnidadUI.wrap,  tipoUnidadUI.descripcion,tipoUnidadUI.indice tipoUnidad, tipoUnidadUI.innerHTML,tipoUnidadUI.css,tipoUnidadUI.javascript, propiedad.descripcion, valor 
,dbo.AnidacionUI(tipoUnidadUI.indice) 
FROM UI_Componentes unidadUI 
INNER JOIN [META_TiposUnidadUI] tipoUnidadUI ON unidadUI.tipoUnidadUI=tipoUnidadUI.indice AND unidadUI.vista=1
LEFT OUTER JOIN META_PropiedadesTiposUnidadesUI propiedad ON tipoUnidadUI.indice=propiedad.tipoUnidadUI
LEFT OUTER JOIN UI_ValoresPropiedadesUnidadesUI valor ON valor.propiedad=propiedad.indice				
ORDER BY unidadUI.orden ASC
FOR XML PATH('UnidadUI'), ROOT('layout')


CREATE TABLE UI_Layouts(
	indice INT PRIMARY KEY,
	descripcion NVARCHAR(200),
	html NVARCHAR(MAX),
	css NVARCHAR(MAX),
	javascript NVARCHAR(MAX)
)

CREATE TABLE UI_Vistas(
	indice INT PRIMARY KEY,
	descripcion NVARCHAR(200),
	html NVARCHAR(MAX),
	css NVARCHAR(MAX),
	javascript NVARCHAR(MAX),
	icon INT REFERENCES GEN_Archivos(indice)
)

