<%InicioProcessamento = Timer%>
<!--#include file="connect.asp"-->
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


'on error resume next

HLivres = 0
HAgendados = 0
HBloqueados = 0

if req("Data")="" then
	Data=date()
else
	Data=req("Data")
end if
EquipamentoID=req("EquipamentoID")
DiaSemana=weekday(Data)
mesCorrente=month(Data)


escreveData = formatdatetime(Data, 1)

set prof = db.execute("select '#CCC' Cor, NomeEquipamento, Foto from equipamentos where ativo='on' and id="&EquipamentoID)
if not prof.eof then
	Cor = prof("Cor")
	NomeEquipamento = prof("NomeEquipamento")
	if isnull(prof("Foto")) or prof("Foto")="" then
		FotoProfissional = "assets/img/Computer.png"
	else
		FotoProfissional = arqEx(prof("Foto"), "Perfil")
	end if
else
	Cor = "#333"
	FotoProfissional = "assets/img/Computer.png"
end if
%>
<script>
$("#FotoProfissional").css("border-color", "<%=Cor%>");
$("#FotoProfissional").attr("src", "<%=FotoProfissional%>");
$("#FotoProfissional").css("background-image", "url(<%=FotoProfissional%>)");
<%
if len(ObsAgenda)>0 then
	%>
	$("#ObsAgenda").removeClass("hidden");
	$("#ObsAgenda").attr("data-content", "<%=ObsAgenda%>");
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
if session("RemSol")<>"" then
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

<% if req("crumb")&"" <> "N" then %>
<script type="text/javascript">
    function crumbAgenda(){
        $(".crumb-active").html("<a href='./?P=EquipamentosAlocados&Pers=1'>Agenda de Equipamentos</a>");
        $(".crumb-icon a span").attr("class", "far fa-calendar");
        $(".crumb-link").replaceWith("");
        $(".crumb-trail").removeClass("hidden");
        $(".crumb-trail").html("<%=(escreveData)%>");
    }
    crumbAgenda();
</script>
<% end if%>

<table class="table table-striped table-hover table-condensed table-agenda">
     <%
        DiaSemana = weekday(Data)
        Hora = cdate("00:00")
		set Horarios = db.execute("select ass.*, '0' tipograde,  l.NomeLocal, '0' GradePadrao, '' Cor from assperiodolocalxprofissional ass LEFT JOIN locais l on l.id=ass.LocalID where ass.ProfissionalID=-"&EquipamentoID&" and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" order by HoraDe")
		if Horarios.EOF then
	        set Horarios = db.execute("select ass.*, l.NomeLocal, '1' GradePadrao, '' Cor from assfixalocalxprofissional ass LEFT JOIN locais l on l.id=ass.LocalID where ass.ProfissionalID=-"&EquipamentoID&" and ass.DiaSemana="&DiaSemana&" AND ((ass.InicioVigencia IS NULL OR ass.InicioVigencia <= "&mydatenull(Data)&") AND (ass.FimVigencia IS NULL OR ass.FimVigencia >= "&mydatenull(Data)&")) order by ass.HoraDe")
		end if

		MostraGrade = true

        if Horarios.eof then
			MostraGrade=False
		else
			if Horarios("GradePadrao")=1 then
				MostraGrade = CalculoSemanalQuinzenal(Horarios("FrequenciaSemanas"), Horarios("InicioVigencia")&"")
			end if
		end if
		if MostraGrade = false then
		%>
				<tr><td class="text-center" colspan="6"><small>Não há grade configurada para este dia da semana.</small></td></tr> 
		<% 
		else
	%>
     		<tbody>
        		<tr class="hidden l<%=LocalID%>" id="0000"></tr>
	<%
				sqlUnidadesBloqueio=""

				while not Horarios.EOF
					LocalID = Horarios("LocalID")
					if Horarios("Cor")&""<>"" then
						Cor = Horarios("Cor")
					end if
					%>
					<tr>
						<td colspan="6" nowrap class="nomeProf text-center" style="background-color:<%=Cor%>; display: none;">
							<%=ucase(Horarios("NomeLocal")&" ")%><input type="hidden" name="LocalEncaixe" id="LocalEncaixe" value="<%=LocalID%>">
						</td>
					</tr>
					<%
					GradeID=Horarios("id")

					if Horarios("tipograde")&"" ="0" then

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
						while Hora<=HoraA
							HoraID = formatdatetime(Hora, 4)
							HoraID = replace(HoraID, ":", "")
							if session("FilaEspera")<>"" then
							%>
							<tr class="l vazio" data-hora="<%=formatdatetime(Hora, 4)%>" id="<%=HoraID%>">
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
							<tr class="l vazio" data-hora="<%=formatdatetime(Hora, 4)%>" id="<%=HoraID%>">
								<td width="1%"></td>
								<td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(Hora,4) %></button></td>
								<td colspan="4">
									<button type="button" onclick="remarcar(<%=session("RemSol")%>, 'Remarcar', '<%=formatDateTime(Hora,4)%>', '<%=LocalID%>')" class="btn btn-xs btn-warning">
										<i class="far fa-chevron-left"></i> Agendar Aqui
									</button>
								</td>
							</tr>
							<%
							elseif session("RepSol")<>"" then
							%>
							<tr class="l vazio" data-hora="<%=formatdatetime(Hora, 4)%>" id="<%=HoraID%>">
								<td width="1%"></td>
								<td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(Hora,4) %></button></td>
								<td colspan="4">
									<button type="button" onclick="repetir(<%=session("RepSol")%>, 'Repetir', '<%=formatDateTime(Hora,4)%>', '<%=LocalID%>')" class="btn btn-xs btn-warning">
										<i class="far fa-chevron-left"></i> Repetir Aqui
									</button>
								</td>
							</tr>
							<%
							else
								HLivres = HLivres+1
							%>
							<tr onclick="abreAgenda('<%=HoraID%>', 0, '<%=Data%>', <%=LocalID%>, <%=EquipamentoID%>,<%=GradeID%>)" class="l vazio" data-local='<%=LocalID%>' data-grade='<%= Horarios("id") %>' data-hora="<%=formatdatetime(Hora, 4)%>" id="<%=HoraID%>">
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
										<tr class="l vazio" data-hora="<%=formatdatetime(HoraPers, 4)%>" id="<%=HoraID%>">
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
										<tr class="l vazio" data-hora="<%=formatdatetime(HoraPers, 4)%>" id="<%=HoraID%>">
											<td width="1%"></td>
											<td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(HoraPers,4) %></button></td>
											<td colspan="4">
												<button type="button" onclick="remarcar(<%=session("RemSol")%>, 'Remarcar', '<%=formatDateTime(HoraPers,4)%>', '<%=LocalID%>')" class="btn btn-xs btn-warning">
													<i class="far fa-chevron-left"></i> Agendar Aqui
												</button>
											</td>
										</tr>
										<%
										elseif session("RepSol")<>"" then
										%>
										<tr class="l vazio" data-hora="<%=formatdatetime(HoraPers, 4)%>" id="<%=HoraID%>">
											<td width="1%"></td>
											<td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(HoraPers,4) %></button></td>
											<td colspan="4">
												<button type="button" onclick="repetir(<%=session("RepSol")%>, 'Repetir', '<%=formatDateTime(HHoraPersora,4)%>', '<%=LocalID%>')" class="btn btn-xs btn-warning">
													<i class="far fa-chevron-left"></i> Repetir Aqui
												</button>
											</td>
										</tr>
										<%
										else
											HLivres = HLivres+1
										%>
										<tr onclick="abreAgenda('<%=HoraID%>', 0, '<%=Data%>', <%=LocalID%>, <%=EquipamentoID%>,<%=GradeID%>)" class="l vazio" data-local="<%=LocalID%>" data-grade='<%= Horarios("id") %>' data-hora="<%=formatdatetime(HoraPers, 4)%>" id="<%=HoraID%>">
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
				Horarios.movenext
				wend
				Horarios.close
				set Horarios=nothing
      %>
        		<tr class="hidden l" id="2359"></tr>
      		</tbody>
		<% end if %>
</table>
                <script>
                <%
                 sqlcomps = "select a.id, a.Data, a.Hora, a.PacienteID, a.LocalID, a.EquipamentoID, a.StaID, a.Encaixe, a.Tempo,a.Procedimentos, a.Primeira, prof.NomeProfissional, p.IdImportado, p.NomePaciente, p.Tel1, p.Cel1, proc.NomeProcedimento, s.StaConsulta, a.rdValorPlano, a.ValorPlano, a.Notas, c.NomeConvenio, l.NomeLocal, (select Resposta from agendamentosrespostas where AgendamentoID=a.id limit 1) Resposta from agendamentos a "&_
                "left join equipamentoprocedimentos eq ON eq.ProcedimentoID=a.TipoCompromissoID "&_
                "left join agendamentosprocedimentos ap ON ap.AgendamentoID=a.id "&_
                "left join pacientes p on p.id=a.PacienteID "&_
                "left join procedimentos proc on proc.id=a.TipoCompromissoID "&_
                "left join staconsulta s on s.id=a.StaID "&_ 
                "left join convenios c on c.id=a.ValorPlano "&_ 
				"left join locais l on l.id=a.LocalID "&_ 
				"left join profissionais prof on prof.id=a.ProfissionalID "
				'response.write sqlcomps

                if NaoExibirOutrasAgendas = 0 then
                    compsWhereSql = "where a.Data="&mydatenull(Data)&" and a.sysActive=1 and (a.EquipamentoID="&EquipamentoID&" or ap.EquipamentoID="&EquipamentoID&" ) GROUP BY a.id order by Hora"
				else
					compsWhereSql = "where a.Data="&mydatenull(Data)&" and a.sysActive=1 and (a.EquipamentoID="&EquipamentoID&" or ap.EquipamentoID="&EquipamentoID&" ) AND COALESCE( l.UnidadeID = "&session("UnidadeID")&",FALSE) GROUP BY a.id order by Hora"
				end if
				
				set comps=db.execute(sqlcomps&compsWhereSql)
                while not comps.EOF

                    ValorProcedimentosAnexos = 0

                    HoraComp = HoraToID(comps("Hora"))
                    Tempo = 0
					Horario = comps("Hora")

					if isnull(Horario) then
						Horario = "00:00"
					end if
					if not isnull(comps("Hora")) then
						compsHora = formatdatetime( comps("Hora"), 4 )
					else
						compsHora = ""
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

					'->hora final
					if not isnull(comps("Tempo")) and comps("Tempo")<>"" and isnumeric(comps("Tempo")) then
						Tempo = Tempo + ccur(comps("Tempo"))
					end if

					if comps("rdValorPlano")="V" then
					    Valor = comps("ValorPlano") + ValorProcedimentosAnexos

						if not isnull(Valor) then
							Valor = "R$ "&fn(Valor)
						else
							Valor = "R$ 0,00"
						end if
						if aut("areceberpacienteV")=0 then
							Valor = ""
						end if
					else
						Valor = comps("NomeConvenio")
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
					'if session("banco")="clinic1612" or session("banco")="clinic5868" or session("banco")="clinic3610" or session("banco")="clinic105" or session("banco")="clinic3859" or session("banco")="clinic5491" then
                        Prontuario = comps("idImportado")
                        if isnull(Prontuario) then
                            Prontuario = ""
                        end if
                    else
                        Prontuario = comps("PacienteID")
                    end if
					'<--

                    Conteudo = "<tr id="""&HoraComp&""" data-toggle=""tooltip"" data-html=""true"" data-placement=""bottom"" title="""&replace(comps("NomePaciente")&" ", "'", "\'")&"<br>Prontuário: "&Prontuario&"<br>"
					if instr(omitir, "tel1")=0 then
						Conteudo = Conteudo & "Tel.: "&replace(comps("Tel1")&" ", "'", "\'")&"<br>"
					end if
					if instr(omitir, "cel1")=0 then
						Conteudo = Conteudo & "Cel.: "&replace(comps("Cel1")&" ", "'", "\'")&"<br>"
					end if
                    if not isnull(comps("NomeProfissional")) then
                        Conteudo = Conteudo & "Prof.: "&replace(comps("NomeProfissional")&" ", "'", "\'")&"<br>"
                    end if
					'if session("Banco")="clinic5594" then
                        Conteudo = Conteudo & "Notas: "&replace(replace(replace(replace(comps("Notas")&"", chr(13), ""), chr(10), ""), "'", ""), """", "")&"<br>"
                    'end if
					Conteudo = Conteudo & """ onclick=""abreAgenda(\'"&HoraComp&"\', "&comps("id")&", \'"&comps("Data")&"\', \'"&comps("LocalID")&"\', \'"&comps("EquipamentoID")&"\',\'GRADE_ID\')"">"&_ 
					"<td width=""1%"">"
					if not isnull(comps("Resposta")) then
						Conteudo = Conteudo & "<i class=""far fa-envelope pink""></i> "
					end if
					if comps("Primeira")=1 then
                        Conteudo = Conteudo & "<i class=""far fa-flag blue"" title=""Primeira vez""></i> "
                    end if
					if comps("LocalID")<>LocalID then
						Conteudo = Conteudo & "<i class=""far fa-exclamation-triangle grey""  title=""Agendado para &raquo; "&replace(comps("NomeLocal")&" ", "'", "\'")&"""></i>"
					end if
					Conteudo = Conteudo & "</td><td width=""1%""><button type=""button"" data-hora="""&replace( compsHora, ":", "" )&""" class=""btn btn-xs btn-default btn-comp"">"&compsHora&"</button></td>"&_ 
					"<td nowrap> "&imoon(comps("StaID"))
					if comps("Encaixe")=1 then
						Conteudo = Conteudo & "<span class=""label bg-alert label-pink label-sm arrowed-in mr10 arrowed-in-right"">encaixe</span>"
					end if
					Conteudo = Conteudo & "<span class=""nomePac"">"&replace(comps("NomePaciente")&" ", "'", "\'")&"</span>"
					Conteudo = Conteudo & "</td>"&_ 
					"<td class=""text-center""><span class=""nomePac"">"&replace(NomeProcedimento&" ", "'", "\'")&"</span></td>"&_
					"<td class=""text-center"">"&comps("StaConsulta")&"</td>"&_ 
					"<td class=""text-right nomeConv"">"&replace(Valor&" ", "'", "\'")&"</td>"&_
					"</tr>"
					HAgendados = HAgendados+1

                %>
                var Status = '<%=comps("StaID")%>';

                $( ".l" ).each(function(){
                    if( $(this).attr("id")=='<%=HoraComp%>' && (Status !== "11" && Status !== "22" && Status !== "33" ))
                    {
                        var gradeId = $(this).data("grade");

                        $(this).replaceWith('<%=conteudo %>'.replace(new RegExp("GRADE_ID",'g'), gradeId));
                        return false;
                    }
                    else if ( $(this).attr("id")>'<%=HoraComp%>' )
                    {
                        var gradeId = $(this).data("grade");
                        $(this).before('<%=conteudo%>'.replace(new RegExp("GRADE_ID",'g'), gradeId));
                        return false;
                    }
                });
				
                	<%
					if HoraFinal<>"" then
						%>
						$( ".vazio" ).each(function(){
							if( $(this).attr("id")>'<%=HoraComp%>' && $(this).attr("id")<'<%=HoraFinal%>' && (Status !== "11" && Status !== "22" && Status !== "33" <%=StatusRemarcado%>) )
							{
								//alert('oi');
								$(this).replaceWith('');
								//return false;
							}
						});
						<%
					end if
                comps.movenext
                wend
                comps.close
                set comps = nothing

                'sqlBloqueio = "select c.* from compromissos c where c.ProfissionalID=-"&EquipamentoID&" and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" and DiasSemana like '%"&weekday(Data)&"%'"
				bloqueioSql = getBloqueioSql("-"&EquipamentoID, Data, sqlUnidadesBloqueio)
                set bloq = db.execute(bloqueioSql)

				while not bloq.EOF
					HoraDe = HoraToID(bloq("HoraDe"))
					HoraA = HoraToID(bloq("HoraA"))
                    Conteudo = "<tr id=""'+$(this).attr('data-hora')+'"" onClick=""abreBloqueio("&bloq("id")&", \'\', \'\');"">"&_ 
					"<td width=""1%""></td><td width=""1%""><button type=""button"" class=""btn btn-xs btn-danger"">'+$(this).attr('data-hora')+'</button></td>"&_ 
					"<td nowrap><img src=""assets/img/bloqueio.png""> <span class=""nomePac"">"&replace(bloq("Titulo")&" ", "'", "\'")&"</span></td>"&_ 
					"<td class=""hidden-xs text-center""></td>"&_ 
					"<td class=""hidden-xs hidden-sm text-center""></td>"&_ 
					"<td class=""hidden-xs text-right nomeConv""></td>"&_ 
					"</tr>"
					HBloqueados = HBloqueados+1
					%>
					$( ".vazio" ).each(function(){
						if( $(this).attr("id")>='<%=HoraDe%>' && $(this).attr("id")<'<%=HoraA%>' )
						{
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
<script language="javascript">
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
	set ObsDia = db.execute("select * from agendaobservacoes where ProfissionalID=-"&EquipamentoID&" and Data="&mydatenull(Data)&"")
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
	
	set pDiasAT=db.execute("select distinct a.DiaSemana from assfixalocalxprofissional a where a.ProfissionalID =- "&EquipamentoID&" and (a.fimVigencia > now() or a.fimVigencia is null)")
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

	'verifica os dias onde há exceção e retira 
	ExcecaoMesAnoSplt = split(Data,"/")
    ExcecaoMesAno = ExcecaoMesAnoSplt(2)&"-"&ExcecaoMesAnoSplt(1)
    sExc = "select DataDe from assperiodolocalxprofissional a where a.DataDe LIKE '"&ExcecaoMesAno&"-%' AND a.DataDe LIKE '"&ExcecaoMesAno&"-%' AND a.ProfissionalID = -"&EquipamentoID
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
	
	 sqlocup = "select * from agendaocupacoes where ProfissionalID=-"&EquipamentoID&" and month(Data)="&month(Data)&" and year(Data)="&year(Data)&" order by Data"
	set ocup = db.execute(sqlocup)
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
		if($(".<%=replace(ocup("Data"), "/", "-")%>").hasClass("danger")===false){
			$("#prog<%=replace(ocup("Data"), "/", "")%>").html('<% If percOcup>0 Then %><div class="progress-bar progress-bar-danger" style="width: <%=percOcup%>%;"></div><% End If %><%if percLivre>0 then%><div class="progress-bar progress-bar-success" style="width: <%=percLivre%>%;"></div><% End If %>');
		}
		<%
	ocup.movenext
	wend
	ocup.close
	set ocup = nothing
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
                        url: 'AgendaResumoEquipamento.asp?D='+api.elements.target.attr('id')+'&EquipamentoID='+$("#EquipamentoID").val() // Use href attribute as URL
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
	var ProfissionalID = ["-<%=EquipamentoID%>"];
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
	//$.post("atualizaOcupacoes.asp?HLivres="+ $(".vazio").size() +"&HAgendados=<%= HAgendados %>&HBloqueados=<%= HBloqueados %>&ProfissionalID=-<%= EquipamentoID %>&LocalID=<%= LocalID %>&Data=<%= Data %>", '', function(data, status){ eval(data) });
	<%
end if
%>
</script>

<!--#include file = "disconnect.asp"-->
