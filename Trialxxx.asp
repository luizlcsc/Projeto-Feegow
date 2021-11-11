<!--#include file="connectCentral.asp"-->
<!DOCTYPE html>
<html>

<head>
    <!-- Meta, title, CSS, favicons, etc. -->
    <meta charset="utf-8">
    <title>Feegow Clinic :: seja bem-vindo</title>
    <meta http-equiv="Content-Language" content="pt-br">
    <meta name="author" content="Feegow">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="robots" content="noindex">

    <!-- Font CSS (Via CDN) -->
    <link rel='stylesheet' type='text/css' href='https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700'>

    <link rel="stylesheet" href="https://pro.fontawesome.com/releases/v5.15.4/css/all.css" integrity="sha384-rqn26AG5Pj86AF4SO72RK5fyefcQ/x32DNQfChxWvbXIyXFePlEktwD18fEz+kQU" crossorigin="anonymous">
    <link rel="stylesheet" type="text/css" href="./assets/skin/default_skin/css/fgw.css?version=8.0.12.0">
    <!-- Theme CSS -->
     <script src="https://www.google.com/recaptcha/api.js" async defer></script>


    <link rel="stylesheet" type="text/css" href="assets/skin/default_skin/css/theme.css">
    <link rel="stylesheet" type="text/css" href="vendor/plugins/ladda/ladda.min.css">

    <!-- Admin Forms CSS -->
    <link rel="stylesheet" type="text/css" href="assets/admin-tools/admin-forms/css/admin-forms.css">

    <!-- Favicon -->
    <link rel="shortcut icon" href="assets/img/favicon.ico">

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
   <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
   <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
   <![endif]-->
   <style type="text/css">
       body.external-page #main{
               background: linear-gradient(
           52deg, #00b4fc, #17df93, #00b4fc, #17df93);
               background-size: 800% 800%;
               -webkit-animation: AnimationName 180s ease infinite;
               -moz-animation: AnimationName 190s ease infinite;
               animation: AnimationName 180s ease infinite;
           }
       }

        @font-face {
             font-family: rubidBold;
             src: url('assets/recurso-indisponivel/Fonte/Rubik-Bold.ttf');
        }
        @font-face {
             font-family: rubid;
             src: url('assets/recurso-indisponivel/Fonte/Rubik-Regular.ttf');
        }

       .top-text *{
           font-family: rubid;
       }

   </style>
</head>

<body class="external-page sb-l-c sb-r-c">

    <!-- Start: Main -->
    <div id="main" class="animated fadeIn">

        <!-- Start: Content-Wrapper -->
        <section id="content_wrapper">

            <!-- begin canvas animation bg -->
            <div id="canvas-wrapper">
                <canvas id="demo-canvas"></canvas>
            </div>

            <!-- Begin: Content -->
            <section id="content">

                <div class="admin-form theme-info" id="login1" style="margin-top: 0">

                    <div class="row mb15 table-layout">

                        <div class="col-xs-6 va-m pln">
                            <a href="./?P=Login" title="Logo">
                                <%
										if request.ServerVariables("HTTP_HOST")<>"livenote.feegow.com.br" then
											if req("Partner")="" then
                                %>
                                <img src="assets/img/logo_white.png" border="0">
                                <%
											else
                                %>
                                <img src="logo/<%=req("Partner")%>.png" border="0" width="250">
                                <%
											end if
										Else %>
                                <img src="assets/img/180_width.png" width="138" border="0">&nbsp;&nbsp;&nbsp;
                                            <img style="margin-bottom: -7px" src="logo/livenote.png" width="130" border="0">
                                <% End If %>
                            </a>
                        </div>

                        <div class="col-xs-6 text-right va-b pr5">
                            <div class="login-links">
                                <a href="./?P=Login" class="active" title="Entrar">Entrar</a>
                            </div>
                        </div>
                    </div>

                    <div class="panel panel-info br-n">
                        <div class="panel-heading p10 heading-border  top-text">

                            <div style="margin: 30px 50px">
                                <div>
                                    <span style="color: #00b4fc;font-size: 42px; font-family: rubidBold">Versão FREE</span>&nbsp;
                                    <span style="color: #CCCCCC;font-size: 22px; font-family: rubidBold">Software Feegow clinic</span>
                                </div>
                                <div>
                                    <strong style="color: #666666;font-size: 22px; font-family: rubidBold">Olá! ;)</strong>

                                </div>
                                <div style="line-height: initial; text-align: justify; font-size: 14px;color: #666666">
                                    Você está prestes a ter acesso a versão <strong> free </strong> do software de gestão clínica mais amigável e completo do mercado.
                                    <br/><br/>
                                    Durante os primeiros 7 dias você terá disponível a versão na íntegra e poderá solicitar uma apresentação do nosso time.
                                    Quando o prazo do trial expirar, você terá somente o acesso à versão que permite o uso da agenda diária e semanal,
                                    além de utilização do prontuário, onde é posssível incluir anamneses e evoluções do paciente.

                                    <br/><br/>
                                    <strong>Insira os seus melhores canais de contato,</strong> pois a licença será ativada pelo telefone, ok?
                                    <br/><br/>
                                    Entendemos que para um melhor aproveitamento da fase de teste, a apresentação é necessária.
                                    <br/><br/>
                                    <span style="color:#00b4fc;font-size: 18px; font-family: 'Arial Black'"><strong>Está pronto para ter a melhor experiência em software clínico?</strong></span>
                                </div>
                            </div>

<!--                            <span class="text-primary"><i class="far fa-stethoscope"></i>-->
<!--                                                        Teste agora o Feegow Clinic!</span>-->
                        </div>
                        <form method="post" autocomplete="off" id="trial" action="">
                            <div class="panel-body bg-light p30">
                                <% IF req("T") = "FULL" THEN %>
                                    <input type="hidden" name="Teste" value="FULL">
                                <% ELSE %>
                                    <input type="hidden" name="Teste" value="FREE">
                                <% END IF %>
                                <div class="row">
                                                <div class="col-md-12">
                                                    <div style="color:red" id="alert_submit">

													</div>

                                                    <div class="row mt10">

                                                        <div class="col-md-12">
                                                            <label for="NomeContato" class="field prepend-icon">
                                                              <input type="text" name="NomeContato" id="NomeContato" class="gui-input" placeholder="Nome completo..." required autofocus>
                                                              <label for="NomeContato" class="field-icon">
                                                                <i class="far fa-user"></i>
                                                              </label>
                                                            </label>
                                                        </div>
                                                    </div>
                                                    <div class="row mt20">
                                                        <div class="col-md-6">
                                                            <label for="Telefone" class="field prepend-icon">
                                                                <input type="text" name="Telefone" id="Telefone" class="gui-input input-mask-phone" placeholder="Telefone...">
                                                                <label for="Telefone" class="field-icon">
                                                                <i class="far fa-phone"></i>
                                                                </label>
                                                            </label>
                                                        </div>
                                                        <div class="col-md-6">
                                                            <label for="Celular" class="field prepend-icon">
                                                                <input type="text" name="Celular" id="Celular" class="gui-input input-mask-phone" placeholder="Celular..." required>
                                                                <label for="Celular" class="field-icon">
                                                                <i class="far fa-mobile-phone"></i>
                                                                </label>
                                                            </label>
                                                        </div>
                                                    </div>
                                                    <div class="row mt20">
                                                        <div class="col-md-12">
                                                                    <label for="Email" class="field prepend-icon">
                                                                      <input type="text" name="Email" id="Email" class="gui-input" placeholder="E-mail..." required>
                                                                      <label for="Email" class="field-icon">
                                                                        <i class="far fa-envelope"></i>
                                                                      </label>
                                                                    </label>
                                                        </div>
                                                    </div>

                                                    <div class="row mt20">
                                                        <div class="col-md-6">
                                                            <label for="Cupom" class="field prepend-icon">
                                                                <input type="text" name="Cupom" id="Cupom" class="gui-input" placeholder="Cupom desconto, caso possua..." value="<%=req("Cupom")%>">
                                                                <label for="Cupom" class="field-icon">
                                                                <i class="far fa-ticket"></i>
                                                                </label>
                                                            </label>

                                                        </div>
                                                        <div class="col-md-6">
                                                            <select name="ComoConheceu" class="gui-input" required>
                                                                <option value="">Como nos Conheceu?</option>
                                                                <option>Hospitalar</option>
                                                                <option value="Evento">Evento / Congresso</option>
                                                                <option>Google</option>
                                                                <option>Facebook</option>
                                                                <option>Instagram</option>
                                                                <option>Indicação</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div class="row mt20">
                                                        <div class="col-md-6">
                                                            <label for="NomeEmpresa" class="field prepend-icon">
                                                                <input type="text" required name="NomeEmpresa" id="NomeEmpresa" class="gui-input" placeholder="Nome da Clínica" >
                                                                <label for="NomeEmpresa" class="field-icon">
                                                                <i class="far fa-hospital-o"></i>
                                                                </label>
                                                            </label>
                                                        </div>
                                                        <div class="col-md-6">
                                                            <label for="UsuariosPretendidos" class="field prepend-icon">
                                                                <input type="text" required name="UsuariosPretendidos" id="UsuariosPretendidos" class="gui-input" placeholder="Quantidade de Profissionais da Clínica" >
                                                                <label for="UsuariosPretendidos" class="field-icon">
                                                                <i class="far fa-group"></i>
                                                                </label>
                                                            </label>
                                                        </div>
                                                    </div>
                                                    <div class="row mt20">
                                                        <div class="col-md-6">
                                                            <label for="Cargo" class="field prepend-icon">
                                                                <input type="text" required name="Cargo" id="Cargo" class="gui-input" placeholder="Cargo" >
                                                                <label for="Cargo" class="field-icon">
                                                                <i class="far fa-suitcase"></i>
                                                                </label>
                                                            </label>
                                                        </div>
                                                        <div class="col-md-6">
                                                            <label for="CRMResponsavel" class="field prepend-icon">
                                                                <input type="text" name="CRMResponsavel" id="CRMResponsavel" class="gui-input" placeholder="CRM do Responsavel" >
                                                                <label for="CRMResponsavel" class="field-icon">
                                                                <i class="far fa-user-md"></i>
                                                                </label>
                                                            </label>
                                                        </div>
                                                    </div>
                                                    <div class="row mt20">
                                                        <div class="col-md-6">
                                                            <label for="senha1" class="field prepend-icon">
                                                                <input type="password" name="senha1" id="senha1" class="gui-input" placeholder="Defina uma Senha..." required>
                                                                <label for="senha1" class="field-icon">
                                                                <i class="far fa-lock"></i>
                                                                </label>
                                                            </label>


                                                        </div>
                                                        <div class="col-md-6">
                                                            <label for="senha2" class="field prepend-icon">
                                                                <input type="password" name="senha2" id="senha2" class="gui-input" placeholder="Confirme sua senha..." required>
                                                                <label for="senha2" class="field-icon">
                                                                <i class="far fa-lock"></i>
                                                                </label>
                                                            </label>
                                                        </div>
                                                        <div class="col-md-12">
                                                            <br>
                                                            <div data-callback="recaptchaSuccess" class="g-recaptcha" data-sitekey="6LcYU94cAAAAAE-wjHMKmWdjz5-JlEukwcyVqzj4"></div>
                                                        </div>

                                                    </div>
                                                </div>

                                                <div class="col-md-4" style="display: none" >

                                                    <div class="row col-md-12">



                                                        <h4 class="mt20"> SUPORTE TÉCNICO </h4>
                                                        <hr class="mv15 br-light" />
                                                        <ul class="list-group">
                                                            <li class="list-group-item">
                                                                <span class="badge badge-success">SP</span>
                                                                11 3136.0479
                                                            </li>
                                                            <li class="list-group-item">
                                                                <span class="badge badge-success">RJ</span>
                                                                21 2018.0123
                                                            </li>
                                                            <li class="list-group-item">
                                                                <span class="badge badge-success">PR</span>
                                                                41 2626.1434
                                                            </li>
                                                            <li class="list-group-item">
                                                                <span class="badge badge-success">RS</span>
                                                                51 2626.3019
                                                            </li>

                                                            <li class="list-group-item">
                                                                <span class="badge badge-success">BA</span>
                                                                71 2626.0047
                                                            </li>
                                                            <li class="list-group-item">
                                                                <span class="badge badge-success">MG</span>
                                                                31 2626.8010
                                                            </li>
                                                            <li class="list-group-item">
                                                                <span class="badge badge-success">DF</span>
                                                                61 2626.1004
                                                            </li>

                                                        </ul>
                                                    </div>
                                                </div>
                                            </div>
                            </div>
                            <!-- end .form-body section -->
                            <div class="panel-footer clearfix p10 ph15" >
                                    <button class="btn btn-primary" style="float: right" id="btnGenerate"><i class="far fa-ok"></i>INICIAR TESTE</button>
                            </div>
                            <!-- end .form-footer section -->
                        </form>
						<form method="post" action="./?P=Login" id="form_fake" style="display:none">
							<input type="password" name="password" id="fake_password" class="gui-input" placeholder="Senha" required="">
							<input type="email" name="User" id="fake_User" class="gui-input" placeholder="Digite seu e-mail de acesso" autofocus="" required="">
						</form>
                    </div>
                </div>

            </section>
            <!-- End: Content -->

        </section>
        <!-- End: Content-Wrapper -->

    </div>
    <!-- End: Main -->

    <!-- BEGIN: PAGE SCRIPTS -->

    <!-- jQuery -->
    <script src="vendor/jquery/jquery-1.11.1.min.js"></script>
    <script src="vendor/jquery/jquery_ui/jquery-ui.min.js"></script>

    <!-- CanvasBG Plugin(creates mousehover effect) -->
    <!--<script src="vendor/plugins/canvasbg/canvasbg.js"></script>-->

    <!-- Theme Javascript -->
    <script src="assets/js/utility/utility.js"></script>
    <script src="assets/js/main.js"></script>
    <script src="vendor/plugins/ladda/ladda.min.js"></script>
  <script src="vendor/plugins/select2/select2.min.js"></script>
  <script src="js/components.js?a=2"></script>
  <script src="vendor/plugins/select2/select2.full.min.js"></script>
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
        <script src="assets/js/tracking-min.js"></script>
        <script src="assets/js/face-min.js"></script>
    	<script type="text/javascript" src="assets/js/qtip/jquery.qtip.js"></script>
		<script src="assets/js/typeahead-bs2.min.js"></script>
		<script src="assets/js/jquery.maskMoney.js" type="text/javascript"></script>
		<script src="assets/js/ace-elements.min.js"></script>
		<script src="assets/js/ace.min.js"></script>

    <!-- Page Javascript -->
    <script type="text/javascript">
        jQuery(document).ready(function () {

            "use strict";

            // Init Theme Core
            Core.init();

            // Init Demo JS
            // //Demo.init();
            //
            // // Init CanvasBG and pass target starting location
            // CanvasBG.init({
            //     Loc: {
            //         x: window.innerWidth / 2,
            //         y: window.innerHeight / 3.3
            //     },
            // });
            //
            // // Init Ladda Plugin on buttons
            // Ladda.bind('.ladda-button', {
            //     timeout: 8000
            // });

            // Bind progress buttons and simulate loading progress. Note: Button still requires ".ladda-button" class.
            Ladda.bind('.progress-button', {
                callback: function (instance) {
                    var progress = 0;
                    var interval = setInterval(function () {
                        progress = Math.min(progress + Math.random() * 0.1, 1);
                        instance.setProgress(progress);

                        if (progress === 1) {
                            instance.stop();
                            clearInterval(interval);
                        }
                    }, 200);
                }
            });
        });
    </script>

    <!-- END: PAGE SCRIPTS -->

    <script type="text/javascript">
        var captchaToken = null;

        function recaptchaSuccess(token){
            captchaToken = token;
        }

        $("#trial").submit(function(){
            if(!captchaToken){
                alert("Preencha a verificação Captcha.");
            }

            if($("#senha1").val()!=$("#senha2").val()){
                alert('As senhas digitadas são diferentes');
            }else{
                $("#btnGenerate").attr("disabled", "disabled");
                $.ajax({
                    type:"POST",
                    url:"https://api.feegow.com.br/trial/start?captcha="+captchaToken,
                    data:$("#trial").serialize(),
                    success:function(data){
						document.getElementById("fake_password").value = $("#senha1").val();
						document.getElementById("fake_User").value = $("#Email").val();
						document.getElementById("form_fake").submit();
                    },
					error:function (xhr, ajaxOptions, thrownError){
						switch (xhr.status) {
							case 422:
   			                    $("#btnGenerate").removeAttr("disabled");
								$("#alert_submit").html(xhr.responseJSON.error)
						}
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
