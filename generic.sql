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
