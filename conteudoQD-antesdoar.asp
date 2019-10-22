<!--#include file="connect.asp"-->
<div class="row">
<table width="100%" border="0">
    <tr>
    <%
    existemQuadros="N"
    set pUs=db.execute("select QuadrosAbertos from sys_users where id="&session("User"))
    if isnull(pUs("QuadrosAbertos")) then varCheck2=" " else varCheck2=pUs("QuadrosAbertos") end if
    valor2=split(varCheck2,", ")
    for i=0 to uBound(valor2)
        set pLoc=db.execute("select * from Locais where id = '"&valor2(i)&"'")
        if not pLoc.EOF then
          if (instr(session("Unidades"), "|0|")>0 or instr(session("Unidades"), "|"&pLoc("UnidadeID")&"|")>0) then
             %>
             <td valign="top">
             <table class="table table-striped table-condensed table-hover" width="100%">
                 <thead>
                    <tr>
                        <th colspan="3" style="min-width:200px" class="text-center">
							<i title="Configura&ccedil;&otilde;es do Local" alt="Configura&ccedil;&otilde;es do Local" style="cursor:pointer" onClick="location.href='?P=EdiProfQD&Pers=1&LId=<%=pLoc("id")%>&Data=<%=Data%>';" class="fa fa-cog"></i> 
							<%=left(ucase(pLoc("NomeLocal")),18)%>
   							<i title="Fechar" alt="Fechar" style="cursor:pointer" onClick="location.href='?P=QuadroDisponibilidade&Pers=1&Rx=<%=pLoc("id")%>&Data=<%=Data%>';" class="fa fa-remove"></i> 

                        </th>
                    </tr>
                 </thead>
                 <tbody>
                    <tr class="hidden l<%=LocalID%>" id="0000"></tr>
                 <%
                    LocalID = pLoc("id")
                    DiaSemana = weekday(Data)
                    Hora = cdate("00:00")
                    set Horarios = db.execute("select ass.*, pro.NomeProfissional, pro.Cor from assfixalocalxprofissional ass LEFT JOIN profissionais pro on pro.id=ass.ProfissionalID where ass.LocalID="&LocalID&" and ass.DiaSemana="&DiaSemana&" order by ass.HoraDe")
                    while not Horarios.EOF
                        %>
                        <tr>
                            <td colspan="3" nowrap class="nomeProf" style="background-color:<%=Horarios("Cor")%>">
								 <%=left(ucase(Horarios("NomeProfissional")&" "), 20)%>
                            </td>
                        </tr>
                        <%
                        Intervalo = Horarios("Intervalo")
                        if isnull(Intervalo) then
                            Intervalo = 30
                        end if
                        HoraDe = cdate(Horarios("HoraDe"))
                        HoraA = cdate(Horarios("HoraA"))
                        ProfissionalID = Horarios("ProfissionalID")
                        if isnull(ProfissionalID) then
                            ProfissionalID = 0
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
                                        <i class="fa fa-chevron-left"></i> Agendar Aqui
                                    </button>
                                </td>
                            </tr>
                            <%
                            elseif session("RemSol")<>"" then
                            %>
                            <tr class="l<%=LocalID%> vazio" data-hora="<%=formatdatetime(Hora, 4)%>" data-id="<%=HoraID%>" id="<%=LocalID&"_"&HoraID%>">
                                <td width="1%"></td>
                                <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(Hora,4) %></button></td>
                                <td colspan="4">
                                    <button type="button" onclick="remarcar(<%=session("RemSol")%>, 'Remarcar', '<%=formatDateTime(Hora,4)%>', '<%=LocalID%>', '<%=ProfissionalID%>')" class="btn btn-xs btn-warning">
                                        <i class="fa fa-chevron-left"></i> Agendar Aqui
                                    </button>
                                </td>
                            </tr>
                            <%
                            elseif session("RepSol")<>"" then
                            %>
                            <tr class="l<%=LocalID%> vazio" data-hora="<%=formatdatetime(Hora, 4)%>" data-id="<%=HoraID%>" id="<%=LocalID&"_"&HoraID%>">
                                <td width="1%"></td>
                                <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(Hora,4) %></button></td>
                                <td colspan="4">
                                    <button type="button" onclick="repetir(<%=session("RepSol")%>, 'Repetir', '<%=formatDateTime(Hora,4)%>', '<%=LocalID%>', '<%=ProfissionalID%>')" class="btn btn-xs btn-warning">
                                        <i class="fa fa-chevron-left"></i> Repetir Aqui
                                    </button>
                                </td>
                            </tr>
                            <%
                            else
                            %>
                            <tr onclick="abreAgenda('<%=HoraID%>', 0, '<%=Data%>', <%=LocalID%>, <%=ProfissionalID%>)" class="l<%=LocalID%>" data-prof="<%=ProfissionalID%>" data-id="<%=HoraID%>" id="<%=LocalID&"_"&HoraID%>">
                                <td width="1%" style="background-color:<%=Horarios("Cor")%>"></td>
                                <td width="1%"><button type="button" class="btn btn-xs btn-info"><%= formatdatetime(Hora,4) %></button></td>
                                <td><%= Tipo %></td>
                            </tr>
                            <%
							end if
                            Hora = dateadd("n", Intervalo, Hora)
                        wend
                    Horarios.movenext
                    wend
                    Horarios.close
                    set Horarios=nothing
                  %>
                  </tbody>
              </table>
                <script>
                <%
                set comps=db.execute("select a.id, a.Data, a.Hora, a.LocalID, a.ProfissionalID, a.StaID, a.Encaixe, p.NomePaciente, pro.NomeProfissional, pro.Cor from agendamentos a "&_
                "left join pacientes p on p.id=a.PacienteID "&_ 
                "left join profissionais pro on pro.id=a.ProfissionalID "&_ 
                "where a.LocalID="&LocalID&" and a.Data="&mydatenull(Data)&"order by Hora")
                while not comps.EOF
                    HoraComp = HoraToID(comps("Hora"))
					compsHora = comps("Hora")
					if not isnull(compsHora) then
						compsHora = formatdatetime(compsHora, 4)
					end if
                    Conteudo = "<tr alt="""&replace(comps("NomeProfissional")&" ", "'", "\'")&""" id="""&HoraComp&""" onclick=""abreAgenda(\'"&HoraComp&"\', "&comps("id")&", \'"&comps("Data")&"\', \'"&comps("LocalID")&"\', \'"&comps("ProfissionalID")&"\')""><td width=""1%"" style=""background-color:"&comps("Cor")&"""></td><td width=""1%""><button type=""button"" class=""btn btn-xs btn-warning"">"&compsHora&"</button></td><td nowrap><img src=""assets/img/"&comps("StaID")&".png""> "
					if comps("Encaixe")=1 then
						Conteudo = Conteudo & "<span class=""label label-pink label-sm arrowed-in arrowed-in-right"">encaixe</span>"
					end if
					Conteudo = Conteudo & "<span class=""nomePac"">"&replace(comps("NomePaciente")&" ", "'", "\'")&"</span></td></tr>"
                %>
                $( ".l<%=LocalID%>" ).each(function(){
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
                comps.movenext
                wend
                comps.close
                set comps = nothing
                %>
                </script>
              </td>
              <%
          end if
        end if
    next
    if chamaQuadros<>"" then
        chamaQuadros=replace(chamaQuadros,locUlt,"S")
    end if
    %>
    </tr>
</table>
</div>