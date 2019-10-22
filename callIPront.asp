<style type="text/css">
    body {
        background-color:#fff!important;
    }
#folha{
		font-family: Arial, sans-serif;
		list-style-type: none;
		margin: 0px;
		padding: 0px;
		width: 760px;
		height:1200px;
		background-color:#FFFFFF;
		border:1px solid #fff;
		position:relative;
}
.campos{
		position:absolute;
		margin: 0;
		border: 2px dotted #fff;
		text-align: center;
		padding: 10px;
		background-color: #fff;
		text-align:left;
		min-height:80px!important;
}
.lembrar{
	position:absolute;
	right:0;
	display:none!important;
}
.campos:hover .lembrar{
	display:block;
}
.campo:hover .lembrar{
	display:block;
}
.gridster .gs-w {
    cursor:default!important;
}
.btn-spee {
    display:none!important;
}
@media print{
    .panel-controls{
        display: none;
    }
    #timeline.timeline-single .timeline-icon{
        background-color: #EEEEEE;
        border-radius: 50%;
        height: 35px;
        width: 35px;
        z-index: 99;
    }
}
.btn-primary.disabled{
    pointer-events:auto;
}
</style>


  <link rel="stylesheet" type="text/css" href="assets/fonts/icomoon/icomoon.css">
  <link rel="stylesheet" type="text/css" href="vendor/plugins/magnific/magnific-popup.css">
  <link rel="stylesheet" type="text/css" href="vendor/plugins/footable/css/footable.core.min.css">
  
  <link rel="stylesheet" href="assets/css/datepicker.css" />
  <link rel="stylesheet" type="text/css" href="vendor/plugins/fullcalendar/fullcalendar.min.css">
  <link rel="stylesheet" type="text/css" href="assets/skin/default_skin/css/fgw.css">
  <link rel="stylesheet" type="text/css" href="assets/admin-tools/admin-forms/css/admin-forms.css">
  <link rel="shortcut icon" href="assets/img/feegowclinic.ico" type="image/x-icon" />
  <link href="vendor/plugins/select2/css/core.css" rel="stylesheet" type="text/css"> 
  <link href="vendor/plugins/select2/select2-bootstrap.css" rel="stylesheet" type="text/css"> 
  <link rel="stylesheet" href="assets/css/old.css" />
  <link rel="stylesheet" type="text/css" href="vendor/plugins/ladda/ladda.min.css">

  <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
  <!--[if lt IE 9]>
  <script src="assets/js/html5shiv.js"></script>
  <script src="assets/js/respond.min.js"></script>
<![endif]-->
  <script src="vendor/jquery/jquery-1.11.1.min.js"></script>
  <script src="vendor/jquery/jquery_ui/jquery-ui.min.js"></script>
  <script src="vendor/plugins/select2/select2.min.js"></script>
  <script src="js/components.js"></script>
  <script src="vendor/plugins/select2/select2.full.min.js"></script>
  <script type="text/javascript" src="ckeditornew/ckeditor.js"></script>
  <script src="ckeditornew/adapters/jquery.js"></script>
  <script src="vendor/plugins/footable/js/footable.all.min.js"></script>
    <link rel="stylesheet" type="text/css" href="site/jquery.gridster.css">
    <link rel="stylesheet" type="text/css" href="site/demo.css">
    <link rel="stylesheet" type="text/css" href="buiforms.css">
    <script src="site/jquery.gridster.js" type="text/javascript" charset="utf-8"></script>
    
<% server.execute("ipront.asp") %>



    <script src="vendor/plugins/dropzone/dropzone.min.js"></script>
    <script src="assets/js/jquery.colorbox-min.js"></script>
    <script type="text/javascript" src="js/editor.js"></script>
    <script src="vendor/plugins/mixitup/jquery.mixitup.min.js"></script>
    <script src="vendor/plugins/fileupload/fileupload.js"></script>
    <script src="vendor/plugins/holder/holder.min.js"></script>
    
  <!-- HighCharts Plugin -->
  <script src="vendor/plugins/highcharts/highcharts.js"></script>

  <!-- FullCalendar Plugin + moment Dependency -->
  <script src="vendor/plugins/fullcalendar/lib/moment.min.js"></script>
  <script src="vendor/plugins/fullcalendar/fullcalendar.min.js"></script>

  <!-- jQuery Validate Plugin-->
  <script src="assets/admin-tools/admin-forms/js/jquery.validate.min.js"></script>

  <!-- jQuery Validate Addon -->
  <script src="assets/admin-tools/admin-forms/js/additional-methods.min.js"></script>

  <!-- Theme Javascript -->
  <script src="assets/js/utility/utility.js"></script>
  <script src="assets/js/demo/demo.js"></script>
  <script src="assets/js/main.js"></script>
  <script src="assets/admin-tools/admin-forms/js/jquery.spectrum.min.js"></script>

  <!-- Widget Javascript -->
  <script src="assets/js/demo/widgets.js"></script>

  <script src="vendor/plugins/pnotify/pnotify.js"></script>
  <script src="vendor/plugins/ladda/ladda.min.js"></script>
  <script src="vendor/plugins/magnific/jquery.magnific-popup.js"></script>

    <!-- old sms -->
    	<script type="text/javascript" src="assets/js/qtip/jquery.qtip.js"></script>
		<script src="assets/js/typeahead-bs2.min.js"></script>
		<script src="assets/js/jquery.maskMoney.js" type="text/javascript"></script>

		<!-- page specific plugin scripts -->
		<script src="assets/js/jquery-ui-1.10.3.custom.min.js"></script>
		<script src="assets/js/jquery.ui.touch-punch.min.js"></script>
		<script src="assets/js/jquery.gritter.min.js"></script>
        <script src="assets/js/jquery.slimscroll.min.js"></script>
		<script src="assets/js/jquery.hotkeys.min.js"></script>
		<script src="assets/js/bootstrap-wysiwyg.min.js"></script>
        <script src="assets/js/jquery.easy-pie-chart.min.js"></script>
		<script src="assets/js/jquery.sparkline.min.js"></script>
		<script src="assets/js/flot/jquery.flot.min.js"></script>
		<script src="assets/js/flot/jquery.flot.pie.min.js"></script>
			<!-- table scripts -->
		<script src="assets/js/jquery.dataTables.min.js"></script>


		<!--[if lte IE 8]>
		  <script src="assets/js/excanvas.min.js"></script>
		<![endif]-->

		<script src="assets/js/chosen.jquery.min.js"></script>
		<script src="assets/js/fuelux/fuelux.spinner.min.js"></script>
		<script src="assets/js/date-time/bootstrap-datepicker.min.js"></script>
		<script src="assets/js/date-time/bootstrap-timepicker.min.js"></script>
		<script src="assets/js/date-time/moment.min.js"></script>
		<script src="assets/js/date-time/daterangepicker.min.js"></script>
		<script src="assets/js/bootstrap-colorpicker.min.js"></script>
		<script src="assets/js/jquery.knob.min.js"></script>
		<script src="assets/js/jquery.autosize.min.js"></script>
		<script src="assets/js/jquery.inputlimiter.1.3.1.min.js"></script>
		<script src="assets/js/jquery.maskedinput.min.js"></script>
		<script src="assets/js/bootstrap-tag.min.js"></script>
		<script src="assets/js/x-editable/bootstrap-editable.min.js"></script>
		<script src="assets/js/x-editable/ace-editable.min.js"></script>

		<!-- ace scripts -->

		<script src="assets/js/ace-elements.min.js"></script>
		<script src="assets/js/ace.min.js"></script><script type="text/javascript">
    //parent.$("#ifr<%= request.querystring("i") %>").css("height",  $("#demo-0").css("height") );
</script>