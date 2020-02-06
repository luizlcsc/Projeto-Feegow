<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<%
'tabelas separado por virgula
Tabelas = req("Tabelas")
ID = req("ID")
PaiID = req("PaiID")
TipoPai = req("TipoPai")

TabelasParametro = "'"&replace(Tabelas, "," ,  "','")&"'"

set RecursosSQL = db.execute("SELECT name,sqlLog, tableName FROM cliniccentral.sys_resources WHERE tableName in ("&TabelasParametro&")")

while not RecursosSQL.eof
    recurso = RecursosSQL("tableName")
    name = RecursosSQL("name")

    %>
    <h4><%=name%></h4>
    <hr style="margin-top: 0">
    <%
    set LogsSQL = getLogs(recurso, ID, PaiID)

    call getLogTableHtml(LogsSQL)

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