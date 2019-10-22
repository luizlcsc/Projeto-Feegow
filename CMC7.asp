<!--#include file="connect.asp"-->
<%
CMC7 = ref("CMC7")

Banco = left(CMC7, 3)
set bc = db.execute("select * from sys_financialbanks where trim(BankNumber)='"&Banco&"'")
if not bc.eof then
    %>
    $("#BankID_2").val(<%=bc("id") %>);
    <%
end if
Agencia = mid(CMC7, 4, 4)
NCheque = mid(CMC7, 13, 6)
Conta = mid(CMC7, 25, 7)
%>

$("#Branch_2").val("<%=Agencia %>");
$("#Account_2").val("<%=Conta %>");
$("#CheckNumber_2").val("<%=NCheque %>");
