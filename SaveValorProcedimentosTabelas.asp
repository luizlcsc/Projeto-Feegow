<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<%

IF ref("procedimentoId") <> "" AND ref("tabelaID") <> "" AND ref("tipo") <> "" THEN
    set ProcedimentoTabela = db.execute("SELECT id FROM procedimentostabelasvalores WHERE TabelaID = "&ref("tabelaID")&" AND ProcedimentoID = "&ref("procedimentoId"))
    LogDetalhe          = ""
    ProcedimentoValorID = "0"
    ProcedimentoID      = ref("procedimentoId")
    TabelaID            = ref("tabelaID")
    Campo               = ref("tipo")
    ValorTabela         = ref("valor")

    IF not ProcedimentoTabela.EOF THEN
        ProcedimentoValorID = ProcedimentoTabela("id")
    END IF

    IF ProcedimentoValorID = "0" THEN
        sqlProcedimento = "INSERT INTO procedimentostabelasvalores (ProcedimentoID, TabelaID, "&Campo&") VALUES ("& ProcedimentoID &", "& TabelaID &","&treatvalzero(ValorTabela)&")"
        descricaoLog    =  "Valor do procedimento na tabela adicionado"&LogDetalhe
    END IF

    IF ProcedimentoValorID <> "0" THEN
        sqlProcedimento = "UPDATE procedimentostabelasvalores SET "&Campo&"="&treatvalzero(ValorTabela)&" WHERE TabelaID="&TabelaID&" AND ProcedimentoID = "&ProcedimentoID&" "
        descricaoLog    = "Valor do procedimento na tabela alterada"&LogDetalhe
    END IF

    db.execute(sqlProcedimento)
    call gravaLogs(sqlProcedimento ,"AUTO", "Valor do procedimento na tabela alterada"&LogDetalhe,"TabelaID")

    db.execute("DELETE FROM procedimentostabelasvalores WHERE Valor = 0")
    call gravaLogs(sqlProcedimento ,"AUTO", "Valor do procedimento na tabela alterada"&LogDetalhe,"TabelaID")

END IF

%>