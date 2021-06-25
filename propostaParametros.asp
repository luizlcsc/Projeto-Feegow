<!--#include file="connect.asp"-->
<%
ElementoID = req("ElementoID")
ProcedimentoID = req("id")
set proc = db.execute("select * from procedimentos where id="&ProcedimentoID)
if not proc.EOF then
	Valor = formatnumber(proc("Valor"),2)
	Subtotal = Valor*ccur(ref("Quantidade"&ElementoID))
	%>
	 $("#ValorUnitario<%=ElementoID%>").val('<%=Valor%>');
     $("#sub<%=ElementoID%>").html("R$ <%=formatnumber(Subtotal,2)%>");
     recalc();
	<%
end if
%>