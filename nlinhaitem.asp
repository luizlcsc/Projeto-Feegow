<!--#include file="connect.asp"-->
<tr id="row<%=id%>"<%if id<0 then%> data-val="<%=id*(-1)%>"<%end if%>>
    <td>
		<%=quickField("text", "Quantidade"&id, "", 4, Quantidade, " text-right disable", "", " required")%>
        </td>
        <%
        if Tipo="" then
            %>
            <td><%= selectInsert("", "ItemID"&id, ItemID, "procedimentos", "NomeProcedimento", " onchange=""parametrosInvoice("&id&", this.value);""", " required", "") %></td>
            <td nowrap="nowrap" width="110"><label><input type="checkbox" name="Executado<%=id%>" id="Executado<%=id%>" value="S"<%if Executado="S" then%> checked="checked"<%end if%> class="ace" /><span class="lbl"> Executado</span></label></td>
            <%
        elseif Tipo="O" then
			set data = db.execute("select * from sys_financialinvoices where id="&InvoiceID)
			if not data.eof then
				if data("CD")="C" then
					TabelaCategoria = "sys_financialincometype"
				else
					TabelaCategoria = "sys_financialexpensetype"
					EscondeFormas = 1
					II = "0_0"
				end if
			end if
            %>
            <td><%=quickField("text", "Descricao"&id, "", 4, Descricao, " disable", "", " placeholder='Descri&ccedil;&atilde;o...' required")%></td>
            <td width="200"><%=selectInsert("", "CategoriaID"&id, CategoriaID, TabelaCategoria, "Name", "", " placeholder='Categoria...'", "")%></td>
            <%
        end if
        %>
    <td><%=quickField("currency", "ValorUnitario"&id, "", 4, formatnumber(ValorUnitario,2), " text-right disable", "", " required onkeyup=""recalc($(this).attr('id'))""")%></td>
    <td><%=quickField("text", "Desconto"&id, "", 4, formatnumber(Desconto,2), " input-mask-brl text-right disable", "", " onkeyup=""recalc($(this).attr('id'))""")%></td>
    <td><%=quickField("text", "Acrescimo"&id, "", 4, formatnumber(Acrescimo,2), " input-mask-brl text-right disable", "", " onkeyup=""recalc($(this).attr('id'))""")%></td>
    <td class="text-right" id="sub<%=id%>" nowrap>R$ <%= formatnumber( Subtotal ,2) %></td>
    <td><button type="button" class="btn btn-xs btn-info" onClick="executado(<%=id%>, 1)"><i class="far fa-search-plus"></i></button></td>
    <td><button type="button" class="btn btn-xs btn-danger disable" onClick="itens('<%=Tipo%>', 'X', '<%=id%>')"><i class="far fa-remove"></i></button></td>
</tr>
<script>
<!--#include file="jqueryfunctions.asp"-->
</script>