<%InicioProcessamento = Timer%>
<!--#include file="connect.asp"-->
<!--#include file="Classes/StringFormat.asp"-->
<!--#include file="Classes/ValidaProcedimentoProfissional.asp"-->
<!--#include file="Classes/GradeAgendaUtil.asp"-->

<script>
$(".dia-calendario").removeClass("danger");
</script>
<%
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
	Tipo=""
end if
LiberarHorarioRemarcado = getConfig("LiberarHorarioRemarcado")
NaoExibirNaAgendaOsStatus = getConfig("NaoExibirNaAgendaOsStatus")
ExibirCorPacienteAgenda = getConfig("ExibirCorPacienteAgenda")
NaoExibirAgendamentoLocal = getConfig("NaoExibirAgendamentoLocal")
NaoExibirOutrasAgendas = getConfig("NaoExibirOutrasAgendas")
AumentarAlturaLinhaAgendamento = getConfig("AumentarAlturaLinhaAgendamento")
ColorirLinhaAgendamento = getConfig("ColorirLinhaAgendamento")
OmitirEncaixeGrade = getConfig("OmitirEncaixeGrade")

'verifica se há agendamento aberto e bloqueia o id concatenado
set vcaAB = db.execute("select id, AgAberto, UltRef from sys_users where AgAberto like '%_%' and id<>"& session("User"))
while not vcaAB.eof
    AgAberto=vcaAB("AgAberto")

    if AgAberto<> "" and vcaAB("UltRef")>dateadd("s", -30, now()) then
        strAB = strAB & "|"& AgAberto &"|"
    end if
    'ProfissionalAB = splAB(0)
    'DataAB = splAB(1)
    'HoraAB = splAB(2)
    '!!! aqui tera um if em js pra ver se a data é a mesma

    'txtAB = "<em>Este horário está sendo utilizado por "& nameInTable(vcaAB("id")) &".</em>"
vcaAB.movenext
wend
vcaAB.close
set vcaAB = nothing


'on error resume next

HLivres = 0
HAgendados = 0
HBloqueados = 0

if req("Data")="" then
	Data=date()
else
	Data=req("Data")
end if
ProfissionalID=req("ProfissionalID")
DiaSemana=weekday(Data)
mesCorrente=month(Data)
set prof = db.execute("select Cor, NomeProfissional, Foto, ObsAgenda, Ativo from profissionais where id="&ProfissionalID)



if lcase(session("Table"))="funcionarios" then
	session("UltimaAgenda") = ProfissionalID
end if

escreveData = formatdatetime(Data, 1)

if not prof.eof then
    ObsAgenda=prof("ObsAgenda")&""

    if getConfig("AbrirAutomaticamenteObsProfissional")=1 and ObsAgenda<>"" then
        %>
        <script>
            oa(<%=treatvalzero(ProfissionalID)%>);
        </script>
        <%
    end if
	Cor = prof("Cor")
	Ativo = prof("Ativo")
	NomeProfissional = prof("NomeProfissional")
	if isnull(prof("Foto")) or prof("Foto")="" then
		FotoProfissional = "./assets/img/user.png"
	else
		FotoProfissional = arqEx(prof("Foto"), "Perfil")
	end if
	ObsAgenda = prof("ObsAgenda")
	ObsAgenda = trim(ObsAgenda&" ")
	ObsAgenda = replace(replace(replace(replace(ObsAgenda, chr(10), " "), chr(13), " "), "'", ""), """", "")
else
	Cor = "#333"
	FotoProfissional = "./assets/img/user.png"
end if
%>
<script>
$("#FotoProfissional").css("border-left", "4px solid <%=Cor%>");
$("#FotoProfissional").css("background-image", "url(<%=FotoProfissional%>)");
$(".select2-single").not("#ProfissionalID").select2();

<%
if len(ObsAgenda)>0 then
	%>
	$("#ObsAgenda").removeClass("hidden");
	$("#ObsAgenda").attr("data-content", '<%=ObsAgenda%>');
	<%
else
	%>
	$("#ObsAgenda").addClass("hidden");
	$("#ObsAgenda").attr("data-content", "");
	<%
end if
%>

</script>


<%

function existeGrade(ProfissionalID, UnidadeID, Hora, Data,Procedimento,Especialidade,Convenio )
    existeGrade = false
    if UnidadeID<>"" then
        sqlUnidade = " AND loc.UnidadeID='"&UnidadeID&"'"
    end if

    if Hora <>"" then
        horaWhere = " AND "&mytime(Hora)&" BETWEEN HoraDe AND HoraA "
    end if

    sqlProcedimentoPermitido =  " AND ((Procedimentos = '' OR Procedimentos IS NULL)"&_
                                " OR Procedimentos LIKE '%|"&Procedimento&"|%') "

    sqlEspecialidadePermitido =  " AND ((Especialidades = '' OR Especialidades IS NULL)"&_
                                " OR Especialidades LIKE '%|"& Especialidade &"|%') "

    sqlConvenioPermitido =  " AND ((Convenios = '' OR Convenios IS NULL)"&_
                                " OR Convenios LIKE '%|"& Convenio &"|%') "

    sqlGrade = "SELECT id GradeID, Especialidades, Procedimentos,Convenios, LocalID FROM (SELECT ass.id, Especialidades, Procedimentos, LocalID,Convenios FROM assfixalocalxprofissional ass LEFT JOIN locais loc ON loc.id=ass.LocalID WHERE ProfissionalID="&treatvalzero(ProfissionalID)&sqlUnidade&" AND DiaSemana=dayofweek("&mydatenull(Data)&") "&horaWhere&"AND ((InicioVigencia IS NULL OR InicioVigencia <= "&mydatenull(Data)&") AND (FimVigencia IS NULL OR FimVigencia >= "&mydatenull(Data)&")) UNION ALL SELECT ex.id*-1 id, Especialidades, Procedimentos, LocalID,Convenios FROM assperiodolocalxprofissional ex LEFT JOIN locais loc ON loc.id=ex.LocalID WHERE ProfissionalID="&ProfissionalID&sqlUnidade&" AND DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&")t"&_
                " where true "&sqlProcedimentoPermitido&sqlEspecialidadePermitido&sqlConvenioPermitido
    'response.write sqlGrade

    set Grade = db.execute(sqlGrade)
    if not Grade.eof then
        existeGrade = true
    end if
end function

if session("FilaEspera")<>"" then
	set fila = db.execute("select f.id, p.NomePaciente from filaespera as f left join pacientes as p on p.id=f.PacienteID where f.id="&session("FilaEspera")&" and f.ProfissionalID like '"&ProfissionalID&"'")
	if not fila.eof then
		UtilizarFila = fila("id")
		%>
        <div class="alert alert-warning col-md-12 text-center" style="padding: 5px">
            Selecione um hor&aacute;rio abaixo para agendar <%=fila("NomePaciente")%>
            <button type="button" class="btn btn-sm btn-danger" onClick="filaEspera('cancelar')">Cancelar</button>
    </div>
        <%
	end if
end if

AlterarNumeroProntuario = getConfig("AlterarNumeroProntuario")

if session("RemSol")<>"" then
Ativo = "off"
remarcarSql = "select a.TipoCompromissoID, a.ProfissionalID, a.EspecialidadeID, if(a.rdValorPlano='P',a.ValorPlano,'') as ConvenioID from agendamentos a where id="&session("RemSol")
'response.write remarcarSql
set RemSQL = db.execute(remarcarSql)

RemarcarAssociacao = 5
RemarcarProfissionalID = req("ProfissionalID")
RemarcarEspecialidadeID = RemSQL("EspecialidadeID")
RemarcarProcedimentoID = RemSQL("TipoCompromissoID")
RemarcarConvenio = RemSQL("ConvenioID")

profissionalValido = validaProcedimentoProfissional(5 ,RemarcarProfissionalID, RemarcarEspecialidadeID,  RemarcarProcedimentoID,"")
existegradeval = existeGrade(RemarcarProfissionalID,"", "", Data,RemarcarProcedimentoID,RemarcarEspecialidadeID,RemarcarConvenio)

if profissionalValido = true then
    Ativo = "on"
    sqlProcedimentoPermitido =  " AND ((ass.Procedimentos = '' OR ass.Procedimentos IS NULL)"&_
                                " OR ass.Procedimentos LIKE '%|"&RemarcarProcedimentoID&"|%') "

    sqlEspecialidadePermitido =  " AND ((ass.Especialidades = '' OR ass.Especialidades IS NULL)"&_
                                " OR ass.Especialidades LIKE '%|"& RemarcarEspecialidadeID &"|%') "

    if RemarcarConvenio<>"" then
    sqlConvenioPermitido =  " AND ((ass.Convenios = '' OR ass.Convenios IS NULL)"&_
                                " OR ass.Convenios LIKE '%|"& RemarcarConvenio &"|%') "
    end if

end if

'response.write "<br>prof:"&RemarcarProfissionalID&" <br>esp:"&RemarcarEspecialidadeID&" <br>proc:"&RemarcarProcedimentoID&" <br>ag:"&session("RemSol")&" <br>conv:"&RemarcarConvenio&" <br>result:"&profissionalValido&" <br>existegrade:"&existegradeval

    if existegradeval or getConfig("PermitirRemarcarSemGrade")=1 then
    %>
    <div class="row">
        <div class="panel  ">
            <div class="col-md-2">
                <div class="input-group">
                    <span class="input-group-addon"><i class="far fa-clock"></i></span>
                    <input type="text" class="form-control input-mask-l-time text-right" placeholder="__:__" id="HoraRemarcar">

                </div>
                <p><i>*Selecione um hor&aacute;rio abaixo ou digite</i></p>
            </div>
            <div class="col-md-2">
                <span class="btn-group">
                    <button type="button" class="btn btn-default" onclick="remarcar(<%=session("RemSol")%>, 'Remarcar', $('#HoraRemarcar').val(), 'Search')">
                        <i class="far fa-check bigger-110"></i>
                        Remarcar</button>

                    <button type="button" class="btn btn-danger" onclick="remarcar(<%=session("RemSol")%>, 'Cancelar', '')"><i class="far fa-times"></i> Cancelar</button>
                </span>
            </div>
        </div>
    </div>
    <%
    else
    %>
     <div class="panel panel-footer row">
        <div class="col-md-6">
            <div class="input-group">
                <span class="input-group-addon">Não é possível remarcar o agendamento no dia selecionado.</span>
                <span class="input-group-btn">
                    <button type="button" class="btn btn-danger" onclick="remarcar(<%=session("RemSol")%>, 'Cancelar', '')">Cancelar</button>
                </span>
            </div>
        </div>
    </div>
    <%
    end if
end if
if session("RepSol")<>"" then
	%>
<div class="panel panel-footer row">
    <div class="col-md-6">
        <div class="input-group">
            <span class="input-group-addon">Selecione um hor&aacute;rio abaixo ou digite</span>
            <input type="text" class="form-control input-mask-l-time text-right" placeholder="__:__" id="HoraRepetir">
            <span class="input-group-btn">
                <button type="button" class="btn btn-default" onclick="repetir(<%=session("RepSol")%>, 'Repetir', $('#HoraRepetir').val(), 'Search')">
                    <i class="far fa-clock-o bigger-110"></i>
                    Repetir</button>
            </span>
            <span class="input-group-btn">
                <button type="button" class="btn btn-danger" onclick="repetir(<%=session("RepSol")%>, 'Cancelar', '')">Parar Repeti&ccedil;&atilde;o</button>
            </span>
        </div>
    </div>
</div>
	<%
end if
%>
<script type="text/javascript">
    function crumbAgenda(){
        $(".crumb-active").html("<a href='./?P=Agenda-1&Pers=1'>Agenda</a>");
        $(".crumb-icon a span").attr("class", "far fa-calendar");
        $(".crumb-link").replaceWith("");
        $(".crumb-trail").removeClass("hidden");
        $(".crumb-trail").html("<%=(escreveData)%>");
        //$("#rbtns").html("<select class='form-control select-xs' id='select-tipo-agenda'><option value='Agenda-1'>Agenda Diária</option><option value='AgendaMultipla'>Agenda Múltipla</option><option value='Agenda-S'>Agenda Semanal</option>");
        <% if device()<>"" then %>
            $(".crumb-icon a").html("<i class='far fa-calendar'></i> <%= Data %>");
            $(".crumb-icon a").css("overflow", "unset");
            $(".crumb-icon a").css("max-width", "unset");
        <% end if %>
    }
    crumbAgenda();
    $("#select-tipo-agenda").change(function(){
        location.href='./?P='+$(this).val()+'&Pers=1';
    });
</script>

<table class="table table-striped table-hover table-condensed table-agenda" id="table-agenda-1">
     <%
        sqlUnidadesBloqueio=""
        if Ativo="on" then
            DiaSemana = weekday(Data)
            Hora = cdate("00:00")
            sqlAssfixaperiodo = "select ass.*, l.NomeLocal, '' Cor, '0' TipoGrade, l.UnidadeID, '0' GradePadrao, '' Procedimentos, '' Mensagem, '' as CorOriginal from assperiodolocalxprofissional ass LEFT JOIN locais l on l.id=ass.LocalID where ass.ProfissionalID="&ProfissionalID& sqlProcedimentoPermitido & sqlEspecialidadePermitido & sqlConvenioPermitido&"  and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" order by HoraDe"
            'response.write sqlAssfixaperiodo&"<br>"
            set Horarios = db.execute(sqlAssfixaperiodo)
            if Horarios.EOF then
                sqlAssfixa = "select ass.*, l.NomeLocal, l.UnidadeID, '1' GradePadrao, ass.Mensagem, ass.Cor as Cor, profissionais.cor as CorOriginal from assfixalocalxprofissional ass LEFT JOIN locais l on l.id=ass.LocalID left join profissionais on profissionais.id = ass.ProfissionalID where ass.ProfissionalID="&ProfissionalID& sqlProcedimentoPermitido & sqlConvenioPermitido & sqlEspecialidadePermitido &" and ass.DiaSemana="&DiaSemana&" AND ((ass.InicioVigencia IS NULL OR ass.InicioVigencia <= "&mydatenull(Data)&") AND (ass.FimVigencia IS NULL OR ass.FimVigencia >= "&mydatenull(Data)&")) order by ass.HoraDe"
                set Horarios = db.execute(sqlAssfixa)
            end if
            if Horarios.eof then
                %>
                <tr><td class="text-center" colspan="6"><small>Não há grade configurada para este dia da semana.</small></td></tr>
                <%
            end if
            while not Horarios.EOF
                MostraGrade=True
                UnidadeID=Horarios("UnidadeID")
                if UnidadeID&"" <> "" and session("admin")=0 and session("Partner")="" then
                    if NaoExibirOutrasAgendas = 1 then
                        if session("UnidadeID")<>UnidadeID then
                            MostraGrade=False
                        end if
                    end if
                    if instr(session("Unidades"),"|"&UnidadeID&"|")=0 then
                        MostraGrade=False
                    end if
                end if
                if Horarios("GradePadrao")=1 then
                    FrequenciaSemanas = Horarios("FrequenciaSemanas")
                    InicioVigencia = Horarios("InicioVigencia")
                    if FrequenciaSemanas>1 then
                        NumeroDeSemanaPassado = datediff("w",InicioVigencia,Data)
                        RestoDivisaoNumeroSemana = NumeroDeSemanaPassado mod FrequenciaSemanas
                        if RestoDivisaoNumeroSemana>0 then
                            MostraGrade=False
                        end if
                    end if
                end if
                if MostraGrade then
                LocalID = Horarios("LocalID")
                Procedimentos = Horarios("Procedimentos")&""
                Cor = Horarios("CorOriginal")
                if Horarios("Cor")&""<>"" then
                    Cor = Horarios("Cor")
                end if
                %>
                <tbody data-LocalID="<%= LocalID %>">
                    <tr class="hidden l l<%=LocalID%>" data-horaid="0000" id="<%= LocalID %>0000"></tr>
                    <tr>
                        <td colspan="6" nowrap class="nomeProf text-center" style="background-color:<%=Cor%>;">
                             <%=ucase(Horarios("NomeLocal")&" ")%> (<%=getNomeLocalUnidade(Horarios("UnidadeID"))%>) <input type="hidden" name="LocalEncaixe" id="LocalEncaixe" value="<%=LocalID%>">
                             <br><%= Horarios("Mensagem") %>
                        </td>
                    </tr>
                    <%
                    GradeID=Horarios("id")
                    if Horarios("TipoGrade")=0 then
                        UnidadeID=Horarios("UnidadeID")
                        if UnidadeID&"" <> "" and session("Partner")="" then
                            sqlUnidadesBloqueio = sqlUnidadesBloqueio&" OR c.Unidades LIKE '%|"&UnidadeID&"|%'"
                        end if
                        if Horarios("GradePadrao")="0" then
                            GradeID=GradeID*-1
                        end if
                        Intervalo = Horarios("Intervalo")
                        if isnull(Intervalo) then
                            Intervalo = 30
                        end if
                        HoraDe = cdate(Horarios("HoraDe"))
                        horarioAFix = (formatdatetime(Horarios("HoraA"), 4))
                        ultimoValorMinuto = Mid(horarioAFix,Len(horarioAFix)-0,1)
                        HoraA = cdate(Horarios("HoraA"))
                        if ultimoValorMinuto <> "9" then
                            HoraA = cdate(dateAdd("n", 1, Horarios("HoraA")))
                        end if
                        Hora = HoraDe
                        Bloqueia = ""
                        if Procedimentos<>"" and session("RemSol")<>"" then
                            sqlProcedimentoBloqueado = "select TipoCompromissoID from agendamentos where id="& session("RemSol")
                            set procRem = db.execute(sqlProcedimentoBloqueado)
                            if not procRem.eof then
                                if instr(Procedimentos, "|"& procRem("TipoCompromissoID") &"|")=0 then
                                    Bloqueia = "S"
                                end if
                            end if
                        end if
                        while Hora<=HoraA
                            HoraID = formatdatetime(Hora, 4)
                            HoraID = replace(HoraID, ":", "")
                            if session("FilaEspera")<>"" then
                            %>
                            <tr class="l vazio" data-hora="<%=formatdatetime(Hora, 4)%>" data-horaid="<%= HoraID %>" id="<%=HoraID%>">
                                <td width="1%"></td>
                                <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(Hora,4) %></button></td>
                                <td colspan="4">
                                <%if UtilizarFila<>"" then%>
                                    <button type="button" onclick="filaEspera('U_<%=session("FilaEspera")%>_<%=formatDateTime(Hora,4)%>')" class="btn btn-xs btn-primary">
                                        <i class="far fa-chevron-left"></i> Agendar Aqui
                                    </button>
                                <%end if%>
                                </td>
                            </tr>
                            <%
                            elseif session("RemSol")<>"" then
                                if Bloqueia="" then
                                %>
                                <tr class="l l<%= LocalID %> vazio" data-hora="<%=formatdatetime(Hora, 4)%>" data-horaid="<%= horaid %>" id="<%=HoraID%>">
                                    <td width="1%"></td>
                                    <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(Hora,4) %></button></td>
                                    <td colspan="4">
                                        <button type="button" onclick="remarcar(<%=session("RemSol")%>, 'Remarcar', '<%=formatDateTime(Hora,4)%>', '<%=LocalID%>')" class="btn btn-xs btn-warning">
                                            <i class="far fa-chevron-left"></i> Remarcar Aqui
                                        </button>
                                    </td>
                                </tr>
                                <%
                                end if
                            elseif session("RepSol")<>"" then
                            %>
                            <tr class="l l<%= LocalID %> vazio" data-hora="<%=formatdatetime(Hora, 4)%>" data-horaid="<%= horaid %>" id="<%=HoraID%>">
                                <td width="1%"></td>
                                <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(Hora,4) %></button></td>
                                <td colspan="4">
                                    <button type="button" onclick="repetir(<%=session("RepSol")%>, 'Repetir', '<%=formatDateTime(Hora,4)%>', '<%=LocalID%>')" class="btn btn-xs btn-warning">
                                        <i class="far fa-chevron-left"></i> Repetir Aqui
                                    </button>
                                </td>
                            </tr>
                            <%
                            elseif instr(strAB, "|"&ProfissionalID&"_"&Data&"_"&formatdatetime(Hora,4))>0 then
                                'ProfissionalAB = splAB(0)
                                'DataAB = splAB(1)
                                'HoraAB = splAB(2)
                                '!!! aqui tera um if em js pra ver se a data é a mesma
                                set pusuAb = db.execute("select id from sys_users where AgAberto like '%"& ProfissionalID&"_"&Data&"_"&formatdatetime(Hora,4) &"%'")
                                if not pusuAb.eof then
                                    nUsuAb = nameInTable(pusuAb("id"))
                                else
                                    nUsuAb = " outro usuário"
                                end if
                                txtAB = "<em>Este horário está sendo utilizado por "& nUsuAb &"."'"& nameInTable(vcaAB("id")) &".</em>"
                            %>
                            <tr class="alert l l<%= LocalID %> vazio" data-hora="<%=formatdatetime(Hora, 4)%>" data-horaid="<%= horaid %>" id="<%=HoraID%>">
                                <td width="1%"></td>
                                <td width="1%"><button type="button" class="btn btn-xs btn-alert"><%= formatdatetime(Hora,4) %></button></td>
                                <td colspan="4">
                                    <%= txtAB %>
                                </td>
                            </tr>
                            <%
                            else
                                HLivres = HLivres+1
                            %>
                            <tr onclick="abreAgenda('<%=HoraID%>', 0, '<%=Data%>', <%=LocalID%>, <%=ProfissionalID%>,<%=GradeID%>)" data-grade="<%=GradeID%>"  class="l l<%= LocalID %> vazio" data-hora="<%=formatdatetime(Hora, 4)%>" data-horaid="<%= horaid %>" id="<%=HoraID%>">
                                <td class="agenda-horario-txt" width="1%"><%= formatdatetime(Hora,4) %></td>
                                <td width="1%"></td>
                                <td colspan="4"><%= Tipo %></td>
                            </tr>
                            <%
                            end if
                            Hora = dateadd("n", Intervalo, Hora)
                        wend
                    else
                        txtHorarios = Horarios("Horarios")&""
                        if instr(txtHorarios, ",") then
                            splHorarios = split(txtHorarios, ",")
                            for ih=0 to ubound(splHorarios)
                                HoraPers = trim(splHorarios(ih))
                                if isdate(HoraPers) then
                                    HLivres = HLivres+1
                                    HoraID = horaToID(HoraPers)
                                    if session("FilaEspera")<>"" then
                                    %>
                                    <tr class="l vazio" data-hora="<%=formatdatetime(HoraPers, 4)%>" data-horaid="<%= HoraID %>" id="<%=HoraID%>">
                                        <td width="1%"></td>
                                        <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(HoraPers,4) %></button></td>
                                        <td colspan="4">
                                            <button type="button" onclick="filaEspera('U_<%=session("FilaEspera")%>_<%=formatDateTime(HoraPers,4)%>')" class="btn btn-xs btn-primary">
                                                <i class="far fa-chevron-left"></i> Agendar Aqui
                                            </button>
                                        </td>
                                    </tr>
                                    <%
                                    elseif session("RemSol")<>"" then
                                    %>
                                    <tr class="l l<%= LocalID %> vazio" data-hora="<%=formatdatetime(HoraPers, 4)%>" data-horaid="<%= horaid %>" id="<%=HoraID%>">
                                        <td width="1%"></td>
                                        <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(HoraPers,4) %></button></td>
                                        <td colspan="4">
                                            <button type="button" onclick="remarcar(<%=session("RemSol")%>, 'Remarcar', '<%=formatDateTime(HoraPers,4)%>', '<%=LocalID%>')" class="btn btn-xs btn-warning">
                                                <i class="far fa-chevron-left"></i> Remarcar Aqui
                                            </button>
                                        </td>
                                    </tr>
                                    <%
                                    elseif session("RepSol")<>"" then
                                    %>
                                    <tr class="l l<%= LocalID %> vazio" data-hora="<%=formatdatetime(HoraPers, 4)%>" data-horaid="<%= horaid %>" id="<%=HoraID%>">
                                        <td width="1%"></td>
                                        <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(HoraPers,4) %></button></td>
                                        <td colspan="4">
                                            <button type="button" onclick="repetir(<%=session("RepSol")%>, 'Repetir', '<%=formatDateTime(HoraPers,4)%>', '<%=LocalID%>')" class="btn btn-xs btn-warning">
                                                <i class="far fa-chevron-left"></i> Repetir Aqui
                                            </button>
                                        </td>
                                    </tr>
                                    <%
                                    else
                                    %>
                                    <tr onclick="abreAgenda('<%= HoraID %>', 0, '<%=Data%>', <%=LocalID%>, <%=ProfissionalID%>, '<%=GradeID%>')" data-grade="<%=GradeID%>" class="l l<%= LocalID %> vazio" data-HoraID="<%= HoraID %>" data-hora="<%=formatdatetime(HoraPers, 4)%>" id="<%=HoraID%>">
                                        <td width="1%"></td>
                                        <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(HoraPers,4) %></button></td>
                                        <td colspan="4"><%= Tipo %></td>
                                    </tr>
                                    <%
                                    end if
                                end if
                            next
                        end if
                    end if
                    elseif instr(""&session("Unidades")&"", "|"&Horarios("UnidadeID")&"|") > 0 then
                    %>
                    <tr><td class="text-center" colspan="6"><small>Não há grade configurada para este dia da semana.</small></td></tr>
                    <%
                    end if
                Horarios.movenext
                wend
                Horarios.close
                set Horarios=nothing
                end if
              %>
              <tr class="hidden l l<%= LocalID %>" data-horaid="2359" id="<%= LocalID %>2359"></tr>
          </tbody>
</table>
                <script>
                $("#AbrirEncaixe").attr("disabled", <% if Ativo<>"on" then %>true<%else %>false<% end if%>);
                <%
                somenteStatus = NaoExibirNaAgendaOsStatus
                if somenteStatus&"" <> "" then
                    sqlSomentestatus = " and a.StaID not in("& replace(somenteStatus,"|","") &")"
                end if
                procedimentosQuery = " (select group_concat(procedimentos.NomeProcedimento) from agendamentosprocedimentos left join procedimentos on procedimentos.id = agendamentosprocedimentos.TipoCompromissoID where agendamentosprocedimentos.AgendamentoID = a.id) as procedimento1, (select group_concat(procedimentos.NomeProcedimento) from agendamentos left join  procedimentos on procedimentos.id = agendamentos.TipoCompromissoID where agendamentos.id = a.id) as procedimento2 "
                compsSql = "select *, concat(procedimento1, ', ', procedimento2) as ProcedimentosList, k.ValorPlano+(select if(rdValorPlano = 'V', ifnull(sum(ValorPlano),0),0) from agendamentosprocedimentos where agendamentosprocedimentos.agendamentoid = k.id) as ValorPlano from (select a.id, "& procedimentosQuery &", a.Data, a.Hora, a.LocalID, a.ProfissionalID, a.StaID, a.Encaixe, a.Tempo, a.FormaPagto, a.Notas, p.Nascimento, p.NomePaciente, p.IdImportado,a.PacienteID, p.Tel1, p.Cel1, p.matricula1, IF(pacPri.id>0 AND pacPri.sysActive=1,CONCAT(""<i class='"",pacPri.icone,""'></i>""),"""") AS PrioridadeIcone, proc.NomeProcedimento,proc.Cor, s.StaConsulta, a.rdValorPlano, a.ValorPlano,a.Procedimentos, a.Primeira, c.NomeConvenio, l.UnidadeID, l.NomeLocal, (select Resposta from agendamentosrespostas where AgendamentoID=a.id limit 1) Resposta, p.CorIdentificacao, a.Retorno from agendamentos a "&_
                "left join pacientes p on p.id=a.PacienteID "&_
                "LEFT JOIN cliniccentral.pacientesprioridades pacPri ON pacPri.id=p.Prioridade "&_
                "left join procedimentos proc on proc.id=a.TipoCompromissoID "&_
                "left join staconsulta s on s.id=a.StaID "&_
                "left join convenios c on c.id=a.ValorPlano "&_
                "left join locais l on l.id=a.LocalID "
                if NaoExibirOutrasAgendas = 0 then
                    compsWhereSql = "where a.Data="&mydatenull(Data)&" and a.sysActive= 1 and a.ProfissionalID="&ProfissionalID & sqlSomentestatus &" order by Hora) as k"
                else
                    compsWhereSql = "where a.Data="&mydatenull(Data)&" and a.sysActive= 1 and a.ProfissionalID="&ProfissionalID & sqlSomentestatus &" AND COALESCE( l.UnidadeID = "&session("UnidadeID")&",FALSE) order by Hora) as k"
                end if
                set comps=db.execute(compsSql&compsWhereSql)

                while not comps.EOF
                    FormaPagto = comps("FormaPagto")
                    UnidadeID = comps("UnidadeID")
                    CorIdentificacao = comps("CorIdentificacao")
                    pacientePrioridadeIcone = comps("PrioridadeIcone")
                    Tempo = 0
                    ValorProcedimentosAnexos = 0
                    podeVerAgendamento=True
                    if UnidadeID&""<>"" and session("admin")=0 and session("Partner")="" and NaoExibirAgendamentoLocal=1 then
                        if instr(session("Unidades"),"|"&UnidadeID&"|")=0 then
                            podeVerAgendamento=False
                        end if
                    end if
					NomeProcedimento = replace(comps("NomeProcedimento"), "`", "")
					VariosProcedimentos = comps("ProcedimentosList")&""
					if VariosProcedimentos<>"" then
					    NomeProcedimento = VariosProcedimentos
					end if
                    'soma o tempo dos procedimentos anexos
                    if VariosProcedimentos<>"" and instr(VariosProcedimentos, ",") then
                        set ProcedimentosAnexosTempoSQL = db.execute("SELECT sum(Tempo)Tempo, sum(IF(rdValorPlano='V',ValorPlano,0))Valor FROM agendamentosprocedimentos WHERE Tempo IS NOT NULL AND AgendamentoID="&comps("id"))
                        if not ProcedimentosAnexosTempoSQL.eof then
                            if not isnull(ProcedimentosAnexosTempoSQL("Tempo")) then
                                Tempo = Tempo + ccur(ProcedimentosAnexosTempoSQL("Tempo"))
                            end if
                            'if not isnull(ProcedimentosAnexosTempoSQL("Valor")) then
                                'ValorProcedimentosAnexos = ValorProcedimentosAnexos + ccur(ProcedimentosAnexosTempoSQL("Valor"))
                            'end if
                        end if
                    end if
					if comps("rdValorPlano")="V" then
						if (lcase(session("table"))="profissionais" and cstr(session("idInTable"))=ProfissionalID) or (session("admin")=1) or aut("|valordoprocedimentoV|")=1 then
							Valor = comps("ValorPlano")
							if not isnull(Valor) then
							    Valor = Valor + ValorProcedimentosAnexos
								Valor = "R$ "&formatnumber(Valor, 2)
							else
								Valor = "R$ 0,00"
							end if
						else
							Valor = "Particular"
						end if
						if aut("areceberpacienteV")=0 then
							Valor = ""
						end if
					else
						Valor = comps("NomeConvenio")
					end if
                    HoraComp = HoraToID(comps("Hora"))
					Horario = comps("Hora")
					if isnull(Horario) then
						Horario = "00:00"
					end if
					if not isnull(comps("Hora")) then
						compsHora = formatdatetime( comps("Hora"), 4 )
					else
						compsHora = ""
					end if
					'->hora final
					if not isnull(comps("Tempo")) and comps("Tempo")<>"" and isnumeric(comps("Tempo")) then
						Tempo = Tempo + ccur(comps("Tempo"))
					end if
					if isdate(Horario) and Horario<>"" then
						HoraFinal = dateadd("n", Tempo, Horario)
						HoraFinal = formatdatetime( HoraFinal, 4 )
						HoraFinal = HoraToID(HoraFinal)
						if HoraFinal<=HoraComp then
							HoraFinal = ""
						end if
					else
						HoraFinal = ""
					end if
					'<-hora final

					'-->Adicionando ao Prontuário o IDImportado
					'if session("banco")="clinic1612" or session("banco")="clinic5868" or session("banco")="clinic3610" or session("banco")="clinic105" or session("banco")="clinic3859" or session("banco")="clinic5491" then
                    if AlterarNumeroProntuario = "1" then
                        Prontuario = comps("idImportado")
                        if isnull(Prontuario) then
                            Prontuario = ""
                        end if
                    else
                        Prontuario = comps("PacienteID")
                    end if
					'<--
					CorLinha = ""
                    AlturaLinha = " style=\'height: 30px\' "
                    if ColorirLinhaAgendamento=1 then
                        if comps("Cor") <> "#fff" and not isnull(comps("Cor")) then
                            CorLinha = " bgcolor =\'"&comps("Cor")&"\'"
                        end if
                    end if
                    if AumentarAlturaLinhaAgendamento=1 then
                        if Tempo&""<>"" and Tempo>30 then
                            AlturaLinha = " style=\'height: "&Tempo&"px\' "
                        end if
                    end if
                     if comps("matricula1") <>"" then

						matricula1 = "<br>Matrícula: "&comps("matricula1")

						if session("banco") = "clinic10402" and len(comps("matricula1")) > 21 then
							matricula1 = "<br>Matrícula: "&mid(comps("matricula1"),8,7)
						end if

                    else
                        matricula1 = "<br>Matrícula: *"
                    end if
                    linkAg = " onclick=""abreAgenda(\'"&HoraComp&"\', "&comps("id")&", \'"&comps("Data")&"\', \'"&comps("LocalID")&"\', \'"&comps("ProfissionalID")&"\',\'GRADE_ID\')"" "
                    Conteudo = "<tr style='background-color:#ffffff;color:#7e7e7e' "&linkAg&" id="""&HoraComp&""" "&CorLinha & AlturaLinha&" data-local='"&comps("LocalID")&"' data-toggle=""tooltip"" data-html=""true"" data-placement=""bottom"" title="""&fix_string_chars_full(comps("NomePaciente"))&"<br>Prontuário: "&Prontuario&matricula1&"<br>"

                    if session("RemSol")<>"" and session("RemSol")&"" <> comps("id")&"" then
                        remarcarlink = " onclick=""remarcar("&session("RemSol")&", \'Remarcar\', \'"&compsHora&"\', \'"&comps("LocalID")&"\')"" "
                        remarcarAqui = "<td ><button class=""btn btn-xs btn-info"" "&remarcarlink&" ><i class=""far fa-external-link""></i> Encaixe </button></td>"
                    end if

                    if instr(omitir, "tel1")=0 then
                        Conteudo = Conteudo & "Tel.: "&replace(comps("Tel1")&" ", "'", "\'")&"<br>"
                    end if
                    if instr(omitir, "cel1")=0 then
                        Conteudo = Conteudo & "Cel.: "&replace(comps("Cel1")&" ", "'", "\'")&"<br>"
                    end if
                    'if session("Banco")="clinic5594" then
                        notas = comps("Notas")
                        'notas = RemoveCaracters(comps("Notas"),"!?:;*/"&chr(13)&chr(10))
                        notas = fix_string_chars_full(notas)
                        Conteudo = Conteudo & "Notas: "&notas&"<br>"
                        'Conteudo = Conteudo & "Notas: "&replace(replace(replace(replace(comps("Notas")&"", chr(13), ""), chr(10), ""), "'", ""), """", "")&"<br>"
                    'end if
                    Conteudo = Conteudo & "Idade: "& IdadeAbreviada(comps("Nascimento")) &"<br>"
                    Conteudo = Conteudo & """ data-id="""&comps("id")&""">"&_
                    "<td width=""1%"" width=""1%"" nowrap "&FirstTdBgColor&" class='agenda-horario-txt btn-comp' data-hora="""&replace( compsHora, ":", "" )&""">"&compsHora&"</td>"
                    Conteudo = Conteudo & "<td width=""1%"">"

                    if not isnull(comps("Resposta")) then
                        Conteudo = Conteudo & "<i class=""far fa-envelope pink""></i> "
                    end if
                    if comps("Primeira")=1 then
                        Conteudo = Conteudo & "<i class=""far fa-flag blue"" title=""Primeira vez""></i>"
                    end if
                    ' if comps("LocalID")<>LocalID then
                        Conteudo = Conteudo & "<i class=""far fa-exclamation-triangle grey hide"" title=""Agendado para &raquo; "&replace(comps("NomeLocal")&" ", "'", "\'")&"""></i>"
                    'end if
                    FirstTdBgColor = ""
                    if ExibirCorPacienteAgenda=1 then
                        if (ISNULL(CorIdentificacao) or CorIdentificacao="") then
                            CorIdentificacao = "transparent"
                        end if
                        FirstTdBgColor = " style=\'border:4px solid "&CorIdentificacao&"!important\' "
                    end if
                    if session("Banco")="clinic4134" then
                        Conteudo = Conteudo & "<button type=""button"" onclick=""abreAgenda(\'"&HoraComp&"\', 0, \'"&comps("Data")&"\', \'"&comps("LocalID")&"\', \'"&comps("ProfissionalID")&"\')"" class=""btn btn-xs btn-system ml5""><i class=""far fa-plus""></i></button>"
                    end if
                    Conteudo = Conteudo & "</td>"&_
                    "<td  nowrap >"&pacientePrioridadeIcone&"  <span></span>"
                    if comps("Encaixe")=1 and OmitirEncaixeGrade=0 then
                        Conteudo = Conteudo & "&nbsp;<span class=""label bg-alert label-sm arrowed-in mr10 arrowed-in-right"">Encaixe</span>"
                    end if
                    Conteudo = Conteudo & "<span class=""nomePac"">"& fix_string_chars_full(comps("NomePaciente")) &"</span><br><span>"&CorProcedimento&replace(replace(NomeProcedimento&" ", "'", "\'"),"\","\\")&"</span>"
                    CorProcedimento = ""
                    if comps("Cor") <> "#fff" and not isnull(comps("Cor")) then
                        CorProcedimento = "<div class=""mr5 mt5"" style=""float:left;position:relative;background-color:"&comps("Cor")&";height:5px;width:5px;border-radius:50%""></div>"
                    end if
                    rotulo = "&nbsp;"&replace(Valor&" ", "'", "\'")
                    if (session("Banco")="clinic100000" or session("Banco")="clinic2263" or session("Banco")="clinic5856") and comps("rdValorPlano")="V" then
                    set TabelaSQL = db.execute("SELECT t.NomeTabela FROM tabelaparticular t LEFT JOIN pacientes p ON p.Tabela=t.id WHERE p.id = "&comps("PacienteID"))
                        if not TabelaSQL.eof then
                            rotulo = TabelaSQL("NomeTabela")
                        end if
                    end if
                    iconRetorno = ""
                    if comps("Retorno") then
                        iconRetorno = "<i data-toggle=""tooltip"" title=""Consulta retorno"" class=""far fa-undo text-warning pt10""></i>"
                    end if
                    Conteudo = Conteudo & "</td>"&_
                    "<td class=""text-center hidden-xs"" ></td>"&_
                    "<td class=""text-center hidden-xs"" >"&comps("StaConsulta")&"</td>"&_
                    "<td class=""text-right nomeConv hidden-xs""><small>"& sinalAgenda(FormaPagto) & rotulo &"</small></td>"&_
                    "</tr>"
                    Conteudo = fix_string_chars(Conteudo)
                    if not podeVerAgendamento then
                        Conteudo = ""
                    end if
					HAgendados = HAgendados+1
					if comps("LocalID")<>LocalID then
					    LocalDiferenteDaGrade=1
					    classeL = ".l"&comps("LocalID")&", .l"
                    else
                        LocalDiferenteDaGrade=0
                        classeL = ".l"&comps("LocalID")
					end if
					if LiberarHorarioRemarcado=1 then
					    StatusRemarcado = " && Status !== '15'"
					end if
                %>
                var classe = "<%=classeL%>";
                var LocalDiferenteDaGrade = "<%=LocalDiferenteDaGrade%>";
                if(LocalDiferenteDaGrade==="1"){
                    if( $(".l<%= comps("LocalID") %>").length>0 ){
                        classe = ".l<%= comps("LocalID") %>";
                    }else{
                        classe = "<%=classeL%>";
                    }
                }
                var HorarioAdicionado = false;
                var Status = '<%=comps("StaID")%>';
                $( classe ).each(function(){
                    if( $(this).attr("data-horaid")=='<%=HoraComp%>' && (Status !== "11" && Status !== "22" && Status !== "33" <%=StatusRemarcado%>))
                    {
                        var gradeId = $(this).data("grade");
                        HorarioAdicionado=true;
                        $(this).replaceWith(`<%= conteudo %>`.replace(new RegExp("GRADE_ID",'g'), gradeId));
                        return false;
                    }
                });
                if(!HorarioAdicionado){
                    $( classe + ", .l").each(function(){
                            var gradeId = $(this).data("grade");
                            let tamanhoGrade = 0;
                            let ultimoHorarioGrade = '0000';
                            if($('tbody[data-localid='+'<%=comps("LocalID")%>'+']').length == 1){
                                tamanhoGrade = parseInt($('tbody[data-localid=<%=comps("LocalID")%>]').children().length)
                                ultimoHorarioGrade = $('tbody[data-localid='+'<%=comps("LocalID")%>'+'] tr:nth-child('+(tamanhoGrade)+')')[0].id
                            }
                           if ( $(this).attr("data-horaid")>'<%=HoraComp%>'){
                                <%if session("FilaEspera")<>"" and comps("StaID") <> "11" then %>
                                    $('[data-horaid=<%=HoraComp%>]').remove();
                                <% end if %>
                                if('<%=HoraComp%>' > ultimoHorarioGrade && $($('#'+ultimoHorarioGrade)).attr('data-local') == '<%=comps("LocalID")%>'){
                                    $($('tbody[data-localid='+'<%=comps("LocalID")%>'+'] tr:nth-child('+(tamanhoGrade)+')')).after(`<%= conteudo %>`.replace(new RegExp("GRADE_ID",'g'), gradeId));
                                }else{
                                    $(this).before(`<%= conteudo %>`.replace(new RegExp("GRADE_ID",'g'), gradeId));
                                }
                                return false;
                           }
                    });
                }
                	<%
					if HoraFinal<>"" then
						%>
						if(Status !== "11" && Status !== "22" <%=StatusRemarcado%>){
                            $( ".vazio" ).each(function(){
                                if( $(this).attr("data-horaid")>'<%=HoraComp%>' && $(this).attr("data-horaid")<'<%=HoraFinal%>' )
                                {
                                    $(this).replaceWith('');
                                    //return false;
                                }
                            });
                        }
						<%
					end if
                comps.movenext
                wend
                comps.close
                set comps = nothing
                'bloqueioSql = "select c.* from compromissos c where (c.ProfissionalID="&ProfissionalID&" or (c.ProfissionalID=0 AND (c.Profissionais = '' or c.Profissionais LIKE '%|"&ProfissionalID&"%|'))) AND ((false "&sqlUnidadesBloqueio&") or c.Unidades='' OR c.Unidades IS NULL) and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" and DiasSemana like '%"&weekday(Data)&"%'"
				bloqueioSql = getBloqueioSql(ProfissionalID, Data, sqlUnidadesBloqueio)
                set bloq = db.execute(bloqueioSql)

                while not bloq.EOF
                    HoraDe = HoraToID(bloq("HoraDe"))
					HoraA = HoraToID(bloq("HoraA"))
                    Conteudo = "<tr id=""'+$(this).attr('data-hora')+'"" onClick=""abreBloqueio("&bloq("id")&", `"&replace(mydatenull(Data)&"","'","")&"`, \'\');"">"&_
					"<td width=""1%""></td><td width=""1%""><button type=""button"" class=""btn btn-xs btn-danger"">'+$(this).attr('data-hora')+'</button></td>"&_
					"<td nowrap><img src=""assets/img/bloqueio.png""> <span class=""nomePac"">"&replace(bloq("Titulo")&" ", "'", "\'")&"</span></td>"&_
					"<td class=""hidden-xs text-center""></td>"&_
					"<td class=""hidden-xs hidden-sm text-center""></td>"&_
					"<td class=""hidden-xs text-right nomeConv""></td>"&_
					"</tr>"
					HBloqueados = HBloqueados+1
					%>
					$( ".vazio" ).each(function(){
						if( $(this).attr("id")>='<%=HoraDe%>' && $(this).attr("id")<'<%=HoraA%>' ){
							$(this).replaceWith('<%= conteudo %>');
						}
					});
					$( ".btn-comp" ).each(function(){
						if( $(this).attr("data-hora")>='<%=HoraDe%>' && $(this).attr("data-hora")<'<%=HoraA%>' )
						{
							$(this).removeClass("btn-default");
							$(this).addClass("btn-danger");
							$(this).html( $(this).html() + ' <i class="far fa-lock"></i>' );
						}
					});
					<%
				bloq.movenext
				wend
				bloq.close
				set bloq=nothing
				%>
                </script>

<input type="hidden" name="DataBloqueio" id="DataBloqueio" value="<%=Data%>" />
<script type="text/javascript">
$(".agendar").click(function(){
	//alert(this.id);
	abreAgenda(this.id, '', $("#Data").val(), $(this).attr("contextmenu") );
});
</script>

<script>
$(document).ready(function(){
    $('[data-toggle="tooltip"]').tooltip();
});
</script>

<br />
<div id="modal-send_sms" class="modal fade" tabindex="-1">
    <div class="modal-dialog modal-sm">
        <div class="modal-content" id="modal" style="width:200px; margin-left:-130px;">
        Carregando...
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div>
<script type="text/javascript">
	jQuery(function($) {
		//show the user info on right or left depending on its position
		$('.nomePaciente').on('mouseenter', function(){
			var $this = $(this);
			$this.find('.popover').fadeIn();
		});
		$('.nomePaciente').on('mouseleave', function(){
			var $this = $(this);
			$this.find('.popover').fadeOut();
		});
	<%
	set ObsDia = db.execute("select * from agendaobservacoes where ProfissionalID="&ProfissionalID&" and Data="&mydatenull(Data)&"")
	if not ObsDia.eof then
		%>
		$("#AgendaObservacoes").not(":focus").val('<%=replace(replace(ObsDia("Observacoes"), chr(10), "\n"), "'", "\'")%>');
		<%
	else
		%>
		$("#AgendaObservacoes").not(":focus").val('');
		<%
	end if
	%>
	});
	$(".dia-calendario").removeClass("success green");
	$(".<%=replace(req("Data"),"/", "-")%>").addClass("success green");
	$(".Locais").html('');
	<%
	set pDiasAT=db.execute("select distinct a.DiaSemana from assfixalocalxprofissional a where a.ProfissionalID = "&ProfissionalID&" and (a.fimVigencia > now() or a.fimVigencia is null)")
	while not pDiasAT.eof
		diasAtende = diasAtende&pDiasAT("DiaSemana")
	pDiasAT.movenext
	wend
	pDiasAT.close
	set pDiasAT=nothing
	dat = 0
	while dat<7
		dat = dat+1
		if instr(diasAtende, dat)=0 then
			%>
			$(".d<%=weekday(dat)%>").addClass("danger");
			<%
		end if
	wend

	if instr(Data,"/") then
        ExcecaoMesAnoSplt = split(Data,"/")
        ExcecaoMesAno = ExcecaoMesAnoSplt(2)&"-"&ExcecaoMesAnoSplt(1)
        sExc = "select DataDe from assperiodolocalxprofissional a where a.DataDe LIKE '"&ExcecaoMesAno&"-%' AND a.DataDe LIKE '"&ExcecaoMesAno&"-%' AND a.ProfissionalID = "&ProfissionalID
        set DiasComExcecaoSQL=db.execute(sExc)
        while not DiasComExcecaoSQL.eof
            diasAtende = DiasComExcecaoSQL("DataDe")
            DataExcecaoClasseSplt = split(diasAtende,"/")
            DataExcecaoClasse = DataExcecaoClasseSplt(0)&"-"&DataExcecaoClasseSplt(1)&"-"&DataExcecaoClasseSplt(2)
                        %>
                        //cidiiddid
        $(".dia-calendario.<%=DataExcecaoClasse%>").removeClass("danger");
                <%
        DiasComExcecaoSQL.movenext
        wend
        DiasComExcecaoSQL.close
        set DiasComExcecaoSQL=nothing
    end if
    call agendaOcupacoes(ProfissionalID, Data)
	%>
// Create the tooltips only when document ready
 $(document).ready(function()
 {
     // MAKE SURE YOUR SELECTOR MATCHES SOMETHING IN YOUR HTML!!!
     $('.dia-calendario').each(function() {
         $(this).qtip({
            content: {
                text: function(event, api) {
                    $.ajax({
                        url: 'AgendaResumo.asp?D='+api.elements.target.attr('id')+'&ProfissionalID='+$("#ProfissionalID").val() // Use href attribute as URL
                    })
                    .then(function(content) {
                        // Set the tooltip content upon successful retrieval
                        api.set('content.text', content);
                    }, function(xhr, status, error) {
                        // Upon failure... set the tooltip content to error
                        api.set('content.text', status + ': ' + error);
                    });
                    return 'Carregando resumo do dia...'; // Set some initial text
                }
            },
            position: {
                viewport: $(window)
            },
            style: 'qtip-wiki'
         });
     });
    confereLocal()
 });
function confereLocal(){
    let linhas = $("tr[data-local]")
    linhas.map((key,elem)=>{
        let idlocal = $(elem).parent().attr('data-localid')
        let idlinha = $(elem).attr('data-local')
        if(idlinha != idlocal){
            $(elem).find('.fa-exclamation-triangle').removeClass("hide")
        }
    })
}
<%
if session("RemSol")<>"" or session("RepSol")<>"" then
	%>
	<!--#include file="JQueryFunctions.asp"-->
	<%
else
	%>
	var HLivres = [$(".vazio").size()];
	var HAgendados = ["<%=HAgendados%>"];
	var HBloqueados = [$(".btn-danger").size()];
	var LocalID = ["<%=LocalID%>"];
	var ProfissionalID = ["<%=ProfissionalID%>"];
	var Data = ["<%=Data%>"];
	var ocupacoes = {
	    "HLivres[]": HLivres,
	    "HAgendados[]": HAgendados,
	    "HBloqueados[]": HBloqueados,
	    "LocalID[]": LocalID,
	    "ProfissionalID[]": ProfissionalID,
	    "Data[]": Data
	};
	$.post("atualizaOcupacoes.asp", ocupacoes, function(data, status){ eval(data) });
	<%
end if
%>
</script>
<!--#include file = "disconnect.asp"-->