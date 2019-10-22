<style>
body {
	background-color:#EBEBEB;
}
</style>
<%
response.Charset="iso-8559-1"

session.LCID = 1046
%>

<meta http-equiv="refresh" content="120" />
<h3><%=formatdatetime(now(), 1)%> - <%=time()%></h3>
<!--#include file="centralFunctions.asp"-->
<!--#include file="connectCentral.asp"-->
<!--#include file="SendMail.asp"-->


<%
on error resume next

'Enviando e-mails de agendamentos de amanhã

if time()>cdate("19:00") and 1=1 then
	Set objWinHttp = Server.CreateObject("WinHttp.WinHttpRequest.5.1")
		Identificacao = sms("LicencaID")&"_"&sms("AgendamentoID")
		objWinHttp.Open "GET", "https://clinic.feegow.com.br/feegow_components/api/EmailProfissional"
	objWinHttp.Send
	resposta = objWinHttp.ResponseText
	Set objWinHttp = Nothing
end if
if time()>cdate("19:00") and 1=0 then
	set l = dbc.execute("select id from licencas where (`Status`='C' or (`Status`<>'C' AND FimTeste>=date(now()))) AND (isnull(EnvioAgenda) or EnvioAgenda<date(now()) ) limit 20")
	while not l.EOF
		set vcabd = dbc.execute("select ii.TABLE_SCHEMA FROM information_schema.`TABLES` ii where ii.TABLE_SCHEMA='clinic"&l("id")&"' AND ii.TABLE_NAME='profissionais'")
		if not vcabd.eof then
		%>
		<strong>Agendas de <%=l("id")%></strong><br>
		<%
		set profs = dbc.execute("select p.id, p.NomeProfissional, t.Tratamento, p.Email1, p.Email2 from `clinic"&l("id")&"`.profissionais p LEFT JOIN `clinic"&l("id")&"`.tratamento t on t.id=p.TratamentoID where Ativo='on'")
		while not profs.eof
			EmailsProf = ""
			if not isnull(profs("Email1")) and profs("Email1")<>"" then
				EmailsProf = profs("Email1")
			end if
			if instr(EmailsProf, profs("Email2"))=0 and not isnull(profs("Email2")) and profs("Email2")<>"" then
				EmailsProf = EmailsProf&"|"&profs("Email2")
			end if
			set u = dbc.execute("select lu.Email from `clinic"&l("id")&"`.sys_users su left join licencasusuarios lu on lu.id=su.id where lcase(su.Table)='profissionais' and su.idInTable="&profs("id"))
			if not u.eof then
				if instr(EmailsProf, u("Email"))=0 then
					EmailsProf = EmailsProf&"|"&u("Email")
				end if
			end if
			if EmailsProf <> "" then
				set age = dbc.execute("select a.Data, a.Hora, pac.NomePaciente, proc.NomeProcedimento, a.rdValorPlano, a.ValorPlano, conv.NomeConvenio from `clinic"&l("id")&"`.agendamentos a LEFT JOIN `clinic"&l("id")&"`.pacientes pac on pac.id=a.PacienteID LEFT JOIN `clinic"&l("id")&"`.convenios conv on conv.id=a.ValorPlano LEFT JOIN `clinic"&l("id")&"`.procedimentos proc on proc.id=a.TipoCompromissoID where a.StaID not in(6, 11, 15) and a.ProfissionalID="&profs("id")&" and a.Data=date_add(date(now()), INTERVAL 1 DAY) order by a.Hora")
				if not age.EOF then
					%>
					<%=profs("NomeProfissional")&" - "&EmailsProf%><br>
					<%
					layout = "<div style='background-color:#fff; padding-top:50px; padding-bottom:30px;'><center><img src=""http://clinic.feegow.com.br/assets/img/60_height.png""><br><br><table style='border:#ccc 1px solid' border=0 width=700><h2>Suas consultas para amanh&atilde;</h2>"&_ 
					"<p><br>Boa noite, "&profs("Tratamento")&" "&profs("NomeProfissional")&"! Seguem abaixo seus agendamentos para "&dateadd("d", 1, date())&".<br></p>"
					while not age.eof
						if age("rdValorPlano")="V" then
							'if isnull(age("ValorPlano")) or not isnumeric(age("ValorPlano")) then
								Pagamento = "Particular"
							'else
							'	Pagamento = "R$ "&formatnumber(age("ValorPlano"), 2)
							'end if
						else
							Pagamento = age("NomeConvenio")
						end if
						if isnull(age("Hora")) then
							Hora = ""
						else
							Hora = formatdatetime(age("Hora"), 4)
						end if
						layout = layout & "<tr><td height=30>"&Hora&"</td><td>"&age("NomePaciente")&"</td>"&_ 
						"<td>"&age("NomeProcedimento")&"</td><td><div align=right>"&Pagamento&"</div></td></tr>"
					age.movenext
					wend
					age.close
					set age=nothing
					layout = layout & "</table><br><br><img src=""http://clinic.feegow.com.br/assets/img/rodape.jpg""></center></div><hr>"
					response.Write(layout)

					splEmails = split(EmailsProf, "|")
					for i=0 to ubound(splEmails)
						EmailProfissional = trim(splEmails(i))
						if instr(EmailProfissional, "@")>0 then
							dbc.execute("insert into emailsfila (LicencaID, DataHora, AgendamentoID, Mensagem, Titulo, Email) VALUES (0, NOW(), 0, '"&rep(layout)&"', 'Sua agenda de "&weekdayname(weekday(date()+1))&"', '"&replace(EmailProfissional, "'", "")&"')")
						end if
					next
				end if
			end if
		profs.movenext
		wend
		profs.close
		set profs=nothing
		end if
		dbc.execute("update licencas set EnvioAgenda=date(now()) where id="&l("id"))
	l.movenext
	wend
	l.close
	set l=nothing
end if
%>


<h1>SMS</h1>
<table width="100%" border="1">
<%
if 1=1 then
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
		'objWinHttp.Open "GET", "http://www.mpgateway.com/v_2_00/smspush/enviasms.aspx?CREDENCIAL=D0D1FD26F8553692FB02897FF3C10D9171C76A63&PRINCIPAL_USER=FEEGOWCLINIC&AUX_USER=&MOBILE="&sms("Celular")&"&SEND_PROJECT=N&MESSAGE="&sms("Mensagem"),False
		Identificacao = sms("LicencaID")&"_"&sms("AgendamentoID")
		objWinHttp.Open "GET", "https://webservices.twwwireless.com.br/reluzcap/wsreluzcap.asmx/EnviaSMS?NumUsu=feegow&Senha=fee177&SeuNum="&Identificacao&"&Celular="&sms("Celular")&"&Mensagem="&sms("Mensagem")
	objWinHttp.Send
	resposta = objWinHttp.ResponseText
	Set objWinHttp = Nothing
	dbc.execute("insert into smshistorico (LicencaID, DataHora, AgendamentoID, Mensagem, Resultado, Celular) values ("&sms("LicencaID")&", "&mydatetime(sms("DataHora"))&", "&sms("AgendamentoID")&", '"&rep(sms("Mensagem"))&"', '"&resposta&"', '"&sms("Celular")&"')")
	dbc.execute("delete from smsfila where id="&sms("id"))
	
	ConnStringCLIENTE = "Driver={MySQL ODBC 5.3 ANSI Driver};Server=localhost;Database=clinic"&sms("LicencaID")&";uid=root;pwd=pipoca453;"
	Set dbCLIENTE = Server.CreateObject("ADODB.Connection")
	dbCLIENTE.Open ConnStringCLIENTE
	dbCLIENTE.execute("update agendamentos set ConfSMS='' where id="&sms("AgendamentoID"))
	dbCLIENTE.close
	set dbCLIENTE=nothing
sms.movenext
wend
sms.close
set sms=nothing
end if
%>
</table>

<h1>EMAIL</h1>
<table width="100%" border="1">
<%
if 1=1 then
set emails = dbc.execute("select * from emailsfila where DataHora<"&mydatetime(now())&" order by id desc")
while not emails.eof
	urlConfirmacao = "https://clinic.feegow.com.br/?P=Confirmacao&L="&emails("LicencaID")&"&A="&emails("AgendamentoID")&"&R="
	Mensagem = emails("Mensagem")
	Mensagem = replace(Mensagem, "[Confirmacao.Mensagem]", " <h4>Deseja confirmar este agendamento? <a href="""&urlConfirmacao&"&CONFIRMA"">CLIQUE AQUI PARA CONFIRMAR</a> ou <a href="""&urlConfirmacao&"&CANCELA"">CLIQUE AQUI PARA CANCELAR</a></h4>")
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
	
	ConnStringCLIENTE = "Driver={MySQL ODBC 5.3 ANSI Driver};Server=localhost;Database=clinic"&emails("LicencaID")&";uid=root;pwd=pipoca453;"
	Set dbCLIENTE = Server.CreateObject("ADODB.Connection")
	dbCLIENTE.Open ConnStringCLIENTE
	dbCLIENTE.execute("update agendamentos set ConfEmail='' where id="&emails("AgendamentoID"))
	dbCLIENTE.close
	set dbCLIENTE=nothing

emails.movenext
wend
emails.close
set emails=nothing
end if
%>
</table>