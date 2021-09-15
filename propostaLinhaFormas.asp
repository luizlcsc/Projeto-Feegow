<%
    disabled = " readonly "
    IF aut("formapagamentopropostaA") = 1 THEN
        disabled = ""
    END IF
%>
<tr id="rowFormas<%=id%>"<%if id<0 then%> data-val="<%=id*(-1)%>"<%end if%>>
    <td width="100%">
	<input type="hidden" name="propostaFormas" value="<%=id%>">
	<%=quickField("memo", "DescricaoFormas"&id, "", 4, Descricao, "", "", disabled&desabilitarProposta)%></td>
    <td><button type="button" class="btn btn-xs btn-danger disable <%=escondeProposta%>" onClick="aplicarProFormas('<%=id%>', 'X')"><i class="far fa-remove"></i></button></td>
</tr>