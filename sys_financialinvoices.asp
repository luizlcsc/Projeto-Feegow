<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<%
if req("T")="C" then
	titulo = "Conta a Receber"
	subtitulo = "administra&ccedil;&atilde;o de receita"
else
	titulo = "Conta a Pagar"
	subtitulo = "administra&ccedil;&atilde;o de despesa"
end if
%>
<%
tableName=req("P")
T=req("T")
id=req("I")

if id="N" then
	sqlVie = "select id, sysUser, sysActive from "&tableName&" where sysUser="&session("User")&" and sysActive=0 and CD='"&T&"'"
	set vie = db.execute(sqlVie)
	if vie.eof then
		db_execute("insert into "&tableName&" (sysUser, sysActive, CD, Recurrence, RecurrenceType, Value) values ("&session("User")&", 0, '"&T&"', 1, 'm', 0)")
		set vie = db.execute(sqlVie)
	end if
	response.Redirect("?P="&tableName&"&I="&vie("id")&"&A="&req("A")&"&Pers=1&T="&T)'A=AgendamentoID quando vem da agenda
else
	set data = db.execute("select * from "&tableName&" where id="&id)
	if data.eof then
		response.Redirect("?P="&tableName&"&I=N&Pers=1&T="&T)
	end if
end if

if req("A")<>"" then
	set age = db.execute("select * from agendamentos where id="&req("A"))
	if not age.eof then
		set vcaAberto = db.execute("select * from sys_financialinvoices where CD='C' and AssociationAccountID=3 and AccountID="&age("PacienteID")&" and Sta='A'")
		if vcaAberto.eof then
			db_execute("insert into sys_financialinvoices (`Name`,AccountID, AssociationAccountID, Value, Tax, Currency, CompanyUnitID, Recurrence, RecurrenceType, CD, Sta, sysActive, sysUser) values ('Gerado a partir de agendamento {2}',"&age("PacienteID")&", 3, '"&calculaovalorbaseadonositensadicionados&"', 1, 'BRL', 0, 1, 'm', 'C', 'A', 1, "&session("User")&")")
			set pult = db.execute("select id from sys_financialinvoices where AccountID="&age("PacienteID")&" order by id desc LIMIT 1")
			InvoiceID = pult("id")
		else
			InvoiceID = vcaAberto("id")
		end if
		db_execute("insert into itensinvoices (InvoiceID, Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Desconto, Executado, DataExecucao, HoraExecucao, GrupoID, AgendamentoID, sysUser) values ("&InvoiceID&", 'S', 1, 0, "&age("TipoCompromissoID")&", "&seestavanoparticularvalordaagendaseconveniovalordoprocedimento&", 0, 'S', "&mydateNull(age("Data"))&", "&myTime(age("Hora"))&", "&gravaogrupoid&", "&age("id")&", "&session("User")&")")
	end if
end if

set reg = db.execute("select * from sys_financialInvoices where id="&id)
if reg.eof then
	response.Redirect("?P="&req("P")&"&T="&req("T")&"&I=N&Pers=1")
else
	Name = reg("Name")
	AccountID = reg("AccountID")
	AssociationAccountID = reg("AssociationAccountID")
	Value = reg("Value")
	Tax = reg("Tax")
	rCurrency = reg("Currency")
	Description = reg("Description")
	AccountPlanID = reg("AccountPlanID")
	CompanyUnitID = reg("CompanyUnitID")
	Recurrence = reg("Recurrence")
	RecurrenceType = reg("RecurrenceType")
	sysActive = reg("sysActive")
	if T<>reg("CD") then
		response.Redirect("?P="&req("P")&"&I="&reg("id")&"&Pers=1&T="&reg("CD"))
	end if
end if

if req("PacienteID")<>"" then
	AccountID = req("PacienteID")
	AssociationAccountID = 3
end if

if T="C" then
	CategoryTable = "sys_financialIncomeType"
	CreditorOrDebtor = "Receber de"
else
	CategoryTable = "sys_financialExpenseType"
	CreditorOrDebtor = "Pagar a"
end if

if sysActive=0 then
	Installments = 1
else
	set countInstallments = db.execute("select count(*) as TOTAL from sys_financialMovement where InvoiceID="&id)
	Installments = ccur(countInstallments("TOTAL"))
end if	

if 1=2 and ref("E")="E" then
	refName = ref("Name")
	refValue = ref("Value")
	splAccount = split(ref("Account"), "_")
	Acccount = splAccount(0)
	AssociationAccount = splAccount(1)
	Tax = 1
	refCurrency = ref("Currency")
	refDescription = ref("Description")
	AccountPlan = ref("AccountPlan")
	CompanyUnit = ref("CompanyUnit")
	Recurrence = ref("Recurrence")
	RecurrenceType = ref("RecurrenceType")
	
	sqlUpdate = "Name='"&refName&"', Account='"&refName&"', AssociationAccount='"&refName&"', Value='"&refName&"', Tax='"&refName&"', Currency='"&refName&"', Description='"&refName&"', AccountPlan='"&refName&"', CompanyUnit='"&refName&"', Recurrence='"&refName&"', RecurrenceType='"&refName&"',"
	sqlUpdate = "update "&tableName&" set "&sqlUpdate&" sysActive=1 where id="&id
	db_execute(sqlUpdate)
	response.Redirect("?P="&tableName)
end if
%>

<script language="javascript">
function replaceAll(string, token, newtoken) {
	while (string.indexOf(token) != -1) {
 		string = string.replace(token, newtoken);
	}
	return string;
}

<%
'if sysActive=0 then%>
$(document).ready(function(){
  $(".Installments").change(function(){
	if($("#sysActive").val()=='0'){
		$.ajax({
			   type:"post",
			   url:"sys_financialInstallments.asp?I=<%=id%>",
			   data:$("#forminvoice").serialize(),
			   success:function(data){
				  $("#divInstallments").html(data);
			   }
		});
	}
  });
});

$(document).ready(function(){





if(<%= Installments %><2){$(".divRecurrence").slideUp(500);}

$("#Installments").change(function(){
	intervalo();
});

/*$('#PaymentMethod').change(function(){
		$.post("financialPaymentAccounts.asp",{
			   PaymentMethod:$("#PaymentMethod").val(),
			   T:$("#T").val(),
			   },function(data,status){
		  $("#divPaymentMethod").html(data);
		});
});*/

$('#StatementTab').click(function(){
		getStatement($("#AccountID").val(), '', '');
	});
});

<%
if sysActive=0 then
	classInstallments = "Installments"
End If %>

function callInstallments(){
    $.ajax({
		   type:"post",
		   url:"sys_financialInstallments.asp?I=<%=id%>",
		   data:$("#forminvoice").serialize(),
		   success:function(data){
		      $("#divInstallments").html(data);
		   }
    });	
}


function saveInvoice(){
	var countInstallmentValues = 0;
	$(".InstallmentValues").each(function() {
		var InstallmentValue = replaceAll($(this).val(), ".", "");
		InstallmentValue = parseFloat(replaceAll(InstallmentValue, ",", "."));
		countInstallmentValues += InstallmentValue;
	});

	var valToConfer = replaceAll($("#Value").val(), ".", "");
	var valToConfer = replaceAll(valToConfer, ",", ".");
	valToConfer = 
	valToConfer = parseFloat(valToConfer);
	if( countInstallmentValues<(valToConfer-0.05) || countInstallmentValues>(valToConfer+0.05) ){
		var erro = 'A soma das parcelas não confere com o valor da conta.';
	}
	if($("#AccountID").val()==""){
		var erro = 'Preencha a conta.';
	}
	if($("#Value").val()=="0,00"){
		var erro = 'Adicione itens com valor para salvar a conta.';
	}
	if(erro != null){
		alert(erro);
	}else{
		var dados = $('#forminvoice').serialize();
		$.ajax({
			type: "POST",
			url: "saveInvoice.asp",
			data: dados,
			success: function( data )
			{
				eval(data);
				$(".divRecurrence").slideUp(500);
				//$("#Value").removeClass('form-control input-mask-brl Installments');
				$("#divSpinnerInstallments").slideUp(500);
				$("#sysActive").val('1');
				callInstallments();
			}
		});
	}
}

<!--#include file="financialCommomScripts.asp"-->

function checkToPay(){
	var dados = $('#forminvoice').serialize();
	$.ajax({
		type: "POST",
		url: "financialFunctionPayment.asp",
		data: dados,
		success: function( data )
		{
		  $("#divPayment").html(data);	  
		}
	});
}

function FinancialValuePayment(){
	$.ajax({
		type: "POST",
		url: "FinancialValuePayment.asp",
		data: $('#forminvoice').serialize(),
		success: function( data )
		{
		  $("#ValorPagamento").html(data);
		  //alert(data);
		}
	});
}

function makePayment(){
	if($("#PaymentMethod").val()!="0"){
		var dados = $('#forminvoice').serialize();
		$.ajax({
			type: "POST",
			url: "makePayment.asp",
			data: dados,
			success: function( data )
			{
			  $("#divPayment").html('Pagamento lan&ccedil;ado com sucesso!');
			  callInstallments();
			}
		});
	}else{
		alert('Preencha a forma de pagamento.');
	}
}

function discountOverbalance(){
	var dados = $('#forminvoice').serialize();
	$.ajax({
		type: "POST",
		url: "discountOverbalance.asp",
		data: dados,
		success: function( data )
		{
		  $("#divPayment").html('Pagamento lan&ccedil;ado com sucesso!');
		  callInstallments();
		}
	});
}

</script>
<form id="forminvoice" method="post" action="">
<div class="row">
    <div class="col-xs-9">
        <div class="tabbable">
            <ul class="nav nav-tabs" id="myTab">
                <li class="active">
                    <a data-toggle="tab" href="#Conta">
                        <i class="<%if T="D" then%>red<%else%>green<%end if%> icon-money bigger-110"></i>
                        <%=Titulo%>
                    </a>
                </li>

                <li>
                    <a data-toggle="tab" href="#Extrato" id="StatementTab">
                        <i class="green icon-exchange bigger-110"></i>
                        Extrato
                    </a>
                </li>
            </ul>

            <div class="tab-content">
            	<div id="Conta" class="tab-pane active">
                	<div class="clearfix form-actions">
                    	<div class="col-md-7">
						
                        	<label><%= CreditorOrDebtor %></label><br />
                        	<%call selectCurrentAccounts("AccountID", "5, 4, 3, 2, 6, 1", AssociationAccountID&"_"&AccountID, "")%>
                        </div>
                        <div class="col-md-2 pull-right">
                        	<label>&nbsp;</label> <br />
                            <button type="button" id="btnSave" class="btn btn-primary btn-block" onclick="saveInvoice();"><i class="far fa-save bigger-110"></i> SALVAR</button>
                            <input type="hidden" name="InvoiceID" id="InvoiceID" value="<%=req("I")%>" />
                            <input type="hidden" name="CompID" id="CompID" value="<%=req("CompID")%>" />
                            <input type="hidden" name="T" id="T" value="<%=req("T")%>" />
                            <input type="hidden" name="sysActive" id="sysActive" value="<%= sysActive %>" />
                            <input type="hidden" name="TriedCheckbox" id="TriedCheckbox" value="" />
                            <input type="hidden" name="Currency" id="Currency" value="BRL" />
                        </div>
                    </div>
                	<div class="row">
                    	<div class="col-md-12" id="itensInvoice">
							<%server.Execute("itensInvoice.asp")%>
                        </div>
                    </div>
                    <div class="row">
                    	<div class="col-md-12">
                        </div>
                    </div>
                	<div class="row">
                        <div class="col-md-12">
                           <!-- begin installments --

							<%if 1=2 then%>
                            <div class="alert well-sm alert-warning">
                            <button class="close" data-dismiss="alert" type="button">
                            <i class="far fa-remove"></i>
                            </button>
                            <strong>
                            <i class="far fa-exclamation"></i>
                            </strong>
                            Pagamentos vencidos.
                            <button class="btn btn-warning btn-sm">Visualizar</button>
                            </div>
                            <% End If %>
							-->

                            <div class="col-md-12">
                                <div class="row">
                                    <div class="widget-box transparent">
                                    	<div class="widget-header">
                                            <h4 class="lighter">Pagamento <small><i class="far fa-double-angle-right"></i> Selecione abaixo a forma de pagamento</small></h4>
                                        </div>
                                        <div class="widget-body">
 											<div class="widget-main padding-6 no-padding-left no-padding-right">
                                        		<div class="alert alert-success col-md-12 hidden">
                                        			<!--#include file="SpinnerParcelas.asp"-->
                                            	</div>
                                                <div class="alert alert-success col-md-12">
                                                	<select>
                                                    	<option>Selecione</option>
                                                        <%
														set forma = db.execute("select f.*, m.PaymentMethod from sys_formasrecto f left join sys_financialpaymentmethod m on m.id=f.MetodoID order by PaymentMethod")
														while not forma.eof
															spl = split(forma("Contas"), ", ")
															for i=0 to ubound(spl)
																if spl(i)<>"" then
																	conta = replace(spl(i), "|", "")
																	if isnumeric(conta) then
																		set contas = db.execute("select * from sys_financialcurrentaccounts where id="&conta)
																		if not contas.eof then
																			%>
																			<option><%=forma("PaymentMethod")%> - <%=contas("AccountName")%></option>
																			<%
																		end if
																	end if
																end if
															next
														forma.movenext
														wend
														forma.close
														set forma=nothing
														%>
                                                    </select>
                                                </div>
                                            </div>
 											<div class="row">
                                                <div class="col-md-12" id="divInstallments">
		                            				<%server.Execute("sys_financialinstallments.asp")%>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
            

                           <!-- installments ends -->
                        </div>
                    </div>
                	<div class="row">
                    	<div class="col-md-6"><label>Observa&ccedil;&otilde;es</label><textarea class="form-control limited" name="Name" id="Name"><%= Name %></textarea></div>
                        <div class="col-md-6">
                        	<%= selectInsert("Unidade", "CompanyUnitID", CompanyUnitID, "sys_financialcompanyunits", "UnitName", "", " placeholder='Empresa Principal'", "") %>
                        </div>
                    </div>
                </div>
            	<div id="Extrato" class="tab-pane">
                Extrato.
                </div>
            </div>
        </div>
    </div><!-- /span -->
    <div class="col-xs-3"><!-- payment column begins -->
        <div class="row">
            <h3 class="header smaller lighter blue">Pagamento<small> <i class="far fa-double-angle-right"> </i> Selecione para pagar</small></h3>
        </div>
        
        <div id="divPayment">
        <span class="label arrowed">Marque ao lado o que deseja pagar</span>
        </div>
    </div><!-- payment column ends -->
</div>
<script language="javascript">
//verify if it's needed
function check(field){
	if(document.getElementById(field).checked==true){
		document.getElementById(field).checked=false;
	}else{
		document.getElementById(field).checked=true;
	}
}

callInstallments();

	function addParcela(){
		var num = $("#Installments").val();
		$("#Installments").val(parseInt(num)+1);
		callInstallments();
		intervalo();
	}
	
	function intervalo(){
		if($("#Installments").val()==1){
			$(".divRecurrence").slideUp(500);
		}else{
			$(".divRecurrence").slideDown(500);
		}
	}

function item(TipoItem, TipoAcao, I){
	$("#modal-table").modal("show");
	$("#modal").html("Carregando...");
	$.ajax({
		   type:"POST",
		   url:"modalItensInvoice.asp?InvoiceID=<%=id%>&TipoItem="+TipoItem+"&TipoAcao="+TipoAcao+"&I="+I,
		   data:$("#forminvoice").serialize(),
		   success:function(data){
			   $("#modal").html(data);
		   }
		   });
}

function atualizaItens(){
	$.ajax({
		   type:"POST",
		   url:"itensInvoice.asp?<%=request.QueryString%>",
		   data:$("#forminvoice").serialize(),
		   success:function(data){
			   $("#itensInvoice").html(data);
			   callInstallments();
		   }
		   });
}

function removeItem(Tipo, ItemID){
	if(Tipo=='Item'){
		var msg = 'Tem certeza de que deseja excluir este item?';
	}else{
		var msg = 'Tem certeza de que deseja excluir todos os itens listados acima?';
	}
	if(confirm(msg)){
			   $.ajax({
			   type:"POST",
			   url:"invoiceRemoveItem.asp?Tipo="+Tipo+"&ItemID="+ItemID,
			   success:function(data){
				   atualizaItens();
			   }
			   });
	}
}

<%if sysActive=0 then%>
$("#ValueInstallment1").val($("#Value").val());
<%end if%>
</script>
</form>

<!--#include file="modal.asp"-->