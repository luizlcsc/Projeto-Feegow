<!--#include file="Classes/GradeAgendaUtil.asp"-->
<%
refEquipamentos = replace(refEquipamentos, "|", "")
if ref("Equipamentos")<>"" then
    sqlRefEquipamentos = " id IN ("&refEquipamentos&") "
end if

if SomenteEquipamentos<>"" then
    SomenteEquipamentos = replace(SomenteEquipamentos, "|", "")
    sqlSomenteEquipamentos = " id IN ("&SomenteEquipamentos&") "
end if

if refEquipamentos<>"" AND SomenteEquipamentos<>"" then
    sqlOR = " OR "
else
    sqlOR = ""
end if

set equ = db.execute("select * from equipamentos where "& sqlRefEquipamentos & sqlOR & sqlSomenteEquipamentos )
while not equ.eof
    EquipamentoID = equ("id")
    %>
             <td valign="top">
             <table class="table table-striped table-condensed table-hover" width="100%">
                 
                 <%
                    MostraGrade = true

					set Horarios = db.execute("select ass.*, '0' tipograde, '0' GradePadrao from assperiodolocalxprofissional ass where ass.ProfissionalID="&EquipamentoID*(-1)&" and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" order by HoraDe")
					if Horarios.EOF then
	                    set Horarios = db.execute("select ass.*, '1' GradePadrao from assfixalocalxprofissional ass where ass.ProfissionalID="&EquipamentoID*(-1)&" and ass.DiaSemana="&DiaSemana&" AND ((ass.InicioVigencia IS NULL OR ass.InicioVigencia <= "&mydatenull(Data)&") AND (ass.FimVigencia IS NULL OR ass.FimVigencia >= "&mydatenull(Data)&")) order by ass.HoraDe")
					end if
                    
                    if not Horarios.EOF then
                        if Horarios("GradePadrao")="1" then
                            MostraGrade = CalculoSemanalQuinzenal(Horarios("FrequenciaSemanas"), Horarios("InicioVigencia")&"")
                        end if
                    end if
                    sqlUnidadesBloqueio= ""

                    if MostraGrade then
                %>
                        <thead>
                            <tr>
                                <th colspan="3" style="min-width:200px" class="text-center warning">
                                    <i title="Configurações do Local" alt="Configurações do Local" style="cursor:pointer" onclick="location.href='?P=Equipamentos&I=<%=equ("id") %>&Pers=1&Aba=Horarios';" class="far fa-cog red"></i>
                                    <%=left(ucase(equ("NomeEquipamento")),20)%>
                                </th>
                            </tr>
                        </thead>
                    <% end if %>
                 <tbody>
                    <tr class="hidden e<%=LocalID%>" id="0000"></tr>
                 <%
                    while not Horarios.EOF

                        MostraGrade = true
                        if Horarios("GradePadrao")="1" then
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

                            if UnidadeID&"" <> "" then
                                sqlUnidadesBloqueio = sqlUnidadesBloqueio&" OR c.Unidades LIKE '%|"&UnidadeID&"|%'"
                            end if
                            
                            LocalID=Horarios("LocalID")
                            %>
                            <tr>
                                <td colspan="3" nowrap class="nomeProf">
                                    <%'=left(ucase(Horarios("NomeProfissional")&" "), 20)%>
                                </td>
                            </tr>
                            <%
                            Intervalo = Horarios("Intervalo")
                            if isnull(Intervalo) or Intervalo=0 then
                                Intervalo = 30
                            end if
                            HoraDe = cdate(Horarios("HoraDe"))
                            HoraA = cdate(Horarios("HoraA"))

                            Hora = HoraDe
                            while Hora<=HoraA
                                HoraID = formatdatetime(Hora, 4)
                                HoraID = replace(HoraID, ":", "")
    '                            else
                                %>
                                <tr onclick="abreAgenda('<%=HoraID%>', 0, '<%=Data%>', '<%=LocalID%>', '<%=ProfissionalID %>', '<%=EquipamentoID %>' ,'<%=Horarios("id")%>')" class="e<%=EquipamentoID%>" data-pro="<%=EquipamentoID%>" data-id="<%=HoraID%>" data-hora="<%= ft(Hora) %>" id="e<%=EquipamentoID&"_"&HoraID%>">
                                    <td width="1%"></td>
                                    <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= ft(Hora) %></button></td>
                                    <td><%= Tipo %></td>
                                </tr>
                                <%
    '							end if
                                Hora = dateadd("n", Intervalo, Hora)

                                ' if instr(Hora, "08:30") <> -1 then
                                '     HoraA = dateadd("n", 1, HoraA)
                                ' end if
                                
                            wend
                        end if
                        Horarios.movenext
                    wend
                    Horarios.close
                    set Horarios=nothing
                  %>
                  </tbody>
              </table>



                <script type="text/javascript">
                <%
                set comps=db.execute("select a.Procedimentos, a.id, a.Data, a.Hora, a.LocalID, a.ProfissionalID, a.StaID, a.FormaPagto, a.Encaixe, a.Tempo, p.NomePaciente, pro.NomeProfissional, pro.Cor, proc.NomeProcedimento, proc.Cor CorProcedimento from agendamentos a "&_
                "left join equipamentoprocedimentos eq ON eq.ProcedimentoID=a.TipoCompromissoID "&_
                "left join agendamentosprocedimentos ap ON ap.AgendamentoID=a.id "&_
                "left join pacientes p on p.id=a.PacienteID "&_
                "left join profissionais pro on pro.id=a.ProfissionalID "&_
                "left join procedimentos proc on proc.id=a.TipoCompromissoID "&_
                "where a.sysActive=1 AND (a.EquipamentoID="&EquipamentoID&" or eq.EquipamentoID="&EquipamentoID&" or ap.EquipamentoID="&EquipamentoID&") and a.Data="&mydatenull(Data)&" GROUP BY a.id order by Hora")
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


					Conteudo = "<tr title="""&replace(comps("NomeProcedimento")&" ", "'", "\'")&" \n "&replace(comps("NomeProfissional")&" ", "'", "\'")&""" id="""&HoraComp&""" onclick=""abreAgenda(\'"&HoraComp&"\', "&comps("id")&", \'"&comps("Data")&"\', \'"&comps("LocalID")&"\', \'"&comps("ProfissionalID")&"\', \'\')""><td width=""1%"" style=""background-color:"&comps("Cor")&"""></td><td width=""1%"" style=""background-color:"&CorProcedimento&"!important""><button type=""button"" class=""btn btn-xs btn-warning"">"&compsHora&"</button></td><td nowrap><img src=""assets/img/"&comps("StaID")&".png""> "
					if comps("Encaixe")=1 then
						Conteudo = Conteudo & "<span class=""label label-pink label-sm arrowed-in arrowed-in-right"">encaixe</span>"
					end if
					Conteudo = Conteudo & "<span class=""nomePac"">"&replace(comps("NomePaciente")&" ", "'", "\'")&"</span>  <span class=""pull-right"">"& sinalAgenda(FormaPagto) &"</span> </td></tr>"
                %>
                $( ".e<%=EquipamentoID%>" ).each(function(){
                    if( $(this).attr("data-id")=='<%=HoraComp%>' )
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
		$( ".e<%=EquipamentoID%>" ).each(function(){
			if( $(this).attr("data-id")>'<%=HoraComp%>' && $(this).attr("data-id")<'<%=HoraFinal%>' )
			{
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

                'set bloq = db.execute("select c.* from compromissos c where c.ProfissionalID=-"&EquipamentoID&" and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" and DiasSemana like '%"&weekday(Data)&"%'")
				bloqueioSql = getBloqueioSql("-"&EquipamentoID, Data, sqlUnidadesBloqueio)
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
                    $( ".e<%=EquipamentoID%>" ).each(function(){
                        if( $(this).attr("data-id")>='<%=HoraDe%>' && $(this).attr("data-id")<'<%=HoraA%>' )
                        {
                            $(this).replaceWith('<%= conteudo %>');
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
equ.movenext
wend
equ.close
set equ=nothing
%>
