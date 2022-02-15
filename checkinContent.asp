<!--#include file="connect.asp"-->
<div class="panel-body">
    <div class="table-responsive" style="overflow-y: scroll">

    <table id="datatable2" class="table table-hover table-striped table-bordered table-condensed">
        <thead>
            <tr>
                <th width="1%"></th>
                <th>Agendado</th>
                <th>Chegada</th>
                <th>Paciente</th>
                <th>Profissional</th>
                <th>Especialidade</th>
                <th>Procedimento</th>
                <th>Local</th>
                <th>Equipamento</th>
                <th>Tabela</th>
                <th>Valor/Convênio</th>
                <th width="1%"></th>
            </tr>
        </thead>
        <tbody>
            <%
            StatusSelecionados = ref("fStaID")
            if StatusSelecionados <> "|1|, |4|, |5|, |7|, |15|, |101|" then
                session("StatusCheckin") = StatusSelecionados
            end if

            if ref("fStaID")<>"" then
                sqlSta = " AND a.StaID IN("& replace(StatusSelecionados, "|", "") &") "
            end if
            if ref("fProfissionalID")<>"0" then
                sqlProf = " AND a.ProfissionalID IN ("& ref("fProfissionalID") &") "
            end if
            if ref("fNomePaciente")<>"" then
                if inStr(ref("fNomePaciente"),"#") then
                    sqlPac = " AND (pac.Matricula1 ='"&replace(ref("fNomePaciente"),"#","")&"') "
                else
                    sqlPac = " AND (pac.NomePaciente LIKE '%"& replace(ref("fNomePaciente"), " ", "%") &"%') "                    
                end if
            end if
            if req("PacienteID") <> "" then
                sqlPac = " AND pac.id = "&req("PacienteID")
            end if
            if session("UnidadeID")<>"" then
                sqlUnidade=" AND (l.UnidadeID="&session("UnidadeID")&" OR a.LocalID=0)"
            end if

            set ag = db.execute("select a.id, a.ProfissionalID, a.LocalID, a.StaID, s.StaConsulta, a.Hora,a.HoraSta, pac.NomePaciente, pac.NomeSocial NomeSocialPaciente, if(isnull(pro.NomeSocial) or pro.NomeSocial='', pro.NomeProfissional, pro.NomeSocial) NomeProfissional, esp.Especialidade, proc.NomeProcedimento, l.Nomelocal, eq.NomeEquipamento, a.rdValorPlano, a.ValorPlano, conv.NomeConvenio, tab.NomeTabela, a.ValorPlano+(select if(rdValorPlano = 'V', ifnull(sum(ValorPlano),0),0) from agendamentosprocedimentos where agendamentosprocedimentos.agendamentoid = a.id) as ValorPlano FROM agendamentos a LEFT JOIN staconsulta s ON a.StaID=s.id LEFT JOIN pacientes pac ON pac.id=a.PacienteID LEFT JOIN profissionais pro ON pro.id=a.ProfissionalID LEFT JOIN especialidades esp ON esp.id=a.EspecialidadeID LEFT JOIN procedimentos proc ON proc.id=a.TipoCompromissoID LEFT JOIN locais l ON l.id=a.LocalID LEFT JOIN equipamentos eq ON eq.id=a.EquipamentoID LEFT JOIN convenios conv ON conv.id=a.ValorPlano LEFT JOIN tabelaparticular tab ON tab.id=a.TabelaParticularID WHERE a.sysActive=1 AND a.Data=curdate() "& sqlSta & sqlProf & sqlPac & sqlUnidade &" ORDER BY Hora")
            'response.write("select a.id, a.ProfissionalID, a.LocalID, a.StaID, s.StaConsulta, a.Hora,a.HoraSta, pac.NomePaciente, pac.NomeSocial NomeSocialPaciente, if(isnull(pro.NomeSocial) or pro.NomeSocial='', pro.NomeProfissional, pro.NomeSocial) NomeProfissional, esp.Especialidade, proc.NomeProcedimento, l.Nomelocal, eq.NomeEquipamento, a.rdValorPlano, a.ValorPlano, conv.NomeConvenio, tab.NomeTabela FROM agendamentos a LEFT JOIN staconsulta s ON a.StaID=s.id LEFT JOIN pacientes pac ON pac.id=a.PacienteID LEFT JOIN profissionais pro ON pro.id=a.ProfissionalID LEFT JOIN especialidades esp ON esp.id=a.EspecialidadeID LEFT JOIN procedimentos proc ON proc.id=a.TipoCompromissoID LEFT JOIN locais l ON l.id=a.LocalID LEFT JOIN equipamentos eq ON eq.id=a.EquipamentoID LEFT JOIN convenios conv ON conv.id=a.ValorPlano LEFT JOIN tabelaparticular tab ON tab.id=a.TabelaParticularID WHERE a.Data=curdate() "& sqlSta & sqlProf & sqlPac & sqlUnidade &" ORDER BY Hora")
            while not ag.eof
                if ag("rdValorPlano")="V" then
                    if  aut("valordoprocedimentoV")=0 then
                        Convenio = "Particular"
                    else
                        Convenio = "R$ "& fn(ag("ValorPlano"))
                    end if
                else
                    Convenio = ag("NomeConvenio")
                end if

                if ag("StaID")=4 or ag("StaID")=3 or ag("StaID")=5 or ag("StaID")=2 then
                    HoraChegada = ft(ag("HoraSta"))
                else
                    HoraChegada=""
                end if
                if ag("NomeSocialPaciente")&""<>"" then
                    NomeSocialPaciente= "Nome Social: "&ag("NomeSocialPaciente")
                else
                    NomeSocialPaciente = ""
                end if

                %>
                <tr data-id="<%=ag("id")%>">
                    <td>
                    <%
                    statusIcon = imoon(ag("StaID"))

                    StatusSelect = "<div class='btn-group'><button class='btn btn-sm btn-transparent dropdown-toggle' data-toggle='dropdown' aria-expanded='false'  > <span class='label-status'>"&statusIcon&"</span>  <i class='far fa-angle-down icon-on-right'></i></button><ul class='dropdown-menu dropdown-danger'>"
                    set StatusSQL=db.execute("SELECT id, StaConsulta FROM staconsulta WHERE id IN (101,6)")
                    while not StatusSQL.eof
                        Active=""
                        if StatusSQL("id")=ag("StaID") then
                            Active=" active "
                        end if

                        statusIcon = imoon(StatusSQL("id"))

                        StatusSelect = StatusSelect&"<li class='"&Active&"'><a data-value='"&StatusSQL("id")&"' style='cursor:pointer' class='muda-status'>"&statusIcon&" "&StatusSQL("StaConsulta")&"</a></option>"
                    StatusSQL.movenext
                    wend
                    StatusSQL.close
                    set StatusSQL = nothing
                    StatusSelect= StatusSelect&"</div></ul>"

                    response.write(StatusSelect)
                    %>
                    </td>
                    <td><a href="?P=Agenda-1&Pers=1&AgendamentoID=<%=ag("id")%>" target="_blank"><%= ft(ag("Hora")) %></a></td>
                    <td><small><%= HoraChegada %></small></td>
                    <td><%= ag("NomePaciente") %><br /><small><%=NomeSocialPaciente%></small></td>
                    <td><%= ag("NomeProfissional") %></td>
                    <td><%= ag("Especialidade") %></td>
                    <td><small><%= ag("NomeProcedimento") %></small></td>
                    <td><small><%= ag("NomeLocal") %></small></td>
                    <td><%= ag("NomeEquipamento") %></td>
                    <td><small><%= ag("NomeTabela") %></small></td>
                    <td class="text-right"><%= Convenio %></td>
                    <td class="p0">
                        <button style="width: 100%;" id="btn<%= ag("id") %>" class="btn btn-sm <% if ag("StaID")=4 then response.Write(" btn-warning ") else response.write(" btn-system ") end if  %>" type="button" onclick="abreAgenda('<%= replace(ft(ag("Hora"))&"", ":", "") %>', <%= ag("id") %>, '<%= date() %>', '<%= ag("LocalID") %>', '<%= ag("ProfissionalID") %>', '')">
                        <% if ag("StaID")=4 then %>
                        <i class=" far fa-clock-o"></i>
                        <% else %>
                        <i class=" far fa-check"></i>
                        <% end if %>

                            <small> <% if ag("StaID")=4 then response.Write(" AGUARDANDO ") else response.write(" CHECKIN ") end if  %></small></button>
                    </td>
                </tr>
                <%
            ag.movenext
            wend
            ag.close
            set ag = nothing
                %>
        </tbody>
    </table>
    </div>
</div>
<script type="text/javascript">
    <%
    if req("AgendamentoID")<>"" then
        %>
        $('#btn<%= req("AgendamentoID") %>').click();
        <%
    end if
    %>

</script>