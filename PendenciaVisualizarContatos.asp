<!--#include file="connect.asp"-->
<%
PendenciaProcedimentoID=req("PendenciaProcedimentoID")
ProfissionalID=req("ProfissionalID")
%>
<div class="row">
    <div class="col-md-12">
        <table class="table table-striped">
            <thead>
                <tr>
                    <th>Usuário</th>
                    <th>Data do contato</th>
                    <th>Contato</th>
                    <th>Observações</th>
                    <th>Status</th>
                    <th>Data do agendamento</th>
                    <th>Valor</th>
                </tr>
            </thead>
            <tbody>
                <%
                set ContatosSQL = db.execute("SELECT ce.*, es.NomeStatus, es.Classe FROM pendencia_contatos_executantes ce LEFT JOIN cliniccentral.pendencia_executante_status es ON es.id=ce.StatusID WHERE  PendenciaProcedimentoID="&PendenciaProcedimentoID&" AND ExecutanteID="&ProfissionalID&" ORDER BY ce.sysDate DESC")
                if not ContatosSQL.eof then
                    while not ContatosSQL.eof

                        Hora = ""

                        usuario = nameInTable(ContatosSQL("sysUser"))

                        if ContatosSQL("Hora") <> "" then

                            splHora = split(ContatosSQL("Hora")," ")
                            Hora = splHora(1)

                        end if

                        %>
                        <tr class="<%=ContatosSQL("Classe")%> linha-executor" data-id="<%=ExecutanteID%>">
                            <td><%=usuario%></td>
                            <td><%=ContatosSQL("sysDate")%></td>
                            <td><%=ContatosSQL("Contato")%></td>
                            <td><%=ContatosSQL("Observacoes")%></td>
                            <td><%=ContatosSQL("NomeStatus")%></td>
                            <td><%=ContatosSQL("Data")&" "&Hora%></td>
                            <td><%=fn(ContatosSQL("Valor"))%></td>
                        </tr>
                        <%
                    ContatosSQL.movenext
                    wend
                    ContatosSQL.close
                    set ContatosSQL=nothing
                else
                %>
                <tr>
                    <td colspan="7">Nenhum contato realizado</td>
                </tr>
                <% end if %>
            </tbody>
        </table>
    </div>
</div>