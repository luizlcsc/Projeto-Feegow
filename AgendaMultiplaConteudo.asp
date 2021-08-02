﻿<!--#include file="connect.asp"-->


<script type="text/javascript">
    $("#LocalPre").val("");
    $("#ProfissionalPre").val("");
</script>

<%
Profissionais = "0"

session("HVazios") = ref("HVazios")

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

if session("FilaEspera")<>"" then
	set fila = db.execute("select f.id, p.NomePaciente from filaespera as f left join pacientes as p on p.id=f.PacienteID where f.id="&session("FilaEspera"))
	if not fila.eof then
		%>
        <div class="alert alert-warning col-md-12 text-center">
            Selecione um hor&aacute;rio abaixo para agendar <%=fila("NomePaciente")%>
            <button type="button" class="btn btn-sm btn-danger" onClick="filaEspera('cancelar','<%= ProfissionalID %>'); $('#buscar').click();">Cancelar</button>
        </div>
        <%
	end if
end if
if session("RemSol")<>"" then
	%>
	<div class="alert alert-warning row col-md-12 text-center">
            Selecione um hor&aacute;rio disponível
            <button type="button" class="btn btn-sm btn-danger" onClick="remarcar(<%=session("RemSol")%>, 'Cancelar', '')">Cancelar</button>
	</div>
	<%
end if
if session("RepSol")<>"" then
	%>
	<div class="alert alert-success row col-md-12 text-center">
    	Selecione um hor&aacute;rio disponível
            <button type="button" class="btn btn-sm btn-danger" onClick="repetir(<%=session("RepSol")%>, 'Cancelar', '')">Parar Repeti&ccedil;&atilde;o</button>
	</div>
	<%
end if

Data = ref("hData")

if Data = "" then
    Data = date()
end if

DiaSemana = weekday(Data)
Mes = month(Data)
Especialidades = ref("Especialidade")
ProcedimentoID = ref("filtroProcedimentoID")
%>

<script type="text/javascript">
    function crumbAgenda(){
        $(".crumb-active").html("<a href='./?P=AgendaMultipla&Pers=1'>Agenda</a>");
        $(".crumb-icon a span").attr("class", "fa fa-calendar");
        $(".crumb-link").replaceWith("");
        $(".crumb-trail").removeClass("hidden");
        $(".crumb-trail").html("<%=(formatdatetime(Data,1))%>");
        $("#rbtns").html("");
    }
    crumbAgenda();
</script>

<table width="100%" border="0">
    <tr>

<%

RemarcacaoID= session("RemSol")

if RemarcacaoID<>"" then
    set AgendamentoRemarcacaoSQL = db.execute("SELECT TipoCompromissoID, EspecialidadeID FROM agendamentos WHERE id="& RemarcacaoID)
    if not AgendamentoRemarcacaoSQL.eof then
        Especialidades= AgendamentoRemarcacaoSQL("EspecialidadeID")
        ProcedimentoID= AgendamentoRemarcacaoSQL("TipoCompromissoID")
    end if
end if


if ProcedimentoID<>"" then
    sqlProcFiltro = "select ifnull(OpcoesAgenda, 0) OpcoesAgenda, SomenteProfissionais, SomenteEquipamentos, SomenteEspecialidades, SomenteLocais, EquipamentoPadrao from procedimentos where id="&ProcedimentoID

    set proc = db.execute(sqlProcFiltro)
    if not proc.eof then
        OpcoesAgenda=proc("OpcoesAgenda")
        if OpcoesAgenda="4" or OpcoesAgenda="5" then
            SomenteProfissionais = proc("SomenteProfissionais")&""
            SomenteProfissionais = replace(SomenteProfissionais, ",", "")
            SomenteProfissionais = replace(SomenteProfissionais, " ", "")
            splSomProf = split(SomenteProfissionais, "|")
            SomenteProfissionais = ""
            for i=0 to ubound(splSomProf)
                if isnumeric(splSomProf(i)) and splSomProf(i)<>"" then
                    SomenteProfissionais = SomenteProfissionais & "," & splSomProf(i)
                end if
            next
            SomenteEspecialidades = proc("SomenteEspecialidades")&""
        end if
        EquipamentoPadrao = proc("EquipamentoPadrao")

        SomenteEquipamentos = proc("SomenteEquipamentos")

        if EquipamentoPadrao&""<>"" then
            EquipamentoPadrao="|"&EquipamentoPadrao&"|"

            if SomenteEquipamentos&""="" then
                SomenteEquipamentos=EquipamentoPadrao
            else
                SomenteEquipamentos=SomenteEquipamentos&","&EquipamentoPadrao
            end if
        end if

        SomenteLocais = proc("SomenteLocais")&""
        if instr(SomenteProfissionais, ",")>0 then
            'Profissionais = replace(SomenteProfissionais, "||", ",")
            'Profissionais = replace(Profissionais, ", , ", ", ")
            'Profissionais = replace(Profissionais, "|", "")
            Profissionais = SomenteProfissionais

            if left(Profissionais, 1)="," then
                Profissionais = right(Profissionais, len(Profissionais)-1)
            end if


            if Profissionais&""<>"" then
                sqlProfissionais = " t.ProfissionalID IN("& Profissionais &") "
            end if
        end if
        if instr(SomenteEspecialidades, "|")>0 then
            set GroupConcat = db.execute("SET SESSION group_concat_max_len = 1000000;")
            set profesp = db.execute("select group_concat(pro.id) Profissionais from profissionais pro LEFT JOIN profissionaisespecialidades pe on pe.ProfissionalID=pro.id where pro.EspecialidadeID IN("& replace(SomenteEspecialidades, "|", "") &") or pe.EspecialidadeID IN("& replace(SomenteEspecialidades, "|", "") &")")

            sqlEspecialidades = ""
            if not profesp.eof then
                ProfissionaisEspecialidade = profesp("Profissionais")
                if trim(ProfissionaisEspecialidade&"") <> "" then
                    sqlEspecialidades = " t.ProfissionalID IN ("&ProfissionaisEspecialidade&") "
                end if
            end if
        end if

        if sqlProfissionais<>"" and sqlEspecialidades<>"" then
            if OpcoesAgenda="4" then
                sqlProfesp = " AND ("&sqlProfissionais&" OR "&sqlEspecialidades&") "
            else
                sqlProfesp = " AND ("&sqlProfissionais&" AND "&sqlEspecialidades&") "
            end if
        elseif sqlProfissionais="" and sqlEspecialidades<>"" then
            sqlProfesp = " AND "&sqlEspecialidades&" "
        elseif sqlProfissionais<>"" and sqlEspecialidades="" then
            sqlProfesp = " AND "&sqlProfissionais&" "
        end if

        sqlProfissionais = ""

        if instr(SomenteLocais, "|")=0 then
            SomenteLocais = ""
        end if

        sqlProcedimentosGrade = " AND (Procedimentos LIKE '%|"&ProcedimentoID&"|%' OR Procedimentos is null or Procedimentos='') "
    end if


end if

if ProcedimentoID<>"" then
    set EspecialidadesPermitidasNoProcedimentoSQL = db.execute("SELECT SomenteEspecialidades FROM procedimentos WHERE id="&treatvalzero(ProcedimentoID))
    if not EspecialidadesPermitidasNoProcedimentoSQL.eof then
        ProcedimentoSomenteEspecialidades = EspecialidadesPermitidasNoProcedimentoSQL("SomenteEspecialidades")
    end if
    sqlProcedimentosGrade = " AND (procedimentos = '' OR Procedimentos IS NULL OR Procedimentos LIKE '%|"&ProcedimentoID&"|%') "
    sqlProcedimentosLocal = " AND (t.Procedimentos LIKE '%|"&ProcedimentoID&"|%' OR t.Procedimentos is null or t.Procedimentos='') "
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

    sqlGradeEspecialidade = " AND (Especialidades is null or Especialidades='' "

    for i=0 to ubound(spltEspecialidades)
        EspecialidadeID=spltEspecialidades(i)

        sqlGradeEspecialidade =  sqlGradeEspecialidade&" OR Especialidades LIKE '%"&EspecialidadeID&"%'"
    next
    sqlGradeEspecialidade=sqlGradeEspecialidade&")"

end if

refLocais = ref("Locais")


'response.write(session("Unidades"))

'if ref("Unidades")<>"" and ref("Unidades")<>"0" then
if instr(refLocais, "UNIDADE_ID")>0 then
    UnidadesIDs=""
    spltLocais = split(refLocais, ",")
    refLocais=""

    for i=0 to ubound(spltLocais)
        if instr(spltLocais(i),"UNIDADE_ID") > 0 then
            if i>0 then
                UnidadesIDs = UnidadesIDs&","
            end if
            UnidadesIDs= UnidadesIDs& replace(replace(spltLocais(i),"UNIDADE_ID",""),"|","")
        else
            if i>0 and refLocais <> "" then
                refLocais = refLocais&","
            end if
            refLocais = refLocais&spltLocais(i)
        end if
    next
    sqlUnidades = " AND t.LocalID IN (select concat(l.id) from locais l where l.UnidadeID IN ("& UnidadesIDs &")) "
end if

if aut("ageoutunidadesV")=0 and ref("Locais")="" then
    tipoUsuario = "profissionais"
    if lcase(session("table"))="funcionarios" then
        tipoUsuario = "funcionarios"
    end IF

    set uniProf = db.execute("SELECT Unidades FROM "&tipoUsuario&" WHERE id="&session("idInTable"))
    if not uniProf.eof then
        uniWhere = "null"
        if Len(uniProf("unidades"))>0 then
            uniWhere = replace(uniProf("unidades"),"|","")
         end if
    sqlUnidades = " AND t.LocalID IN (select concat(l.id) from locais l where l.UnidadeID IN ("& uniWhere &")) "
    end if
end if


if refLocais<>"" or SomenteLocais<>"" then
    %>
    <!--#include file="AgendaMultiplaLocais.asp"-->
    <%
end if

refEquipamentos = ref("Equipamentos")
if refEquipamentos<>"" or SomenteEquipamentos<>"" then
    %>
    <!--#include file="AgendaMultiplaEquipamentos.asp"-->
    <%
end if


if ref("Especialidade")<>"" then
    leftEsp = " LEFT JOIN profissionaisespecialidades e on e.ProfissionalID=p.id "
    sqlEspecialidadesSel = " AND (p.EspecialidadeID IN ("& replace(ref("Especialidade"), "|", "") &") OR e.EspecialidadeID IN ("& replace(ref("Especialidade"), "|", "") &") ) "
    fieldEsp = " , e.EspecialidadeID EspecialidadeAd "

    splEsp = split(ref("Especialidade"), ", ")
    for i=0 to ubound(splEsp)
        loopEsp = loopEsp & " OR Especialidades LIKE '%"& splEsp(i) &"%'"
    next 
    'sqlEspecialidadesGrade = " AND (ISNULL(Especialidades) OR Especialidades LIKE '' "& loopEsp &") "
end if


if ref("Profissionais")<>"" then
    sqlProfissionais = " AND p.id IN ("& replace(ref("Profissionais"), "|", "") &") "
else
've se deve seprar por paciente
     sqlProfissionais =""
    if lcase(session("table"))="funcionarios" then
         set FuncProf = db.execute("SELECT Profissionais FROM funcionarios WHERE id="&session("idInTable"))
         if not FuncProf.EOF then
            profissionais=FuncProf("Profissionais")
            if not isnull(profissionais) and profissionais<>"" then
                profissionaisExibicao = replace(profissionais, "|", "")
                if profissionaisExibicao<>"" then
                    sqlProfissionais = " AND p.id IN ("&profissionaisExibicao&")"
                end if
            end if
         end if
    elseif lcase(session("table"))="profissionais" then
         set FuncProf = db.execute("SELECT AgendaProfissionais FROM profissionais WHERE id="&session("idInTable"))
         if not FuncProf.EOF then
            profissionais=FuncProf("AgendaProfissionais")
            if not isnull(profissionais) and profissionais<>"" then
                profissionaisExibicao = replace(profissionais, "|", "")
                if profissionaisExibicao<>"" then
                    sqlProfissionais = " AND p.id IN ("&profissionaisExibicao&")"
                end if
            end if
         end if
    end if

    set sysConf = db.execute("select * from sys_config")
    
    if sysConf("ConfigGeolocalizacaoProfissional")="S" and recursoAdicional(39)=4 and sqlProfissionais&"" = "" and req("R") = "0" then
        sqlProfissionais = " AND p.id IN (0)"
    end if

end if

if ref("Convenio")<>"" then
    splConv = split(ref("Convenio"), ", ")
    for i=0 to ubound(splConv)
        loopConvenios = loopConvenios & " OR p.SomenteConvenios LIKE '%"& splConv(i) &"%'"
        loopConveniosGrade = loopConveniosGrade & " OR Convenios LIKE '%"& splConv(i) &"%'"
    next
    sqlConvenios = " AND (ISNULL(p.SomenteConvenios) OR p.SomenteConvenios LIKE '' "& loopConvenios &") "
    sqlConveniosGrade = " AND (ISNULL(Convenios) OR Convenios LIKE '' "& loopConveniosGrade &") "
end if

sql = ""

sqlOrder = " ORDER BY NomeProfissional"
if session("Banco") = "clinic935" then
    sqlOrder = " ORDER BY OrdemAgenda DESC"
end if
sql = "select t.ProfissionalID, p.EspecialidadeID, t.LocalID, IF (p.NomeSocial IS NULL OR p.NomeSocial='', p.NomeProfissional, p.NomeSocial) NomeProfissional, p.ObsAgenda, p.Cor, p.SomenteConvenios "& fieldEsp &" from (select Especialidades, ProfissionalID, LocalID from assfixalocalxprofissional WHERE HoraDe !='00:00:00' AND DiaSemana=[DiaSemana] AND ((InicioVigencia IS NULL OR InicioVigencia <= "&mydatenull(Data)&") AND (FimVigencia IS NULL OR FimVigencia >= "&mydatenull(Data)&") "&sqlProcedimentosGrade&sqlEspecialidadesGrade&sqlConveniosGrade&") UNION ALL select '', ProfissionalID, LocalID from assperiodolocalxprofissional WHERE DataDe<="& mydatenull(Data) &" and DataA>="& mydatenull(Data) &sqlEspecialidadesGrade&sqlConveniosGrade&") t LEFT JOIN profissionais p on p.id=t.ProfissionalID "& leftEsp &" WHERE p.Ativo='on' AND (p.NaoExibirAgenda!='S' or isnull(p.NaoExibirAgenda))  "& sqlEspecialidadesSel & sqlProfissionais & sqlConvenios & sqlProfesp & sqlGradeEspecialidade & sqlUnidades &" GROUP BY t.ProfissionalID"&sqlOrder

sqlVerme = "select t.FrequenciaSemanas, t.InicioVigencia, t.FimVigencia, t.ProfissionalID, p.EspecialidadeID, t.LocalID, p.NomeProfissional, p.ObsAgenda, p.Cor, p.SomenteConvenios "& fieldEsp &" from (select Especialidades, FrequenciaSemanas, InicioVigencia, FimVigencia, ProfissionalID, LocalID, Procedimentos from assfixalocalxprofissional WHERE DiaSemana=[DiaSemana] AND ((InicioVigencia IS NULL OR (DATE_FORMAT(InicioVigencia ,'%Y-%m-01') <= "&mydatenull(Data)&")) AND (FimVigencia IS NULL OR (DATE_FORMAT(FimVigencia ,'%Y-%m-30') >= "&mydatenull(Data)&" )))) t LEFT JOIN profissionais p on p.id=t.ProfissionalID "& leftEsp &" WHERE p.Ativo='on' AND (p.NaoExibirAgenda!='S' or isnull(p.NaoExibirAgenda)) "&sqlProcedimentosLocal&sqlEspecialidadesSel & sqlConvenios & sqlProfissionais & sqlGradeEspecialidade &sqlProfesp & sqlUnidades &" "

sqlVermePer = "select t.DataDe, t.DataA, t.ProfissionalID, p.EspecialidadeID, t.LocalID, p.SomenteConvenios, t.procedimentos "& fieldEsp &" from (select ProfissionalID, LocalID, DataDe, DataA, procedimentos from assperiodolocalxprofissional WHERE DataDe>="& mydatenull( DiaMes("P", Data ) )&" AND DataA<="& mydatenull( DiaMes("U", Data) ) &") t LEFT JOIN profissionais p on p.id=t.ProfissionalID "& leftEsp &" WHERE p.Ativo='on' AND (p.NaoExibirAgenda!='S' or isnull(p.NaoExibirAgenda)) "& sqlProcedimentosLocal & sqlEspecialidadesSel & sqlConvenios & sqlProfissionais & sqlProfesp & sqlUnidades

sql = replace(sql, "[DiaSemana]", DiaSemana)
if session("Banco")="clinic5760" then
    'response.Write("<script>//SQL GRADES-> "& sql &"</script>")
end if
'response.write sql
set comGrade = db.execute( sql )
if comGrade.eof then
    %>
    <div class="alert alert-warning text-center mt20"><i class="fa fa-alert"></i> Nenhum profissional encontrado com grade que atenda aos critérios selecionados.  </div>
    <%
end if

cProf = 0
while not comGrade.eof
    set pesp = db.execute("select esp.especialidade from especialidades esp where esp.id="& treatvalnull(comGrade("EspecialidadeID"))&" or esp.id in(select group_concat(pe.EspecialidadeID) from profissionaisespecialidades pe where ProfissionalID in ("&treatvalzero(comGrade("ProfissionalID"))&"))")
    NomeEspecialidade = ""
    while not pesp.eof
        NomeEspecialidade = NomeEspecialidade & left(pesp("especialidade")&"", 21) &"<br>"
    pesp.movenext
    wend
    pesp.close
    set pesp=nothing

    ObsAgenda = comGrade("ObsAgenda")
    if len(ObsAgenda)>0 then
        ObsAgenda = 1
    else
        ObsAgenda = 0
    end if
    
    CorTitulo = comGrade("Cor")
   ' locaisUnidade = ref("Locais")

    'response.write(locaisUnidade)


    %>


             <td valign="top" align="center" id="pf<%= comGrade("ProfissionalID") %>"><i class="fa fa-circle-o-notch fa-spin"></i></td>

            <script type="text/javascript">
                $.post("namAgenda.asp", {
                    Especialidades: '<%= Especialidades %>',
                    ProfissionalID: '<%= comGrade("ProfissionalID") %>',
                    Data: '<%= Data %>',
                    NomeProfissional: "<%= comGrade("NomeProfissional") %>",
                    Cor: '<%= CorTitulo %>',
                    NomeEspecialidade: '<%= NomeEspecialidade %>',
                    ProcedimentoID: "<%= ProcedimentoID %>",
                    Locais: "<%= ref("Locais") %>",
                    ObsAgenda: "<%= ObsAgenda %>",
                    strAB: '<%= strAB %>'
                }, function (data) {
                        $('#pf<%= comGrade("ProfissionalID") %>').html(data)

                        let conteudo = $($('#contQuadro  table  table  tr')[0]).text();
                        conteudo = conteudo.trim();
                        if(conteudo === ""){
                            $('#contQuadro').html(`<div class="alert alert-warning text-center mt20"><i class="fa fa-alert"></i> Nenhum profissional encontrado com grade que atenda aos critérios selecionados.  </div>`)
                        }
                });
            </script>


<%

comGrade.movenext
wend
comGrade.close
set comGrade=nothing
%>

            </tr>
</table>
<script type="text/javascript">
    <%
    set ObsDia = db.execute("select * from agendaobservacoes where ProfissionalID=0 and Data="&mydatenull(Data)&"")
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

    $(".dia-calendario").addClass("danger");
    <%
	cDiaSemana = 0
	while cDiaSemana<7
	    cDiaSemana = cDiaSemana+1
	    'repete o sql de cima

        set vcaGrade = db.execute( replace(sqlVerme, "[DiaSemana]", cDiaSemana) )
        response.write("//"&sqlVerme)
	    while not vcaGrade.eof
	            FrequenciaSemanas= vcaGrade("FrequenciaSemanas")
       	        InicioVigencia = vcaGrade("InicioVIgencia")&""
       	        FimVigencia = vcaGrade("FimVigencia")&""

       	        if FimVigencia<>"" or InicioVigencia<>"" then
       	            %>
                       $(".d<%=weekday(cDiaSemana)%>").filter(function() {
                           var data = new Date($(this).attr("id").split("/").reverse().join("-"));

                           var dataCalendario = data.getTime();

                           var inicioVigencia = new Date("<%=InicioVigencia%>".split("/").reverse().join("-"));
                           var fimVigencia = new Date("<%=FimVigencia%>".split("/").reverse().join("-"));

                           var inicioVigenciaTime = inicioVigencia.getTime();
                           var fimVigenciaTime = fimVigencia.getTime();
                           var frequenciaSemanas = parseInt("<%=FrequenciaSemanas%>");

                           var fimOk = true, inicioOk=true, frequenciaOk=true;


                           if(frequenciaSemanas>1){

                                var SemanasEntreDataEInicio = Math.round((data - inicioVigencia)/ 604800000);
                                var RestoDivisaoNumeroSemana = SemanasEntreDataEInicio % frequenciaSemanas;

                                if(RestoDivisaoNumeroSemana>0){
                                    frequenciaOk=false;
                                }
                           }

                           if("<%=FimVigencia%>"!==""){
                               fimOk = dataCalendario <= fimVigenciaTime;
                           }
                           if("<%=InicioVigencia%>"!==""){
                               inicioOk = dataCalendario >= inicioVigenciaTime;
                           }

                            return inicioOk && fimOk && frequenciaOk;
                          }).removeClass("danger");
                       <%
       	        else
                       %>
                       $(".d<%=weekday(cDiaSemana)%>").removeClass("danger");//P: <%=vcaGrade("ProfissionalID")%>
                       <%
       			end if
       		vcaGrade.movenext
       		wend
       		vcaGrade.close
       		set vcaGrade=nothing
	wend

    

    set liberar = db.execute( sqlVermePer )
	while not liberar.eof
	    lDe = liberar("DataDe")
        lA = liberar("DataA")

        while lDe<=lA
            classe = replace(lDe, "/", "-")
            %>
            $(".<%=classe%>").removeClass("danger");
            <%
            lDe=dateAdd("d", 1, lDe)
        wend
    liberar.movenext
    wend
    liberar.close
    set liberar = nothing

if cProf=1 and ref("filtroProcedimentoID")<>"" then
    %>
    $("#ProfissionalPre").val("<%=ProfissionalID %>");
    <%
end if

    %>

    //console.log("<%'=sql%>");
</script>
<script>
$(document).ready(function(){
    $('[data-toggle="tooltip"]').tooltip();
});
</script>
