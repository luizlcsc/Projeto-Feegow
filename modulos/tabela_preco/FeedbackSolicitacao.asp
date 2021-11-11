<!--#include file="../../connect.asp"-->
<%

Feedback = ref("feedback")
solicitacao_id = ref("solicitacao_id")

set SolicitacaoSQL = db_execute("SELECT * FROM solicitacao_tabela_preco WHERE id="&solicitacao_id)

if Feedback = "APROVAR" then
    TabelaPrecoID = SolicitacaoSQL("TabelaPrecoID")

    valorProposto = SolicitacaoSQL("TabelaPrecoID")

    set ProcedimentosSQL = db_execute("SELECT tpp.* FROM solicitacao_tabela_preco_procedimentos tpp WHERE SolicitacaoID="&solicitacao_id)

    while not ProcedimentosSQL.eof
        ProcedimentoID = ProcedimentosSQL("ProcedimentoID")
        ValorProposto = ProcedimentosSQL("ValorProposto")
        ValorAnterior = ProcedimentosSQL("ValorAnterior")

        db_execute("UPDATE procedimentostabelasvalores SET Valor="&treatvalzero(ValorProposto)&_
        " WHERE ProcedimentoID="&ProcedimentoID&" AND Valor="&ValorAnterior&" AND TabelaID="&TabelaPrecoID)

    ProcedimentosSQL.movenext
    wend
    ProcedimentosSQL.close
    set ProcedimentosSQL=nothing

    NovoStatus = "APROVADO"

end if

if Feedback = "REJEITAR" then
    NovoStatus = "REJEITADO"
end if

db_execute("UPDATE solicitacao_tabela_preco SET Status='"&NovoStatus&"' WHERE id="&solicitacao_id)

%>OK