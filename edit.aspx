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
		
		function AddCatalogoReveal(uiItem){
			CrearPantalla("views-control",function(parentNode){
				VerCatalogo(uiItem.getAttribute("concepto"),parentNode,uiItem.getAttribute("visibles").split(","), CrearForm);
			}); 
		}
		
		$(function(){	
			Reveal.initialize({history: true,transition: 'slide',width:"100%", height:"100%"});
			AddCatalogoReveal(document.getElementById("cinicial"));			
		});
		 
		 function GuardarEdicion(){
			var concepto= _conceptoActual;
			var _form= $(".present form")[0];
			Guardar(_form, concepto);
		 }
		 
		 function EliminarItem_(){
			var datai= item_seleccionado.datai;
			EliminarItem(GetVal(datai,"indice"));
		 }
		 
		 function CrearForm(isEdit){
			var concepto= _conceptoActual;
			var datai;
			if(isEdit) datai= item_seleccionado.datai;
			CrearPantalla('views-control',function(parentNode){				
				MostrarForm(concepto,parentNode,datai,isEdit);
			});
		 }
		 
		</script>
		
	<!--Fin-->
	<style>
		html,body{height:100%;margin:0px;background-color:#333;color:#ddd;}
		body.*{font-family:Roboto Verdana;}
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
		div.buttons button.btn-primary{float:left;margin-left:5%;}
		div.edit{width:100%;height:90%;overflow:auto;clear:right;}
		ul.objetos.sel{width:50%;float:left;}
		section{border:0px;margin:0px !important;}
		section h1{font-size:1em !important;text-align:center;}
		
		div.reveal .slides{text-align:inherit}
		div.reveal section.present{height:100%;overflow:auto;}
		
		.seleccionado{background-color:rgb(#99ddee)}
		
	</style>
	
</head>
<body>        
		<div class="wrap">			
			<div class="group">
				<div class="buttons">
					<div class="dropdown">
						<button class="btn btn-primary dropdown-toggle" type="button" id="dropdownMenuButtonSM" data-bs-toggle="dropdown" aria-expanded="false">
						  Objetos editables
						</button>
						<ul class="dropdown-menu" aria-labelledby="dropdownMenuButtonSM">
							<li id="cinicial" concepto="COM_Proyectos" visibles="'descripcion'" onclick="AddCatalogoReveal(this);"><label class="dropdown-item">Proyectos</label></li>
							<li concepto="META_TiposUnidadUI" visibles="'descripcion'"onclick="AddCatalogoReveal(this);" ><label class="dropdown-item">Componentes</label></li>
							<li concepto="UI_Layouts" visibles="'descripcion'" onclick="AddCatalogoReveal(this);" ><label class="dropdown-item">Layouts</label></li>
							<li concepto="UI_Vistas" visibles="'descripcion'" onclick="AddCatalogoReveal(this);" ><label class="dropdown-item">Views</label></li>
						</ul>
					</div>
					<button class="btn btn-danger"  style="margin-left:40px;" onclick="EliminarItem_();">Eliminar</button>
					<button class="btn btn-success" onclick="GuardarEdicion();">Guardar</button>
					<button class="btn btn-secondary" onclick="CrearForm(true);">Editar</button>
					<button class="btn btn-warning" onclick="CrearForm(false);">Nuevo</button>
				</div>
				<div class="edit" id="edit">
					<div class="reveal"><div class="slides" id="views-control"></div></div>
				</div>
			</div>
			<div class="vista"><iframe src="index.aspx"/></div>	
		</div>
</body>
</html> 
