<!--#include file="connect.asp"-->
<%
produtoId = req("ProdutoID")
set ProdutoSQL = db.execute("SELECT Codigo,CD,CD,ApresentacaoUnidade FROM produtos WHERE id = '" & produtoId & "'")

if not ProdutoSQL.eof then
%>

if($("#Codigo<%=req("I")%>").val() == ""){
    $("#Codigo<%=req("I")%>").val("<%=ProdutoSQL("Codigo")%>");
}


$("#CD<%=req("I")%>").val("<%=ProdutoSQL("CD")%>");

if($("#ApresentacaoUnidade<%=req("I")%>").val() == ""){
    $("#ApresentacaoUnidade<%=req("I")%>").val("<%=ProdutoSQL("ApresentacaoUnidade")%>");
}

<%
end if
%>