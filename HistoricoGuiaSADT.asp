<!--#include file="connect.asp"-->
<%
GuiaID=req("GuiaID")
set GuiaLogSQL = db.execute("SELECT * FROM tissprocedimentossadt_log WHERE GuiaID="&GuiaID)

%>

<div class="row">
    <div class="col-md-12">
    <%
    if not GuiaLogSQL.eof then
    %>
        <table class="table table-bordered">
            <thead>
                <tr>
                    <th>Data</th>
                    <th>Usuário</th>
                    <th>Inicio</th>
                    <th>Fim</th>
                    <th>Tabela</th>
                    <th>Descrição</th>
                    <th>Qtd</th>
                    <th>Fator</th>
                    <th>Valor total</th>
                    <th>Observações</th>
                </tr>
            </thead>
            <tbody>
                <%
                while not GuiaLogSQL.eof

                    HoraInicio = GuiaLogSQL("HoraInicio")
                    HoraFim = GuiaLogSQL("HoraFim")

                    if HoraInicio<>"" then
                        HoraInicio=formatdatetime(HoraInicio,4)
                    end if
                    if HoraFim<>"" then
                        HoraFim=formatdatetime(HoraFim,4)
                    end if


                    %>
                    <tr>
                        <td><%=GuiaLogSQL("sysDate")%></td>
                        <td><%=nameInTable(GuiaLogSQL("sysUser"))%></td>
                        <td><%=HoraInicio%></td>
                        <td><%=HoraFim%></td>
                        <td><%=GuiaLogSQL("TabelaID")%></td>
                        <td><%=GuiaLogSQL("Descricao")%></td>
                        <td><%=GuiaLogSQL("Quantidade")%></td>
                        <td><%=GuiaLogSQL("Fator")%></td>
                        <td><%=GuiaLogSQL("ValorTotal")%></td>
                        <td><%=GuiaLogSQL("Obs")%></td>
                    </tr>
                    <%
                GuiaLogSQL.movenext
                wend
                GuiaLogSQL.close
                set GuiaLogSQL=nothing
                %>
            </tbody>
        </table>
    <%
    else
    %>
        Não há logs registrados para essa guia.
    <%
    end if
    %>
    </div>
</div>