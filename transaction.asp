<!--#include file="connect.asp"-->
<%
transferenciaCaixa = ref("transferenciaCaixa")&""

if req("transactionID") = "" then
	transactionID = ref("transactionID")
	transactionType = ref("transactionType")
else
	transactionID = req("transactionID")
    if transactionID = "4" then
        transactionType = "4"
    else
	    transactionType = ""
    end if
end if
if transactionID="1" then
	title = "Novo Lan&ccedil;amento"
else
	title = "Detalhes do Lan&ccedil;amento"
end if

if req("Save")="Save" then

    'set ConfigSQL = db.execute("SELECT ConfirmarTransferencia FROM sys_config WHERE id=1")
    ConfirmarTransferencia=getConfig("ConfirmarTransferencia")

    'if not ConfigSQL.eof then
    '    if ConfigSQL("ConfirmarTransferencia")="S" then
    '        ConfirmarTransferencia=True
    '    end if
    'end if

    CaixaID=session("CaixaID")

	if ref("transactionType")="1" then
	    CaixaID=""
		if ref("transactionAction")="Credit" then
			creditAccount = ref("transactionAccountID")
			debitAccount = "0_0"
			reverseCreditAccount = "0_0"
			reverseDebitAccount = ref("transactionAccountID")
		else
			creditAccount = "0_0"
			debitAccount = ref("transactionAccountID")
			reverseCreditAccount = ref("transactionAccountID")
			reverseDebitAccount = "0_0"
		end if
	else
		creditAccount = ref("transactionAccountIDCredit")
		debitAccount = ref("transactionAccountIDDebit")
	end if
	if ref("transactionType")="1" and left(ref("transactionAccountID"), 2)="1_" then
		creditAccount = reverseCreditAccount
		debitAccount = reverseDebitAccount
	end if

	paymentMethodID = ref("transactionType")
	splCreditAccount = split(creditAccount, "_")
	splDebitAccount = split(debitAccount, "_")

    ' ######################### BLOQUEIO FINANCEIRO ########################################
    UnidadeID=session("UnidadeID")
    contabloqueadacred = verificaBloqueioConta(1, 1, creditAccount, UnidadeID,myDate(ref("TransactionDate")))
    contabloqueadadebt = verificaBloqueioConta(1, 1, debitAccount, UnidadeID,myDate(ref("TransactionDate")))
    if contabloqueadacred = "1" or contabloqueadadebt = "1" then
        %>
        showMessageDialog("Esta conta está BLOQUEADA e não pode ser alterada!");
        <%
        response.end
    end if
    ' #####################################################################################

    if paymentMethodID&"" = "1" then
        'Se a transferencia for em dinheiro, validar se o valor transferido é permitido
        'SELECT Value FROM sys_financialmovement WHERE TYPE = 'Pay' AND CaixaID = 18 AND PaymentMethodID = 1
        sqlTotalEmCaixa = "SELECT " &_
                            "(COALESCE((SELECT SUM(VALUE) totalEntrada FROM sys_financialmovement WHERE TYPE = 'Pay' AND CaixaID = 18 AND PaymentMethodID = 1), 0) - " &_
                            "COALESCE((SELECT SUM(VALUE) total FROM sys_financialmovement WHERE (TYPE = 'Bill' OR TYPE = 'Transfer') AND CaixaID = 18 AND PaymentMethodID = 1),0)) total" 
        set getTotalCaixa = db.execute(sqlTotalEmCaixa)
        if not getTotalCaixa.eof then 
            if ccur(ref("TransactionValue")) > ccur(getTotalCaixa("total")) then
                Sucesso= False
            end if
        end if
    end if

	gCurrency = session("DefaultCurrency")
	if splDebitAccount(0)="1" then
		set getCurrency = db.execute("select * from sys_financialCurrentAccounts where id="&splDebitAccount(1))
		DebitCurrency = getCurrency("Currency")
		if DebitCurrency<>session("DefaultCurrency") then
			gCurrency = DebitCurrency
		end if
	end if
'	if splCreditAccount(0)="1" then
'		set getCurrency = db.execute("select * from sys_financialCurrentAccounts where id="&splCreditAccount(1))
'		CreditCurrency = getCurrency("Currency")
'		if CreditCurrency<>session("DefaultCurrency") then
'			gCurrency = CreditCurrency
'		end if
'	else
		gCurrency = ref("Currency")
'	end if
	if ref("Rate")="" then
		saveRate = getRate()
	else
		saveRate = ref("Rate")
	end if

    Sucesso=True

    if ref("max")<>"" then
        if ccur(ref("TransactionValue")) > ccur(ref("max")) and splCreditAccount(0)="7" and ref("PaymentMethodID")="1" then
            Sucesso= False
        end if
    end if

    if Sucesso then

        outroUsuario = ""
        CaixaID=session("CaixaID")
        UnidadeID=session("UnidadeID")
        set CaixaSQL = db.execute("SELECT c.id CaixaID, c.sysUser UserID, aa.Empresa FROM caixa c LEFT JOIN sys_financialcurrentaccounts aa ON aa.id = c.ContaCorrenteID WHERE c.id="&splCreditAccount(1))
        if not CaixaSQL.eof then
            if CaixaSQL("UserID")&"" <> Session("user")&"" then
                outroUsuario = CaixaSQL("UserID")&""
                CaixaID = CaixaSQL("CaixaID")
                UnidadeID=CaixaSQL("Empresa")
            end if
        end if

        'response.write("aqui")
        'response.write(splDebitAccount(0))
        if ConfirmarTransferencia and (splDebitAccount(0)=1 or splDebitAccount(0)=7 or (splCreditAccount(0) =7 and outroUsuario <> "")) then
            sqlFilaTransferecia = "INSERT INTO filatransferencia (Descricao, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, PaymentMethodID, Value, Date, CaixaID, sysUser, UnidadeID) VALUES "&_
            "('"&ref("TransactionDescription")&"', '"&splCreditAccount(0)&"', '"&splCreditAccount(1)&"', '"&splDebitAccount(0)&"', '"&splDebitAccount(1)&"', '"&ref("PaymentMethodID")&"', '"&treatVal(ref("TransactionValue"))&"', '"&myDate(ref("TransactionDate"))&"', "&treatvalnull(CaixaID)&", "&session("User")&", "&treatvalzero(UnidadeID)&")"
            
            'solicita confirmacao da transferencia
            if splDebitAccount(0)=1 then
                'caixa fisico/conta bancaria
                set ContaSQL = db.execute("SELECT UsuariosConfirmadores FROM sys_financialcurrentaccounts WHERE id="&splDebitAccount(1))
                if not ContaSQL.eof then
                    UsuariosConfirmadores = ContaSQL("UsuariosConfirmadores")&""
                end if
            elseif splDebitAccount(0)=7  then
                set CaixaSQL = db.execute("SELECT sysUser FROM caixa WHERE id="&splDebitAccount(1))
                if not CaixaSQL.eof then
                    UsuariosConfirmadores = CaixaSQL("sysUser")&""
                end if
            elseif splCreditAccount(0) =7 then
                set CaixaSQL = db.execute("SELECT sysUser FROM caixa WHERE id="&splCreditAccount(1))
                if not CaixaSQL.eof then
                    if CaixaSQL("sysUser")&"" <> Session("user")&"" then
                        UsuariosConfirmadores = CaixaSQL("sysUser")&""
                    end if
                end if
            end if

            db.execute(sqlFilaTransferecia)

            set FilaTransferenciaSQL = db.execute("SELECT id FROM filatransferencia ORDER BY id DESC LIMIT 1")

            FilaTransferenciaID = FilaTransferenciaSQL("id")

            UsuariosConfirmadores = replace(UsuariosConfirmadores,"|","")

            UsuariosConfirmadoresSplt = split(UsuariosConfirmadores, ",")
            for i=0 to ubound(UsuariosConfirmadoresSplt)
                UsuarioID=UsuariosConfirmadoresSplt(i)
                Metadata= "R$ "& fn(ref("TransactionValue")) & " -> "& nameInAccount(splDebitAccount(0)&"_"&splDebitAccount(1))

                call addNotificacao(1, UsuarioID, FilaTransferenciaID, 1, 1, Metadata)
                userName=nameInTable(UsuarioID)

            next
            %>
            showMessageDialog("Transferência enviada para aprovação de <strong><%=userName%></strong>.", "warning", "Aguardando aprovação");
            <%
        else
            disponibilizarsaldo = ref("disponibilizarsaldo")

            CD = ""
            CategoryID = ""
            if disponibilizarsaldo = "N" then 
                CD = "T"
            end if
            UnidadeID = 0
            if ref("UnidadeID")&""<>"" then
                UnidadeID = ref("UnidadeID")
            end if
            if ref("transactionAction")&"" = "Credit" then 
                CategoryID = (ref("CategoriaIncome"))
            elseif ref("transactionAction")&"" = "Debit" then 
                CategoryID = (ref("CategoriaExpensive"))
            end if
        
            sql = "insert into sys_financialMovement (Name, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, PaymentMethodID, Value, Date, CD, Type, Currency, Rate, CaixaID, sysUser, UnidadeID, CategoryID) values ('"&ref("TransactionDescription")&"', '"&splCreditAccount(0)&"', '"&splCreditAccount(1)&"', '"&splDebitAccount(0)&"', '"&splDebitAccount(1)&"', '"&ref("PaymentMethodID")&"', '"&treatVal(ref("TransactionValue"))&"', '"&myDate(ref("TransactionDate"))&"', '"&CD&"', 'Transfer', '"&gCurrency&"', '"&treatVal(saveRate)&"', "&treatvalnull(CaixaID)&", "&session("User")&", "&treatvalzero(UnidadeID)&", "&treatvalnull(CategoryID)&")"
        '	response.Write(sql)
            db_execute(sql)
            %>
                showMessageDialog("Transferência enviada.", "success");
                //getStatement($("#StatementAccountID").val(), '');
                $("#Filtrate").click();
            <%
        end if
    end if

    if Sucesso then
    %>
        $("#modalCaixa").modal("hide");
        $("#modal-table").modal("hide");
    <%
    else
    %>
        showMessageDialog("Valor maior que o permitido", "danger");
    <%
    end if
Response.End
end if

%>
<form name="formTransaction" id="formTransaction" action="" method="post">
<input type="hidden" name="transactionID" id="transactionID" value="<%= transactionID %>">
<input type="hidden" name="max" value="<%= ref("max") %>">
	<div class="modal-header">
		<button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
		<h4 class="modal-title"><%= Title %></h4>
	</div>



	<div class="modal-body">
      <div class="row">
		<div class="col-md-5">
          <div class="control-group"><label class="control-label bolder blue">Tipo de Lan&ccedil;amento</label>
          <%
          readonly = ""
          if transferenciaCaixa = "1" then 
            readonly = " readonly "
            set getTransactionType = db.execute("select * from sys_financialTransactionType where TransactionName = 'Transferência' order by id")
          else
          'wander da skin laser precisa da opcao
            if getconfig("liberaacertodesaldo") = 1 or session("User")=82302 then
              filtroacertodesaldo = ""
            else 
               filtroacertodesaldo = " where TransactionName <> 'Acerto de Saldo' "
            end if 
            set getTransactionType = db.execute("select * from sys_financialTransactionType "&filtroacertodesaldo&" order by id")
          end if
		  
		  while not getTransactionType.eof

		    if getTransactionType("id")=4 or getTransactionType("id")=3 or (getTransactionType("id")=1 and aut("|movementI|")=1) then
                ExibeRadio = True
                checked = ""
                contaPaciente = False
                PacienteID = req("PacienteID")
                if PacienteID<>0 and getTransactionType("id")<>4 then
                    ExibeRadio = False
                elseif PacienteID<>0 and getTransactionType("id")=4 then
                    checked = "checked"
                    contaPaciente = True
                end if
                if ExibeRadio = True then
                    %><div class="radio"><label><input name="transactionType" type="radio" class="ace postTransaction" <%=checked%> value="<%=getTransactionType("id")%>"<% If transactionType=cstr(getTransactionType("id")) Then
                        TransactionDescription = getTransactionType("TransactionName")
                    %> checked<%end if%>><span class="lbl"> <%=getTransactionType("TransactionName")%></span></label></div>
                    <%
                end if
			end if
		  getTransactionType.movenext
		  wend
		  getTransactionType.close
		  set getTransactionType = nothing
		  %>
          </div>
        </div>
        <div class="col-md-7">
        	<%
			select case transactionType
			case "1" %>
              <div>
            	<label><input name="transactionAction" onchange='cPlan()'  type="radio" class="ace" value="Credit"<% If ref("transactionAction")="Credit" or ref("transactionAction")="" Then
					 %> checked<%end if%>><span class="lbl"> Cr&eacute;dito</span></label>
            	<label><input name="transactionAction" onchange='cPlan()'  type="radio" class="ace" value="Debit"<% If ref("transactionAction")="Debit" Then
					 %> checked<%end if%>><span class="lbl"> D&eacute;bito</span></label>
               </div>
               <div>
                <label>Conta</label>
                <%=selectInsertCA("", "transactionAccountID", ref("transactionAccountID"), "5, 4, 3, 2, 6, 1", "", " onchange='cPlan()' ", "")%>
               </div>
               <div>
               <label>Unidade</label>
               <%=quickField("empresa", "UnidadeID", "", 12, session("UnidadeID"), "", "", "")%>
               </div>
               <div>
                <label>Categoria</label>
                <div class="income">
                <% call quickField("simpleSelect", "CategoriaIncome", "", 12, CategoriaIncome, "select id, Name from sys_financialincometype where sysActive=1 order by Name", "Name", " ") %>
                </div>
                <div class="expensive" style="display:none">
                <% call quickField("simpleSelect", "CategoriaExpensive", "", 12, CategoriaExpensive, "select id, Name from sys_financialexpensetype where sysActive=1 order by Name", "Name", " ") %>
                </div>
               </div>
                <div>
                <label>Disponibilizar este saldo?</label><br>
                <label><input name="disponibilizarsaldo"   type="radio" class="ace" value="S"<% If ref("disponibilizarsaldo")="S" or ref("disponibilizarsaldo")="" Then
					 %> checked<%end if%>><span class="lbl"> SIM</span></label>
            	<label><input name="disponibilizarsaldo"   type="radio" class="ace" value="N"<% If ref("disponibilizarsaldo")="N" Then
					 %> checked<%end if%>><span class="lbl"> NÃO</span></label>
               </div>
                <%
			case "3", "5", "6", "7", "8"
				%>
               <div>
                <label>Transferido de</label> <br />
				<%=selectInsertCA("", "transactionAccountIDCredit", ref("transactionAccountIDCredit"), "5, 4, 2, 6, 1, 7", "", " required  onchange='cPlan()' " & readonly, "")%>
               </div>
               <div>
                <label>Para</label> <br />
                <%
                    if aut("|movementI|")=0 then
                    contasPara="1, 7, 5"
                else
                    contasPara="5, 4, 2, 6, 1, 7"
                end if
                %>
                <%=selectInsertCA("", "transactionAccountIDDebit", ref("transactionAccountIDDebit"), contasPara, "", " required  onchange='cPlan()' ", "")%>
               </div>
				<%

            case "4"
                readonly = ""
                if aut("|movementI|")=0 or aut("|transferirI|")=0 then
                    readonly = " readonly "
                end if
				%>
               <div>
                    <label>Saindo de</label> <br />
                    <%=selectInsertCA("", "transactionAccountIDCredit", ref("transactionAccountIDCredit"), "3", "", " required  onchange='cPlan()' " & readonly, "")%>
               </div>
               <div>
                    <label>Entrando em</label> <br />
                    <%
                    if contaPaciente <> False then
                        set NomePacienteSQL = db_execute("SELECT NomePaciente FROM pacientes WHERE id="&PacienteID)
                    %>  
                        <div class="col-md-12 input-group">
                            <input type="text" class="form-control" value="<%=NomePacienteSQL("NomePaciente")%>" disabled>
                            <input type="hidden" name="transactionAccountIDDebit" id="transactionAccountIDDebit" value="3_<%=PacienteID%>">
                        </div>
                    <%else%>
                        <%=selectInsertCA("", "transactionAccountIDDebit", ref("transactionAccountIDDebit"), "3", "", " required  onchange='cPlan()' " & readonly, "")%>
                    <%end if%>
               </div>
				<%
			end select
			%>
			<div class="row">
			<%
			   sqlPaymentMethods = "select * from sys_financialpaymentmethod order by PaymentMethod"
               if transferenciaCaixa="1" then
                    CaixaID = session("CaixaID")
                    sqlPaymentMethods = "SELECT pm.* from sys_financialmovement fm "&_
                    "INNER JOIN sys_financialpaymentmethod pm ON fm.PaymentMethodID = pm.id "&_
                    "WHERE fm.Type IN ('Pay','Transfer') and fm.CaixaID = "&CaixaID&" GROUP BY pm.id"
                end if
                if transactionType <> "4" then
            %>
				    <%=quickField("simpleSelect", "PaymentMethodID", "Forma", 12, "",sqlPaymentMethods, "PaymentMethod", " required empty ")%>
                <%end if%>
            </div>
			<%
			if TransactionDate = "" then
				TransactionDate = date()
			else
				TransactionDate = ref("TransactionDate")
			end if
			%>
               <div class="row">
               		<%= quickField("currency", "TransactionValue", "Valor", 6, ref("TransactionValue"), "", "", " required ") %>
               		<%= quickField("datepicker", "TransactionDate", "Data", 6, TransactionDate, "", "", " required ") %>
               </div>
              <%if transactionType <> "4" then%>
                <div>
                    <label>Descri&ccedil;&atilde;o</label>
                    <input required class="form-control" name="TransactionDescription" id="TransactionDescription" value="<%= TransactionDescription %>">
                </div>
              <%end if%>
              <div id="divCategoriaID"></div>
          </div>
        </div>
      </div>
	<div class="modal-footer no-margin-top">
		<button class="btn btn-sm btn-default pull-right" data-dismiss="modal">
			<i class="far fa-remove"></i>
			Fechar
		</button>
		<button  id="btnSaveTransaction" class="btn btn-sm btn-primary pull-right mr10">
        <i class="fa fa-check"></i>
        Salvar</button>
	</div>
</form>

<script type="text/javascript">

    function cPlan() {

        setTimeout(function(){
            $.post("transactionPlan.asp", $("#formTransaction").serialize(),
                function (data) {
                    $("#divCategoriaID").html(data);
            });
        }, 1000);
    }

    jQuery(function ($) {

        $("input[name='transactionAction']").on('change', function(){
            var value = $(this).val();
            $(".income, .expensive").hide();
            
            if(value == "Credit"){
                $(".income").show();
            }else if(value == "Debit"){
                $(".expensive").show();
            }
        })


	$(".chosen-select").chosen();
	$('.postTransaction').change(function(){
		transaction('','',true);
	});
	$('#transactionAccountID').change(function(){
		transaction('','',true);
	});
	$('#formTransaction').submit(function(){
		transaction('', 'Save', true);
		return false;
	});
		$('.date-picker').datepicker({autoclose:true}).next().on(ace.click_event, function(){
		$(this).prev().focus();
	});
	$(".input-mask-brl").maskMoney({prefix:'', thousands:'.', decimal:',', affixesStay: true});



	<!--#include file="financialCommomScripts.asp"-->
});
</script>