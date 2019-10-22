<!--#include file="connect.asp"-->
<%
Server.ScriptTimeout = 1800

set ages = db.execute("select * from googleagenda where ProfissionalID="&req("ProfissionalID"))
while not ages.EOF
	call googleCalendar("X", "", ages("AgendamentoID"), "", "", "", "", "", "", "")
ages.movenext
wend
ages.close
set ages=nothing

if ref("Integrar")="S" then
	db_execute("update profissionais set GoogleCalendar='"&ref("GoogleCalendar")&"' where id="&req("ProfissionalID"))

	set age = db.execute("select count(id)NumeroAgendamentos, a.*, p.NomePaciente, proc.NomeProcedimento from agendamentos a LEFT JOIN pacientes p on a.PacienteID=p.id LEFT JOIN procedimentos proc on proc.id=a.TipoCompromissoID where a.ProfissionalID="&req("ProfissionalID")&" and a.Data>=date(now()) AND a.Data <= date_add(CURDATE(), INTERVAL 1 year)")
	if age("NumeroAgendamentos")>1000 then
	    set age = db.execute("select count(id)NumeroAgendamentos, a.*, p.NomePaciente, proc.NomeProcedimento from agendamentos a LEFT JOIN pacientes p on a.PacienteID=p.id LEFT JOIN procedimentos proc on proc.id=a.TipoCompromissoID where a.ProfissionalID="&req("ProfissionalID")&" and a.Data>=date(now()) AND a.Data <= date_add(CURDATE(), INTERVAL 1 month)")
	end if
	while not age.eof
		'response.Write(age("id"))
		call googleCalendar("I", ref("GoogleCalendar"), age("id"), req("ProfissionalID"), age("NomePaciente"), age("Data"), age("Hora"), age("Tempo"), age("NomeProcedimento"), age("Notas"))
	age.movenext
	wend
	age.close
	set age = nothing
	%>
    new PNotify({
        title: 'Sucesso!',
        text: 'Integração conectada.',
        type: 'success',
        delay: 1500
    });
	<%
else
	db_execute("update profissionais set GoogleCalendar='' where id="&req("ProfissionalID"))
	%>
    new PNotify({
        title: 'Sucesso!',
        text: 'Integração desconectada.',
        type: 'success',
        delay: 1500
    });
	<%
end if
%>