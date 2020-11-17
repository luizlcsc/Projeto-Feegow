<!--#include file="connect.asp"-->
<!--#include file="Classes/ModuloDeCompras.asp"-->
<%
CompraID=req("I")
Acao = ref("A")
Tipo = ref("T")
LimitarPlanoContas = ref("LimitarPlanoContas")
if Tipo="P" then
    Tipo = "S"
end if
II = ref("II")
Row = req("Row")
PacoteID = ""
if Row<>"" then
	Row=ccur(Row)
end if

if Acao="" then
	%>
	<table width="100%" class="duplo table table-striped table-condensed">
		<thead>
			<tr class="info">
				<th width="7%">Quant.</th>
				<th>Item</th>
                <th id="hPlanoContas"></th>
                <th id="hCentroCusto"></th>
				<th width="15%">Valor Unit.</th>
				<th width="11%" class="hidden">Desconto</th>
				<th width="5%">Total</th>
				<th width="5%">Completo</th>
				<th width="1%"></th>
			</tr>
		</thead>
		<tbody>
		<%
		conta = 0
		Total = 0
		Subtotal = 0
		set itens = db.execute("select * from itenscompra where CompraID="&CompraID&" order by id")

		if not itens.eof then

		    set FornecedorSQL = db.execute("SELECT f.limitarPlanoContas FROM fornecedores f INNER JOIN solicitacao_compra i ON i.AccountID=f.id WHERE i.AssociationAccountID=2 AND f.limitarPlanoContas != '' and f.limitarPlanoContas is not null AND i.id="&CompraID)

		    if not FornecedorSQL.eof then
		        LimitarPlanoContas = FornecedorSQL("limitarPlanoContas")
		    end if

            while not itens.eof
                conta = conta+itens("Quantidade")
                Subtotal = itens("Quantidade")*(itens("ValorUnitario")-itens("Desconto")+itens("Acrescimo"))
                Total = Total+Subtotal
                NomeItem = ""
                if itens("Tipo")="S" then
                    set pItem = db.execute("select NomeProcedimento NomeItem from procedimentos where id="&itens("ItemID"))
                    if not pItem.eof then
                        NomeItem = pItem("NomeItem")
                    end if
                elseif itens("Tipo")="M" then
                    set pItem = db.execute("select NomeProduto NomeItem from produtos where id="&itens("ItemID"))
                    if not pItem.eof then
                        NomeItem = pItem("NomeItem")
                    end if
                elseif itens("Tipo")="O" then
                    NomeItem = itens("Descricao")
                end if
                id = itens("id")
                Quantidade = itens("Quantidade")

                ItemID = itens("ItemID")
                Executado = itens("Executado")
                CategoriaID = itens("CategoriaID")
                if CategoriaID=0 then
                    CategoriaID = ""
                end if
                CentroCustoID = itens("CentroCustoID")
                if CentroCustoID=0 then
                    CentroCustoID = ""
                end if

                Desconto = itens("Desconto")
                Acrescimo = itens("Acrescimo")
                Tipo = itens("Tipo")
                Descricao = itens("Descricao")
                ValorUnitario = itens("ValorUnitario")
                %>
                <!--#include file="compraLinhaItem.asp"-->
                <%
            itens.movenext
            wend
            itens.close
            set itens=nothing

		end if
		%>
		<tr id="footItens">
		</tr>
		</tbody>
		<tfoot>
			<tr>
				<th colspan="7"><%=conta%> itens</th>
				<th id="total" class="text-right" nowrap>R$ <%=formatnumber(Total,2)%></th>
				<th colspan="2"><input type="hidden" name="Valor" id="Valor" value="<%=formatnumber(Total,2)%>" /></th>
			</tr>
		</tfoot>
	</table>
<script>
function parametrosProduto(ElementoID, ProdutoID) {
    $.get("getProdutoCompra.asp", {ProdutoID:ProdutoID, ElementoID:ElementoID},function(data) {
        console.log('compra',data)
        eval(data);
        recalcular($("#ValorUnitario"+ElementoID))
    });
}

</script>
<%
elseif Acao="I" then
    id = (Row+1)*(-1)
    Quantidade = 1
    if req("autoPCi")<>"" and isnumeric(req("autoPCi")) then
        CategoriaID = req("autoPCi")
    else
        CategoriaID = ""
    end if
    Desconto = 0
    Acrescimo = 0
    Descricao = ""
    CentroCustoID=ref("CC")

	if ref("T")<>"P"  and ref("T")<>"K" then
		ItemID = 0'id do procedimento
		ValorUnitario = 0
		%>
		<!--#include file="compraLinhaItem.asp"-->
		<%
	end if
	%>
	<script>
	    <!--#include file="JQueryFunctions.asp"-->
    </script>
    <%
elseif Acao="X" then
	%>
	$("#row<%= II %>, #row2_<%= II %>").replaceWith("");
    recalc();
	<%
end if
%>

<!--#include file="disconnect.asp"-->