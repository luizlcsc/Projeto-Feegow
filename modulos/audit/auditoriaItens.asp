<!--#include file="./../../connect.asp"-->
<!--#include file="AuditoriaUtils.asp"-->
<div class="panel m10">
    <div class="panel-heading">
        <span class="panel-title">
            Resultado da busca
        </span>
        <span class="panel-controls">

            <button type="button" style="display: none" class="btn btn-sm btn-success" id="marcarAuditado" onclick="marcarAuditado()"><i class="far fa-check"></i> Marcar como auditado</button>
        </span>
    </div>
    <div class="panel-body">

<%
Unidades = ref("Unidades")
if Unidades = "" then
    Unidades = session("Unidades")
end if

Status = ref("StatusAuditoria")
Status = replace(Status, "|", "")

Eventos = ref("Eventos")
Eventos = replace(Eventos, "|", "")

Unidades = replace(Unidades, "|", "")

if Status="" or Unidades="" or Eventos="" then
    %>
    Preencha os filtros.
    <%
    Response.End
end if

sql = "SELECT ai.StatusID, u.NomeFantasia, lu.Nome Usuario, ai.id,ai.RegistroID,ai.AuditoriaEventoID, a.Descricao EventoAuditoria, ai.Data, ai.Hora, ai.Explanacao, ai.sysUser "&_
                          "FROM auditoria_itens ai "&_
                          "LEFT JOIN vw_unidades u ON u.id=ai.UnidadeID "&_
                          "LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=ai.sysUser "&_
                          "INNER JOIN cliniccentral.auditoria_eventos a ON a.id=ai.AuditoriaEventoID "&_
                          "WHERE Data BETWEEN "& mydatenull(ref("De")) &" AND "& mydatenull(ref("Ate")) &" AND ai.StatusID IN ("&Status&")  AND a.id IN ("&Eventos&") AND UnidadeID IN("& Unidades &") ORDER BY a.id, ai.Data, ai.Hora LIMIT 200"
set ListaAuditoriaSQL = db.execute(sql)

if not ListaAuditoriaSQL.eof then

    %>
    <table class="table">
        <thead>
            <tr class="primary">
                <th></th>
                <th>id</th>
                <th>Status</th>
                <th>Unidade</th>
                <th>Usuário</th>
                <th>Registro</th>
                <th>Data</th>
                <th>Hora</th>
                <th>Ações</th>
            </tr>
        </thead>

        <tbody>
    <%
    while not ListaAuditoriaSQL.eof
        novoBloco = 0
        if ultAI<>ListaAuditoriaSQL("AuditoriaEventoID") then
            novoBloco = 1
            %>
            <tr class="dark">
                <td>
                    <div class="hidden checkbox-custom checkbox-default mb5">
                        <input type="checkbox" name="allAuditoria<%=ListaAuditoriaSQL("AuditoriaEventoID")%>" id="allAuditoria<%=ListaAuditoriaSQL("AuditoriaEventoID")%>" onclick="selecionarItens('<%=ListaAuditoriaSQL("AuditoriaEventoID")%>', $(this).prop('checked'))" />
                        <label for="allAuditoria<%=ListaAuditoriaSQL("AuditoriaEventoID")%>"></label>
                    </div>
                </td>
                <td colspan="8"><center><i class="far fa-info-circle"></i> <%=ListaAuditoriaSQL("EventoAuditoria")%></center></td>
            </tr>
            <%
        end if
        ultAI= ListaAuditoriaSQL("AuditoriaEventoID")
        %>

            <tr>
                <td>
                    <div class="hidden checkbox-custom checkbox-default mb5">
                        <input data-evento="<%=ListaAuditoriaSQL("AuditoriaEventoID")%>" onclick="refetchSelectedItems()" type="checkbox" class="item-auditoria" name="Item" id="ckAuditoria<%=ListaAuditoriaSQL("id") %>" value="<%=ListaAuditoriaSQL("id") %>" />
                        <label for="ckAuditoria<%=ListaAuditoriaSQL("id") %>">
                        </label>
                    </div>
                </td>
                <td><code>#<%=ListaAuditoriaSQL("id")%></code></td>
                <td>
                    <%=badgeStatusAuditado(ListaAuditoriaSQL("StatusID"))%>
                </td>
                <td><%=ListaAuditoriaSQL("NomeFantasia")%></td>
                <td><%=ListaAuditoriaSQL("Usuario")%></td>
                <td><%=ListaAuditoriaSQL("RegistroID")%></td>
                <td><%=ListaAuditoriaSQL("Data")%></td>
                <td><%=formatdatetime(ListaAuditoriaSQL("Hora"), 4)%></td>
                <td>
                    <button onclick="ExibirDetalhesAuditoria('<%=ListaAuditoriaSQL("id")%>')" title="Ver detalhes" data-toggle="tooltip" type="button" class="btn btn-xs btn-primary">
                        <i class="far fa-search"></i>
                    </button>

                </td>
            </tr>
        <%
    ListaAuditoriaSQL.movenext
    wend
    ListaAuditoriaSQL.close
    set ListaAuditoriaSQL = nothing
    %>
        </tbody>
    </table>
    <%
else
    %>
    Nenhum item a auditar encontrado.
    <%
end if
%>

    </div>
</div>