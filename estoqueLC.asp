<!--#include file="connect.asp"-->
<%
LancamentoID = req("LancamentoID")

call estoqueLancaConta(LancamentoID, "eval")
%>