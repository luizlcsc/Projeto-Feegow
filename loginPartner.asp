<!--#include file="Classes/Connection.asp"--><%
						set tryLogin = dbc.execute("select lu.*, l.Servidor from licencasusuariosmulti lu left join licencas l on l.id=LicencaAtual where lu.Email='"&ref("User")&"' and lu.Senha='"&ref("Password")&"' and lu.Cupom='"&req("Partner")&"'")
                        if not tryLogin.EOF then

                            Servidor = tryLogin("Servidor")&""
							session("Servidor")=Servidor


							session("Banco")="clinic"&tryLogin("LicencaAtual")
							session("ExibeChatAtendimento")= True
							session("Email")= tryLogin("Email")
							session("Admin")=tryLogin("Admin")
							session("Logo")=req("Partner")&".png"
							session("Status")="C"
							session("Permissoes") = tryLogin("Permissoes")
							session("NameUser") = tryLogin("Nome")
							session("Photo") = "assets/img/user.png"
							session("OtherCurrencies") = ""
							session("User")=tryLogin("id")*(-1)
							session("idInTable")=tryLogin("id")
							session("Table") = "cliniccentral.licencasusuariosmulti"
							session("Partner")=req("Partner")
' "clinic"&tryLogin("LicencaAtual")
                            				set dbProvi = newConnection("clinic"&tryLogin("LicencaAtual"), Servidor)

							set getUnidades = dbProvi.execute("select group_concat('|', id, '|') Unidades from sys_financialcompanyunits")
							session("Unidades") = "|0|" & getUnidades("Unidades")
							session("UnidadeID") = 0


							if session("UnidadeID")=0 then
								set getNome = dbProvi.execute("select NomeEmpresa from empresa")
								if not getNome.eof then
									session("NomeEmpresa") = getNome("NomeEmpresa")
								end if
							else
								set getNome = dbProvi.execute("select UnitName from sys_financialcompanyunits where id="&session("UnidadeID"))
								if not getNome.eof then
									session("NomeEmpresa") = getNome("UnitName")
								end if
							end if


							set outrosUsers = dbProvi.execute("select * from sys_users")
							while not outrosUsers.eof
								session("UsersChat") = session("UsersChat")&"|"&outrosUsers("id")&"|"'colocando A só pra simular aberto depois tira o A
							outrosUsers.movenext
							wend
							outrosUsers.close
							set outrosUsers=nothing

							dbProvi.execute("update atendimentos set HoraFim=( select time(UltRef) from sys_users where id="&session("User")&" ) where isnull(HoraFim) and sysUser="&session("User")&" order by id desc limit 1")

							response.Redirect("./?P=Home&Pers=1")
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
%>
