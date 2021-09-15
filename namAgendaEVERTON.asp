<!--#include file="connect.asp"--><% 'NÃO DESCOLAR DAQUI SENÃO BUGA TUDO!!!
NomeEspecialidade = ref("NomeEspecialidade")
ProfissionalID = ref("ProfissionalID")
Data = ref("Data")
DiaSemana = weekday(Data)
NomeProfissional = ref("NomeProfissional")
Cor = ref("Cor")
ProcedimentoID = ref("ProcedimentoID")
HVazios = ref("HVazios")
strAB = ref("strAB")
Especialidades = ref("Especialidades")

if instr(ref("Locais"), "UNIDADE_ID")>0 then
    Unidades = replace(ref("Locais"), "UNIDADE_ID", "")
    UnidadesIN = replace(Unidades, "|", "'")
    sqlUnidadesHorarios = " AND l.UnidadeID IN("& UnidadesIN &") "
    joinLocaisUnidades = " LEFT JOIN locais l ON l.id=a.LocalID "
    whereLocaisUnidades = " AND l.UnidadeID IN("& UnidadesIN &") "
end if
'    response.write("{{"& sqlUnidadesHorarios &"}}")

if ProcedimentoID<>"" then
    set EspecialidadesPermitidasNoProcedimentoSQL = db.execute("SELECT SomenteEspecialidades FROM procedimentos WHERE id="&treatvalzero(ProcedimentoID))
    if not EspecialidadesPermitidasNoProcedimentoSQL.eof then
        ProcedimentoSomenteEspecialidades = EspecialidadesPermitidasNoProcedimentoSQL("SomenteEspecialidades")
    end if
    sqlProcedimentosGrade = " AND (Procedimentos LIKE '%|"&ProcedimentoID&"|%' OR Procedimentos is null or Procedimentos='') "
end if

if ProcedimentoSomenteEspecialidades<>"" then
    if Especialidades="" then
        Especialidades = ProcedimentoSomenteEspecialidades
    else
        Especialidades = Especialidades&", "&ProcedimentoSomenteEspecialidades
    end if
end if

if Especialidades<>""  then
    spltEspecialidades = split(Especialidades, ", ")

    sqlGradeEspecialidade = " AND (ass.Especialidades is null or ass.Especialidades='' "

    for i=0 to ubound(spltEspecialidades)
        EspecialidadeID=spltEspecialidades(i)

        sqlGradeEspecialidade =  sqlGradeEspecialidade&" OR ass.Especialidades LIKE '%"&EspecialidadeID&"%'"
    next
    sqlGradeEspecialidade=sqlGradeEspecialidade&")"
end if


Hora = cdate("00:00")
set Horarios = db.execute("select ass.*, l.NomeLocal, l.UnidadeID, '0' TipoGrade, '0' GradePadrao, '' Procedimentos, '' Mensagem from assperiodolocalxprofissional ass LEFT JOIN locais l on l.id=ass.LocalID where ass.ProfissionalID="&ProfissionalID&" and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" " & sqlProcedimentosGrade& sqlGradeEspecialidade &" order by HoraDe")
if Horarios.EOF then
set Horarios = db.execute("select ass.*, l.NomeLocal, l.UnidadeID, '1' GradePadrao, Mensagem from assfixalocalxprofissional ass LEFT JOIN locais l on l.id=ass.LocalID where ass.ProfissionalID="&ProfissionalID&" and ass.DiaSemana="&DiaSemana&" AND ((ass.InicioVigencia IS NULL OR ass.InicioVigencia <= "&mydatenull(Data)&") AND (ass.FimVigencia IS NULL OR ass.FimVigencia >= "&mydatenull(Data)&")) "&sqlUnidadesHorarios & sqlProcedimentosGrade& sqlGradeEspecialidade &" order by ass.HoraDe")
end if
if not Horarios.eof then
%>

<table class="table table-striped table-condensed table-hover" width="100%"><thead><tr><th colspan="3" style="min-width:200px" class="text-center pn">

    <div class="panel-heading p5 mn" style="line-height:14px!important; color:#777; font-size:11px; font-weight:bold">
        <span class="panel-title">
            <%=left(ucase(NomeProfissional),20)%> <br /><small><%= NomeEspecialidade %></small>
        </span>
            <div style="position:absolute; top:0; right:0; width:22px">
                <%
                if aut("horarios")=1 then
                    %>
                    <a class="btn btn-xs btn-block mtn" title="Grade" target="_blank" href="./?P=Profissionais&I=<%= ProfissionalID %>&Pers=1&Aba=Horarios">
                        <span class="far fa-cog"></span>
                    </a>
                    <%
                end if
                if ref("ObsAgenda")="1" then
                    %>
                    <a type="button" class="btn btn-xs btn-block mtn ObsAgenda" href="javascript:oa(<%= ProfissionalID %>)"><i class="far fa-info-circle"></i></a>
                    <%
                end if
                if aut("|agendaI|")=1 then
                    GradePadraoID=""
                    if Horarios("GradePadrao")="1" then
                        GradePadraoID=Horarios("id")
                    end if
                %>
                    <a class="btn btn-default btn-xs" id="AbrirEncaixe" href="javascript:abreAgenda('00:00', '', '<%= Data %>', '', '<%= ProfissionalID %>', '', '<%= GradePadraoID %>');">
                            <span class="far fa-external-link"></span>
                        </a>
		        <%
                end if
                %>
            </div>
    </div>
    </th></tr></thead><tbody><tr class="hidden l<%=LocalID%>" id="0000"></tr><%
    sqlUnidadesBloqueio= ""

    while not Horarios.EOF
        LocalID = Horarios("LocalID")
        UnidadeID = Horarios("UnidadeID")
        Procedimentos = Horarios("Procedimentos")&""


        if UnidadeID&"" <> "" then
            sqlUnidadesBloqueio = sqlUnidadesBloqueio&" OR c.Unidades LIKE '%|"&UnidadeID&"|%'"
        end if

        MostraGrade=True

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

        if Unidades<>"" then
            if instr(Unidades, "|"&UnidadeID&"|")=0 then
                MostraGrade=False
            end if
        end if

        if MostraGrade then
        cProf = cProf+1
        %><tr><td colspan="3" nowrap class="nomeProf" style="background-color:<%= Cor %>"><%=left(ucase(Horarios("NomeLocal")&" "), 20)%><%=getNomeLocalUnidade(Horarios("UnidadeID"))%> <br><%= Horarios("Mensagem") %> <input type="hidden" name="Ocupacoes" value="<%= ProfissionalID &"_"& LocalID %>" /><input type="hidden" id="OcupProfLivres<%= ProfissionalID &"_"& LocalID %>" name="OcupProfLivres<%= ProfissionalID &"_"& LocalID %>" /><input type="hidden" id="OcupProfBloq<%= ProfissionalID &"_"& LocalID %>" name="OcupProfBloq<%= ProfissionalID &"_"& LocalID %>" /><input type="hidden" id="OcupProfOcu<%= ProfissionalID &"_"& LocalID %>" name="OcupProfOcu<%= ProfissionalID &"_"& LocalID %>" /></td></tr><%


    if Horarios("TipoGrade")=0 then
        GradeID=Horarios("id")
        if Horarios("GradePadrao")="0" then
            GradeID=GradeID*-1
        end if
        Intervalo = Horarios("Intervalo")
        LocalID = Horarios("LocalID")
        if isnull(Intervalo) or Intervalo=0 then
            Intervalo = 30
        end if
        HoraDe = cdate(Horarios("HoraDe"))
		if isnull(Horarios("HoraA")) then
			HoraA = HoraDe
		else
		    horarioAFix = (formatdatetime(Horarios("HoraA"), 4))
            ultimoValorMinuto = Mid(horarioAFix,Len(horarioAFix)-0,1)

            HoraA = cdate(Horarios("HoraA"))
            if ultimoValorMinuto <> "9" then
                HoraA = cdate(dateAdd("n", 1, Horarios("HoraA")))
            end if
		end if
        ProfissionalID = Horarios("ProfissionalID")
        if isnull(ProfissionalID) then
            ProfissionalID = 0
        end if
		if instr(Profissionais, "|"&ProfissionalID&"|")=0 and ProfissionalID<>0 then
			Profissionais = Profissionais&"|"&ProfissionalID&"|"
		end if

        Bloqueia = ""
        if Procedimentos<>"" and session("RemSol")<>"" then
            set procRem = db.execute("select TipoCompromissoID from agendamentos where id="& session("RemSol"))
            if not procRem.eof then
                if instr(Procedimentos, "|"& procRem("TipoCompromissoID") &"|")=0 then
                    Bloqueia = "S"
                end if
            end if
        end if

        Hora = HoraDe
        while Hora<=HoraA
            HoraID = formatdatetime(Hora, 4)
            HoraID = replace(HoraID, ":", "")
            if session("FilaEspera")<>"" then
            %>
            <tr data-unidade="<%=UnidadeID%>" class="p vazio l<%= LocalID %>" data-hora="<%=formatdatetime(Hora, 4)%>" data-pro="<%=ProfissionalID%>" id="<%=HoraID%>">
                <td width="1%"></td>
                <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(Hora,4) %></button></td>
                <td colspan="4">
                    <button type="button" onclick="filaEspera('U_<%=session("FilaEspera")%>_<%=formatDateTime(Hora,4)%>')" class="btn btn-xs btn-primary">
                        <i class="far fa-chevron-left"></i> Agendar Aqui
                    </button>
                </td>
            </tr>
            <%
            elseif session("RemSol")<>"" then
                if Bloqueia="" then
                %>
                <tr data-unidade="<%=UnidadeID%>" class="p<%=ProfissionalID%> l<%= LocalID %> vazio" data-hora="<%=formatdatetime(Hora, 4)%>" data-pro="<%=ProfissionalID%>" data-id="<%=HoraID%>" id="<%=ProfissionalID&"_"&HoraID%>">
                    <td width="1%"></td>
                    <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(Hora,4) %></button></td>
                    <td colspan="4">
                        <button type="button" onclick="remarcar(<%=session("RemSol")%>, 'Remarcar', '<%=formatDateTime(Hora,4)%>', '<%=LocalID%>', '<%=ProfissionalID%>')" class="btn btn-xs btn-warning">
                            <i class="far fa-chevron-left"></i> Agendar Aqui
                        </button>
                    </td>
                </tr>
                <%
                end if
            elseif session("RepSol")<>"" then
            %>
            <tr data-unidade="<%=UnidadeID%>" class="p<%=ProfissionalID%> l<%= LocalID %> vazio" data-hora="<%=formatdatetime(Hora, 4)%>" data-pro="<%=ProfissionalID%>" data-id="<%=HoraID%>" id="<%=ProfissionalID&"_"&HoraID%>">
                <td width="1%"></td>
                <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(Hora,4) %></button></td>
                <td colspan="4">
                    <button type="button" onclick="repetir(<%=session("RepSol")%>, 'Repetir', '<%=formatDateTime(Hora,4)%>', '<%=LocalID%>', '<%=ProfissionalID%>')" class="btn btn-xs btn-warning">
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
            <tr data-unidade="<%=UnidadeID%>" class="alert l l<%= LocalID %> vazio" data-hora="<%=formatdatetime(Hora, 4)%>" data-horaid="<%= horaid %>" id="<%=HoraID%>">
                <td width="1%"></td>
                <td width="1%"><button type="button" class="btn btn-xs btn-alert"><%= formatdatetime(Hora,4) %></button></td>
                <td colspan="2">
                    <%= txtAB %>
                </td>
            </tr>
            <%
            else
            %><tr data-unidade="<%=UnidadeID%>" onclick="abreAgenda('<%=HoraID%>', 0, '<%=Data%>', <%=LocalID%>, <%=ProfissionalID %>, '','<%=GradeID%>' )" class="p<%=ProfissionalID%> l<%= LocalID %> vazio<%=ProfissionalID &"_"& LocalID %>" data-pro="<%=ProfissionalID%>" data-id="<%=HoraID%>" data-hora="<%= ft(Hora) %>" id="<%=ProfissionalID&"_"&HoraID%>"><td width="1%" style="background-color:<%= Cor %>"></td><td width="1%"><button type="button" class="btn btn-xs btn-info"><%= ft(Hora) %></button></td><td><%= Tipo %></td></tr><%
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
                %><tr data-unidade="<%=UnidadeID%>" onclick="abreAgenda('<%=HoraID%>', 0, '<%=Data%>', <%=LocalID%>, <%=ProfissionalID %>,'','<%=Horarios("id")%>' )" class="p<%=ProfissionalID%> l<%= LocalID %>" data-pro="<%=ProfissionalID%>" data-id="<%=HoraID%>" data-hora="<%= ft(HoraPers) %>" id="<%=ProfissionalID&"_"&HoraID%>"><td width="1%" style="background-color:<%= Cor %>"></td><td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(HoraPers,4) %></button></td><td colspan="4"><%= Tipo %></td></tr><%
            end if
        next
    end if
end if
end if
%><tr class="hidden l p<%=ProfissionalID%> l<%= LocalID %>" data-id="2359"></tr><%

        strJSgrades = strJSgrades & "$('#OcupProfLivres"& ProfissionalID &"_"& LocalID &"').val( $('.vazio"& ProfissionalID &"_"& LocalID &"').size() );"
        strJSgrades = strJSgrades & "$('#OcupProfBloq"& ProfissionalID &"_"& LocalID &"').val( $('.bloq"& ProfissionalID &"_"& LocalID &"').size() );"
        strJSgrades = strJSgrades & "$('#OcupProfOcu"& ProfissionalID &"_"& LocalID &"').val( $('.ocu"& ProfissionalID &"_"& LocalID &"').size() );"

    Horarios.movenext
    wend
    Horarios.close
    set Horarios=nothing
    %></tbody></table><%'=Profissionais %>
<script type="text/javascript">
<%
set comps=db.execute("select loc.UnidadeID, a.id, a.Data, a.Hora, a.LocalID, a.ProfissionalID, a.StaID, a.FormaPagto, a.Encaixe, a.Tempo, a.Procedimentos, p.NomePaciente, p.Nascimento, pro.NomeProfissional, pro.Cor, proc.NomeProcedimento, proc.Cor CorProcedimento from agendamentos a "&_
"left join pacientes p on p.id=a.PacienteID " & joinLocaisUnidades &_ 
"left join profissionais pro on pro.id=a.ProfissionalID "&_ 
"left join locais loc on loc.id=a.LocalID "&_
"left join procedimentos proc on proc.id=a.TipoCompromissoID "&_
"where a.ProfissionalID="&ProfissionalID&" and a.Data="&mydatenull(Data) & whereLocaisUnidades &"order by Hora")
while not comps.EOF
    HoraComp = HoraToID(comps("Hora"))
    compsHora = comps("Hora")
    LocalID = comps("LocalID")
    FormaPagto = comps("FormaPagto")
    AgendamentoUnidadeID = comps("UnidadeID")

	if not isnull(compsHora) then
		compsHora = formatdatetime(compsHora, 4)
	end if


	NomeProcedimento = comps("NomeProcedimento")
	VariosProcedimentos = comps("Procedimentos")&""
	if VariosProcedimentos<>"" then
		NomeProcedimento = VariosProcedimentos
	end if
    Tempo = 0
    ValorProcedimentosAnexos = 0

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


	'->hora final
	if not isnull(comps("Tempo")) and comps("Tempo")<>"" and isnumeric(comps("Tempo")) then
		Tempo = Tempo + ccur(comps("Tempo"))
	else
		Tempo = 0
	end if
	Horario = comps("Hora")
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
    CorProcedimento = comps("CorProcedimento")
	'<-hora final

    if session("HVazios")="" then
		Conteudo = "<tr data-unidade="""&AgendamentoUnidadeID&""" data-toggle=""tooltip"" data-id="""&HoraComp&""" class=""ocu"& ProfissionalID&" ocu"& ProfissionalID &"_"& LocalID &""" data-html=""true"" data-placement=""bottom"" title="""&replace(NomeProcedimento&" ", "'", "\'")&" <br> "&replace(comps("NomeProfissional")&" ", "'", "\'")&" <br> Idade: "&IdadeAbreviada(comps("Nascimento"))&""" id="""&HoraComp&""" onclick=""abreAgenda(\'"&HoraComp&"\', "&comps("id")&", \'"&comps("Data")&"\', \'"&comps("LocalID")&"\', \'"&comps("ProfissionalID")&"\')""><td width=""1%"" style=""background-color:"&comps("Cor")&"""></td><td width=""1%"" style=""background-color:"&CorProcedimento&"!important""><button type=""button"" class=""btn btn-xs btn-warning slot-cor"">"&compsHora&"</button></td><td nowrap><img src=""assets/img/"&comps("StaID")&".png""> "
	    if comps("Encaixe")=1 then
		    Conteudo = Conteudo & "<span class=""label label-alert label-sm arrowed-in arrowed-in-right"">Enc</span>"
	    end if
    	Conteudo = Conteudo & "<span class=""nomePac"">"& replace(comps("NomePaciente") & " ", "'", "\'") & "</span>  <span class=""pull-right"">"& sinalAgenda(FormaPagto) & "</span> </td></tr>"
    else
        Conteudo = ""
    end if
%>
var Status = '<%=comps("StaID")%>';
var $agendamentoSlot = $( ".p<%=ProfissionalID%>.l<%=LocalID%>" );

if($agendamentoSlot.length===0){
    $agendamentoSlot= $( ".p<%=ProfissionalID%>" );
}

$agendamentoSlot.each(function(){
    var horaSlot = $(this).attr("data-id");
    if( horaSlot=='<%=HoraComp%>' && (Status !== '11' && Status !== '22'))
    {
        $(this).replaceWith('<%= conteudo %>');
        return false;
    }
    else if ( horaSlot>'<%=HoraComp%>' )
    {
        if($agendamentoSlot.filter("[data-id='<%=HoraComp%>']").length > 0 && (Status !== '11' && Status !== '22')){
            $agendamentoSlot.filter("[data-id='<%=HoraComp%>']").replaceWith('<%= conteudo %>');
        }else{
            $agendamentoSlot.filter("[data-id='<%=HoraComp%>']").before('<%=conteudo%>');
        }
        return false;
    }
});
<%
if HoraFinal<>"" then
%>
if(Status!== '11' && Status !== '22'){
$( ".p<%=ProfissionalID%>" ).each(function(){
    if( $(this).attr("data-id")>'<%=HoraComp%>' && $(this).attr("data-id")<'<%=HoraFinal%>' ){
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


bloqueioSql = "select c.* from compromissos c where (c.ProfissionalID="&ProfissionalID&" or (c.ProfissionalID=0 AND (c.Profissionais = '' or c.Profissionais LIKE '%|"&ProfissionalID&"%|'))) AND ((false "&sqlUnidadesBloqueio&") or c.Unidades='' OR c.Unidades IS NULL) and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" and DiasSemana like '%"&weekday(Data)&"%'"

set bloq = db.execute(bloqueioSql)

while not bloq.EOF

BloqueioPorUnidade=False
UnidadesBloqueio=bloq("Unidades")

if bloq("BloqueioMulti")="S" and UnidadesBloqueio&""<>"" then
    BloqueioPorUnidade=True
end if

HoraDe = HoraToID(bloq("HoraDe"))
HoraA = HoraToID(bloq("HoraA"))
if session("HVazios")="" then
    Conteudo = "<tr id=""'+$(this).attr('id')+'"" class=""bloq"& ProfissionalID &"_"& LocalID &""" onClick=""abreBloqueio("&bloq("id")&", \'\', \'\');"">"&_
    "<td width=""1%""></td><td width=""1%""><button type=""button"" class=""btn btn-xs btn-danger"">'+$(this).attr('data-hora')+'</button></td>"&_ 
    "<td nowrap><img src=""assets/img/bloqueio.png""> <span class=""nomePac"">"&replace(bloq("Titulo")&" ", "'", "\'")&"</span></td>"&_ 
    "<td class=""hidden-xs text-center""></td>"&_ 
    "<td class=""hidden-xs hidden-sm text-center""></td>"&_ 
    "<td class=""hidden-xs text-right nomeConv""></td>"&_ 
    "</tr>"
else
    Conteudo = ""
end if
HBloqueados = HBloqueados + 1

%>
var unidadesBloqueadas = "<%=replace(UnidadesBloqueio&"", "|", "")%>".split(", ");

$( ".p<%=ProfissionalID%>" ).each(function(){

    var condicao = true;

    <%
    if BloqueioPorUnidade=True then
        %>
        condicao=unidadesBloqueadas.indexOf($(this).data("unidade")+"") !== -1;
        <%
    end if
    %>

    if(condicao){

        if( $(this).attr("data-id")>='<%=HoraDe%>' && $(this).attr("data-id")<'<%=HoraA%>' )
        {
            $(this).replaceWith('<%= conteudo %>');
        }
    }
});

$( ".ocu<%=ProfissionalID%>" ).each(function(){

    var condicao = true;

    <%
    if BloqueioPorUnidade=True then
        %>
        condicao=unidadesBloqueadas.indexOf($(this).data("unidade")+"") !== -1;
        <%
    end if
    %>
    if(condicao){
        if( $(this).attr("data-id")>='<%=HoraDe%>' && $(this).attr("data-id")<'<%=HoraA%>' )
        {
            var $slot = $(this).find(".slot-cor");
            $slot.removeClass("btn-warning").addClass("btn-danger").append("&nbsp; <i class='far fa-lock'></i>");
        }
    }
});
$( ".p<%=ProfissionalID%> .btn-comp" ).each(function(){
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

if session("HVazios")="S" then
    %>

    if($(".p<%= ProfissionalID %>").size()==1) {
        $("#pf<%= ProfissionalID %>").html("");
    }
<% end if %>
</script>
<% end if 
'NÃO ESCREVER NADA ABAIXO DAQUI!!!! NEM ENTER    !!!!
%>
<script>
$(document).ready(function(){
    $('[data-toggle="tooltip"]').tooltip();
});

<%= strJSgrades %>

//console.log( $(".fa-circle-o-notch").size() );

if( $(".fa-circle-o-notch").size()==1 ){
    $.post("Ocupacoes.asp?Tipo=Multipla&Data=<%= Data %>", $("[name^=Ocup]").serialize(), function(data){ eval(data) } );
}
</script>