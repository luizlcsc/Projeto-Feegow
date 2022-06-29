<!--#include file="connect.asp"-->
<!--#include file="Classes/ExecuteAllServers.asp"-->
<!--#include file="Classes/Connection.asp"-->
<!--#include file="Classes/Senhas.asp"-->
<!--#include file="connectCentral.asp"-->
<!--#include file="Classes/eventEmitter.asp"-->
<%

idInTable = ref("I")
Table = ref("T")
LicencaID = replace(session("Banco"), "clinic", "")
Acao = ref("Acao")
Home = ref("Home")

AlterarSenhaAoLogin = 0
Password = ref("password")
PasswordSalt = getEnv("FC_PWD_SALT", "SALT_")

if ref("AlterarSenhaAoLogin") <>"" then
	AlterarSenhaAoLogin = 1
end if 

set getUserID = db.execute("select id from sys_users where `Table` = '"&Table&"' and idInTable="&idInTable)
if not getUserID.EOF then
	UserID = getUserID("id")
else
	UserID = ""
end if

if ref("User")<>"" then
	'1. Se ja existe esse email pra outro usuario
	set vca = dbc.execute("select id from licencasusuarios where Email = '"&ref("User")&"' and not id = '"&UserID&"' AND LicencaID="&LicencaID)

	if not vca.eof then
		%>
        showMessageDialog('Este e-mail j&aacute; est&aacute; associado a outro usu&aacute;rio.');
        <%
		erro = "S"
	end if

    mensagemErroSenha = validaCriteriosSenha(ref("password"), ref("password2"))

	if mensagemErroSenha<>"" then
		%>
        showMessageDialog('<%=mensagemErroSenha%>');
        <%
		erro = "S"
	end if

	if erro = "" then
		tipo = lcase(Table)
		if tipo="profissionais" then Nome = "NomeProfissional" end if
		if tipo="funcionarios" then Nome = "NomeFuncionario" end if

		set pNome = db.execute("select "&Nome&" FROM "&tipo&" WHERE id="&idInTable)
		if not pNome.EOF then
			NomePessoa = rep(trim(pNome(""&Nome&"")&" "))
		end if

		if UserID="" then
			dbc.execute("replace into licencasusuarios (Nome, Tipo, Email, Senha, LicencaID, Admin, Home) values ('"&NomePessoa&"', '"&Table&"', '"&ref("User")&"', '"&ref("password")&"', '"&LicencaID&"', 0, '"&Home&"')")
			sqlEvent = "insert into licencasusuarios (Nome, Tipo, Email, Senha, LicencaID, Admin, Home) values ('"&NomePessoa&"', '"&Table&"', '"&ref("User")&"', '"&ref("password")&"', '"&LicencaID&"', 0, '"&Home&"')"
			set pult = dbc.execute("select * from licencasusuarios where Email = '"&ref("User")&"' order by id desc LIMIT 1")
			UserID = pult("id")
			
			call eventEmitter(125, sqlEvent, UserID)
			set getNomeColuna = db.execute("select * from cliniccentral.sys_financialaccountsassociation where `table` = '"&Table&"'")

			sqlinsert = "replace into licencasusuarios (id, Nome, Tipo, Email, VersaoSenha, SenhaCript, Senha, LicencaID, Admin, Home) "&_
			            "values "&_
			            "("&UserID&", '"&NomePessoa&"', '"&Table&"', '"&ref("User")&"', 3, SHA1('"&PasswordSalt&Password&"'), NULL, '"&LicencaID&"', 0, '"&Home&"')"

			call ExecuteAllServers(sqlInsert)
			'local
			db_execute("replace into sys_users (id, `Table`, NameColumn, idInTable, Permissoes) values ("&pult("id")&", '"&Table&"', '"&getNomeColuna("column")&"', '"&idInTable&"', '"&permissoesPadrao()&"')")
		else
            session("AlterarSenha") = 0

			if Acao= "Redefinir" then
				sqlupdate = "update cliniccentral.licencasusuarios set Ativo=1, Senha=NULL, VersaoSenha=3, SenhaCript=SHA1('"&PasswordSalt&Password&"'), AlterarSenhaAoLogin=0 " &_
				            "where id="&UserID&" and LicencaID="&LicencaID

				call ExecuteAllServers(sqlupdate)
			else
				sqlupdate = "update cliniccentral.licencasusuarios set Ativo=1, Nome='"&NomePessoa&"', Tipo='"&Table&"', Email='"&ref("User")&"', " &_
				            "Senha=NULL, VersaoSenha=3, SenhaCript=SHA1('"&PasswordSalt&Password&"'), " &_
				            "Home='"&Home&"', AlterarSenhaAoLogin="&AlterarSenhaAoLogin&" where id="&UserID&" and LicencaID="&LicencaID
                call ExecuteAllServers(sqlUpdate)
			end if

            dbc.execute("INSERT INTO cliniccentral.licencasusuariossenhas (LicencaID,UsuarioID,Senha) VALUES ("&LicencaID&", "&UserID&", SHA1('" & PasswordSalt & Password &"'))")
		end if
	%>


		gtag('event', 'acesso_concedido', {
			'event_category': 'dados_de_acesso',
			'event_label': "Dados de acesso > conceder e-mail e senha",
		});

        new PNotify({
            title: 'Sucesso!',
            text: 'Dados de acesso alterados com sucesso.',
            type: 'success',
            delay: 1000
        });
        $('#msg').html('<div class="badge badge-success">Usu&aacute;rio com acesso ao sistema</div>');
		if($("#modal-alterar-senha").length > 0){
		    $("#modal-alterar-senha").modal("hide");
		}
		<%
	end if
else
	'desabilita acesso ao usuario
	set vceAdmin = dbc.execute("select id, Admin from licencasusuarios where id = '"&UserID&"' and LicencaID="&LicencaID)
	if not vceAdmin.EOF then
		if vceAdmin("Admin")=1 then
			%>
				new PNotify({
					title: 'ERRO',
					text: 'Voc&ecirc; n&atilde;o pode desabilitar acesso do usu&aacute;rio administrador.',
					type: 'danger',
                    delay: 3000
				});
			<%
		else
			sqlupdate = "update licencasusuarios set Email=null,Senha=null,Ativo=0, Home='"&Home&"' where id = '"&UserID&"' and LicencaID="&LicencaID
			call ExecuteAllServers(sqlupdate)

			%>

				gtag('event', 'acesso_desabilitado', {
					'event_category': 'dados_de_acesso',
					'event_label': "Dados de acesso > remover e-mail",
				});

				new PNotify({
					title: 'Sucesso!',
					text: 'Acesso ao sistema desabilitado',
					type: 'success',
                    delay: 2000
				});
				$('#msg').html('<div class="badge badge-danger">Usu&aacute;rio sem acesso ao sistema</div>');
			<%
		end if
	end if
end if
%>
<!--#include file="disconnect.asp"-->