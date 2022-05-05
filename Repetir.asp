<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<!--#include file="AgendamentoUnificado.asp"-->
<%
on error resume next


ProfissionalID = req("ProfissionalID")
EquipamentoID = req("EquipamentoID")
LocalID = req("LocalID")
Data = req("Data")
Hora = req("Hora")
Acao = req("Acao")
AgendamentoID = req("AgendamentoID")
DiaSemana = weekday(Data)

'equipamento ou profissional
isAgendaEquipamento = req("tipoAgendamento")

'if isnumeric(ProfissionalID) then
	'if ccur(ProfissionalID) < 0 then
		'EquipamentoID=ProfissionalID*-1
	'end if
'end if

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
	session("RepSol")=AgendamentoID
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
	session("RepSol")=""
	redirectID = ProfissionalID
	if isAgendaEquipamento = "equipamento" then
        redirectID = EquipamentoID
    end if
	%>
	loadAgenda('<%=Data%>', <%=redirectID%>);
	<%
end if

if Acao="Repetir" then
	erro=""
	
	set ProcedimentosAgendamentoSQL = db.execute(" SELECT CONCAT(a.TipoCompromissoID, COALESCE(CONCAT(',', GROUP_CONCAT(ap.TipoCompromissoID)),'')) ProcedimentoID FROM agendamentos a "&_
	" LEFT JOIN agendamentosprocedimentos ap ON ap.AgendamentoID = a.id "&_
	" WHERE a.id="&session("RepSol"))

	if not ProcedimentosAgendamentoSQL.eof then

		if UnidadeID<>"" then
			sqlUnidade = " AND loc.UnidadeID='"&UnidadeID&"'"
		end if

		if Hora <>"" then
			horaWhere = " AND "&mytime(Hora)&" BETWEEN HoraDe AND HoraA "
		end if

		Procedimentos__array = split(ProcedimentosAgendamentoSQL("ProcedimentoID"), ",")
		ProcedimentoValidado = false

		if ProfissionalID&""="" or ProfissionalID&""="0"  then
			ProfissionalEquipamentoID=EquipamentoID*-1
		else
			ProfissionalEquipamentoID=ProfissionalID
		end if
		
		For i = 0 To ubound(Procedimentos__array)
			Procedimento = Procedimentos__array(i)
			sqlProcedimentoPermitido =  " AND ((Procedimentos = '' OR Procedimentos IS NULL)"&_
										" OR Procedimentos LIKE '%|"&Procedimento&"|%') "
										
			set sqlGrade = db.execute("SELECT id GradeID, Especialidades, Procedimentos,Convenios, "&_
										" LocalID FROM (SELECT ass.id, Especialidades, Procedimentos, LocalID,Convenios FROM assfixalocalxprofissional ass "&_
														" LEFT JOIN locais loc ON loc.id=ass.LocalID "&_
														" WHERE ProfissionalID="&treatvalzero(ProfissionalEquipamentoID)&_
														sqlUnidade&_
														" AND DiaSemana=dayofweek("&mydatenull(Data)&") "&_
														horaWhere&_
														" AND ((InicioVigencia IS NULL OR InicioVigencia <= "&mydatenull(Data)&") AND (FimVigencia IS NULL OR FimVigencia >= "&mydatenull(Data)&")) "&_
														" UNION ALL "&_
														" SELECT ex.id*-1 id, Especialidades, Procedimentos, LocalID,Convenios FROM assperiodolocalxprofissional ex "&_
														" LEFT JOIN locais loc ON loc.id=ex.LocalID "&_
														" WHERE ProfissionalID="&treatvalzero(ProfissionalEquipamentoID)&sqlUnidade&_
														" AND DataDe<="&mydatenull(Data)&_
														" AND DataA>="&mydatenull(Data)&")t"&_
										" where true "&sqlProcedimentoPermitido)
			if sqlGrade.eof and ProcedimentoValidado = false then
				erro = "Procedimento não permitido nesta grade."
				ProcedimentoValidado = true
			end if
		next
	end if

	if erro="" then
		
		set DadosConsulta=db.execute("select * from agendamentos where id="&session("RepSol"))
		rfTempo=DadosConsulta("Tempo")
		rfProcedimento=DadosConsulta("TipoCompromissoID")
		rfrdValorPlano=DadosConsulta("rdValorPlano")
		rfValorPlano=DadosConsulta("ValorPlano")
		rfPlanoID = DadosConsulta("PlanoID")
		rfPaciente=DadosConsulta("PacienteID")
		rfStaID=1
		rfLocal=DadosConsulta("LocalID")
		rfEspecialidade=DadosConsulta("EspecialidadeID")
		rfTabelaParticularID=DadosConsulta("TabelaParticularID")
		
		rfProfissionalID = ProfissionalID
		rfNotas=ref("Notas")
		
		if EquipamentoID&"" = "" then
			EquipamentoID = DadosConsulta("EquipamentoID")
		end if

		sqlTempo = "SELECT tempo FROM procedimento_tempo_profissional WHERE profissionalid="&treatvalzero(rfProfissionalID)&" AND procedimentoID="&treatvalzero(rfProcedimento)
		set TempoProProfissionalSQL = db.execute(sqlTempo)
		if not TempoProProfissionalSQL.eof then
			rfTempo=TempoProProfissionalSQL("tempo")
		end if

		if isNumeric(rfTempo) and not rfTempo="" then TempoSol=rfTempo else TempoSol=0 end if
		HoraSolIni=cDate(hour(Hora)&":"&minute(Hora))
		HoraSolFin=dateAdd("n",TempoSol,HoraSolIni)
		HoraSolFin=cDate(hour(HoraSolFin)&":"&minute(HoraSolFin))

		ConsultaID="0"
		db_execute("insert into agendamentos (PacienteID, ProfissionalID, Data, Hora, TipoCompromissoID, StaID, ValorPlano, rdValorPlano, PlanoID, Notas, FormaPagto, LocalID, Tempo, HoraFinal,Procedimentos, EquipamentoID, sysUser, EspecialidadeID, TabelaParticularID) values ('"&rfPaciente&"', "&treatvalzero(rfProfissionalID)&", "&mydatenull(Data)&", "&mytime(Hora)&", '"&rfProcedimento&"', '"&rfStaID&"', "&treatvalzero(rfValorPlano)&", '"&rfrdValorPlano&"', '"&rfPlanoID&"', '"&rfNotas&"', '0', "&treatvalzero(LocalID)&", '"&rfTempo&"', '"&HoraSolFin&"','"&DadosConsulta("Procedimentos")&"','"&EquipamentoID&"', "&session("User")&", "&treatvalnull(rfEspecialidade)&", "&treatvalnull(rfTabelaParticularID)&")")
		set pultCon=db.execute("select id, ProfissionalID, ConfSMS, ConfEmail from agendamentos where ProfissionalID="&treatvalzero(rfProfissionalID)&" and Data="&mydatenull(Data)&" and Hora="&mytime(Hora)&" order by id desc limit 1")
		'procedimentos
		
		call agendaUnificada("insert", pultCon("id"), pultCon("ProfissionalID"))

		set ap = db.execute("SELECT * FROM agendamentosprocedimentos WHERE AgendamentoID = "&session("RepSol"))

		if not ap.eof then
			while not ap.eof
				sqlP = "INSERT INTO agendamentosprocedimentos (AgendamentoID,TipoCompromissoID,Tempo,rdValorPlano,ValorPlano,PlanoID,LocalID,EquipamentoID) VALUES ('"&pultCon("id")&"','"&ap("TipoCompromissoID")&"','"&ap("Tempo")&"','"&ap("rdValorPlano")&"',"&ap("ValorPlano")&",'"&ap("PlanoID")&"',"&treatvalzero(ap("LocalID"))&","&treatvalzero(ap("EquipamentoID"))&")"
				'response.write(sqlP)
				db.execute(sqlP)
			ap.movenext
			wend
			ap.close
			set ap=nothing
		end if

		ConsultaID = pultCon("id")

		strLog = "insert into LogsMarcacoes (PacienteID, ProfissionalID, ProcedimentoID, DataHoraFeito, Data, Hora, Sta, Usuario, Motivo, Obs, ARX, ConsultaID, UnidadeID) values ('"&rfPaciente&"', "&treatvalzero(rfProfissionalID)&", '"&rfProcedimento&"', '"&now()&"', "&mydatenull(Data)&", "&mytime(Hora)&", '"&rfStaID&"', '"&session("User")&"', '0', 'Agendamento gerado a partir de repetição. "&rfNotas&"', 'A', '"&pultCon("id")&"', "&treatvalzero(session("UnidadeID"))&")"
		db_execute(strLog)
		'call centralSMS(pultCon("ConfSMS"), Data, Hora, session("RepSol"))
		'call centralEmail(pultCon("ConfEmail"), Data, Hora, session("RepSol"))
		call googleCalendar("X", "", ConsultaID, "", "", "", "", "", "", "")
		call googleCalendar("I", "vca", ConsultaID, ProfissionalID, "", "", "", "", "", "")

		redirectID = ProfissionalID
		if isAgendaEquipamento = "equipamento" then
			redirectID = EquipamentoID
		end if

		%>
		loadAgenda('<%=Data%>', <%=redirectID%>);
		getUrl("patient-interaction/get-appointment-events", {appointmentId: "<%=ConsultaID%>" })
		<%
	end if
	if erro<>"" then
		%>
		new PNotify({
			title: 'Não agendado!',
			text: '<%=erro%>',
			type: 'danger',
			delay: 3000
		});
		<%
	end if
end if
%>