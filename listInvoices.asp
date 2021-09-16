<!--#include file="connect.asp"-->
<%
c=0
Total=0

DeleteMovementID = ref("DeleteMovementID")
if DeleteMovementID<>"" and isnumeric(DeleteMovementID) then
	set getDeleted = db.execute("select * from sys_financialMovement where id="&DeleteMovementID)
	if not getDeleted.EOF then
		'verificar se h� outros movimentos com a mesma invoiceID, se nao houver, apagar a Invoice tb, se houver, update a invoice com valor - o valor deste movimento
		set searchOtherInvoiceMovements = db.execute("select * from sys_financialMovement where InvoiceID like '"&getDeleted("InvoiceID")&"' and id<>"&getDeleted("id"))
		if searchOtherInvoiceMovements.EOF then
			db_execute("delete from sys_financialInvoices where id = '"&getDeleted("InvoiceID")&"'")
			if not isnull(getDeleted("InvoiceID")) then
				set itensadeletar = db.execute("select * from itensinvoice where InvoiceID="&getDeleted("InvoiceID"))
				while not itensadeletar.eof
					db_execute("delete from rateiorateios where ItemInvoiceID="&itensadeletar("id"))
					db_execute("update rateiorateios set ItemContaAPagar=NULL where ItemContaAPagar="&itensadeletar("id"))
				itensadeletar.movenext
				wend
				itensadeletar.close
				set itensadeletar=nothing
				db_execute("delete from itensinvoice where InvoiceID='"&getDeleted("InvoiceID")&"'")
			end if
		else
			set getThisInvoice = db.execute("select * from sys_financialInvoices where id = '"&getDeleted("InvoiceID")&"'")
			db_execute("update sys_financialInvoices set value='"&treatval( ccur(getThisInvoice("Value"))-ccur(getDeleted("Value")) )&"' where id = '"&getDeleted("InvoiceID")&"'")
		end if
		'apagar os discounts de movementid e installmentid
		set movimentosAfetados = db.execute("select InstallmentID, MovementID from sys_financialDiscountPayments where InstallmentID="&DeleteMovementID&" or MovementID="&DeleteMovementID)
		while not movimentosAfetados.eof
			strAfetados = strAfetados&movimentosAfetados("InstallmentID")&";"&movimentosAfetados("MovementID")&";"
		movimentosAfetados.movenext
		wend
		movimentosAfetados.close
		set movimentosAfetados=nothing
		db_execute("delete from sys_financialDiscountPayments where InstallmentID="&DeleteMovementID&" or MovementID="&DeleteMovementID)
		'apagar o movimento
		db_execute("delete from sys_financialMovement where id="&DeleteMovementID)
		
		splAfetados = split(strAfetados, ";")
		for af=0 to ubound(splAfetados)
			if splAfetados(af)<>"" then
				call getValorPago(splAfetados(af), NULL)
			end if
		next
	end if
end if

if inStr(ref("AccountID"),"_") then
	ScreenType="Statement"
	splAccount = split(ref("AccountID"), "_")
	AccountAssociationID = splAccount(0)
	AccountID = splAccount(1)
else
	ScreenType=ref("AccountID")
end if


if ref("DateFrom")<>"" then
	session("DateFrom") = cdate( ref("DateFrom") )
end if
if ref("DateTo")<>"" then
	session("DateTo") = cdate( ref("DateTo") )
end if

if session("DateFrom")="" then
	session("DateFrom") = cdate("01/"&month(date())&"/"&year(date()))
	session("DateTo") = dateadd("m", 1,"01/"&month(date())&"/"&year(date()))
end if
%>
<div class="row">
	<div class="col-xs-10 clearfix form-actions no-margin">
    	<div class="row">
            <div class="col-md-6">
                <label>Extrato de Conta        <%if ScreenType="Statement" then%><%= accountBalance(ref("AccountID"), 1) %><% End If %><span id="textBalance"></span></label><br />
                <%'=selectCurrentAccounts("StatementAccount", "5, 4, 3, 2, 6, 1", ref("AccountID"), "")%>
                <%=selectInsertCA("", "StatementAccount", ref("AccountID"), "5, 4, 3, 2, 6, 1", " onclick=getStatement($(this).attr(\'data-valor\'))", "", "")%>
            </div>
            <%=quickField("datepicker", "DateFrom", "De", 2, session("DateFrom"), " input-sm", "", " required")%>
            <%=quickField("datepicker", "DateTo", "At&eacute;", 2, session("DateTo"), " input-sm", "", " required")%>
            <div class="col-md-2"><label>&nbsp;</label><br />
                <button class="btn btn-sm btn-primary btn-block" id="Filtrate" name="Filtrate" type="button">
                    <i class="far fa-search bigger-110"></i>
                    Filtrar
                </button>
            </div>
        </div>


		<%
        if ScreenType<>"Statement" then
        %>
        <div class="row">
            <div class="col-xs-3">
                <label>Exibir</label><br />
                <select class="form-control" id="Pagto" name="Pagto">
                	<option value="">Todas</option>
                    <option value="Q"<% If ref("Pagto")="Q" Then %> selected="selected"<% End If %>>Somente quitadas</option>
                    <option value="N"<% If ref("Pagto")="N" Then %> selected="selected"<% End If %>>Somente n&atilde;o quitadas</option>
                </select>
            </div>
	        <%=quickfield("multiple", "Unidades", "Unidades", 4, "", "select * from sys_financialcompanyunits where sysActive", "UnitName", "")%>
        </div>
        <% End If %>



    </div>
    <div class="col-xs-2 hidden-xs">
		<button class="btn btn-info btn-xs btn-block" type="button" onclick="print();"><i class="far fa-print"></i> Imprimir</button>
		<div class="btn-group btn-block">
        <button class="btn btn-xs btn-success dropdown-toggle btn-block" data-toggle="dropdown">Adicionar <i class="far fa-angle-down icon-on-right"></i></button>
        <ul class="dropdown-menu">
          <%
          if aut("contasapagarI")=1 then
          %>
          <li><a href="?P=invoice&I=N&T=D&Pers=1">Nova Despesa</a></li>
          <%
          end if
          if aut("contasareceberI")=1 then
          %>
          <li><a href="?P=invoice&I=N&T=C&Pers=1">Nova Receita</a></li>
          <%
          end if
          if aut("lancamentosI")=1 then
          %>
          <li><a onclick="transaction(0);" data-toggle="modal" href="#modal-table">Novo Lan&ccedil;amento</a></li>
          <%
          end if
          %>
        </ul>
       </div>
    </div>
</div>

<input type="hidden" value="<%=ref("AccountID")%>" name="StatementAccountID" id="StatementAccountID" />

<hr />
<div class="row">
  <div class="col-md-12">
	<table class="table table-striped table-bordered table-hover">
	<thead>
		<tr>
        	<th></th>
			<th>Data</th>
			<th>Conta</th>
			<th>Descri&ccedil;&atilde;o</th>
            <% If session("OtherCurrencies")<>"" Then %><th>Valor <%=session("OtherCurrencies")%></th><% End If %>
			<th>Valor</th>
			<th><% If ScreenType="Statement" Then %>Saldo<% Else %>Pago<% End If %></th>
			<th width="1%"></th>
		</tr>
	</thead>
	<%
	Balance = 0
	linhas = 0
	ExibiuPrimeiraLinha = "N"
	SaldoAnteriorFim = 0
	if ScreenType="Statement" then
		set getMovement = db.execute("select m.*, "&_ 
		"CASE WHEN m.`Type`='Bill' THEN "&_ 
			"(select CompanyUnitID from sys_financialinvoices where id=m.InvoiceID limit 1)"&_ 
		"WHEN m.`Type`='Pay' THEN "&_
			" (1 ou 7 ve a unidade) "&_  
		"END as UnidadeIDCred "&_  
		"from sys_financialMovement m "&_ 
		"where (m.AccountAssociationIDCredit="&AccountAssociationID&" and m.AccountIDCredit="&AccountID&") or (m.AccountAssociationIDDebit="&AccountAssociationID&" and m.AccountIDDebit="&AccountID&") order by m.Date")
	else
		set getMovement = db.execute("select m.*, i.CompanyUnitID UnidadeID from sys_financialMovement m left join sys_financialinvoices i on i.id=m.InvoiceID where m.Type='Bill' order by m.Date")
	end if
	while not getMovement.eof
		Value = getMovement("Value")
		AccountAssociationIDCredit = getMovement("AccountAssociationIDCredit")
		AccountIDCredit = getMovement("AccountIDCredit")
		AccountAssociationIDDebit = getMovement("AccountAssociationIDDebit")
		AccountIDDebit = getMovement("AccountIDDebit")
		PaymentMethodID = getMovement("PaymentMethodID")
		Rate = getMovement("Rate")
		Descricao = ""
		SaldoAnterior = Balance
		UnidadeID = getMovement("UnidadeID")
		'defining who is the C and who is the D
	'	response.Write("if "&AccountAssociationIDCredit&"="&AccountAssociationID&" and "&AccountIDCredit&"="&AccountID&" then")
	'	response.Write("if "&AccountAssociationIDCredit=AccountAssociationID&" and "&AccountIDCredit=AccountID&" then")

		if ccur(AccountAssociationIDCredit)=ccur(AccountAssociationID) and ccur(AccountIDCredit)=ccur(AccountID) then
			CD = "C"
			displayCD = CD
			if AccountAssociationID = "1" then
				displayCD = "D"
			end if
			if getMovement("Currency")<>session("DefaultCurrency") then
				Value = Value / Rate
			end if
			Balance = Balance+Value
			accountReverse = accountName(AccountAssociationIDDebit, AccountIDDebit)
		else
			CD = "D"
			displayCD = CD
			if AccountAssociationID = "1" then
				displayCD = "C"
			end if
			if getMovement("Currency")<>session("DefaultCurrency") then
				Value = Value / Rate
			end if
			Balance = Balance-Value
			accountReverse = accountName(AccountAssociationIDCredit, AccountIDCredit)
		end if
		accountReverse = left(accountReverse, 25)

		if getMovement("Date")<=session("DateTo") then
			SaldoAnteriorFim = Balance
		end if

		if (accountReverse="" and getMovement("Type")="Bill") or (ScreenType<>"" and getMovement("Type")="Bill") then
			'->if paid
				if getMovement("Type")="Bill" then
					if getMovement("CD")="D" then
						linkBill = "<a href=""?P=invoice&T="&getMovement("CD")&"&I="&getMovement("InvoiceID")&"&Pers=1"">"
					else
						linkBill = "<a href=""?P=invoice&T="&getMovement("CD")&"&I="&getMovement("InvoiceID")&"&Pers=1"">"
					end if
					endLinkBill = "</a>"
				else
					linkBill = ""
					endLinkBill = ""
				end if
				if ScreenType="Statement" then
					if getMovement("CD")="C" then
						accountReverse = linkBill&"<span class=""badge"">Receita</span>"&endLinkBill
					else
						accountReverse = linkBill&"<span class=""badge"">Despesa</span>"&endLinkBill
					end if
				end if
				totalPago = getValorPago(getMovement("id"), getMovement("ValorPago"))
''

				if getMovement("Value")>totalPago then
					Paid = ""
				else
					if getMovement("Type")="Bill" then
						Paid = "<img src=""assets/img/checked.png"" width=""18"" height=""18"">"
					else
						Paid = ""
					end if
				end if
				if ref("Pagto")="Q" and Paid="" then
					Omite = "S"
				elseif ref("Pagto")="N" and Paid<>"" then
					Omite = "S"
				else
					Omite = ""
				end if
''				
			'<-if paid
		end if
		'-
		cType = getMovement("Type")
		
		if (screenType="Statement" or CD=ref("AccountID")) and getMovement("Date")>=session("DateFrom") and getMovement("Date")<=session("DateTo") then
			if not isnull(getMovement("InvoiceID")) then
				cItens = 0
				set itens = db.execute("select * from itensinvoice where InvoiceID="&getMovement("InvoiceID"))
				while not itens.eof
					if itens("Tipo")="S" then
						set proc = db.execute("select id, NomeProcedimento from procedimentos where id="&itens("ItemID"))
						if not proc.eof then
							Descricao = left(proc("NomeProcedimento"), 23)
						else
							Descricao = "Procedimento exclu&iacute;do"
						end if
					elseif itens("Tipo")="O" then
						Descricao = left(itens("Descricao"), 23)
					end if
					if itens("Quantidade")>1 then
						Descricao = Descricao&" ("&itens("Quantidade")&")"
					end if
					cItens = cItens+1
				itens.movenext
				wend
				itens.close
				set itens=nothing
				if cItens>1 then
					Descricao = cItens&" itens"
				end if
			end if
			
			linhas = linhas+1

			'---> mostrar primeira linha de saldo
			if ExibiuPrimeiraLinha="N" and ScreenType="Statement" then
				%>
				<tr>
                	<td colspan="5"><strong>SALDO ANTERIOR</strong></td>
                    <td class="text-right"><strong><% If (AccountAssociationID=1 or AccountAssociationID=7) and ScreenType="Statement" Then %><%= formatnumber(SaldoAnterior*(-1),2) %><% Else %><%= formatnumber(SaldoAnterior,2) %><% End If %></strong></td>
                    <td></td>
                </tr>
				<%
				ExibiuPrimeiraLinha = "S"
			end if
			'<--- mostrar primeira linha de saldo
			if Omite="" then
				c=c+1
				Total = Total+getMovement("Value")
			%>
			<tr>
				<td width="1%"><label><input id="checkbox1" class="ace ace-checkbox-2 bootbox-confirm" type="checkbox" value="<%=getMovement("id")%>" name="InstallmentsToPay" onclick="checkToPay()"><span class="lbl"> </span></label></td>
				<td width="8%" class="text-right"><%= getMovement("Date") %></td>
				<td><%=iconMethod(getMovement("PaymentMethodID"), CD)%>&nbsp;<%= accountReverse %></td>
				<td><%= linkBill %>
						<%=Descricao%> (<%=UnidadeID%> - <%=getMovement("Type")%>)
						<%if len(getMovement("Name"))>0 and Descricao<>"" then%> - <%end if%><%=left(getMovement("Name"),20)%>
					<%= endlinkBill %><br /><%=getMovement("Obs")%>
                    </td>
				<% If session("OtherCurrencies")<>"" Then %>
					<td class="text-right"><% If getMovement("Currency")<>session("DefaultCurrency") Then %><%= formatnumber(getMovement("Value"),2)%><% End If %></td>
				<% End If %>
				<td class="text-right"> <%= Paid %>&nbsp;<%= formatnumber(Value,2) %>&nbsp;<%=displayCD%></td>
				<td class="text-right"><% 
				If ScreenType="Statement" Then
					%><% If (AccountAssociationID=1 or AccountAssociationID=7) and Balance<>0 Then %><%= formatnumber(Balance*(-1),2) %><% Else %><%= formatnumber(Balance,2) %><% End If %><% 
				Else 
					%><%= formatnumber(totalPago,2) %><% 
				End If %></td>
				<td nowrap="nowrap">
					<div class="action-buttons">
						<%= linkBill %>
							<i class="far fa-edit green bigger-130"></i>
						<%= endlinkBill %>
						<a class="blue" onclick="modalPaymentDetails(<%=getMovement("id")%>);" data-toggle="modal" role="button" href="#modal-table">
							<i class="far fa-search-plus bigger-130"></i>
						</a>
						<a class="red" onclick="if(confirm('Tem certeza de que deseja excluir?'))getStatement('<%=ref("AccountID")%>', '', '', '<%= getMovement("id") %>');" role="button" href="#">
							<i class="far fa-trash bigger-130"></i>
						</a>
					</div>
				</td>
			</tr>
			<%
			end if
		end if
	getMovement.movenext
	wend
	getMovement.close
	set getMovement = nothing

			'---> mostrar primeira linha de saldo
			if ExibiuPrimeiraLinha="N" and ScreenType="Statement" then
				%>
				<tr>
                	<td colspan="5"><strong>SALDO ANTERIOR</strong></td>
                    <td class="text-right"><strong><%= formatnumber(SaldoAnteriorFim,2) %></strong></td>
                </tr>
				<%
				ExibiuPrimeiraLinha = "S"
			end if
			'<--- mostrar primeira linha de saldo
			if ScreenType<>"Statement" then
				%>
                <tfoot>
				<tr>
                	<th colspan="4"><%=c%> registros</th>
                    <th class="text-right"><%=formatnumber(Total, 2)%></th>
                </tr>
                </td>
				<%
			end if
	%>
	</table>
<%
if linhas=0 then
	%>
	<div class="col-md-12 text-center">N&atilde;o h&aacute; lan&ccedil;amentos para o per&iacute;odo consultado.</div>
	<%
end if
%>
  </div>
</div>

<script language="javascript">
jQuery(function($) {
	$('input[name=date-range-picker]').daterangepicker().prev().on(ace.click_event, function(){
		$(this).next().focus();
	});
	$(".chosen-select").chosen();
	$('#StatementAccount').change(function(){
		getStatement($("#StatementAccount").val(), '', '', '');
	});
	$('#Filtrate').click(function(){
		getStatement('<%=ref("AccountID")%>', $("#DateFrom").val(), $("#DateTo").val(), '');
	});
	$('#previousMonth').click(function(){
		getStatement('<%=ref("AccountID")%>', '<%= dateAdd("m", -1, session("DateFrom")) %>', '<%= dateAdd("m", -1, session("DateTo")) %>', '');
	});
	$('#nextMonth').click(function(){
		getStatement('<%=ref("AccountID")%>', '<%= dateAdd("m", 1, session("DateFrom")) %>', '<%= dateAdd("m", 1, session("DateTo")) %>', '');
	});
});
<!--#include file="jQueryFunctions.asp"-->
</script>