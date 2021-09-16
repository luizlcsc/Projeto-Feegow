<!--#include file="connectCentral.asp"-->
<!DOCTYPE html>
<html lang="en">
<head>
    <link rel="shortcut icon" href="assets/img/favicon.png" type="image/x-icon" />
    <meta charset="utf-8" />
    <title>Feegow Clinic :: Teste gratuitamente o Feegow Clinic</title>

    <meta name="description" content="User login page" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <!-- basic styles -->

    <link href="assets/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="assets/css/font-awesome.min.css" />

    <!--[if IE 7]>
		  <link rel="stylesheet" href="assets/css/font-awesome-ie7.min.css" />
		<![endif]-->

    <!-- page specific plugin styles -->

    <!-- fonts -->

    <link rel="stylesheet" href="assets/css/ace-fonts.css" />

    <!-- ace styles -->

    <link rel="stylesheet" href="assets/css/ace.css" />
    <link rel="stylesheet" href="assets/css/ace-rtl.min.css" />

    <!--[if lte IE 8]>
		  <link rel="stylesheet" href="assets/css/ace-ie.min.css" />
		<![endif]-->

    <!-- inline styles related to this page -->

    <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->

    <!--[if lt IE 9]>
		<script src="assets/js/html5shiv.js"></script>
		<script src="assets/js/respond.min.js"></script>
		<![endif]-->
</head>

<body class="login-layout">
    <div class="main-container">
        <div class="main-content">
            <div class="row">
                <div class="col-sm-10 col-sm-offset-1">
                    <br>
                    <br>

                    <div class="login-container" style="width: 80%">


                        <div class="space-6"></div>

                        <div class="position-relative">
                            <div id="login-box" class="login-box visible widget-box no-border">
                                <div class="widget-body">
                                    <div class="widget-main">
                                        <div class="center" style="margin: 20px 0 30px 0;">
                                            <img src="assets/img/logo.png" border="0">
                                        </div>

                                        <div class="space-6"></div>
                                        <form id="trial" method="post" action="">
                                            <div class="row">
                                                <div class="col-md-6">
                                                    <h4 class="header blue lighter bigger">
                                                        <i class="far fa-stethoscope green"></i>
                                                        Teste agora o Feegow Clinic!
                                                    </h4>
                                                    <div class="row">
                                                        <div class="col-md-12">
                                                            <label>Nome completo</label><br>
                                                            <span class="block input-icon input-icon-right">
                                                                <input type="text" name="NomeContato" id="NomeContato" class="form-control" required autofocus>
                                                                <i class="far fa-user"></i>
                                                            </span>
                                                        </div>
                                                        <div class="col-md-12">
                                                            <div class="row">
                                                                <div class="col-md-6">
                                                                    <label>Telefones de contato</label><br>
                                                                    <span class="block input-icon input-icon-right">
                                                                        <input type="text" class="form-control input-mask-phone" name="Telefone" id="Telefone" placeholder="" />
                                                                        <i class="far fa-phone"></i>
                                                                    </span>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <label>&nbsp;</label><br>
                                                                    <span class="block input-icon input-icon-right">
                                                                        <input type="text" class="form-control input-mask-phone" name="Celular" required id="Celular" placeholder="" />
                                                                        <i class="far fa-mobile-phone"></i>
                                                                    </span>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <div class="col-md-12">
                                                            <label>E-mail</label><br>
                                                            <span class="block input-icon input-icon-right">
                                                                <input type="email" class="form-control" name="Email" placeholder="E-mail" required />
                                                                <i class="far fa-envelope"></i>
                                                            </span>
                                                        </div>
                                                        <div class="col-md-12">
                                                            <div class="row">
                                                                <div class="col-md-6">
                                                                    <label>Defina uma Senha</label>
                                                                    <span class="block input-icon input-icon-right">
                                                                        <input type="password" class="form-control" name="senha1" id="senha1" placeholder="Defina uma senha" required />
                                                                        <i class="far fa-lock"></i>
                                                                    </span>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <label>&nbsp;</label><br>
                                                                    <span class="block input-icon input-icon-right">
                                                                        <input type="password" class="form-control" name="senha2" id="senha2" placeholder="Confirme sua senha" required />
                                                                        <i class="far fa-lock"></i>
                                                                    </span>
                                                                </div>
                                                            </div>
                                                            <div class="row">
                                                                <div class="col-md-6">
                                                                    <label>Cupom desconto</label><br>
                                                                    <span class="block input-icon input-icon-right">
                                                                        <input type="text" class="form-control" name="Cupom" id="Cupom" value="<%=req("Cupom")%>" placeholder="Código do cupom, caso possua" />
                                                                        <i class="far fa-ticket"></i>
                                                                    </span>
                                                                </div>
                                                                <div class="col-md-6">
                                                                    <label>Como nos Conheceu?</label><br />
                                                                    <select name="ComoConheceu" class="form-control" required>
                                                                        <option value=""></option>
                                                                        <option value="Evento">Evento / Congresso</option>
                                                                        <option>Google</option>
                                                                        <option>Facebook</option>
                                                                        <option>Indicação</option>
                                                                    </select>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <!--div class="col-md-12">
                                                            	<label>Como conheceu o Feegow Clinic?</label><br>
                                                                <select name="ComoConheceu" class="form-control">
                                                                	<option value="">selecione</option>
                                                                    <option value="Google">Google</option>
                                                                    <option value="Facebook">Facebook</option>
                                                                    <option value="Indica&ccedil;&atilde;o">Indica&ccedil;&atilde;o</option>
                                                                    <option value="Baixaki">Baixaki</option>
                                                                    <option value="Impressos">Impressos</option>
                                                                </select>
                                                            </div-->
                                                    </div>
                                                    <div class="clearfix form-actions">
                                                        <button class="btn btn-primary btn-block" id="btnGenerate"><i class="far fa-ok"></i>INICIAR TESTE</button>
                                                    </div>
                                                </div>
                                                <div class="col-md-6">
                                                    <h4 class="header blue lighter bigger">
                                                        <i class="far fa-key green"></i>
                                                        J&aacute; &eacute; cadastrado?
                                                    </h4>
                                                    <a href="?P=Login" class="btn btn-success btn-block">IR PARA TELA DE LOGIN</a>
                                                    <div class="clearfix form-actions">
                                                        <h4>SUPORTE TÉCNICO</h4>
                                                        <hr>
                                                        <table class="table table-striped table-bordered">
                                                            <tbody>
                                                                <tr>
                                                                    <td valign="top" nowrap><span class="textotel"><strong>SP</strong> 11 3136.0479<br>

                                                                        <strong>RJ</strong> 21 2018.0123
                                                                        <br>
                                                                        <strong>PR</strong> 41 2626.1434 </span>
                                                                        <br>
                                                                        <br>
                                                                    </td>
                                                                    <td class="textotel" valign="top" nowrap>
                                                                        <strong>RS</strong> 51 2626.3019<br>
                                                                        <strong>BA</strong> 71 2626.0047 
                                                                    </td>
                                                                    <td valign="top" class="textotel" nowrap><strong>MG</strong> 31 2626.8010
                                                                        <br>
                                                                        <strong>DF</strong> 61 2626.1004<br>
                                                                    </td>
                                                                </tr>
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </div>
                                            </div>
                                        </form>
                                    </div>
                                    <!-- /widget-main -->

                                    <div class="toolbar clearfix">
                                        <div>
                                            <a href="http://www.feegowclinic.com.br" class="forgot-password-link">
                                                <i class="far fa-arrow-left"></i>
                                                Voltar para o website
                                            </a>
                                        </div>
                                    </div>
                                </div>
                                <!-- /widget-body -->
                            </div>
                            <!-- /login-box -->

                            <div id="forgot-box" class="forgot-box widget-box no-border">
                                <div class="widget-body">
                                    <div class="widget-main">
                                        <h4 class="header red lighter bigger">
                                            <i class="far fa-key"></i>
                                            Recuperar Senha
                                        </h4>

                                        <div class="space-6"></div>
                                        <p>
                                            Digite seu e-mail para receber as instruções
                                        </p>

                                        <form>
                                            <fieldset>
                                                <label class="block clearfix">
                                                    <span class="block input-icon input-icon-right">
                                                        <input type="email" class="form-control" placeholder="Email" />
                                                        <i class="far fa-envelope"></i>
                                                    </span>
                                                </label>

                                                <div class="clearfix">
                                                    <button type="button" class="width-35 pull-right btn btn-sm btn-danger">
                                                        <i class="far fa-lightbulb"></i>
                                                        Enviar!
                                                    </button>
                                                </div>
                                            </fieldset>
                                        </form>
                                    </div>
                                    <!-- /widget-main -->

                                    <div class="toolbar center">
                                        <a href="#" onclick="show_box('login-box'); return false;" class="back-to-login-link">Voltar para o login
												<i class="far fa-arrow-right"></i>
                                        </a>
                                    </div>
                                </div>
                                <!-- /widget-body -->
                            </div>
                            <!-- /forgot-box -->

                            <div id="signup-box" class="signup-box widget-box no-border">
                                <div class="widget-body">
                                    <div class="widget-main">
                                        <h4 class="header green lighter bigger">
                                            <i class="far fa-group blue"></i>
                                            New User Registration
                                        </h4>

                                        <div class="space-6"></div>
                                        <p>Enter your details to begin: </p>

                                        <form>
                                            <fieldset>
                                                <label class="block clearfix">
                                                    <span class="block input-icon input-icon-right">
                                                        <input type="email" class="form-control" placeholder="Email" />
                                                        <i class="far fa-envelope"></i>
                                                    </span>
                                                </label>

                                                <label class="block clearfix">
                                                    <span class="block input-icon input-icon-right">
                                                        <input type="text" class="form-control" placeholder="Username" />
                                                        <i class="far fa-user"></i>
                                                    </span>
                                                </label>

                                                <label class="block clearfix">
                                                    <span class="block input-icon input-icon-right">
                                                        <input type="password" class="form-control" placeholder="Password" />
                                                        <i class="far fa-lock"></i>
                                                    </span>
                                                </label>

                                                <label class="block clearfix">
                                                    <span class="block input-icon input-icon-right">
                                                        <input type="password" class="form-control" placeholder="Repeat password" />
                                                        <i class="far fa-retweet"></i>
                                                    </span>
                                                </label>

                                                <label class="block">
                                                    <input type="checkbox" class="ace" />
                                                    <span class="lbl">I accept the
															<a href="#">User Agreement</a>
                                                    </span>
                                                </label>

                                                <div class="space-24"></div>

                                                <div class="clearfix">
                                                    <button type="reset" class="width-30 pull-left btn btn-sm">
                                                        <i class="far fa-refresh"></i>
                                                        Reset
                                                    </button>

                                                    <button type="button" class="width-65 pull-right btn btn-sm btn-success">
                                                        Register
															<i class="far fa-arrow-right icon-on-right"></i>
                                                    </button>
                                                </div>
                                            </fieldset>
                                        </form>
                                    </div>

                                    <div class="toolbar center">
                                        <a href="#" onclick="show_box('login-box'); return false;" class="back-to-login-link">
                                            <i class="far fa-arrow-left"></i>
                                            Back to login
                                        </a>
                                    </div>
                                </div>
                                <!-- /widget-body -->
                            </div>
                            <!-- /signup-box -->
                        </div>
                        <!-- /position-relative -->
                    </div>
                </div>
                <!-- /.col -->
            </div>
            <!-- /.row -->
        </div>
    </div>
    <!-- /.main-container -->
    <input type="hidden" id="spinners">
    <!-- basic scripts -->

    <!--[if !IE]> -->
    <%
response.Write("		<script type=""text/javascript"">")
response.Write("			window.jQuery || document.write(""<script src='assets/js/jquery-2.0.3.min.js'>""+""<""+""/script>"");")
response.Write("		</script>")
    %>
    <!-- <![endif]-->

    <!--[if IE]>
<%
response.Write("<script type=""text/javascript"">")
response.Write(" window.jQuery || document.write(""<script src='assets/js/jquery-1.10.2.min.js'>""+""<""+""/script>"");")
response.Write("</script>")
%>
<![endif]-->
    <%
response.Write("		<script type=""text/javascript"">")
response.Write("			if(""ontouchend"" in document) document.write(""<script src='assets/js/jquery.mobile.custom.min.js'>""+""<""+""/script>"");")
response.Write("		</script>")
    %>
    <script src="assets/js/bootstrap.min.js"></script>
    <script src="assets/js/typeahead-bs2.min.js"></script>
    <script src="assets/js/jquery.maskMoney.js" type="text/javascript"></script>

    <!-- page specific plugin scripts -->
    <script src="assets/js/jquery-ui-1.10.3.custom.min.js"></script>
    <script src="assets/js/jquery.ui.touch-punch.min.js"></script>
    <script src="assets/js/jquery.gritter.min.js"></script>
    <script src="assets/js/jquery.slimscroll.min.js"></script>
    <script src="assets/js/jquery.hotkeys.min.js"></script>
    <script src="assets/js/bootstrap-wysiwyg.min.js"></script>
    <script src="assets/js/select2.min.js"></script>
    <script src="assets/js/jquery.easy-pie-chart.min.js"></script>
    <script src="assets/js/jquery.sparkline.min.js"></script>
    <script src="assets/js/flot/jquery.flot.min.js"></script>
    <script src="assets/js/flot/jquery.flot.pie.min.js"></script>
    <script src="assets/js/flot/jquery.flot.resize.min.js"></script>
    <!-- table scripts -->
    <script src="assets/js/jquery.dataTables.min.js"></script>
    <script src="assets/js/bootbox.min.js"></script>
    <script src="assets/js/jquery.dataTables.bootstrap.js"></script>


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
    <script type="text/javascript" src="assets/js/bootstrap-datetimepicker.min.js"></script>
    <script type="text/javascript" src="assets/js/bootstrap-datetimepicker.pt-BR.js"></script>

    <!-- ace scripts -->

    <script src="assets/js/ace-elements.min.js"></script>
    <script src="assets/js/ace.min.js"></script>

    <!-- inline scripts related to this page -->

    <script type="text/javascript">
        $("#trial").submit(function(){
            if($("#senha1").val()!=$("#senha2").val()){
                alert('As senhas digitadas são diferentes');
            }else{
                $("#btnGenerate").attr("disabled", "disabled");
                $.ajax({
                    type:"POST",
                    url:"generateTrial.asp",
                    data:$("#trial").serialize(),
                    success:function(data){
                        eval(data);
                    }
                })
            }
            return false;
        });



        function show_box(id) {
            jQuery('.widget-box.visible').removeClass('visible');
            jQuery('#'+id).addClass('visible');
        }
        $(".close").click(function(){
            jQuery('#divError').fadeOut(1000);
        });
        <!--#include file="jQueryFunctions.asp"-->
    </script>
</body>
</html>
