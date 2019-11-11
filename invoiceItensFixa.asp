<!--#include file="connect.asp"-->
<%
InvoiceID=req("I")
Acao = ref("A")
Tipo = ref("T")
II = ref("II")
Row = req("Row")
if Row<>"" then
	Row=ccur(Row)
end if

if Acao="" then
	%>
	<table width="100%" class="duplo table table-striped table-condensed">
		<thead>
			<tr>
				<th width="7%">Quant.</th>
				<th>Item</th>
				<th>Centro de Custo</th>
				<th width="7%">Valor Unit.</th>
				<th width="7%">Desc.</th>
				<th width="7%">Acréscimo.</th>
				<th width="7%">Total</th>
				<th width="1%"></th>
			</tr>
		</thead>
		<tbody>
		<%
		conta = 0
		Total = 0
		Subtotal = 0
		set itens=db.execute("select * from itensinvoicefixa where InvoiceID="&InvoiceID&" order by id")
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
			elseif itens("Tipo")="O" then
				NomeItem = itens("Descricao")
			end if
			CentroCustoID = itens("CentroCustoID")

			id = itens("id")
			Quantidade = itens("Quantidade")
			ItemID = itens("ItemID")
			CategoriaID = itens("CategoriaID")
			Desconto = itens("Desconto")
			Acrescimo = itens("Acrescimo")
			Tipo = itens("Tipo")
			Descricao = itens("Descricao")
			ValorUnitario = itens("ValorUnitario")
			Executado = itens("Executado")
			ProfissionalID = itens("ProfissionalID")
			Associacao = itens("Associacao")
			DataExecucao = itens("DataExecucao")
			HoraExecucao = itens("HoraExecucao")
			if not isnull(HoraExecucao) and isdate(HoraExecucao) then
				HoraExecucao = formatdatetime(HoraExecucao, 4)
			end if
			HoraFim = itens("HoraFim")
			if not isnull(HoraFim) and isdate(HoraFim) then
				HoraFim = formatdatetime(HoraFim, 4)
			end if
			%>
            <!--#include file="invoiceLinhaItemFixa.asp"-->
			<%
		itens.movenext
		wend
		itens.close
		set itens=nothing


		if req("Lancto")="Dir" then
			conta = 0
			Total = 0
			Subtotal = 0
			Row = 0
			set itens=db.execute("select * from tempinvoice where InvoiceID="&InvoiceID)
			while not itens.eof
				Row = Row-1
				conta = conta+itens("Quantidade")
				Subtotal = itens("Quantidade")*(itens("ValorUnitario")-itens("Desconto")+itens("Acrescimo"))
				Total = Total+Subtotal
				NomeItem = ""
				if itens("Tipo")="S" then
					set pItem = db.execute("select NomeProcedimento NomeItem from procedimentos where id="&itens("ItemID"))
					if not pItem.eof then
						NomeItem = pItem("NomeItem")
					end if
				elseif itens("Tipo")="O" then
					NomeItem = itens("Descricao")
				end if
				id = Row
				Quantidade = itens("Quantidade")
				ItemID = itens("ItemID")
				CategoriaID = itens("CategoriaID")
				Desconto = itens("Desconto")
				Acrescimo = itens("Acrescimo")
				Tipo = itens("Tipo")
				Descricao = itens("Descricao")
				ValorUnitario = itens("ValorUnitario")
				Executado = itens("Executado")
				ProfissionalID = itens("ProfissionalID")
				Associacao = 5
				DataExecucao = itens("DataExecucao")
				HoraExecucao = itens("HoraExecucao")
				AtendimentoID = itens("AtendimentoID")
				AgendamentoID = itens("AgendamentoID")
				if not isnull(HoraExecucao) and isdate(HoraExecucao) then
					HoraExecucao = formatdatetime(HoraExecucao, 4)
				end if
				HoraFim = itens("HoraFim")
				if not isnull(HoraFim) and isdate(HoraFim) then
					HoraFim = formatdatetime(HoraFim, 4)
				end if
				%>
				<!--#include file="invoiceLinhaItemFixa.asp"-->
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
				<th colspan="3"><%=conta%> itens</th>
				<th id="total" class="text-right" nowrap>R$ <%=formatnumber(Total,2)%></th>
				<th colspan="2"><input type="hidden" name="Valor" id="Valor" value="<%=formatnumber(Total,2)%>" /></th>
			</tr>
		</tfoot>
	</table>
<script type="text/javascript">
    <!--#include file="JQueryFunctions.asp"-->
</script>
<%
elseif Acao="I" then
    id = (Row+1)*(-1)
    Quantidade = 1
    CategoriaID = 0
    Desconto = 0
    Acrescimo = 0
    Tipo = ref("T")
    Descricao = ""
	if Tipo="S" or Tipo="O" then
		ItemID = 0'id do procedimento
		ValorUnitario = 0
		%>
		<!--#include file="invoiceLinhaItemFixa.asp"-->
		<%
	elseif Tipo="P" then
		set pct = db.execute("select pi.ProcedimentoID, pi.ValorUnitario from pacotesitens pi where pi.PacoteID="&II)
		while not pct.EOF
			ItemID = pct("ProcedimentoID")'id do procedimento
			ValorUnitario = pct("ValorUnitario")
			Subtotal = ValorUnitario
			%>
			<!--#include file="invoiceLinhaItemFixa.asp"-->
			<%
			id = id-1
		pct.movenext
		wend
		pct.close
		set pct=nothing
	end if
	%>
	<script>
    geraParcelas('S');
//	recalc();
		<!--#include file="jqueryfunctions.asp"-->
    </script>
    <%
elseif Acao="X" then
	%>
	$("#row<%= II %>, #row2_<%= II %>").replaceWith("");
    recalc();
	<%
end if

if Acao<>"X" then
%>
<script>
$("input[name^=Executado]").click(function(){
	id = $(this).attr('id');
	id = id.replace('Executado', '');
	if($(this).prop('checked')==true){
		$("#row2_"+ id ).removeClass('hidden');
		calcRepasse(id);
	}else{
		$("#row2_"+ id ).addClass('hidden');
		$("#rat"+id).html("");
	}
});

function allRepasses(){
	$("input[name^=Executado").each(function(index, element) {
        if( $(this).prop('checked')==true ){
			id = $(this).attr('id');
			id = id.replace('Executado', '');
			calcRepasse(id);
		}
    });
}

/*
$("select[name^=ProfissionalID]").change(function(){
	id = $(this).attr('id');
	id = id.replace('ProfissionalID', '');
	calcRepasse(id);
});
colocar a funcao direta no onclick (ver a documentacao do select insert)
*/


</script>
<%
end if
%>
<!--#include file="disconnect.asp"-->