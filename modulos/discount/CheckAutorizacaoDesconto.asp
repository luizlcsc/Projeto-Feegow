<!--#include file="./../../connect.asp"-->
<%

SolicitacaoID = req("SolicitacaoID")

set SolicitacaoSQL = db_execute("SELECT Status,Desconto FROM descontos_pendentes WHERE id="&SolicitacaoID)

if not SolicitacaoSQL.eof then
    if SolicitacaoSQL("Status")<>1 then
        response.write("PENDENTE")
        response.end
    elseif SolicitacaoSQL("Status")=1 then
        response.write("APROVADO")
        response.end
    end if
end if
%>