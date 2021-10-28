<tr id="row<%=id%>"<%if id<0 then%> data-val="<%=id*(-1)%>"<%end if%> class="invoice-linha-item" >
    <td>
    	<input type="hidden" name="AtendimentoID<%=id%>" id="AtendimentoID<%=id%>" value="<%=AtendimentoID%>">
    	<input type="hidden" name="AgendamentoID<%=id%>" id="AgendamentoID<%=id%>" value="<%=AgendamentoID%>">
		<%=quickField("text", "Quantidade"&id, "", 4, Quantidade, " text-right disable", "", " required onkeyup=""recalc($(this).attr('id'))""")%><input type="hidden" name="inputs" value="<%= id %>"></td>
        <%
        if Tipo="S" or Tipo="P" then
            %>
            <td><%= selectInsert("", "ItemID"&id, ItemID, "procedimentos", "NomeProcedimento", " onchange=""parametrosInvoice("&id&", this.value);""", " required", "") %></td>
            <%
        elseif Tipo="O" then
			set data = db.execute("select * from invoicesfixas where id="&InvoiceID)
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
            <td>
                <div class="row">
                    <div class="col-xs-7">
                    <%=quickField("text", "Descricao"&id, "", 8, Descricao, " disable", "", " placeholder='Descri&ccedil;&atilde;o...' required")%>
                    </div>
                    <div class="col-xs-5">
                        <%=selectInsert("", "CategoriaID"&id, CategoriaID, TabelaCategoria, "Name", "", " placeholder='Categoria...'", "")%>
                    </div>
                </div>
            </td>
            <%
        end if
        %>
    <td><%= selectInsert("", "CentroCustoID"&id, CentroCustoID, "centrocusto", "NomeCentroCusto", "", "", "") %></td>
    <td><%=quickField("currency", "ValorUnitario"&id, "", 4, fn(ValorUnitario), " text-right disable", "", " onkeyup=""recalc($(this).attr('id'))"" onchange='recorrenteLista();' ")%></td>
    <td><%=quickField("currency", "Desconto"&id, "", 4, fn(Desconto), " text-right disable", "", " onkeyup=""recalc($(this).attr('id'))"" onchange='recorrenteLista();' ")%></td>
    <td><%=quickField("currency", "Acrescimo"&id, "", 4, fn(Acrescimo), " text-right disable", "", " onkeyup=""recalc($(this).attr('id'))"" onchange='recorrenteLista();' ")%></td>
    <td class="text-right" id="sub<%=id%>" nowrap>R$ <%= fn( Subtotal) %></td>
    <td><button type="button" class="btn btn-xs btn-danger disable" onClick="itens('<%=Tipo%>', 'X', '<%=id%>')"><i class="far fa-remove"></i></button></td>
</tr>
