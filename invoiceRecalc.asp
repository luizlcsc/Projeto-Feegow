<!--#include file="connect.asp"-->
<%
elem = req("elem")
campo = elem
val = req("val")
c = 0
while c<10
	elem = replace(elem, c, "")
	c = c+1
wend

autoid = replace(campo, elem, "")

db_execute("update tempinvoice set "&elem&"="&treatvalzero(val)&" where autoid="&autoid)

Total = 0
InvoiceID = req("InvoiceID")
set ti = db.execute("select * from tempinvoice where sysUser="&session("User")&" and InvoiceID="&InvoiceID)
while not ti.eof
	Subtotal = ti("Quantidade") * ( ti("ValorUnitario")-ti("Desconto")+ti("Acrescimo") )
	Total = Total+Subtotal
	%>
	$("#sub<%=ti("autoid")%>").html("R$ <%=formatnumber(Subtotal,2)%>");
	<%
ti.movenext
wend
ti.close
set ti = nothing
%>
$("#total").html("R$ <%=formatnumber(Total,2)%>");
$("#Valor").val("<%=formatnumber(Total,2)%>");
geraParcelas($('#NumeroParcelas').val(), '0');
<!--#include file="disconnect.asp"-->