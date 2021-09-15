<!--#include file="connect.asp"-->
<div class="page-header">
	<h4 class="lighter blue">Pagamento
		<div class="widget-toolbar no-border">
			<button class="bootbox-close-button close" type="button"><i class="far fa-remove"></i></button>
		</div>
    </h4>
</div>
<div class="modal-body">
<%
InvoiceID = req("I")
if req("XMov")<>"" then
	db_execute("delete from sys_financialmovement where id="&req("XMov"))
	%>
    <script>
	geraParcelas('N');
	</script>
	<%
end if

set inv = db.execute("select i.*, fr.MetodoID from sys_financialinvoices i left join sys_formasrecto fr on fr.id=i.FormaID where i.id="&InvoiceID)
CD = inv("CD")
if req("MetodoID")<>"" then
	MetodoID = ccur(req("MetodoID"))
else
	MetodoID = inv("MetodoID")
end if
'ContaID = req("ContaID")

'------> pegando os creditos
AssociationAccountID = inv("AssociationAccountID")
AccountID = inv("AccountID")
'set mov = db.execute("select m.*, (select sum(DiscountedValue) from sys_financialdiscountpayments where MovementID=m.id) as soma from sys_financialmovement m where ((m.AccountAssociationIDCredit="&AssociationAccountID&" and m.AccountIDCredit="&AccountID&" and Type='Transfer') or (m.AccountAssociationIDDebit="&AssociationAccountID&" and m.AccountIDDebit="&AccountID&" and Type='Pay')) and m.Type<>'Bill'")
set mov = db.execute("select m.*, (select sum(DiscountedValue) from sys_financialdiscountpayments where MovementID=m.id) as soma from sys_financialmovement m where ((m.AccountAssociationIDCredit="&AssociationAccountID&" and m.AccountIDCredit="&AccountID&") or (m.AccountAssociationIDDebit="&AssociationAccountID&" and m.AccountIDDebit="&AccountID&")) and m.Type<>'Bill'")
		while not mov.eof
			valor = mov("Value")
			soma = mov("soma")
			'response.Write(valor&"/"&soma&"<br />")
			if isnull(soma) then soma=0 end if
			if valor>soma then
				if headCredito = "" then
				%>
				<form id="frmCredito" action="" method="post">
				<h5 class="lighter green">Cr&eacute;ditos Dispon&iacute;veis</h5>
				<div class="row">
					<div class="col-md-12" id="Credits">
					<table class="table table-striped table-hover table-bordered">
					<thead>
						<tr>
							<th width="1%"></th>
							<th>Data</th>
							<th>Tipo</th>
							<th>Valor</th>
							<th>Utilizado</th>
							<th>Cr&eacute;dito</th>
                            <th width="1%"></th>
						</tr>
					</thead>
					<%
					headCredito = "S"
				end if
				credito = valor-soma
				%>
				<tr>
					<td><label><input type="checkbox" class="ace credito" id="Credito" name="Credito" value="<%=mov("id")&"_"&formatnumber(credito,2)%>" /><span class="lbl"></span></label></td>
					<td class="text-right"><%=mov("Date")%></td>
					<td><%=mov("Type")%></td>
					<td class="text-right"><%=formatnumber(valor,2)%></td>
					<td class="text-right"><%=formatnumber(soma,2)%></td>
					<td class="text-right"><%=formatnumber(credito,2)%></td>
                    <td><button type="button" class="btn btn-xs btn-danger" onclick="excluiMov(<%=mov("id")%>);"<% If soma>0 Then %> disabled="disabled"<% End If %>><i class="far fa-remove"></i></button></td>
				</tr>
				<%
			end if
		mov.movenext
		wend
		mov.close
		set mov=nothing
		if headCredito="S" then
		%>
		</table>
		</div>
	</div>
    <div id="pagtoCredito" class="clearfix form-actions">
    	<%server.Execute("calcCredito.asp")%>
    </div>
	</form>
		<%
		end if
'<------ pegando os creditos
%>

<form method="post" action="" id="invoicePagamento">
<div class="row">
	<div class="col-md-4">
        <label for="MetodoID">Forma de Pagamento</label>
        <%if inv("FormaID")<>0 then%><input type="hidden" name="MetodoID" value="<%=MetodoID%>" /><%end if%>
        <select required name="MetodoID" id="MetodoID" class="form-control"<%if inv("FormaID")<>0 then%> disabled="disabled"<%end if%>>
            <option value="">Selecione</option>
            <%
            set PaymentMethod = db.execute("select * from sys_financialPaymentMethod where AccountTypes"&CD&"<>'' or id=3 order by PaymentMethod")
            while not PaymentMethod.eof
                %><option value="<%=PaymentMethod("id")%>"<%if MetodoID=PaymentMethod("id") then%> selected="selected"<%end if%>><%=PaymentMethod("PaymentMethod")%></option>
                <%
            PaymentMethod.movenext
            wend
            PaymentMethod.close
            set PaymentMethod=nothing
            %>
        </select>
	</div>
    <!--sujo-->
    <div class="col-md-4">
    <%
    if MetodoID=3 then
        %><label for="ContaRectoID">Selecione a Pessoa</label><br /><%
        'call selectCurrentAccounts("ContaRectoID", "4, 3, 2", AssociationAccountID&"_"&AccountID, "")
		response.Write(selectInsertCA("", "ContaRectoID", AssociationAccountID&"_"&AccountID, "4, 3, 2, 5", othersToSelect, othersToInput, campoSuperior))
    else
        set PaymentMethods = db.execute("select * from sys_financialPaymentMethod where id = '"&MetodoID&"'")
        if not PaymentMethods.EOF then
			'verifica se o caixa está aberto
			set caixa = db.execute("select * from caixa where sysUser="&session("User")&" and isnull(dtFechamento)")
			if not caixa.eof then
				CaixaID = caixa("id")
			end if
			if (MetodoID=1 or MetodoID=2) and CaixaID<>"" then
	            %>
                <input type="hidden" name="ContaRectoID" value="7_<%=CaixaID%>" />
                <%
			else
				%>
                <div class="row">
                  <div class="col-md-12">
                    <label for="ContaRectoID"><%=PaymentMethods("Text"&CD)%></label><br />
                    <select name="ContaRectoID" class="form-control" id="ContaRectoID">
                    <%
                    splAccountTypes = split(PaymentMethods("AccountTypes"&CD), "|")
                    for i=0 to ubound(splAccountTypes)
                        set PaymentAccounts=db.execute("select * from sys_financialCurrentAccounts where AccountType="&splAccountTypes(i))
                        while not PaymentAccounts.EOF
                            %><option value="1_<%=PaymentAccounts("id")%>"<%if inv("ContaRectoID")=PaymentAccounts("id") then%> selected="selected"<%end if%>><%=PaymentAccounts("AccountName")%></option>
                        <%PaymentAccounts.movenext
                        wend
                        PaymentAccounts.close
                        set PaymentAccounts=nothing
                    next
                    
                        
                    %>
                    </select>
                  </div>
                </div>
                <%
			end if
			%>
            <div class="row">
            <%
            if CD="C" then
                select case PaymentMethods("id")
                case 2'check
                    %>
                    <%=quickField("simpleSelect", "BankID", "Banco Emissor", "12", "", "select * from sys_financialBanks order by BankName", "BankName", "")%>
                    <%=quickField("text", "CheckNumber", "N&deg; do Cheque", "6", "", "", "", "")%>
                    <%=quickField("text", "Holder", "Titular", "6", "", "", "", "")%>
                    <%=quickField("text", "Document", "Documento", "6", "", "", "", "")%>
                    <%=quickField("datepicker", "CheckDate", "Data do Cheque", "6", date(), "", "", "")%>
                    <%=quickField("simpleCheckbox", "Cashed", "Compensado", "6", "1", "", "", "")%>
                    <%
                case 4
                    %>
                    <%=quickField("currency", "BankFee", "Valor da Tarifa", "6", "0,00", "", "", "")%>
                    <%
                case 8
                    %>
                    <%=quickField("text", "TransactionNumber", "N&uacute;mero da Transa&ccedil;&atilde;o", "12", "", "", "", "")%>
                    <div class="col-md-4">
                    <label for="NumberOfInstallments">Parcelas</label><br />
                    <select name="NumberOfInstallments" id="NumberOfInstallments">
                    <%
                    c=0
                    while c<12
                        c=c+1
                        %><option value="<%= c %>"><%= c %></option>
                        <%
                    wend
                    %>
                    </select>
                    </div>
                    <%=quickField("text", "AuthorizationNumber", "N&uacute;mero da Autoriza&ccedil;&atilde;o", "8", "", "", "", "")%>
                    <%
                case 9
                    %>
                    <%=quickField("text", "TransactionNumber", "N&uacute;m. Transa&ccedil;&atilde;o", "6", "", "", "", "")%>
                    <input type="hidden" name="NumberOfInstallments" id="NumberOfInstallments" value="1">
                    <%=quickField("text", "AuthorizationNumber", "N&uacute;m. Autoriza&ccedil;&atilde;o", "6", "", "", "", "")%>
                    <%
                end select
            else
                select case PaymentMethods("id")
                case 2'check
                    %>
                    <%=quickField("text", "CheckNumber", "N&uacute;mero do Cheque", "6", "", "", "", "")%>
                    <%=quickField("datepicker", "CheckDate", "Data do Cheque", "6", date(), "", "", "")%>
                    <%
                case 5, 6, 7
                    %>
                    <%=quickField("currency", "BankFee", "Valor da Tarifa", "6", "0,00", "", "", "")%>
                    <%
                case 10
                    %>
                    <%=quickField("text", "AuthorizationNumber", "N&uacute;mero da Autoriza&ccedil;&atilde;o", "8", "", "", "", "")%>
                    <div class="col-md-4">
                    <label for="NumberOfInstallments">Parcelas</label><br />
                    <select name="NumberOfInstallments" id="NumberOfInstallments">
                    <%
                    c=0
                    while c<12
                        c=c+1
                        %><option value="<%= c %>"><%= c %></option>
                        <%
                    wend
                    %>
                    </select>
                    </div>
                    <%=quickField("text", "TransactionNumber", "N&uacute;mero da Transa&ccedil;&atilde;o", "8", "", "", "", "")%>
                    <%
                end select
            end if
			%>
            </div>
            <%
		end if
    end if
    %>
    </div>
    <!--//sujo-->







	<%
	TotalDevedor = 0
	set parc = db.execute("select * from sys_financialmovement where id in('"&replace(ref("Parcela"), ", ", "', '")&"')")
	while not parc.eof
		Valor = parc("Value")

		AlreadyDiscounted = 0
		set getAlreadyDiscounted = db.execute("select * from sys_financialDiscountPayments where InstallmentID="&parc("id"))
		while not getAlreadyDiscounted.EOF
			AlreadyDiscounted = AlreadyDiscounted+getAlreadyDiscounted("DiscountedValue")
		getAlreadyDiscounted.movenext
		wend
		getAlreadyDiscounted.close
		set getAlreadyDiscounted = nothing

		PaymentMovement = 0
		set getPaymentMovement = db.execute("select * from sys_financialDiscountPayments where MovementID="&parc("id"))
		while not getPaymentMovement.EOF
			PaymentMovement = PaymentMovement+getPaymentMovement("DiscountedValue")
		getPaymentMovement.movenext
		wend
		getPaymentMovement.close
		set getPaymentMovement = nothing

		Devedor = Valor - AlreadyDiscounted - PaymentMovement
		TotalDevedor = Devedor+TotalDevedor

	parc.movenext
	wend
	parc.close
	set parc=nothing
	%>
    <div class="col-md-4">
    	<div class="row">
		    <%=quickField("datepicker", "DataPagto", "Data do Pagamento", 12, date(), "", "", "")%>
		    <%=quickField("currency", "ValorPagto", "Valor do Pagamento", 12, formatnumber(TotalDevedor,2), "", "", "")%>
        </div>
    </div>


</div>
    <div class="modal-footer">
    	<button class="btn btn-success btn-sm"><i class="far fa-save"></i> Pagar</button>
    </div>
    <input type="hidden" name="CaixaID" value="<%=CaixaID%>" />
</form>
</div>
<script>

$("#invoicePagamento").submit(function(){
	$.post("savePagamento.asp?I=<%=InvoiceID%>", $("#invoicePagamento, #formItens").serialize(), function(data, status){ eval(data) });
	return false;
});
$("#MetodoID").change(function(){
	$.post("invoicePagamento.asp?I=<%=InvoiceID%>&MetodoID="+$("#MetodoID").val(), $("#formItens").serialize(), function(data, status){ $("#modal").html( data ) });
});

$(".credito").click(function(){
	$.post("calcCredito.asp?InvoiceID=<%=InvoiceID%>", $("#frmCredito").serialize(), function(data, success){ $("#pagtoCredito").html(data) } );
});

function applyCredit(){
	$.post("aplicarCredito.asp", $("#frmCredito, #formItens").serialize(), function(data, status){ eval(data) });
}

function excluiMov(I){
	if(confirm('Tem certeza de que deseja excluir este crédito?')){
		$.post("invoicePagamento.asp?I=<%=req("I")%>&XMov="+I, '', function(data, status){ $("#modal").html(data) } );
	}
}
<!--#include file="jQueryFunctions.asp"-->
</script>
<!--#include file="disconnect.asp"-->
