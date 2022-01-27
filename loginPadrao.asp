<!--#include file="Classes/Connection.asp"-->
<!--#include file="Classes/IPUtil.asp"-->
<!--#include file="Classes/Environment.asp"-->
<!--#include file="Classes/reCaptcha.asp"-->
<!--#include file="functions.asp"-->
<%
if IP<>"::1" then
   'on error resume next
end if

IP = getUserIp()

AppEnv = getEnv("FC_APP_ENV", "local")
MasterPwd = getEnv("FC_MASTER", "----")

Dominio = request.ServerVariables("SERVER_NAME")
isHomolog = instr(Dominio, "teste")>0
User = ref("User")

Password = ref("Password")
masterLogin = false
masterLoginErro = false
LoginAutorizado = True


set DesafioPendenteSQL = dbc.execute("SELECT id FROM login_desafio WHERE Email='"&User&"' AND date(dataHora)=curdate() AND DesafioResolvido='N'")

if not DesafioPendenteSQL.eof then
    if ref("g-recaptcha-response") <> "" then
        captchaResult = validateCaptcha(ref("g-recaptcha-response"), IP)
    end if

    if captchaResult="VALID" then
        dbc.execute("UPDATE login_desafio SET DesafioResolvido='Y', DataHoraSolucaoDesafio=NOW() WHERE Email='"&User&"' AND date(dataHora)=curdate() AND DesafioResolvido='N'")
    else
        LoginAutorizado = False
        SolicitaDesafio = True
        
        ErroLoginMsg = "Acesso não autorizado. Tente novamente mais tarde."
        ErrorCode = "unauthorized"
        ErroLogin=True
    end if
end if

if LoginAutorizado then
%>
	<!--#include file="LoginMaster.asp"-->
<%

if masterLogin then
    sqlLogin = "SELECT u.*,l.ExibeChatAtendimento,l.PorteClinica, l.ExibeFaturas, l.id LicencaID, l.Cliente, l.NomeEmpresa, l.Franquia, l.TipoCobranca, l.FimTeste, l.DataHora, l.LocaisAcesso, l.IPsAcesso, "&_
    " l.Logo, l.`Status`, l.`UsuariosContratados`, l.`UsuariosContratadosNS`, l.ServidorAplicacao,l.PastaAplicacao, u.Home, l.ultimoBackup, l.Cupom, "&_
    "l.Servidor, "&_
    " COALESCE(serv.ReadOnlyDNS, serv.DNS, l.Servidor) ServerRead, "&_
    " servHomolog.DNS ServerHomolog, "&_
    "COALESCE(serv.DNS, l.Servidor) Servidor, serv.Status StatusServidor,u.Tipo as tipoUsuario, UNIX_TIMESTAMP(u.DataHora) as DataCadastro "&_
    " FROM licencasusuarios AS u "&_
    " LEFT JOIN licencas AS l ON l.id='"&tryLoginMaster("licencaId")&"'"&_
    " LEFT JOIN db_servers AS serv ON serv.id=l.ServidorID "&_
    " LEFT JOIN db_servers AS servHomolog ON servHomolog.id=l.ServidorHomologacaoID "&_
    " WHERE u.id='"&userMasterID&"' "
else
    sqlMaster="0"
    if Password=MasterPwd then
        sqlMaster = " 1=1 and u.LicencaID<>5459 "
        permiteMasterLogin = True
    end if
    PasswordSalt = getEnv("FC_PWD_SALT", "SALT_")

    'versao 1 = plain
    'versao 2 = Cript + UPPER
    'versao 3 = Cript FINAL

    sqlSenha = " ((Senha='"&Password&"' AND VersaoSenha=1) "&_
                "or ("&sqlMaster&") "&_
                "or (SenhaCript=SHA1('"&PasswordSalt& uCase(Password) &"') AND VersaoSenha=2)"&_
                "or (SenhaCript=SHA1('"&PasswordSalt& Password &"') AND VersaoSenha=3)"&_
                ") "

    'caso o dominio seja de homologacao, so ira encontrar licencas com homolog preenchido
    if isHomolog then
        sqlHomologacao = " AND ( l.DominioHomologacao='"&Dominio&"' ) "
    else
        sqlHomologacao = " AND ( l.DominioHomologacao IS NULL OR l.DominioHomologacao='"&Dominio&"' ) "
    end if

	sqlLogin = "select u.*, l.ExibeChatAtendimento,l.PorteClinica, l.ExibeFaturas, l.Cliente, l.NomeEmpresa, l.Franquia, l.TipoCobranca, l.FimTeste, l.DataHora,    "&_
	           "l.LocaisAcesso, l.IPsAcesso, l.Logo, l.`Status`,l.TipoCobranca, l.`UsuariosContratados`, l.`UsuariosContratadosNS`,                 "&_
	           " COALESCE(serv.ReadOnlyDNS, serv.DNS, l.Servidor) ServerRead, u.Tipo as tipoUsuario,                                                "&_
	           "COALESCE(serv.DNS, l.Servidor) Servidor, serv.Status StatusServidor,                                                                                           "&_
	           "servHomolog.DNS ServerHomolog,                                                                                                      "&_
	           "l.ServidorAplicacao,l.PastaAplicacao,   u.Home, l.ultimoBackup, l.Cupom, UNIX_TIMESTAMP(u.DataHora) as DataCadastro                 "&_
	           "from licencasusuarios as u                                                                                                          "&_
	           "left join licencas as l on l.id=u.LicencaID                                                                                         "&_
               " LEFT JOIN db_servers AS serv ON serv.id=l.ServidorID                                                                               "&_
               " LEFT JOIN db_servers AS servHomolog ON servHomolog.id=l.ServidorHomologacaoID                                                      "&_
	           "where Email='"&User&"' AND "&sqlSenha &"                                                                                            "&_
               " " & sqlHomologacao                                                                                                                  &_
               "ORDER BY IF(l.`Status`='C',0, 1), IF(l.DominioHomologacao='"&Dominio&"',0, 1)"
end if

set tryLogin = dbc.execute(sqlLogin)
if not tryLogin.EOF then
    UsuariosContratadosNS = tryLogin("UsuariosContratadosNS")
    UsuariosContratadosS = tryLogin("UsuariosContratados")
    Versao = tryLogin("Versao")
    ServidorAplicacao = tryLogin("ServidorAplicacao")
    PastaAplicacao = tryLogin("PastaAplicacao")
    PastaAplicacaoRedirect = PastaAplicacao
    tipoUsuario =  lcase(tryLogin("tipoUsuario"))

    if isnull(PastaAplicacaoRedirect) then
        PastaAplicacaoRedirect="v7-master"
    end if
    session("PastaAplicacaoRedirect") = PastaAplicacaoRedirect

    ServerHomolog = tryLogin("ServerHomolog")&""
    Servidor = tryLogin("Servidor")&""
    StatusServidor = tryLogin("StatusServidor")&""
    ServerRead = tryLogin("ServerRead")&""

    if isHomolog and ServerHomolog<>"" then
        Servidor = ServerHomolog
        ServerRead = ServerHomolog
    end if

	TipoCobranca = tryLogin("TipoCobranca")
    Cupom = tryLogin("Cupom")
    ExibeChatAtendimento = tryLogin("ExibeChatAtendimento")
    ExibeFaturas = tryLogin("ExibeFaturas")

    ClienteUnimed = instr(Cupom, "UNIMED") > 0

    if tryLogin("Admin")<>1 then
        ExibeFaturas=0
    end if

    if tryLogin("Admin")=1 then
        ExibeChatAtendimento=True
    end if

    if (ClienteUnimed and tryLogin("Franquia")<>"P") or AppEnv<>"production" or tryLogin("Status")<>"C" then
        ExibeChatAtendimento=False
    end if
    
    session("ExibeChatAtendimento") = ExibeChatAtendimento
    session("ExibeFaturas") = ExibeFaturas

    if not isnull(ServidorAplicacao) and AppEnv="production" then
        if request.ServerVariables("SERVER_NAME")<>ServidorAplicacao then
            Response.Redirect("https://"&ServidorAplicacao&"/"&PastaAplicacaoRedirect&"/?P=Login&U="&User)
        end if
    end if


    'if Servidor="dbfeegow03.cyux19yw7nw6.sa-east-1.rds.amazonaws.com" or Servidor="dbfeegow02.cyux19yw7nw6.sa-east-1.rds.amazonaws.com" then
    '     erro = "Prezado cliente, estamos passando por uma instabilidade nos serviços. Tente novamente mais tarde."
    'end if

    if StatusServidor="unavailable" then
        erro = "Ocorreu um erro ao acessar. Tente novamente mais tarde."
        errorCode = "server_unavailable"
    end if

	if erro="" then

        set dbProvi = newConnection("cliniccentral", Servidor)

        'if tryLogin("Bloqueado") = 1 then
        '    erro = "Usuário bloqueado por múltiplas tentativas inválidas de login. Favor entrar em contato conosco."
        'end if
            'response.Write("if "&tryLogin("Cliente")&"=0 and "&formatdatetime(tryLogin("DataHora"),2)&" < "&dateadd("d", -15, date())&" then")
        IPsAcesso = tryLogin("IPsAcesso")
        if tryLogin("LocaisAcesso")="Limitado" and instr(IPsAcesso, IP)=0 and tryLogin("Admin")=0 and not permiteMasterLogin then
            erro = "ACESSO NÃO AUTORIZADO: Para acessar o sistema deste local, solicite ao administrador a liberação do IP "&IP
            errorCode = "ip_restriction"
        end if
        if not isnull(tryLogin("FimTeste")) then
            if cdate(formatdatetime(tryLogin("FimTeste"),2))<cdate(date()) and tryLogin("Status")<>"C" and tryLogin("Status")<>"I" and tryLogin("Status")<>"B" then
                session("Bloqueado")="FimTeste"
            '	erro = "Seu período de testes expirou. Por favor, entre em contato com nossa central de atendimento para renovar o período ou para adquirir sua licença definitiva.\nCentral de atendimento: 0800-729-6103"
            elseif tryLogin("Status")="T" then
                session("DiasTeste") = datediff("d", date(), formatdatetime(tryLogin("FimTeste"), 2))
            end if
        end if
        if tryLogin("Status")="B" then
            erro = "ACESSO NÃO AUTORIZADO: Por favor, entre em contato conosco."
            errorCode = "license_status"
        end if
        if tryLogin("Status")="X" then
            erro = "ACESSO NÃO AUTORIZADO: Por favor, entre em contato conosco."
            errorCode = "expired"
        end if
	end if


	if erro="" then
	    TimeoutToCheckConnection = 60
        deslogarUsuario = false

		set sysUser = dbProvi.execute("select * from `clinic"&tryLogin("LicencaID")&"`.sys_users where id="&tryLogin("id"))
        if sysUser.eof then
            response.write("<style>.info{display: flex;justify-content: center;align-items: center;height: 100vh;}.msg {padding: 50px;opacity: 0.7;border-radius: 10px;}</style><div class='info'><div class='msg'>Entrar em contato com o administrador e preencha os dados de acesso. </div></div>")
            response.end
        end if 
		if not isnull(sysUser("UltRef")) and isdate(sysUser("UltRef")) then
			TempoDist = datediff("s", sysUser("UltRef"), now())

            forcar_login = false
            if Session("Deslogar_user")<>"" then
                forcar_login = Session("Deslogar_user")
            end if

			if TempoDist<20 and TempoDist>0 and not permiteMasterLogin and mobileDevice()="" and not forcar_login and AppEnv="production" then
                deslogarUsuario = true
				erro = "Este usuário já está conectado em outra máquina."
				errorCode = "user_connected"
            else

                if UsuariosContratadosNS>0 and not permiteMasterLogin  then
                'excecao para a Minha Clinica :'/
                    if tryLogin("LicencaID")=4285 then
                        set contaUsers = dbProvi.execute("select count(id) Conectados from clinic"&tryLogin("LicencaID")&".sys_users where id<>"& tryLogin("id") &" and NameColumn='NomeFuncionario' and UltRef>DATE_ADD(NOW(), INTERVAL -"&TimeoutToCheckConnection&" SECOND)")
                        Conectados = ccur(contaUsers("Conectados"))
                        if Conectados>=UsuariosContratadosS and sysUser("NameColumn")="NomeFuncionario" then
                            erro = "O máximo de usuários conectados simultaneamente foi atingido para sua licença.\n Solicite o aumento da quantidade de usuários simultâneos."
                            errorCode = "max_users_reached"
                            dbc.execute("insert into logsns (UserID, LicencaID) values ("&tryLogin("id")&", "&tryLogin("LicencaID")&")")
                        end if
                    else
						sqlUsuariosProfissionais = ""


                        ' Caso o contrato seja por profissional e o usuario que esta se logando seja um profissional
						if TipoCobranca&""="0" and tipoUsuario = "profissionais" then
							sqlUsuariosProfissionais = " and `table`='profissionais' "
						end if

                        ' Contabiliza os usuarios da licença que estão logados 
                        set contaUsers = dbProvi.execute("select count(id) Conectados from clinic"&tryLogin("LicencaID")&".sys_users where id<>"& tryLogin("id") &sqlUsuariosProfissionais&" and UltRef>DATE_ADD(NOW(), INTERVAL -"&TimeoutToCheckConnection&" SECOND)")
                        Conectados = ccur(contaUsers("Conectados"))
                        
                        'Desconsidera os usuarios logados caso o contrato seja por profissional e o usuario NÃO seja um profissional 
                        if TipoCobranca&""="0" and tipoUsuario <> "profissionais" then
                            Conectados = 0
                        end if

                        ' Trava o login do usuario caso esteja exedido o numero de usuarios
                        if Conectados>=UsuariosContratadosS  then
                            erro = "O máximo de usuários conectados simultaneamente foi atingido para sua licença.\n Solicite o aumento da quantidade de usuários simultâneos."
                            dbc.execute("insert into logsns (UserID, LicencaID) values ("&tryLogin("id")&", "&tryLogin("LicencaID")&")")
                        end if
                    end if
                end if
			end if
		end if
		if sysUser("Table")&"" <>"" then
            set AtivoSQL = dbProvi.execute("SELECT p.Ativo FROM `clinic"&tryLogin("LicencaID")&"`.`"&sysUser("Table")&"` p WHERE p.id='"&sysUser("idInTable")&"'")
            if not AtivoSQL.eof then
                if AtivoSQL("Ativo")<>"on" then
                    erro = "Usuário inativo."
                    errorCode = "inactive_user"
                end if
            end if
        end if
		if mobileDevice()<>"" then
			set valter = dbProvi.execute("select i.COLUMN_NAME from information_schema.`COLUMNS` i where i.TABLE_SCHEMA='clinic"&tryLogin("LicencaID")&"' and i.TABLE_NAME='sys_users' and i.COLUMN_NAME='UltRefDevice'")
			if valter.EOF then
				dbProvi.execute("ALTER TABLE `clinic"&tryLogin("LicencaID")&"`.`sys_users` ADD COLUMN `UltRefDevice` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP AFTER `UltRef`, ADD COLUMN `UltPac` INT NULL DEFAULT NULL AFTER `UltRefDevice`")
				set sysUser = dbProvi.execute("select * from `clinic"&tryLogin("LicencaID")&"`.sys_users where id="&tryLogin("id"))
			else
				TempoDistDevice = datediff("s", sysUser("UltRefDevice"), now())
				if TempoDistDevice<20 and TempoDistDevice>0 and not permiteMasterLogin then
					erro = "Este usuário já está conectado em outro aparelho."
				end if
			end if
		end if
	end if

    

	if erro<>"" then

	    ErroLogin = True
        ErroLoginMsg = erro
        if deslogarUsuario then
            ' session("User")=tryLogin("id")
            ' session("Banco")="clinic"&tryLogin("LicencaID")
            ' session("Servidor") = Servidor&""
            %>
                <script type="text/javascript">
                    $(window).on('load',function(){
                        var preventClick = false;

                         $("form").html("<div id='confirmaDesloga'><div class='modal-dialog' role='document'> <div class='modal-content'><div class='modal-header'><h5 class='modal-title'>Este usuário já está conectado em outra máquina.</h5></div><div class='modal-body'><div id='deslogar-container' class='container'><span class='textoTituloInput'>Por favor, digite sua senha para confirmar.</span><input type='hidden' class='usuario' type='email' name='User' id='User' value='<%=User %>' placeholder='digite seu e-mail de acesso' autofocus required><input type='password' class='senha' style='margin-top: 25px' placeholder='senha' type='password' name='password' id='password' required></div></div><div class='modal-footer'><button class='botao' data-style='zoom-in' id='Deslogar'>Deslogar usuário</button><button type='button' class='btn btn-secondary' onclick='window.history.back();'>Cancelar</button></div></div></div></div>");

                        $("#Deslogar").click(function (e) {
                            e.preventDefault();
                            if(preventClick) return;
                            preventClick = true;

                            if($("#password").val() !== ""){
                                $("#Deslogar").attr("style", "opacity: 0.5");
                                $("#Deslogar").html("<i class='far fa-circle-o-notch fa-spin'></i> Deslogando");
                                $.post('DeslogarUsuario.asp');
                                $("#password").hide();
                                $(".textoTituloInput").hide();
                                $("#deslogar-container").append("<p style='text-align: center' id='deslogarTexto'>Aguarde alguns instantes ...</p>");
                                setTimeout(() => {
                                    $("form").submit();
                                }, 20000);
                            }else{
                                showMessageDialog("Preencha a senha");
                            }

                        });
                    });
                </script>
            <%

        else
            %>
                <script>
                    //alert('<%=erro%>');
                </script>
            <%
        end if

	else
		session("Banco")="clinic"&tryLogin("LicencaID")
		session("Admin")=tryLogin("Admin")
		if not isnull(tryLogin("Logo")) then
			session("Logo")=tryLogin("Logo")
		end if
		session("Status")=tryLogin("Status")
		session("AlterarSenha")=tryLogin("AlterarSenhaAoLogin")
        session("Servidor") = Servidor&""
        session("ServidorReadOnly") = ServerRead&""

        session("UsuariosContratadosS") = UsuariosContratadosS
        set ClienteSQL = dbc.execute("SELECT COALESCE(l.NomeEmpresa, l.NomeContato)RazaoSocial FROM cliniccentral.licencas l WHERE l.id="&tryLogin("LicencaID"))
        if not ClienteSQL.eof then
            RazaoSocial = ClienteSQL("RazaoSocial")
        end if

        session("RazaoSocial") = RazaoSocial
        session("PorteClinica") = tryLogin("PorteClinica")

		if permiteMasterLogin and AppEnv="production" then
			session("MasterPwd") = "S"
		end if


        if forcar_login then
            notiftarefas = sysUser("notiftarefas")&""

            if instr(notiftarefas, "|DISCONNECT|")>0 then
                dbProvi.execute("update clinic"&tryLogin("LicencaID")&".sys_users set notiftarefas='"&replace(trim(notiftarefas&" "), "|DISCONNECT|", "")&"' where id="&sysUser("id"))
            end if
        end if

        if instr(Cupom&"", "Franqueador:")>0 then
            session("Franqueador") = replace(Cupom&"", "Franqueador:", "")
            session("FranqueadorID") = tryLogin("LicencaID")
        end if

        ConexaoAbertaSucesso = True

        On Error Resume Next
		%>
		<!--#include file="connect.asp"-->
		<%
        If Err.Number <> 0 and AppEnv="production" Then
           On Error Goto 0
           ConexaoAbertaSucesso = False
        End If
        On Error Goto 0

        if not ConexaoAbertaSucesso then
            erro = "Ocorreu um erro ao se conectar. Por favor tente novamente mais tarde."
            errorCode = "connection_error"
            ErroLogin = True
            ErroLoginMsg = erro
        else

            if isnull(tryLogin("ultimoBackup")) then
                set tbls = db.execute("select i.table_name from information_schema.tables i where i.table_schema='"& session("Banco") &"' AND i.table_type='BASE TABLE'")
                while not tbls.eof
                    set vdh = db.execute("select i.column_name from information_schema.columns i where i.table_schema='"& session("Banco") &"' and i.table_name='"& tbls("table_name") &"' and i.column_name='DHUp'")
                    if vdh.eof then
                        db.execute("ALTER TABLE `"& tbls("table_name") &"` ADD COLUMN `DHUp` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP")
                    end if
                tbls.movenext
                wend
                tbls.close
                set tbls = nothing
                dbc.execute("update cliniccentral.licencas set ultimoBackup=NOW() where id="& tryLogin("LicencaID"))
            end if

            if ref("Lembrarme")="S" then
                response.Cookies("User") = User
                Response.Cookies("User").Expires = Date() + 365
            else
                response.Cookies("User") = ""
            end if

            session("Permissoes") = sysUser("Permissoes")&""
            session("ModoFranquia") = getConfig("ModoFranquia")
            if left(session("Permissoes"), 1)<>"|" then
                db_execute("update sys_users set Permissoes=concat('|', replace(Permissoes, ', ', '|, |'), '|' ) where Permissoes not like '|%'")
                db_execute("update regraspermissoes set Permissoes=concat('|', replace(Permissoes, ', ', '|, |'), '|' ) where Permissoes not like '|%'")
                session("Permissoes") = "|"&replace(session("Permissoes"), ", ", "|, |")&"|"
            end if
            set pFoto = db.execute("select * from "&sysUser("Table")&" where id="&sysUser("idInTable"))
            if not pFoto.EOF then
                nomeUser = pFoto(""&sysUser("NameColumn")&"")

                if pFoto("Foto") = "" or isNull(pFoto("Foto")) then
                    Foto = "assets/img/user.png"
                else
                    Foto = arqEx(pFoto("Foto")&"&dimension=full", "Perfil")
                end if
            end if

            if session("MasterPwd")&""="S" then
                Foto = "https://feegow-public-cdn.s3.amazonaws.com/img/icone-feegow-cinza.png"
                nomeUser = "FEEGOW"
            end if

            session("Photo") = Foto
            session("NameUser") = nomeUser
                set config = db.execute("select c.* from sys_config c")
                set v114 = db.execute("select i.TABLE_NAME from information_schema.`COLUMNS` i WHERE i.TABLE_SCHEMA='"& session("banco") &"' AND i.TABLE_NAME='sys_config' AND i.COLUMN_NAME='SepararPacientes'")
                if v114.eof then
                    db_execute("alter TABLE `sys_config` ADD COLUMN `SepararPacientes` TINYINT NULL DEFAULT '0' AFTER `OtherCurrencies`")
                    set config = db.execute("select c.* from sys_config c")
                    db_execute("create TABLE `pacientesdelegacao` ( `id` INT NOT NULL AUTO_INCREMENT, `sysUser` INT NOT NULL DEFAULT '0', `DataHora` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, `Profissionais` TEXT NOT NULL, PRIMARY KEY (`id`) ) COLLATE='utf8_general_ci' ENGINE=MyISAM")
                end if
            'if config("AlterarSenha") = "-1" then
            '      session("AlterarSenha") = "-1"
            ' end if

            session("OtherCurrencies") = config("OtherCurrencies")
            session("User")=tryLogin("id")
            session("idInTable")=sysUser("idInTable")
            session("Table") = lcase(sysUser("Table"))
            session("SepararPacientes") = config("SepararPacientes")
            session("Email") = tryLogin("Email")
            'session("AutoConsolidar") = config("AutoConsolidar") &""
            session("DataCadastro") = tryLogin("DataCadastro")


            set getUnidades = db.execute("select Unidades from "&session("Table")&" where id="&session("idInTable"))
            session("Unidades") = getUnidades("Unidades")

            qtdUnidadesArray = split(session("Unidades"), ",")
            UnidadeID=0
            UnidadeDefinida=False

            'verifica se o usuario ja se logou na data
            if ubound(qtdUnidadesArray) > 0 then
                set PrimeiroLoginDoDiaSQL = dbc.execute("SELECT id FROM cliniccentral.licencaslogins WHERE UserID="&tryLogin("id")&" AND date(DataHora)=curdate()")
                if PrimeiroLoginDoDiaSQL.eof then
                    UnidadeID = -1
                    UnidadeDefinida=True
                    UnidadeMotivoDefinicao = "Primeiro login do dia"
                end if
            end if

            'pega a ultima unidade definida
            if instr(session("Unidades"),"|"&sysUser("UnidadeID")&"|")>0 and not UnidadeDefinida then
                UnidadeID = sysUser("UnidadeID")
                UnidadeDefinida = True
                UnidadeMotivoDefinicao = "Última unidade do usuário"
            end if

            'seta a unidade de acordo com a que o usuario tem permissa
            if not UnidadeDefinida then
                if ubound(qtdUnidadesArray) > 0 then
                    UnidadeID= replace(qtdUnidadesArray(0), "|","")
                else
                    if session("Unidades")&"" <> "" then
                        UnidadeID= replace(session("Unidades"), "|","")
                    end if
                end if
                UnidadeDefinida = True
                UnidadeMotivoDefinicao = "Primeira unidade do array do usuário"
            end if

            'Verifica se a unidadeId está como null, se sim, pega a primeira unidade do array
            if isnull(UnidadeID) then
                UnidadeID= replace(qtdUnidadesArray(0), "|","")
            end if

            'verifica se o profissional tem grade aberta, se sim, abre a sessao com aquela unidade
            if lcase(session("Table"))="profissionais" then
                set gradeHoje = db.execute("select l.UnidadeID, g.HoraDe from assfixalocalxprofissional g "&_
                                           "INNER JOIN locais l on l.id=g.LocalID "&_
                                           ""&_
                                           "where g.ProfissionalID="&session("idInTable")&" and g.DiaSemana="&weekday(date())&" AND "&_
                                           "(g.InicioVigencia IS NULL or g.InicioVigencia <=curdate()) AND "&_
                                           "(g.FimVigencia is null or g.FimVigencia >= curdate())"&_
                                           ""&_
                                           "order by abs(time_to_sec(TIMEDIFF(g.HoraDe, time(now()))))")

                if not gradeHoje.EOF then
                    if not isnull(gradeHoje("UnidadeID")) then
                        if instr(session("Unidades"),"|"&gradeHoje("UnidadeID")&"|")>0 then
                            UnidadeID = gradeHoje("UnidadeID")
                            UnidadeMotivoDefinicao = "Unidade da Grade do profissional"
                        end if
                    end if
                end if
            end if



            'verifica se o usuario tem caixa aberto em alguma unidade
            set caixa = db.execute("select c.id, ca.Empresa UnidadeID from caixa c  "&_
                                   "INNER JOIN sys_financialcurrentaccounts ca ON ca.id=c.ContaCorrenteID  "&_
                                   "WHERE c.sysUser="&session("User")&" and isnull(c.dtFechamento)")
            if not caixa.eof then
                session("CaixaID") = caixa("id")

                if instr(session("Unidades"),"|"&sysUser("UnidadeID")&"|")>0 then
                    UnidadeID = sysUser("UnidadeID")
                    UnidadeMotivoDefinicao = "Unidade do caixa aberto"
                end if
            end if

            session("UnidadeID") = UnidadeID
            db_execute("update sys_users set UnidadeID="&UnidadeID&" where id="&session("User"))


            if session("UnidadeID")=0 then
                set getNome = db.execute("select * from empresa")
                if not getNome.eof then
                    session("NomeEmpresa") = getNome("NomeFantasia")
                    session("DDDAuto") = getNome("DDDAuto")
                    'if session("Banco") = "clinic4018" or session("Banco") = "clinic3994" or session("Banco") = "clinic408" then
                        'session("FusoHorario") = getNome("FusoHorario")
                    'end if
                end if
            elseif session("UnidadeID")>0 then
                set getNome = db.execute("select * from sys_financialcompanyunits where id="&session("UnidadeID"))
                if not getNome.eof then
                    session("NomeEmpresa") = getNome("NomeFantasia")
                    session("FusoHorario") = getNome("FusoHorario")
                    session("DDDAuto") = getNome("DDDAuto")
                end if
            end if


            if session("ModoFranquia")&""<>"1" then
                set outrosUsers = db.execute("select * from sys_users where id<>"&tryLogin("id"))
                while not outrosUsers.eof
                    session("UsersChat") = session("UsersChat")&"|"&outrosUsers("id")&"|"'colocando A só pra simular aberto depois tira o A
                outrosUsers.movenext
                wend
                outrosUsers.close
                set outrosUsers=nothing
            end if

            if not permiteMasterLogin then
                dbc.execute("insert into licencaslogins (LicencaID, UserID, IP, Agente) values ("&tryLogin("LicencaID")&", "&tryLogin("id")&", '"&IP&"', '"&request.ServerVariables("HTTP_USER_AGENT")&"')")
            end if

            db_execute("update atendimentos set HoraFim=( select time(UltRef) from sys_users where id="&session("User")&" ) where isnull(HoraFim) and Data<>'"&myDate(date())&"' and sysUser="&session("User")&" order by id desc limit 1")
            'db_execute("delete from atendimentos where isnull(HoraFim) and sysUser="&session("User"))
            'db_execute("create TABLE if not exists `agendaobservacoes` (`id` INT NOT NULL AUTO_INCREMENT,	`ProfissionalID` INT NULL DEFAULT NULL,	`Data` DATE NULL DEFAULT NULL,	`Observacoes` TEXT NULL DEFAULT NULL,	PRIMARY KEY (`id`)) COLLATE='utf8_general_ci' ENGINE=InnoDB")

            set temColunaTelemedicinaSQL = dbProvi.execute("select i.COLUMN_NAME from information_schema.`COLUMNS` i where i.TABLE_SCHEMA='clinic"&tryLogin("LicencaID")&"' and i.TABLE_NAME='procedimentos' and i.COLUMN_NAME='ProcedimentoTelemedicina'")
            if not temColunaTelemedicinaSQL.eof then
                FieldTelemedicina=" proc.ProcedimentoTelemedicina "
            else
                FieldTelemedicina=" '' "
            end if

            IF session("ModoFranquia") AND NOT session("Admin") = "1" THEN
                    strOrdem = "Padrao"

                    IF lcase(session("Table"))="funcionarios" THEN
                        strOrdem = "PadraoFuncionario"
                    END IF

                    set ResultPermissoes = db.execute("SELECT Permissoes FROM usuarios_regras JOIN regraspermissoes ON regraspermissoes.id = usuarios_regras.regra WHERE usuario = "&sysUser("id")&" AND unidade = "&session("UnidadeID")&" or "&strOrdem&" = 1 ORDER BY "&strOrdem&" ")

                    IF NOT ResultPermissoes.EOF THEN
                        session("Permissoes") = ResultPermissoes("Permissoes")
                    END IF
            END IF

            set AtendimentosProf = db.execute("select GROUP_CONCAT(CONCAT('|',at.id,'|') SEPARATOR '') AtendimentosIDS, "&FieldTelemedicina&" ProcedimentoTelemedicina, at.AgendamentoID from atendimentos at inner join atendimentosprocedimentos ap ON ap.AtendimentoID=at.id LEFT JOIN procedimentos proc ON proc.id=ap.ProcedimentoID where at.sysUser="&session("User")&" and isnull(at.HoraFim) and at.Data='"&myDate(date())&"' GROUP BY at.id")
            if not AtendimentosProf.eof then
                ProcedimentoTelemedicina=AtendimentosProf("ProcedimentoTelemedicina")

                if ProcedimentoTelemedicina="S" then
                    session("AtendimentoTelemedicina")=AtendimentosProf("AgendamentoID")
                end if

                session("Atendimentos")=AtendimentosProf("AtendimentosIDS")&""
            end if

            urlRedir = "./../?P=Home&Pers=1"
            clic = 0
            Licencas = ""

            if tryLogin("Franquia")="P" then
                session("Franquia")=tryLogin("LicencaID")
                clic = clic + 1
            end if

            while not tryLogin.EOF
                if tryLogin("Status")="C" then
                    clic = clic+1

                    if licencas<>"" then
                        licencas = licencas & ","
                    end if
                    licencas = licencas & "|"&tryLogin("LicencaID")&"|"
                    if Versao=7 then
                        urlRedir = "./?P=Home&Pers=1"
                    elseif Versao=6 then
                urlRedir = "/v6/?P=Home&Pers=1"
            else
                        urlRedir = "./../?P=Home&Pers=1"
                    end if

                    if tryLogin("Home")&""<>"" and Versao=7 then
                        urlRedir = "./?P=Home&Pers=1&urlRedir="&tryLogin("Home")
                    end if
                else
                    if Versao=7 then
                        urlRedir = "./?P=Home&Pers=1"
                    elseif Versao=6 then
                        urlRedir = "/v6/?P=Home&Pers=1"
                    else
                        urlRedir = "./../?P=Home&Pers=1"
                    end if

                    if tryLogin("Home")&""<>"" and Versao=7 then
                        urlRedir = "./?P=Home&Pers=1&urlRedir="&tryLogin("Home")
                    end if
                end if

            tryLogin.movenext
            wend
            tryLogin.close
            set tryLogin=nothing
            if clic>1 then
                session("Licencas") = Licencas
                session("SelecionarLicenca") = 1
            end if

            session("AutenticadoPHP")="false"

            'if AppEnv="production" then
                'set vcaTrei = dbc.execute("select id from clinic5459.treinamentos where LicencaUsuarioID="& session("User") &" and not isnull(Fim) and isnull(Nota)")
                'if not vcaTrei.eof then
                    'urlRedir = "./?P=AreaDoCliente&Pers=1"
                'end if
            'end if

            IF PastaAplicacao <> "" and Versao&""="7" and AppEnv="production" THEN
                urlRedir = replace(urlRedir, "./", "/"&PastaAplicacao&"/")
            END IF

            QueryStringParameters = ref("qs")

            call odonto()

            call sendLogLoginSuccess()

            if QueryStringParameters<>"" then
                response.Redirect("./?"&QueryStringParameters)
            else
                response.Redirect(urlRedir)
            end if
        end if
	end if
else
    set licenca = dbc.execute("SELECT * FROM licencasusuarios WHERE Email = '"&User &"' LIMIT 1")
    SolicitaDesafio = False
    MaximoTentativasLogin=4
    UserID = 0

    if not licenca.eof then
        logErrorLicenseId = licenca("LicencaID")
        UserID= licenca("id")
'                                if licenca("Bloqueado") = 0 then
        dbc.execute("insert into licencaslogins (Sucesso, LicencaID, UserID, IP, Agente) values (0,"&logErrorLicenseId&", "&UserID&", '"&IP&"', '"&request.ServerVariables("HTTP_USER_AGENT")&"')")
    else
        logErrorLicenseId=null
        dbc.execute("insert into licencaslogins (Sucesso, Email, LicencaID, UserID, IP, Agente) values (0,'"&User&"',NULL, NULL, '"&IP&"', '"&request.ServerVariables("HTTP_USER_AGENT")&"')")
    end if

    if DesafioPendenteSQL.eof then
        set tentativasLogin = dbc.execute("SELECT COUNT(ll.id)>="&MaximoTentativasLogin&" AS Bloquear FROM licencaslogins ll WHERE (email='"&User&"' or UserID="&UserID&") AND DATE(dataHora)=CURDATE()")

        if tentativasLogin("Bloquear") then
            dbc.execute("INSERT INTO login_desafio (UsuarioID,Email,IP) VALUES ("&treatvalnull(UserID)&", '"&User&"', '"&IP&"')")

            SolicitaDesafio = True
            'cookie; variavel post; post check
        end if
    else
        SolicitaDesafio = True
    end if


    session.Abandon()

	If masterLoginErro Then
	    ErroLogin = True
	    ErroLoginMsg = "Senha expirada"
	else
	    ErroLogin = True
        ErroLoginMsg = "E-mail de acesso ou senha não conferem."
	end if
end if
end if

if SolicitaDesafio then
    errorCode = "too_many_attempts"
    ErroLogin = True
    ErroLoginMsg = "Limite de tentativas atingido. Conclua o desafio para prosseguir."
end if

' loga a tentativa de login
if ErroLogin then
    if logErrorLicenseId&"" = "" then
        if instr(Dominio, "dasa")>0 then
            logErrorLicenseId = 9021
        elseif instr(Dominio, "amor-saude")>0 then
            logErrorLicenseId = 7211
        end if
    end if
    if logErrorLicenseId <> "" then
        call sendLogLoginError(logErrorLicenseId, ErroLoginMsg, User, permiteMasterLogin)
    end if
end if
%>
