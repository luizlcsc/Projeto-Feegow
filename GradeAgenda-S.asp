<%InicioProcessamento = Timer%>
<!--#include file="connect.asp"-->
<!--#include file="Classes/StringFormat.asp"-->
<!--#include file="Classes/ValidaProcedimentoProfissional.asp"-->
<!--#include file="Classes/GradeAgendaUtil.asp"-->
<%
'on error resume next
ColorirLinhaAgendamento = getConfig("ColorirLinhaAgendamento")
OmitirEncaixeGrade = getConfig("OmitirEncaixeGrade")
HLivres = 0
HAgendados = 0
HBloqueados = 0

if req("Data")="" then
	Data=date()
else
	Data=req("Data")
end if

DataSel = cdate(Data)

if weekday(Data)>1 then
	Data = dateAdd("d", (weekday(Data)-1)*(-1), Data)
end if

PrimeiroDiaSemana = Data

ProfissionalID=req("ProfissionalID")
DiaSemana=weekday(Data)
mesCorrente=month(Data)


if lcase(session("Table"))="funcionarios" then
	session("UltimaAgenda") = ProfissionalID
end if
LiberarHorarioRemarcado = getConfig("LiberarHorarioRemarcado")


set prof = db.execute("select Cor, NomeProfissional, Foto, ObsAgenda from profissionais where id="&ProfissionalID)
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
<script type="text/javascript">
    function crumbAgenda(){
        $(".crumb-active").html("<a href='./?P=Agenda-S&Pers=1'>Agenda semanal</a>");
        $(".crumb-icon a span").attr("class", "far fa-calendar");
        $(".crumb-link").replaceWith("");
        $(".crumb-trail").removeClass("hidden");
        $(".crumb-trail").html("<%=(escreveData)%>");
        $("#rbtns").html("");
    }
    crumbAgenda();

    $("#FotoProfissional").css("border-left", "4px solid <%=Cor%>");
    $("#FotoProfissional").css("background-image", "url(<%=FotoProfissional%>)");
    //$("#Data").val("<%= Data %>");
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

<div class="col-md-offset-10 col-md-2 text-right" style="padding: 5px">
    <a href="javascript:loadAgenda('<%=dateadd("d", -7, Data)%>', $('#ProfissionalID').val() );" id="anterior" class="btn btn-default btn-sm"><i class="far fa-chevron-left"></i></a>
    <a href="javascript:loadAgenda('<%=dateadd("d", 7, Data)%>', $('#ProfissionalID').val() );" id="proxima" class="btn btn-default btn-sm"><i class="far fa-chevron-right"></i></a>
    <a href="javascript:loadAgenda('<%=date()%>', $('#ProfissionalID').val() );" class="btn btn-default btn-sm">Hoje</a>
</div>

<%
if session("FilaEspera")<>"" then
	set fila = db.execute("select f.id, p.NomePaciente from filaespera as f left join pacientes as p on p.id=f.PacienteID where f.id="&session("FilaEspera")&" and f.ProfissionalID like '"&ProfissionalID&"'")
	if not fila.eof then
		UtilizarFila = fila("id")
		%>
		<span class="label block arrowed-in label-lg label-pink">Selecione um hor&aacute;rio abaixo para agendar <%=fila("NomePaciente")%></span>
        <%
	end if
end if
if session("RemSol")<>"" then
Ativo = "off"
remarcarSql = "select a.TipoCompromissoID, a.ProfissionalID, a.EspecialidadeID, if(a.rdValorPlano='P',a.ValorPlano,'') as ConvenioID from agendamentos a where id="&session("RemSol")
'response.write testesql
set RemSql = db.execute(remarcarSql)

RemarcarAssociacao = 5
RemarcarProfissionalID = req("ProfissionalID")
RemarcarEspecialidadeID = RemSql("EspecialidadeID")
RemarcarProcedimentoID = RemSql("TipoCompromissoID")
RemarcarConvenio = RemSql("ConvenioID")

profissionalValido = validaProcedimentoProfissional(5 ,RemarcarProfissionalID, RemarcarEspecialidadeID,  RemarcarProcedimentoID,"")

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

	%>
	<div class="alert alert-default col-md-12 text-center" style="padding: 5px">
            Selecione um hor&aacute;rio disponível
            <button type="button" class="btn btn-sm btn-danger" onClick="remarcar(<%=session("RemSol")%>, 'Cancelar', '')"><i class="far fa-times"></i> Cancelar</button>
    </div>
	<%
end if
if session("RepSol")<>"" then
	%>
	<div class="alert alert-default col-md-12 text-center" style="padding: 5px">
        Selecione um hor&aacute;rio disponível
        <button type="button" class="btn btn-sm btn-danger" onClick="repetir(<%=session("RepSol")%>, 'Cancelar', '')"><i class="far fa-times"></i> Parar Repeti&ccedil;&atilde;o</button>
    </div>
	<%
end if


%>



<div class="row">
<table class="table">
<tr>
<%
n = 7
diaS = 0
CorGeral = Cor
while diaS<n
  DiaSemana = weekday(Data)
  diaS=diaS+1
  
  escreveData = left(weekdayname(DiaSemana), 3) &", "&Data

  table_striped = "table-striped"
  if ColorirLinhaAgendamento=1 then
    table_striped = ""
  end if
  
  %>
  <td width="14%" class="pn" style="vertical-align:top">
    <table data-weekday="<%=diaS%>" class="table dia-semana-coluna <%=table_striped%> table_striped table-hover table-bordered table-condensed table-agenda mn">
    <thead>
        <tr>
            <th colspan="6" class="text-center<% If cdate(Data)=DataSel Then %> success<% End If %>" nowrap><%=ucase(escreveData)%></th>
        </tr>
    </thead>
         <tbody>
            <tr class="hidden l<%=LocalID%>" id="<%=DiaSemana%>0000"></tr>
         <%
            sqlUnidadesBloqueio=""
            Hora = cdate("00:00")
            set Horarios = db.execute("select ass.*, '' Cor, l.NomeLocal, '0' TipoGrade,  l.UnidadeID, '0' GradePadrao from assperiodolocalxprofissional ass LEFT JOIN locais l on l.id=ass.LocalID where ass.ProfissionalID="&ProfissionalID&sqlProcedimentoPermitido & sqlConvenioPermitido & sqlEspecialidadePermitido &" and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" order by HoraDe")
            if Horarios.EOF then
                set Horarios = db.execute("select ass.*, l.NomeLocal, l.UnidadeID, '1' GradePadrao, '' Cor from assfixalocalxprofissional ass LEFT JOIN locais l on l.id=ass.LocalID where ass.ProfissionalID="&ProfissionalID&sqlProcedimentoPermitido & sqlConvenioPermitido & sqlEspecialidadePermitido &" and ass.DiaSemana="&DiaSemana&" AND ((ass.InicioVigencia IS NULL OR ass.InicioVigencia <= "&mydatenull(Data)&") AND (ass.FimVigencia IS NULL OR ass.FimVigencia >= "&mydatenull(Data)&")) order by ass.HoraDe")
            end if

            while not Horarios.EOF
                LocalID = Horarios("LocalID")
                UnidadeID = Horarios("UnidadeID")
                MostraGrade=True

                if UnidadeID&"" <> "" and session("admin")=0 then
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
                
                Cor = CorGeral
                if Horarios("Cor")&""<>"" then
                    Cor = Horarios("Cor")
                end if
                %>
                <tr>
                    <td colspan="6" nowrap class="nomeProf text-center" style="background-color:<%=Cor%>;">
                         <%=ucase(Horarios("NomeLocal")&" ")%><%=getNomeLocalUnidade(Horarios("UnidadeID"))%><input type="hidden" name="LocalEncaixe" id="LocalEncaixe" value="<%=LocalID%>">
                    </td>
                </tr>
                <%
                if Horarios("TipoGrade")=0 then

                    if UnidadeID&"" <> "" and session("Partner")="" then
                        sqlUnidadesBloqueio = sqlUnidadesBloqueio&" OR c.Unidades LIKE '%|"&UnidadeID&"|%'"
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
                    while Hora<=HoraA
                        GradeID=Horarios("id")
                        if Horarios("GradePadrao")="0" then
                            GradeID=GradeID*-1
                        end if
                        HoraID = formatdatetime(Hora, 4)
                        HoraID = replace(HoraID, ":", "")
                        if session("FilaEspera")<>"" then
                        %>
                        <tr class="l vazio<%= DiaSemana %>" data-hora="<%=formatdatetime(Hora, 4)%>" id="<%=DiaSemana&HoraID%>">
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
                        %>
                        <tr class="l vazio<%= DiaSemana %> l<%= LocalID %>" data-hora="<%=formatdatetime(Hora, 4)%>" id="<%=DiaSemana&HoraID%>">
                            <td width="1%"></td>
                            <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(Hora,4) %></button></td>
                            <td colspan="4">
                                <button type="button" onclick="remarcar(<%=session("RemSol")%>, 'Remarcar', '<%=formatDateTime(Hora,4)%>', '<%=LocalID%>', '<%= Data %>')" class="btn btn-xs btn-warning">
                                    <i class="far fa-chevron-left"></i> Remarcar Aqui 
                                </button>
                            </td>
                        </tr>
                        <%
                        elseif session("RepSol")<>"" then
                        %>
                        <tr class="l vazio<%= DiaSemana %>" data-hora="<%=formatdatetime(Hora, 4)%>" id="<%=DiaSemana&HoraID%>">
                            <td width="1%"></td>
                            <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(Hora,4) %></button></td>
                            <td colspan="4">
                                <button type="button" onclick="repetir(<%=session("RepSol")%>, 'Repetir', '<%=formatDateTime(Hora,4)%>', '<%=LocalID%>', '<%= Data %>')" class="btn btn-xs btn-warning">
                                    <i class="far fa-chevron-left"></i> Repetir Aqui
                                </button>
                            </td>
                        </tr>
                        <%
                        else
                            HLivres = HLivres+1
                        %>
                        <tr data-grade="<%=GradeID%>" onclick="abreAgenda('<%=HoraID%>', 0, '<%=Data%>', <%=LocalID%>, <%=ProfissionalID%>,<%=GradeID%>)" class="l l<%= LocalID %> vazio<%= DiaSemana %>" data-hora="<%=formatdatetime(Hora, 4)%>" id="<%=DiaSemana&HoraID%>">
                            <td width="1%"></td>
                            <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(Hora,4) %></button></td>
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
                                <tr class="l vazio<%= DiaSemana %>" data-hora="<%=formatdatetime(HoraPers, 4)%>" data-horaid="<%= HoraID %>" id="<%=DiaSemana&HoraID%>">
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
                                <tr class="l l<%= LocalID %> vazio<%= DiaSemana %>" data-hora="<%=formatdatetime(HoraPers, 4)%>" data-horaid="<%= horaid %>" id="<%=DiaSemana&HoraID%>">
                                    <td width="1%"></td>
                                    <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(HoraPers,4) %></button></td>
                                    <td colspan="4">
                                        <button type="button" onclick="remarcar(<%=session("RemSol")%>, 'Remarcar', '<%=formatDateTime(HoraPers,4)%>', '<%=LocalID%>', '<%= Data %>')" class="btn btn-xs btn-warning">
                                            <i class="far fa-chevron-left"></i> Remarcar Aqui
                                        </button>
                                    </td>
                                </tr>
                                <%
                                elseif session("RepSol")<>"" then
                                %>
                                <tr class="l l<%= LocalID %> vazio<%= DiaSemana %>" data-hora="<%=formatdatetime(HoraPers, 4)%>" data-horaid="<%= horaid %>" id="<%=DiaSemana&HoraID%>">
                                    <td width="1%"></td>
                                    <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(HoraPers,4) %></button></td>
                                    <td colspan="4">
                                        <button type="button" onclick="repetir(<%=session("RepSol")%>, 'Repetir', '<%=formatDateTime(HoraPers,4)%>', '<%=LocalID%>', '<%= Data %>')" class="btn btn-xs btn-warning">
                                            <i class="far fa-chevron-left"></i> Repetir Aqui
                                        </button>
                                    </td>
                                </tr>
                                <%
                                else

                                %>
                                <tr onclick="abreAgenda('<%= HoraID %>', 0, '<%=Data%>', <%=LocalID%>, <%=ProfissionalID%>)" class="l l<%= LocalID %> vazio<%= DiaSemana %> vazio" data-HoraID="<%= HoraID %>" data-hora="<%=formatdatetime(HoraPers, 4)%>" id="<%=DiaSemana&HoraID%>" >
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
                end if
            Horarios.movenext
            wend
            Horarios.close
            set Horarios=nothing
          %>
            <tr class="hidden l" id="<%=DiaSemana%>2359"></tr>
          </tbody>
    </table>
	<script>
    <%

    somenteStatus = getConfig("NaoExibirNaAgendaOsStatus")
    if somenteStatus&"" <> "" then
        sqlSomentestatus = " and a.StaID not in("& replace(somenteStatus,"|","") &")"
    end if

    set comps=db.execute("select a.id, a.Data, a.Hora, a.LocalID, a.ProfissionalID, a.PacienteID,a.StaID, a.FormaPagto, a.Encaixe, a.Tempo, a.Procedimentos, a.Primeira, p.NomePaciente, p.IdImportado, p.Tel1, p.Cel1, p.CorIdentificacao, proc.NomeProcedimento,proc.Cor , s.StaConsulta, a.rdValorPlano, a.ValorPlano, a.Notas, c.NomeConvenio, l.UnidadeID, l.NomeLocal, (select Resposta from agendamentosrespostas where AgendamentoID=a.id limit 1) Resposta from agendamentos a "&_
    "left join pacientes p on p.id=a.PacienteID "&_
    "left join procedimentos proc on proc.id=a.TipoCompromissoID "&_
    "left join staconsulta s on s.id=a.StaID "&_
    "left join convenios c on c.id=a.ValorPlano "&_
    "left join locais l on l.id=a.LocalID "&_
    "where a.Data="&mydatenull(Data)&" and a.sysActive=1 and a.ProfissionalID="&ProfissionalID&sqlSomentestatus&" order by Hora")

    while not comps.EOF
        Tempo=0
        ValorProcedimentosAnexos=0
        podeVerAgendamento=True
        UnidadeID=comps("UnidadeID")
        CorIdentificacao = comps("CorIdentificacao")

        if UnidadeID&""<>"" and session("admin")=0 then
            if instr(session("Unidades"),"|"&UnidadeID&"|")=0 then
                podeVerAgendamento=False
            end if
        end if

        NomeProcedimento = comps("NomeProcedimento")
        VariosProcedimentos = comps("Procedimentos")&""
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
                if not isnull(ProcedimentosAnexosTempoSQL("Valor")) then
                    ValorProcedimentosAnexos = ValorProcedimentosAnexos + ccur(ProcedimentosAnexosTempoSQL("Valor"))
                end if
            end if
        end if

        if comps("rdValorPlano")="V" then
            if (lcase(session("table"))="profissionais" and cstr(session("idInTable"))=ProfissionalID) or (session("admin")=1) then
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
        FormaPagto = comps("FormaPagto")
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
		else
			Tempo = 0
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
        if getConfig("AlterarNumeroProntuario") = 1 then
        'if session("banco")="clinic1612" or session("banco")="clinic3610" or session("banco")="clinic105" or session("banco")="clinic3859" or session("banco")="clinic5491" then
            Prontuario = comps("idImportado")
            if isnull(Prontuario) then
                Prontuario = ""
            end if
        else
            Prontuario = comps("PacienteID")
        end if
        '<--
        CorLinha = ""
        if ColorirLinhaAgendamento=1 then
            if comps("Cor") <> "#fff" and not isnull(comps("Cor")) then
                CorLinha = "style=\'background-color:"&comps("Cor")&"!important\'"
            end if
        end if
        LocalDiferente=""

		    titleSemanal= replace(fix_string_chars_full(comps("NomePaciente"))&"<br>"&NomeProcedimento&"<br>Prontuário: "&Prontuario&"<br>Tel.: "&comps("Tel1")&"<br>Cel.: "&comps("Cel1")&" "&"<br> ", "'", "\'") & "Notas: "&fix_string_chars_full(comps("Notas")&"")&"<br>"
               
        Conteudo = "<tr id="""&DiaSemana&HoraComp&""""&CorLinha &" data-toggle=""tooltip"" data-html=""true"" data-placement=""bottom"" title="""&titleSemanal&""" onclick=""abreAgenda(\'"&HoraComp&"\', "&comps("id")&", \'"&comps("Data")&"\', \'"&comps("LocalID")&"\', \'"&comps("ProfissionalID")&"\',\'GRADE_ID\')"">"&_
        "<td width=""1%"">"
                if not isnull(comps("Resposta")) then
            Conteudo = Conteudo & "<i class=""far fa-envelope pink""></i> "
        end if
        if comps("Primeira")=1 then
            Conteudo = Conteudo & "<i class=""far fa-flag blue"" title=""Primeira vez""></i>"
        end if
        if comps("LocalID")<>LocalID then
            Conteudo = Conteudo & " [LOCAL_DIF] "
            LocalDiferente = "<i class=""far fa-exclamation-triangle grey"" title=""Agendado para &raquo; "&replace(comps("NomeLocal")&" ", "'", "\'")&"""></i>"
        end if
        FirstTdBgColor = ""
        if getConfig("ExibirCorPacienteAgenda")&""=1 then
            if (ISNULL(CorIdentificacao) or CorIdentificacao="") then
                CorIdentificacao = "transparent"
            end if
            FirstTdBgColor = " style=\'border:4px solid "&CorIdentificacao&"!important\' "
        end if
        statusIcon = imoon(comps("StaID"))

        Conteudo = Conteudo & "</td><td width=""1%"" "&FirstTdBgColor&"><button type=""button"" data-hora="""&replace( compsHora, ":", "" )&""" class=""btn btn-xs btn-default btn-comp"& DiaSemana &""">"&compsHora&"</button></td>"&_
        "<td nowrap> "&statusIcon
        if comps("Encaixe")=1 and OmitirEncaixeGrade=0 then
            Conteudo = Conteudo & "<span class=""label label-alert"">enc</span>"
        end if
        Conteudo = Conteudo & "<span class=""nomePac"">"&fix_string_chars_full(comps("NomePaciente"))&"</span>  <span class=""pull-right"">"& sinalAgenda(FormaPagto) &"</span>"
        Conteudo = Conteudo & "</td>"&_
        "</tr>"
        
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
            if( $(".l<%= comps("LocalID") %>", $(".dia-semana-coluna[data-weekday=<%=diaS%>]")).length>0 ){
                classe = ".l<%= comps("LocalID") %>";
            }else{
                classe = "<%=classeL%>";
            }
        }


        var HorarioAdicionado = false;
        var Status = '<%=comps("StaID")%>';

        $( classe ).each(function(){
            if( $(this).attr("id")=='<%=DiaSemana&HoraComp%>' && (Status !== "11" && Status !== "22" && Status !== "33" <%=StatusRemarcado%>))
            {
                var gradeId = $(this).data("grade");

                var conteudo =`<%= conteudo %>`;
                HorarioAdicionado=true;

                if (!$(this).hasClass("l<%=comps("LocalID")%>")){
                    conteudo = conteudo.replace("[LOCAL_DIF]",'<%=LocalDiferente%>');
                }else{
                    conteudo = conteudo.replace("[LOCAL_DIF]",'');
                }

                $(this).replaceWith(conteudo.replace(new RegExp("GRADE_ID",'g'), gradeId));
                return false;
            }
        });
        if(!HorarioAdicionado){
            $( classe + ", .l").each(function(){
                   if ( $(this).attr("id")>'<%=DiaSemana&HoraComp%>' )
                   {
                       var gradeId = $(this).data("grade");
                        <%if session("FilaEspera")<>"" then %>
                            $('[id=<%=DiaSemana&HoraComp%>]').remove();
                        <% end if %>

                        var conteudo ='<%= conteudo %>';
                        if (!$(this).hasClass("l<%=comps("LocalID")%>")){
                            conteudo = conteudo.replace("[LOCAL_DIF]",'<%=LocalDiferente%>');
                        }else{
                            conteudo = conteudo.replace("[LOCAL_DIF]",'');
                        }
                       $(this).before(conteudo.replace(new RegExp("GRADE_ID",'g'), gradeId));
                       return false;
                   }
            });
        }
	<%
	if HoraFinal<>"" then
		%>
        if(Status !== "11" && Status !== "22" && Status !== "33" <%=StatusRemarcado%>){
            $( ".vazio<%=DiaSemana%>" ).each(function(){
                if( $(this).attr("id")>'<%=DiaSemana&HoraComp%>' && $(this).attr("id")<'<%=DiaSemana&HoraFinal%>' )
                {
                    //alert('oi');
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

    'bloqueioSql = "select c.* from compromissos c where (c.ProfissionalID="&ProfissionalID&" or (c.ProfissionalID=0 AND (c.Profissionais = '' or c.Profissionais LIKE '%|"&ProfissionalID&"%|'))) AND (c.Unidades LIKE '%|"&UnidadeID&"|%' or c.Unidades='' or c.Unidades is null) and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" and DiasSemana like '%"&weekday(Data)&"%'"
    bloqueioSql = getBloqueioSql(ProfissionalID, Data, sqlUnidadesBloqueio)
    set bloq = db.execute(bloqueioSql)

    while not bloq.EOF
        HoraDe = HoraToID(bloq("HoraDe"))
        HoraA = HoraToID(bloq("HoraA"))
        Conteudo = "<tr id=""'+$(this).attr('data-hora')+'"" onClick=""abreBloqueio("&bloq("id")&", `"&replace(mydatenull(Data)&"","'","")&"`, \'\');"">"&_
        "<td width=""1%""></td><td width=""1%""><button type=""button"" class=""btn btn-xs btn-danger"">'+$(this).attr('data-hora')+'</button></td>"&_
        "<td nowrap><img src=""assets/img/bloqueio.png""> <span class=""nomePac"">"&replace(bloq("Titulo")&" ", "'", "\'")&"</span></td>"&_
        "</tr>"
        HBloqueados = HBloqueados+1
        %>
        $( ".vazio<%=DiaSemana%>" ).each(function(){
            if( $(this).attr("id")>='<%=DiaSemana&HoraDe%>' && $(this).attr("id")<'<%=DiaSemana&HoraA%>' )
            {
                $(this).replaceWith('<%= conteudo %>');
            }
        });
        $( ".btn-comp<%= DiaSemana %>" ).each(function(){
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
  </td>
  <%
  Data = dateadd("d", 1, Data)
  wend
%>
</tr>
</table>

</div>
<input type="hidden" name="DataBloqueio" id="DataBloqueio" value="<%=Data%>" />
<script type="text/javascript">
$(".agendar").click(function(){
	//alert(this.id);
	abreAgenda(this.id, '', $("#Data").val(), $(this).attr("contextmenu") );
});
</script>
<br />
<script>
$(document).ready(function(){
    $('[data-toggle="tooltip"]').tooltip();
});
</script>


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
	set ObsDia = db.execute("select * from agendaobservacoes where ProfissionalID="&ProfissionalID&" and Data="&mydatenull(DataSel)&"")
	if not ObsDia.eof then
		%>
		$("#AgendaObservacoes").val('<%=replace(replace(ObsDia("Observacoes"), chr(10), "\n"), "'", "\'")%>');
		<%
	else
		%>
		$("#AgendaObservacoes").val('');
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

    ExcecaoMesAnoSplt = split(PrimeiroDiaSemana,"/")
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

    call agendaOcupacoes(ProfissionalID, PrimeiroDiaSemana)

	%>
// Create the tooltips only when document ready
 $(document).ready(function()
 {
     // MAKE SURE YOUR SELECTOR MATCHES SOMETHING IN YOUR HTML!!!
     if(false){
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
     }
 });
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
$("#anterior").attr("href", "javascript:loadAgenda('<%=dateadd("d", -8, Data)%>', $('#ProfissionalID').val() )");
$("#proxima").attr("href", "javascript:loadAgenda('<%=dateadd("d", 1, Data)%>', $('#ProfissionalID').val() )");
</script>
<!--#include file = "disconnect.asp"-->
