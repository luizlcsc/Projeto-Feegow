<!--#include file="connect.asp"-->
<%
AutoID = req("AutoID")
set ai = db.execute("select ti.*, ti.ItemID, i.FormaID, p.NomeProcedimento, i.ContaRectoID from tempinvoice ti left join sys_financialinvoices i on ti.InvoiceID=i.id left join procedimentos p on p.id=ti.ItemID where ti.autoid="&AutoID)
if not ai.eof then
	if not isnull(ai("FormaID")) and not isnull(ai("ContaRectoID")) then
		FormaID = "P"&ai("FormaID")&"_"&ai("ContaRectoID")
	else
		FormaID = ""
	end if
	ProfissionalID = ai("ProfissionalID")
	ProcedimentoID = ai("ItemID")
'pega a forma predefinida


'response.Write(FormaID &" - "& dominioRepasse( FormaID, ProfissionalID, ProcedimentoID))
'response.Write("<br>dominioRepasse( "&FormaID&", "&ProfissionalID&", "&ProcedimentoID&")")
    DominioID = dominioRepasse( FormaID, ProfissionalID, ProcedimentoID, "", "", "" )
	set fun = db.execute("select * from rateiofuncoes where DominioID="&DominioID&" and FM='F' and ContaPadrao=''")
	if not fun.eof then
%>
        <h5>Profissionais participantes</h5>
        <table class="table table-striped table-bordered">
        <thead>
            <tr>
                <th>Servi&ccedil;o</th>
                <th>Fun&ccedil;&atilde;o</th>
                <th>Profissional</th>
            </tr>
        </thead>
        <%
            while not fun.eof
				muid = ai("id")&"_"&fun("id")
				set vcaRateio = db.execute("select * from temprateiorateios where autoItemInvoiceID="&ai("autoid")&" and sysUserTemp="&session("User")&" and FuncaoID="&fun("id"))
				if not vcaRateio.eof then
					ContaCredito = vcaRateio("ContaCredito")
				else
					ContaCredito = fun("ContaPadrao")
				end if
                %>
                <tr>
                    <td>
                    	<input type="hidden" name="itensF" value="<%=muid%>" />
						<%=ai("NomeProcedimento")%>
                    </td>
                    <td><%=fun("Funcao")%></td>
                    <td><%call simpleSelectCurrentAccounts("ContaCredito"&muid, "5, 4, 2", ContaCredito, "","")%></td>
                </tr>
                <%
            fun.movenext
            wend
            fun.close
            set fun=nothing
        %>
        </table>
	<%
	end if
	%>
	<hr>

	<%
	set fun = db.execute("select rf.*, p.NomeProduto from rateiofuncoes rf left join produtos p on p.id=rf.ProdutoID where rf.DominioID="&DominioID&" and rf.FM='M' and rf.Variavel='S'")
	while not fun.eof
		muid = ai("id")&"_"&fun("id")

		set vcaRateio = db.execute("select * from temprateiorateios where autoItemInvoiceID="&ai("autoid")&" and sysUserTemp="&session("User")&" and FuncaoID="&fun("id"))
		if not vcaRateio.eof then
			ContaCredito = vcaRateio("ContaCredito")
			Quantidade = vcaRateio("Quantidade")
		else
			ContaCredito = fun("ContaPadrao")
			Quantidade = fun("Quantidade")
		end if
		if not isnull(Quantidade) then Quantidade = formatnumber(Quantidade,2) end if
			if ExibiuTituloMat = "" then
				%>
				<h5>Materiais utilizados</h5>
				<table class="table table-striped table-bordered">
				<thead>
					<tr>
						<th>Servi&ccedil;o</th>
						<th>Produto</th>
						<th>Quantidade Utilizada</th>
						<th>Estoque</th>
						<th>Conta Cr&eacute;dito</th>
					</tr>
				</thead>
				<%
			end if
			ExibiuTituloMat = "S"
		%>
		<tr>
			<td>
				<input type="hidden" name="itensM" value="<%=muid%>" />
				<%=ai("NomeProcedimento")%>
			</td>
			<td><%=fun("NomeProduto")%></td>
			<td><%= quickField("text", "Quantidade"&muid, "", 5, Quantidade, "input-mask-brl text-right", "", "") %></td>
			<td id="muid<%=muID%>">
			<%
			set vcBaixado = db.execute("select id from estoquelancamentos where ItemInvoiceID="&ai("id")&" and FuncaoRateioID="&fun("id"))
			if not vcBaixado.eof then
				%>
				<button type="button" class="btn btn-xs btn-success"><i class="far fa-upload"></i> Baixado</button>
				<%
			else
				%>
				<div class="btn-group">
				<button class="btn btn-danger btn-xs dropdown-toggle" data-toggle="dropdown">
				<i class="far fa-download"></i> Baixar <span class="far fa-caret-down icon-on-right"></span>
				</button>
				<ul class="dropdown-menu dropdown-danger">
				<%
				set lanc = db.execute("select distinct Validade, Lote from estoquelancamentos where ProdutoID="&fun("ProdutoID"))
				while not lanc.eof
					Quantidade = quantidadeEstoque(fun("ProdutoID"), lanc("Lote"), lanc("Validade"))
					if Quantidade>0 then
						%>
							<li><a href="javascript:lancar('<%=muid%>', '<%=lanc("Lote")%>', '<%=lanc("Validade")%>');">Lt. <%=lanc("Lote")%>, Val. <%=lanc("Validade")%> - Disp.: <%=Quantidade &" "& lcase(unidade)%></a><li>
						<%
					end if
				lanc.movenext
				wend
				lanc.close
				set lanc = nothing
				%>
				</ul>
				</div>
				<%
			end if
			%>
			</td>
			<td><%call simpleSelectCurrentAccounts("ContaCredito"&muid, "00, 5, 4, 2, 1", ContaCredito, "","")%></td>
			</tr>
		<%
	fun.movenext
	wend
	fun.close
	set fun=nothing
	if ExibiuTituloMat="S" then
		%>
		</table>
		<%
	end if
end if
%>