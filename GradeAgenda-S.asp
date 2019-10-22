<%InicioProcessamento = Timer%>
<!--#include file="connect.asp"-->
<%
'on error resume next

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


ProfissionalID=req("ProfissionalID")
DiaSemana=weekday(Data)
mesCorrente=month(Data)

if lcase(session("Table"))="funcionarios" then
	session("UltimaAgenda") = ProfissionalID
end if


set prof = db.execute("select Cor, NomeProfissional, Foto, ObsAgenda from profissionais where id="&ProfissionalID)
if not prof.eof then
	Cor = prof("Cor")
	NomeProfissional = prof("NomeProfissional")
	if isnull(prof("Foto")) or prof("Foto")="" then
		FotoProfissional = "/assets/img/user.png"
	else
		FotoProfissional = arqEx(prof("Foto"), "Perfil")
	end if
	ObsAgenda = prof("ObsAgenda")
    ObsAgenda = trim(ObsAgenda&" ")
    ObsAgenda = replace(replace(replace(replace(ObsAgenda, chr(10), " "), chr(13), " "), "'", ""), """", "")
else
	Cor = "#333"
	FotoProfissional = "/assets/img/user.png"
end if
%>
<script type="text/javascript">
    function crumbAgenda(){
        $(".crumb-active").html("<a href='./?P=Agenda-S&Pers=1'>Agenda</a>");
        $(".crumb-icon a span").attr("class", "fa fa-calendar");
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
    <a href="javascript:loadAgenda('<%=dateadd("d", -7, Data)%>', $('#ProfissionalID').val() );" id="anterior" class="btn btn-default btn-sm"><i class="fa fa-chevron-left"></i></a>
    <a href="javascript:loadAgenda('<%=dateadd("d", 7, Data)%>', $('#ProfissionalID').val() );" id="proxima" class="btn btn-default btn-sm"><i class="fa fa-chevron-right"></i></a>
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
	%>
	<div class="alert alert-warning col-md-12 text-center" style="padding: 5px">
            Selecione um hor&aacute;rio disponível
            <button type="button" class="btn btn-sm btn-danger" onClick="remarcar(<%=session("RemSol")%>, 'Cancelar', '')">Cancelar</button>
    </div>
	<%
end if
if session("RepSol")<>"" then
	%>
	<div class="alert alert-success col-md-12 text-center" style="padding: 5px">
        Selecione um hor&aacute;rio disponível
        <button type="button" class="btn btn-sm btn-danger" onClick="repetir(<%=session("RepSol")%>, 'Cancelar', '')">Parar Repeti&ccedil;&atilde;o</button>
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
  %>
  <td width="14%" class="pn" style="vertical-align:top">
    <table class="table table-striped table-hover table-bordered table-condensed table-agenda mn">
    <thead>
        <tr>
            <th colspan="6" class="text-center<% If cdate(Data)=DataSel Then %> success<% End If %>" nowrap><%=ucase(escreveData)%></th>
        </tr>
    </thead>
         <tbody>
            <tr class="hidden l<%=LocalID%>" id="<%=DiaSemana%>0000"></tr>
         <%
            Hora = cdate("00:00")
            set Horarios = db.execute("select ass.*, '' Cor, l.NomeLocal, '0' TipoGrade,  l.UnidadeID, '0' GradePadrao from assperiodolocalxprofissional ass LEFT JOIN locais l on l.id=ass.LocalID where ass.ProfissionalID="&ProfissionalID&" and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" order by HoraDe")
            if Horarios.EOF then
                set Horarios = db.execute("select ass.*, l.NomeLocal, l.UnidadeID, '1' GradePadrao, '' Cor from assfixalocalxprofissional ass LEFT JOIN locais l on l.id=ass.LocalID where ass.ProfissionalID="&ProfissionalID&" and ass.DiaSemana="&DiaSemana&" AND ((ass.InicioVigencia IS NULL OR ass.InicioVigencia <= "&mydatenull(Data)&") AND (ass.FimVigencia IS NULL OR ass.FimVigencia >= "&mydatenull(Data)&")) order by ass.HoraDe")
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
                            GradeID="0"
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
                                    <i class="fa fa-chevron-left"></i> Agendar Aqui
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
                                    <i class="fa fa-chevron-left"></i> Agendar Aqui 
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
                                    <i class="fa fa-chevron-left"></i> Repetir Aqui
                                </button>
                            </td>
                        </tr>
                        <%
                        else
                            HLivres = HLivres+1
                        %>
                        <tr onclick="abreAgenda('<%=HoraID%>', 0, '<%=Data%>', <%=LocalID%>, <%=ProfissionalID%>,<%=GradeID%>)" class="l l<%= LocalID %> vazio<%= DiaSemana %>" data-hora="<%=formatdatetime(Hora, 4)%>" id="<%=DiaSemana&HoraID%>">
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
                                <tr class="l vazio" data-hora="<%=formatdatetime(HoraPers, 4)%>" data-horaid="<%= HoraID %>" id="<%=HoraID%>">
                                    <td width="1%"></td>
                                    <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(HoraPers,4) %></button></td>
                                    <td colspan="4">
                                        <button type="button" onclick="filaEspera('U_<%=session("FilaEspera")%>_<%=formatDateTime(HoraPers,4)%>')" class="btn btn-xs btn-primary">
                                            <i class="fa fa-chevron-left"></i> Agendar Aqui
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
                                        <button type="button" onclick="remarcar(<%=session("RemSol")%>, 'Remarcar', '<%=formatDateTime(HoraPers,4)%>', '<%=LocalID%>', '<%= Data %>')" class="btn btn-xs btn-warning">
                                            <i class="fa fa-chevron-left"></i> Remarcar Aqui
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
                                        <button type="button" onclick="repetir(<%=session("RepSol")%>, 'Repetir', '<%=formatDateTime(HoraPers,4)%>', '<%=LocalID%>', '<%= Data %>')" class="btn btn-xs btn-warning">
                                            <i class="fa fa-chevron-left"></i> Repetir Aqui
                                        </button>
                                    </td>
                                </tr>
                                <%
                                else

                                %>
                                <tr onclick="abreAgenda('<%= HoraID %>', 0, '<%=Data%>', <%=LocalID%>, <%=ProfissionalID%>)" class="l l<%= LocalID %> vazio<%= DiaSemana %> vazio" data-HoraID="<%= HoraID %>" data-hora="<%=formatdatetime(HoraPers, 4)%>" id="<%=DiaSemana&HoraID%>">
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

    set comps=db.execute("select a.id, a.Data, a.Hora, a.LocalID, a.ProfissionalID, a.PacienteID,a.StaID, a.FormaPagto, a.Encaixe, a.Tempo, a.Procedimentos, a.Primeira, p.NomePaciente, p.IdImportado, p.Tel1, p.Cel1, proc.NomeProcedimento, s.StaConsulta, a.rdValorPlano, a.ValorPlano, a.Notas, c.NomeConvenio, l.UnidadeID, l.NomeLocal, (select Resposta from agendamentosrespostas where AgendamentoID=a.id limit 1) Resposta from agendamentos a "&_
    "left join pacientes p on p.id=a.PacienteID "&_
    "left join procedimentos proc on proc.id=a.TipoCompromissoID "&_
    "left join staconsulta s on s.id=a.StaID "&_
    "left join convenios c on c.id=a.ValorPlano "&_
    "left join locais l on l.id=a.LocalID "&_
    "where a.Data="&mydatenull(Data)&" and a.ProfissionalID="&ProfissionalID&" order by Hora")

    while not comps.EOF
        Tempo=0
        ValorProcedimentosAnexos=0
        podeVerAgendamento=True
        UnidadeID=comps("UnidadeID")


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

		titleSemanal= replace(comps("NomePaciente")&"<br>"&NomeProcedimento&"<br>Prontuário: "&Prontuario&"<br>Tel.: "&comps("Tel1")&"<br>Cel.: "&comps("Cel1")&" "&"<br> ", "'", "\'") & "Notas: "&replace(replace(replace(replace(comps("Notas")&"", chr(13), ""), chr(10), ""), "'", ""), """", "")&"<br>"
               
        Conteudo = "<tr id="""&DiaSemana&HoraComp&""" data-toggle=""tooltip"" data-html=""true"" data-placement=""bottom"" title="""&titleSemanal&""" onclick=""abreAgenda(\'"&HoraComp&"\', "&comps("id")&", \'"&comps("Data")&"\', \'"&comps("LocalID")&"\', \'"&comps("ProfissionalID")&"\')"">"&_
        "<td width=""1%"">"
                if not isnull(comps("Resposta")) then
            Conteudo = Conteudo & "<i class=""fa fa-envelope pink""></i> "
        end if
        if comps("Primeira")=1 then
            Conteudo = Conteudo & "<i class=""fa fa-flag blue"" title=""Primeira vez""></i>"
        end if
        if comps("LocalID")<>LocalID then
            Conteudo = Conteudo & "<i class=""fa fa-exclamation-triangle grey"" title=""Agendado para &raquo; "&replace(comps("NomeLocal")&" ", "'", "\'")&"""></i>"
        end if
        Conteudo = Conteudo & "</td><td width=""1%""><button type=""button"" data-hora="""&replace( compsHora, ":", "" )&""" class=""btn btn-xs btn-default btn-comp"& DiaSemana &""">"&compsHora&"</button></td>"&_
        "<td nowrap><img src=""assets/img/"&comps("StaID")&".png""> "
        if comps("Encaixe")=1 then
            Conteudo = Conteudo & "<span class=""label label-alert"">enc</span>"
        end if
        Conteudo = Conteudo & "<span class=""nomePac"">"&replace(comps("NomePaciente")&" ", "'", "\'")&"</span>  <span class=""pull-right"">"& sinalAgenda(FormaPagto) &"</span>"
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

        LiberarHorarioRemarcado = getConfig("LiberarHorarioRemarcado")
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
            if( $(this).attr("id")=='<%=DiaSemana&HoraComp%>' && (Status !== "11" && Status !== "22" && Status !== "33" <%=StatusRemarcado%>))
            {
                HorarioAdicionado=true;
                $(this).replaceWith('<%= conteudo %>');
                return false;
            }
        });
        if(!HorarioAdicionado){
            $( classe + ", .l").each(function(){
                   if ( $(this).attr("id")>'<%=DiaSemana&HoraComp%>' )
                   {
                       $(this).before('<%=conteudo%>');
                       return false;
                   }
            });
        }
	<%
	if HoraFinal<>"" then
		%>
        if(Status !== "11" && Status !== "22" && Status !== "33"){
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

    bloqueioSql = "select c.* from compromissos c where (c.ProfissionalID="&ProfissionalID&" or (c.ProfissionalID=0 AND (c.Profissionais = '' or c.Profissionais LIKE '%|"&ProfissionalID&"%|'))) AND (c.Unidades LIKE '%|"&UnidadeID&"|%' or c.Unidades='' or c.Unidades is null) and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" and DiasSemana like '%"&weekday(Data)&"%'"

    set bloq = db.execute(bloqueioSql)
    while not bloq.EOF
        HoraDe = HoraToID(bloq("HoraDe"))
        HoraA = HoraToID(bloq("HoraA"))
        Conteudo = "<tr id=""'+$(this).attr('data-hora')+'"" onClick=""abreBloqueio("&bloq("id")&", \'\', \'\');"">"&_
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
                $(this).html( $(this).html() + ' <i class="fa fa-lock"></i>' );
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
	$(".<%=replace(request.QueryString("Data"),"/", "-")%>").addClass("success green");
	$(".Locais").html('');
	<%


	dat = 0
	while dat<7
		dat = dat+1
		if instr(diasAtende, dat)=0 then
			%>
			$(".d<%=weekday(dat)%>").addClass("danger");
			<%
		end if
	wend

	if false then
	set ocup = db.execute("select * from agendaocupacoes where ProfissionalID="&ProfissionalID&" and month(Data)="&month(Data)&" and year(Data)="&year(Data)&" order by Data")
	while not ocup.eof
		oHLivres = ocup("HLivres")
		oHAgendados = ocup("HAgendados")
		oHBloqueados = ocup("HBloqueados")
		oTotais = oHLivres+oHAgendados+oHBloqueados
		if oTotais=0 then
			percOcup=100
			percLivre = 0
		else
			oFator = 100 / oTotais
			percOcup = cInt( oFator* (oHAgendados+oHBloqueados) )
			percLivre = cInt( oFator* oHLivres )
		end if
		%>
		$("#prog<%=replace(ocup("Data"), "/", "")%>").html('<% If percOcup>0 Then %><div class="progress-bar progress-bar-danger" style="width: <%=percOcup%>%;"></div><% End If %><%if percLivre>0 then%><div class="progress-bar progress-bar-success" style="width: <%=percLivre%>%;"></div><% End If %>');
		<%
	ocup.movenext
	wend
	ocup.close
	set ocup = nothing
	end if
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
