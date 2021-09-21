<%
function linhaFuncao(FuncaoID, Funcao, Valor, TipoValor, Sobre, Conta, NumeraRepasse, ItemInvoiceID, FM, ProdutoID, ValorUnitario, Quantidade)
	if Valor="" or isnull(Valor) then Valor = 0 end if
	if isnull(Sobre) then Sobre="" end if
	if FM="M" then
		if isnull(ProdutoID) or ProdutoID="" then ProdutoID=0 end if
		if Quantidade="" or not isnumeric(Quantidade) then Quantidade=0 end if
		if ValorUnitario="" or not isnumeric(ValorUnitario) then ValorUnitario=0 end if
		%>
        <td colspan="5"><div class="row">
            <div class="col-xs-3"><%=selectInsert("Produto", "ProdutoID"&ItemInvoiceID&"-"&FuncaoID, ProdutoID, "produtos", "NomeProduto", "", "", "")%></div>
            <div class="col-xs-3"><label>Conta</label><br /><%call simpleSelectCurrentAccounts("ContaCredito"&ItemInvoiceID&"-"&FuncaoID, "00, 5, 4, 2, 1", Conta, "")%></div>
            <div class="col-xs-2"><label>Valor Unit.</label><br /><%call quickField("text", "ValorUnitario"&ItemInvoiceID&"-"&FuncaoID, "", 12, formatnumber(ValorUnitario,2), " input-sm input-mask-brl text-right", "", "")%></div>
            <div class="col-xs-2"><label>Quantidade</label><br /><%call quickField("text", "Quantidade"&ItemInvoiceID&"-"&FuncaoID, "", 12, formatnumber(Quantidade,2), " input-sm input-mask-brl text-right", "", "")%></div>
            <div class="col-xs-2"><label>Total</label><br /><%call quickField("text", "Valor"&ItemInvoiceID&"-"&FuncaoID, "", 12, formatnumber(Valor,2), " input-sm input-mask-brl text-right", "", "")%></div>
            <input type="hidden" name="Sobre<%=ItemInvoiceID&"-"&FuncaoID%>" value="0" />
        </div></td>
		<%
	else
		response.Write("<tr>")
		response.Write("	<td>")
		call quickField("text", "Funcao"&ItemInvoiceID&"-"&FuncaoID, "", 12, Funcao, " input-sm", "", "")
		response.Write("</td>")
		response.Write("	<td><div class=""row""><div class=""col-md-12"">")
		call simpleSelectCurrentAccounts("ContaCredito"&ItemInvoiceID&"-"&FuncaoID, "00, 5, 4, 2, 1", Conta, "","")
		response.Write("</div></div></td>") 
		response.Write("	<td>")
		call quickField("text", "Valor"&ItemInvoiceID&"-"&FuncaoID, "", 12, formatnumber(Valor,2), " input-sm input-mask-brl text-right", "", "")
		response.Write("</td>")
		response.Write("	<td>")
		response.Write("		<select class=""input-sm"" name=""tipoValor"&ItemInvoiceID&"-"&FuncaoID&""" id=""tipoValor"&ItemInvoiceID&"-"&FuncaoID&""">")
		response.Write("			<option value=""P""")
		If TipoValor="P" Then response.Write(" selected") end if
		response.Write(">%</option>")
		response.Write("			<option value=""V""")
		If TipoValor="V" Then response.Write(" selected") end if
		response.Write(">R$</option></select></td>")
		%>
		<td>
			<select class="input-sm" name="Sobre<%=ItemInvoiceID&"-"&FuncaoID%>" id="<%=ItemInvoiceID&"-"&FuncaoID%>">
				<option value="0"<%if cstr(Sobre)="0" then%> selected="selected"<%end if%>>Total</option>
				<option value="1"<%if cstr(Sobre)="1" then%> selected="selected"<%end if%>>Subtotal 1</option>
				<option value="2"<%if cstr(Sobre)="2" then%> selected="selected"<%end if%>>Subtotal 2</option>
				<option value="3"<%if cstr(Sobre)="3" then%> selected="selected"<%end if%>>Subtotal 3</option>
			</select>
		</td>
		<%
	end if
	%><td><input type="hidden" name="FM<%=ItemInvoiceID%>-<%=FuncaoID%>" value="<%=FM%>" /><button type="button" class="btn btn-danger btn-sm" onClick="RemoveRepasse(<%=ItemInvoiceID%>, <%=FuncaoID%>);"><i class="far fa-remove"></i></button></td></tr><%
end function
%>