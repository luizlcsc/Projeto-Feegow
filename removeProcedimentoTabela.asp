<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->

<%

idTabela = ref("idTabela")
idProcedimento = ref("idProcedimento")


sqlDel = "delete from procedimentostabelasvalores WHERE TabelaID="&idTabela&" AND ProcedimentoID="&idProcedimento

call gravaLogs(sqlDel ,"AUTO", "Valor do procedimento na tabela removido","TabelaID")
db.execute(sqlDel)

response.write("ok")

%>