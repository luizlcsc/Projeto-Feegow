<%
Quantidade = replace(request.Form("Quantidade"),".",",")
Fator = request.Form("Fator")
ValorUnitario = request.Form("ValorUnitario")
Pressed = request.QueryString("Pressed")

if ValorUnitario="" then
    ValorUnitario=0
end if

if Quantidade<>"" and isnumeric(Quantidade) and Fator<>"" and isnumeric(Fator) and ValorUnitario<>"" and isnumeric(ValorUnitario) then
	%>
	$("#ValorTotal").val("<%=formatnumber( Quantidade*Fator*ValorUnitario , 2)%>");
	<%
end if
%>