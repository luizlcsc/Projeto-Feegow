<%
response.Charset="iso-8559-1"
%>
<meta http-equiv="refresh" content="20" />
<h3><%=formatdatetime(now(), 1)%> - <%=time()%></h3>
<!--#include file="centralFunctions.asp"-->
<!--#include file="connectCentral.asp"-->
<!--#include file="SendMail.asp"-->
<h1>SMS</h1>
<table width="100%" border="1">
<%
set sms = dbc.execute("select * from smsfila where DataHora<"&mydatetime(now()))
while not sms.eof
	%>
	<tr>
    	<td><%=sms("LicencaID")%></td>
    	<td><%=sms("DataHora")%></td>
    	<td><%=sms("AgendamentoID")%></td>
    	<td><%=sms("Mensagem")%></td>
    	<td><%=sms("Celular")%></td>
    </tr>
	<%
	Set objWinHttp = Server.CreateObject("WinHttp.WinHttpRequest.5.1")
		objWinHttp.Open "GET", "http://www.mpgateway.com/v_2_00/smspush/enviasms.aspx?CREDENCIAL=D0D1FD26F8553692FB02897FF3C10D9171C76A63&PRINCIPAL_USER=FEEGOWCLINIC&AUX_USER=&MOBILE="&sms("Celular")&"&SEND_PROJECT=N&MESSAGE="&sms("Mensagem"),False
	objWinHttp.Send
	resposta = objWinHttp.ResponseText
	Set objWinHttp = Nothing
	dbc.execute("insert into smshistorico (LicencaID, DataHora, AgendamentoID, Mensagem, Resultado, Celular) values ("&sms("LicencaID")&", "&mydatetime(sms("DataHora"))&", "&sms("AgendamentoID")&", '"&rep(sms("Mensagem"))&"', '"&resposta&"', '"&sms("Celular")&"')")
	dbc.execute("delete from smsfila where id="&sms("id"))
	
	ConnStringCLIENTE = "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database=clinic"&sms("LicencaID")&";uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
	Set dbCLIENTE = Server.CreateObject("ADODB.Connection")
	dbCLIENTE.Open ConnStringCLIENTE
	dbCLIENTE.execute("update agendamentos set ConfSMS='' where id="&sms("AgendamentoID"))
	dbCLIENTE.close
	set dbCLIENTE=nothing

sms.movenext
wend
sms.close
set sms=nothing
%>
</table>

<h1>EMAIL</h1>
<table width="100%" border="1">
<%
set emails = dbc.execute("select * from emailsfila where DataHora<"&mydatetime(now())&" order by id desc")
while not emails.eof
	Mensagem = emails("Mensagem")
	%>
	<tr>
    	<td><%=emails("LicencaID")%></td>
    	<td><%=emails("DataHora")%></td>
    	<td><%=emails("AgendamentoID")%></td>
    	<td><%=left(Mensagem, 40)%></td>
    	<td><%=emails("Email")%></td>
    </tr>
	<%
	
	call SendMail(emails("Email"), emails("Titulo"), Mensagem)
	
	dbc.execute("insert into emailshistorico (LicencaID, DataHora, AgendamentoID, Mensagem, Titulo, Resultado, Email) values ("&emails("LicencaID")&", "&mydatetime(emails("DataHora"))&", "&emails("AgendamentoID")&", '"&rep(Mensagem)&"', '"&rep(emails("Titulo"))&"', '', '"&emails("Email")&"')")
	dbc.execute("delete from emailsfila where id="&emails("id"))
	
	ConnStringCLIENTE = "Driver={MySQL ODBC 5.2 ANSI Driver};Server=localhost;Database=clinic"&emails("LicencaID")&";uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
	Set dbCLIENTE = Server.CreateObject("ADODB.Connection")
	dbCLIENTE.Open ConnStringCLIENTE
	dbCLIENTE.execute("update agendamentos set ConfEmail='' where id="&emails("AgendamentoID"))
	dbCLIENTE.close
	set dbCLIENTE=nothing

emails.movenext
wend
emails.close
set emails=nothing
%>
</table>