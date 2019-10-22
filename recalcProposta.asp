
<!--#include file="connect.asp"-->
<%
inputs = ref("inputs")
inputAlterado = req("input")
ParcelasID = ref("ParcelasID")
Total = 0


spl = split(inputs, ", ")
for i=0 to ubound(spl)
	Quantidade = ref("Quantidade"&spl(i))
	ValorUnitario = ref("ValorUnitario"&spl(i))
	Desconto = ref("Desconto"&spl(i))
	TipoDesconto = ref("DescontoTipo"&spl(i))
	Acrescimo = ref("Acrescimo"&spl(i))
	if Quantidade="" or not isnumeric(Quantidade) then
		Quantidade = 0
	end if
	if ValorUnitario="" or not isnumeric(ValorUnitario) then
		ValorUnitario = 0
	end if
	if Desconto="" or not isnumeric(Desconto) then
		Desconto = 0
	end if
	if Acrescimo="" or not isnumeric(Acrescimo) then
		Acrescimo = 0
	end if
	Quantidade = ccur(Quantidade)
	ValorUnitario = ccur(ValorUnitario)
	Desconto = ccur(Desconto)
	if TipoDesconto="P" and Desconto>0 then
        Desconto = (Desconto/100) * ValorUnitario
    end if
	Acrescimo = ccur(Acrescimo)
	Subtotal = Quantidade * (ValorUnitario - Desconto + Acrescimo)
	Total = Total+Subtotal
	%>
	$("#sub<%=spl(i)%>").html("R$ <%=formatnumber(Subtotal, 2)%>");
    <%
next

%>
$("#total").html("R$ <%=formatnumber(Total, 2)%>");
$("#Valor").val("<%=formatnumber(Total, 2)%>");

