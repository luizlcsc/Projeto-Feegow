<!--#include file="connect.asp"--><!--#include file="connectCentral.asp"--><%
if request.ServerVariables("REMOTE_ADDR")<>"::1" and request.ServerVariables("REMOTE_ADDR")<>"127.0.0.1" then
	on error resume next
end if
if ref("Chegada")<>"" and isdate(ref("Chegada")) then
	HoraSta = formatdatetime(ref("Chegada"), 3)
else
	HoraSta = time()
end if

if ref("ProcedimentoID")="0" or ref("ProcedimentoID")="" then
	erro = "Selecione um procedimento"
end if

if session("Banco") = "clinic4421" or session("Banco") = "clinic100000" then
    dt = left(mydate(ref("Data")),8)&"%"
    sql = "SELECT IF(COUNT(a.id) >= p.MaximoNoMes AND p.MaximoNoMes IS NOT NULL, 1, 0)ultimos FROM agendamentos a LEFT JOIN procedimentos p ON p.id = a.TipoCompromissoID WHERE a.Data LIKE '"&dt&"' AND a.PacienteID = "&ref("PacienteID")&" AND a.TipoCompromissoID = "&ref("ProcedimentoID")
    '   response.write(dt   )
    set ultimosAgendamentos = db.execute(sql)
    if ultimosAgendamentos("ultimos") = "1" then
        erro = "Este paciente já ultrapassou o seu limite para este procedimemto este mês."
    end if
end if

set veri=db.execute("select Tempo,HoraFinal from agendamentos where isNull(Tempo) or isNull(HoraFinal)")
if not veri.EOF then
	db_execute("update agendamentos set Tempo=0 where isNull(Tempo) or Tempo like ''")
	set p=db.execute("select * from agendamentos where isNull(HoraFinal)")
	while not p.eof
'		response.Write("update agendamentos set HoraFinal="& mytime( dateAdd("n",p("Tempo"),cdate( hour(p("Hora"))&":"&minute(p("Hora")) )) )&" where id="&p("id"))
		db_execute("update agendamentos set HoraFinal="& mytime( dateAdd("n",p("Tempo"),cdate( hour(p("Hora"))&":"&minute(p("Hora")) )) )&" where id="&p("id"))
	p.moveNext
	wend
	p.close
	set p=nothing
end if
rfTempo=request.Form("Tempo")
rfHora=request.Form("Hora")
rfProfissionalID=request.Form("ProfissionalID")
rfData=request.Form("Data")
rfProcedimento=request.Form("ProcedimentoID")
rfrdValorPlano=request.Form("rdValorPlano")
if rfrdValorPlano="V" then
	rfValorPlano=request.Form("Valor")
	if rfValorPlano="" or not isnumeric(rfValorPlano) then
		rfValorPlano=0
	end if
else
	rfValorPlano=request.Form("ConvenioID")
end if
rfPaciente=ref("PacienteID")
PacienteID = rfPaciente
rfStaID=request.Form("StaID")
if ref("LocalID")="" then
	rfLocal=0
else
	rfLocal=request.Form("LocalID")
end if
rfNotas=ref("Notas")
rfSubtipoProcedimento=0'request.Form("SubtipoProcedimento")'VERIFICAR
ConsultaID=request.form("ConsultaID")
%><!--#include file="errosPedidoAgendamento.asp"--><%''=request.Form()%><%
if erro="" then
'response.Write(request.Form())
'"Hora=&Paciente=&Procedimento=&StaID=&Local=&rdValorPlano=&ValorPlano=&ProfissionalID=&Data=&Tempo=
	if rfStaID=5 or rfStaID="5" then
		call gravaChamada(rfProfissionalID, rfPaciente)
	end if
	Notas=replace(replace(rfNotas,"_"," "),"'","''")
	'-->Verifica se paciente já tem esse convênio. Se não, cria esse convênio para esse paciente
	if rfrdValorPlano="P" then
		call gravaConvPac(rfValorPlano, rfPaciente)
	end if
	
	camposPedir = "Tel1, Cel1, Email1"
	if session("banco")="clinic811" then
		camposPedir = "Tel1, Cel1, Email1, Origem"
	end if
	splCamposPedir = split(camposPedir, ", ")
	
	upPac = ""
	for z=0 to ubound(splCamposPedir)
		upPac = upPac & splCamposPedir(z)&"='"&ref("age"&splCamposPedir(z)&"")&"', "
	next
	
	db_execute("update pacientes set "& upPac &" sysActive=1 where id="&rfPaciente)
	'<--Verifica se paciente já tem esse convênio. Se não, cria esse convênio para esse paciente\\
	if ConsultaID="0" then
		sql = "insert into agendamentos (PacienteId, ProfissionalID, Data, Hora, TipoCompromissoID, StaID, ValorPlano, rdValorPlano, Notas, FormaPagto, HoraSta, LocalID, Tempo, HoraFinal, SubtipoProcedimentoID, ConfEmail, ConfSMS, Encaixe, EquipamentoID) values ('"&rfPaciente&"','"&rfProfissionalID&"','"&mydate(rfData)&"','"&rfHora&"','"&rfProcedimento&"','"&rfStaID&"','"&treatVal(rfValorPlano)&"','"&rfrdValorPlano&"','"&Notas&"','0', '"&HoraSta&"',"&treatvalzero(rfLocal)&",'"&rfTempo&"','"&hour(HoraSolFin)&":"&minute(HoraSolFin)&"', '"&rfSubtipoProcedimento&"', '"&ref("ConfEmail")&"', '"&ref("ConfSMS")&"', "&treatvalnull(ref("Encaixe"))&", "&treatvalnull(ref("EquipamentoID"))&")"
	
'		response.Write(sql&vbcrlf)
	
		db_execute(sql)
		set pultCon=db.execute("select id from agendamentos order by id desc limit 1")
		db_execute("insert into LogsMarcacoes (PacienteID, ProfissionalID, ProcedimentoID, DataHoraFeito, Data, Hora, Sta, Usuario, Motivo, Obs, ARX, ConsultaID) values ('"&rfPaciente&"', '"&rfProfissionalID&"', '"&rfProcedimento&"', '"&now()&"', '"&mydate(rfData)&"', '"&rfHora&"', '"&rfStaID&"', '"&session("User")&"', '0', '"&Notas&"', 'A', '"&pultCon("id")&"')")
		ConsultaID = pultcon("id")
        
        call statusPagto(ConsultaID, rfPaciente, rfData, rfrdValorPlano, rfValorPlano, rfStaID, rfProcedimento, rfProfissionalID)

        txtEmail = "Novo agendamento realizado:<br><br>Data: "& rfData &" - "& rfHora


		call googleCalendar("I", "vca", ConsultaID, rfProfissionalID, "", "", "", "", "", "")
	else
		set pCon=db.execute("select * from agendamentos where id = '"&ConsultaID&"'")
		contaAlteracoes=0
		if not pCon.EOF then
            alteracoesAgendamento = ""
            if pCon("Data")<>cdate(rfData) then
                ObsR="Altera&ccedil;&atilde;o de data (de "&pCon("Data")&" para "& rfData &")."
				contaAlteracoes=contaAlteracoes+1
                alteracoesAgendamento = alteracoesAgendamento & contaAlteracoes&". "& ObsR &"<br>"
            end if
			if cDate(hour(pCon("Hora"))&":"&minute(pCon("Hora")))<>cDate(rfHora) then
				ObsR="Altera&ccedil;&atilde;o de hor&aacute;rio (de "& ft(pCon("Hora")) &" para "& rfHora &")."
				contaAlteracoes=contaAlteracoes+1
                alteracoesAgendamento = alteracoesAgendamento & contaAlteracoes&". "& ObsR &"<br>"
			end if
			if cCur(pCon("TipoCompromissoID"))<>cCur(rfProcedimento) then
				ObsR="Altera&ccedil;&atilde;o de procedimento."
				contaAlteracoes=contaAlteracoes+1
                alteracoesAgendamento = alteracoesAgendamento & contaAlteracoes&". "& ObsR &"<br>"
			end if
			if cCur(pCon("StaID"))<>cCur(rfStaID) then
				ObsR="Altera&ccedil;&atilde;o de status."
				contaAlteracoes=contaAlteracoes+1
                alteracoesAgendamento = alteracoesAgendamento & contaAlteracoes&". "& ObsR &"<br>"
			end if
			if contaAlteracoes>1 then
				ObsR="Altera&ccedil;&atilde;o de dados do agendamento."
			end if
			if contaAlteracoes>0 then
                txtEmail = "Agendamento alterado:<br><br> "& alteracoesAgendamento
            end if

            Profissional2 = pCon("ProfissionalID")&""
		end if
		if contaAlteracoes>0 then
			db_execute("insert into LogsMarcacoes (PacienteID, ProfissionalID, ProcedimentoID, DataHoraFeito, Data, Hora, Sta, Usuario, Motivo, Obs, ARX, ConsultaID) values ('"&rfPaciente&"', '"&rfProfissionalID&"', '"&rfProcedimento&"', '"&now()&"', '"&mydate(rfData)&"', '"&rfHora&"', '"&rfStaID&"', '"&session("User")&"', '0', '"&ObsR&"', 'R', '"&ConsultaID&"')")
		end if
		db_execute("update agendamentos set PacienteId='"&rfPaciente&"', ProfissionalID='"&rfProfissionalID&"', Data='"&mydate(rfData)&"', Hora='"&rfHora&"', TipoCompromissoID='"&rfProcedimento&"', StaID='"&rfStaID&"', ValorPlano='"&treatVal(rfValorPlano)&"', rdValorPlano='"&rfrdValorPlano&"', Notas='"&Notas&"', FormaPagto='0', HoraSta='"&HoraSta&"', LocalID='"&rfLocal&"', Tempo='"&rfTempo&"' ,HoraFinal='"&hour(HoraSolFin)&":"&minute(HoraSolFin)&"', SubtipoProcedimentoID='"&rfSubtipoProcedimento&"', ConfEmail='"&ref("ConfEmail")&"', ConfSMS='"&ref("ConfSMS")&"', Encaixe="&treatvalnull(ref("Encaixe"))&", EquipamentoID="&treatvalnull(ref("EquipamentoID"))&" where id like '"&ConsultaID&"'")

        call statusPagto(ConsultaID, rfPaciente, rfData, rfrdValorPlano, rfValorPlano, rfStaID, rfProcedimento, rfProfissionalID)

	end if
	call centralSMS(ref("ConfSMS"), rfData, rfHora, ConsultaID)
	call centralEmail(ref("ConfEmail"), rfData, rfHora, ConsultaID)
	call googleCalendar("X", "", ConsultaID, "", "", "", "", "", "", "")
	call googleCalendar("I", "vca", ConsultaID, rfProfissionalID, "", "", "", "", "", "")
    call disparaEmail(rfProfissionalID, txtEmail, rfPaciente, rfProcedimento)
'V	if rfrdValorPlano="P" then
'E		set veSePacTemPlano=db.execute("select * from Paciente where id like '"&rfPaciente&"'")
'R		if not veSePacTemPlano.EOF then
'I			if isNull(veSePacTemPlano("Convenio1")) or veSePacTemPlano("Convenio1")=0 then
'F			db_execute("update pacientes set Convenio1='"&rfValorPlano&"' where id like '"&rfPaciente&"'")
'I			end if
'C		end if
'A	end if
	'se deu tudo certo e salvou, faz as acoes abaixo
	%>
        new PNotify({
            title: 'Agendamento salvo!',
            text: '',
            type: 'success',
            delay: 1500
        });
        if( $('#TipoAgenda').val()=='Equipamento'){
            loadAgenda('<%=rfData%>', '<%= ref("EquipamentoID") %>');
        }else{
            loadAgenda('<%=rfData%>', <%= rfProfissionalID %>);
        }
       	//$("#modal-agenda").modal('hide');
        af('f');
	<%
    if rfProfissionalID=Profissional2 then
        Profissional2 = ""
    end if
    getEspera(rfProfissionalID &", "& Profissional2)

	if session("OtherCurrencies")="phone" then
		set vcaCha = db.execute("select id from chamadas where StaID=1 AND sysUserAtend="&session("User"))
		if not vcaCha.EOF then
			db_execute("insert into chamadasagendamentos (ChamadaID, AgendamentoID) values ("&vcaCha("id")&", "&ConsultaID&")")
		end if
	end if

    if ref("rpt")="S" then
        rptDataInicio = cdate(ref("Data"))
        rptTerminaRepeticao = ref("TerminaRepeticao")
        rptIntervaloRepeticao = ref("IntervaloRepeticao")
        rptRepeticaoOcorrencias = 1
        Repeticao = ref("Repeticao")
        repetirDias = ref("repetirDias")
        tipoDiaMes = ref("tipoDiaMes")
        if repetirDias="" then
            repetirDias = cstr(weekday(Data))
        end if

        if rptTerminaRepeticao="N" then
            rptRepeticaoDataFim = dateAdd("yyyy", 2, rptDataInicio)
        elseif rptTerminaRepeticao="O" then
            if rptRepeticaoOcorrencias<>"" and isnumeric(rptRepeticaoOcorrencias) then
                rptRepeticaoOcorrencias = cint( ref("RepeticaoOcorrencias") )
            end if
        elseif rptTerminaRepeticao="D" then
            if isdate(ref("RepeticaoDataFim")) and ref("RepeticaoDataFim")<>"" then
                rptRepeticaoDataFim = cdate(ref("RepeticaoDataFim"))
            else
                rptRepeticaoDataFim = rptDataInicio
            end if
        end if

        if tipoDiaMes="DiaSemana" and Repeticao="M" then
            Repeticao = "S"
            rptIntervaloRepeticao = ccur(rptIntervaloRepeticao)*4
            repetirDias = cstr( weekDay(rptDataInicio) )
        end if

        rptDataLoop = rptDataInicio
        rptOcorrencias = 0
        Maximo = 200
        while ( (rptTerminaRepeticao="O" and rptOcorrencias<rptRepeticaoOcorrencias) or (rptRepeticaoDataFim<>"O" and rptDataLoop<rptRepeticaoDataFim) ) and rptC<Maximo
            select case Repeticao
                case "D"
                    rptDataLoop = dateAdd("d", rptIntervaloRepeticao, rptDataLoop)
                    replica = 1
                case "S"
                    rptDataLoop = dateAdd("d", 1, rptDataLoop)
                    if weekDay(rptDataLoop)=1 and ccur(rptIntervaloRepeticao)>1 then
                        rptDataLoop = dateAdd("d", (ccur(rptIntervaloRepeticao)-1)*7, rptDataLoop)
                    end if
                    if instr(repetirDias, weekday(rptDataLoop))>0 then
                        replica = 1
                    else
                        replica = 0
                    end if
                case "M"
                    rptDataLoop = dateadd( "m", ccur(rptIntervaloRepeticao), rptDataLoop )
                    if rptTerminaRepeticao<>"O" then
                        if rptDataLoop<=rptRepeticaoDataFim then
                            replica = 1
                        else
                            replica = 0
                        end if
                    else
                        replica = 1
                    end if
                case "A"
                    rptDataLoop = dateAdd("yyyy", rptIntervaloRepeticao, rptDataLoop)
                    replica = 1
            end select
            if replica=1 then
                rptC = rptC + 1
                'response.write("console.log('"& rptDataLoop &" - "& weekday(rptDataLoop) &"');")
                rptOcorrencias = rptOcorrencias+1

		        sql = "insert into agendamentos (PacienteId, ProfissionalID, Data, Hora, TipoCompromissoID, StaID, ValorPlano, rdValorPlano, Notas, FormaPagto, HoraSta, LocalID, Tempo, HoraFinal, SubtipoProcedimentoID, ConfEmail, ConfSMS, Encaixe, EquipamentoID) values ('"&PacienteID&"','"&rfProfissionalID&"', "&mydatenull(rptDataLoop)&", '"&rfHora&"','"&rfProcedimento&"','"&rfStaID&"','"&treatVal(rfValorPlano)&"','"&rfrdValorPlano&"','"&Notas&"','0', '"&HoraSta&"',"&treatvalzero(rfLocal)&",'"&rfTempo&"','"&hour(HoraSolFin)&":"&minute(HoraSolFin)&"', '"&rfSubtipoProcedimento&"', '"&ref("ConfEmail")&"', '"&ref("ConfSMS")&"', "&treatvalnull(ref("Encaixe"))&", "&treatvalnull(ref("EquipamentoID"))&")"
                
	
        '		response.Write(sql&vbcrlf)
	
		        db.execute(sql)
                set pult = db.execute("select id from agendamentos where PacienteID="& PacienteID &" order by id desc limit 1")
                itensRepeticao = itensRepeticao &"|"& pult("id") &"|, "
            end if
        wend
        if itensRepeticao<>"" then
            'itensRepeticao = left(itensRepeticao, len(itensRepeticao)-2)
            db_execute("insert into agendamentosrepeticoes (AgendamentoID, Agendamentos) values ("&ConsultaID&", '"&itensRepeticao & "|"& ConsultaID &"|')")
        end if
    end if

else
	%>
    new PNotify({
        title: 'N&Atilde;O AGENDADO!',
        text: '<%=erro%>',
        type: 'danger',
        delay: 3000
    });
	<%
end if
%>