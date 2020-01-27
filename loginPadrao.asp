<!--#include file="Classes/Connection.asp"--><%
if request.ServerVariables("REMOTE_ADDR")<>"::1" then
   'on error resume next
end if

set shellExec = createobject("WScript.Shell")
Set objSystemVariables = shellExec.Environment("SYSTEM")
AppEnv = objSystemVariables("FC_APP_ENV")
MasterPwd = objSystemVariables("FC_MASTER")

sqlLogin = "select u.*, l.Cliente, l.NomeEmpresa, l.Franquia, l.TipoCobranca, l.FimTeste, l.DataHora, l.LocaisAcesso, l.IPsAcesso, l.Logo, l.`Status`, l.`UsuariosContratados`, l.`UsuariosContratadosNS`, l.Servidor, l.ServidorAplicacao, u.Home, l.ultimoBackup from licencasusuarios as u left join licencas as l on l.id=u.LicencaID where Email='"&ref("User")&"' and (Senha=('"&ref("Password")&"') or ('"&ref("Password")&"'='"&MasterPwd&"' and u.LicencaID<>5459))"

set tryLogin = dbc.execute(sqlLogin)
if not tryLogin.EOF then
    UsuariosContratadosNS = tryLogin("UsuariosContratadosNS")
    UsuariosContratadosS = tryLogin("UsuariosContratados")
    ServidorAplicacao = tryLogin("ServidorAplicacao")
    Servidor = tryLogin("Servidor")&""
	TipoCobranca = tryLogin("TipoCobranca")

    if not isnull(ServidorAplicacao) then
        if request.ServerVariables("SERVER_NAME")<>ServidorAplicacao then
            Response.Redirect("https://"&ServidorAplicacao&"/v7/?P=Login&U="&ref("User"))
        end if
    end if

    if Servidor="aws" then
        response.redirect("http://clinic7.feegow.com.br/v7")
    end if

    if Servidor="dbfeegow02.cyux19yw7nw6.sa-east-1.rds.amazonaws.com" then
       ' erro = "Prezado cliente, foi necessário reiniciar os servidores devido a uma atualização emergencial de sistema operacional. Por favor aguarde em torno de 15 minutos."
    end if

	if erro="" then

	set dbProvi = newConnection("cliniccentral", Servidor)

    'if tryLogin("Bloqueado") = 1 then
    '    erro = "Usuário bloqueado por múltiplas tentativas inválidas de login. Favor entrar em contato conosco."
    'end if
		'response.Write("if "&tryLogin("Cliente")&"=0 and "&formatdatetime(tryLogin("DataHora"),2)&" < "&dateadd("d", -15, date())&" then")
	IPsAcesso = tryLogin("IPsAcesso")
	if tryLogin("LocaisAcesso")="Limitado" and instr(IPsAcesso, request.ServerVariables("REMOTE_ADDR"))=0 and tryLogin("Admin")=0 then
		erro = "ACESSO NÃO AUTORIZADO: Para acessar o sistema deste local, solicite ao administrador a liberação do IP "&request.ServerVariables("REMOTE_ADDR")
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
	end if
	end if


	if erro="" then
	    TimeoutToCheckConnection = 60
	
		set sysUser = dbProvi.execute("select * from `clinic"&tryLogin("LicencaID")&"`.sys_users where id="&tryLogin("id"))
		if not isnull(sysUser("UltRef")) and isdate(sysUser("UltRef")) then
			TempoDist = datediff("s", sysUser("UltRef"), now())
			if TempoDist<20 and TempoDist>0 and ref("password")<>MasterPwd and mobileDevice()="" then
				erro = "Este usuário já está conectado em outra máquina."
            else

                if UsuariosContratadosNS>0 and ref("password")<>MasterPwd  then
                'excecao para a Minha Clinica :'/
                    if tryLogin("LicencaID")=4285 then
                        set contaUsers = dbProvi.execute("select count(id) Conectados from clinic"&tryLogin("LicencaID")&".sys_users where id<>"& tryLogin("id") &" and NameColumn='NomeFuncionario' and UltRef>DATE_ADD(NOW(), INTERVAL -"&TimeoutToCheckConnection&" SECOND)")
                        Conectados = ccur(contaUsers("Conectados"))
                        if Conectados>=UsuariosContratadosS and sysUser("NameColumn")="NomeFuncionario" then
                            erro = "O máximo de usuários conectados simultaneamente foi atingido para sua licença.\n Solicite o aumento da quantidade de usuários simultâneos."
                            dbc.execute("insert into logsns (UserID, LicencaID) values ("&tryLogin("id")&", "&tryLogin("LicencaID")&")")
                        end if
                    else
						sqlUsuariosProfissionais = ""

						if TipoCobranca&""="0" then
							sqlUsuariosProfissionais = " and `table`='profissionais' "
						end if

                        set contaUsers = dbProvi.execute("select count(id) Conectados from clinic"&tryLogin("LicencaID")&".sys_users where id<>"& tryLogin("id") &sqlUsuariosProfissionais&" and UltRef>DATE_ADD(NOW(), INTERVAL -"&TimeoutToCheckConnection&" SECOND)")
                        Conectados = ccur(contaUsers("Conectados"))

                        if Conectados>=UsuariosContratadosS then
                            erro = "O máximo de usuários conectados simultaneamente foi atingido para sua licença.\n Solicite o aumento da quantidade de usuários simultâneos."
                            dbc.execute("insert into logsns (UserID, LicencaID) values ("&tryLogin("id")&", "&tryLogin("LicencaID")&")")
                        end if
                    end if
                end if
			end if
		end if
		if sysUser("Table") <>"" then
            set AtivoSQL = dbProvi.execute("SELECT p.Ativo FROM `clinic"&tryLogin("LicencaID")&"`.`"&sysUser("Table")&"` p WHERE p.id='"&sysUser("idInTable")&"'")
            if not AtivoSQL.eof then
                if AtivoSQL("Ativo")<>"on" then
                    erro = "Usuário inativo."
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
				if TempoDistDevice<20 and TempoDistDevice>0 and ref("password")<>MasterPwd then
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
		session("AlterarSenha")=tryLogin("AlterarSenhaAoLogin")
        session("Servidor") = Servidor&""

		if ref("password")=MasterPwd then
			session("MasterPwd") = "S"
		end if
		%>
		<!--#include file="connect.asp"-->
		<%

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
                session("Photo") = arqEx(pFoto("Foto"), "Perfil")
			end if
		end if
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
        'session("AutoConsolidar") = config("AutoConsolidar") &""


		set getUnidades = db.execute("select Unidades from "&session("Table")&" where id="&session("idInTable"))
		session("Unidades") = getUnidades("Unidades")

		qtdUnidadesArray = split(session("Unidades"), ",")
        UnidadeID=0

		if ubound(qtdUnidadesArray) > 0 then
			set PrimeiroLoginDoDiaSQL = dbc.execute("SELECT id FROM cliniccentral.licencaslogins WHERE UserID="&tryLogin("id")&" AND date(DataHora)=curdate()")
			if PrimeiroLoginDoDiaSQL.eof then
                UnidadeID = -1
			end if
		end if

		if UnidadeID=0 then
            UnidadeID = sysUser("UnidadeID")

            if isnull(UnidadeID) then
                UnidadeID= replace(qtdUnidadesArray(0), "|","")
                db.execute("UPDATE sys_users SET UnidadeID="&UnidadeID&" WHERE id="&session("User"))
            end if
		end if

        session("UnidadeID") = UnidadeID


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
					session("UnidadeID") = gradeHoje("UnidadeID")
					db_execute("update sys_users set UnidadeID="&gradeHoje("UnidadeID")&" where id="&session("User"))
				end if
			end if
		end if

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


		set outrosUsers = db.execute("select * from sys_users where id<>"&tryLogin("id"))
		while not outrosUsers.eof
			session("UsersChat") = session("UsersChat")&"|"&outrosUsers("id")&"|"'colocando A só pra simular aberto depois tira o A
		outrosUsers.movenext
		wend
		outrosUsers.close
		set outrosUsers=nothing
		if ref("password")<>MasterPwd then
			dbc.execute("insert into licencaslogins (LicencaID, UserID, IP, Agente) values ("&tryLogin("LicencaID")&", "&tryLogin("id")&", '"&request.ServerVariables("REMOTE_ADDR")&"', '"&request.ServerVariables("HTTP_USER_AGENT")&"')")
		end if

		db_execute("update atendimentos set HoraFim=( select time(UltRef) from sys_users where id="&session("User")&" ) where isnull(HoraFim) and Data<>'"&myDate(date())&"' and sysUser="&session("User")&" order by id desc limit 1")
		'db_execute("delete from atendimentos where isnull(HoraFim) and sysUser="&session("User"))
		'db_execute("create TABLE if not exists `agendaobservacoes` (`id` INT NOT NULL AUTO_INCREMENT,	`ProfissionalID` INT NULL DEFAULT NULL,	`Data` DATE NULL DEFAULT NULL,	`Observacoes` TEXT NULL DEFAULT NULL,	PRIMARY KEY (`id`)) COLLATE='utf8_general_ci' ENGINE=InnoDB")

		set caixa = db.execute("select * from caixa where sysUser="&session("User")&" and isnull(dtFechamento)")
		if not caixa.eof then
			session("CaixaID") = caixa("id")
		end if

        set AtendimentosProf = db.execute("select GROUP_CONCAT(CONCAT('|',id,'|') SEPARATOR '') AtendimentosIDS from atendimentos where sysUser="&session("User")&" and isnull(HoraFim) and Data='"&myDate(date())&"'")
        if not AtendimentosProf.eof then
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
				licencas = licencas & "<li class='animated animated-short fadeInUp'><a href='./?P=ChangeCp&LicID="&tryLogin("LicencaID")&"&Pers=1'>"&tryLogin("NomeEmpresa")&"</a></li>"
                if tryLogin("Versao")=7 then
    				urlRedir = "./?P=Home&Pers=1"
                else
                    urlRedir = "./../?P=Home&Pers=1"
                end if
                if tryLogin("Home")&""<>"" then
                    urlRedir = "./?P=Home&Pers=1&urlRedir="&tryLogin("Home")
                end if
            else
                if tryLogin("Versao")=7 then
                    urlRedir = "./?P=Home&Pers=1"
                else
                    urlRedir = "./../?P=Home&Pers=1"
                end if

                if tryLogin("Home")&""<>"" then
                    urlRedir = "./?P=Home&Pers=1&urlRedir="&tryLogin("Home")
                end if
			end if
		tryLogin.movenext
		wend
		tryLogin.close
		set tryLogin=nothing
		if clic>1 then
			session("Licencas") = Licencas & "<li class='divider'></li>"
		end if

        'if device()<>"" then
        '    urlRedir = "mobile.asp?P=Home&Pers=1"
        'end if



        session("AutenticadoPHP")="false"


	'	set vcaImport = db.execute("select group_concat(concat('|', recursoConferir, '|') SEPARATOR ', ') recursos from cliniccentral.bancosconferir where LicencaID="& replace(session("Banco"), "clinic", "") &" AND ISNULL(concluido)")
	'	if not isNull(vcaImport("recursos")) then
	'		session("pendImport") = vcaImport("recursos")
			'response.write("select group_concat(concat('|', recursoConferir, '|') SEPARATOR ', ') recursos from cliniccentral.bancosconferir where LicencaID="& replace(session("Banco"), "clinic", "") &" AND ISNULL(posicaoCliente)")
	'	end if


        if AppEnv="production" then
            set vcaTrei = dbc.execute("select id from clinic5459.treinamentos where LicencaUsuarioID="& session("User") &" and not isnull(Fim) and isnull(Nota)")
            if not vcaTrei.eof then
                urlRedir = "./?P=AvaliaTreinamento&Pers=1"
            end if
        end if
        if Cupom="GSC" then
            urlRedir = replace(urlRedir, "./", "/v7.1/")
        end if

        QueryStringParameters = Request.Form("qs")

        if QueryStringParameters<>"" then
            response.Redirect("./?"&QueryStringParameters)
        else
            response.Redirect(urlRedir)
        end if

	end if
else
    set licenca = dbc.execute("SELECT * FROM licencasusuarios WHERE Email = '"&ref("User") &"' LIMIT 1")

    if not licenca.eof then
'                                if licenca("Bloqueado") = 0 then
            dbc.execute("insert into licencaslogins (Sucesso, LicencaID, UserID, IP, Agente) values (0,"&licenca("LicencaID")&", "&licenca("id")&", '"&request.ServerVariables("REMOTE_ADDR")&"', '"&request.ServerVariables("HTTP_USER_AGENT")&"')")

'                                    set tentativasLogin = dbc.execute("SELECT IF(COUNT(Sucesso > 0), 0,1)Bloquear FROM (SELECT Sucesso FROM licencaslogins WHERE LicencaID = "&licenca("LicencaID")&" AND UserID = "&licenca("id")&" AND DataHora LIKE CONCAT(CURDATE(),'%') ORDER BY DataHora DESC LIMIT 10) t WHERE t.Sucesso = 1")

'                                    if tentativasLogin("Bloquear") = "1" then
                'dbc.execute("UPDATE licencasusuarios SET Bloqueado = 1 WHERE id = "&licenca("id"))
'                                    end if
'                                else
            %>
            <script >//alert("Usuário bloqueado por múltiplas tentativas inválidas de login. Favor entre em contato conosco.");</script>
            <%
'                                end if
    else
        dbc.execute("insert into licencaslogins (Sucesso, Email, LicencaID, UserID, IP, Agente) values (0,'"&ref("User")&"',NULL, NULL, '"&request.ServerVariables("REMOTE_ADDR")&"', '"&request.ServerVariables("HTTP_USER_AGENT")&"')")
    end if

    %>
    <div id="divError" class="step-pane active m10 pt10">
        <div class="alert alert-danger"><button class="close" data-dismiss="alert" type="button"><i class="fa fa-remove"></i></button>
            <i class="fa fa-remove"></i>
            <strong>E-mail de acesso ou senha não confere.</strong>
        </div>
    </div>
    <%
end if
%>