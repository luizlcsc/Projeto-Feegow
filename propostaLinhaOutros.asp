<tr id="rowOutros<%=id%>"<%if id<0 then%> data-val="<%=id*(-1)%>"<%end if%>>
    <td width="75%">
	<input type="hidden" name="propostaOutros" value="<%=id%>">
	<%=quickField("memo", "DescricaoOutros"&id, "", 4, Descricao, "", "", "")%></td>
    <td width="25%"><%=quickField("memo", "ValorOutros"&id, "", 4, Valor, "", "", "")%></td>
    <td><button type="button" class="btn btn-xs btn-danger disable" onClick="aplicarProOutros('<%=id%>', 'X')"><i class="fa fa-remove"></i></button></td>
</tr>