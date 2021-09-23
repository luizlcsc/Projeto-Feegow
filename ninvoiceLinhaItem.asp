<tr id="row<%=id%>"<%if id<0 then%> data-val="<%=id*(-1)%>"<%end if%>>
    <td>
    	<input type="hidden" name="AtendimentoID<%=id%>" id="AtendimentoID<%=id%>" value="<%=AtendimentoID%>">
    	<input type="hidden" name="AgendamentoID<%=id%>" id="AgendamentoID<%=id%>" value="<%=AgendamentoID%>">
		<%=quickField("text", "Quantidade"&id, "", 4, Quantidade, " text-right disable", "", " required onkeyup=""recalc($(this).attr('id'))""")%><input type="hidden" name="inputs" value="<%= id %>"></td>
        <%
        if Tipo="S" or Tipo="P" then
            %>
            <td><%= selectInsert("", "ItemID"&id, ItemID, "procedimentos", "NomeProcedimento", "", " required", "") %></td>
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
<%
if req("T")<>"D" then
%>
<tr id="row2_<%=id%>"<%if Executado<>"S" then%> class="hidden"<%end if%>>
	<td></td>
    <td colspan="8">
    	<div class="col-xs-4">
			<label>Profissional</label><br>
            <%=simpleSelectCurrentAccounts("ProfissionalID"&id, "5, 8, 2", Associacao&"_"&ProfissionalID, " onchange=""calcRepasse("& id &")""","")%>
			<%'=selectInsertCA("", "ProfissionalID"&id, Associacao&"_"&ProfissionalID, "5, 8, 2", " onchange=""setTimeout(function()calcRepasse("& id &"), 500)""", "", "")%>
        </div>
        <%= quickField("datepicker", "DataExecucao"&id, "Data da Execu&ccedil;&atilde;o", 2, DataExecucao, "", "", "") %>
        <%= quickField("text", "HoraExecucao"&id, "In&iacute;cio", 1, HoraExecucao, " input-mask-l-time", "", "") %>
        <%= quickField("text", "HoraFim"&id, "Fim", 1, HoraFim, " input-mask-l-time", "", "") %>
        <span id="rat<%=id%>">
        <%
		Row = id
		if Executado="S" then
			set rats = db.execute("select rr.*, f.Variavel, f.ContaPadrao from rateiorateios rr LEFT JOIN rateiofuncoes f on f.id=rr.FuncaoID where rr.ItemInvoiceID="&id)
			while not rats.eof
				FM = rats("FM")
				Variavel = rats("Variavel")
				ProdutoID = rats("ProdutoID")
				FuncaoID = rats("FuncaoID")
				ContaCredito = rats("ContaCredito")
				ContaPadrao = rats("ContaPadrao")
				ValorUnitario = rats("ValorUnitario")
				Sobre = rats("Sobre")
				Funcao = rats("Funcao")
				Valor = rats("Valor")
				TipoValor = rats("TipoValor")
				Quantidade = rats("Quantidade")
				%>
				<!--#include file="invoiceLinhaRepasse.asp"-->
				<%
			rats.movenext
			wend
			rats.close
			set rats=nothing
		end if
		%>
        
        </span>
    </td>
</tr>
<%
end if
%>