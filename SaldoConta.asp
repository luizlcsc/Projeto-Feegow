<!--#include file="connect.asp"-->
<!--#include file="Classes/AccountBalance.asp"-->

<%
ContaID=req("Conta")
DataReferencia = req("DataReferencia")

Saldo = accountBalancePerDate(ContaID, 0, DataReferencia)

response.write("R$ "& fn(Saldo))
%>