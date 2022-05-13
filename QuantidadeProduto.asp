<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->
<%
EstoquePosicaoID = ref("EstoquePosicaoID")

sqlLote = " SELECT TipoUnidade, ApresentacaoNome, replace(format(ApresentacaoQuantidade,2),'.',',') ApresentacaoQuantidade, lower(MID(Descricao, 7 , 50)) Descricao  "&_
" FROM estoqueposicao e "&_
" left JOIN produtos p ON p.id = e.ProdutoID "&_
" left join cliniccentral.tissunidademedida as u on p.ApresentacaoUnidade=u.id "&_
" WHERE e.id = "&EstoquePosicaoID

set produtos = db.execute(sqlLote)
responseJson(recordToJSON(produtos))
%>