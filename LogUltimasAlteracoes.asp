<!--#include file="connect.asp"-->
<%
'tabelas separado por virgula
Tabelas = req("Tabelas")

TabelasParametro = "'"&replace(Tabelas, "," ,  "','")&"'"

set RecursosSQL = db.execute("SELECT name,sqlLog, tableName FROM cliniccentral.sys_resources WHERE tableName in ("&TabelasParametro&")")

while not RecursosSQL.eof
    recurso = RecursosSQL("tableName")
    sqlLog = RecursosSQL("sqlLog")
    if sqlLog<>"" then
    %>
    <h4><%=RecursosSQL("name")%></h4>
    <hr style="margin-top: 0">
    <%

        set UltimasAlteracoesLogSQL = db.execute(sqlLog)

        if not UltimasAlteracoesLogSQL.eof then
            %>
<table class="table">
    <tr class="success">
        <th>#</th>
        <th>Usuário</th>
        <th>Data e hora</th>
        <th>Operação</th>
        <th>Obs.</th>
        <th>Descrição</th>
        <th></th>
    </tr>
    <%
    while not UltimasAlteracoesLogSQL.eof
        %>
        <tr>
            <td><code>#<%=UltimasAlteracoesLogSQL("id")%></code></td>
            <td><%=UltimasAlteracoesLogSQL("Usuario")%></td>
            <td><%=UltimasAlteracoesLogSQL("DataHora")%></td>
            <td><%=UltimasAlteracoesLogSQL("Operacao")%></td>
            <td><%=UltimasAlteracoesLogSQL("Obs")%></td>
            <td><%=UltimasAlteracoesLogSQL("Descricao")%></td>
            <td><button onclick="seeLogDetails('<%=UltimasAlteracoesLogSQL("I")%>','<%=recurso%>')" class="btn btn-primary btn-xs" type="button"><i class="fa fa-expand"></i></button></td>
        </tr>
        <%
    UltimasAlteracoesLogSQL.movenext
    wend
    UltimasAlteracoesLogSQL.close
    set UltimasAlteracoesLogSQL=nothing
    %>
</table>
            <%
        else
        %>
        Nenhum log registrado.
        <%
        end if
    end if

RecursosSQL.movenext
wend
RecursosSQL.close
set RecursosSQL=nothing
%>
<script >
    function seeLogDetails(id, resource) {
        closeComponentsModal();

        setTimeout(function() {
            openComponentsModal("DefaultLog.asp", {
                I: id,
                R: resource,
                Impressao: 1
            }, "Log de alterações", true);
        }, 700);
    }
</script>