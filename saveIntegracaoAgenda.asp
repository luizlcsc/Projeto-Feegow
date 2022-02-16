<!--#include file="connect.asp"-->
<%
Server.ScriptTimeout = 1800

if 1 then
    set ages = db.execute("select g.* from googleagenda g LEFT JOIN agendamentos a ON a.id = g.AgendamentoID where g.ProfissionalID="&req("ProfissionalID")&" AND a.Hora IS NOT NULL AND a.Data >= CURDATE()")
    while not ages.EOF
        call googleCalendar("X", "", ages("AgendamentoID"), "", "", "", "", "", "", "")
    ages.movenext
    wend
    ages.close
    set ages=nothing
end if

if ref("Integrar")="S" then
	db_execute("update profissionais set GoogleCalendar='"&ref("GoogleCalendar")&"' where id="&req("ProfissionalID"))

    set NumeroAgendamentosSQL = db.execute("SELECT count(a.id)NumeroAgendamentos FROM agendamentos a where a.ProfissionalID="&req("ProfissionalID")&" and a.Data>=date(now()) AND a.Data <= date_add(CURDATE(), INTERVAL 1 year)")
	set age = db.execute("select a.*, p.NomePaciente, proc.NomeProcedimento from agendamentos a LEFT JOIN pacientes p on a.PacienteID=p.id LEFT JOIN procedimentos proc on proc.id=a.TipoCompromissoID where a.ProfissionalID="&req("ProfissionalID")&" and a.Data>=date(now()) AND a.Data <= date_add(CURDATE(), INTERVAL 1 year)")
	if not age.eof then
	    if NumeroAgendamentosSQL("NumeroAgendamentos")&"" <> "" then
	        if ccur(NumeroAgendamentosSQL("NumeroAgendamentos"))>1000 then
	            set age = db.execute("select a.*, p.NomePaciente, proc.NomeProcedimento from agendamentos a LEFT JOIN pacientes p on a.PacienteID=p.id LEFT JOIN procedimentos proc on proc.id=a.TipoCompromissoID where a.ProfissionalID="&req("ProfissionalID")&" and a.Data>=date(now()) AND a.Data <= date_add(CURDATE(), INTERVAL 1 month)")
	        end if
	    end if
	end if
	i=0
	while not age.eof
	    i=i+1
	    'fazer aq fuso horario reverso
        'FusoHorario=3
        'HorarioVerao="S"

        if isHorarioVerao() then
            if not isnull(age("LocalID")) then
                set UnidadeSQL = db.execute("SELECT UnidadeID FROM locais WHERE id="&age("LocalID"))
                UnidadeID=0

                if not UnidadeSQL.eof then
                    if UnidadeSQL("UnidadeID")&"" <> "" then
                        UnidadeID = UnidadeSQL("UnidadeID")
                    end if
                end if

                set UnidadeConfigSQL = db.execute("SELECT FusoHorario, HorarioVerao FROM (SELECT 0 id, FusoHorario, HorarioVerao FROM empresa WHERE id=1 UNION ALL SELECT id, FusoHorario, HorarioVerao FROM sys_financialcompanyunits WHERE sysActive=1)t WHERE t.id="&UnidadeID)
                if not UnidadeConfigSQL.eof then
                    if UnidadeConfigSQL("HorarioVerao")&"" <> "" then
                        HorarioVerao=UnidadeConfigSQL("HorarioVerao")
                        FusoHorario=UnidadeConfigSQL("FusoHorario")

                        if not isnumeric(FusoHorario) or FusoHorario="0" then
                            FusoHorario=3
                        else
                            FusoHorario = FusoHorario * -1
                        end if
                    end if
                end if
            end if
        end if
        Hora = age("Hora")

        Hora = dateadd("h", FusoHorario,age("Hora"))

        if HorarioVerao="S" then
            Hora = dateadd("h", -1,age("Hora"))
        end if


		'response.Write(age("id"))
		call googleCalendar("I", ref("GoogleCalendar"), age("id"), req("ProfissionalID"), age("NomePaciente"), age("Data"), Hora, age("Tempo"), age("NomeProcedimento"), age("Notas"))
	age.movenext
	wend
	age.close
	set age = nothing
	%>
    new PNotify({
        title: 'Sucesso!',
        text: 'Integração conectada. <%=i%> agendamento(s) enviados.',
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