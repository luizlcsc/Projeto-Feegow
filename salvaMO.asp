<!--#include file="connect.asp"-->
<%
response.Charset="utf-8"

on error resume next

set moPend = db.execute("select * from cliniccentral.smsmo")
while not moPend.eof
	spl = split(moPend("seunum"), "_")
	LicencaID = spl(0)
	AgendamentoID = spl(1)
	resposta = trim(moPend("mensagem"))
	mensagem = lcase(resposta)
	if LicencaID<>"0" and LicencaID<>0 and LicencaID<>"" then
		if mensagem="sim" or mensagem="confirm" or mensagem="comfirma" or mensagem="cofirma" or mensagem="confirma" or mensagem="confirmar" or mensagem="confirmado" then
			resposta = "Confirmado via SMS."
			db_execute("update clinic"&LicencaID&".agendamentos set StaID=7 where id="&AgendamentoID)
		elseif mensagem="nao" or mensagem="não" or mensagem="cancelar" or mensagem="cancela" or mensagem="camcela" or mensagem="cansela" or mensagem="desmarcar" then
			set vcaCancel = db.execute("select * from clinic"&LicencaID&".staconsulta where id=11")
			if vcaCancel.eof then
				db_execute("insert into clinic"&LicencaID&".staconsulta (id, StaConsulta) values (11, 'Desmarcado pelo paciente')")
			end if
			resposta = "Desmarcado via SMS."
			db_execute("update clinic"&LicencaID&".agendamentos set StaID=11 where id="&AgendamentoID)
		end if
		datarec = left(moPend("datarec"), 19)
		datarec = replace(datarec, "T", " ")
		'2015-07-19T23:03:44.16-03:00
		db_execute("insert into clinic"&LicencaID&".agendamentosrespostas (AgendamentoID, Resposta, DataHora) values ("&AgendamentoID&", '"&rep(resposta)&"', '"&datarec&"')")
		db_execute("insert into cliniccentral.smsmohistorico (select * from cliniccentral.smsmo where id="&moPend("id")&")")
	end if
	db_execute("delete from cliniccentral.smsmo where id="&moPend("id"))
moPend.movenext
wend
moPend.close
set moPend = nothing
response.Redirect("RecebeSMS.php")
%>