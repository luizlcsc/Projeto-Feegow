<!--#include file="connect.asp"-->	
<!--#include file="connectCentral.asp"-->
<!--#include file="Classes/AgendamentoValidacoes.asp"-->

<%

if request.ServerVariables("REMOTE_ADDR")<>"::1" then
    on error resume next
end if

ProfissionalID = req("ProfissionalID")
EquipamentoID = req("EquipamentoID")
LocalID = req("LocalID")
Data = req("Data")
Hora = req("Hora")
Acao = req("Acao")
AgendamentoID = req("AgendamentoID")
ProfissionalNaoInformado=False

isAgendaEquipamento = req("tipoAgendamento")


if ProfissionalID="" then
    ProfissionalNaoInformado=True
end if

if ProfissionalNaoInformado then
    set AgendamentoSQL = db.execute("SELECT ProfissionalID FROM agendamentos WHERE id="&AgendamentoID)
    if not AgendamentoSQL.eof then
        ProfissionalID=AgendamentoSQL("ProfissionalID")
    end if
end if
if isdate(Data) then
	DiaSemana = weekday(Data)
end if

if LocalID="Search" then
	set vcaAss = db.execute("select * from assfixalocalxprofissional where ProfissionalID="&ProfissionalID&" and DiaSemana="&DiaSemana&" and HoraDe<="&mytime(Hora)&" and HoraA>="&mytime(Hora))
	if not vcaAss.EOF then
		LocalID = vcaAss("LocalID")
	else
		set vcaAss = db.execute("select * from assfixalocalxprofissional where ProfissionalID="&ProfissionalID&" and DiaSemana="&DiaSemana)
		if not vcaAss.EOF then
			LocalID = vcaAss("LocalID")
		end if
	end if
end if

if Acao="Solicitar" then
	set AgendamentoSet = db.execute("SELECT StaID in (3) executado FROM agendamentos WHERE id="&AgendamentoID)

	IF NOT AgendamentoSet.EOF THEN
	    IF AgendamentoSet("executado") THEN
	    %>
            showMessageDialog("Este agendamento já se encontra finalizado", "danger")
        <%
        response.end
        END IF
	END IF

	session("RemSol")=AgendamentoID
    redirectID = ProfissionalID
	if isAgendaEquipamento = "equipamento" then
        redirectID = EquipamentoID
    end if

	%>
	loadAgenda('<%=Data%>', <%=redirectID%>);
    af('f');
	<%
end if
if Acao="Cancelar" then
	session("RemSol")=""
    redirectID = ProfissionalID
	if isAgendaEquipamento = "equipamento" then
        redirectID = EquipamentoID
    end if
	%>
	loadAgenda('<%=Data%>', <%=redirectID%>);
	<%
end if


if Acao="Remarcar" then
    Encaixe=0

    set AgendamentoSQL = db.execute("SELECT especialidadeid,tipocompromissoid, localid ,Hora, HoraFinal, Tempo, EquipamentoID, IF(rdValorPlano='P',ValorPlano,0) ConvenioID FROM agendamentos WHERE id="&session("RemSol"))
    if LocalID="Search" then
        LocalID = AgendamentoSQL("localid")
    end if 
    
    rfTempo = AgendamentoSQL("Tempo")
    AgendamentoID=session("RemSol")
    ConvenioID=AgendamentoSQL("ConvenioID")
    EspecialidadeID=AgendamentoSQL("especialidadeid")
    ProcedimentoID=AgendamentoSQL("tipocompromissoid")

    if EquipamentoID="" then
        EquipamentoID=AgendamentoSQL("EquipamentoID")
    end if

    if isNumeric(rfTempo) and not rfTempo="" then TempoSol=rfTempo else TempoSol=0 end if
    HoraSolIni=cDate(hour(Hora)&":"&minute(Hora))
    HoraSolFin=dateAdd("n",TempoSol,HoraSolIni)
    HoraSolFin=cDate(hour(HoraSolFin)&":"&minute(HoraSolFin))

    sql = "SELECT total_agendamentos >= max_agendamentos AS nao_pode_agendar FROM (SELECT COUNT(*) AS total_agendamentos, IF(procedimentos.MaximoAgendamentos='' or procedimentos.MaximoAgendamentos Is null, 1, procedimentos.MaximoAgendamentos) AS max_agendamentos from agendamentos LEFT JOIN procedimentos ON procedimentos.id = agendamentos.TipoCompromissoID where StaID not in (11,15) AND ProfissionalID = "&treatvalzero(ProfissionalID)&" and ProfissionalID<>0 and Data = "&mydatenull(Data)&" and ((Hora>time('"&hour(HoraSolIni)&":"&minute(HoraSolIni)&"') and Hora < time('"&HoraSolFin&"') and Encaixe IS NULL and HoraFinal>time('"&hour(HoraSolIni)&":"&minute(HoraSolIni)&"')) or Hora="&mytime(HoraSolIni)&")   GROUP BY 2) AS t HAVING nao_pode_agendar = 1"
        
    set ve1=db.execute(sql)
    if not ve1.eof then
        check = ve1("nao_pode_agendar")
        if check = "1" then
            erro="Erro: O horário solicitado não dispõe do tempo requerido (entre "&HoraSolIni&" e "&HoraSolFin&") para o agendamento deste procedimento."
        end if
    end if

    if erro="" then

        sql = "select id from agendamentos where ProfissionalID = "&treatvalzero(ProfissionalID)&" and ProfissionalID<>0 and Data = "&mydatenull(Data)&" and (Hora<=time('"&hour(HoraSolIni)&":"&minute(HoraSolIni)&"') and HoraFinal>time('"&hour(HoraSolIni)&":"&minute(HoraSolIni)&"')) and Encaixe IS NULL"

        set EncaixeSQL = db.execute(sql)

        if not EncaixeSQL.eof then
            Encaixe=1
        end if

        if Encaixe="1" and erro="" then
            set MaximoEncaixesSQL = db.execute("select MaximoEncaixes, (select count(id) from agendamentos where ProfissionalID="&ProfissionalID&" and Encaixe=1 and Data="&mydatenull(Data)&" and id!='"&session("RemSol")&"') NumeroEncaixes from profissionais where id="&ProfissionalID&" and not isnull(MaximoEncaixes)")

            if not MaximoEncaixesSQL.eof then
                NumeroEncaixes = ccur(MaximoEncaixesSQL("NumeroEncaixes"))+1
                MaximoEncaixes = ccur(MaximoEncaixesSQL("MaximoEncaixes"))
                if NumeroEncaixes>MaximoEncaixes then
                    erro = "Número máximo de encaixes atingido.."
                end if
            end if

        end if
    end if
    if ConvenioID&"" <> "0" then
        if erro = "" then
            erro = erro & ValidaLocalConvenio("1",ConvenioID,LocalID)
        end if

        if erro = "" then
            sqlGrade = "SELECT id GradeID, Especialidades, Procedimentos,Convenios, LocalID FROM (SELECT ass.id, Especialidades, Procedimentos, LocalID,Convenios FROM assfixalocalxprofissional ass  WHERE ProfissionalID="&treatvalzero(ProfissionalID)&" AND DiaSemana=dayofweek("&mydatenull(Data)&") AND "&mytime(Hora)&" BETWEEN HoraDe AND HoraA AND ((InicioVigencia IS NULL OR InicioVigencia <= "&mydatenull(Data)&") AND (FimVigencia IS NULL OR FimVigencia >= "&mydatenull(Data)&")) UNION ALL SELECT ex.id*-1 id, Especialidades, Procedimentos, LocalID,Convenios FROM assperiodolocalxprofissional ex LEFT JOIN locais loc ON loc.id=ex.LocalID WHERE ProfissionalID="&ProfissionalID&" AND DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&")t"
            
            set validaRemarcar = db.execute(sqlGrade)
            if not validaRemarcar.eof then
                vLimitarConvenios = validaRemarcar("convenios")&""
                if vLimitarConvenios <>"" then
                    if instr(vLimitarConvenios, "|"&ConvenioID&"|")<=0 then
                        erro = erro&" Grade não aceita o convênio deste agendamento\n"
                    end if
                end if
                vLimitarEspecialidade = validaRemarcar("Especialidades")&""
                if vLimitarEspecialidade <>"" then
                    if instr(vLimitarEspecialidade, "|"&EspecialidadeID&"|")<=0 then
                        erro = erro&" Grade não aceita a especialidade deste agendamento\n"
                    end if
                end if
                vLimitarProcedimento = validaRemarcar("Procedimentos")&""
                if vLimitarProcedimento <>"" then
                    if instr(vLimitarProcedimento, "|"&ProcedimentoID&"|")<=0 then
                        erro = erro&" Grade não aceita o procedimento deste agendamento\n"
                    end if
                end if
            end if
        end if
    end if

    if erro="" then
        sql = "update agendamentos set EquipamentoID="&treatvalnull(EquipamentoID)&", Data="&mydatenull(Data)&", Hora="&mytime(Hora)&", ProfissionalID="&treatvalzero(ProfissionalID)&", LocalID="&treatvalzero(LocalID)&", Encaixe="&Encaixe&" where id="&session("RemSol")

        db_execute(sql)
    '	response.Write("select ConfSMS, ConfEmail from agendamentos where id="&session("RemSol"))

        set age = db.execute("select ConfSMS, ConfEmail,PacienteID,TipoCompromissoID from agendamentos where id="&session("RemSol"))
        if not age.eof then
            sql = "INSERT INTO logsmarcacoes (DataHoraFeito,Sta,Motivo, PacienteID, ProfissionalID, ProcedimentoID,Data,Hora,Usuario,ARX,ConsultaID,Obs, UnidadeID) VALUES ('"&now()&"',15,0,"&age("PacienteID")&","&treatvalzero(ProfissionalID)&","&age("TipoCompromissoID")&","&mydatenull(Data)&","&mytime(Hora)&","&session("User")&", 'R',"&session("RemSol")&",'Remarcado', "&treatvalzero(session("UnidadeID"))&")"
            'response.write(sql)
            db.execute(sql)
            'call centralSMS(age("ConfSMS"), Data, Hora, session("RemSol"))
            'call centralEmail(age("ConfEmail"), Data, Hora, session("RemSol"))
            call googleCalendar("X", "", session("RemSol"), "", "", "", "", "", "", "")
            call googleCalendar("I", "vca", session("RemSol"), ProfissionalID, "", "", "", "", "", "")
        end if
        session("RemSol")=""
        redirectID = ProfissionalID
        if isAgendaEquipamento = "equipamento" then
            redirectID = EquipamentoID
        end if
 
        %>
        //alert('<%=replace(sql, "'", "\'")%>');
        getUrl("patient-interaction/get-appointment-events", {appointmentId: "<%=AgendamentoID%>",sms: true,email:true })
        loadAgenda('<%=Data%>', <%=redirectID%>);
        <%
    else
    %>
    showMessageDialog('<%= erro %>')
    <%
    end if
end if
%>