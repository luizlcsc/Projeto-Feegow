<!--#include file="connect.asp"-->
<!--#include file="validar.asp"-->
<!--#include file="connectCentral.asp"-->
<!--#include file="Classes/FuncoesRepeticaoMensalAgenda.asp"-->
<!--#include file="Classes/Logs.asp"-->
<!--#include file="AgendamentoUnificado.asp"-->
<!--#include file="Classes/StringFormat.asp"-->
<!--#include file="modulos/audit/AuditoriaUtils.asp"-->
<!--#include file="webhookFuncoes.asp"-->

<%
if request.ServerVariables("REMOTE_ADDR")<>"::1" and request.ServerVariables("REMOTE_ADDR")<>"127.0.0.1" and session("Banco")<>"clinic5856" then
	'on error resume next
end if


if ref("Chegada")<>"" and isdate(ref("Chegada")) then
	HoraSta = formatdatetime(ref("Chegada"), 3)
else
	HoraSta = time()
end if

if ref("ProcedimentoID")="0" or ref("ProcedimentoID")="" then
	erro = "Selecione um procedimento"
end if

if (ref("ProfissionalID")="0" or ref("ProfissionalID")="") AND (ref("EquipamentoID")="0" or ref("EquipamentoID")="") then
	erro = "Selecione o profissional"
end if

if ref("ageCPF")<>"" then
    if CalculaCPF(ref("ageCPF"))=0 then
        erro = "CPF inválido."
    end if
end if



if ref("Hora")="00:00" and ref("Encaixe")="1"  then
	erro = "Escolha um horário para o encaixe."
end if



if cdate(ref("Data"))< date() and aut("agendamentosantigosA")=0 then
    erro = "Não é possível alterar agendamento de datas passadas. Solicite um administrador que realize a operação."
end if


if 0 then
    set veri=db.execute("select Tempo,HoraFinal from agendamentos where isNull(Tempo) or isNull(HoraFinal)")
    if not veri.EOF then
	    db.execute("update agendamentos set Tempo=0 where isNull(Tempo) or Tempo like ''")
	    set p=db.execute("select * from agendamentos where isNull(HoraFinal)")
	    while not p.eof
    '		response.Write("update agendamentos set HoraFinal="& mytime( dateAdd("n",p("Tempo"),cdate( hour(p("Hora"))&":"&minute(p("Hora")) )) )&" where id="&p("id"))
		    db.execute("update agendamentos set HoraFinal="& mytime( dateAdd("n",p("Tempo"),cdate( hour(p("Hora"))&":"&minute(p("Hora")) )) )&" where id="&p("id"))
	    p.moveNext
	    wend
	    p.close
	    set p=nothing
    end if
end if
function somatempo()
controle = 0
    contador = 0
    variavel = ""
    tracinho = ""
    tempoFinal = 0
       
    While controle = 0
        if contador = 1 then
            variavel = 1
            tracinho= "-"
        end if  
        if contador > 1 then
            variavel = variavel +1
        end if  
        tempoLocal =  ref("Tempo"&tracinho&variavel)
        if tempoLocal = "" then
            controle = 1
        else
            tempoLocal = cint(tempoLocal)
            tempoFinal = tempoFinal + tempoLocal
        end if
        contador = contador +1
    wend

    tempoFinal = tempoFinal&""
    somatempo = tempoFinal 
end function 

TempoTotal=somatempo()
rfTempo=ref("Tempo")
rfHora=ref("Hora")
rfProfissionalID=ref("ProfissionalID")
rfEspecialidadeID=ref("EspecialidadeID")
rdEquipamentoID=ref("EquipamentoID")
GradeID = ref("GradeID")
indicacaoID=ref("indicacaoId")
rfData=ref("Data")
if isdate(rfData) then
    rfData = cdate(rfData)
end if

if ref("LocalID")<>"" then
    set LocalSQL = db.execute("SELECT UnidadeID FROM locais WHERE id="&treatvalzero(ref("LocalID")))

    if not LocalSQL.eof then
        AgendamentoUnidadeID=LocalSQL("UnidadeID")
    end if
end if

' ######################### BLOQUEIO FINANCEIRO ########################################
if AgendamentoUnidadeID <> "" then
    contabloqueadacred = verificaBloqueioConta(2, 2, 0, AgendamentoUnidadeID,rfData)
    if contabloqueadacred = "1" or contabloqueadadebt = "1" then
        erro ="Agenda bloqueada para edição retroativa (data fechada)."
    end if
end if
' #####################################################################################


rfProcedimento=ref("ProcedimentoID")
rfrdValorPlano=ref("rdValorPlano")
if rfrdValorPlano="V" then
	rfValorPlano=ref("Valor")
	if rfValorPlano="" or not isnumeric(rfValorPlano) then
		rfValorPlano=0
	end if
else
	rfValorPlano=ref("ConvenioID")
	PlanoID=ref("PlanoID")
end if
rfPaciente=ref("PacienteID")
PacienteID = rfPaciente
PrimeiraVez=0

if PacienteID="0" or PacienteID="" or PacienteID="-1" then
	erro = "Selecione ou insira um paciente."

else
    'verifica se eh primeira consulta do paciente
    set PrimeiroAtendimentoSQL = db.execute("SELECT age.id FROM agendamentos age WHERE sysActive=1 AND PacienteID="&treatvalzero(PacienteID)&" AND StaID IN (1,2,3,4)")
    if PrimeiroAtendimentoSQL.eof then
        PrimeiraVez=1
    end if
end if

rfStaID=ref("StaID")
if ref("LocalID")&""="" then
	rfLocal=0
else
	rfLocal=ref("LocalID")
end if
rfNotas=ref("Notas")
rfSubtipoProcedimento=0'ref("SubtipoProcedimento")'VERIFICAR
ConsultaID=ref("ConsultaID")
rfProgramaID=ref("ProgramaID")


if ConsultaID<>"0" then
	set pCon=db.execute("select * from agendamentos where id = '"&ConsultaID&"'")
    if altCarac>0 and aut("senhaagendaI")=0 and session("SenhaStatusAgenda")="S" then
        if not pCon.eof then
            altCarac = 0
            'se config:alteracao de carac somente mediante senha e usuario nao tem perm, e (status anterior aguard ou atend) e status atual <> aguard ou atend
            if isnumeric(rfValorPlano) and rfValorPlano<>"" then
                ccurValorPlano = ccur(rfValorPlano)
            else
                ccurValorPlano = 0
            end if
            if ((pCon("rdValorPlano")<>rfrdValorPlano or pCon("PacienteID")&""<>rfPaciente or pCon("ValorPlano")<>ccurValorPlano or rfProcedimento<>pCon("TipoCompromissoID")&"") or (rfStaID<>"3" and rfStaID<>"2" and rfStaID<>"4" and rfStaID<>"5")) and (pCon("StaID")=2 or pCon("StaID")=3 or pCon("StaID")=4) then
                altCarac = altCarac + 1
                if ref("autSenha")="" or ref("autUser")="" then
                    erro = "Aguardando senha de autorização."'pCon("rdValorPlano") &" - "& rfrdValorPlano &" | "& pCon("PacienteID")&" - "&rfPaciente &" | "& pCon("ValorPlano") &" - "& ccurValorPlano
                    set usersAut = db.execute("select lu.id, lu.Nome from sys_users su LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=su.id WHERE Permissoes LIKE '%|senhaagendaI|%'")
                    while not usersAut.eof
                        htmlUA = htmlUA &"<label><input type='radio' name='autUser' value='"& usersAut("id") &"'> "& usersAut("Nome") &"</label> <br>"
                    usersAut.movenext
                    wend
                    usersAut.close
                    set usersAut=nothing
                    %>
                    $("#autUsers").html("<%= htmlUA %>");
                    $("#autDiv").removeClass("hidden");
                    $("#autSenha").focus();
                    <%
                else
                    set vSenha = db.execute("select id from cliniccentral.licencasusuarios where id="&ref("autUser")&" and Senha='"& ref("autSenha") &"'")
                    if vSenha.eof then
                        erro = "Senha incorreta."
                    end if
                end if
            end if
        end if
    end if
end if
%>
<!--#include file="errosPedidoAgendamento.asp"-->
<%
if erro="" then
'"Hora=&Paciente=&Procedimento=&StaID=&Local=&rdValorPlano=&ValorPlano=&ProfissionalID=&Data=&Tempo=
	if rfStaID=5 or rfStaID="5" then
	    set LocalSQL = db.execute("SELECT UnidadeID FROM locais WHERE id="&treatvalzero(rfLocal))

	    UnidadeID=session("UnidadeID")
	    if not LocalSQL.eof then
	        UnidadeID=LocalSQL("UnidadeID")
	    end if

		call gravaChamada(rfProfissionalID, rfPaciente, UnidadeID)
	end if
	Notas=replace(replace(rfNotas,"_"," "),"'","''")
	'-->Verifica se paciente já tem esse convênio. Se não, cria esse convênio para esse paciente
	if rfrdValorPlano="P" then
		call gravaConvPac(rfValorPlano, rfPaciente)
	end if

	if ref("ageTabela")<>"" then
	    campoPedirTabela = ", Tabela"
	end if
	camposPedir = "Tel1, Cel1, Email1"&campoPedirTabela

	if session("banco")="clinic811" or session("banco")="clinic5445" then
		camposPedir = "Tel1, Cel1, Email1, Origem"
	end if

    set CamposPedirConfigSQL = db.execute("SELECT * FROM obrigacampos WHERE Recurso='Agendamento'")

    if not CamposPedirConfigSQL.eof then
        Exibir = CamposPedirConfigSQL("Exibir")

        if Exibir&"" <> "" then
            camposPedir= camposPedir &", " & replace(Exibir,"|","")
        end if
    end if

	splCamposPedir = split(camposPedir, ", ")
	
	upPac = ""
	for z=0 to ubound(splCamposPedir)
        nomeindicado = ""
        valp = ref("age"&splCamposPedir(z)&"")

	    if valp ="" then
	        valpac = "NULL"
        elseif isdate(valp) then
	        valpac = mydatenull(valp)
        else
	        valpac = "'"&valp&"'"
	    end if

	    IF "age"&splCamposPedir(z)&"" = "ageCel1" THEN
            valpac = RemoveCaracters(valpac,"-./ ()")
        end if
        IF "age"&splCamposPedir(z)&"" = "ageTel1" THEN
            valpac = RemoveCaracters(valpac,"-./ ()")
        end if
        
	    IF "age"&splCamposPedir(z)&"" = "ageCPF" THEN
            valpac = RemoveCaracters(valpac,"-./")
            valp = RemoveCaracters(valp,"-./")
            hasCpf = true

            'desativado: Apresentando comportamento estranho. Precisa considerar se o paciente esta sendo adicionado ou nao
            IF getConfig("NaoPermitirCPFduplicado") and False THEN
                set PacienteDuplicadoSQL = db.execute("SELECT cpf,id, NomePaciente FROM pacientes WHERE ((cpf='"&valp&"' OR cpf='"&valp&"') and sysActive=1 and '"&valp&"'!='' and id!="&rfPaciente&") ")
                IF not PacienteDuplicadoSQL.eof THEN
                        %>
                        new PNotify({
                            title: 'N&Atilde;O AGENDADO!',
                            text: 'CPF duplicado. Paciente <%= PacienteDuplicadoSQL("NomePaciente") %>',
                            type: 'danger',
                            delay: 3000
                        });
                        <%
                    response.end
                END IF
            END IF

        END IF

        existeTabela = db.execute("select count(id) = 1 as existeTabela from pacientes where Tabela is not null and id="&rfPaciente)
        if  splCamposPedir(z) = "Tabela" and existeTabela("existeTabela") = "1" then
            upPac = upPac&""
        else
            coluna = splCamposPedir(z)
            if splCamposPedir(z)<>"IndicadoPorSelecao" then
                upPac = upPac & coluna &"="&valpac&", "
            end if
        end if
	next

    if ref("Checkin")="1" then
        CPF = RemoveCaracters(ref("CPF")&"",".-/ ")
        'db.execute("update pacientes set NomePaciente='"& ref("NomePaciente") &"', Nascimento="& mydatenull(ref("Nascimento")) &", CPF='"& CPF &"', Sexo="& treatvalzero(ref("Sexo")) &", Cep='"& ref("Cep") &"', Endereco='"& ref("Endereco") &"', Numero='"& ref("Numero") &"', Complemento='"& ref("Complemento") &"', Bairro='"& ref("Bairro") &"', Cidade='"& ref("Cidade") &"', Estado='"& ref("Estado") &"', Pais="& treatvalzero(ref("Pais")) &", Tel2='"& ref("Tel2") &"', Cel2='"& ref("Cel2") &"', Email2='"& ref("Email2") &"', Observacoes='"& ref("Observacoes") &"', Pendencias='"& ref("Pendencias") &"', Profissao='"& ref("Profissao") &"', GrauInstrucao="& treatvalzero(ref("GrauInstrucao")) &", Documento='"& ref("Documento") &"', Naturalidade='"& ref("Naturalidade") &"', EstadoCivil="& treatvalzero(ref("EstadoCivil")) &", Origem="& treatvalzero(ref("Origem")) &", IndicadoPor='"& ref("IndicadoPor") &"', Religiao='"& ref("Religiao") &"', CNS='"& ref("CNS") &"', CorPele="& treatvalzero(ref("CorPele")) &", lembrarPendencias='"& ref("lembrarPendencias") &"' where id="& rfPaciente )
        db.execute("update pacientes set NomePaciente='"& ref("NomePaciente") &"', Nascimento="& mydatenull(ref("Nascimento")) &", CPF='"& CPF &"', Sexo="& treatvalzero(ref("Sexo")) &", Cep='"& ref("Cep") &"', Endereco='"& ref("Endereco") &"', Numero='"& ref("Numero") &"', Complemento='"& ref("Complemento") &"', Bairro='"& ref("Bairro") &"', Cidade='"& ref("Cidade") &"', Estado='"& ref("Estado") &"', Pais="& treatvalzero(ref("Pais")) &", Tel2='"& ref("Tel2") &"', Cel2='"& ref("Cel2") &"', Email2='"& ref("Email2") &"', Observacoes='"& ref("Observacoes") &"', Pendencias='"& ref("Pendencias") &"', Profissao='"& ref("Profissao") &"', GrauInstrucao="& treatvalzero(ref("GrauInstrucao")) &", Documento='"& ref("Documento") &"', Naturalidade='"& ref("Naturalidade") &"', EstadoCivil="& treatvalzero(ref("EstadoCivil")) &", Origem="& treatvalzero(ref("Origem")) &", IndicadoPor='"& nomeindicado &"', Religiao='"& ref("Religiao") &"', CNS='"& ref("CNS") &"', CorPele="& treatvalzero(ref("CorPele")) &", lembrarPendencias='"& ref("lembrarPendencias") &"' where id="& rfPaciente )
    end if

	db.execute("update pacientes set "& upPac &" sysActive=1 where id="&rfPaciente)

	if session("SepararPacientes") then
	    db.execute("update pacientes set Profissionais='|"&rfProfissionalID&"|' where Profissionais IS NULL AND id="&rfPaciente)
    end if

    if req("PreSalvarCheckin")="" then
        '<--Verifica se paciente já tem esse convênio. Se não, cria esse convênio para esse paciente\\
        if ConsultaID="0" then
            sql = "insert into agendamentos (PacienteId, ProfissionalID, Data, Hora, TipoCompromissoID, StaID, ValorPlano, PlanoID, rdValorPlano, Notas, FormaPagto, HoraSta, LocalID, Tempo, HoraFinal, SubtipoProcedimentoID, ConfEmail, ConfSMS, Encaixe, Retorno, EquipamentoID, EspecialidadeID, TabelaParticularID, Primeira, IndicadoPor, sysUser, ProgramaID) values ('"&rfPaciente&"','"&rfProfissionalID&"','"&mydate(rfData)&"','"&rfHora&"','"&rfProcedimento&"','"&rfStaID&"','"&treatVal(rfValorPlano)&"', "&treatvalzero(PlanoID)&",'"&rfrdValorPlano&"','"&Notas&"','0', '"&HoraSta&"',"&treatvalzero(rfLocal)&",'"&rfTempo&"','"&hour(HoraSolFin)&":"&minute(HoraSolFin)&"', '"&rfSubtipoProcedimento&"', '"&ref("ConfEmail")&"', '"&ref("ConfSMS")&"', "&treatvalnull(ref("Encaixe"))&","&treatvalnull(ref("Retorno"))&", "&treatvalnull(ref("EquipamentoID"))&", "& treatvalnull(ref("EspecialidadeID")) &", "& treatvalnull(ref("ageTabela")) &", "&PrimeiraVez&", '"&indicacaoID&"', "&session("User")&", " & treatvalnull(rfProgramaID) & ")"

    		'response.Write(sql&vbcrlf)

    		call gravaLogs(sql, "AUTO", "Agendamento criado", "")

            db.execute(sql)
            set pultCon=db.execute("select id, ProfissionalID from agendamentos order by id desc limit 1")

            call agendaUnificada("insert", pultCon("id"), pultCon("ProfissionalID"))

            DataHoraFeito = now()
            if session("FusoHorario")<>"" then
                FusoHorario = session("FusoHorario")
                if FusoHorario<>-180 and FusoHorario<>-120 and FusoHorario<>-60 then
                    FusoHorario = -180
                end if

                HorasDiferencaFusoHorario= ((FusoHorario / 60) + 3) * -1

                DataHoraFeito = dateadd("h", HorasDiferencaFusoHorario, DataHoraFeito)
            end if
            db.execute("insert into LogsMarcacoes (PacienteID, ProfissionalID, ProcedimentoID, DataHoraFeito, Data, Hora, Sta, Usuario, Motivo, Obs, ARX, ConsultaID, UnidadeID) values ('"&rfPaciente&"', '"&rfProfissionalID&"', '"&rfProcedimento&"', '"&DataHoraFeito&"', '"&mydate(rfData)&"', '"&rfHora&"', '"&rfStaID&"', '"&session("User")&"', '0', '"&Notas&"', 'A', '"&pultCon("id")&"', "&session("UnidadeID")&")")
            ConsultaID = pultcon("id")
            call statusPagto(ConsultaID, rfPaciente, rfData, rfrdValorPlano, rfValorPlano, rfStaID, rfProcedimento, rfProfissionalID)

            txtEmail = "Novo agendamento realizado:<br><br>Data: "& rfData &" - "& rfHora


        else
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
                DataHoraFeito = now()
                if session("FusoHorario")<>"" then
                    FusoHorario = session("FusoHorario")
                    if FusoHorario<>-180 and FusoHorario<>-120 and FusoHorario<>-60 then
                        FusoHorario = -180
                    end if

                    HorasDiferencaFusoHorario= ((FusoHorario / 60) + 3) * -1

                    DataHoraFeito = dateadd("h", HorasDiferencaFusoHorario, DataHoraFeito)
                end if
                db.execute("insert into LogsMarcacoes (PacienteID, ProfissionalID, ProcedimentoID, DataHoraFeito, Data, Hora, Sta, Usuario, Motivo, Obs, ARX, ConsultaID, UnidadeID) values ('"&rfPaciente&"', '"&rfProfissionalID&"', '"&rfProcedimento&"', '"&DataHoraFeito&"', '"&mydate(rfData)&"', '"&rfHora&"', '"&rfStaID&"', '"&session("User")&"', '0', '"&ObsR&"', 'R', '"&ConsultaID&"', "&session("UnidadeID")&")")
            end if

            if rfStaID = 11 or rfStaID = 22 then ' desmarcado e cancelado
                call agendaUnificada("delete", ConsultaID, rfProfissionalID)
            else
                call agendaUnificada("update", ConsultaID, rfProfissionalID)
            end if

            sqlUpdateAgendamento = "update agendamentos set IndicadoPor='"&indicacaoID&"', PacienteId='"&rfPaciente&"', ProfissionalID='"&rfProfissionalID&"', Data='"&mydate(rfData)&"', Hora='"&rfHora&"', TipoCompromissoID='"&rfProcedimento&"', StaID='"&rfStaID&"', ValorPlano='"&treatVal(rfValorPlano)&"', PlanoID="&treatvalzero(PlanoID)&", rdValorPlano='"&rfrdValorPlano&"', Notas='"&Notas&"', FormaPagto='0', HoraSta='"&HoraSta&"', LocalID='"&rfLocal&"', Tempo='"&rfTempo&"' ,HoraFinal='"&hour(HoraSolFin)&":"&minute(HoraSolFin)&"', SubtipoProcedimentoID='"&rfSubtipoProcedimento&"', ConfEmail='"&ref("ConfEmail")&"', ConfSMS='"&ref("ConfSMS")&"', Encaixe="&treatvalnull(ref("Encaixe"))&", Retorno="&treatvalnull(ref("Retorno"))&", EquipamentoID="&treatvalnull(ref("EquipamentoID"))&", EspecialidadeID="& treatvalnull(ref("EspecialidadeID")) &", TabelaParticularID="& refnull("ageTabela") &", ProgramaID=" & treatvalnull(rfProgramaID) & " where id = '"&ConsultaID&"'"

            if ref("Checkin")="1" then
                DescricaoAlteracao = "Check-in"
            else
                DescricaoAlteracao = "Agendamento alterado"
            end if
            call gravaLogs(sqlUpdateAgendamento, "AUTO", DescricaoAlteracao, "")
            db.execute(sqlUpdateAgendamento)

            call statusPagto(ConsultaID, rfPaciente, rfData, rfrdValorPlano, rfValorPlano, rfStaID, rfProcedimento, rfProfissionalID)

        end if
    else
        db_execute("update agendamentos set IndicadoPor='"&indicacaoID&"', EspecialidadeID="& treatvalnull(ref("EspecialidadeID")) &", TabelaParticularID="& treatvalnull(ref("ageTabela")) &" where id = '"&ConsultaID&"'")
    end if

	if (session("Banco")="clinic5445" or session("Banco")="clinic100000") and ref("ageCanal")<>"" then
	    db.execute("UPDATE agendamentos SET CanalID="&treatvalnull(ref("ageCanal"))&" WHERE id="&ConsultaID)
    end if

    if cdate(ref("Data"))< date() then

        if (rfStaID="11" or rfStaID="16" or rfStaID="6" ) and pCon("StaID")&"" <> rfStaID then
            'status de agendamento passado alterado para status em que o atendimento nao foi prestado.

            call registraEventoAuditoria("altera_status_agendamento_passado", ConsultaID, "")
        else
            call registraEventoAuditoria("altera_agendamento_passado", ConsultaID, "")
        end if

    end if


    if session("Banco")="clinic5459" then
        n = 0
        while n<5
            n = n+1
            if ref("EmailAcesso"&n)<>"" or ref("Nome"&n)<>"" or ref("Telefone"&n)<>"" then
                set vca = db.execute("select id from agendamentoscontatos where AgendamentoID="& ConsultaID &" and n="& n)
                sqlRep = "agendamentoscontatos set AgendamentoID='"& ConsultaID &"', EmailAcesso='"& ref("EmailAcesso"&n) &"', Nome='"& ref("Nome"&n) &"', Telefone='"& ref("Telefone"& n) &"', n="& n &", sysUser="& session("User") &" "
                if vca.eof then
                    db.execute("insert into "& sqlRep)
                else
                    db.execute("update "& sqlRep &" where id="& vca("id"))
                end if
            else
                db.execute("delete from agendamentoscontatos where AgendamentoID="& ConsultaID &" and n="& n)
            end if
        wend
    end if

    '-> procedimentos adicionais na agenda
    ProcedimentosAgendamento = trim(ref("ProcedimentosAgendamento"))
    if ProcedimentosAgendamento<>"" then

        if (Mid(ProcedimentosAgendamento,Len(ProcedimentosAgendamento),1) = ",") then
        ProcedimentosAgendamento = Mid(ProcedimentosAgendamento,1,Len(ProcedimentosAgendamento)-1)
        end if
        ProcedimentosAgendamento = replace(ProcedimentosAgendamento, ", ,", ", ")

        db.execute("delete from agendamentosprocedimentos where AgendamentoID="&ConsultaID&" and id not in(0"& ProcedimentosAgendamento &")")
        splPA = split(ProcedimentosAgendamento, ", ")
        for iPA=0 to ubound(splPA)
            if splPA(iPA)&""<>"" then
                apID = ccur( splPA(iPA) )
                apTipoCompromissoID = ref("ProcedimentoID"& apID)
                apTempo = ref("Tempo"& apID)
                aprdValorPlano = ref("rdValorPlano"& apID)
                if aprdValorPlano="V" then
                    apValorPlano = ref("Valor"& apID)
                    applanoId=""
                else
                    apValorPlano = ref("ConvenioID"& apID)
                    applanoId = ref("PlanoID"& apID)
                end if
                apLocalID = ref("LocalID"& apID)
                apEquipamentoID = ref("EquipamentoID"& apID)
                if apID<0 then
                    db.execute("insert into agendamentosprocedimentos (AgendamentoID, TipoCompromissoID, Tempo, rdValorPlano, ValorPlano,PlanoID, LocalID, EquipamentoID) values ("& ConsultaID &", "& treatvalzero(apTipoCompromissoID) &", "& treatvalnull(apTempo) &", '"& aprdValorPlano &"', "& treatvalzero(apValorPlano) &",  "& treatvalzero(applanoId) &","& treatvalzero(apLocalID) &", "& treatvalzero(apEquipamentoID) &")")
                else
                    db.execute("update agendamentosprocedimentos set TipoCompromissoID="& treatvalzero(apTipoCompromissoID) &", Tempo="& treatvalnull(apTempo) &", rdValorPlano='"& aprdValorPlano &"', ValorPlano="& treatvalzero(apValorPlano) &", PlanoID="& treatvalzero(applanoId) &",LocalID="& treatvalzero(apLocalID) &", EquipamentoID="& treatvalzero(apEquipamentoID) &" where id="& apID)
                end if
            end if
        next

    else
        db.execute("delete from agendamentosprocedimentos where AgendamentoID="&ConsultaID)
    end if
    call atuAge(ConsultaID)
    '<- procedimentos adicionais na agenda

    'verifica se status é desmarcado se for muda a ação para remover registro do googlecalendar
    Action = "XI"
    GCNomePaciente = ""
    if rfStaID&"" = "11" or rfStaID&"" = "16" then
        Action = "X"
        GCNomePaciente = "excluir_da_agenda"
    end if

	%>
	if (typeof feegow_components_path !== 'undefined'<% if request.ServerVariables("REMOTE_ADDR")="::1" then response.write("  && 0 ") end if %>){
        $.get(feegow_components_path+"/googlecalendar/save", {Licenca: "<%=LicenseID%>" ,Acao:"<%=Action%>", Email:"vca", AgendamentoID:"<%=ConsultaID%>", ProfissionalID:"<%=rfProfissionalID%>", NomePaciente:"<%=GCNomePaciente%>", Data:"", Hora:"", Tempo:"", NomeProcedimento:"", Notas:""}, function(){})

        <%
        forceNotSendSMS = "false"
        forceNotSendWhatsApp = "false"
        forceNotSendEmail = "false"

        if ref("ConfSMS")="S" or ref("ConfEmail")="S" or True then
            if ref("ConfSMS")="S" then
                forceNotSendSMS = "true"
                forceNotSendWhatsApp = "true"
            end if
            if ref("ConfEmail")="S" then
                forceNotSendEmail = "true"
            end if
            '<ACIONA WEBHOOK ASP PADRÃO PARA NOTIFICAÇÕES WHATSAPP> 
            if recursoAdicional(43) = 4 and ref("ConfSMS")="S" then
                call webhookMessage()
            end if
            '<ACIONA WEBHOOK ASP PADRÃO PARA NOTIFICAÇÕES WHATSAPP>
            %>
            getUrl("patient-interaction/get-appointment-events", {appointmentId: "<%=ConsultaID%>",sms: "<%=ref("ConfSMS")%>"=='S',email:"<%=ref("ConfEmail")%>"=='S' })
            <%
        end if
        %>
	}
    
    <%
    action = "novo_agendamento"

    if ConsultaID<>"0" then
        action = "edita_agendamento"
    end if

    if ref("Checkin")="1" then
        action = "checkin"
    end if

    'call disparaEmail(rfProfissionalID, txtEmail, rfPaciente, rfProcedimento)
'V	if rfrdValorPlano="P" then
'E		set veSePacTemPlano=db.execute("select * from Paciente where id = '"&rfPaciente&"'")
'R		if not veSePacTemPlano.EOF then
'I			if isNull(veSePacTemPlano("Convenio1")) or veSePacTemPlano("Convenio1")=0 then
'F			db.execute("update pacientes set Convenio1='"&rfValorPlano&"' where id = '"&rfPaciente&"'")
'I			end if
'C		end if
'A	end if
	'se deu tudo certo e salvou, faz as acoes abaixo
	%>
        gtag('event', '<%=action%>', {
            'event_category': 'agendamento',
            'event_label': "Botão salvar clicado.",
        });

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
			db.execute("insert into chamadasagendamentos (ChamadaID, AgendamentoID) values ("&vcaCha("id")&", "&ConsultaID&")")
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

                        parocuraraqui = nthDiaSemaMes
                        if nthDiaSemaMes > max then
                            parocuraraqui = max
                        end if

                        rptDataLoop = DateSerial(year(slp(parocuraraqui-1)),Month(slp(parocuraraqui-1))+intervaloMensal, Day(slp(parocuraraqui-1)))
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
                'response.write("console.log('"& rptDataLoop &" - "& weekday(rptDataLoop) &"');")
                rptOcorrencias = rptOcorrencias+1


		        sql = "insert into agendamentos (PacienteId, ProfissionalID, Data, Hora, TipoCompromissoID, StaID, ValorPlano, rdValorPlano, Notas, FormaPagto, HoraSta, LocalID, Tempo, HoraFinal, SubtipoProcedimentoID, ConfEmail, ConfSMS, Encaixe, EquipamentoID, EspecialidadeID, Primeira, IndicadoPor, sysUser) values ('"&PacienteID&"','"&rfProfissionalID&"', "&mydatenull(rptDataLoop)&", '"&rfHora&"','"&rfProcedimento&"','"&rfStaID&"','"&treatVal(rfValorPlano)&"','"&rfrdValorPlano&"','"&Notas&"','0', '"&HoraSta&"',"&treatvalzero(rfLocal)&",'"&rfTempo&"','"&hour(HoraSolFin)&":"&minute(HoraSolFin)&"', '"&rfSubtipoProcedimento&"', '"&ref("ConfEmail")&"', '"&ref("ConfSMS")&"', "&treatvalnull(ref("Encaixe"))&", "&treatvalnull(ref("EquipamentoID"))&", "& treatvalnull(ref("EspecialidadeID")) &", "&PrimeiraVez&", '"&indicacaoID&"', "&session("User")&")"

	
        '		response.Write(sql&vbcrlf)
	
		        db.execute(sql)
                set pult = db.execute("select id, ProfissionalID from agendamentos where PacienteID="& PacienteID &" order by id desc limit 1")
                AgendamentoRepetidoID = pult("id")

                call agendaUnificada("insert", pult("id"), pult("ProfissionalID"))

                db.execute("insert into LogsMarcacoes (PacienteID, ProfissionalID, ProcedimentoID, DataHoraFeito, Data, Hora, Sta, Usuario, Motivo, Obs, ARX, ConsultaID, UnidadeID) values "&_
                "('"&rfPaciente&"', '"&rfProfissionalID&"', '"&rfProcedimento&"', null, '"&mydate(rfData)&"', '"&rfHora&"', '"&rfStaID&"', '"&session("User")&"', '0', 'Agendamento gerado a partir de repetição', 'A', '"&AgendamentoRepetidoID&"', "&treatvalzero(session("UnidadeID"))&")")
                set ap = db.execute("SELECT * FROM agendamentosprocedimentos WHERE AgendamentoID = "&ConsultaID)

                if not ap.eof then
                    while not ap.eof
                        sqlP = "INSERT INTO agendamentosprocedimentos (AgendamentoID,TipoCompromissoID,Tempo,rdValorPlano,ValorPlano,LocalID,EquipamentoID) VALUES ('"&pult("id")&"','"&ap("TipoCompromissoID")&"',"&treatvalzero(ap("Tempo"))&",'"&ap("rdValorPlano")&"',"&ap("ValorPlano")&","&treatvalzero(ap("LocalID"))&","&treatvalzero(ap("EquipamentoID"))&")"
                        'response.write(sqlP)
                        db.execute(sqlP)
                    ap.movenext
                    wend
                    ap.close
                    set ap=nothing
                end if

                itensRepeticao = itensRepeticao &"|"& pult("id") &"|, "
                'replica = 0
            end if
        wend
        if itensRepeticao<>"" then
            'itensRepeticao = left(itensRepeticao, len(itensRepeticao)-2)
            db.execute("insert into agendamentosrepeticoes (AgendamentoID, Agendamentos) values ("&ConsultaID&", '"&itensRepeticao & "|"& ConsultaID &"|')")
        end if
    end if

    'call BaixaAutomatica(rfData, rfProfissionalID, ref("EspecialidadeID"), rfProcedimento, rfrdValorPlano, rfValorPlano, rfPaciente, rfStaID, ConsultaID, ref("ageTabela"))


    if session("Banco")="clinic100000" or session("Banco")="clinic5710" then
        if ref("Restricoes")<>"" then
            splRest = split(ref("Restricoes"), ", ")
            for i=0 to ubound(splRest)
                spl2 = split(splRest(i), "_")
                APID = spl2(0)
                RestricaoID = spl2(1)
                set vcaRespRest = db.execute("select id from procedimentosrestricoesrespostas where AgendamentoID="& ConsultaID &" and AgendamentoProcedimentoID="& treatvalzero(APID) &" and RestricaoID="& RestricaoID &" and sysUser="& session("User"))
                if vcaRespRest.eof then
                    sqlRest = "insert into procedimentosrestricoesrespostas (AgendamentoID, AgendamentoProcedimentoID, RestricaoID, sysUser, Resposta) values ("& ConsultaID &", "& treatvalzero(APID) &", "& RestricaoID &", "& session("User") &", '"& ref("resp"& splRest(i)) &"')"
                    'response.write( sqlRest &"<br>")
                else
                    sqlRest = "update procedimentosrestricoesrespostas set Resposta='"& ref("resp"& splRest(i)) &"' where id="& vcaRespRest("id")
                end if
                db.execute( sqlRest )
            next
        end if
    end if

else
	%>
    new PNotify({
        title: 'Não agendado!',
        text: '<%=erro%>',
        type: 'danger',
        delay: 3000
    });
	<%
end if
%>