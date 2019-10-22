<!--#include file="connect.asp"-->
<%
ProdutoID=req("ProdutoID")
ElementoID=req("ElementoID")

set ProdutoSQL = db.execute("SELECT PrecoCompra FROM produtos WHERE id="&ProdutoID)
Valor = 0
Quantidade = 1

if not ProdutoSQL.eof then
    Valor=ProdutoSQL("PrecoCompra")
end if

set UltimaCompraSQL = db.execute("SELECT Quantidade,ValorUnitario, Executado FROM itenscompra WHERE Tipo='M' AND ItemID="&ProdutoID&" ORDER BY id DESC LIMIT 1")

if not UltimaCompraSQL.eof then
    Tipo= UltimaCompraSQL("Executado")
    Valor= fn(UltimaCompraSQL("ValorUnitario"))
    Quantidade= UltimaCompraSQL("Quantidade")
end if

%>
var $parentLinha = $("#invoiceItens").find("[data-id=<%=ElementoID%>]");
$parentLinha.find(".quantidade").val("<%=Quantidade%>");
$parentLinha.find(".CampoValorUnitario").val("<%=Valor%>");
$parentLinha.find("#Executado<%=ElementoID%><%=Tipo%>").click();
<%
%>