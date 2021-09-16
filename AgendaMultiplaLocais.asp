<%
refLocais = replace(refLocais, "|", "")
if ref("Locais")<>"" then

    if instr(refLocais, "G") then
        LocaisSplt = split(ref("Locais"), ", ")
        for i=0 to ubound(LocaisSplt)
            LocaisSplt(i) = replace(LocaisSplt(i),"|","")

             if left(LocaisSplt(i),1)="G" then
                set GrupoLocaisSQL = db.execute("SELECT Locais FROM locaisgrupos WHERE id="&replace(LocaisSplt(i),"G",""))
                if not GrupoLocaisSQL.eof then
                    refLocais = replace(refLocais, LocaisSplt(i), replace(GrupoLocaisSQL("Locais"),"|",""))
                end if
            end if
        next
    end if

    if refLocais<>"" then
        sqlRefLocais = " id IN ("&refLocais&") "
    end if
end if

if SomenteLocais<>"" then
    SomenteLocais = replace(SomenteLocais, "|", "")
    sqlSomenteLocais = " id IN ("&SomenteLocais&") "
end if

if refLocais<>"" AND SomenteLocais<>"" then
    sqlOR = " OR "
else
    sqlOR = ""
end if

cLoc = 0
set loc = db.execute("select * from locais where "& sqlRefLocais & sqlOR & sqlSomenteLocais )
while not loc.eof
    cLoc = cLoc+1
    LocalID = loc("id")

                    Hora = cdate("00:00")
					set Horarios = db.execute("select ass.*, p.NomeProfissional from assperiodolocalxprofissional ass LEFT JOIN profissionais p on p.id=ass.ProfissionalID where ass.LocalID="&LocalID&" and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" order by HoraDe")
					if Horarios.EOF then
	                    set Horarios = db.execute("select ass.*, p.NomeProfissional from assfixalocalxprofissional ass LEFT JOIN profissionais p on p.id=ass.ProfissionalID where ass.LocalID="&LocalID&" and ass.DiaSemana="&DiaSemana&" AND ((ass.InicioVigencia IS NULL OR ass.InicioVigencia <= "&mydatenull(Data)&") AND (ass.FimVigencia IS NULL OR ass.FimVigencia >= "&mydatenull(Data)&")) order by ass.HoraDe")
					end if
					if not Horarios.EOF then
					    %>
                     <td valign="top">
                     <table class="table table-striped table-condensed table-hover" width="100%">
                         <thead>
                            <tr>
                                <th colspan="3" style="min-width:200px" class="text-center danger">
                                    <i title="Configurações do Local" alt="Configurações do Local" style="cursor:pointer" onclick="location.href='?P=EdiProfQD&Pers=1&LId=<%=LocalID %>&Data=<%=Data %>';" class="far fa-cog"></i>
                                    <%=left(ucase(loc("NomeLocal")),20)%><%=getNomeLocalUnidade(loc("UnidadeID"))%>
                                </th>
                            </tr>
                         </thead>
                         <tbody>
                            <tr class="hidden l<%=LocalID%>" id="0000"></tr>
                         <%
                        while not Horarios.EOF
                            ProfissionalID = Horarios("ProfissionalID")

                            Continuar=True
                            if ref("Especialidade")<>"" and ProfissionalID<>0 then
                                Especialidades = replace(ref("Especialidade"),"|","")
                                set ProfissionalEspecialidadeSQL = db.execute("SELECT profissionais.EspecialidadeID FROM profissionais WHERE EspecialidadeID IN ("&Especialidades&") AND id='"&ProfissionalID&"' UNION SELECT EspecialidadeID FROM profissionaisespecialidades WHERE EspecialidadeID IN ("&Especialidades&") AND ProfissionalID='"&ProfissionalID&"'")

                                if ProfissionalEspecialidadeSQL.eof then
                                    Continuar=False
                                end if
                            end if
                            if Continuar then
                                %>
                                <tr>
                                    <td colspan="3" nowrap class="nomeProf">
                                         <%=left(ucase(Horarios("NomeProfissional")&" "), 20)%>
                                    </td>
                                </tr>
                                <%

                                Intervalo = Horarios("Intervalo")
                                if isnull(Intervalo) or Intervalo=0 then
                                    Intervalo = 30
                                end if
                                HoraDe = cdate(Horarios("HoraDe"))
                                HoraA = cdate(Horarios("HoraA"))
                                ProfissionalID = Horarios("ProfissionalID")

                                Hora = HoraDe
                                while Hora<=HoraA
                                    HoraID = formatdatetime(Hora, 4)
                                    HoraID = replace(HoraID, ":", "")
        '                            else
                                    %>
                                    <tr onclick="abreAgenda('<%=HoraID%>', 0, '<%=Data%>', <%=LocalID%>, <%=ProfissionalID %> )" class="l<%=LocalID%> pl<%=ProfissionalID%>" data-pro="<%=ProfissionalID%>" data-id="<%=HoraID%>" data-hora="<%= ft(Hora) %>" id="l<%=LocalID&"_"&HoraID%>">
                                        <td width="1%"></td>
                                        <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= ft(Hora) %></button></td>
                                        <td><%= Tipo %></td>
                                    </tr>
                                    <%
        '							end if
                                    Hora = dateadd("n", Intervalo, Hora)
                                wend


                                'aplica os bloqueios
                                set bloq = db.execute("select c.* from compromissos c where c.ProfissionalID="&ProfissionalID&" and DataDe<="&mydatenull(Data)&" and DataA>="&mydatenull(Data)&" and DiasSemana like '%"&weekday(Data)&"%'")

                                if not bloq.eof then
                                %>
                                <script >
                                <%
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
                                $( ".pl<%=ProfissionalID%>" ).each(function(){
                                    if( $(this).attr("data-id")>='<%=HoraDe%>' && $(this).attr("data-id")<'<%=HoraA%>' )
                                    {
                                        $(this).replaceWith('<%= conteudo %>');
                                    }
                                });
                                $( ".pl<%=ProfissionalID%> .btn-comp" ).each(function(){
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
                                <%
                                end if
                            end if
                        Horarios.movenext
                        wend
                        Horarios.close
                        set Horarios=nothing
                        %>
                          </tbody>
                      </table>
                        <%
                    end if
                  %>



                <script type="text/javascript">
                <%
                set comps=db.execute("select a.id, a.Data, a.Hora, a.LocalID, a.ProfissionalID, a.StaID, a.FormaPagto, a.Encaixe, a.Tempo, p.NomePaciente, pro.NomeProfissional, pro.Cor, proc.NomeProcedimento, proc.Cor CorProcedimento from agendamentos a "&_
                "left join pacientes p on p.id=a.PacienteID "&_ 
                "left join profissionais pro on pro.id=a.ProfissionalID "&_ 
                "left join procedimentos proc on proc.id=a.TipoCompromissoID "&_ 
                "where a.LocalID="&LocalID&" and a.sysActive=1 and a.Data="&mydatenull(Data)&"order by Hora")
                while not comps.EOF
                    HoraComp = HoraToID(comps("Hora"))
                    compsHora = comps("Hora")
                    FormaPagto = comps("FormaPagto")
					if not isnull(compsHora) then
						compsHora = formatdatetime(compsHora, 4)
					end if

					'->hora final
					if not isnull(comps("Tempo")) and comps("Tempo")<>"" and isnumeric(comps("Tempo")) then
						Tempo = ccur(comps("Tempo"))
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


					    Conteudo = "<tr title="""&replace(comps("NomeProcedimento")&" ", "'", "\'")&" \n "&replace(comps("NomeProfissional")&" ", "'", "\'")&""" id="""&HoraComp&""" onclick=""abreAgenda(\'"&HoraComp&"\', "&comps("id")&", \'"&comps("Data")&"\', \'"&comps("LocalID")&"\', \'"&comps("ProfissionalID")&"\')""><td width=""1%"" style=""background-color:"&comps("Cor")&"""></td><td width=""1%"" style=""background-color:"&CorProcedimento&"!important""><button type=""button"" class=""btn btn-xs btn-warning"">"&compsHora&"</button></td><td nowrap><img src=""assets/img/"&comps("StaID")&".png""> "
					if comps("Encaixe")=1 then
						Conteudo = Conteudo & "<span class=""label label-pink label-sm arrowed-in arrowed-in-right"">encaixe</span>"
					end if
					Conteudo = Conteudo & "<span class=""nomePac"">"&replace(comps("NomePaciente")&" ", "'", "\'")&"</span>  <span class=""pull-right"">"& sinalAgenda(FormaPagto) &"</span> </td></tr>"
                %>
                $( ".l<%=LocalID%>" ).each(function(){

                    var Status = '<%=comps("StaID")%>';
                    if( $(this).attr("data-id")=='<%=HoraComp%>' && Status !== "11")
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
                    $( ".l<%=LocalID%>" ).each(function(){
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
    %>
    </script>

              </td>


<%
loc.movenext
wend
loc.close
set loc=nothing

if cLoc=1 and ref("filtroProcedimentoID")<>"" then
    %>
    <script type="text/javascript">
    $("#LocalPre").val("<%=LocalID %>");
    </script>
    <%
end if
%>
