<!--#include file="connect.asp"-->


<script type="text/javascript">
    $("#LocalPre").val("");
    $("#ProfissionalPre").val("");
</script>

<%
Profissionais = "0"

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
%>

<script type="text/javascript">
    function crumbAgenda(){
        $(".crumb-active").html("<a href='./?P=AgendaMultipla&Pers=1'>Agenda</a>");
        $(".crumb-icon a span").attr("class", "far fa-calendar");
        $(".crumb-link").replaceWith("");
        $(".crumb-trail").removeClass("hidden");
        $(".crumb-trail").html("<%=(formatdatetime(ref("hData"),1))%>");
        $("#rbtns").html("");
    }
    crumbAgenda();
</script>

<table width="100%" border="0">
    <tr>

<%
Data = ref("hData")
DiaSemana = weekday(Data)
Mes = month(Data)
ProcedimentoID = ref("filtroProcedimentoID")


if ProcedimentoID<>"" then
    set proc = db.execute("select ifnull(OpcoesAgenda, 0) OpcoesAgenda, SomenteProfissionais, SomenteEspecialidades, SomenteLocais, EquipamentoPadrao from procedimentos where id="&ProcedimentoID)
    if not proc.eof then
        if proc("OpcoesAgenda")="4" then
            SomenteProfissionais = proc("SomenteProfissionais")&""
            SomenteEspecialidades = proc("SomenteEspecialidades")&""
        end if
        SomenteEquipamentos = proc("EquipamentoPadrao")
        SomenteLocais = proc("SomenteLocais")&""
        if instr(SomenteProfissionais, "|")>0 then
            Profissionais = replace(SomenteProfissionais, "||", ",")
            Profissionais = replace(Profissionais, ", , ", ", ")
            Profissionais = replace(Profissionais, "|", "")

            if left(Profissionais, 1)="," then
                Profissionais = right(Profissionais, len(Profissionais)-1)
            end if

            if Profissionais&""<>"" then
                sqlProfissionais = " t.ProfissionalID IN("& Profissionais &") "
            end if
        end if
        if instr(SomenteEspecialidades, "|")>0 then
            set profesp = db.execute("select group_concat(pro.id) Profissionais from profissionais pro LEFT JOIN profissionaisespecialidades pe on pe.ProfissionalID=pro.id where pro.EspecialidadeID IN("& replace(SomenteEspecialidades, "|", "") &")")
            if not profesp.eof then
                if profesp("Profissionais")&"" <> "" then
                    sqlEspecialidades = " t.ProfissionalID IN ("&profesp("Profissionais")&") "
                end if
            end if
        end if
        
        if sqlProfissionais<>"" and sqlEspecialidades<>"" then
            sqlProfesp = " AND ("&sqlProfissionais&" OR "&sqlEspecialidades&") "
        elseif sqlProfissionais="" and sqlEspecialidades<>"" then
            sqlProfesp = " AND "&sqlEspecialidades&" "
        elseif sqlProfissionais<>"" and sqlEspecialidades="" then
            sqlProfesp = " AND "&sqlProfissionais&" "
        end if
        sqlProfissionais = ""
        
        if instr(SomenteLocais, "|")=0 then
            SomenteLocais = ""
        end if
    end if
end if



refLocais = ref("Locais")

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
            if i>0 then
                refLocais = refLocais&","
            end if
            refLocais = refLocais&spltLocais(i)
        end if
    next
    sqlUnidades = " AND t.LocalID IN (select concat(l.id) from locais l where l.UnidadeID IN ("& UnidadesIDs &")) "
    'sqlUnidadesHorarios = " AND ass.LocalID IN (select concat(ll.id) from locais ll where ll.UnidadeID IN ("& UnidadesIDs &")) "

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
end if


if ref("Profissionais")<>"" then
    sqlProfissionais = " AND p.id IN ("& replace(ref("Profissionais"), "|", "") &") "
else
've se deve seprar por paciente
    if lcase(session("table"))="funcionarios" then
         set FuncProf = db.execute("SELECT Profissionais FROM funcionarios WHERE id="&session("idInTable"))
         if not FuncProf.EOF then
         profissionais=FuncProf("Profissionais")
            if isnull(profissionais) or profissionais="" then
                sqlProfissionais=""
            else
                profissionaisExibicao = replace(profissionais, "|", "")
                if profissionaisExibicao<>"" then
                    sqlProfissionais = " AND p.id IN ("&profissionaisExibicao&")"
                end if
            end if
         else
            sqlProfissionais =""
         end if
    end if
end if

if ref("Convenio")<>"" then
    splConv = split(ref("Convenio"), ", ")
    for i=0 to ubound(splConv)
        loopConvenios = loopConvenios & " OR p.SomenteConvenios LIKE '%|"& splConv(i) &"|%'"'
    next
    sqlConvenios = " AND (ISNULL(p.SomenteConvenios) OR p.SomenteConvenios LIKE '' "& loopConvenios &") "
end if

sql = ""

sqlOrder = " ORDER BY NomeProfissional"
if session("Banco") = "clinic935" then
    sqlOrder = " ORDER BY OrdemAgenda DESC"
end if
sql = "select t.ProfissionalID, p.EspecialidadeID, t.LocalID, IF (p.NomeSocial IS NULL OR p.NomeSocial='', p.NomeProfissional, p.NomeSocial) NomeProfissional, p.Cor, p.SomenteConvenios "& fieldEsp &" from (select ProfissionalID, LocalID from assfixalocalxprofissional WHERE HoraDe !='00:00:00' AND DiaSemana=[DiaSemana] AND ((InicioVigencia IS NULL OR InicioVigencia <= "&mydatenull(Data)&") AND (FimVigencia IS NULL OR FimVigencia >= "&mydatenull(Data)&")) UNION ALL select ProfissionalID, LocalID from assperiodolocalxprofissional WHERE DataDe<="& mydatenull(Data) &" and DataA>="& mydatenull(Data) &") t LEFT JOIN profissionais p on p.id=t.ProfissionalID "& leftEsp &" WHERE p.Ativo='on'  "& sqlEspecialidadesSel & sqlProfissionais & sqlConvenios & sqlProfesp & sqlUnidades &" GROUP BY t.ProfissionalID"&sqlOrder

sqlVerme = "select t.ProfissionalID, p.EspecialidadeID, t.LocalID, p.NomeProfissional, p.Cor, p.SomenteConvenios "& fieldEsp &" from (select ProfissionalID, LocalID from assfixalocalxprofissional WHERE DiaSemana=[DiaSemana] AND ((InicioVigencia IS NULL OR InicioVigencia <= "&mydatenull(Data)&") AND (FimVigencia IS NULL OR FimVigencia >= "&mydatenull(Data)&"))) t LEFT JOIN profissionais p on p.id=t.ProfissionalID "& leftEsp &" WHERE p.Ativo='on' "& sqlEspecialidadesSel & sqlConvenios & sqlProfissionais & sqlProfesp & sqlUnidades &" GROUP BY t.ProfissionalID"

sqlVermePer = "select t.DataDe, t.DataA, t.ProfissionalID, p.EspecialidadeID, t.LocalID, p.SomenteConvenios "& fieldEsp &" from (select ProfissionalID, LocalID, DataDe, DataA from assperiodolocalxprofissional WHERE DataDe>="& mydatenull( DiaMes("P", Data ) )&" AND DataA<="& mydatenull( DiaMes("U", Data) ) &") t LEFT JOIN profissionais p on p.id=t.ProfissionalID "& leftEsp &" WHERE p.Ativo='on' "& sqlEspecialidadesSel & sqlConvenios & sqlProfissionais & sqlProfesp & sqlUnidades

sql = replace(sql, "[DiaSemana]", DiaSemana)
if session("Banco")="clinic5760" then
    response.Write("<script>//SQL GRADES-> "& sql &"</script>")
end if

set comGrade = db.execute( sql )
if comGrade.eof then
    %>
    <div class="alert alert-warning text-center"><i class="far fa-alert"></i> Nenhum profissional encontrado com grade que atenda aos critérios selecionados.  </div>
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
    %>



             <td valign="top">
             <table class="table table-striped table-condensed table-hover" width="100%">
                 <thead>
                    <tr>
                        <th colspan="3" style="min-width:200px" class="text-center">
							<%=left(ucase(comGrade("NomeProfissional")),20)%> <br />
                            <small><%= NomeEspecialidade %></small>
                        </th>
                    </tr>
                 </thead>
                 <tbody>
                    <tr class="hidden l<%=LocalID%>" id="0000"></tr>
                 <%
                    ProfissionalID = comGrade("ProfissionalID")
                    Hora = cdate("00:00")
					set Horarios = db.execute("select ass.*, l.NomeLocal, l.UnidadeID, '0' TipoGrade, '0' GradePadrao from assperiodolocalxprofissional ass LEFT JOIN locais l on l.id=ass.LocalID where ass.ProfissionalID="&ProfissionalID&" and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" "&sqlUnidadesHorarios&" order by HoraDe")
					if Horarios.EOF then
	                    set Horarios = db.execute("select ass.*, l.NomeLocal, l.UnidadeID, '1' GradePadrao from assfixalocalxprofissional ass LEFT JOIN locais l on l.id=ass.LocalID where ass.ProfissionalID="&ProfissionalID&" and ass.DiaSemana="&DiaSemana&" AND ((ass.InicioVigencia IS NULL OR ass.InicioVigencia <= "&mydatenull(Data)&") AND (ass.FimVigencia IS NULL OR ass.FimVigencia >= "&mydatenull(Data)&")) "&sqlUnidadesHorarios&" order by ass.HoraDe")
					end if

                    while not Horarios.EOF
                        LocalID = Horarios("LocalID")
                        UnidadeID = Horarios("UnidadeID")


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

                        if MostraGrade then
                        cProf = cProf+1
                        %>
                        <tr>
                            <td colspan="3" nowrap class="nomeProf" style="background-color:<%=comGrade("Cor")%>">
								 <%=left(ucase(Horarios("NomeLocal")&" "), 20)%><%=getNomeLocalUnidade(Horarios("UnidadeID"))%>
                            </td>
                        </tr>
                        <%
                    if Horarios("TipoGrade")=0 then
                        GradeID=Horarios("id")
                        if Horarios("GradePadrao")="0" then
                            GradeID="0"
                        end if
                        Intervalo = Horarios("Intervalo")
                        if isnull(Intervalo) or Intervalo=0 then
                            Intervalo = 30
                        end if
                        HoraDe = cdate(Horarios("HoraDe"))
                        HoraA = cdate(Horarios("HoraA"))
                        ProfissionalID = Horarios("ProfissionalID")
                        if isnull(ProfissionalID) then
                            ProfissionalID = 0
                        end if
						if instr(Profissionais, "|"&ProfissionalID&"|")=0 and ProfissionalID<>0 then
							Profissionais = Profissionais&"|"&ProfissionalID&"|"
						end if

                        Hora = HoraDe
                        while Hora<=HoraA
                            HoraID = formatdatetime(Hora, 4)
                            HoraID = replace(HoraID, ":", "")
                            if session("FilaEspera")<>"" then
                            %>
                            <tr class="p vazio" data-hora="<%=formatdatetime(Hora, 4)%>" data-pro="<%=ProfissionalID%>" id="<%=HoraID%>">
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
                            %>
                            <tr class="p<%=ProfissionalID%> vazio" data-hora="<%=formatdatetime(Hora, 4)%>" data-pro="<%=ProfissionalID%>" data-id="<%=HoraID%>" id="<%=ProfissionalID&"_"&HoraID%>">
                                <td width="1%"></td>
                                <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(Hora,4) %></button></td>
                                <td colspan="4">
                                    <button type="button" onclick="remarcar(<%=session("RemSol")%>, 'Remarcar', '<%=formatDateTime(Hora,4)%>', '<%=LocalID%>', '<%=ProfissionalID%>')" class="btn btn-xs btn-warning">
                                        <i class="far fa-chevron-left"></i> Agendar Aqui
                                    </button>
                                </td>
                            </tr>
                            <%
                            elseif session("RepSol")<>"" then
                            %>
                            <tr class="p<%=ProfissionalID%> vazio" data-hora="<%=formatdatetime(Hora, 4)%>" data-pro="<%=ProfissionalID%>" data-id="<%=HoraID%>" id="<%=ProfissionalID&"_"&HoraID%>">
                                <td width="1%"></td>
                                <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(Hora,4) %></button></td>
                                <td colspan="4">
                                    <button type="button" onclick="repetir(<%=session("RepSol")%>, 'Repetir', '<%=formatDateTime(Hora,4)%>', '<%=LocalID%>', '<%=ProfissionalID%>')" class="btn btn-xs btn-warning">
                                        <i class="far fa-chevron-left"></i> Repetir Aqui
                                    </button>
                                </td>
                            </tr>
                            <%
                            else
                            %>
                            <tr onclick="abreAgenda('<%=HoraID%>', 0, '<%=Data%>', <%=LocalID%>, <%=ProfissionalID %>, '','<%=GradeID%>' )" class="p<%=ProfissionalID%>" data-pro="<%=ProfissionalID%>" data-id="<%=HoraID%>" data-hora="<%= ft(Hora) %>" id="<%=ProfissionalID&"_"&HoraID%>">
                                <td width="1%" style="background-color:<%=comGrade("Cor")%>"></td>
                                <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= ft(Hora) %></button></td>
                                <td><%= Tipo %></td>
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
                                %>
                                <tr onclick="abreAgenda('<%=HoraID%>', 0, '<%=Data%>', <%=LocalID%>, <%=ProfissionalID %>,'','<%=Horarios("id")%>' )" class="p<%=ProfissionalID%>" data-pro="<%=ProfissionalID%>" data-id="<%=HoraID%>" data-hora="<%= ft(HoraPers) %>" id="<%=ProfissionalID&"_"&HoraID%>">
                                    <td width="1%" style="background-color:<%=comGrade("Cor")%>"></td>
                                    <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(HoraPers,4) %></button></td>
                                    <td colspan="4"><%= Tipo %></td>
                                </tr>
                                <%
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
                    <tr class="hidden l p<%=ProfissionalID%> l<%= LocalID %>" data-id="2359"></tr>
                  </tbody>
              </table>
                 <%'=Profissionais %>
                <script type="text/javascript">
                <%
                set comps=db.execute("select a.id, a.Data, a.Hora, a.LocalID, a.ProfissionalID, a.StaID, a.FormaPagto, a.Encaixe, a.Tempo, a.Procedimentos, p.NomePaciente, pro.NomeProfissional, pro.Cor, proc.NomeProcedimento, proc.Cor CorProcedimento from agendamentos a "&_
                "left join pacientes p on p.id=a.PacienteID "&_ 
                "left join profissionais pro on pro.id=a.ProfissionalID "&_ 
                "left join procedimentos proc on proc.id=a.TipoCompromissoID "&_ 
                "where a.ProfissionalID="&ProfissionalID&" and a.Data="&mydatenull(Data)&"order by Hora")
                while not comps.EOF
                    HoraComp = HoraToID(comps("Hora"))
                    compsHora = comps("Hora")
                    FormaPagto = comps("FormaPagto")
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


					    Conteudo = "<tr data-toggle=""tooltip"" data-html=""true"" data-placement=""bottom"" title="""&replace(NomeProcedimento&" ", "'", "\'")&" <br> "&replace(comps("NomeProfissional")&" ", "'", "\'")&""" id="""&HoraComp&""" onclick=""abreAgenda(\'"&HoraComp&"\', "&comps("id")&", \'"&comps("Data")&"\', \'"&comps("LocalID")&"\', \'"&comps("ProfissionalID")&"\')""><td width=""1%"" style=""background-color:"&comps("Cor")&"""></td><td width=""1%"" style=""background-color:"&CorProcedimento&"!important""><button type=""button"" class=""btn btn-xs btn-warning"">"&compsHora&"</button></td><td nowrap><img src=""assets/img/"&comps("StaID")&".png""> "
					if comps("Encaixe")=1 then
						Conteudo = Conteudo & "<span class=""label label-alert label-sm arrowed-in arrowed-in-right"">Enc</span>"
					end if
					Conteudo = Conteudo & "<span class=""nomePac"">"&replace(comps("NomePaciente")&" ", "'", "\'")&"</span>  <span class=""pull-right"">"& sinalAgenda(FormaPagto) &"</span> </td></tr>"
                %>
                var Status = '<%=comps("StaID")%>';
                $( ".p<%=ProfissionalID%>" ).each(function(){
                    if( $(this).attr("data-id")=='<%=HoraComp%>' && Status !== '11')
                    {
                        $(this).replaceWith('<%= conteudo %>');
                        return false;
                    }
                    else if ( $(this).attr("data-id")>'<%=HoraComp%>' )
                    {
                        $(this).before('<%=conteudo%>');
                        return false;
                    }
                });
                <%
	if HoraFinal<>"" then
		%>
		if(Status!== '11'){
            $( ".p<%=ProfissionalID%>" ).each(function(){
                if( $(this).attr("data-id")>'<%=HoraComp%>' && $(this).attr("data-id")<'<%=HoraFinal%>' )
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


                bloqueioSql = "select c.* from compromissos c where (c.ProfissionalID="&ProfissionalID&" or (c.ProfissionalID=0 AND (c.Profissionais = '' or c.Profissionais LIKE '%|"&ProfissionalID&"%|'))) AND (c.Unidades LIKE '%|"&UnidadeID&"|%' or c.Unidades='' or c.Unidades is null) and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" and DiasSemana like '%"&weekday(Data)&"%'"

				set bloq = db.execute(bloqueioSql)

                while not bloq.EOF
                HoraDe = HoraToID(bloq("HoraDe"))
                HoraA = HoraToID(bloq("HoraA"))
                Conteudo = "<tr id=""'+$(this).attr('id')+'"" onClick=""abreBloqueio("&bloq("id")&", \'\', \'\');"">"&_ 
                "<td width=""1%""></td><td width=""1%""><button type=""button"" class=""btn btn-xs btn-danger"">'+$(this).attr('data-hora')+'</button></td>"&_ 
                "<td nowrap><img src=""assets/img/bloqueio.png""> <span class=""nomePac"">"&replace(bloq("Titulo")&" ", "'", "\'")&"</span></td>"&_ 
                "<td class=""hidden-xs text-center""></td>"&_ 
                "<td class=""hidden-xs hidden-sm text-center""></td>"&_ 
                "<td class=""hidden-xs text-right nomeConv""></td>"&_ 
                "</tr>"
                HBloqueados = HBloqueados+1
                %>
                $( ".p<%=ProfissionalID%>" ).each(function(){
                    if( $(this).attr("data-id")>='<%=HoraDe%>' && $(this).attr("data-id")<'<%=HoraA%>' )
                    {
                        $(this).replaceWith('<%= conteudo %>');
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

                %>
                </script>
              </td>


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
        response.write("//"& sqlVerme )
        set vcaGrade = db.execute( replace(sqlVerme, "[DiaSemana]", cDiaSemana) )
	    if not vcaGrade.eof then
			%>
			$(".d<%=weekday(cDiaSemana)%>").removeClass("danger");//P: <%=vcaGrade("ProfissionalID")%>
			<%
		end if
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
