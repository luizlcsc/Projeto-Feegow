<!--#include file="Classes/FuncoesRepeticaoMensalAgenda.asp"-->

<%
set ConfigSQL = db.execute("select BloquearEncaixeEmHorarioBloqueado from sys_config WHERE id=1 LIMIT 1")

if ref("ageTel1")="" and ref("ageCel1")="" then
    erro = "Erro: Preencha ao menos um telefone do paciente."
    %>
    $("#ageCel1").focus();
    <%
end if

if (session("Banco")="clinic5368" or session("Banco")="clinic5872" or session("Banco")="clinic5563") and ref("ageEmail1")="" then
    erro = "Erro: Preencha o e-mail do paciente."
    %>
    $("#ageEmail1").focus();
    <%
end if

if getConfig("ObrigarLocalAtendimento")=1 then
    if ref("LocalID")="" or ref("LocalID")=0 then
        erro = "Erro: Preencha o local de atendimento."
    end if
end if

if (ref("EquipamentoID")&""<>"") AND (ref("ProfissionalID")&""="" OR ref("ProfissionalID")=0) then
    set configEquipamento = db.execute("select PermitirAgendamentoSemProfissional from equipamentos where id ="&ref("EquipamentoID"))
    if not configEquipamento.EOF then
        if configEquipamento("PermitirAgendamentoSemProfissional") <> "on" then
            erro = "Erro: Preencha o Profissional"
        end if
    end if
end if

if (ref("ageTabela")&""="" or ref("ageTabela")&""="0") and getConfig("ObrigarTabelaParticular") then
    erro = "Erro: Preencha a tabela do paciente."
end if


if not isdate(rfHora) then
	erro="Erro: Horário inválido."
end if

if cdate(rfData) < date() and ConsultaID="0" and aut("|agendamentosantigosI|")=0 then
	erro="Erro: Data do agendamento não pode ser anterior a hoje."
end if

if cdate(rfData&" "&rfHora) < now() and ConsultaID="0" and aut("|agehorantI|")=0 then
	erro="Erro: Data e hora do agendamento inválido."
end if

if rfStaID="0" or rfStaID="" then
	erro="Erro: Selecione um <strong>STATUS</strong> para o agendamento."
end if
if rfPaciente="" or rfPaciente="0" then
	erro="Erro: Selecione ou insira um paciente."
end if
if rfrdValorPlano="P" and (rfValorPlano="" or rfValorPlano="0") then
	erro="Erro: Selecione um conv&ecirc;nio."
end if

'if session("Banco")="clinic811" and ref("ageOrigem")="0" then
'    erro = "Erro: Selecione a origem."
'end if

if aut("|agestafinA|")=0 and ref("Checkin")<>"1" then
    if rfStaID="3" or rfStaID="4" or rfStaID="6" or rfStaID="2" then
        erro = "Você não possui permissão para alterar para este status."
    end if
end if

if ref("rdValorPlano")="P" then
    set ConfigConvenio = db.execute("select id from convenios where NaoAgendaSemPlano = 1 and id="&treatvalzero(ref("ConvenioID")))
    if not ConfigConvenio.EOF and ref("PlanoID") = "" then
        erro = "Erro: Selecione um Plano"
    end if
end if

if ref("Procedimentoid")&""="" then
    erro = "Erro: Selecione pelo menos um procedimento"
end if

function ValidaProcedimentoLocal(linha,pProcedimentoID,pLocalID) 
    ValidaProcedimentoLocal=""
    set ProcedimentoLocaisSQL = db.execute("SELECT SomenteLocais FROM procedimentos WHERE id="&treatvalzero(pProcedimentoID))
    if not ProcedimentoLocaisSQL.eof then
        LimitarLocais = ProcedimentoLocaisSQL("SomenteLocais")

        if LimitarLocais&""<>"" and pLocalID&"" <> "" and pLocalID&"" <> "0" then
            if instr(LimitarLocais, "|"&pLocalID&"|")<=0 then
                ValidaProcedimentoLocal= linha&"° procedimento não aceita o Local selecionado."
            end if
            if instr(LimitarLocais, "|NONE|")>0 then
                ValidaProcedimentoLocal= linha&"° procedimento não permite Locais."
            end if
        end if
    end if
end function

function ValidaProcedimentoObrigaSolicitante(linha,pProcedimentoID) 
    ValidaProcedimentoObrigaSolicitante= ""
    set ProcedimentoLocaisSQL = db.execute("SELECT ObrigarSolicitante FROM procedimentos WHERE id="&treatvalzero(pProcedimentoID))
    if not ProcedimentoLocaisSQL.eof then
        ObrigarSolicitante = ProcedimentoLocaisSQL("ObrigarSolicitante")

        if ObrigarSolicitante = "S" then
            ValidaProcedimentoObrigaSolicitante = linha&"° procedimento obriga profissional indicador."
        end if
    end if
end function

function ValidaLocalConvenio(linha,vConvenio,vLocal)
    ValidaLocalConvenio=""
    set convenioSQL = db.execute("select unidades from convenios where id="&treatvalzero(vConvenio))
    if not convenioSQL.eof then
        set localSQL = db.execute("select unidadeid from locais where id="&vLocal)
        if not localSQL.eof then
            LimitarUnidades = convenioSQL("unidades")&""
            parUnidadeID = localSQL("unidadeid")&""

            if LimitarUnidades&"" <> "" and LimitarUnidades<>"0" then
                if instr(LimitarUnidades, "|"&parUnidadeID&"|")<=0 then
                    ValidaLocalConvenio= linha&"° procedimento, local não aceita este convênio"
                end if
            end if
        end if
    end if
end function

function addError(error, valor)
    if valor <> "" then
        addError = error&"\n"&valor
    else
        addError = error
    end if
end function

if erro ="" then
    searchindicacaoId = ref("searchindicacaoId")
    'verifica se procedimento pode ser realizado nos locais
    erro = ValidaProcedimentoLocal(1,ref("ProcedimentoID")&"", ref("LocalID")&"")
    if searchindicacaoId ="" then
        erro = addError(erro, ValidaProcedimentoObrigaSolicitante(1,ref("ProcedimentoID")&""))
    end if
    if ref("LocalID")&"" <>"" and ref("rdValorPlano") = "P" then
        erro = addError(erro, ValidaLocalConvenio(1,ref("ConvenioID")&"",ref("LocalID")&""))
    end if
    '-> procedimentos adicionais na agenda
    ProcedimentosAgendamento = trim(ref("ProcedimentosAgendamento"))

    if ProcedimentosAgendamento<>"" then
    splPA = split(ProcedimentosAgendamento, ", ")
        for iPA=0 to ubound(splPA)
            if splPA(iPA)&""<>"" then
                apID = ccur( splPA(iPA) )
                apTipoCompromissoID = ref("ProcedimentoID"& apID)
                apLocalID = ref("LocalID"& apID)
                apConvenioID = ref("ConvenioID"& apID)
                aprdValorPlano = ref("rdValorPlano"& apID)
                
                erro = addError(erro, ValidaProcedimentoLocal((iPA+2),apTipoCompromissoID&"", apLocalID&""))
                
                if searchindicacaoId ="" then
                    erro = addError(erro, ValidaProcedimentoObrigaSolicitante((iPA+2),apTipoCompromissoID&""))
                end if

                if apLocalID <>"" and aprdValorPlano  = "P" then
                    erro = addError(erro, ValidaLocalConvenio((iPA+2),apConvenioID&"",apLocalID&""))
                end if
            end if
        next
    end if
end if


if rfrdValorPlano="P" then
    PlanoID = ref("PlanoID")
    if PlanoID<>"" and PlanoID<>"0" then
        set PlanoSQL = db.execute("SELECT vp.NaoCobre FROM tissprocedimentosvaloresplanos vp INNER JOIN tissprocedimentosvalores v ON v.id=vp.AssociacaoID WHERE v.ConvenioID="&treatvalzero(rfValorPlano)&" AND v.ProcedimentoID="&treatvalzero(rfProcedimento)&" AND  vp.PlanoID="&treatvalzero(PlanoID))
        if not PlanoSQL.eof then
            if PlanoSQL("NaoCobre")="S" then
                erro="Este plano não cobre o procedimento selecionado."
            end if
        end if
       
    end if

    set ProcedimentoConveniosSQL = db.execute("SELECT SomenteConvenios FROM procedimentos WHERE id="&treatvalzero(rfProcedimento))
    if not ProcedimentoConveniosSQL.eof then
        LimitarConvenios = ProcedimentoConveniosSQL("SomenteConvenios")

        if LimitarConvenios&""<>"" then
            if instr(LimitarConvenios, "|"&rfValorPlano&"|")<=0 then
                erro="Esse procedimento não aceita o convênio selecionado."
            end if
            if instr(LimitarConvenios, "|NONE|")>0 then
                erro="Este procedimento não permite convênio."
            end if
        end if
    end if

    set ProfissionalConveniosSQL = db.execute("SELECT SomenteConvenios FROM profissionais WHERE id="&treatvalzero(rfProfissionalID))
    if not ProfissionalConveniosSQL.eof then
        LimitarConvenios = ProfissionalConveniosSQL("SomenteConvenios")

        if LimitarConvenios&""<>"" then
            if instr(LimitarConvenios, "|"&rfValorPlano&"|")<=0 then
                erro="Esse profissional não aceita o convênio selecionado."
            end if
            if instr(LimitarConvenios, "|NONE|")>0 then
                erro="Este profissional não permite convênio."
            end if
        end if
    end if

end if


'if session("Banco")="clinic811" and ref("ProcedimentoID")<>"7" and ref("PacienteID")<>"" then
'    response.write("select ii.ItemID from sys_financialinvoices i left join itensinvoice ii on ii.InvoiceID=i.id WHERE i.AccountID="&treatvalnull(ref("PacienteID"))&" AND i.AssociationAccountID=3 AND (Executado<>'S' OR ISNULL(Executado))")
'    set vcaII = db.execute("select ii.ItemID from sys_financialinvoices i left join itensinvoice ii on ii.InvoiceID=i.id WHERE i.AccountID="&treatvalnull(ref("PacienteID"))&" AND i.AssociationAccountID=3 AND (Executado<>'S' OR ISNULL(Executado))")
'    if vcaII.EOF then
'        erro = "Erro: Este paciente não possui itens contratados a executar."
'    end if
'end if

if isNumeric(rfTempo) and not rfTempo="" then TempoSol=rfTempo else TempoSol=0 end if
HoraSolIni=cDate(hour(rfHora)&":"&minute(rfHora))
HoraSolFin=dateAdd("n",TempoSol,HoraSolIni)
HoraSolFin=cDate(hour(HoraSolFin)&":"&minute(HoraSolFin))


if ref("LocalID")&""<>"" and ConsultaID="0" then
    'set maxAgendamentoLocal = db.execute("select count(id) id from agendamentos ag where Data = "&mydatenull(ref("Data"))&" and Hora = '"&ref("Hora")&":00' and LocalID="&ref("LocalID")&" group by ag.localid having count(ag.id) >= (select lc.MaximoAgendamentos from locais lc where lc.id=ag.localID and MaximoAgendamentos!='')")
    set maxAgendamentoLocal = db.execute("select count(id) id from agendamentos ag where Data = "&mydatenull(ref("Data"))&" and ( Hora <= '"&ref("Hora")&":00' and HoraFinal >= '"&ref("Hora")&":00') and LocalID="&ref("LocalID")&" group by ag.localid having count(ag.id) >= (select lc.MaximoAgendamentos from locais lc where lc.id=ag.localID and MaximoAgendamentos!='')")

    if not maxAgendamentoLocal.eof then
        erro="Local indisponível. Máximo de pacientes neste local e horário é inválido."
    end if
end if

if ref("Encaixe")<>"1" and ref("StaID")<>"6" and ref("StaID")<>"11" and ref("StaID")<>"4" then
    set ve1=db.execute("select * from agendamentos where ProfissionalID = '"&rfProfissionalID&"' and StaID !=11 and ProfissionalID<>0 and Data = '"&mydate(rfData)&"' and not id = '"&ConsultaID&"' and Hora>time('"&hour(HoraSolIni)&":"&minute(HoraSolIni)&"') and Hora<time('"&HoraSolFin&"') and Encaixe IS NULL and HoraFinal>time('"&hour(HoraSolIni)&":"&minute(HoraSolIni)&"')")
    if not ve1.eof then
        erro="Erro: O horário solicitado não dispõe dos "&TempoSol&" minutos requeridos para o agendamento deste procedimento."
    end if
    LabelErroMaximoAgendamentos="equipamento"
    if rfProfissionalID <> "0" then
        sqlProfissionalOuEquipamento = "and ProfissionalID<>0 "
        LabelErroMaximoAgendamentos="profissional"
    end if
    set ve2=db.execute("select * from agendamentos where (ProfissionalID = '"&rfProfissionalID&"' and EquipamentoID='"&ref("EquipamentoID")&"') AND StaID NOT IN (6,11,3,4, 15)  "&sqlProfissionalOuEquipamento&" and Data = '"&mydate(rfData)&"' and not id = '"&ConsultaID&"' and Encaixe IS NULL and Hora=time('"&hour(HoraSolIni)&":"&minute(HoraSolIni)&"') order by Hora")
    if not ve2.EOF then
        if isnumeric(ve2("Tempo")) then
            tmp=ccur(ve2("Tempo"))
        else
            tmp=0
        end if
        set veNrComp=db.execute("select MaximoAgendamentos from procedimentos where id = '"&rfProcedimento&"'")
        if not veNrComp.EOF then
            if not isnull(veNrComp("MaximoAgendamentos")) and isnumeric(veNrComp("MaximoAgendamentos")) then
                nrComp=cint(veNrComp("MaximoAgendamentos"))
            else
                nrComp=1
            end if
        else
            nrComp=1
        end if
        if nrComp=1 then
            erro="Erro: O horário escolhido já está preenchido para este "&LabelErroMaximoAgendamentos&" neste horário."'&request.Form()&"|"&veSeFaixas("Hora")&" e fim "&veSeFaixas("HoraFinal")
        else
            set contaComps=db.execute("select COUNT(id) as TotalPacs from agendamentos where ProfissionalID = '"&rfProfissionalID&"' and ProfissionalID<>0 and Data = '"&mydate(rfData)&"' and Hora = time('"&hour(HoraSolIni)&":"&minute(HoraSolIni)&"') and not id = '"&ConsultaID&"'")

            if ccur(contaComps("TotalPacs"))>=nrComp then
                erro="Erro: O máximo de atendimentos simultâneos para este procedimento foi excedido."
            end if
        end if
    end if
end if

if erro="" then
    if rfProcedimento<>"" and rfEspecialidadeID<>"" then

        set ProcedimentoEspecialidadesSQL = db.execute("SELECT SomenteEspecialidades, OpcoesAgenda, SomenteProfissionais FROM procedimentos WHERE id="&rfProcedimento&" AND OpcoesAgenda in (4,5) AND SomenteEspecialidades!='' and SomenteEspecialidades is not null")
        if not ProcedimentoEspecialidadesSQL.eof then
            OpcoesAgenda=ProcedimentoEspecialidadesSQL("OpcoesAgenda")
            SomenteEspecialidades = ProcedimentoEspecialidadesSQL("SomenteEspecialidades")
            SomenteProfissionais = ProcedimentoEspecialidadesSQL("SomenteProfissionais")

            if OpcoesAgenda="4" or SomenteProfissionais&""="" then
                if instr(SomenteEspecialidades, "|"&rfEspecialidadeID&"|")=0 then
                    erro="Este procedimento não é permitido para a especialidade selecionada."
                end if
            elseif OpcoesAgenda="5" then
                if instr(SomenteEspecialidades, "|"&rfEspecialidadeID&"|")=0 OR instr(SomenteProfissionais, "|"&rfProfissionalID&"|")=0 then
                    erro="Este procedimento não é permitido para a especialidade selecionada."
                end if
            end if
        end if
    end if
end if


'set ve3=db.execute("select * from agendamentos where ProfissionalID like '"&rfProfissionalID&"' and Data like '"&mydate(rfData)&"' and not id = '"&ConsultaID&"' and Hora<time('"&hour(HoraSolIni)&":"&minute(HoraSolIni)&"') and HoraFinal>time('"&hour(HoraSolIni)&":"&minute(HoraSolIni)&"')")
'if not ve3.eof then
'	erro="Erro: O procedimento agendado para este profissional às "&cdate( hour(ve3("Hora"))&":"&minute(ve3("Hora")) )&" não permite outros agendamentos até as "&cdate( hour(ve3("HoraFinal"))&":"&minute(ve3("HoraFinal")) )&"."
'end if

set ve4=db.execute("select * from agendamentos where ProfissionalID = '"&rfProfissionalID&"' and ProfissionalID<>0 and Data = '"&mydate(rfData)&"' and staId not in (6,11) and not id = '"&ConsultaID&"' and Hora>time('"&hour(HoraSolIni)&":"&minute(HoraSolIni)&"') and HoraFinal<time('"&hour(HoraSolFin)&":"&minute(HoraSolFin)&"')")
if not ve4.eof then
	Hora=cdate( hour(ve4("Hora"))&":"&minute(ve4("HoraFinal")) )
	HoraFinal=cdate( hour(ve4("HoraFinal"))&":"&minute(ve4("HoraFinal")) )
	if HoraFinal>Hora then
			erro="Erro: O procedimento que você deseja realizar requer que a agenda deste profissional esteja livre das "&HoraSolIni&" às "&HoraSolFin&", mas há um procedimento agendado das "&cdate( hour(ve4("Hora"))&":"&minute(ve4("Hora")) )&" às "&cdate( hour(ve4("HoraFinal"))&":"&minute(ve4("HoraFinal")) )&" que impede este agendamento."'&ve4("id")
	end if
end if

'set ve5=db.execute("select * from agendamentos where ProfissionalID = '"&rfProfissionalID&"' and Data = '"&mydate(rfData)&"' and not id = '"&ConsultaID&"' and Hora<time('"&HoraSolIni&"') and HoraFinal>time('"&HoraSolFin&"')")
'if not ve5.eof then
'	erro="Erro: Já existe um procedimento agendado das "&cdate( hour(ve5("Hora"))&":"&minute(ve5("Hora")) )&" às "&cdate( hour(ve5("Hora"))&":"&minute(ve5("Hora")) )&" que impede este agendamento."&ConsultaID&" - "&ve5("id")
'end if

set ve6=db.execute("select * from agendamentos where ProfissionalID = '"&rfProfissionalID&"' and ProfissionalID<>0 and Data = '"&mydate(rfData)&"' and not id = '"&ConsultaID&"' and Hora=time('"&hour(HoraSolIni)&":"&minute(HoraSolIni)&"') and not TipoCompromissoID like '"&rfProcedimento&"'")
if not ve6.EOF then
	'erro="Erro: Já existe um outro procedimento agendado para este profissional às "&cdate( hour(ve6("Hora"))&":"&minute(ve6("Hora")) )&"."
end if
TotalEncaixeLocal = -1
if ref("GradeID")<> "" then
    GradeID =  ref("GradeID")

    if ref("Encaixe")="1" then
        set MaximosDeEncaixePorGradeSQL = db.execute("SELECT MaximoEncaixes FROM assfixalocalxprofissional WHERE id="&treatvalzero(GradeID)&"")
        if not MaximosDeEncaixePorGradeSQL.eof then
            MaximoEncaixesPorGrade=MaximosDeEncaixePorGradeSQL("MaximoEncaixes")
        end if
    end if

    'trata os retornos por grade
    'response.write(rfProcedimento)


    if rfProcedimento&""<>"" then
         set TipoProcedimentoSQL = db.execute("SELECT TipoProcedimentoID FROM procedimentos WHERE TipoProcedimentoID=9 AND id="&rfProcedimento)
         if not TipoProcedimentoSQL.eof then
             set MaximoRetornosGradeSQL = db.execute("SELECT MaximoRetornos, ProfissionalID, HoraDe, HoraA FROM assfixalocalxprofissional WHERE id="&treatvalzero(GradeID))
             if not MaximoRetornosGradeSQL.eof then
                 if MaximoRetornosGradeSQL("MaximoRetornos")&"" <> "" then
                     if isnumeric(MaximoRetornosGradeSQL("MaximoRetornos")&"") then
                         sqlAgendamentosRetornos = "SELECT count(agendamentos.id)NumeroRetornos FROM agendamentos INNER JOIN procedimentos ON procedimentos.id = agendamentos.TipoCompromissoID WHERE ProfissionalID="&treatvalzero(MaximoRetornosGradeSQL("ProfissionalID"))&" AND Hora BETWEEN TIME('"&right(MaximoRetornosGradeSQL("HoraDe"),8)&"') AND TIME('"&right(MaximoRetornosGradeSQL("HoraA"),8)&"') AND Data="&mydatenull(rfData)&" AND StaId NOT IN (6,11) AND procedimentos.TipoProcedimentoID=9"
                         set AgendamentosRetornosSQL = db.execute(sqlAgendamentosRetornos)

                         if not AgendamentosRetornosSQL.eof then
                             if cint(AgendamentosRetornosSQL("NumeroRetornos")) >= cint(MaximoRetornosGradeSQL("MaximoRetornos")) then
                                 erro = "Máximo de retornos excedido."
                             end if
                         end if

                     end if
                 end if
             end if
         end if
    end if
end if

'!!!!!!!!verificar se ele tem permissoes pra agendar em outras unidades, se nao tiver, verifica se este local está numa unidade que ele esteja contido
if instr(session("Permissoes"), "ageoutunidadesI")=0 and session("Admin")<>1 then
    if ref("LocalID")<>0 then
        set local = db.execute("select UnidadeID from locais where id="&treatvalzero(ref("LocalID")))
        if not local.EOF then
            if not isnull(local("UnidadeID")) then
                if instr(session("Unidades"), "|"&local("UnidadeID")&"|")=0 then
                    erro = "Erro: Você não tem permissão para agendar nesta unidade."
                end if
            end if
        end if
	end if
end if



if ref("Encaixe")="1" and erro="" and ConsultaID="0" then
    set MaximoEncaixesSQL = db.execute("select MaximoEncaixes, MinimoDeTempoEntreEncaixes, (select count(id) from agendamentos where ProfissionalID="&rfProfissionalID&" and Encaixe=1 and Data="&mydatenull(rfData)&" and id!='"&ConsultaID&"') NumeroEncaixes from profissionais where id="&rfProfissionalID)

    if not MaximoEncaixesSQL.eof then
        if not isnull(MaximoEncaixesSQL("MinimoDeTempoEntreEncaixes")) then
            MinimoHora = dateadd("n", MaximoEncaixesSQL("MinimoDeTempoEntreEncaixes") * -1, rfHora)
            MaximoHora = dateadd("n", MaximoEncaixesSQL("MinimoDeTempoEntreEncaixes"), rfHora)

            sqlAgendamentoId = ""
            if ConsultaID<>"" then
                sqlAgendamentoId= " AND id!="&treatvalzero(ConsultaID)
            end if

            sqlEncaixe= "SELECT id FROM agendamentos WHERE ProfissionalID="&rfProfissionalID&" AND Data="&mydatenull(rfData)&" AND Encaixe=1 "&_
                                     " AND Hora>'"&MinimoHora&"' AND Hora<'"&MaximoHora&"'" & sqlAgendamentoId&" LIMIT 1"
            set EncaixesProximosSQL = db.execute(sqlEncaixe)
            if not EncaixesProximosSQL.eof then
                erro="Horário solicitado não permitido. Intervalo entre encaixes: "&MaximoEncaixesSQL("MinimoDeTempoEntreEncaixes")&" minutos."
            end if
        end if

        if ref("LocalID")&"" <> "" then
            set TotalEncaixesLocalSQL = db.execute("select count(id) total from agendamentos where (LocalID = "&treatvalzero(ref("LocalID"))&" ) AND ProfissionalID="&rfProfissionalID&" and Encaixe=1 and Data="&mydatenull(rfData)&" and id!='"&ConsultaID&"'")
            if not TotalEncaixesLocalSQL.eof then 
                TotalEncaixeLocal = ccur(TotalEncaixesLocalSQL("total"))
            end if
        end if
        NumeroEncaixes = ccur(MaximoEncaixesSQL("NumeroEncaixes"))+1

        ValidaMaximoEncaixes=True

        if MaximoEncaixesPorGrade<>"" then
            MaximoEncaixes = ccur(MaximoEncaixesPorGrade)
        else
            if isnull(MaximoEncaixesSQL("MaximoEncaixes")) then
                ValidaMaximoEncaixes=False
            else
                MaximoEncaixes = ccur(MaximoEncaixesSQL("MaximoEncaixes"))
            end if
        end if

        if NumeroEncaixes>MaximoEncaixes and ValidaMaximoEncaixes or MaximoEncaixes=0 and ValidaMaximoEncaixes then
            if TotalEncaixeLocal = -1 OR TotalEncaixeLocal >= MaximoEncaixes then
                erro = "Número máximo de encaixes atingido!"
            end if 
        end if
        
    end if

    if getConfig("BloquearEncaixeEmHorarioBloqueado") = 1 then
        diaDaSemana=weekday(rfData)
        ProfissionalEquipamento = rfProfissionalID
        if ProfissionalEquipamento="0" then
            ProfissionalEquipamento="-"&ref("EquipamentoID")
        end if

        sqlCompromissos = "select id from Compromissos where ProfissionalID = '"&ProfissionalEquipamento&"' and DataDe<="&mydatenull(rfData)&" and DataA>="&mydatenull(rfData)&" and DiasSemana like '%"&diaDaSemana&"%' and HoraDe<=time('"&rfHora&"') and HoraA>time('"&rfHora&"')"

        set v7=db.execute(sqlCompromissos)
        if not v7.EOF then
            erro="Erro: O horário solicitado está bloqueado."
        end if
    end if

    if erro="" then
        set ProcedimentoPermiteEncaixeSQL = db.execute("SELECT PermiteEncaixe FROM procedimentos WHERE id="&rfProcedimento)
        if not ProcedimentoPermiteEncaixeSQL.eof then
            if ProcedimentoPermiteEncaixeSQL("PermiteEncaixe")="N" then
                erro = "Este procedimento não permite encaixe."
            end if
        end if
    end if
end if

if erro="" then
    diaDaSemana=weekday(rfData)
    sqlBloqueio = "SELECT id FROM compromissos WHERE DiasSemana like '%"&diaDaSemana&"%' AND ProfissionalID = "&rfProfissionalID&" and "&mydatenull(rfData)&" BETWEEN DataDe AND DataA AND (HoraDe< time('"&HoraSolFin&"') AND HoraDe > time('"&HoraSolIni&"'))"
    set TemBloqueioSQL = db.execute(sqlBloqueio)
    if not TemBloqueioSQL.eof then
        erro="Este horário está bloqueado."
    end if
end if

if erro = "" and ref("LocalID")<>"" and ref("LocalID")<>"0"  then

    if ref("rdValorPlano")="P" then
        if validaConvenio( ref("ConvenioID"), ref("LocalID") )=0 then
           ' erro="Esta unidade não aceita o convênio selecionado na linha 1."
        end if
    end if

    procedimentosID = trim(ref("ProcedimentosAgendamento"))
    if procedimentosID <> "" then
        procedimentos = split(procedimentosID, ",")
        For i=0 To UBound(procedimentos)
            apID = Trim(procedimentos(i))
            EquipID = ref("EquipamentoID" & apID)
            aprdValorPlano = ref("rdValorPlano"& apID)
            apValorPlano = ref("ConvenioID"& apID)
            apLocalID = ref("LocalID"& apID)

            if aprdValorPlano="P" then
                if validaConvenio(apValorPlano,apLocalID )=0 then
             '       erro="Esta unidade não aceita o convênio selecionado na linha "&i+2&"."
                end if
            end if
        Next
    end if
end if

if erro="" and rdEquipamentoID <> "" then

    'Validar se o equipamento tem possibilidade
    'pHora=ref("Hora")
    'pData=ref("Data")

    'Validar se o equipamento bloqueia grade ou nao
    temBloqueio = validarEquipamento(ref("EquipamentoID"), rfData, rfHora)

    if temBloqueio = 0 then
        erro = "Existem equipamento sem disponibilidade"
    end if

    if erro = "" then
        procedimentosID = trim(ref("ProcedimentosAgendamento"))
        if procedimentosID <> "" then 
            procedimentos = split(procedimentosID, ",")
            For Each p In procedimentos
                EquipID = ref("EquipamentoID" & Trim(p))
                temBloqueio = validarEquipamento(EquipID, rfData, rfHora)

                if temBloqueio = 0 then
                    erro = "Existem equipamento sem disponibilidade"
                end if
            Next
        end if
    end if

end if

if erro="" then
    if ref("EquipamentoID")<>"" and ref("EquipamentoID")<>"0" then
        sqlBloqueioEquipamentoAgendado = "SELECT COUNT(*) <> 0 AS bloquear FROM compromissos WHERE TRUE AND DataDe <= "&mydatenull(rfData)&" AND DataA >= "&mydatenull(rfData)&" AND DiasSemana LIKE CONCAT('%',(SELECT DAYOFWEEK("&mydatenull(rfData)&")),'%') AND HoraDe <= '"&rfHora&"'  AND HoraA > '"&rfHora&"'  AND profissionalID = -"&ref("EquipamentoID")

        TemBloqueioEquipamentoAgendadoSQL = db.execute(sqlBloqueioEquipamentoAgendado)
        if TemBloqueioEquipamentoAgendadoSQL("bloquear") <> "0"  then
            erro = " Este equipamento está bloqueado nesse horário."
        end if

        DiaSemana = weekday(rfData)
        set Horarios = db.execute("select ass.*, l.NomeLocal, '' Cor from assperiodolocalxprofissional ass LEFT JOIN locais l on l.id=ass.LocalID where ass.ProfissionalID=-"&ref("EquipamentoID")&" and DataDe<="&mydatenull(rfData)&" and DataA>="&mydatenull(rfData)&" order by HoraDe")
		if Horarios.EOF then			
	        set Horarios = db.execute("select ass.*, l.NomeLocal, '' Cor from assfixalocalxprofissional ass LEFT JOIN locais l on l.id=ass.LocalID where ass.ProfissionalID=-"&ref("EquipamentoID")&" and ass.DiaSemana="&DiaSemana&" AND ((ass.InicioVigencia IS NULL OR ass.InicioVigencia <= "&mydatenull(rfData)&") AND (ass.FimVigencia IS NULL OR ass.FimVigencia >= "&mydatenull(rfData)&")) order by ass.HoraDe")
		end if

        if Horarios.eof then
            erro = "Não existe grade configurada para esse equipamento."
        end if

        if erro="" then
            'validar se o agendamento ja existe pela ag. diaria

            if rfProfissionalID<>"0" then
                queryPodeAgendar = "SELECT COUNT(age.id) AS possuiAgendamento "&_
                                     "FROM agendamentos age "&_
                                     "JOIN profissionais prof ON prof.id = age.ProfissionalID "&_
                                    "WHERE age.ProfissionalID = '"&rfProfissionalID&"'"&_
                                     " AND age.DATA = "&mydatenull(rfData)&" "&_
                                     " AND age.StaID NOT IN (11,6) and age.Hora = '"&rfHora&"' and age.id != "&ConsultaID
                set podeAgendarSQL = db.execute(queryPodeAgendar)

                if not podeAgendarSQL.eof then
                    if podeAgendarSQL("possuiAgendamento")<>"0" then
                        erro = "Este profissional já possui um agendamento neste horário."
                    end if
                end if
            end if


        end if
    end if
end if

function validarEquipamento(equipamentoId, dataAgendamento, hora)

   validarEquipamento = 1
   if equipamentoId <> "" then
   'Validar se o equipamento bloqueia pela grade
   sqlEquipamento = "SELECT IFNULL(BloqueiaGrade, 'off') as BloqueiaGrade FROM equipamentos WHERE id = " & equipamentoId
   set equipamento = db.execute(sqlEquipamento)

   if not equipamento.eof then
       if equipamento("BloqueiaGrade") = "on" then
           'Procurar uma grade de excecão para o equipamento
           sqlGradeExcecao = "select count(*) as total from assperiodolocalxprofissional app where ProfissionalID = -" & equipamentoId & " AND '" & dataAgendamento & "' between DataDe AND DataA AND '" & hora & "' BETWEEN HoraDe AND HoraA"
           set gradeExcecao = db.execute(sqlGradeExcecao)

           'Procurar a grade do dia
           sqlGrade = "select count(*) as total from assfixalocalxprofissional app where ProfissionalID = -" & equipamentoId & " AND DATE_FORMAT('" & dataAgendamento & "', '%W') = DiaSemana AND '" & hora & "' BETWEEN HoraDe AND HoraA"
           set grade = db.execute(sqlGrade)

           if cint(gradeExcecao("total")) > 0 or cint(grade("total")) > 0 then
               'Retorno da função
               sqlCompromisso = "select count(*) as total from compromissos c where ProfissionalID = -" & equipamentoId & " AND '" & dataAgendamento & "' BETWEEN DataDe AND DataA AND '" & hora & "' BETWEEN HoraDe AND HoraA"
               set compromisso = db.execute(sqlCompromisso)
               if cint(compromisso("total")) > 0 then
                   validarEquipamento = 0
               else
                   'Equipamento disponivel
                   validarEquipamento = 1
               end if
           else
               validarEquipamento = 0
           end if
       else
           validarEquipamento = 1
       end if
   end if
   end if
end function

checkQuantidadeAgendamentoHorario() 

function checkQuantidadeAgendamentoHorario()  
    rptDataInicio = cdate(ref("Data"))
    rptTerminaRepeticao = ref("TerminaRepeticao")
    rptIntervaloRepeticao = ref("IntervaloRepeticao")
    rptRepeticaoOcorrencias = 1
    Repeticao = ref("Repeticao")
    repetirDias = ref("repetirDias")
    tipoDiaMes = ref("tipoDiaMes")
    rfTempo=ref("Tempo")
    rfHora=ref("Hora")
    rfProfissionalID=ref("ProfissionalID")
    rfEspecialidadeID=ref("EspecialidadeID")
    rdEquipamentoID=ref("EquipamentoID")
    indicacaoID=ref("indicacaoId")
    rfData=ref("Data")
    rfProcedimentoId=ref("ProcedimentoID")

    listDates = array()    

    if isdate(rfData) then
        rfData = cdate(rfData)
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
            'Repeticao = "S"
            'rptIntervaloRepeticao = ccur(rptIntervaloRepeticao)*4
            repetirDias = cstr( weekDay(rptDataInicio) )
            diaSemana = weekDay(rptDataInicio)
            nthDiaSemaMes = nth_date(rptDataInicio)
        end if

        rptDataLoop = rptDataInicio
        rptOcorrencias = 0
        Maximo = 200
        while ( (rptTerminaRepeticao="O" and rptOcorrencias<rptRepeticaoOcorrencias) or (rptRepeticaoDataFim<>"O" and rptDataLoop<rptRepeticaoDataFim) ) and rptC<Maximo
            
           ' response.write("xxxxxxxxxxx")
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

                    if  tipoDiaMes="DiaSemana" then
                        datas = datas_da_semana(rptDataLoop,diaSemana)
                        slp = split(datas, ",")
                        max = ubound(slp)+1

                        procurarAqui = nthDiaSemaMes
                        if nthDiaSemaMes > max then
                            procurarAqui = max
                        end if

                        rptDataLoop = DateSerial(year(slp(procurarAqui-1)),Month(slp(procurarAqui-1))+intervaloMensal, Day(slp(procurarAqui-1)))
                    end if

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
                rptOcorrencias = rptOcorrencias+1

                ReDim Preserve listDates(UBound(listDates) + 1)                
                listDates(UBound(listDates)) = "select count(id) >= (select MaximoAgendamentos from procedimentos where id = "&rfProcedimentoId&") as BloquearAgendamento, Data from agendamentos where ProfissionalID = "&rfProfissionalID&" and Hora = '"&rfHora&"' and TipoCompromissoID = "&rfProcedimentoId&" and StaID NOT IN(11,15) and Data = "&mydatenull(rptDataLoop)&""
               ' response.write(mydatenull(rptDataLoop))
            end if
        wend
        ' Response.end    

        queryMaximoAgendamento = Join(listDates, " union all " )
      '  response.write(queryMaximoAgendamento)
       ' response.end
        set existeAgendamentosMaximoConflict = db.execute(queryMaximoAgendamento)

        while not existeAgendamentosMaximoConflict.EOF


        existeAgendamentosMaximoConflict.movenext
        wend
        existeAgendamentosMaximoConflict.close
        set existeAgendamentosMaximoConflict=nothing

        'if existsDatesConflict("BloquearAgendamento") = "1" then
        '    Response.ContentType = "application/json"
        '    Response.write("{""existeAgendamentosFuturos"":  true}")
        '    Response.end
        'end if

      '  Response.ContentType = "application/json"
      '  Response.write("{""existeAgendamentosFuturos"":  false}")     
      '  Response.end            
    end if
end function

function validaConvenio(convenioID, localID)
    validaConvenio=1
    if convenioID&""<>"0" then 
        mUnidadeID = session("UnidadeID")
        if localID&""<>"" then
            if localID <> 0 then    
                set sqlUnidadeID = db.execute("select UnidadeID from locais where id="&localID)
                if not sqlUnidadeID.eof then
                    mUnidadeID = sqlUnidadeID("UnidadeID")
                end if
            end if
        end if

        if mUnidadeID&"" <> "" then
            set PlanoNaUnidadeSQL = db.execute("select id from convenios where sysActive=1 and (unidades like '%|"&mUnidadeID&"|%' or unidades ='' or unidades is null) and id = "&convenioID)
            if PlanoNaUnidadeSQL.eof then
                    validaConvenio=0
            end if
        end if
    end if

end function
%>