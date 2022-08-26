<%@ Page Language="C#" %>
<%@ Import Namespace="Server"%>
<%@ Import Namespace="System.Data"%>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
    <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1, user-scalable=0"/>
    <script src="js/jquery-3.6.0.min.js"></script>
    <script src="assets/dist/js/bootstrap.bundle.min.js"></script>
	<link rel="stylesheet" href="assets/dist/css/bootstrap.min.css">
    <script src="js/root.js?v=1.2"></script>
	<link rel="stylesheet" href="reveal/dist/reveal.css">
	<script src="reveal/dist/reveal.js"></script>
	<link rel="stylesheet" href="reveal/dist/theme/white.css" id="theme">
	<link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">
	
	<style>
		.sel{height:100%;overflow:auto;}
		.sel li,.sel li label{cursor:pointer;}
		.sel li:active{background-color:#d9f;font-weight:bolder;}
		section.present{top:0px !important;}
	</style>
	<!--Editor-->		
		<link rel=stylesheet href="codemirror-5.65.5/lib/codemirror.css">
		<link rel=stylesheet href="codemirror-5.65.5/doc/docs.css">
		<script src="codemirror-5.65.5/lib/codemirror.js"></script>
		<script src="codemirror-5.65.5/mode/xml/xml.js"></script>
		<script src="codemirror-5.65.5/mode/javascript/javascript.js"></script>
		<script src="codemirror-5.65.5/mode/css/css.js"></script>
		<script src="codemirror-5.65.5/mode/htmlmixed/htmlmixed.js"></script>
		<script src="codemirror-5.65.5/addon/edit/matchbrackets.js"></script>
		
		<script>
		var _ROOT_SYSTEM= function(){}
		_ROOT_SYSTEM.url_base="/logic/controlador.aspx";
		$(function(){	
			Reveal.initialize({history: true,transition: 'slide',width:"80%", height:"100%"});
			CrearPantalla("views-control",function(parentNode){
				VerCatalogo('META_TiposUnidadUI',parentNode,['descripcion']);
			}); 		  
		});
		 
		 function GuardarEdicion(id,part){
			var content= encodeURIComponent(document.getElementById("e_" + part).value);
			$.post(url,{component:id,part:part,content:content},function(data){
				alert(GetVal(data,"mensaje"));
			});
		 }
		 
		 function Editar(concepto){
			CrearPantalla('views-control',function(parentNode){
				MostrarForm(concepto,parentNode);
			});
		 }
		 
		</script>
		
	<!--Fin-->
	<style>
		html,body{height:100%;margin:0px;}
		body.*{font-family:Roboto Verdana;color:#444;}
		.wrap{height:100%;width:100%;}
		.wrap .list,.wrap .group,.wrap .vista{height:100%;float:left;}
		.wrap .list .objetos{height:20%;margin:0px;}
		.wrap .list .list-components{height:80%;}
		.wrap .edit textarea{min-height:300px;}
		.wrap .group{width:70%;}		
		.wrap .vista{width:30%;}				
		.wrap .editor textarea,.wrap .vista iframe{width:100%;height:100%;float:left;}
		
		.CodeMirror { height: 100%; border: 1px solid #ddd; }
		.CodeMirror pre { padding-left: 7px; line-height: 1.25; }
		.banner { background: #ffc; padding: 6px; border-bottom: 2px solid silver; text-align: center }
		div.buttons{height:12%;width:100%;}
		div.buttons button{float:right;margin-right:20px;margin-top:10px;}
		div.edit{width:100%;height:85%;overflow:auto;clear:right;}
		ul.objetos.sel{width:50%;float:left;}
		section{border:0px;margin:0px !important;}
		section h1{font-size:1em !important;text-align:center;}
		
		div.reveal .slides{text-align:inherit}
		div.reveal section.present{height:100%;overflow:auto;}
		
	</style>
	
</head>
<body>        
		<div class="wrap">			
			<div class="group">
				<div class="buttons">
					<ul class="objetos sel">
						<li onclick="CrearPantalla('views-control',function(parentNode){VerCatalogo('COM_Proyectos',parentNode,['descripcion']);});"><label class="pro">Proyectos</label></li>
						<li onclick="CrearPantalla('views-control',function(parentNode){VerCatalogo('UI_Layouts',parentNode,['descripcion']);});"><label class="lay">Layouts</label></li>
						<li onclick="CrearPantalla('views-control',function(parentNode){VerCatalogo('META_TiposUnidadUI',parentNode,['descripcion']);});"><label class="comp">Componentes</label></li>
					</ul>
					<button onclick="Guardar($('#edit').find('form')[0],_conceptoActual);">Guardar</button>
					<button onclick="Editar(_conceptoActual);">Editar</button>
					<button onclick="NuevoItem($('#edit').find('form')[0],_conceptoActual);">Nuevo</button>
				</div>
				<div class="edit" id="edit">
					<div class="reveal"><div class="slides" id="views-control"></div></div>
				</div>
			</div>
			<div class="vista"><iframe src="index.aspx"/></div>	
		</div>
</body>
</html> 
