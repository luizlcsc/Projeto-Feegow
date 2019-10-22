<%
                        if not tryLogin.EOF then
							'response.Write("if "&tryLogin("Cliente")&"=0 and "&formatdatetime(tryLogin("DataHora"),2)&" < "&dateadd("d", -15, date())&" then")
							IPsAcesso = tryLogin("IPsAcesso")
							if tryLogin("LocaisAcesso")="Limitado" and instr(IPsAcesso, request.ServerVariables("REMOTE_ADDR"))=0 and tryLogin("Admin")=0 then
								erro = "ACESSO NÃO AUTORIZADO: Para acessar o sistema deste local, solicite ao administrador a liberação do IP "&request.ServerVariables("REMOTE_ADDR")
							end if
							if not isnull(tryLogin("FimTeste")) then
								if cdate(formatdatetime(tryLogin("FimTeste"),2))<cdate(date()) and tryLogin("Status")<>"C" and tryLogin("Status")<>"B" then
									session("Bloqueado")="FimTeste"
								'	erro = "Seu período de testes expirou. Por favor, entre em contato com nossa central de atendimento para renovar o período ou para adquirir sua licença definitiva.\nCentral de atendimento: 0800-729-6103"
								elseif tryLogin("Status")="T" then
									session("DiasTeste") = datediff("d", date(), formatdatetime(tryLogin("FimTeste"), 2))
								end if
							end if
							if tryLogin("Status")="B" then
								erro = "ACESSO NÃO AUTORIZADO: Por favor, entre em contato conosco."
							end if
							
								
							if erro="" then
								set sysUser = dbc.execute("select * from `clinic"&tryLogin("LicencaID")&"`.sys_users where id="&tryLogin("id"))
								if not isnull(sysUser("UltRef")) and isdate(sysUser("UltRef")) then
									TempoDist = datediff("s", sysUser("UltRef"), now())
									if TempoDist<20 and TempoDist>0 and ref("password")<>"##Yogo@@Nutella." and device()="" then
										erro = "Este usuário já está conectado em outra máquina."
									end if
								end if
                                set vcAtivo = dbc.execute("select * from `clinic"&tryLogin("LicencaID")&"`.`"&sysUser("Table")&"` where id="&sysUser("idInTable")&" and Ativo='on'")
                                if vcAtivo.eof then
                                    erro = "Usuário encontra-se inativo."
                                end if
								if device()<>"" then
									set valter = dbc.execute("select i.COLUMN_NAME from information_schema.`COLUMNS` i where i.TABLE_SCHEMA='clinic"&tryLogin("LicencaID")&"' and i.TABLE_NAME='sys_users' and i.COLUMN_NAME='UltRefDevice'")
									if valter.EOF then
										dbc.execute("ALTER TABLE `clinic"&tryLogin("LicencaID")&"`.`sys_users` ADD COLUMN `UltRefDevice` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP AFTER `UltRef`, ADD COLUMN `UltPac` INT NULL DEFAULT NULL AFTER `UltRefDevice`")
										set sysUser = dbc.execute("select * from `clinic"&tryLogin("LicencaID")&"`.sys_users where id="&tryLogin("id"))
									else
										TempoDistDevice = datediff("s", sysUser("UltRefDevice"), now())
										if TempoDistDevice<20 and TempoDistDevice>0 and ref("password")<>"##Yogo@@Nutella." then
											erro = "Este usuário já está conectado em outro aparelho."
										end if
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
								session("Status")=tryLogin("Status")
								%>
								<!--#include file="connect.asp"-->
								<%
                                    if ref("Lembrarme")="S" then
                                        response.Cookies("User") = ref("User")
                                        Response.Cookies("User").Expires = Date() + 365
                                    else
                                        response.Cookies("User") = ""
                                    end if

								session("Permissoes") = sysUser("Permissoes")
								if left(session("Permissoes"), 1)<>"|" then
									db_execute("update sys_users set Permissoes=concat('|', replace(Permissoes, ', ', '|, |'), '|' ) where Permissoes not like '|%'")
									db_execute("update regraspermissoes set Permissoes=concat('|', replace(Permissoes, ', ', '|, |'), '|' ) where Permissoes not like '|%'")
									session("Permissoes") = "|"&replace(session("Permissoes"), ", ", "|, |")&"|"
								end if
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
								session("OtherCurrencies") = config("OtherCurrencies")
								session("User")=tryLogin("id")
								session("idInTable")=sysUser("idInTable")
								session("Table") = lcase(sysUser("Table"))


								set getUnidades = db.execute("select Unidades from "&session("Table")&" where id="&session("idInTable"))
								session("Unidades") = getUnidades("Unidades")
								session("UnidadeID") = sysUser("UnidadeID")


								if session("Table")="profissionais" then
									set gradeHoje = db.execute("select l.UnidadeID from assfixalocalxprofissional g LEFT JOIN locais l on l.id=g.LocalID where g.ProfissionalID="&session("idInTable")&" and g.DiaSemana="&weekday(date()))
									if not gradeHoje.EOF then
										if not isnull(gradeHoje("UnidadeID")) then
											session("UnidadeID") = gradeHoje("UnidadeID")
											db_execute("update sys_users set UnidadeID="&gradeHoje("UnidadeID")&" where id="&session("User"))
										end if
									end if
								end if
								if session("UnidadeID")=0 then
									set getNome = db.execute("select NomeEmpresa from empresa")
									if not getNome.eof then
										session("NomeEmpresa") = getNome("NomeEmpresa")
									end if
								else
									set getNome = db.execute("select UnitName from sys_financialcompanyunits where id="&session("UnidadeID"))
									if not getNome.eof then
										session("NomeEmpresa") = getNome("UnitName")
									end if
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
								
								set caixa = db.execute("select * from caixa where sysUser="&session("User")&" and isnull(dtFechamento)")
								if not caixa.eof then
									session("CaixaID") = caixa("id")
								end if
								
								clic = 0
								Licencas = ""
								while not tryLogin.EOF
								    if tryLogin("Status")="C" then
										clic = clic+1
										licencas = licencas & "<li><a href='./?P=ChangeCp&LicID="&tryLogin("LicencaID")&"&Pers=1'>"&tryLogin("NomeEmpresa")&"</a></li>"
								    end if
								tryLogin.movenext
								wend
								tryLogin.close
								set tryLogin=nothing
								if clic>1 then
									session("Licencas") = Licencas & "<li class='divider'></li>"
								end if

								response.Redirect("./?P=Home&Pers=1")
							end if
                        else
                            %>
                            <div id="divError" class="step-pane active">
                            	<div class="alert alert-danger"><button class="close" data-dismiss="alert" type="button"><i class="fa fa-remove"></i></button>
                                	<i class="fa fa-remove"></i>
                                    <strong>E-mail de acesso ou senha não confere.</strong>
                                </div>
                            </div>
                            <%
                        end if
%>