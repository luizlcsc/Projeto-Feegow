<tr id="rowOutros<%=id%>"<%if id<0 then%> data-val="<%=id*(-1)%>"<%end if%>>
    <td width="75%">
	<input type="hidden" name="propostaOutros" value="<%=id%>">
	<%=quickField("editor", "DescricaoOutros"&id, "", 4, Descricao, "0", "", desabilitarProposta)%></td>
    <td width="25%"><%=quickField("memo", "ValorOutros"&id, "", 4, Valor, "" , "", desabilitarProposta)%></td>
    <td><button type="button" class="btn btn-xs btn-danger disable <%=escondeProposta%>" onClick="aplicarProOutros('<%=id%>', 'X')"><i class="fa fa-remove"></i></button></td>
</tr>