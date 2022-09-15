<%@ Page Language="C#" %>
<%@ Import Namespace="Server"%>
<%@ Import Namespace="System.Data"%>

<%@ Register Src="~/header.ascx" TagPrefix="uc1" TagName="header" %>
<%@ Register Src="~/footer.ascx" TagPrefix="uc2" TagName="footer" %>
<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
    <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1, user-scalable=0"/>
    <script src="js/jquery-3.6.0.min.js"></script>
    <script src="assets/dist/js/bootstrap.bundle.min.js"></script>
    <script src="js/root.js?v=1.2"></script>
	<link rel="stylesheet" href="assets/dist/css/bootstrap.min.css">
	<link rel="stylesheet" href="reveal/dist/reveal.css">
	<script src="reveal/dist/reveal.js"></script>
	<link rel="stylesheet" href="reveal/dist/theme/white.css" id="theme">
	<script>		
		window.onload= function(){
			_ROOT_SYSTEM.url_base= document.body.getAttribute("url");
			_ROOT_SYSTEM.vistaInicial= document.body.getAttribute("vista");
			_ROOT_SYSTEM.contenedor= document.body.getAttribute("contenedor");
			_ROOT_SYSTEM.ConstruirUI(_ROOT_SYSTEM.url_base,_ROOT_SYSTEM.vistaInicial,_ROOT_SYSTEM.contenedor);
		}
		
		$(function(){	
			Reveal.initialize({history: true,transition: 'slide',width:"100%", height:"100%"});
		});
	</script>
	<style>
		html,body{height:100%;margin:0px;}
		body.*{font-family:Roboto Verdana;color:#444;}
		div.reveal .slides{text-align:inherit}
		div.reveal section.present{height:100%;overflow:auto;}
	</style>
</head>
<body vista="1" url="/logic/controlador.aspx" contenedor="views-control">
	<div class="reveal"><div class="slides" id="views-control"><section></section></div></div>
</body>
</html>
