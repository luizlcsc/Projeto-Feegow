<!--#include file="connect.asp"-->

<div class="page-header">
    <h1>CONTATOS REALIZADOS</h1>
</div>

<form method="post" action="">
    <div class="clearfix form-actions">
        <%=quickfield("datepicker", "De", "De", 2, ref("De"), "input-mask-date", "", "") %>
        <%=quickfield("datepicker", "Ate", "Até", 2, ref("Ate"), "input-mask-date", "", "") %>
        <%=quickfield("users", "Operador", "Operador", 2, ref("Operador"), "", "", "") %>
        <%=quickfield("multiple", "Canal", "Canal", 4, ref("Canal"), "select * from chamadascanais", "NomeCanal", "") %>
        <label>&nbsp;</label><br /><button class="btn btn-sm btn-primary"><i class="far fa-search"></i> Buscar</button>
    </div>
</form>



<%
    if ref("De")<>"" and ref("Ate")<>"" then
        c=0
        if ref("Operador")<>"" then
            sqlOperador = " AND c.sysUserAtend="&ref("Operador")&" "
        end if
        if ref("Canal")<>"" then
            sqlCanal = " AND c.RE IN("& replace(ref("Canal"), "|", "") &") "
        end if
        sql = "select c.*, lu.Nome Operador, p.NomePaciente NomeContato, p.id PacienteID, can.NomeCanal, res.Descricao Resultado, cag.AgendamentoID, recont.Data rData, recont.Hora rHora from chamadas c LEFT JOIN cliniccentral.licencasusuarios lu on lu.id=c.sysUserAtend LEFT JOIN pacientes p on p.id=replace(c.Contato, '3_', '') LEFT JOIN chamadascanais can on can.id=c.RE LEFT JOIN chamadasresultados res on res.id=c.Resultado LEFT JOIN chamadasagendamentos cag on cag.ChamadaID=c.id LEFT JOIN chamadasrecontatar recont on recont.ChamadaOrigemID=c.id WHERE date(c.DataHora) BETWEEN "&mydatenull(ref("De"))&" AND "&mydatenull(ref("Ate")) & sqlOperador & sqlCanal &" ORDER BY DataHora"
        set cham = db.execute(sql)
        if cham.eof then
 '   response.Write(sql)
            %>
            <center><em>Nenhum resultado encontrado.</em></center>
            <%
        else
            %>
            <table width="100%" class="table table-striped table-hover table-condensed">
                <thead>
                    <tr>
                        <th>Data / Hora</th>
                        <th>Operador</th>
                        <th>Contato</th>
                        <th>Canal</th>
                        <th>Motivo</th>
                        <th>Agendamento</th>
                        <th>Recontatar</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        while not cham.eof
                        c=c+1

                        Notas = cham("Notas")
                        if len(Notas)>1 then
                            Notas = "<br/><small>"&Notas&"</small>"
                        end if
                    %>
                    <tr>
                        <td><%=cham("DataHora") %></td>
                        <td><%=cham("Operador") %></td>
                        <td><a href="./?P=pacientes&Pers=1&I=<%=cham("PacienteID") %>" target="_blank"><%=cham("NomeContato") %></a></td>
                        <td><%=cham("NomeCanal") %></td>
                        <td><%=cham("Resultado") & Notas %></td>
                        <td>
                            <%
                                if not isnull(cham("AgendamentoID")) then
                                    set age = db.execute("select p.NomeProfissional, a.Data, a.Hora from agendamentos a LEFT JOIN profissionais p on p.id=a.ProfissionalID where a.id="&cham("AgendamentoID"))
                                    if not age.eof then
                                        %>
                                        <a href="./?P=Agenda-1&Pers=1&AgendamentoID=<%=cham("AgendamentoID") %>" class="btn btn-success btn-xs"><i class="far fa-calendar"></i> <%=age("Data") & " - " & formatdatetime(age("Hora"), 4) %></a>
                                        <%
                                    end if
                                end if
                            %>
                        </td>
                        <td>
                            <%
                                if not isnull("rHora") and isdate(cham("rHora")) and isdate(cham("rData")) then
                                    %>
                                    <%=cham("rData") &" - "& formatdatetime(cham("rHora"), 4) %>
                                    <%
                                end if
                            %>
                        </td>
                    </tr>
                    <%
                        cham.movenext
                        wend
                        cham.close
                        set cham=nothing
                    %>
                </tbody>
            </table>
            <%=c %> registros encontrados.
            <%
        end if
    end if
%>