<!--#include file="connect.asp"-->
<%
PropostaID=req("I")
Acao = ref("A")
Tipo = ref("T")
II = ref("II")
Row = req("Row")
if Row<>"" then
	Row=ccur(Row)
end if

if Acao="" then
	%>
	<table width="100%" class="duplo table table-striped table-bordered table-condensed">
		<thead>
			<tr>
				<th width="7%">Descrição</th>
				<th width="9%">Valor</th>
				<th width="1%"></th>
			</tr>
		</thead>
		<tbody>
		<%
		conta = 0
		Total = 0
		Subtotal = 0
		set itens=db.execute("select * from itensproposta where PropostaID="&PropostaID)
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
            <!--#include file="propostaLinhaOutros.asp"-->
			<%
		itens.movenext
		wend
		itens.close
		set itens=nothing

		%>
		<tr id="footItens">
		</tr>
		</tbody>
		<tfoot>
			<tr>
				<th><%=conta%> itens</th>
				<th id="total" class="text-right" nowrap>R$ <%=formatnumber(Total,2)%></th>
				<th><input type="hidden" name="Valor" id="Valor" value="<%=formatnumber(Total,2)%>" /></th>
			</tr>
		</tfoot>
	</table>
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
		<!--#include file="propostaLinhaItem.asp"-->
		<%
	elseif Tipo="P" then
		set pct = db.execute("select pi.ProcedimentoID, pi.ValorUnitario from pacotesitens pi where pi.PacoteID="&II)
		while not pct.EOF
			ItemID = pct("ProcedimentoID")'id do procedimento
			ValorUnitario = pct("ValorUnitario")
			Subtotal = ValorUnitario
			%>
			<!--#include file="propostaLinhaItem.asp"-->
			<%
			id = id-1
		pct.movenext
		wend
		pct.close
		set pct=nothing
	end if
	%>
	<script>
//	recalc();
    <!--#include file="jQueryFunctions.asp"-->
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