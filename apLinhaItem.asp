<%
if Row&"" = "" then
    Row=0
end if
if id&"" = "" then
    id=0
end if
%>
<tr id="row<%=id%>" <%if id<0 then%> data-val="<%=Row+1%>"<%end if%> class="invoice-linha-item" >
	<td>
    	<input type="hidden" name="Linhas" value="<%=id%>">
        <input type="hidden" name="ConvenioID<%=id%>" value="<%=ConvenioID%>">
        <input type="hidden" name="TipoProcedimentoID<%=id%>" value="<%=TipoProcedimentoID%>">
        <input type="hidden" name="ProcedimentoID<%=id%>" value="<%=ProcedimentoID%>">
        <input type="hidden" name="Fator<%=id%>" value="<%=Fator%>">
    	<i class="far fa-<%= Icone %>"></i>
    </td>
    <td><%=NomeForma%></td>
    <td><%=NomeProcedimento%></td>
    <td class="text-right"><%=Fator%></td>
    <%
    if aut("valordoprocedimentoV")=0 then
        none = "none"
    else
        none = ""
    end if

    if aut("areceberpacienteV")>0 then
    %>
        <td width="22%" class="text-right">
            <div style="display:<%=none%>">

            <%
            visivel = ""
            if not aut("finalizaratendimentoA")=1 then
            visivel = "none"
            %>
                <span> <%=formatnumber(ValorFinal,2)%> </span>
            <%end if%>
                <div style="display:<%=visivel%>">
                    <%=quickField("currency", "ValorFinal"&id, "", 4, formatnumber(ValorFinal,2), "", "", " placeholder='Valor' style=' height:50px;' ")%>
                </div>
            </div>

        </td>
	<%else%>
    <input type="hidden" name="<%="ValorFinal"&id%>" value="<%=ValorFinal%>">
	<%end if%>
    <td><button class="btn btn-info btn-xs" type="button" onClick="$('#row2<%=id%>').fadeToggle(200);"><i class="far fa-align-left"></i></button></td>
    <td>
    <%if aut("finalizaratendimentoX")=1 then%>
        <button class="btn btn-danger btn-xs" type="button" onClick="addProc('X', <%=id%>);"><i class="far fa-remove"></i></button>
	<%end if%>
    </td>
</tr>
<%
if SolIC="S" and Icone="credit-card" then
    display = ""
    txtIC = "<span class='red'>Informe a indicação clínica</span>"
else
    display = " style=""display:none"""
    txtIC = ""
end if
%>
<tr id="row2<%=id%>" <%=display %>>
	<td></td>
	<td colspan="6"><%=quickField("memo", "Obs"&id, txtIC, 12, Obs, "", "", " placeholder='Observações' style='height:50px'")%></td>
</tr>