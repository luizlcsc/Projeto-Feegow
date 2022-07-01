<%
if session("Partner")<>"" then
	session("Banco")="clinic"&req("I")
	%>
	<!--#include file="connectCentral.asp"-->
	<%
	set LicencaSQL = dbc.execute("SELECT Servidor FROM licencas where id="&req("I"))

    Servidor = LicencaSQL("Servidor")
    session("Servidor") = Servidor

    response.write(Servidor)

    %>
    <!--#include file="connect.asp"-->
    <%

	dbc.execute("update cliniccentral.licencasusuariosmulti set LicencaAtual="&req("I")&" where id="&( session("User")*(-1) ))
	set getUnidades = db.execute("select group_concat('|', id, '|') Unidades from sys_financialcompanyunits")
	session("Unidades") = "|0|" & getUnidades("Unidades")
	session("UnidadeID") = 0


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


	set outrosUsers = db.execute("select * from sys_users")
	while not outrosUsers.eof
		session("UsersChat") = session("UsersChat")&"|"&outrosUsers("id")&"|"'colocando A só pra simular aberto depois tira o A
	outrosUsers.movenext
	wend
	outrosUsers.close
	set outrosUsers=nothing

	db_execute("update atendimentos set HoraFim=( select time(UltRef) from sys_users where id="&session("User")&" ) where isnull(HoraFim) and sysUser="&session("User")&" order by id desc limit 1")

	response.Redirect("./?P=Agenda-1&Pers=1")
end if
%>