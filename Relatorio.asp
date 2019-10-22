<!--#include file="connect.asp"-->
<!DOCTYPE html>
<html lang="pt">
	<head>
    	<title>Relat&oacute;rio</title>
		<link rel="shortcut icon" href="icon_clinic.png" type="image/x-icon" />
		<link href="css/bootstrap.min.css" rel="stylesheet" />
		<!--[if IE 7]>
		  <link rel="stylesheet" href="assets/css/font-awesome-ie7.min.css" />
		<![endif]-->

        <link rel="stylesheet" type="text/css" href="assets/fonts/icomoon/icomoon.css">
        <link rel='stylesheet' type='text/css' href="../assets/css/font-awesome.min.css">
	    <script type="text/javascript" src="assets/js/jquery.min.js"></script>
		<script type="text/javascript" src="ckeditornew/ckeditor.js"></script>
        <script src="ckeditornew/adapters/jquery.js"></script>
        <script src="vendor/jquery/jquery-1.11.1.min.js"></script>
    </head>
    <body>
	<%
    server.Execute(req("TipoRel")&".asp")
    %>
	</body>
</html>