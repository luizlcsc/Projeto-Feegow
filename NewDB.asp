<!--#include file="connect.asp"-->

	<div class="row">
		<div class="col-sm-10 col-sm-offset-1"><br><br>

			<div class="login-container" style="width:80%">
				

				<div class="space-6"></div>

				<div class="position-relative">
					<div id="login-box" class="login-box visible widget-box no-border">
						<div class="widget-body">
							<div class="widget-main">
				<div class="center" style="margin:20px 0 30px 0;">
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
															<label>Senha</label>
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
														<div class="col-md-12">
															<label>Cupom desconto</label><br>
															<span class="block input-icon input-icon-right">
																<input type="text" class="form-control" name="Cupom" id="Cupom" value="<%=req("Cupom")%>" placeholder="Digite o número do seu cupom" />
																<i class="far fa-ticket"></i>
															</span>
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
												<button class="btn btn-primary btn-block" id="btnGenerate"><i class="far fa-ok"></i> INICIAR TESTE</button>
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
														  <td valign="top" nowrap><span class="textotel"><strong>SP</strong> 11 4063.9947<br>
												
												<strong>RJ</strong> 21 4063.6039 <br>
												<strong>PR</strong> 41 4063.9951 </span><br><br></td>
														  <td class="textotel" valign="top" nowrap> 
												<strong>SC</strong> 48 4052.9967<br>
												<strong>RS</strong> 51 4063.9837<br>
												<strong>BA</strong> 71 4062.9931 
															</td>
														  <td valign="top" class="textotel" nowrap><strong>MG</strong> 31 4063.9918 <br>
												<strong>CE</strong> 85 4062.9930 <br>
															<strong>DF</strong> 61 4063.9917<br></td>
														  </tr>
													  </tbody></table>
											</div>
										</div>
									</div>
								</form>
							</div><!-- /widget-main -->

							<div class="toolbar clearfix">
								<div>
									<a href="http://www.feegowclinic.com.br" class="forgot-password-link">
										<i class="far fa-arrow-left"></i>
										Voltar para o website
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
