<!--#include file="connect.asp"-->
<!--#include file="sqls/sqlUtils.asp"-->
<!--#include file="connectCentral.asp"-->
<%
HorarioAgoraSQL = db.execute("SELECT DATE_FORMAT(NOW(), '%Y-%m-%dT%H:%i:%s') AS now")
HorarioAgora = HorarioAgoraSQL("now")
set config = db.execute("select ChamarAposPagamento from sys_config limit 1")
HorarioVerao="N"
PermiteParticular = True

omitir = ""
if session("Admin")=0 then
	set omit = db.execute("select * from omissaocampos")
	while not omit.eof
		tipo = omit("Tipo")
		grupo = omit("Grupo")
		if Tipo="P" and lcase(session("Table"))="profissionais" and (instr(grupo, "|0|")>0 or instr(grupo, "|"&session("idInTable")&"|")>0) then
			omitir = omitir&lcase(omit("Omitir"))
		elseif Tipo="F" and lcase(session("Table"))="funcionarios" and (instr(grupo, "|0|")>0 or instr(grupo, "|"&session("idInTable")&"|")>0) then
			omitir = omitir&lcase(omit("Omitir"))
		elseif Tipo="E" and lcase(session("Table"))="profissionais" then
			set prof = db.execute("select EspecialidadeID from profissionais where id="&session("idInTable"))
			if not prof.eof then
				if instr(grupo, "|"&prof("EspecialidadeID")&"|")>0 then
					omitir = omitir&lcase(omit("Omitir"))
				end if
			end if
		end if
	omit.movenext
	wend
	omit.close
	set omit = nothing
end if


GradeID = req("GradeID")
Requester = req("Requester")
Encaixe = req("Encaixe")&""

if Encaixe = "-1" then
    Encaixe = "1"
else
    Encaixe = "0"
end if

IF session("PacienteIDSelecionado") <> "" THEN
    PacienteID = session("PacienteIDSelecionado")
    session("PacienteIDSelecionado") = ""
END IF
IF req("PacienteID") <> "" THEN
    PacienteID = req("PacienteID")
END IF

IF req("SolicitanteID") <> "" THEN
    indicadoId = req("SolicitanteID")
END IF

ProcedimentoID = req("ProcedimentoID")
Valor = req("Valor")&""

if ProcedimentoID<>"" then
    set ProcedimentoSelecionadoSQL = db.execute("SELECT Valor FROM procedimentos WHERE id="&treatvalzero(ProcedimentoID))
    if not ProcedimentoSelecionadoSQL.eof then
        if Valor="" then
            Valor=fn(ProcedimentoSelecionadoSQL("Valor"))
        end if
    end if
end if
camposPedir = "Tel1, Cel1, Email1"

if session("banco")="clinic811" or session("banco")="clinic5445" then
    camposPedir = "Tel1, Cel1, Email1, Origem"
end if
if session("banco")="clinic450" then
    camposPedir = "Tel1, Cel1, Nascimento, Email1"
end if



set CamposPedirConfigSQL = db.execute("SELECT * FROM obrigacampos WHERE Recurso='Agendamento'")

if not CamposPedirConfigSQL.eof then
    camposPedir= "Tel1, Cel1, Email1, " & replace(CamposPedirConfigSQL("Exibir"),"|","")
    camposObrigatorioPaciente= CamposPedirConfigSQL("Obrigar")
end if

splCamposPedir = split(camposPedir, ", ")

if request.ServerVariables("REMOTE_ADDR")<>"::1" then
	'on error resume next
end if

ProfissionalID = req("ProfissionalID")
if ProfissionalID="undefined" or ProfissionalID="0" then
    ProfissionalID=""
end if
EquipamentoID = req("EquipamentoID")
if EquipamentoID="0" or EquipamentoID="undefined" then
    EquipamentoID=""
end if
LocalID = req("LocalID")


agendamentoIDSelecionado = req("id")&""

EncaixesExibe=1

if LocalID&""="" or LocalID="undefined" then LocalID=0 end if

if ProfissionalID<>"" and ProfissionalID<>"0" then
    set prof = db.execute("select SomenteConvenios, MaximoEncaixes  from profissionais where id="&ProfissionalID)
    if not prof.eof then
        if isnull(prof("SomenteConvenios")) or prof("SomenteConvenios")="" then
            Convenios = "Todos"
        elseif instr(prof("SomenteConvenios"), "|NONE|") then
            Convenios = "Nenhum"
        else
            SomenteConvenios = prof("SomenteConvenios")&""
            Convenios = replace(SomenteConvenios, "|", "")
        end if
        if not isnull(prof("MaximoEncaixes")) then
            EncaixesExibe = ccur(prof("MaximoEncaixes"))
        else
            EncaixesExibe=-1
        end if
    else
        Convenios = "Todos"
    end if
else
    Convenios = "Todos"
end if

Hora = req("horario")
Hora = left(Hora,2)&":"&mid(Hora, 3, 2)
Data = ""
if req("Data")="" or not isdate(req("Data")) then
	Data = date()
else
	Data = req("Data")
end if
if req("Horario")="00:00" then
	Encaixe = 1
    if ProfissionalID<>"" and ProfissionalID<>"0" then
        set vMax = db.execute("select MaximoEncaixes, (select count(id) from agendamentos where ProfissionalID="&ProfissionalID&" and Encaixe=1 and Data="&mydatenull(Data)&") NumeroEncaixes from profissionais where id="&ProfissionalID&" and not isnull(MaximoEncaixes)")
        if not vMax.EOF then
            NumeroEncaixes = ccur(vMax("NumeroEncaixes"))+1
            MaximoEncaixes = ccur(vMax("MaximoEncaixes"))
            if NumeroEncaixes>MaximoEncaixes then
                %>
                <div class="alert alert-danger text-center erroralert">
                    <i class="far fa-exclamation-triangle"></i> ATEN&Ccedil;&Atilde;O: O n&uacute;mero m&aacute;ximo de <%=MaximoEncaixes %> encaixes permitidos para este profissional j&aacute; foi atingido.
                </div>

                <script >
                    $("#btnSalvarAgenda").attr("disabled", true);
                </script>
                <%
            end if
        end if
    end if
end if
'response.Write("["&Hora&"]")
fieldReadonly = ""

set confEvento = db.execute("SELECT * FROM configeventos WHERE id=1")
if not confEvento.EOF then
    ConfEmail = confEvento("EnvioAutomaticoEmail")
    ConfSMS = confEvento("EnvioAutomaticoSMS")
    ConfWhatsapp = confEvento("EnvioAutomaticoWhatsapp")
    ServicoSMS = confEvento("AtivarServicoSMS")
    ServicoEmail = confEvento("AtivarServicoEmail")
    ServicoWhatsapp = confEvento("AtivarServicoWhatsapp")
end if

if req("id")<>"" and isNumeric(req("id")) then
	AgendamentoID = req("id")
	set buscaAgendamentos = db.execute("select a.*, s.StaConsulta from agendamentos a LEFT JOIN staconsulta s ON s.id = a.StaID where a.id="&req("id"))
else
	set buscaAgendamentos = db.execute("select a.*, s.StaConsulta from agendamentos a LEFT JOIN staconsulta s ON s.id = a.StaID where a.ProfissionalID="&ProfissionalID&" and a.Hora='"&Hora&"' and a.Data='"&mydate(Data)&"'")
	'VERIFICAR -> esse este der mais de um registro no horaio/profissional criar consulta em grupo
end if

if buscaAgendamentos.EOF then
	ConsultaID = 0
	StaID = 1
    ProgramaID = ""
    statusDescricao= ""
else
    'Validar a permissão
    if aut("alterarcheckinpagoA") = 1 then
        if buscaAgendamentos("FormaPagto") = 1 then
            fieldReadonly = " readonly "
        end if
    end if
	Data2 = buscaAgendamentos("Data")
	Hora2 = buscaAgendamentos("Hora")
    if Hora = "" then
        Hora = Hora2
    end if

    if Data = "" or req("id")<>"" then
        Data = Data2
    end if

	ConsultaID = buscaAgendamentos("id")
	PacienteID = buscaAgendamentos("PacienteID")
	Encaixe = buscaAgendamentos("Encaixe")
	Retorno = buscaAgendamentos("Retorno")
    EquipamentoID = buscaAgendamentos("EquipamentoID")
    if session("Banco")="clinic5445" or session("Banco")="clinic5760" then
        ageCanal = buscaAgendamentos("CanalID")
    end if


	ProcedimentoID = buscaAgendamentos("TipoCompromissoID")
	rdValorPlano = buscaAgendamentos("rdValorPlano")
	if rdValorPlano="P" then
		ConvenioID = buscaAgendamentos("ValorPlano")
		PlanoID = buscaAgendamentos("PlanoID")
	else
		Valor = fn(buscaAgendamentos("ValorPlano"))
	end if
	Tempo = buscaAgendamentos("Tempo")
	StaID = buscaAgendamentos("StaID")
	LocalID = buscaAgendamentos("LocalID")
	Notas = buscaAgendamentos("Notas")
	ConfEmail = buscaAgendamentos("ConfEmail")
	TabelaParticularID = buscaAgendamentos("TabelaParticularID")
	ConfSMS = buscaAgendamentos("ConfSMS")
	Chegada = buscaAgendamentos("HoraSta")
	hh = Right("00" & Hour(Chegada), 2)
    nn = Right("00" & Minute(Chegada), 2)
    'Chegada = hh & ":" & nn
    if Chegada&""<>"" then
        Chegada = Hour(Chegada)&":"&Minute(Chegada)
    else
        Chegada = Hour(time)&":"&Minute(time)
    end if

    if LocalID&""="" or LocalID="undefined" then
        LocalID=0
    end if

	ProfissionalID = buscaAgendamentos("ProfissionalID")

    indicadoId = buscaAgendamentos("IndicadoPor")
    ProgramaID = buscaAgendamentos("ProgramaID")
    statusDescricao = buscaAgendamentos("StaConsulta")
end if

if PacienteID<>"" then
    if PacienteID<>"0" then
        set pac = db.execute("select * from pacientes where id="&PacienteID)
        if not pac.eof then
    '		Tel1 = pac("Tel1")
    '		Cel1 = pac("Cel1")
    '		Email1 = pac("Email1")

            if ConsultaID&"" = "0" then
                TabelaValor = pac("Tabela")
            end if
        end if

        if agendamentoIDSelecionado <> "" then
            set agendaInfo = db.execute("select TabelaParticularID from agendamentos where id="&agendamentoIDSelecionado)
            if not agendaInfo.eof then
                TabelaParticularID = agendaInfo("TabelaParticularID")
            end if
        end if

        ageTabela = TabelaValor
        if TabelaParticularID <> "" then
            ageTabela = TabelaParticularID
        end if
    end if
end if

'dah o select pegando os dados do agendamento
'rdValorPlano = agen("rdValorPlano")


'response.Write(Hora)

set vcaVarTab = db.execute("select id from tabelaparticular where Ativo='on' AND sysActive=1")
if not vcaVarTab.eof then
    colPac = 4
    haTab = 1
else
    colPac = 6
    haTab = 0
end if

if isnumeric(req("EquipamentoID")) and req("EquipamentoID")<>"0" then
    'sanderson
    'equipamento está vindo com pacotes quanto esta variavel está vazia
    'oti = ""
    oti = "agenda"
else
    oti = "agenda"
end if

'Trata a formatação do valor contido na variável GradeApenasConvenios
function trataConvenio(GradeApenasConvenios)
    
    GradeApenasConvenios = replace(GradeApenasConvenios, "|P|,", "")
    GradeApenasConvenios = replace(GradeApenasConvenios, "||NONE||", "")
    GradeApenasConvenios = replace(GradeApenasConvenios, "|", "")

    trataConvenio = GradeApenasConvenios
end function

'Metodo para seleção da tabela correta ao ID
function selecionaTabela(GradeID)
    if GradeID < 0 then
        QueryGradeSQL = "SELECT *,''Profissionais FROM assperiodolocalxprofissional WHERE id="&GradeID*-1
    else
        QueryGradeSQL = "SELECT * FROM assfixalocalxprofissional WHERE id="&GradeID
    end if

    selecionaTabela = QueryGradeSQL

end function

'Atualizando valores da grade de convenios
if GradeID<> "" and GradeID<>"undefined" and Convenios<> "Nenhum" then

    GradeSelecionada= selecionaTabela(GradeID)

    set GradeSQL = db.execute(GradeSelecionada)

    if not GradeSQL.eof then
        GradeApenasProcedimentos = GradeSQL("Procedimentos")
        GradeApenasConvenios = GradeSQL("Convenios")
        GradeEquipamentoApenasProfissionais = GradeSQL("Profissionais")
        if GradeApenasConvenios <> "" then
            if instr(GradeApenasConvenios,"|P|")=0 then
                PermiteParticular = False
            end if
            GradeApenasConvenios = trataConvenio(GradeApenasConvenios)&""
            Convenios = GradeApenasConvenios

            if GradeApenasConvenios="P" then
                Convenios = "Nenhum"
            end if
        end if
        
        if not isnull(GradeSQL("MaximoEncaixes")) and GradeSQL("MaximoEncaixes")<>"" then
            MaximoEncaixes = GradeSQL("MaximoEncaixes")
        end if
    end if
else
    GradeID=""
end if

'verificar convenios pelo local e pela unidade
mUnidadeID = session("UnidadeID")
if LocalID <> 0 then
    set sqlUnidadeID = db.execute("select UnidadeID from locais where id="&treatvalzero(LocalID))
    if not sqlUnidadeID.eof then
        mUnidadeID = sqlUnidadeID("UnidadeID")
    end if
end if

if Convenios = "Todos" then
    sqlconveniosexibir2 = "select group_concat(id) exibir from convenios where sysActive=1 and (unidades like'%|"&mUnidadeID&"|%' or unidades ='' or unidades is null or unidades=0)"
    set conveniosexibir2 = db.execute(sqlconveniosexibir2)
    if not conveniosexibir2.eof then
        ExibirConvenios = conveniosexibir2("exibir")

        if not isnull(conveniosexibir2("exibir")) then
            Convenios = conveniosexibir2("exibir")
        end if
    end if
else
 if Convenios <> "Nenhum" then
    sqlconveniosexibir2 = "SELECT GROUP_CONCAT('|',id,'|') naoexibir"&_
                        " FROM convenios"&_
                        " WHERE sysActive=1 AND unidades not LIKE'%|"&mUnidadeID&"|%' and unidades <> ''"
    set conveniosexibir2 = db.execute(sqlconveniosexibir2)

    if not conveniosexibir2.eof then
        ConveniosSpt = split(Convenios,",")
        novoConvenio = ""
        For i=0 To ubound(ConveniosSpt)
            if novoConvenio<>"" then novoConvenio =novoConvenio&"," end if
            novoConvenio = novoConvenio&"|"&ConveniosSpt(i)&"|"
        Next

        naoExibir = conveniosexibir2("naoexibir")&""
        naoExibirSpt = split(naoExibir,",")
        For i=0 To ubound(naoExibirSpt)
            novoConvenio = replace(novoConvenio,","&naoExibirSpt(i),"")
        Next

        Convenios=replace(novoConvenio,"|","")
    end if

 end if
end if

if req("id")="0" and aut("|agehorantI|")=0 and isdate(Data) and isdate(Hora) and req("horario")<>"00:00" then
    if cdate(Data&" "&Hora)<now() then
    %>
<script>
    alert('Você não pode criar agendamentos em horários passados.');
    af('f'); crumbAgenda();
</script>
    <div class="alert alert-danger">
        Você não pode criar agendamentos em horários passados.
    </div>
    <%
    end if
end if
%>
<div class="panel">
<div class="panel-heading">
    <ul class="nav panel-tabs-border panel-tabs panel-tabs-left" id="myTab4">
        <li id="liAgendamento" class="active abaAgendamento"><a data-toggle="tab" onclick="crumbAgenda();" href="#dadosAgendamento"><i class="far fa-calendar"></i> <span class="hidden-xs">Agendamento</span></a></li>
        <li id="abaFicha" class="abasAux abaAgendamento"><a data-toggle="tab" onclick="ajxContent('Pacientes&Agenda=1&AgendamentoID=<%=agendamentoIDSelecionado%>', $('#PacienteID').val(), '1', 'divDadosPaciente'); $('#alertaAguardando').removeClass('hidden'); toRequired()" href="#divDadosPaciente"><i class="far fa-user"></i> <span class="hidden-xs">Ficha</span></a></li>
        <li id="abaHistorico" class="abasAux abaAgendamento"><a data-toggle="tab" onclick="ajxContent('HistoricoPaciente&PacienteID='+$('#PacienteID').val(), '', '1', 'divHistorico'); " href="#divHistorico"><i class="far fa-list"></i> <span class="hidden-xs">Hist&oacute;rico</span></a></li>
        <%if Aut("contapac")=1 or aut("|areceberpaciente")=1 then%>
	        <li id="abaConta" class="abasAux abaAgendamento hidden-xs"><a data-toggle="tab" onclick="$('#divHistorico').html('Carregando...'); ajxContent('Conta', $('#PacienteID').val(), '1', 'divHistorico'); $('#alertaAguardando').removeClass('hidden'); $('#pagar').remove();" href="#divHistorico"><i class="far fa-money"></i> <span class="hidden-xs">Conta</span></a></li>
        <% End If %>
	</ul>



<span class="panel-controls" onclick="javascript:af('f'); crumbAgenda();">
    <i class="far fa-arrow-left"></i> <span class="hidden-xs">Voltar</span>
</span>



</div>
<div class="panel-body">
    <%
    if Requester="MultiplaFiltros" then
    %>
<div class="col-md-12" id="div-obs-profissional" style="display:none">
    <div class="alert alert-default">
        <strong class="nome-profissional"></strong> <br> <span class="obs-profissional"></span>
    </div>
</div>
    <%
    end if
    %>
    <input type="hidden" id="AgAberto" value="<%= ProfissionalID &"_"& Data &"_"& Hora %>" />

    <% if (StaID=1 or StaID=7 or StaID=15) and cdate(Data)=date() and 0 then %>
        <div class="alert alert-warning hidden" id="alertaAguardando">Caso o paciente tenha chegado, mude o status para aguardando.</div>
    <% end if %>

    <div id="tabContentCheckin" class="tab-content">
    <div id="dadosGuiaConsulta"></div>
    <div id="dadosAgendamento" class="tab-pane in active">
        <form onsubmit="submitAgendamento(true); return false;" method="post" action="" id="formAgenda" name="formAgenda">
        <input type="hidden" name="ConsultaID" id="ConsultaID" value="<%=ConsultaID%>" />
        <input type="hidden" name="GradeID" id="GradeID" value="<%=GradeID%>" />

        <div class="modal-body">
            <div class="bootbox-body">
            <% Pagador = indicadoId %>
            <br>
                <div class="panel hidden" id="autDiv">
                    <div class="panel-heading warning">
                        <span class="panel-title">Esta ação requer a autorização de um dos usuários abaixo:</span>
                    </div>
                    <div class="panel-body">
                        <div class="alert alert-warning" id="autUsers"></div>
                        <input type="password" name="autSenha" placeholder="Digite a senha" class="form-control" autocomplete="off" />
                    </div>
                </div>

        <%
		set msgs = db.execute("select DataHora,Resposta from agendamentosrespostas where AgendamentoID = '"&AgendamentoID&"' and AgendamentoID<>0")
		while not msgs.eof
			%>
			<span class="label label-alert">Paciente respondeu em <%=msgs("DataHora")%>: <em><%=msgs("Resposta")%></em></span>
			<%
		msgs.movenext
		wend
		msgs.close
		set msgs = nothing

        HoraReadonly = ""
        if req("horario")<>"00:00" and req("horario")<>"0001" then
            HoraReadonly = " readonly"
        end if
        if Encaixe=1 and aut("horariosencaixeA")=1 then
            HoraReadonly = ""
        end if

        ProfissionaisEquipamentos = replace(GradeEquipamentoApenasProfissionais&"","|","")
        if ProfissionaisEquipamentos&"" = "" then
            ProfissionaisEquipamentos="0"
        end if



        %>
        <div class="row">
			<%= quickField("datepicker", "Data", "Data", 2, cdate(Data), "", "", " required no-datepicker readonly") %>
            <%= quickField("timepicker", "Hora", "Hora", 2, Hora, "", "", " data-time="""&Hora&""" required"&HoraReadonly) %>

            <div class="col-md-1"><br>

            	<div class="checkbox-custom checkbox-alert"<%if EncaixesExibe=0 or aut("agendamentoencaixe")=0 then%> style="display:none"  <%end if %>>
                    <input type="checkbox" name="Encaixe" id="Encaixe" value="1" <%if Encaixe=1 then%> disabled checked<%end if%>><label for="Encaixe" class="checkbox"> Encaixe</label>
                </div>
            	<%
                if Encaixe=1 then
                %>
                <input type="hidden" name="Encaixe" value="1">
                <%
                end if
                %>
            </div>
            <div class="col-md-1"><br>
                <%
                if getConfig("OcultarBotaoRetorno")&""="0" then
                %>
                    <div class="checkbox-custom checkbox-warning"><input type="checkbox" name="Retorno" id="Retorno" value="1" <%if Retorno=1 then%>checked<%end if%>><label for="Retorno" class="checkbox"> Retorno</label></div>
                <%
                else
                %>
                    <input type="checkbox" class="hidden" name="Retorno" id="Retorno" value="1" <%if Retorno=1 then%>checked<%end if%>>
                <%
                end if
                %>
            </div>

			<%if req("Tipo")="Quadro" or req("ProfissionalID")="" or req("ProfissionalID")="0" or req("ProfissionalID")="null" then%>
                <%= quickField("simpleSelect", "ProfissionalID", "Profissional", 2, ProfissionalID, "select id, NomeProfissional from profissionais where sysActive=1 and Ativo='on' AND (id IN ("&ProfissionaisEquipamentos&") or '"&ProfissionaisEquipamentos&"'='0') order by NomeProfissional", "NomeProfissional", " required") %>
            <%else %>
                <div class="col-md-2">
                    <input type="hidden" name="ProfissionalID" id="ProfissionalID" value="<%=ProfissionalID%>" />
                </div>
            <%end if %>

            <div class="col-md-2" id="divEspecialidadeID">
                <% server.execute("divEspecialidade.asp") %>
            </div>



                    <div class="col-md-2">
                    <input type="hidden" name="Checkin" value="<%= req("Checkin") %>" />
                    <%
					if StaID=4 or StaID=101 then
						colCheg = "6"
						disCheg = "block"
					else
						colCheg = "12"
						disCheg = "none"
					end if

                    if req("Checkin")="1" then
					    %>
                        <div class="row">
                            <div class="col-md-12">
                                <input type="hidden" name="StaID" id="StaID" value="4" />
                                <%
                                HoraChegada=time()
                                if HorarioVerao="" then
                                    HoraChegada = dateadd("h", -1, Time())
                                end if
                                %>
                                <input type="hidden" name="Chegada" id="Chegada" value="<%= HoraChegada %>" />
                            </div>
                        </div>
                        <%
                    else
                        %>

                        <div class="row">
                	        <div class="col-md-<%=colCheg%>" id="divStatus">
                                <label>Status</label><br />
	                	        <select name="StaID" id="StaID" class="form-control">
                                <%
						        set sta = db.execute("select id,StaConsulta from StaConsulta order by StaConsulta")
						        while not sta.eof
							        %>
							        <option value="<%=sta("id")%>"<%if StaID=sta("id") then%> selected="selected"<%end if%> style="background-image:url(assets/img/<%=sta("id")%>.png); background-repeat:no-repeat; padding-left:22px; background-position:3px 3px"><%=sta("StaConsulta")%></option>
							        <%
						        sta.movenext
						        wend
						        sta.close
						        set sta=nothing
						        %>
                    	        </select>
                            </div>
                            <div class="col-md-6" id="divChegada" style="display:<%=disCheg%>">
                    	        <label>Chegada</label><br>
						        <%= quickField("text", "Chegada", "", 2, Chegada, "input-mask-l-time", "", "") %>
                            </div>
                        </div>
                        <%
                    end if
                        %>
                    </div>




        </div>

        <div class="row pt20">
                <script type="text/javascript">
                function sipac(Ipac){
                    if(Ipac>1000000000){
                        $.get("baseExt.asp?OP=insert&I="+Ipac, function(data){ eval(data) });
                    }
                    $.get("ListaPropostas.asp?Origem=Agenda&PacienteID="+ Ipac+ "&CallID=-999", function(data){
                        if(data.length>5){
                            $("#modal-table").modal("show");
                            $("#modal").html(data);
                        }
                     });
                }
            </script>
            <div class="col-md-<%= colPac %>">
                <%
                'ALTERAÇÃO DE PACIENTES APÓS O AGENDAMENTO NÃO É PERMITIDO | 10/03/2021
                if agendamentoIDSelecionado<>"" and agendamentoIDSelecionado<>"0" then 
                    pacienteInputClass = "style=""display:none;"""
                    set PacienteSQL = db.execute("select NomePaciente from pacientes where id="&pacienteId)
                        pacienteNome = "<label>Paciente</label><br>"&PacienteSQL("NomePaciente")
                    PacienteSQL.close
                    set PacienteSQL = nothing
                end if
                %>
                <span <%=pacienteInputClass%>>
                    <%=selectInsert("Paciente", "PacienteID", PacienteID, "pacientes", "NomePaciente", " onchange=""sipac(this.value); parametros(this.id, this.value);""", "required", "")%>
                </span>
                <%=pacienteNome%>
            </div>
			<%
			for i=0 to ubound(splCamposPedir)
			    valorCampo=""
				if isobject(pac) then
					if not pac.eof then
					    if splCamposPedir(i)<>"" then
					        if splCamposPedir(i)<>"IndicadoPorSelecao" then
                                valorCampo = pac(""&splCamposPedir(i)&"")
					        end if
                        end if
					end if
				end if

				if splCamposPedir(i)<>"IndicadoPorSelecao" then
                    set dField = db.execute("select c.label, c.selectSQL, c.selectColumnToShow, tc.typeName from cliniccentral.sys_resourcesfields c LEFT JOIN cliniccentral.sys_resourcesfieldtypes tc on tc.id=c.fieldTypeID WHERE c.ResourceID=1 AND c.columnName='"&splCamposPedir(i)&"'")
                    if not dField.EOF then
                        colMd=2

                        if instr(Omitir, "|"&lcase(splCamposPedir(i))&"|") then
                        %>
                            <input type="hidden" name="age<%=splCamposPedir(i)%>" id="age<%=splCamposPedir(i)%>" value="<%=valorCampo%>">
                            <%
                        else
                            if instr(camposObrigatorioPaciente, "|"&splCamposPedir(i)&"|") then
                                camposRequired=" required"
                            else
                                camposRequired=""
                            end if
                            if dField("typeName") = "simpleSelect" then
                                camposRequired = camposRequired & " empty"
                            end if
                            sqlOrClass = dField("selectSQL")
                             if instr(lcase(splCamposPedir(i)), "cpf")>0 then
                                colMd=3
                                sqlOrClass = "input-mask-cpf"

                            end if
                            %><input type="text" name="ageEmail10" class="form-control hidden" autocomplete="off" />
                            <%= quickField(dField("typeName"), "age"&splCamposPedir(i), dField("label"), colMd, valorCampo, sqlOrClass, dField("selectColumnToShow"), " autocomplete='campo-agenda' no-select2 datepicker-vazio "&camposRequired&" "&fieldReadonly) %>
                        <%end if

                    end if
                end if
			next
			'and req("Checkin")<>"1"
            if haTab and req("Checkin")<>"1" then
                if session("Banco")="clinic6102" or session("Banco")="clinic6118" then
                    tabelaRequired=" required "
                end if
                call quickField("simpleSelect", "ageTabela", "Tabela", 2, ageTabela, "select id, NomeTabela from tabelaparticular where Ativo='on' AND sysActive=1 and (Unidades like '' or Unidades = "&session("UnidadeID")&" or Unidades like '%|"& session("UnidadeID") &"|%') order by NomeTabela", "NomeTabela", " empty no-select2  onchange=""$.each($('.linha-procedimento'), function(){ parametros('ProcedimentoID'+$(this).data('id'),$(this).find('select[data-showcolumn=\'NomeProcedimento\']').val()); });"" "&tabelaRequired&" "&fieldReadonly)
            end if

            if getConfig("ExibirCampoCanal")=1 then
                if ageCanal<>1 then
                    if session("Banco")="clinic5445" then
                        canalRequired = "required"
                    end if

                    call quickField("simpleSelect", "ageCanal", "Canal", 2, ageCanal, "select id, NomeCanal from agendamentocanais where sysActive=1 AND ExibirNaAgenda='S' order by NomeCanal", "NomeCanal", " no-select2 "&canalRequired&" empty")
                end if
            end if
            %>

            <% if instr(camposPedir, "IndicadoPorSelecao")>0 then
                ObrigarCampoIndicado = ""
                if instr(camposObrigatorioPaciente, "IndicadoPorSelecao")>0 then
                    ObrigarCampoIndicado = " required "
                end if
            %>
                <div class="col-md-3">
                    <%= selectInsertCA("Indicação", "indicacaoId", Pagador, "5, 8", " onclick=""autoPC($(this).attr(\'data-valor\')) "" ", " "&fieldReadonly&ObrigarCampoIndicado, "") %>
                </div>
            <% end if %>

            <%
            ' Select de Programas de Saúde 
            if getConfig("ExibirProgramasDeSaude") = 1 then
                sqlSelectProgramas = "SELECT p.id, p.NomePrograma FROM programas p " &_
                                     "INNER JOIN profissionaisprogramas pp ON p.id = pp.ProgramaID " &_
                                     "LEFT JOIN pacientesprogramas pap ON pap.ProgramaID = p.id " &_
                                     "WHERE pp.ProfissionalID = '" & ProfissionalID &"' AND pp.sysActive = 1 "
                if PacienteID <> "" then
                    sqlSelectProgramas = sqlSelectProgramas & " AND pap.PacienteID = '" & PacienteID & "' AND pap.sysActive = 1 "
                end if
                if ConvenioID <> "" and ConvenioID <> 0 then
                    sqlSelectProgramas = sqlSelectProgramas & " AND (p.ConvenioID IS NULL OR p.ConvenioID = '" & ConvenioID & "') "
                end if
                sqlSelectProgramas = sqlSelectProgramas & " GROUP BY p.id ORDER BY p.NomePrograma"
                call quickField("simpleSelect", "ProgramaID", "Programa de Saúde", 3, ProgramaID, sqlSelectProgramas, "NomePrograma", " no-select2 empty onchange=""parametros(this.id, this.value)""")
            end if
             %>
        </div>


<%
if session("Banco")="clinic5459" then
    %>
    <hr class="short alt">
    <div class="panel">
        <div class="panel-heading">
            <span class="panel-title">Pessoas de contato</span>
            <span class="panel-controls"><i class="btn btn-success btn-xs far fa-plus"></i></span>
        </div>
        <div class="panel-body" id="agendamentosContatos">
            <% server.execute("agendamentosContatos.asp") %>
        </div>
    </div>
    <%
end if
%>


        <% if req("Checkin")="1" then %>
            <hr class="short alt" />
            <div class="row pt20 checkin-conteudo-paciente">
                <% server.execute("AgendamentoCheckin.asp") %>
            </div>

        <% end if %>


        <div id="divAgendamentoCheckin">
            <!--#include file="agendamentoProcedimentos.asp"-->
        </div>



                        <hr class="alt short">
                        <%

                        set OutrosAgendamentosSQL = db.execute("SELECT a.id, prof.NomeProfissional, proc.NomeProcedimento, a.Data, a.Hora "&_
                        "FROM agendamentos a "&_
                        "INNER JOIN profissionais prof ON prof.id=a.ProfissionalID "&_
                        "INNER JOIN procedimentos proc ON proc.id=a.TipoCompromissoID "&_
                        "WHERE a.PacienteID="&treatvalzero(PacienteID)&" AND a.sysActive=1 AND a.Data="&mydatenull(Data)&" AND a.Hora <> "&mytime(Hora)&" ORDER BY a.Hora")
                        if not OutrosAgendamentosSQL.eof then
                            %>
                            <h4>Este paciente possui outros agendamentos nessa data.</h4>

                            <table class="table table-striped">
                                <thead>
                                    <tr class="warning">
                                        <th>Hora</th>
                                        <th>Profissional</th>
                                        <th>Procedimento</th>
                                        <th>#</th>
                                    </tr>
                                </thead>

                                <tbody>
                                <%
                                while not OutrosAgendamentosSQL.eof
                                    %>
                                    <tr>
                                        <td><%=ft(OutrosAgendamentosSQL("Hora"))%></td>
                                        <td><%=OutrosAgendamentosSQL("NomeProfissional")%></td>
                                        <td><%=OutrosAgendamentosSQL("NomeProcedimento")%></td>
                                        <td><button type="button" onclick="abreAgenda('<%=replace(ft(OutrosAgendamentosSQL("Hora")),":","")%>', '<%=OutrosAgendamentosSQL("id")%>', '<%=OutrosAgendamentosSQL("Data")%>')" class="btn btn-primary btn-xs"><i class="far fa-external-link"></i></button></td>
                                    </tr>
                                    <%
                                OutrosAgendamentosSQL.movenext
                                wend
                                OutrosAgendamentosSQL.close
                                set OutrosAgendamentosSQL = nothing
                                %>
                                </tbody>
                            </table>
                            <hr class="alt short">
                            <%
                        end if
                        %>
                <div class="row">
                    <div class="col-md-8">
                        <div class="row">
                        <%
						set s = dbc.execute("select EventoID, EnviadoEm, WhatsApp, Resultado from cliniccentral.smshistorico where AgendamentoID="&ConsultaID&" and AgendamentoID<>0 and LicencaID="&replace( session("banco"), "clinic", "" ))
						set m = dbc.execute("select EventoID, EnviadoEm from cliniccentral.emailshistorico where AgendamentoID="&ConsultaID&" and AgendamentoID<>0 and LicencaID="&replace( session("banco"), "clinic", "" ))

						set smsFila = dbc.execute("select EventoID, DataHora, EventoID, WhatsApp from cliniccentral.smsfila where AgendamentoID="&ConsultaID&" and AgendamentoID<>0 and LicencaID="&replace( session("banco"), "clinic", "" ))
						set emailsFila = dbc.execute("select EventoID, DataHora, EventoID from cliniccentral.emailsfila where AgendamentoID="&ConsultaID&" and AgendamentoID<>0 and LicencaID="&replace( session("banco"), "clinic", "" ))


						if not s.eof then
							SMSEnviado = "S"
						end if
						if not m.EOF then
							EmailEnviado = "S"
						end if


                        if ConsultaID=0 then
                        response.write("    <div class=""col-md-4"">")
                            IntervaloRepeticao = 1
						    %>
                                <div class="checkbox-custom checkbox-success"><input name="rpt" id="rpt" onclick="rpti();" value="S" type="checkbox"<%if rpt="S" and rpt="" then%> checked="checked"<%end if%> /><label for="rpt"> Repetir</label></div>
                            <%
                        response.write("    </div>")
                        end if

                        if recursoAdicional(31)=4 or recursoAdicional(43)=4 or recursoAdicional(49)=4 then
                            LabelSmsZap = "WhatsApp"
                            idSmsZap = "ConfWhatsapp"
                        else
                            LabelSmsZap = "SMS"
                            idSmsZap = "ConfSMS"
                        end if
						%>

                            <div class="col-md-4">
                            <%if ServicoSMS="S" or ServicoWhatsapp="S" then%>
                                <div class="checkbox-custom checkbox-primary"><input name="<%=idSmsZap%>"  id="<%=idSmsZap%>" value="S" <% if getConfig("SMSEmailSend") = 1 then %> onclick="return false;" <% end if %> type="checkbox"<%if ConfSMS="S" and SMSEnviado<> "S" or ConfWhatsapp="S" then%> checked="checked"<%end if%> /><label for="<%=idSmsZap%>"> Enviar <%=LabelSmsZap%></label></div>
                            <%end if%>
                                <%
								'response.Write("select EnviadoEm, WhatsApp from cliniccentral.smshistorico where AgendamentoID="&ConsultaID&" and LicencaID="&replace( session("banco"), "clinic", "" ))
								while not s.eof
								    SmsOuWhatsApp="SMS enviado em "
								    enviadoEm = s("EnviadoEm")
								    if s("WhatsApp") then
								        SmsOuWhatsApp="WhatsApp enviado em "

								        if s("Resultado") = "400" then
								            enviadoEm = ""
								            SmsOuWhatsApp = "Falha no envio - problema de conexão com o celular"
								        end if
								    end if

								    DescricaoEvento=""

								    if s("EventoID")&""<>"" then
								        'set EventoSQL = db.execute("SELECT Descricao FROM eventos_emailsms WHERE id="&smsFila("EventoID"))
								        'if not EventoSQL.eof then
								        '    DescricaoEvento=" ("&EventoSQL("Descricao")&")"
								        'end if
                                    end if

									%>
									<br><small><em><i class="far fa-check"></i> <%=SmsOuWhatsApp%><%=DescricaoEvento%>  <strong><%=enviadoEm%></strong></em></small>
									<%
								s.movenext
								wend
								s.close
								set s=nothing

								while not smsFila.eof
								    SmsOuWhatsApp="SMS"
								    if smsFila("WhatsApp") then
								        SmsOuWhatsApp="WhatsApp"
								    end if

								    DescricaoEvento=""

								    if smsFila("EventoID")&""<>"" then
								        'set EventoSQL = db.execute("SELECT Descricao FROM eventos_emailsms WHERE id="&smsFila("EventoID"))
								        'if not EventoSQL.eof then
								        '    DescricaoEvento=" ("&EventoSQL("Descricao")&")"
								        ' end if
                                    end if

									%>
									<br><small><em><i class="far fa-history"></i> <%=SmsOuWhatsApp%><%=DescricaoEvento%> programado para <strong><%=smsFila("DataHora")%></strong></em></small>
									<%
								smsFila.movenext
								wend
								smsFila.close
								set smsFila=nothing
								%>
                            </div>
                            <div class="col-md-4">
                            <%if ServicoEmail="S" then%>
                                <div class="checkbox-custom checkbox-primary"><input name="ConfEmail"  id="ConfEmail" value="S" type="checkbox"<%if ConfEmail="S" and EmailEnviado<> "S" then%> checked="checked"<%end if%> /><label for="ConfEmail"> Enviar E-mail</label></div>
                            <%end if%>

                                <%
								while not m.eof
									%>
									<br><small><em>E-mail enviado em <%=m("EnviadoEm")%></em></small>
									<%
								m.movenext
								wend
								m.close
								set m=nothing


								while not emailsFila.eof

								    DescricaoEvento=""

								    if emailsFila("EventoID")&""<>"" then
								        'set EventoSQL = db.execute("SELECT Descricao FROM eventos_emailsms WHERE id="&smsFila("EventoID"))
								        'if not EventoSQL.eof then
								        '    DescricaoEvento=" ("&EventoSQL("Descricao")&")"
								        ' end if
                                    end if

									%>
									<br><small><em><i class="far fa-mail"></i>Envio<%=DescricaoEvento%> programado para <strong><%=emailsFila("DataHora")%></strong></em></small>
									<%
								emailsFila.movenext
								wend
								emailsFila.close
								set emailsFila=nothing
								%>
                            </div>
                        </div>
                        <div class="row hidden" id="divRpt">
                        	<div class="col-md-12">
                                <div class="row">
                                    <table class="table">
                                        <tr>
                                            <td>Repetição:</td>
                                            <td>
                                                <select name="Repeticao" id="Repeticao" class="form-control">
                                                    <option value="D" data-description="dias">Todos os dias</option>
                                                    <option value="S" data-description="semanas" selected>Semanal</option>
                                                    <option value="M" data-description="meses">Mensal</option>
                                                    <option value="A" data-description="anos">Anual</option>
                                                </select>


                                                <%'=quickfield("simpleSelect", "Repeticao", "", 12, Repeticao, "select 'D'id, 'Todos os dias' Tipo UNION ALL select 'S', 'Semanal:' UNION ALL select 'M', 'Mensal' UNION ALL select 'A', 'Anual'", "Tipo", "") %></td>
                                        </tr>
                                        <tr>
                                            <td>Repete a cada:</td>
                                            <td>
                                                <div class="input-group">
                                                    <%=quickfield("number", "IntervaloRepeticao", "", 12, IntervaloRepeticao, "", "", " min=1 max=30 maxlegth=2") %>
                                                    <span class="input-group-addon" id="rptDescricao">
														semanas
													</span>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr id="rptDS">
                                            <td>Repete:</td>
                                            <td nowrap>
                                                <%
                                                    DiaSemana = weekday(Data)

                                                c=0
                                                while c<7
                                                    c=c+1
                                                    %>
                                                    <label>
                                                            <input type="checkbox" class="ace" name="repetirDias" value="<%=c %>"<%if DiaSemana=c then response.write(" checked ") end if %> /><span class="lbl"> <%=left(ucase(weekdayname(c)), 3) %></span>
                                                    </label>
                                                    &nbsp;
                                                    <%
                                                wend
                                                %>
                                            </td>
                                        </tr>
                                        <tr id="rptDM" class="hidden">
                                            <td>Considerar:</td>
                                            <td>
                                                <label><input type="radio" class="ace" name="tipoDiaMes" value="Dia" checked /><span class="lbl"> dia corrido do mês</span></label>
                                                <label><input type="radio" class="ace" name="tipoDiaMes" value="DiaSemana" /><span class="lbl"> dia da semana equivalente</span></label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Início em:</td>
                                            <td>
                                                <%=quickfield("datepicker", "InicioRepeticao", "", 12, Data, "", "", " disabled ") %>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Termina:</td>
                                            <td>
                                                <div class="row col-xs-12">
                                                    <label><input type="radio" class="ace" name="TerminaRepeticao" value="N" checked /><span class="lbl"> Nunca </span></label>
                                                </div>
                                                <div class="row">
                                                    <div class="col-xs-3">
                                                        <label><input type="radio" class="ace" name="TerminaRepeticao" value="O" /><span class="lbl"> Após </span></label>
                                                    </div>
                                                    <div class="col-xs-3">
                                                        <input type="number" class="form-control" name="RepeticaoOcorrencias" value="<%=RepeticaoOcorrencias %>" />
                                                    </div>
                                                    <div class="col-xs-6">
                                                        Ocorrências
                                                    </div>
                                                </div>
                                                <div class="row">
                                                    <div class="col-xs-3">
                                                        <label><input type="radio" class="ace" name="TerminaRepeticao" value="D" /><span class="lbl"> Em </span></label>
                                                    </div>
                                                    <div class="col-xs-9">
                                                        <%=quickfield("datepicker", "RepeticaoDataFim", "", 9, RepeticaoDataFim, "", "", "") %>
                                                    </div>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>


                                </div>
                            </div>
                        </div>

                    </div>
                    <%= quickField("memo", "Notas", " ", 4, Notas, "", "", " placeholder=""Observações"" ") %>


                </div>








            </div>
        </div>
        <div class="">
        <%if session("banco")="clinic1773" then%>
        <button class="btn btn-sm btn-primary" title="Enviar sms personalizado." type="button" style="float: left;" id="btnSendSms">
                        <i class="far fa-mobile"></i>
                    </button>
        <%end if

        if ConsultaID<>0 then
        %>

        <div class="col-xs-6 col-md-1 pt10">
            <button class="btn btn-sm btn-default btn-block" type="button" onClick="printAgendamento();">
                <i class="far fa-print"></i>
            </button>
        </div>
        <%
        set AgendamentoTeleconsultaSQL = db.execute("SELECT proc.ProcedimentoTelemedicina FROM agendamentos age INNER JOIN procedimentos proc ON proc.id=age.TipoCompromissoID WHERE proc.ProcedimentoTelemedicina='S' AND age.id="&treatvalzero(agendamentoIDSelecionado))
        if not AgendamentoTeleconsultaSQL.eof then
            %>
            <div class="col-xs-3 col-md-2 pt10">
                <button class="btn btn-sm btn-link " type="button" onClick="CopyLinkToClipboard('<%=ConsultaID%>', <%=ProfissionalID%>, <%=PacienteID%>)">
                    <i class="far fa-link"></i> Copiar link da consulta
                </button>
            </div>
            <%
        end if
        end if

        %>

            <div class="col-xs-12 col-md-6 pull-right">
                <%
                disabled = ""
                if (ConsultaID=0 and aut("agendaI")=1) or (ConsultaID<>0 and aut("agendaA")=1) then
                    if req("Checkin")="1" then
                        txtBtn = "<i class=""far fa-check""></i>  FINALIZAR CHECKIN"
                        colCHK = 8
                        hiddenCHK = " hidden "

                        if getConfig("BloquearCheckin")=1 then
                            disabled = " disabled "
                        end if

                        %>
                        <div class="col-md-6 hidden">
                            <button class="btn btn-sm btn-system">PAGAR</button>
                        </div>
                        <%
                    else
                        txtBtn = "<i class=""far fa-save""></i> Salvar"
                        colCHK = 3
                        hiddenCHK = ""
                    end if

                %>

                <div class="col-xs-6 col-md-<%= colCHK %> pt10">
                    <%
                        otherClass = ""
                        if config("ChamarAposPagamento")="S" then
                            'otherClass="disabled"
                        end if
                    %>
                    <button class="btn btn-block btn-sm btn-primary <%=otherClass%> <%=disabled%>" id="btnSalvarAgenda">
                        <%= txtBtn %>
                    </button>

                </div>
                <%
                end if
                if ConsultaID<>0 then
                    if aut("agendaI")=1 then
                    %>
                    <div class="col-xs-6 col-md-3 pt10 <%= hiddenCHK %>">
                        <button class="btn btn-sm btn-success btn-block" type="button" onclick="repetir(<%=ConsultaID%>, 'Solicitar', '');">
                            <i class="far fa-copy"></i> Repetir
                        </button>
                    </div>
                    <%
                    end if
                    if aut("agendaA")=1 then
                    %>
                    <div class="col-xs-6 col-md-3 pt10 <%= hiddenCHK %>">
                        <button class="btn btn-sm btn-warning btn-block" type="button" onclick="remarcar(<%=ConsultaID%>, 'Solicitar', '');">
                            <i class="far fa-copy"></i> Remarcar
                        </button>
                    </div>
                    <%
                    end if
                    if aut("agendaX")=1 and (cdate(Data) >= date() or (cdate(Data) < date() and aut("agendamentosantigosX")=1)) then
                    %>
                    <div class="col-xs-5 col-md-3 pt10 <%= hiddenCHK %>">
                        <button class="btn btn-sm btn-danger btn-block" type="button" data-bb-handler="danger" onclick="excluiAgendamento(<%=ConsultaID%>, 0);">
                            <i class="far fa-trash"></i> Excluir
                        </button>
                    </div>
                    <%
                    end if
                    %>
                    <div class="hidden col-xs-1 col-md-1 pt10 <%= hiddenCHK %>">
                        <button title="Histórico de alterações" class="btn btn-sm btn-default btn-block" type="button" data-bb-handler="default" onclick="logAgendamento('<%=ConsultaID%>', 0);">
                            <i class="far fa-history"></i>
                        </button>
                    </div>
                    <%
                Else
                    if aut("bloqueioagendaI")=1 and req("Tipo")<>"Quadro" then
                    %>
                    <div class="col-xs-6 col-md-3 pt10 <%= hiddenCHK %>">
                        <button class="btn btn-sm btn-info btn-block" type="button" data-bb-handler="danger" onclick="abreBloqueio(0, '<%=Data%>', '<%=Hora%>');">
                            <i class="far fa-lock"></i> Inserir Bloqueio
                        </button>
                    </div>
                    <%
                    end if
                End If %>
            </div>


        </div>
        </form>
	</div>
    <div id="divDadosPaciente" class="tab-pane">
    	Carregando...
    </div>
    <div id="divHistorico" class="tab-pane">
    	Carregando...
    </div>
</div>
</div>
</div>




<div id="permissaoTabela" class="modal fade" role="dialog">
  <div class="modal-dialog">

    <!-- Modal content-->
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Permissão para uso de Tabela</h4>
      </div>
      <div class="modal-body">
        <div class="col-md-4">
            <p>Selecione um usuário abaixo que tenha  permissão: 
                </p>      
              
        </div>        
            <div class="col-md-6">
                <label style="" class="error_msg"></label><br>
                <label>Senha do Usuário</label>
                <input type="hidden" id="tabela-password" name="tabela-password" class="form-control">
            </div>

        <div class="col-md-12 tabelaParticular" style="color:#000;">
        
             
        </div>
        </div>
       
        <div class="modal-footer" style="margin-top:13em;">
                <button type="button" class="btn btn-default fechar" data-dismiss="modal" >Fechar</button>                
                <button type="button" class="btn btn-info confirmar"    >Confirmar</button>
       
         </div>

  </div>
</div>
</div>





<script type="text/javascript">

$(".abasAux").on("click",function(){
    crumbAgendaUpdate();
});

function crumbAgendaUpdate(){
    let NomePaciente = $("#PacienteID").select2('data')[0].full_name;
    $(".crumb-active a").html(NomePaciente);
}

///Sanderson
///compara o ultimo alerta para não repetir o alerta para os mesmos parametros pelo tipo de alerta
///obj parametros do alerta par0:tipo, par1, par2 ... parametros variados
var AlertasArray = [];
function ValidaAlertas(obj){
    let isvalid = AlertasArray.findIndex(x=> _.isEqual(x,obj));
    let retorno = false;

    if(isvalid===-1){
        isvalid = AlertasArray.findIndex(x=>x.par0 === obj.par0)
        if(isvalid!==-1){
            AlertasArray.splice(isvalid,1)
        }
        AlertasArray.push(obj);
        retorno = true;
    }

    return retorno;
}


function RegistrarMultiplasPendencias(liberar) {
    var checkin = $("#checkinID").val();
    var PacienteID = $("#PacienteID").val();
    var ProcedimentoSelecionadoID = $(".linha-procedimento-id");
    var ids = "";

    ProcedimentoSelecionadoID.each(function(i, obj){
        ids +=  + obj.value + ","
    });
    ids += "0"

    if(PacienteID == "" || PacienteID == 0 || PacienteID == null){
        alert("Paciente não selecionado");
    }else{
        openComponentsModal('procedimentosListagem.asp?ProcedimentoId=' + ids + '&PacientedId=' + PacienteID + '&requester=MultiplaPorFiltro&Checkin=' + checkin, true, 'Restrições', true, '')
    }

    return false;

}

    function addRemoveRetorno(increment = true){
        <% if getConfig("SubtrairUmMinutoAgendamentoRetorno") then %>
            var hora = $("#Hora").val();
            var horas = hora.split(":");

            var d = new Date(0,0,0, horas[0], horas[1], 0);
            var dVal=d.valueOf();
            if(increment){
                // adicionar 1 minuto
                var newDate=new Date(dVal + 1000 * 60);
            }else{
                var newDate=new Date(dVal - 1000 * 60);
            }
            var vhora = (newDate.getHours() < 10)?"0"+newDate.getHours():newDate.getHours();
            var vmin = (newDate.getMinutes() < 10)?"0"+newDate.getMinutes():newDate.getMinutes();
            $("#Hora").val( vhora + ":" + vmin);
        <% end if %>

        <% if getConfig("MarcarRetornosComoEncaixe") then %>
            $("#Encaixe").prop("checked", increment);
        <% end if %>
    }

    $("#PacienteID").change(function() {
        var pacienteId = $(this).val();

        $.get("ListarProcedimentosPacote.asp", {
            contadorProcedimentos:0,
            PacienteID: pacienteId,
            ProfissionalID: $("#ProfissionalID").val()
        }, function (data) {
            if(data.length > 0) {
                openModal(data, "Selecionar procedimento do pacote contratado", true, false);
            }
        })
    });

    $("#Retorno").change(function() {
        var RetornoSelecionado = $(this).prop("checked");

        if(RetornoSelecionado){
            btnSalvarToggleLoading(false, true, "Selecione um retorno");
            $("#btnSalvarAgenda").attr("data-force-disabled", true);
            var $dadosAgendamentos = $("#dadosAgendamento" );
            let ConvenioId = "";

            if($dadosAgendamentos.find("#rdValorPlanoP").prop("checked") && !$dadosAgendamentos.find("#rdValorPlanoP").prop("disabled") ){
                ConvenioId = $dadosAgendamentos.find("#ConvenioID").val();
            }

            $.get("EscolheAtendimentoParaRetorno.asp", {
                PacienteID: $dadosAgendamentos.find("#PacienteID").val(),
                ProcedimentoID: $dadosAgendamentos.find("#ProcedimentoID").val(),
                ProfissionalID: $dadosAgendamentos.find("#ProfissionalID").val(),
                EspecialidadeID: $dadosAgendamentos.find("#EspecialidadeID").val(),
                Data: $dadosAgendamentos.find("#Data").val(),
                ConvenioId: ConvenioId
            }, function(data) {
                openModal(data, "Selecionar atendimento para o retorno", true, false);
            });

            addRemoveRetorno();
        }else{
            btnSalvarToggleLoading(true, true);

            //reset valor do procedimento
            var $valoresProcedimentos = $(".valorprocedimento");

            $valoresProcedimentos.each(function() {
                var valorOriginal = $(this).attr("data-valor-original");
                if(typeof valorOriginal !== 'undefined' && parseInt(valorOriginal) > 0){
                    $(this).val(valorOriginal);
                }
            });

            addRemoveRetorno(false);
        }

        //$("#ProcedimentoID").change();
    });
    $("#Encaixe").change(function() {
        var $Hora = $("#Hora");
        var checked = $(this).prop("checked");

        $("#Notas").prop("required", false);
        if(!checked){
            $Hora.val($Hora.data("time"));
        }else{
            <% if getConfig("ObrigarObsEncaixeAgendamento") = "1" then %>
                $("#Notas").prop("required", true);
            <% end if %>
        }

        $Hora.attr("readonly", !checked);


        $Hora.mask("99:99");
    });

    $.fn.modal.Constructor.prototype.enforceFocus = function() {};
$("#searchPacienteID").change(function(){
	$("#ageTel1, #ageCel1, #ageEmail1").val('');
});
function abasAux(){
//	alert($("#PacienteID").val());
	if($("#PacienteID").val()=="" || $("#PacienteID").val()=="0"){
		$(".abasAux").css("display", "none");
	}else{
		$(".abasAux").css("display", "block");
	}
}
abasAux();

function btnSalvarToggleLoading(state, force, waitMessage="Aguarde...") {
  var $el = $('#btnSalvarAgenda'), timeout= state ?  500 : 0;


  setTimeout(function() {
    if($el.attr("data-force-disabled") !== 'true' || force){
          if(state){
              $el.attr('disabled', false).html(`<i class='far fa-save'></i> Salvar`, false);
          }else{
              $el.attr('disabled', true).html(`<i class='far fa-circle-o-notch  fa-spin'></i> `+waitMessage, true);
          }
      }
  }, timeout);
}

function parametros(tipo, id){
    btnSalvarToggleLoading(false);
    setTimeout(function() {
        if(id == -1){
            id = $("#"+tipo).val();
        }

        $.ajax({
            type:"POST",
            url:"AgendaParametros.asp?tipo="+tipo+"&id="+id,
            data:$("#formAgenda").serialize(),
            success:function(data){
                eval(data);
                abasAux();
                btnSalvarToggleLoading(true);

            },
            error:function(data){
                // console.log(data)
                //comentado por possivel erro para clientes: Valor divergente da tabela particular (variacao)
                btnSalvarToggleLoading(true);
            }
        });
    }, 100);
}

$(".linha-procedimento").find(".ckpagar").each(function(i, value){
    <% if config("ChamarAposPagamento")="S" then %>
        $("#btnSalvarAgenda").addClass("disabled");
    <% end if %>
});


$(".clforma:checked").each(function(i, value){
    if(value.value == "P"){
        $("#btnSalvarAgenda").removeClass("disabled");
    }
});

$(".abaAgendamento").click(function(){
    setAgendamentoHeaders();
});

function setAgendamentoHeaders() {
    <%

        set LocalUnidadeSQL = db.execute("SELECT UnidadeID FROM locais WHERE id="&treatvalzero(LocalID))
        if not LocalUnidadeSQL.eof then
            UnidadeID = LocalUnidadeSQL("UnidadeID")
        end if

        set UnidadeSQL = db.execute("SELECT NomeFantasia FROM (SELECT 0 id, NomeFantasia FROM empresa WHERE id=1 UNION ALL SELECT id,NomeFantasia FROM sys_financialcompanyunits WHERE sysActive=1)t WHERE t.id="&treatvalzero(UnidadeID))
        if not UnidadeSQL.eof then
            NomeUnidade = UnidadeSQL("NomeFantasia")&" - "
        end if
      set ProfissionalSQL = db.execute("SELECT CONCAT(IF(tr.Tratamento IS NULL, '',tr.Tratamento),' ', p.NomeProfissional)NomeProfissional, ObsAgenda FROM profissionais p LEFT JOIN tratamento tr ON tr.id=p.TratamentoID WHERE p.id="&treatvalzero(ProfissionalID))
      if not ProfissionalSQL.eof then
          NomeProfissional = ProfissionalSQL("NomeProfissional")
          obsProfissional = replace(replace(replace(ProfissionalSQL("ObsAgenda")&"", """", "'"), chr(10), "\n"), chr(13), "")
      end if
      %>
      var nomeUnidade = "<%=NomeUnidade%>";

        var nomeProfissional = "<%=NomeProfissional%>";
      $("#rbtns").html(" <strong style='font-size:17px;margin-right:30px'>"+nomeUnidade +nomeProfissional+"</strong>");
}
setAgendamentoHeaders();

function valplan(n, tipo){
//	var tipo = $(this).val();
	if(tipo=="V"){
		$("#divConvenio"+n+", #divConvenioPlano"+n).hide();
		$("#divValor"+n).show();
	}else{
		$("#divConvenio"+n+", #divConvenioPlano"+n).show();
		$("#divValor"+n).hide();
	}
}

checkAgendasMarcadas = _ => {
  var header = { method: 'POST',
                 cache: 'default' };

  return fetch(`checkRepeticaoAgendamento.asp?${$("#formAgenda").serialize()}`, header)
		.then((promiseResponse) => {
				return promiseResponse.json();
            }
        );
};

function bootbox(){
    $("#modal").html("<div class='modal-content'><div class='modal-header'><button type='button' class='close' data-dismiss='modal'>&times;</button><h4 class='modal-title'>Atenção</h4></div><div class='modal-body'><p>Foram identificados agendamentos futuros ou bloqueios nesse horário, deseja continuar?.</p></div><div class='modal-footer'><button type='button' onclick='submitAgendamento(false);' class='btn btn-default' data-dismiss='modal'>Sim</button><button type='button' class='btn btn-default' data-dismiss='modal'>Não</button></div></div>");
    $("#modal-table").modal('show');

}
var checkmultiplos = '<%= getConfig("RealizarCheckinMultiplosProcedimentos") %>';

function checkinMultiplo()
{
    let pacienteid = $("#PacienteID").val();
    let unidadeid = '<%=session("UnidadeID")%>';
    let agendamentoID = '<%=req("id")%>';
    $.get("checkinmultiplo.asp",{
        PacienteID:pacienteid,
        UnidadeID: unidadeid,
        AgendamentoID: agendamentoID
        }
        , function (data) {
            if(data.length > 0) {
                openModal(data, "Selecione abaixo os agendamento que deseja realizar check in", true, false);
            }else{
                saveAgenda();
            }
        })
}

function gravaWorklist () {
    let checkin = $("#Checkin").val();
    <% if recursoAdicional(27)=4 then
    set pacs_config = db.execute("select id from pacs_config where expired = 0")
        if not pacs_config.eof and ConsultaID<>0 then %>
            if(checkin){
                postUrl("pacs", {agendamento_id:'<%=AgendamentoID%>',profissional_id:'<%=ProfissionalID%>'});
            }
        <% end if
    end if%>
}

var saveAgenda = function(){
        $("#btnSalvarAgenda").html(`<i class="far fa-circle-o-notch fa-spin fa-fw"></i> <span>Salvando...</span>`);
        //$("#btnSalvarAgenda").attr('disabled', 'disabled');
        $("#btnSalvarAgenda").prop("disabled", true);

        $.post("saveAgenda.asp", $("#formAgenda").serialize())
        .done(function(data){
            //$("#btnSalvarAgenda").removeAttr('disabled');
            eval(data);
            $("#btnSalvarAgenda").html('<i class="far fa-save"></i> Salvar');
            $("#btnSalvarAgenda").prop("disabled", false);
            crumbAgenda();
            gravaWorklist();
        })

        .fail(function(err){
            $("#btnSalvarAgenda").prop("disabled", true);
            showMessageDialog("Ocorreu um erro ao tentar salvar. Tente novamente mais tarde", 'danger');


            gtag('event', 'erro_500', {
                'event_category': 'erro_agenda',
                'event_label': "Erro ao salvar agendamento."
            });
        });

        if(typeof callbackAgendaFiltros === "function"){
            callbackAgendaFiltros();
            crumbAgenda();
        }
    }

async function submitAgendamento(check) {

    let valorPlano = null;
    let checkin = $("#Checkin").length;

    if($("#rdValorPlanoV").prop("checked") && !$("#rdValorPlanoV").prop("disabled") ){
        valorPlano = "V";
    }

    if($("#rdValorPlanoP").prop("checked") && !$("#rdValorPlanoP").prop("disabled") ){
        valorPlano = "P";
    }

    if(checkin != 1){
        if(valorPlano === null){
            new PNotify({
                title: 'Particular ou Convênio?',
                text: 'Selecione a forma do agendamento.',
                type: 'danger',
                delay: 2000
            });

            return false;
        }
    }

    <% IF isAmorSaude() or getConfig("ValidarCartaoClubFlex") = 1 THEN %>
        let bool = await checkParticularTableFields();

        if(!bool){
            return false;
        }
    <% END IF %>

    var repetir = $("#rpt").prop("checked");
    if(checkin === 1 && checkmultiplos === "1"){
        checkinMultiplo();
    }else{
        if(repetir){
            checkAgendasMarcadas().then((response) => {
                if(response.existeAgendamentosFuturos && check) {
                    bootbox();
                    return false;
                }
                saveAgenda();
                return false;
            });
        }else{

            saveAgenda();
        }
    }
}

function excluiAgendamento(ConsultaID, Confirma){
    let StaAgendamento = '<%=StaID%>';
    let descricaoStatus = '<%=statusDescricao%>'
    let permissaoExcluir = '<%=aut("|agestafinX|")%>';
    let permiteExcluir = true;

    if((StaAgendamento == "2" ||StaAgendamento == "3" || StaAgendamento == "4" ||StaAgendamento == "6" ) && permissaoExcluir == "0"){
        permiteExcluir = false;
    }

    if(permiteExcluir){
        $.ajax({
            type:"POST",
            url:"excluiAgendamento.asp?ConsultaID="+ConsultaID+"&Confirma="+Confirma+"&token=98b4d9bbfdfe2170003fcb23b8c13e6b",
            data:$("#formExcluiAgendamento").serialize(),
            success:function(data){
                $("#div-agendamento").html(data);
            }
        });
    }else{
        new PNotify({
        title: 'Não excluído!',
        text: 'Você não possui permissão para excluir este agendamento com status de '+descricaoStatus+'.',
        type: 'danger',
        delay: 3000
    });
    }
}
function repeteAgendamento(ConsultaID){
	$.ajax({
		type:"POST",
		url:"repeteAgendamento.asp?ConsultaID="+ConsultaID,
		data:$("#formExcluiAgendamento").serialize(),
		success:function(data){
			$("#div-agendamento").html(data);
		}
	});
}
setInterval(function(){abasAux()}, 3000);

function atualizaHoraAtual(){
    //let horaAtual = '<%=formatdatetime(getClientDataHora(session("UnidadeID")),4)%>';
    var data    = new Date();
    var hora    = data.getHours();          // 0-23
    var min     = data.getMinutes();        // 0-59
    let horaAtual = ("00"+ hora).slice(-2) + ':' + ("00"+ min).slice(-2) ;
    
    $("#Chegada").val(horaAtual);
}

$("#StaID").change(function(){
    //triagem 101
	if($(this).val()=="4" || $(this).val()=="101"){
		$("#divStatus").removeClass("col-md-12");
		$("#divStatus").addClass("col-md-6");
		$("#divChegada").fadeIn("slow");

		atualizaHoraAtual();
	}else{
		$("#divStatus").addClass("col-md-12");
		$("#divStatus").removeClass("col-md-6");
		$("#divChegada").hide();
	}
});

<%
if session("OtherCurrencies")="phone" and ConsultaID=0 then
	set vcaCha = db.execute("select Contato from chamadas where StaID=1 AND sysUserAtend="&session("User"))
	if not vcaCha.EOF then
		if not isnull(vcaCha("Contato")) and instr(vcaCha("Contato")&" ", "_") then
			spl = split(vcaCha("Contato"), "_")
			if spl(0)="3" then
				set pac = db.execute("select id, NomePaciente from pacientes where id="&spl(1))
				if not pac.eof then
					%>
					$("#PacienteID").val("<%=pac("id")%>");
					$("#searchPacienteID").val("<%=pac("NomePaciente")%>");
					parametros('select-PacienteID', <%=pac("id")%>);
					<%
				end if
			end if
		end if
	end if
end if


    if Convenios="Nenhum" then
        %>
        $("#rdValorPlanoV").click();
        <%
    end if
        %>



function dispEquipamento(){
        $.post("agendaParametros.asp?tipo=Equipamento", $("#formAgenda").serialize(), function(data){eval(data);});
    }

$("#EquipamentoID, #Hora, #Data, #Tempo").change(function(){
    dispEquipamento();
})

    $("#btnSendSms").click(function() {
        var licenca = "<%=session("banco")%>";
        var agendamento = $("#ConsultaID").val();
        var celular = $("#ageCel1").val();
        if(celular != ''){
            var txt = prompt("Digite a mensagem do sms:");
            if(txt != null){
                $.post("send_sms_agenda.php",{licenca:licenca,msg:txt,celular:celular,agendamento:agendamento},function(data) {

                });
            }
        }
    });

    function rpti(){
        var d = $("#divRpt");
        var c = $("#rpt");
        if(c.prop("checked")==true){
            d.removeClass("hidden");
        }else{
            d.addClass("hidden");
        }
    }

$("#Repeticao").change(function(){
    Descricao = $("#Repeticao option:selected").attr("data-description");
    $("#rptDescricao").html(Descricao);
    if(Descricao=="semanas"){
        $("#rptDS td").fadeIn();
        $("#rptDM").addClass("hidden");
    }else if(Descricao=="meses"){
        $("#rptDM").removeClass("hidden");
        $("#rptDS td").fadeOut();
    }else{
        $("#rptDS td").fadeOut();
        $("#rptDM").addClass("hidden");
    }
});


<%
if req("ProcedimentoID")<>"" and isnumeric(req("ProcedimentoID")) then
    set proc = db.execute("select id, NomeProcedimento from procedimentos where id="&req("ProcedimentoID"))
    if not proc.eof then
        %>
        $("#searchProcedimentoID").val("<%=proc("NomeProcedimento")%>");
        $("#ProcedimentoID").val("<%=proc("id")%>");
        $("#rdValorPlanoV").click();
        parametros("select-ProcedimentoID", <%=proc("id")%>);
    <%
    end if
end if
%>
function addProcedimentos(I) {
    var pacienteId = $("#PacienteID").val();
    var professionalId = $("#ProfissionalID").val();
    var convenioID = $("#ConvenioID").val();

        $.get("ListarProcedimentosPacote.asp", {
            contadorProcedimentos: I,
            PacienteID: pacienteId,
            ProfissionalID: professionalId,
            ConvenioID: convenioID
        }, function (data) {
            if(data.length > 0) {
                openModal(data, "Selecionar procedimento do pacote contratado", true, false);
            }
        });
};
function procs(A, I, LocalID, Convenios, GradeApenasProcedimentos, GradeApenasConvenios,Equipamento,count,callback=false) {
    if(!count){
        let linhas = $("tr[class='linha-procedimento']").length
        count = linhas*-1
    }
    if(A=='I'){
        I = parseInt($("#nProcedimentos").val())-1;
        $("#nProcedimentos").val( I );
        let formapgt = $("[name=rdValorPlano]:checked").val();
        let convenioID = $("#ConvenioID").val();
        let linhas = $('select[id^="ProcedimentoID"]')
        let planoID = $("#PlanoID").val();
        $.post("procedimentosagenda.asp?EquipamentoID="+Equipamento, {
            A: A, I: I ,
            LocalID:LocalID,
            Convenios:Convenios,
            GradeApenasProcedimentos:GradeApenasProcedimentos,
            GradeApenasConvenios: GradeApenasConvenios,
            EquipamentoID: Equipamento,
            Forma: formapgt,
            ConvenioSelecionado: convenioID,
            PlanoSelecionado: planoID,
            linhas: count //"-"+linhas.length
            }, function (data) {
            // addProcedimentos(I);
            $('#bprocs').append(data);
            if(callback && typeof callback == 'function'){
                callback(true)
            }

        });
    }else if(A=='X'){
        $("#la"+I).remove();
        somarValores();
    }
}
function printProcedimento(ProcedimentoID, PacienteID, ProfissionalID, TipoImpresso) {

    if(TipoImpresso === "Preparos"){
        $("body").append("<iframe id='ImpressaoEtiqueta' src='listaDePreparoPorProcedimento.asp?PacienteId="+PacienteID+"&procedimento="+ProcedimentoID+"' style='display:none;'></iframe>")
        return;
    }
    var solicitante = $("#indicacaoId").val();

    var ConvenioID = $("#ConvenioID").val();

    $.get("printProcedimentoAgenda.asp", {
        ProcedimentoID:ProcedimentoID,
        ConvenioID:ConvenioID,
        PacienteID:PacienteID,
        Solicitante:solicitante,
        ProfissionalID:ProfissionalID,
        UnidadeID:'<%=UnidadeID%>',
        Tipo: TipoImpresso,
        DataAgendamento: '<%=Data%>'
    }, function(data) {
        eval(data);
    });
}
function printAgendamento() {
    $("#ImpressaoAgendamento").remove();
    $("body").append("<iframe id='ImpressaoAgendamento' src='printAgendamento.asp?AgendamentoID=<%=ConsultaID%>' style='display:none;'></iframe>");
}





$("#ProfissionalID", "#dadosAgendamento").change(function() {
    $.get("divEspecialidade.asp", {
        ProfissionalID: $(this).val()
    }, function(data) {
        $("#divEspecialidadeID").html(data);
    });
});

function VerGradeDoHorario() {
    var Hora = $("#Hora").val();
    var EncaixeMarcado = $("#Encaixe").is(":checked");
    let dataAgendamento = new Date($("#dadosAgendamento #Data").val().split("/").reverse().join("-")+" "+$("#dadosAgendamento #Hora").val());
    if(EncaixeMarcado && '<%=ProfissionalID%>' !== ''  && dataAgendamento >= new Date()){
        $.get("VerificaGradeDoHorario.asp", {Data: '<%=Data%>', Hora: Hora, ProfissionalID: '<%=ProfissionalID%>', UnidadeID: '<%=req("UnidadeID")%>'}, function(data) {
            eval(data);
        });
    }
}

$("#Hora, #Encaixe").change(function (){
    VerGradeDoHorario()
});

//retira do select os options que não serão usado caso agendamento seja futuro
function changeStatusOption()
{
<%
 if cdate(Data) > Date() then
%>
    let rule = ["2","3","5","105","103","6","4","101"];
    $('#StaID > option').each(function() {
        let value = $(this).val();

        if($.inArray(value, rule)!==-1)
        {
            $(this).hide();
        }
    });
<%
end if
%>

}

$(function(){

    somarValores();
    changeStatusOption();
    $(".valorprocedimento, .linha-procedimento").on('change', function(){
        somarValores();
    });
    VerGradeDoHorario()
    //$("#Chegada").val(new Date().toTimeString().split(' ')[0]);
});

function logAgendamento(agendamentoId) {
    openComponentsModal("DefaultLog.asp", {Impressao: "S",R: "agendamentos", I: agendamentoId}, "Alterações do agendamento", true);
}



 function CopyLinkToClipboard(AgendamentoID, ProfissionalID, PacienteID) {
    getUrl("/telemedicina/gerar-link", {AgendamentoID: AgendamentoID, ProfissionalID: ProfissionalID, PacienteID: PacienteID, LicencaID: '<%=replace(session("Banco"),"clinic", "")%>'}, function(data) {
        CopyToClipboard(data.link);

        showMessageDialog("Link copiado para a área de transferência.", "primary");
    });
 }

function CopyToClipboard (text) {
	// Copies a string to the clipboard. Must be called from within an
	// event handler such as click. May return false if it failed, but
	// this is not always possible. Browser support for Chrome 43+,
	// Firefox 42+, Safari 10+, Edge and IE 10+.
	// IE: The clipboard feature may be disabled by an administrator. By
	// default a prompt is shown the first time the clipboard is
	// used (per session).
	if (window.clipboardData && window.clipboardData.setData) {
		// IE specific code path to prevent textarea being shown while dialog is visible.
		return clipboardData.setData("Text", text);

  } else if (document.queryCommandSupported && document.queryCommandSupported("copy")) {
    var textarea = document.createElement("textarea");
    textarea.textContent = text;
    textarea.style.position = "fixed";  // Prevent scrolling to bottom of page in MS Edge.
    document.body.appendChild(textarea);
    textarea.select();

    try {
      return document.execCommand("copy");  // Security exception may be thrown by some browsers.
    } catch (ex) {
      //console.warn("Cópia de tag falhou.", ex);
      showMessageDialog("Ocorreu um erro ao copiar o link. Por favor copie manualmente.", "danger", "ERRO!", 5000);
      return false;
    } finally {
      document.body.removeChild(textarea);
    }
	}
}

<% IF isAmorSaude() or getConfig("ValidarCartaoClubFlex") = 1 THEN %>
    if(!($("#openConsulta").length > 0)){
        $("#qfagematricula1").prepend(`<div class='pull-right'><a id='openConsulta' href='javascript:openConsultaCartao()'><i class="fa fa-search" aria-hidden="true"></i></a></div>`)
    }
    function openConsultaCartao(){
        openComponentsModal("pesquisa-paciente-parceiro.asp",{}, "Consulta de Paciente | Cartão de Desconto", true);
    }
    function callRow(row){
        $("#ageMatricula1").val(row.matricula);
        $('#ageMatricula1').trigger('change');
        $("#modal-components").modal("hide");
    }

<% END IF%>

function ObsConvenio(ConvenioID) {
    $("#modal-table").modal("show");
    $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
    $.post("ObsConvenio.asp?ConvenioID="+ConvenioID, "", function (data) {
        $("#modal").html(data);

    });
    $("#modal").addClass("modal-lg");
}
atualizaHoraAtual();




var idStr = "#ageTabela";
$('.modal').click(function(){
$(idStr).val("");

});


$(idStr).change(function(){
        var id       = $(idStr).val();
        var sysUser  = "<%=session("user") %>";
        var regra  = "|tabelaParticular12V|";
        $.ajax({
        method: "POST",
        url: "TabelaAutorization.asp",
        data: {autorization:"buscartabela",id:id,sysUser:sysUser},
        success:function(result){
            if(result == "Tem regra") {
                $("#tabela-password").attr("type","password");
                $('#permissaoTabela').modal('show');
                buscarNome(id,sysUser,regra);
            }
        }
    });
        $('.confirmar').click(function(){
                var Usuario =  $('input[name="nome"]:checked').val();
                var senha   =  $('#tabela-password').val();
                liberar(Usuario , senha , id);
        });
    });



function buscarNome(id ,user, regra){
    $.ajax({
        method: "POST",
        ContentType:"text/html",
        url: "TabelaAutorization.asp",
        data: {autorization:"pegarUsuariosQueTempermissoes",id:id,LicencaID:user,regra:regra},
        success:function(result){
        
            res = result.split('|');     
                    $('.tabelaParticular').html(result);
            }
        });
}

function liberar(Usuario , senha , id){
    $.ajax({
    method: "POST",
    url: "SenhaDeAdministradorValida.asp",
    data: {autorization:"liberar",id:id ,U:Usuario , S:senha},
    success:function(result){      
            if( result == "1" ){
                    $('.error_msg').text("Logado Com Sucesso!").fadeIn().css({color:"green" });;
                setTimeout(() => {
                    $('#permissaoTabela').modal('hide');
                    $(idStr).val(id);
                }, 2000);
                }else{
                        $('.error_msg').text("Senha incorreta!").css({color:"red" }).fadeIn();
                        $(idStr).val("");
                }
            }
        });
}

function toRequired(){
    $(document).ajaxComplete(function(){
<%
        set obriga = db.execute("select * from obrigacampos where Tipo='Paciente' and Obrigar like '%|%'")
        if not obriga.eof then
            Obr = obriga("Obrigar")
            splObr = split(Obr, ", ")
            for o=0 to ubound(splObr)
                campoObrigatorio = replace(splObr(o), "|", "")
            %>
                var campoNaoObrigatorio = false;
                var campoObrigatorio = '<%=campoObrigatorio%>'
                if(!$("#<%=replace(splObr(o), "|", "") %>").parents(".qr").hasClass("hidden") && campoNaoObrigatorio == false){
                    $("#dadosAgendamento #<%=replace(splObr(o), "|", "") %>").attr("required", "required");
                    $("#divDadosPaciente #<%=replace(splObr(o), "|", "") %>").attr("required", "required");
                }
            <%
            next
        end if
%>
    });
}

$( document ).ready(function() {
    let selects =  $('input')
    selects.map((key,ele)=>{
        if($(ele).attr('id') !== "sidebar-search"){
            $(ele).keypress(function(event){
                var keycode = (event.keyCode ? event.keyCode : event.which);
                if(keycode == '13'){
                    event.preventDefault(); 
                }
            });
        }
    })
});

$("select[name^=ConvenioID]").change(function(){
    $.get("ObsConvenioAgenda.asp?ConvenioID="+$(this).val(), function(data){
        if(data!=""){
            $("#modal-table").modal("show");
            $("#modal").html(data);
        }
    });
});

<!--#include file="jQueryFunctions.asp"-->
</script>
