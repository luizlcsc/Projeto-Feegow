<!--#include file="connect.asp"-->
<%
ConnString43 = "Driver={MySQL ODBC 8.0 ANSI Driver};Server=dbfeegow01.cyux19yw7nw6.sa-east-1.rds.amazonaws.com;Database=cliniccentral;uid=root;pwd=pipoca453;"
Set db43 = Server.CreateObject("ADODB.Connection")
db43.Open ConnString43

ConnString45 = "Driver={MySQL ODBC 8.0 ANSI Driver};Server=dbfeegow02.cyux19yw7nw6.sa-east-1.rds.amazonaws.com;Database=cliniccentral;uid=root;pwd=pipoca453;"
Set db45 = Server.CreateObject("ADODB.Connection")
db45.Open ConnString45

ConnString34 = "Driver={MySQL ODBC 8.0 ANSI Driver};Server=dbfeegow03.cyux19yw7nw6.sa-east-1.rds.amazonaws.com;Database=cliniccentral;uid=root;pwd=pipoca453;"
Set db34 = Server.CreateObject("ADODB.Connection")
db34.Open ConnString34

idInTable = ref("I")
Table = ref("T")
LicencaID = replace(session("Banco"), "clinic", "")

set getUserID = db.execute("select * from sys_users where `Table` like '"&Table&"' and idInTable="&idInTable)
if not getUserID.EOF then
	UserID = getUserID("id")
else
	UserID = ""
end if

if ref("User")<>"" then
	'1. Se ja existe esse email pra outro usuario
	set vca = db43.execute("select * from licencasusuarios where Email like '"&ref("User")&"' and not id = '"&UserID&"' AND LicencaID="&replace(session("Banco"), "clinic", ""))
	if not vca.eof then
		%>
        new PNotify({
            title: 'ERRO',
            text: 'Este e-mail j&aacute; est&aacute; associado a outro usu&aacute;rio.',
            type: 'danger'
        });
        <%
		erro = "S"
	end if
	'2. Se a senha tem no minimo 4 caracteres
	if len(ref("password"))<4 then
		%>
        new PNotify({
            title: 'ERRO',
            text: 'A senha deve conter no m&iacute;nimo 4 caracteres.',
            type: 'danger'
        });
        <%
		erro = "S"
	end if
	'3. Se a senha 2 bate com a senha 1
	if ref("password")<>ref("password2") then
		%>
        new PNotify({
            title: 'ERRO',
            text: 'As senhas digitadas n&atilde;o conferem.',
            type: 'danger'
        });
        <%
		erro = "S"
	end if
	if erro = "" then
		tipo = lcase(Table)
		if tipo="profissionais" then Nome = "NomeProfissional" end if
		if tipo="funcionarios" then Nome = "NomeFuncionario" end if
'		response.Write("select "&Nome&" FROM "&tipo&" WHERE id="&idInTable)
		set pNome = db.execute("select "&Nome&" FROM "&tipo&" WHERE id="&idInTable)
		if not pNome.EOF then
			NomePessoa = rep(trim(pNome(""&Nome&"")&" "))
		end if

	'	if UserID="" AND idInTable<>"" and not isnull(idInTable) and isnumeric(idInTable) then
	'		set vcaInSys=db.execute("select * from sys_users where `Table`='"&lcase(Table)&"' AND idInTable="&idInTable)
	'		if not vcaInSys.EOF then
	'			UserID = idInTable("id")
	'		end if
	'	end if

		if UserID="" then
			db43.execute("insert into licencasusuarios (Nome, Tipo, Email, Senha, LicencaID, Admin, Home) values ('"&NomePessoa&"', '"&Table&"', '"&ref("User")&"', '"&ref("password")&"', '"&LicencaID&"', 0, '"&ref("Home")&"')")
			set pult = db43.execute("select * from licencasusuarios where Email like '"&ref("User")&"' order by id desc")
			set getNomeColuna = db.execute("select * from cliniccentral.sys_financialaccountsassociation where `table` like '"&Table&"'")
			db45.execute("insert into licencasusuarios (id, Nome, Tipo, Email, Senha, LicencaID, Admin, Home) values ("&pult("id")&", '"&NomePessoa&"', '"&Table&"', '"&ref("User")&"', '"&ref("password")&"', '"&LicencaID&"', 0, '"&ref("Home")&"')")
			db34.execute("insert into licencasusuarios (id, Nome, Tipo, Email, Senha, LicencaID, Admin, Home) values ("&pult("id")&", '"&NomePessoa&"', '"&Table&"', '"&ref("User")&"', '"&ref("password")&"', '"&LicencaID&"', 0, '"&ref("Home")&"')")
			db_execute("insert into sys_users (id, `Table`, NameColumn, idInTable, Permissoes) values ("&pult("id")&", '"&Table&"', '"&getNomeColuna("column")&"', '"&idInTable&"', '"&permissoesPadrao()&"')")
		else
			db43.execute("update licencasusuarios set Nome='"&NomePessoa&"', Tipo='"&Table&"', Email='"&ref("User")&"', Senha='"&ref("password")&"', Home='"&ref("Home")&"' where id="&UserID&" and LicencaID="&LicencaID)
			db45.execute("update licencasusuarios set Nome='"&NomePessoa&"', Tipo='"&Table&"', Email='"&ref("User")&"', Senha='"&ref("password")&"', Home='"&ref("Home")&"' where id="&UserID&" and LicencaID="&LicencaID)
			db34.execute("update licencasusuarios set Nome='"&NomePessoa&"', Tipo='"&Table&"', Email='"&ref("User")&"', Senha='"&ref("password")&"', Home='"&ref("Home")&"' where id="&UserID&" and LicencaID="&LicencaID)
		end if
	%>
        new PNotify({
            title: 'Sucesso!',
            text: 'Dados de acesso alterados com sucesso.',
            type: 'success',
            delay: 1000
        });
        $('#msg').html('<div class="badge badge-success">Usu&aacute;rio com acesso ao sistema</div>');
		<%
	end if
else
	'desabilita acesso ao usuario
	set vceAdmin = db43.execute("select * from licencasusuarios where id = '"&UserID&"' and LicencaID="&LicencaID)
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
			db43.execute("update licencasusuarios set Email='', Senha='', Home='"&ref("Home")&"' where id = '"&UserID&"' and LicencaID="&LicencaID)
			db45.execute("update licencasusuarios set Email='', Senha='', Home='"&ref("Home")&"' where id = '"&UserID&"' and LicencaID="&LicencaID)
			db34.execute("update licencasusuarios set Email='', Senha='', Home='"&ref("Home")&"' where id = '"&UserID&"' and LicencaID="&LicencaID)
			%>
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