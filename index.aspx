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
</head>
<body proyecto="0" url="/logic/controlador.aspx" contenedor="wrap">  
           
        <uc1:header runat="server" ID="header" />
		<div id="wrap"></div>
        <uc2:footer runat="server" ID="footer" />
</body>
</html>
