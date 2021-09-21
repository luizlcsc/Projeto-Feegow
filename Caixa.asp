<!--#include file="connect.asp"-->
<form id="formCaixa" action="" method="post">
<%
set caixa = db.execute("select * from caixa where sysUser="&session("User")&" and isnull(dtFechamento)")
if caixa.eof then
	%>
    <div class="modal-header">
	    <h3 class="lighter blue"><i class="far fa-inbox"></i> Abertura de Caixa</h3>
    </div>
    <div class="modal-body">
        <div class="panel">
            <div class="panel-body">
              <div class="row">
                <div class="col-md-6">Usu&aacute;rio: <br>
                <strong><%=ucase(nameInTable(session("User")))%></strong> </div>
    	        <div class="col-md-6">Data de Abertura: <br>
                <strong><%=ucase(formatdatetime(date(),1))%></strong></div>
              </div>
                <hr class="short alt" />
              <div class="row">
      	        <%=quickField("currency", "SaldoInicial", "Saldo Inicial", 5, "0,00", "", "", "")%>
                <%
		        'verificar a que unidades este usuario pertence
		
		        set user = db.execute("select * from sys_users where id="&session("User"))
		        Tabela = lcase(user("Table"))
		        if Tabela="funcionarios" then
			        set fun = db.execute("select * from funcionarios where id="&user("idInTable"))
			        if not fun.eof then
				        Unidades = fun("Unidades")
			        end if
			        'response.Write("Unidades: "&fun("Unidades"))
		        end if
		        %>
                <div class="col-md-7">
                    <label>Conta do Caixa:</label><br>
                    <select class="form-control" name="ContaCorrenteID">
                    <%
                    TemCaixa=0
                    set unid = db.execute("select * from sys_financialcurrentaccounts where AccountType=1 and Empresa="&session("UnidadeID")&" and sysActive=1 order by AccountName")
                    while not unid.eof
                        TemCaixa=1
                        if (Tabela="funcionarios" and instr(Unidades, "|"&unid("Empresa")&"|")>0) or (Tabela="profissionais") then
                            %>
                            <option value="<%=unid("id")%>"><%=unid("AccountName")%></option>
                            <%
                        end if
                    unid.movenext
                    wend
                    unid.close
                    set unid=nothing
                    %>
                    </select>
                </div>
              </div>
            </div>
        </div>
    </div>
    <input type="hidden" name="Acao" value="Abrir">
    <div class="modal-footer">
    	<button class="btn btn-success pull-right" id="btnAbrirCaixa" <% if TemCaixa =0 then %> disabled <% end if %>><i class="far fa-inbox"></i> ABRIR CAIXA</button>
    </div>
    <%




else




	%>
    <div class="modal-header">
	    <h1 class="lighter blue">Fechamento de Caixa</h1>
    </div>
    <div class="modal-body">
      <div class="row">
        <div class="col-md-6">Usu&aacute;rio: <br>
        <strong><%=ucase(nameInTable(session("User")))%></strong> <small><code>#<%=session("CaixaID")%></code></small> </div>
    	<div class="col-md-6">Data de Abertura: <br>
        <strong><%=caixa("dtAbertura")%></strong></div>
      </div>
      <hr />
      
      <div class="clearfix form-actions">
      	<%=quickField("currency", "SaldoInicial", "Saldo Inicial", 5, caixa("SaldoInicial"), "", "", " disabled")%>
        <%
		'verificar a que unidades este usuario pertence
		
		set user = db.execute("select * from sys_users where id="&session("User"))
		if user("Table")="Funcionarios" then
			set fun = db.execute("select * from funcionarios where id="&user("idInTable"))
			'response.Write("Unidades: "&fun("Unidades"))
		end if
		%>
        <div class="col-md-7">
            <label>Conta do Caixa:</label><br>
            <select disabled class="form-control" name="ContaCorrenteID">
            <%
            set unid = db.execute("select * from sys_financialcurrentaccounts where id="&caixa("ContaCorrenteID")&" AND sysActive=1")
            while not unid.eof
				%>
				<option value="<%=unid("id")%>"><%=unid("AccountName")%></option>
				<%
            unid.movenext
            wend
            unid.close
            set unid=nothing
            %>
            </select>
        </div>
      </div>
      <%
	  set pen = db.execute("select m.id, m.Value, m.InvoiceID, m.ValorPago, p.NomePaciente from sys_financialmovement m left join pacientes p on p.id=m.AccountIDDebit where m.sysUser="&session("User")&" and m.CD='C' and m.Type='Bill' and m.CaixaID="&caixa("id")&" and m.Value > 0 and (isnull(m.ValorPago) or FLOOR(m.ValorPago)<FLOOR(m.Value)) and m.Date<=date(now())")
	  if not pen.eof then
	  %>
      <table class="table table-striped table-bordered">
      	<thead>
          <tr class="danger">
          	<th class="red" width="59%"><i class="far fa-exclamation-circle"></i> Pend&ecirc;ncias</th>
            <th class="red" width="20%">Valor</th>
            <th class="red" width="20%">Pendente</th>
            <th class="red" width="1%"></th>
          </tr>
        </thead>
        <tbody>
        <%
		cpen = 0
		while not pen.eof
		  if isnull(pen("ValorPago")) then
		  '	call getValorPago(pen("id"), pen("ValorPago"))
			ValorPago=0
		  else
			ValorPago=pen("ValorPago")
		  end if
		  cpen=cpen+1
		  %>
		  <tr>
            <td><%=pen("NomePaciente")%></td>
            <td class="text-right"><%=formatnumber(pen("Value"),2)%></td>
            <td class="text-right"><%=formatnumber(pen("Value")-ValorPago,2)%></td>
            <td><a href="?P=invoice&I=<%=pen("InvoiceID")%>&A=&Pers=1&T=C" class="btn btn-xs btn-success"><i class="far fa-edit"></i></a></td>
          </tr>
		  <%
		pen.movenext
		wend
		pen.close
		set pen=nothing
		%>
        </tbody>
        <tfoot>
        	<tr>
            	<th colspan="4"><%= cpen %> pend&ecirc;ncias</th>
            </tr>
        </tfoot>
      </table>
      <%
	  end if
	  %>
	  <br>
	  <%
	  if aut("aberturacaixinhaV")=1 then
	  %>
      <table class="table table-striped table-hover table-bordered">
      	<thead>
        	<tr class="success">
            	<th>Tipo</th>
                <th>Entradas</th>
                <th>Sa&iacute;das</th>
                <th>Saldo Final</th>
            </tr>
        </thead>
        <tbody>
        	<%
        	SaldoFinalCaixa= 0

			set mov = db.execute("select m.PaymentMethodID,"&_
			"-777 as Recebimentos, "&_ 
			"-777 as Pagamentos, "&_ 
			" pm.PaymentMethod "&_ 
			" from sys_financialmovement m "&_
			" left join sys_financialpaymentmethod pm on pm.id=m.PaymentMethodID "&_
			" where m.Type<>'Bill' and (AccountAssociationIDDebit=7 and AccountIDDebit="&caixa("id")&" or AccountAssociationIDCredit=7 and AccountIDCredit="&caixa("id")&" ) group by m.PaymentMethodID "&_ 
			" UNION ALL "&_
			"select mOutros.PaymentMethodID, ifnull(sum(mOutros.Value),0), 0, pmOutros.PaymentMethod from sys_financialmovement mOutros "&_ 
			" left join sys_financialpaymentmethod pmOutros on pmOutros.id=mOutros.PaymentMethodID "&_ 
			"where mOutros.PaymentMethodID not in(1, 2) and mOutros.CaixaID="&caixa("id")&_ 
			" group by mOutros.PaymentMethodID")
			SaldoFinalFinal = 0
			while not mov.eof
				Recebimentos = mov("Recebimentos")
				Pagamentos = ccur(mov("Pagamentos"))
                if Recebimentos=-777 then
                    set pRec = db.execute("select ifnull(sum(Value), 0) Recebimentos from sys_financialmovement where (Type='Pay' or Type='Transfer') and AccountAssociationIDDebit=7 and AccountIDDebit="&caixa("id")&" and PaymentMethodID="& mov("PaymentMethodID"))
                    Recebimentos = pRec("Recebimentos")
                end if
                if Pagamentos=-777 then
                    set pPag = db.execute("select ifnull(sum(Value), 0) Pagamentos from sys_financialmovement where (Type='Pay' or Type='Transfer') and AccountAssociationIDCredit=7 and AccountIDCredit="&caixa("id")&" and PaymentMethodID="& mov("PaymentMethodID"))
                    Pagamentos = pPag("Pagamentos")
                end if

				SaldoFinal = Recebimentos-Pagamentos


				SaldoFinalFinal = SaldoFinalFinal+SaldoFinal
				%>
				<tr data-payment-method="<%=mov("PaymentMethodID")%>">
					<td><%=mov("PaymentMethod")%>
                    <%
					if mov("PaymentMethodID")=1 then
					    SaldoFinalCaixa= SaldoFinalCaixa+SaldoFinal
						%><input type="hidden" name="Dinheiro" value="<%=SaldoFinal%>" />
                        <%
					end if%>
                    </td>
                    <td class="text-right"><%=formatnumber(Recebimentos,2)%></td>
                    <td class="text-right"><%=formatnumber(Pagamentos,2)%></td>
                    <td class="text-right"><%=formatnumber(SaldoFinal,2)%></td>
                </tr>
				<%
			mov.movenext
			wend
			mov.close
			set mov=nothing
			%>
        </tbody>
        <tfoot>
        	<th colspan="3">Total geral</th>
            <th class="text-right"><%=formatnumber(SaldoFinalFinal,2)%></th>
        </tfoot>
      </table>
      <%
      else
      %>
        <div class="alert alert-default">
            <strong>Atenção! </strong> Você precisa de permissão para visualizar os lançamentos.
        </div>
      <%
      end if
      %>
    </div>
    <input type="hidden" name="Acao" value="Fechar">
    <input type="hidden" name="idCaixa" value="<%=caixa("id")%>">
    <div class="modal-footer">

            <%
            if aut("aberturacaixinhaI")=1 or aut("|movementI|")=1 then
                %>
			    <button type="button" class="btn btn-warning btn-sm" onclick="transferir()"><i class="far fa-exchange"></i> Transferir</button>
			    <a href="./?P=invoice&T=D&I=N&Pers=1" class="btn btn-primary btn-sm"><i class="far fa-plus"></i> Despesa</a>
			    <%
			end if
            if aut("aberturacaixinhaV")=1 then
			%>
			<a href="./?P=MeuCaixa&Pers=1" class="btn btn-info btn-sm"><i class="far fa-reorder"></i> Detalhes</a>
			<%
			end if
			%>
		<% 
        if getConfig("DetalharFechamentoCaixa")="1" or getConfig("PermitirFechamentoDeCaixaValorAbaixo")<>"1" then %>
        	<button class="btn btn-success btn-sm" type="button" onclick="location.href='./?P=PreFechaCaixa&Pers=1'"><i class="far fa-inbox"></i> Fechar Caixa</button>
        <% else %>
        	<button class="btn btn-success btn-sm"><i class="far fa-inbox"></i> Fechar Caixa</button>
        <% end if %>

    </div>
	<%
end if
%>
</form>
<script type="text/javascript">
<!--#include file="jQueryFunctions.asp"-->

var $btnAbrirCaixa = $("#btnAbrirCaixa");

$("#formCaixa").submit(function(){
    <%
    if caixa.eof then
    %>
    $btnAbrirCaixa.attr("disabled",true);
    $.post("saveCaixa.asp", $("#formCaixa").serialize(), function(data, status){ eval(data) });
    <%
    else
    %>
    if(confirm("Tem certeza que deseja fechar o caixa? Ele não poderá ser reaberto.")){
        $btnAbrirCaixa.attr("disabled",true);
        $.post("saveCaixa.asp", $("#formCaixa").serialize(), function(data, status){ eval(data) });
    }
    <%
    end if
    %>
	return false;
});

function transferir(){
    $.post("transaction.asp", {
        transactionID: 0,
        transactionType: 3,
        PaymentMethodID: 1,
        TransactionValue: '',
        TransactionDate: '<%= date() %>',
        TransactionDescription: '',
        fromCaixa: 1,
        transactionAccountIDCredit: '7_<%= session("CaixaID") %>',
        max: '<%= SaldoFinalCaixa %>',
        transferenciaCaixa : "1"
    }, function(data){
        $("#modalCaixaContent").html(data);
    });
}

</script>