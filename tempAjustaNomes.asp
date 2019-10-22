<!--#include file="connect.asp"-->
<%
'on error resume next 1946, 1051, 1995, 2228

response.Charset="utf-8"

set nulls = db.execute("select * from cliniccentral.licencasusuarios where LicencaID NOT IN(1051) order by LicencaID")
while not nulls.eof
	Tabela = ""
	
	%>
	<%=nulls("LicencaID")%> - 
	<%=nulls("Email")%> - 
	<%
	set vcaBanco = db.execute("select * from information_schema.schemata where schema_name='clinic"&nulls("LicencaID")&"'")
	if vcaBanco.EOF then
		%>
		<span style="color:red"><em>Banco apagado</em></span>
        <%
	else
		set pUser = db.execute("select * from clinic"&nulls("LicencaID")&".sys_users where id="&nulls("id"))
		if not pUser.eof then
			Tabela = pUser("Table")
			Coluna = pUser("NameColumn")
			%>
			<%=Tabela%> - <%=Coluna%> - 
			<%
			set pNome = db.execute("select "&Coluna&" from clinic"&nulls("LicencaID")&"."&Tabela&" where id="&pUser("idInTable"))
			if not pNome.EOF then
				Nome = pNome(""&Coluna&"")
				%>
				<%=Nome%>
				<%
				db_execute("update cliniccentral.licencasusuarios set Nome='"&rep(Nome)&"', Tipo='"&Tabela&"' where id="&pUser("id"))
			end if
		end if
	end if
	%><br><%
nulls.movenext
wend
nulls.close
set nulls=nothing
%>