<!--#include file="../../connect.asp"-->
<%

linhas = ref("linhas[]")
linhas = split(linhas, ", ")

Motivo = ref("motivo")
TabelaPrecoID = ref("tabela_preco_id")

db_execute("INSERT INTO solicitacao_tabela_preco (TabelaPrecoID, Descricao, UnidadeID, sysUser) VALUES ("&TabelaPrecoID&", '"&Motivo&"', "&session("UnidadeID")&","&session("User")&")")

SolicitacaoID = getLastAdded("solicitacao_tabela_preco")

procedimentosAlterados = 0
for i=0 to ubound(linhas)
    linha = linhas(i)

    nome_procedimento = ref("alteracoes["&i&"][nome]")
    procedimento_id = ref("alteracoes["&i&"][procedimento_id]")
    valorAnterior = ccur(ref("alteracoes["&i&"][valor_anterior]"))
    valorProposto = ccur(ref("alteracoes["&i&"][valor_proposto]"))

    
    diferenca = valorProposto - valorAnterior

    if valorAnterior<>valorProposto then
        procedimentosAlterados = procedimentosAlterados + 1
    
    end if

    db_execute("INSERT INTO solicitacao_tabela_preco_procedimentos (SolicitacaoID, ProcedimentoID, valorAnterior, valorProposto) "&_
    " VALUES ("&treatvalzero(SolicitacaoID)&", "&treatvalzero(procedimento_id)&", "&treatvalzero(valorAnterior)&", "&treatvalzero(valorProposto)&")")
next
%>