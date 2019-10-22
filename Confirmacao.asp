<!--#include file="connectCentral.asp"-->
<center>
<h1>
CONFIRMA&Ccedil;&Atilde;O DE CONSULTA: </h1>
<h3 style="color:#6E6E6E"><strong>
<%
session.LCID = 1046
LicencaID =  replace(request.QueryString("L"), "'", "")
AgendamentoID =  replace(request.QueryString("A"), "'", "")
R =  replace(request.QueryString(), "'", "")
set lic = dbc.execute("select * from licencas where id = '"&LicencaID&"' and isnull(Excluido) limit 1")
if not lic.eof then
	set age = dbc.execute("select * from clinic"&LicencaID&".agendamentos where id = '"&AgendamentoID&"' limit 1")
	if not age.EOF then
		DataHora = cdate(age("Data")&" "&formatdatetime(age("Hora"),3))
		if DataHora<now() then
			%>
			Voc&ecirc; n&atilde;o pode confirmar ou desmarcar consultas em hor&aacute;rios passados.
			<%
		else
			if instr(R, "CONFIRMA")>0 then
				resposta = "Confirmado via E-MAIL."
				dbc.execute("update clinic"&LicencaID&".agendamentos set StaID=7 where id="&AgendamentoID)
				%>
                CONSULTA CONFIRMADA COM SUCESSO!!!
                <%
			end if
			if instr(R, "CANCELA") then
				set vcaCancel = dbc.execute("select * from clinic"&LicencaID&".staconsulta where id=11")
				if vcaCancel.eof then
					dbc.execute("insert into clinic"&LicencaID&".staconsulta (id, StaConsulta) values (11, 'Desmarcado pelo paciente')")
				end if
				resposta = "Desmarcado via E-MAIL."
				dbc.execute("update clinic"&LicencaID&".agendamentos set StaID=11 where id="&AgendamentoID)
				%>
				CONSULTA DESMARCADA COM SUCESSO!!!
				<%
			end if
			if resposta<>"" then
				dbc.execute("insert into clinic"&LicencaID&".agendamentosrespostas (AgendamentoID, Resposta, DataHora) values ("&AgendamentoID&", '"&resposta&"', NOW() )")
				dbc.execute("insert into cliniccentral.emailsmohistorico (mensagem, AgendamentoID, LicencaID) values ('"&resposta&"', "&AgendamentoID&", "&LicencaID&")")
			end if
		end if
	end if
end if
%>
</strong></h3>
</center>