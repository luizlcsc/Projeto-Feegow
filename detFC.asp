 <!--#include file="connect.asp"-->
 <%
 De = req("De")
 Ate = req("Ate")
 CD = req("CD")
 Descricao = req("Desc")
 PR = req("PR")

 if CD="C" then
	descCD = "Entradas"
else
	descCD = "Saídas"
 end if
 PR = req("PR")
 if PR="Prev" then
	descPR = "Previsto"
 else
	descPR = "Realizado"
 end if
 mDe = mydatenull(De)
 mAte = mydatenull(Ate)

 between = " between "& mDe &" and "& mAte &" "


 %>
 <div class="panel mt50">
	<div class="panel-heading">
		<span class="panel-title"><%= descCD &" - "& Data &" ("& descPR &")" %> </span>
	</div>
	<div class="panel-body">

	<%
	if Descricao="" then
		Descricao = "Dinheiro e transferências, Crédito, Débito, Cheque"
	end if

	splDesc = split(Descricao, ", ")
	for i=0 to ubound(splDesc)

		total = 0
		Descricao = splDesc(i)

		set pDetSQL = db.execute("select * from cliniccentral.fc where description='"& Descricao &"' and CD='"& CD &"'")
		sql = pDetSQL(PR&"SQL")
		sql = replace(replace(replace(replace(sql, "[De]", mDe), "[Ate]", mAte), "[sysUser]", session("User")), "[CD]", CD)
		set t = db.execute(sql)
		if not t.eof then
		%>

		<h4><%= Descricao %></h4>
		<table class="table table-condensed table-bordered table-hover table-striped">
			<thead>
				<tr>
					<th width="1%"></th>
					<th>Data</th>
					<th>Pagador / Fornecedor</th>
					<th>Compensação</th>
					<th>Detalhamento</th>
					<th nowrap>Valor Conta</th>
					<th nowrap>Valor Pago</th>
					<th nowrap>Valor Fluxo</th>
				</tr>
			</thead>
			<tbody>
				<%
	''			response.write(sql)
				while not t.eof
					descParc = ""
					total = total+t("ValorEfetivo")
					if t("FormaID")=8 then
						set parc = db.execute("select t.Parcela, (select count(*) from sys_financialcreditcardreceiptinstallments where TransactionID=t.TransactionID) Parcelas from sys_financialcreditcardreceiptinstallments t where t.id="& t("CompensacaoID"))
						if not parc.eof then
							descParc = "Parcela "& parc("Parcela") &"/"& parc("Parcelas")
						end if
					end if
					if t("ParcelaID")>0 then
						Pagador = accountName(NULL, t("Pagador"))
					else
						set iifix = db.execute("select i.AccountID, i.AssociationAccountID from itensinvoicefixa ii LEFT JOIN invoicesfixas i ON i.id=ii.InvoiceID WHERE ii.id="& t("ParcelaID")*-1)
						Pagador = accountName(iifix("AssociationAccountID"), iifix("AccountID"))
					end if
					%>
					<tr>
						<td width="1%"><a href="<%= t("Link") %>" target="_blank"><i class="far fa-external-link"></i></a></td>
						<td><%= t("Data") %></td>
						<td><%= Pagador %></td>
						<td><%= t("CompensacaoData") %></td>
						<td>
							<b>Descrição: </b> <%= t("Descricao") &"<br>"& t("PaymentMethod") &" "& descParc %></td>
						<td nowrap class="text-right">R$ <%= fn(t("ParcelaValor")) %></td>
						<td nowrap class="text-right">R$ <%= fn(t("PagamentoValor")) %></td>
						<th nowrap class="text-right">R$ <%= fn(t("ValorEfetivo")) %></th>
					</tr>
					<%
				t.movenext
				wend
				t.close
				set t = nothing
				%>
			</tbody>
			<tfoot>
				<tr>
					<th colspan="6" class="text-right" nowrap>R$ <%= fn(total) %></th>
				</tr>
			</tfoot>
		</table>
		<%
		end if
	next
	%>
	</div>
</div>