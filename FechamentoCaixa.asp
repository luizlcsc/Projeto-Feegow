<!--#include file="connect.asp"-->
<%
Data = date()
%>
<div class="page-header">
	<h1 class="lighter blue">Fechamento de Caixa <small></small></h1>
</div>

<div class="clearfix form-actions">
	<%=quickField("datepicker", "Data", "Data", 3, Data, "input-mask-date input-sm", "", "")%>
    <div class="col-md-2"><label>&nbsp;</label><br />
    	<button type="button" class="btn btn-sm btn-block btn-primary"><i class="far fa-lock"></i> FECHAR CAIXA</button>
    </div>
</div>

<div class="row">
	<div class="col-md-6">
		<h4>Saldos</h4>
        <table class="table table-striped table-bordered table-hover table-condensed">
        	<thead>
            	<tr>
                	<th>Conta</th>
                    <th class="text-right">Saldo</th>
                </tr>
            </thead>
            <tbody>
            <%
			SaldoTotal = 0
			set contas = db.execute("select * from sys_financialcurrentaccounts where sysActive=1")
			while not contas.eof
				Saldo = accountBalance("1_"&contas("id"), 0)
				SaldoTotal = SaldoTotal+Saldo
				%>
				<tr>
                	<td><%=contas("AccountName")%></td>
                    <td class="text-right"><%=formatnumber(Saldo*(-1),2)%></td>
                </tr>
				<%
			contas.movenext
			wend
			contas.close
			set contas=nothing
            %>
            </tbody>
            <tfoot>
            	<tr>
                	<th>Total</th>
                	<th class="text-right"><%=formatnumber(SaldoTotal*(-1),2)%></th>
                </tr>
            </tfoot>
        </table>
	</div>
    <div class="col-md-6">
        <h4>Movimenta&ccedil;&atilde;o</h4>
        <table class="table table-striped table-bordered table-hover table-condensed">
            <thead>
            	<tr>
                	<th>Forma</th>
                	<th class="text-right">Entradas</th>
                    <th class="text-right">Sa&iacute;das</th>
                    <th class="text-right">Resultado</th>
                </tr>
            </thead>
            <tbody>
            <%
			TotalEntradas = 0
			TotalSaidas = 0
'            set dist = db.execute("select distinct PaymentMethodID from sys_financialmovement where not isnull(PaymentMethodID) and `Date`="&mydatenull(Data))
            set dist = db.execute("select distinct mov.PaymentMethodID, forma.PaymentMethod from sys_financialmovement as mov left join sys_financialpaymentmethod as forma on forma.id=mov.PaymentMethodID where not isnull(PaymentMethodID) and PaymentMethodID!=3")
            while not dist.eof
				entradas = 0
				saidas = 0
				set pmov = db.execute("select * from sys_financialmovement where PaymentMethodID="&dist("PaymentMethodID")&" and PaymentMethodID!=3")
				while not pmov.eof
					if pmov("CD")="D" then
						entradas = entradas+pmov("Value")
					elseif pmov("CD")="C" then
						saidas = saidas+pmov("Value")
					end if
				pmov.movenext
				wend
				pmov.close
				set pmov=nothing
				resultado = entradas-saidas
				TotalEntradas = TotalEntradas+entradas
				TotalSaidas = TotalSaidas+saidas
                %>
                <tr>
                	<td><%=dist("PaymentMethod")%></td>
                    <td class="text-right"><%=formatnumber(entradas, 2)%></td>
                    <td class="text-right"><%=formatnumber(saidas, 2)%></td>
                    <td class="text-right"><%=formatnumber(resultado, 2)%></td>
                </tr>
				<%
            dist.movenext
            wend
            dist.close
            set dist=nothing
			TotalResultado = TotalEntradas-TotalSaidas
            %>
            </tbody>
            <tfoot>
            	<tr>
                	<th>Total</th>
                    <th class="text-right"><%=formatnumber(TotalEntradas,2)%></th>
                    <th class="text-right"><%=formatnumber(TotalSaidas,2)%></th>
                    <th class="text-right"><%=formatnumber(TotalResultado,2)%></th>
                </tr>
            </tfoot>
        </table>
    </div>
</div>
<hr />