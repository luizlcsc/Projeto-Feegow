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
  		<link rel="stylesheet" href="https://pro.fontawesome.com/releases/v5.15.4/css/all.css" integrity="sha384-rqn26AG5Pj86AF4SO72RK5fyefcQ/x32DNQfChxWvbXIyXFePlEktwD18fEz+kQU" crossorigin="anonymous">
	    <script type="text/javascript" src="assets/js/jquery.min.js"></script>
		<script type="text/javascript" src="ckeditornew/ckeditor.js"></script>
        <script src="ckeditornew/adapters/jquery.js"></script>
        <script src="https://cdn.feegow.com/feegowclinic-v7/vendor/jquery/jquery-1.12.4.min.js"></script>
    </head>
    <body>
	<%
    server.Execute(req("TipoRel")&".asp")
    %>
	</body>
</html>