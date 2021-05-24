<%
Quantidade = replace(ref("Quantidade"),".",",")
Fator = ref("Fator")
ValorUnitario = ref("ValorUnitario")
Pressed = req("Pressed")

if ValorUnitario="" then
    ValorUnitario=0
end if

if Quantidade<>"" and isnumeric(Quantidade) and Fator<>"" and isnumeric(Fator) and ValorUnitario<>"" and isnumeric(ValorUnitario) then
	%>
	$("#ValorTotal").val("<%=formatnumber( Quantidade*Fator*ValorUnitario , 2)%>");
	<%
end if
%>