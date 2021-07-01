<!--#include file="connect.asp"-->

<%
id              = ref("id")
ConvenioID      = ref("ConvenioID")
ProdutoID       = ref("ProdutoID")
ProdutoTabelaID = ref("ProdutoTabelaID")
TabelaID        = ref("TabelaID")
Codigo          = ref("Codigo")
FormaCobranca   = ref("FormaCobranca")
Descricao       = ref("Descricao")
Valor           = ref("Valor")
NaoCobre        = ref("NaoCobre")

if NaoCobre <> "1" then
    NaoCobre = 0
end if


if ConvenioID = "" or ProdutoID = "" or TabelaID = "" or Codigo = "" then
    response.write("Parâmetros obrigatórios não informados")
    response.status = 422
    response.end
end if

if id <> "" and ProdutoTabelaID = "" then
    response.write("Parâmetros inválidos")
    response.status = 422
    response.end
end if

' insere
if ProdutoTabelaID = "" then
    sqlProdutoTabela = "INSERT INTO tissprodutostabela (Codigo, ProdutoID, TabelaID, Valor, sysActive, sysUser) VALUES " &_
                       "('" & Codigo & "', '" & ProdutoID & "', '" & TabelaID & "', " & treatValZero(Valor) & ", 1, '" & session("User") & "')"
    db.execute(sqlProdutoTabela)
    db.execute("SET @ProdutoTabelaID = LAST_INSERT_ID();")

    sqlProdutosValores = "INSERT INTO tissprodutosvalores (ProdutoTabelaID, ConvenioID, Valor, Descricao, NaoCobre, FormaCobranca) VALUES " &_
                         "(@ProdutoTabelaID, '" & ConvenioID & "', " & treatValZero(Valor) & ", '" & Descricao & "', '" & NaoCobre & "', '" & FormaCobranca & "')"
    db.execute(sqlProdutosValores)

' atualiza a tabela e insere ou atualiza a exceção
else
    sqlProdutoTabela = "UPDATE tissprodutostabela SET Codigo = '" & Codigo & "', TabelaID = '" & TabelaID & "', sysUser = '" & session("User") & "' WHERE id = '" & ProdutoTabelaID & "'"
    db.execute(sqlProdutoTabela)

    if id = "" then
        sqlProdutosValores = "INSERT INTO tissprodutosvalores (ProdutoTabelaID, ConvenioID, Valor, Descricao, NaoCobre, FormaCobranca) VALUES " &_
                         "('" & ProdutoTabelaID & "', '" & ConvenioID & "', " & treatValZero(Valor) & ", '" & Descricao & "', '" & NaoCobre & "', '" & FormaCobranca & "')"
    db.execute(sqlProdutosValores)
    else
        sqlProdutosValores = "UPDATE tissprodutosvalores SET Valor = " & treatValZero(Valor) & ", Descricao = '" & Descricao & "', NaoCobre = '" & NaoCobre & "', FormaCobranca = '" & FormaCobranca & "' WHERE id = '" & id & "'"
        db.execute(sqlProdutosValores)
    end if
end if

response.write("OK")

%>
