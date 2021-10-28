<!--#include file="connect.asp"-->
<%
De = ref("De")
if De="" then De=date() end if
Ate = ref("Ate")
if Ate="" then Ate=date() end if
TipoPedido = ref("TipoPedido")
if TipoPedido="" then TipoPedido="|N|, |S|" end if
%>
<form method="POST">
    <div class="panel">
        <div class="panel-body">
            <%= quickfield("datepicker", "De", "De", 2, De, "", "", "") %>
            <%= quickfield("datepicker", "Ate", "Até", 2, Ate, "", "", "") %>
            <%= quickfield("multiple", "TipoPedido", "Tipo de Pedido", 4, TipoPedido, "select 'N' id, 'Pedido de exame padrão' TipoPedido UNION ALL select 'S', 'Pedido em guia de SP/SADT'", "TipoPedido", "") %>
            <div class="col-md-2">
                <button class="btn btn-block btn-primary mt25" type="submit">Buscar</button>
            </div>
        </div>
    </div>
</form>
<%
if ref("De")<>"" then
    mDe = mydatenull(De)
    mAte = mydatenull(Ate)
    if instr(TipoPedido, "|N|") then
        sqlN = "SELECT pn.PacienteID, pn.Data, 'Normal' TipoPedido, pn.PedidoExame, pacN.NomePaciente FROM pacientespedidos pn INNER JOIN pacientes pacN ON pacN.id=pn.PacienteID WHERE pn.sysActive=1 AND pn.Data BETWEEN "& mDe &" AND "& mAte &" AND pn.sysUser="& session("User") &" "
    end if
    if TipoPedido="|N|, |S|" then
        sqlUnion = " UNION ALL "
    end if
    if instr(TipoPedido, "|S|") then
        sqlS = "SELECT ps.PacienteID, ps.DataSolicitacao Data, 'SP/SADT' TipoPedido, pis.Descricao PedidoExame, pacS.NomePaciente FROM tissguiasadt ps INNER JOIN pacientes pacS ON pacS.id=ps.PacienteID LEFT JOIN tissprocedimentossadt pis ON pis.GuiaID=ps.id WHERE ps.DataSolicitacao BETWEEN "& mDe &" AND "& mAte &" AND ps.ContratadoSolicitanteID="& session("IdInTable") &" "
    end if
    sql = sqlN & sqlUnion & sqlS

    'rw(sql)
    set pex = db.execute(sql)
    %>
    <div class="panel">
        <div class="panel-body">
            <table class="table table-hover table-bordered">
                <thead>
                    <tr>
                        <th>Data</th>
                        <th>Paciente</th>
                        <th>Tipo</th>
                        <th>Exame Solicitado</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    while not pex.eof
                        %>
                        <tr>
                            <td><%= pex("Data") %></td>
                            <td><a href="./?P=Pacientes&Pers=1&I=<%= pex("PacienteID") %>" target="_blank"><%= pex("NomePaciente") %></a></td>
                            <td><%= pex("TipoPedido") %></td>
                            <td><%= pex("PedidoExame") %></td>
                        </tr>
                        <%
                    pex.movenext
                    wend
                    pex.close
                    set pex = nothing
                    %>
                </tbody>
            </table>
        </div>
    </div>
    <%
end if
%>