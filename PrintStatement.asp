<!--#include file="functions.asp"-->

<!DOCTYPE html>
<html lang="en">
	<head>
		<link type="text/css" rel="stylesheet" href="assets/js/qtip/jquery.qtip.css" />
		<link rel="shortcut icon" href="icon_clinic.png" type="image/x-icon" />
		<meta charset="utf-8" />
		<title>Feegow Software :: <%=session("NameUser")%></title>

		<meta name="description" content="" />
		<meta name="viewport" content="width=device-width, initial-scale=1.0" />

  <link rel="stylesheet" href="https://pro.fontawesome.com/releases/v5.15.4/css/all.css" integrity="sha384-rqn26AG5Pj86AF4SO72RK5fyefcQ/x32DNQfChxWvbXIyXFePlEktwD18fEz+kQU" crossorigin="anonymous">
  <link rel="stylesheet" type="text/css" href="assets/fonts/icomoon/icomoon.css">
  <link rel="stylesheet" type="text/css" href="vendor/plugins/magnific/magnific-popup.css">
  <link rel="stylesheet" type="text/css" href="vendor/plugins/footable/css/footable.core.min.css">
  <link rel='stylesheet' type='text/css' href='assets/css/css.css'>
  <link rel="stylesheet" type="text/css" href="vendor/plugins/fullcalendar/fullcalendar.min.css">
  <link rel="stylesheet" type="text/css" href="assets/skin/default_skin/css/theme.css">
  <link rel="stylesheet" type="text/css" href="assets/admin-tools/admin-forms/css/admin-forms.css">
  <link rel="shortcut icon" href="assets/img/feegowclinic.ico" type="image/x-icon" />
  <link href="vendor/plugins/select2/css/core.css" rel="stylesheet" type="text/css"> 
  <link href="vendor/plugins/select2/select2-bootstrap.css" rel="stylesheet" type="text/css"> 
  <link rel="stylesheet" href="assets/css/old.css" />
  <link rel="stylesheet" type="text/css" href="vendor/plugins/ladda/ladda.min.css">
        <!-- fonts -->


		<!-- ace styles -->

		<!--[if lte IE 8]>
		  <link rel="stylesheet" href="assets/css/ace-ie.min.css" />
		<![endif]-->

		<!-- inline styles related to this page -->
		<style type="text/css">
            body{
                background-color:#fff!important;
            }
			</style>
            <!-- ace settings handler -->

  <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
  <!--[if lt IE 9]>
  <script src="assets/js/html5shiv.js"></script>
  <script src="assets/js/respond.min.js"></script>
<![endif]-->
  <script src="vendor/jquery/jquery-1.11.1.min.js"></script>
  <script src="vendor/jquery/jquery_ui/jquery-ui.min.js"></script>
  <script src="vendor/plugins/select2/select2.min.js"></script> 
  <script src="assets/js/bootstrap.min.js"></script>
  <script src="vendor/plugins/select2/select2.full.min.js"></script>
  <script type="text/javascript" src="ckeditornew/ckeditor.js"></script>
  <script src="ckeditors/adapters/jquery.js"></script>
  <script src="vendor/plugins/footable/js/footable.all.min.js"></script>
  <script src="js/components.js"></script>
<style type="text/css">
   a[href]:after {
     content: ""!important;
   }

</style>
	</head>
    <body style="overflow-x:scroll">
    	<div class="container-fluid">
            <div style="position:fixed; top:10px; right:10px;z-index: 9">
                <button type="button" onclick="downloadExcel()" class="btn btn-success hidden-print"><i class="far fa-file-excel-o"></i></button>
                <button type="button" onclick="print()" class="btn btn-info hidden-print"><i class="far fa-print"></i></button>
            </div>
	    	<% 
           reqdebug = req("debug")
           if reqdebug = "1" then
              reqdebug = "?debug=1"
            else   
              reqdebug = ""
           end if 
           if req("R")<> "" then 
              server.Execute(req("R")&".asp"&reqdebug) 
           else 
              server.Execute(ref("R")&".asp"&reqdebug)  
           end if
        %>
        </div>
<form id="formExcel" method="POST">
    <input type="hidden" name="html" id="htmlTable">
</form>
    </body>


			<!-- table scripts -->
		<script src="assets/js/jquery.dataTablesRel.min.js"></script>
		<script src="assets/js/bootbox.min.js"></script>

<script >
function downloadExcel(){
    $("#htmlTable").val($("body").html());
    var tk = localStorage.getItem("tk");
    $("#formExcel").attr("action", domain+"reports/download-excel?title=Relatório&tk="+tk).submit();
}

</script>

<script src="js/highcharts.js"></script>
<script src="js/exporting.js"></script>
</html>