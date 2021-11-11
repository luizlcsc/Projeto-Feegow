<!--#include file="./../../connect.asp"-->
<!--#include file="AuditoriaUtils.asp"-->
<%

ItemID = req("ItemID")


set ItemAuditoriaSQL = db.execute("SELECT ai.StatusID, ai.Detalhes, a.SQLRegistro, u.NomeFantasia, lu.Nome Usuario, ai.id,ai.RegistroID,ai.AuditoriaEventoID, a.Descricao EventoAuditoria, ai.Data, ai.Hora, ai.Explanacao, ai.sysUser "&_
                    "FROM auditoria_itens ai "&_
                    "LEFT JOIN vw_unidades u ON u.id=ai.UnidadeID "&_
                    "LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=ai.sysUser "&_
                    "INNER JOIN cliniccentral.auditoria_eventos a ON a.id=ai.AuditoriaEventoID "&_
                    "WHERE ai.id="&ItemID)


if not ItemAuditoriaSQL.eof then
    StatusID = ItemAuditoriaSQL("StatusID")
    NotasAuditoria = ItemAuditoriaSQL("Explanacao")
    %>
    <div class="row">
        <div class="col-md-12">
            <br>
        </div>
        <div class="col-md-6">
            <strong>Código:</strong> <small>#<%=ItemAuditoriaSQL("id")%></small>  <br>
            <strong>Usuário:</strong> <%=ItemAuditoriaSQL("Usuario")%>  <br>
            <strong>Evento:</strong> <%=ItemAuditoriaSQL("EventoAuditoria")%>  <br>
            <strong>Data:</strong> <%=ItemAuditoriaSQL("Data")%>  <br>
            <strong>Detalhes:</strong> <%=ItemAuditoriaSQL("Detalhes")%>  <br>
            <strong>Hora:</strong> <%=formatdatetime(ItemAuditoriaSQL("Hora"), 4)%>  <br>

            <%=DescricaoRegistro%>  <br>
        </div>
        <div class="col-md-6">
            <strong>Registro:</strong><code>#<%=ItemAuditoriaSQL("RegistroID")%></code> <br>
            <%
            SQLRegistro = ItemAuditoriaSQL("SQLRegistro")
            if not isnull(SQLRegistro) then
                SQLRegistro  = replace(SQLRegistro, "[RegistroID]", ItemAuditoriaSQL("RegistroID"))

                set RegistroSQL = db.execute(SQLRegistro)

                if not RegistroSQL.eof then

                    Valor = RegistroSQL("Valor")
                    if Valor then
                        Valor = "R$ "&fn(Valor)
                    end if
                %>
                <strong>Cliente: </strong> <%=RegistroSQL("Cliente")%> <br>
                <strong>Valor: </strong> <%=Valor%> <br>
                <strong>Detalhes: </strong> <%=RegistroSQL("Detalhes")%> <br>
                <strong>Data original: </strong> <%=RegistroSQL("DataOriginal")%> <br>
                <strong>Executante: </strong> <%=RegistroSQL("Executante")%> <br>
                <%
                    if RegistroSQL("Url")&"" <> "" then
                    %>
                    <a target="_blank" href="<%=RegistroSQL("Url")%>" class="btn btn-sm btn-default mt15"><i class="far fa-external-link"></i> Ver mais </a>
                    <%
                    end if
                end if
            end if
            %>
        </div>
    </div>

    <div class="row">
        <div class="col-md-12">
            <hr class="short alt" />

        </div>
    </div>

    <div class="row">

        <div class="col-md-6">
            <span id="status-item-auditoria"><%=badgeStatusAuditado(ItemAuditoriaSQL("StatusID"))%></span>
            <div class="btn-group ">
                    <button class="btn btn-sm btn-default dropdown-status dropdown-toggle " data-toggle="dropdown" >
                        <span class="label-status">Alterar</span>  <i class="far fa-angle-down icon-on-right"></i>
                    </button>

                    <ul class="dropdown-menu dropdown-danger">
                        <li><a onclick="changeAuditoriaStatus('2', '<%=ItemID%>')" data-value="2" style="cursor:pointer" class="StatusItemAudit">
                                <i class="far fa-check-circle text-success"></i> Marcar como auditado
                            </a>
                        </li>
                        <li><a onclick="changeAuditoriaStatus('3', '<%=ItemID%>')" data-value="3" style="cursor:pointer" class="StatusItemAudit">
                                <i class="far fa-question-circle"></i> Marcar como ignorado
                            </a>
                        </li>
                        <li><a onclick="changeAuditoriaStatus('4', '<%=ItemID%>')" data-value="4" style="cursor:pointer" class="StatusItemAudit">
                                <i class="far fa-exclamation-circle text-danger"></i> Marcar como suspeito
                            </a>
                        </li>
                        <li><a onclick="changeAuditoriaStatus('1', '<%=ItemID%>')" data-value="1" style="cursor:pointer" class="StatusItemAudit">
                                <i class="far fa-clock text-warning"></i> Marcar como pendente
                            </a>
                        </li>
                    </ul>
                </div>
        </div>

        <input type="hidden" name="Auditoria_ItemID" value="<%=ItemID%>">
        <input type="hidden" name="Auditoria_StatusID" id="Auditoria_StatusID" value="<%=StatusID%>">
        <input type="hidden" name="Auditoria_Acao" value="E">

        <%=quickField("memo", "Auditoria_Notas", "Notas", 12, NotasAuditoria, "", "", "")%>


    </div>
    <%

    set HistoricoInteracaoSQL = db.execute("SELECT * FROM auditoria WHERE ItemAuditoriaID="&ItemID)

    if not HistoricoInteracaoSQL.eof then
        %>
    <h4>Ações neste item</h4>

    <table class="table table-condensed">
        <tr class="warning">
            <th>Usuário</th>
            <th>Data e hora</th>
            <th>Notas</th>
            <th>Ação</th>
        </tr>
        <%

        while not HistoricoInteracaoSQL.eof
            %>
            <tr>
                <td><%=HistoricoInteracaoSQL("sysUser")%></td>
                <td><%=HistoricoInteracaoSQL("sysDate")%></td>
                <td><%=HistoricoInteracaoSQL("Notas")%></td>
                <td><%=HistoricoInteracaoSQL("Acao")%></td>
            </tr>
            <%
        HistoricoInteracaoSQL.movenext
        wend
        HistoricoInteracaoSQL.close
        set HistoricoInteracaoSQL=nothing

        %>
        </table>
        <%
    end if
end if

%>