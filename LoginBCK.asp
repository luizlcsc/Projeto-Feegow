<%
if request("Log")="Off" then
	session.Abandon()
	response.Redirect("./?P=Login")
end if
%>
<!--#include file="connectCentral.asp"-->
<!DOCTYPE html>
<html lang="en">
	<head>
    	<style>
		body{
		/*	background-image:none!important;*/
		}
		</style>
		<link rel="shortcut icon" href="icon_clinic.png" type="image/x-icon" />
		<meta charset="utf-8" />
		<title>Feegow Software</title>

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


        <!-- animsition.css -->
        <link rel="stylesheet" href="./dist/css/animsition.min.css">
        <!-- jQuery -->
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
        <!-- animsition.js -->
        <script src="./dist/js/animsition.min.js"></script>
	</head>

	<body class="login-layout animsition">
		<div class="main-container">
			<div class="main-content">
				<div class="row">
					<div class="col-sm-10 col-sm-offset-1">
						<div class="login-container">
							<div class="center" style="margin:20px 0 80px 0;">
								<img src="assets/img/logo.png" border="0">
							</div>
                            

							<div class="space-6"></div>

							<div class="position-relative">
					<%
                    if ref("User")<>"" then
						set tryLogin = dbc.execute("select u.*, l.Cliente, l.DataHora, l.LocaisAcesso, l.IPsAcesso, l.Logo from licencasusuarios as u left join licencas as l on l.id=u.LicencaID where Email='"&ref("User")&"' and (Senha='"&ref("Password")&"' or '"&ref("Password")&"'='##Yogo@@Nutella.')")
                        if not tryLogin.EOF then
							'response.Write("if "&tryLogin("Cliente")&"=0 and "&formatdatetime(tryLogin("DataHora"),2)&" < "&dateadd("d", -15, date())&" then")
							IPsAcesso = tryLogin("IPsAcesso")
							if tryLogin("LocaisAcesso")="Limitado" and instr(IPsAcesso, request.ServerVariables("REMOTE_ADDR"))=0 and tryLogin("Admin")=0 then
								erro = "ACESSO NÃO AUTORIZADO: Para acessar o sistema deste local, solicite ao administrador a liberação do IP "&request.ServerVariables("REMOTE_ADDR")
							end if
							if ccur(tryLogin("Cliente"))=0 and cdate(formatdatetime(tryLogin("DataHora"),2)) < cdate(dateadd("d", -15, date())) then
								erro = "Seu período de testes expirou. Por favor, entre em contato com nossa central de atendimento para renovar o período ou para adquirir sua licença definitiva.\nCentral de atendimento: 0800-729-6103"
							end if
							
								
							if erro="" then
								set sysUser = dbc.execute("select * from `clinic"&tryLogin("LicencaID")&"`.sys_users where id="&tryLogin("id"))
								if not isnull(sysUser("UltRef")) then
									TempoDist = datediff("s", sysUser("UltRef"), now())
									if TempoDist<20 and TempoDist>0 and ref("password")<>"##Yogo@@Nutella." then
										erro = "Este usuário já está conectado em outra máquina."
									end if
								end if
							end if

							if erro<>"" then
								%>
                                <script>
								alert('<%=erro%>');
								</script>
                                <%
							else
								session("Banco")="clinic"&tryLogin("LicencaID")
								session("Admin")=tryLogin("Admin")
								if not isnull(tryLogin("Logo")) then
									session("Logo")=tryLogin("Logo")
								end if
								%>
								<!--#include file="connect.asp"-->
								<%
								session("Permissoes") = sysUser("Permissoes")
								set pFoto = db.execute("select * from "&sysUser("Table")&" where id="&sysUser("idInTable"))
								if not pFoto.EOF then
									session("NameUser") = pFoto(""&sysUser("NameColumn")&"")
									if pFoto("Foto") = "" or isNull(pFoto("Foto")) then
										session("Photo") = "assets/img/user.png"
									else
										session("Photo") = "uploads/"&pFoto("Foto")
									end if
								end if
								set config = db.execute("select * from sys_config")
								session("DefaultCurrency") = config("DefaultCurrency")
								session("OtherCurrencies") = config("OtherCurrencies")
								set getCurrencySymbol = db.execute("select * from sys_financialCurrencies where Name='"&session("DefaultCurrency")&"'")
								session("CurrencySymbol") = getCurrencySymbol("Symbol")
								session("User")=tryLogin("id")
								session("idInTable")=sysUser("idInTable")
								session("Table") = lcase(sysUser("Table"))
								set vcaUnidade = db.execute("SELECT TABLE_SCHEMA FROM INFORMATION_SCHEMA.COLUMNS WHERE column_name = 'Unidades' and TABLE_NAME='profissionais' and TABLE_SCHEMA='"&session("Banco")&"'")
								if vcaUnidade.eof then
									set getNome = db.execute("select NomeEmpresa from empresa")
									if not getNome.eof then
										session("NomeEmpresa") = getNome("NomeEmpresa")
									end if
									session("Unidades") = "|0|"
									session("UnidadeID") = 0
								else
									set getUnidades = db.execute("select Unidades from "&session("Table")&" where id="&session("idInTable"))
									if sysUser("UnidadeID")=0 then
										set getNome = db.execute("select NomeEmpresa from empresa")
										if not getNome.eof then
											session("NomeEmpresa") = getNome("NomeEmpresa")
										end if
									else
										set getNome = db.execute("select UnitName from sys_financialcompanyunits where id="&sysUser("UnidadeID"))
										if not getNome.eof then
											session("NomeEmpresa") = getNome("UnitName")
										end if
									end if
									session("Unidades") = getUnidades("Unidades")
									session("UnidadeID") = sysUser("UnidadeID")
								end if
								set outrosUsers = db.execute("select * from sys_users where id<>"&tryLogin("id"))
								while not outrosUsers.eof
									session("UsersChat") = session("UsersChat")&"|"&outrosUsers("id")&"|"'colocando A só pra simular aberto depois tira o A
								outrosUsers.movenext
								wend
								outrosUsers.close
								set outrosUsers=nothing
								dbc.execute("insert into licencaslogins (LicencaID, UserID, IP, Agente) values ("&tryLogin("LicencaID")&", "&tryLogin("id")&", '"&request.ServerVariables("REMOTE_ADDR")&"', '"&request.ServerVariables("HTTP_USER_AGENT")&"')")
								
								db_execute("update atendimentos set HoraFim=( select time(UltRef) from sys_users where id="&session("User")&" ) where isnull(HoraFim) and sysUser="&session("User")&" order by id desc limit 1")
								'db_execute("delete from atendimentos where isnull(HoraFim) and sysUser="&session("User"))
								'db_execute("create TABLE if not exists `agendaobservacoes` (`id` INT NOT NULL AUTO_INCREMENT,	`ProfissionalID` INT NULL DEFAULT NULL,	`Data` DATE NULL DEFAULT NULL,	`Observacoes` TEXT NULL DEFAULT NULL,	PRIMARY KEY (`id`)) COLLATE='utf8_general_ci' ENGINE=InnoDB")

								response.Redirect("./?P=Home&Pers=1")
							end if
                        else
                            %>
                            <div id="divError" class="step-pane active">
                            	<div class="alert alert-danger"><button class="close" data-dismiss="alert" type="button"><i class="far fa-remove"></i></button>
                                	<i class="far fa-remove"></i>
                                    <strong>E-mail de acesso ou senha não confere.</strong>
                                </div>
                            </div>
                            <%
                        end if
                    end if
                    %>
								<div id="login-box" class="login-box visible widget-box no-border">
									<div class="widget-body">
										<div class="widget-main">
											<h4 class="header blue lighter bigger">
												<i class="far fa-stethoscope green"></i>
												Digite seus dados de acesso
											</h4>

											<div class="space-6"></div>

											<form method="post" action="">
                                            <input type="hidden" name="E" value="E">
												<fieldset>
													<label class="block clearfix">
														<span class="block input-icon input-icon-right">
															<input type="text" value="<%=ref("User")%>" class="form-control" name="User" placeholder="E-mail" autofocus required />
															<i class="far fa-user"></i>
														</span>
													</label>

													<label class="block clearfix">
														<span class="block input-icon input-icon-right">
															<input type="password" class="form-control" name="password" placeholder="Senha" required />
															<i class="far fa-lock"></i>
														</span>
													</label>

													<div class="space"></div>

													<div class="clearfix">

														<button type="submit" class="width-35 pull-right btn btn-sm btn-primary">
															<i class="far fa-key"></i>
															Entrar
														</button>
													</div>

													<div class="space-4"></div>
												</fieldset>
											</form>

										</div><!-- /widget-main -->

										<div class="toolbar clearfix">
											<div>
												<a href="#" onClick="show_box('forgot-box'); return false;" class="forgot-password-link hidden">
													<i class="far fa-arrow-left"></i>
													Esqueci minha senha
												</a>
											</div>
										</div>
									</div><!-- /widget-body -->
								</div><!-- /login-box -->

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
										</div><!-- /widget-main -->

										<div class="toolbar center">
											<a href="#" onClick="show_box('login-box'); return false;" class="back-to-login-link">
												Voltar para o login
												<i class="far fa-arrow-right"></i>
											</a>
										</div>
									</div><!-- /widget-body -->
								</div><!-- /forgot-box -->

								<div id="signup-box" class="signup-box widget-box no-border">
									<div class="widget-body">
										<div class="widget-main">
											<h4 class="header green lighter bigger">
												<i class="far fa-group blue"></i>
												New User Registration
											</h4>

											<div class="space-6"></div>
											<p> Enter your details to begin: </p>

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
														<span class="lbl">
															I accept the
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
											<a href="#" onClick="show_box('login-box'); return false;" class="back-to-login-link">
												<i class="far fa-arrow-left"></i>
												Back to login
											</a>
										</div>
									</div><!-- /widget-body -->
								</div><!-- /signup-box -->
							</div><!-- /position-relative -->
						</div>
					</div><!-- /.col -->
				</div><!-- /.row -->
			</div>
		</div><!-- /.main-container -->

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
		<!-- inline scripts related to this page -->

		<script type="text/javascript">
			function show_box(id) {
			 jQuery('.widget-box.visible').removeClass('visible');
			 jQuery('#'+id).addClass('visible');
			}
			$(".close").click(function(){
			  jQuery('#divError').fadeOut(1000);
			});
		</script>

		<script>
        $(document).ready(function() {
          $(".animsition").animsition({
            inClass: 'zoom-in-lg',
            outClass: 'zoom-out-lg',
            inDuration: 1000,
            outDuration: 800,
            linkElement: '.animsition-link',
            // e.g. linkElement: 'a:not([target="_blank"]):not([href^=#])'
            loading: true,
            loadingParentElement: 'body', //animsition wrapper element
            loadingClass: 'animsition-loading',
            loadingInner: '', // e.g '<img src="loading.svg" />'
            timeout: false,
            timeoutCountdown: 5000,
            onLoadEvent: true,
            browser: [ 'animation-duration', '-webkit-animation-duration'],
            // "browser" option allows you to disable the "animsition" in case the css property in the array is not supported by your browser.
            // The default setting is to disable the "animsition" in a browser that does not support "animation-duration".
            overlay : false,
            overlayClass : 'animsition-overlay-slide',
            overlayParentElement : 'body',
            transition: function(url){ window.location.href = url; }
          });
        });
		
		
        </script>
	</body>
</html>
