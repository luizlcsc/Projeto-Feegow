<!--#include file="connect.asp"-->
<div class="panel-heading">
	<span class="panel-title">Pagamento</span>
	<span class="panel-controls">
		<button class="btn btn-sm btn-default" onClick="$('.parcela').prop('checked', false); $('#pagar').fadeOut();" type="button"><i class="far fa-remove"></i> Cancelar</button>
	</span>
</div>









<%
RestringirFormasDeRecebimento= getConfig("RestringirFormasDeRecebimento")

BandeiraCartaoObrigatorio = 0
if getConfig("ObrigarBandeiraCartao")="1" then
    BandeiraCartaoObrigatorio = 1
end if
NumeroAutorizacaoObrigatorio = 0
if getConfig("ObrigarNumeroAutorizacao")="1" then
    NumeroAutorizacaoObrigatorio = 1
end if

if req("UnidadeID")="" then
    UnidadeID = session("UnidadeID")
else
    UnidadeID = req("UnidadeID")
end if

set StoneInfo = db.execute("SELECT * from stone_codes WHERE UnidadeID="&UnidadeID)
if not StoneInfo.eof then
    StoneCode=StoneInfo("StoneCode")
end if

CD = req("T")
Parcelas = replace(ref("Parcela"), "|", "")

ValorPagto = 0

set InvoiceSQL = db.execute("SELECT InvoiceID FROM sys_financialmovement WHERE id IN ("&Parcelas&")")
if not InvoiceSQL.eof then
    InvoiceID=InvoiceSQL("InvoiceID")
end if

set movs = db.execute("select ( Value - ifnull(ValorPago,0) ) Pendente, AccountAssociationIDDebit, AccountAssociationIDCredit, AccountIDDebit, AccountIDCredit, Date from sys_financialmovement WHERE id IN("&Parcelas&")")
while not movs.eof
	ValorPagto = ValorPagto + movs("Pendente")
    if CD="C"then
	    AssContaID = movs("AccountAssociationIDDebit")
	    ContaID = movs("AccountIDDebit")
    else
	    AssContaID = movs("AccountAssociationIDCredit")
	    ContaID = movs("AccountIDCredit")
    end if
    DataCheque = movs("Date")
movs.movenext
wend
movs.close
set movs=nothing




'------> pegando os creditos
if 1=1 then
sqlMovCred = "select m.*, (select sum(DiscountedValue) from sys_financialdiscountpayments where MovementID=m.id) as soma from sys_financialmovement m where ((m.AccountAssociationIDCredit="&AssContaID&" and m.AccountIDCredit="&ContaID&") or (m.AccountAssociationIDDebit="&AssContaID&" and m.AccountIDDebit="&ContaID&")) and m.Type in('Pay', 'Transfer') and (m.CD != 'T' OR m.CD IS NULL) "
'response.Write( sqlMovCred )
set mov = db.execute(sqlMovCred)

%>
<div class="conteudo-creditos">
<%
		while not mov.eof
			valor = mov("Value")
			soma = mov("soma")

			if isnull(soma) then soma=0 end if

			valor = round(valor,2)
			soma = round(soma,2)

            if valor>soma then
				if headCredito = "" then
				%>
				<form id="frmCredito" action="" method="post">
                <div class="modal-body">
                    <div class="widget-box">
	                    <div class="widget-header widget-hea1der-small header-color-green">
		                    <h6>CRÉDITOS DISPONÍVEIS</h6>

		                
	                    </div>

	                    <div class="widget-body">
		                    <div class="widget-main padding-4">
			                    <div class="slim-scroll" data-height="125">
				                    <div class="content" id="Credits">
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
                                    <tbody>
					                <%
				    headCredito = "S"
				end if
				credito = valor-soma
				%>
				                        <tr>
					                        <td><label><input type="radio" class="ace credito" id="Credito" name="Credito" value="<%=mov("id")&"_"&formatnumber(credito,2)%>" /><span class="lbl"></span></label></td>
					                        <td class="text-right"><%=mov("Date")%></td>
					                        <td><%=mov("id")%> - <%=mov("Name")%></td>
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
                    <div id="pagtoCredito" class="alert alert-info mt10">
    	                <%server.Execute("calcCredito.asp")%>
                    </div>
                                </div></div></div></div>
	            </form>
		<%
		end if
%>
</div>
<%
end if
'<------ pegando os creditos
%>




















<style>
    .radio-custom.disabled{
        cursor: not-allowed;
    }
    .radio-custom.disabled label{
        cursor: not-allowed;
    }
    .radio-custom.radio-primary.disabled label:before, .checkbox-custom.checkbox-primary label:before{
        background-color: #fafafa;
        border-color: #d4d4d4;
    }
    .radio-menor label:before{
        width: 15px;
        height: 15px;
    }
    .radio-custom.radio-menor  input[type=radio]:checked + label:after, .radio-custom input[type=checkbox]:checked + label:after{
        top: 4px;
        left: 4px;
        width: 7.4px;
        height: 7.4px;
    }
</style>
<form method="post" action="" id="frmPagto">
<div class="modal-body">
    <div class="row">
        <%

        if getConfig("PermitirCreditoDeOutrosPacientes")=1 and CD="C" and AssContaID=3 and false then
            %>
<div class="col-md-12">
    <div class="row">
        <div id="content-utilizar-credito-outro-paciente" class="col-md-3  col-md-offset-9">
            <button class="btn btn-default btn-sm" type="button" onclick="CreditoOutroPacienteToggleSelect()">
                <i class="far fa-unlink"></i> Utilizar crédito de outro paciente
            </button>
        </div>

        <div style="display:none;" id="content-escolher-paciente-credito" class="col-md-6  col-md-offset-6">
            <div class="col-md-9">
                <label>Selecione a conta ou paciente</label><br>
                <%=selectInsertCA("", "PacienteCreditoID", "", "3", "", "", "")%>
            </div>
            <div class="col-md-3">
                <button class="btn m20 btn-success btn-block" onclick="BuscarCreditosPaciente($('#PacienteCreditoID').val())" type="button"><i class="far fa-search"></i> Buscar</button>
            </div>
        </div>
    </div>
</div>
<script >
function CreditoOutroPacienteToggleSelect(showSelect=true) {
    var $contentUtilizar = $("#content-utilizar-credito-outro-paciente"),
        $contentEscolhePaciente = $("#content-escolher-paciente-credito");

    if(showSelect){
        $contentUtilizar.fadeOut(function() {
          $contentEscolhePaciente.fadeIn();
        });
    }
}

function BuscarCreditosPaciente(ContaID) {
    $.get("BuscarCreditosPaciente.asp", {ContaID: ContaID}, function(data) {
        $(".conteudo-creditos").html(data);
    });
}
</script>
            <%
        end if

        %>


        <div id="pagtoConv" class="col-md-12 widget-container-span ui-sortable">
            <div class="widget-box">
                <div class="widget-header">
                <div class="row">
                    <div id="AlertMessenger" class="alert alert-warning" role="alert" style="display: none;"></div>
                </div>
                    <h5 class="row">
                        <span class="col-md-9">
                            Dados do Pagamento
                        </span>
                        <div class="col-md-3">
                            <input type="hidden" id="InvoiceId" value="<%=InvoiceID%>">
                            <input type="hidden" id="LicencaID" value="<%=session("Banco")%>">
                            <input type="hidden" id="StoneCode" value="<%=StoneCode%>">
                            <input type="hidden" id="MovementID" value="<%=Parcelas%>">
                            <input type="hidden" id="UsuarioID" value="<%=session("User")%>">
                            <input type="hidden" id="CaixaID" value="<%=session("CaixaID")%>">

                            <%
                            if aut("altunirectoA")=0 then
                                    disabUN = " disabled "
                                    response.write("<input type='hidden' name='UnidadeIDPagto' id='UnidadeIDPagtoHidden' value='"& UnidadeID &"'>")
                               end if
                                call quickField("empresa", "UnidadeIDPagto", "", 4, UnidadeID, "", "", " style='margin-top:5px'"& disabUN)

                                %>
                        </div>
                    </h5>
                </div>
                <div class="widget-body">
                    <div class="widget-main">
                    	<div class="row">
                            <div class="col-md-4" id="listRadioFormaPagamento">
                                <%
                    			set vcaFormas = db.execute("select * from sys_formasrecto")

                                if vcaFormas.EOF then
                                    TodasFormas = "todas"
                                end if

                    '			if vcaFormas.EOF THEN
                                    if CD="D" AND session("CaixaID")<>"" then
                                        sqlFormasAceitas = " AND id IN(1) "
                                    end if

                                    if CD="C" then
                                        set usr = db.execute("select limitarecpag from sys_users where id="& session("User")&" and limitarecpag not like ''")
                                        if not usr.eof then
                                            sqlFormasAceitas = " AND id IN("& replace(usr("limitarecpag"), "|", "") &") "
                                        end if
                                    end if
                                      MetodoIDSelect = null
                                      BandeirasIDSelect = null
                                      set sysFormasRecto = db.execute("select sys_formasrecto.*, sys_financialinvoices.FormaID, sys_financialinvoices.ContaRectoID, REPLACE(sys_formasrecto.bandeiras, '|', '') as bandeirasId "&_
                                                                     " from sys_financialinvoices "&_
                                                                     " join sys_formasrecto on sys_formasrecto.id = sys_financialinvoices.FormaID "&_
                                                                    " where sys_financialinvoices.id = "&InvoiceID)

                                    if not sysFormasRecto.eof then
                                        if sysFormasRecto("MetodoID")=1 OR sysFormasRecto("MetodoID")=2 OR sysFormasRecto("MetodoID")=7  OR sysFormasRecto("MetodoID")=8 then
                                            MetodoIDSelect = sysFormasRecto("MetodoID")
                                        end if
                                        ContaRectoSelect = sysFormasRecto("ContaRectoID")
                                        BandeirasIDSelect = sysFormasRecto("bandeirasId")
                                    end if
                                    set PaymentMethod = db.execute("select * from cliniccentral.sys_financialPaymentMethod where AccountTypes"&CD&"<>'' "& sqlFormasAceitas &" order by PaymentMethod")
'                                    set PaymentMethod = db.execute("select * from sys_financialPaymentMethod where AccountTypes"&CD&"<>'' or id=3 order by PaymentMethod")
                                    while not PaymentMethod.eof
										set RecebimentoLimitadoSQL = db.execute("SELECT * FROM sys_formasrecto WHERE MetodoID="&PaymentMethod("id"))

                                        if (not RecebimentoLimitadoSQL.eof  or TodasFormas<>"") or not RestringirFormasDeRecebimento then
                                        %>
                                        <div class="radio-custom radio-primary" data-id="<%=PaymentMethod("id") %>">
                                            <input type="radio" class="ace Metodo" data-id="<%=PaymentMethod("id") %>" name="MetodoID" id="MetodoID<%=PaymentMethod("id") %>" onclick="subConta(<%=PaymentMethod("id")%>);" value="<%=PaymentMethod("id")%>"<%if MetodoID=PaymentMethod("id") then%> checked<%end if%>><label for="MetodoID<%=PaymentMethod("id") %>"> <%=PaymentMethod("PaymentMethod")%></label>
                                        </div>
                                        <div class="subConta hidden" id="contas_<%=PaymentMethod("id")%>">
                                        <%
										if session("CaixaID")="" OR PaymentMethod("id")=7 OR PaymentMethod("id")=8 OR PaymentMethod("id")=9 OR PaymentMethod("id")=4 OR PaymentMethod("id")=5 OR PaymentMethod("id")=15 OR PaymentMethod("id")=6 then
										    sqlContasLiberadas = ""

										    Contas=""
                                            while not RecebimentoLimitadoSQL.eof
                                                ContasCartao = RecebimentoLimitadoSQL("Contas")

                                                if Contas="" then
                                                    Contas = ContasCartao
                                                else
                                                    if ContasCartao&"" <> "" then
                                                        Contas = Contas&","&ContasCartao
                                                    end if
                                                end if

                                            RecebimentoLimitadoSQL.movenext
                                            wend
                                            RecebimentoLimitadoSQL.close
                                            set RecebimentoLimitadoSQL=nothing

                                            if instr(Contas, "|ALL|")=0 and Contas<>"" then
                                                sqlContasLiberadas= " AND id IN ("&replace(Contas, "|", "")&")"
                                            end if

											if PaymentMethod("AccountTypes"&CD)<>"" then
												sqlContas = "select * from sys_financialcurrentaccounts where Empresa="&UnidadeID&" and AccountType in("&replace(PaymentMethod("AccountTypes"&CD), "|", ",")&") and sysActive=1 "&sqlContasLiberadas
												'response.Write(sqlContas)
												set contas = db.execute(sqlContas)
                                                if contas.eof then
                                                    %>
                                                    <script type="text/javascript">
                                                        $("#MetodoID<%=PaymentMethod("id") %>").prop("disabled", true);
                                                        $("#MetodoID<%=PaymentMethod("id") %>").parent(".radio-custom").addClass("disabled");
                                                        $("#MetodoID<%=PaymentMethod("id") %>").closest("div").attr("title", "Não há conta cadastrada para esta forma nesta unidade.");
                                                        $("#MetodoID<%=PaymentMethod("id") %>").closest("div").attr("data-toggle", "tooltip").attr("data-placement","bottom");
                                                    </script>
                                                    <%
                                                end if
												while not contas.eof
													%>
                                                    <div class="radio-custom radio-success radio-menor">
                                                        &nbsp;&nbsp;&nbsp;&nbsp;
                                                        <input type="radio" class="Conta" name="ContaID" onclick="apaDist()" id="ct<%=PaymentMethod("id")%>_<%=contas("id")%>" value="<%=contas("id")%>"><label for="ct<%=PaymentMethod("id")%>_<%=contas("id")%>"> <%=contas("AccountName")%></label>
                                                    </div>
													<%
												contas.movenext
												wend
												contas.close
												set contas=nothing
											end if
										end if

if false then
										'if session("Admin")<>1 then

                                            set PermissaoDePermissoesDoUsuarioSQL = db.execute("SELECT r.limitarecpag FROM regraspermissoes r INNER JOIN sys_users u ON u.Permissoes LIKE CONCAT('%[',r.id,']%') AND r.limitarecpag IS NOT NULL AND r.limitarecpag!='' AND u.id="&session("User"))
                                            if not PermissaoDePermissoesDoUsuarioSQL.eof then

                                                if PermissaoDePermissoesDoUsuarioSQL("limitarecpag")<>"" then
                                                    %>
                                                    $(".Forma").each(function(){
                                                        var forma = '|'+$(this).data("id")+'|';
                                                        if('<%=PermissaoDePermissoesDoUsuarioSQL("limitarecpag")%>'.indexOf(forma)<-1){
                                                            $(this).prop("disabled", true);
                                                        }
                                                    });
                                                    <%
                                                end if
                                            end if
                                        'end if
end if
										%>
										</div>
										<%
                                    end if
                                    PaymentMethod.movenext
                                    wend
                                    PaymentMethod.close
                                    set PaymentMethod=nothing
                    '			else
                    '				ve se esse user tem acesso a todas as formas ou mostra so as formas predefinidas
                    '			end if
                                %>
                            </div>
                            <div class="col-md-4">
                            	<div class="detalheMetodo" id="divMetodo_2">
                                    <%
                                    if CD="C" then
                                        %>
									    <%=quickField("simpleSelect", "BankID_2", "Banco Emissor", "12", "", "select id, concat(BankNumber, ' - ', BankName) BankName from sys_financialBanks order by BankNumber", "BankName", "")%>
                                        <%=quickField("text", "Branch_2", "Agência", "6", "", "", "", "")%>
                                        <%=quickField("text", "Account_2", "N&deg; da Conta", "6", "", "", "", "")%>
                                        <%=quickField("text", "CheckNumber_2", "N&deg; do Cheque", "6", "", "", "", "")%>
                                        <%=quickField("text", "Holder_2", "Titular", "6", "", "", "", "")%>
                                        <%=quickField("text", "Document_2", "Documento", "6", "", "", "", "")%>
                                        <%=quickField("datepicker", "CheckDate_2", "Data do Cheque", "6", DataCheque, "", "", "")%>
                                        <%=quickField("simpleCheckbox", "Cashed_2", "Compensado", "6", "1", "", "", "")%>
                                        <div class="col-md-12">
                                            <br />
                                            <input type="text" id="CMC7" name="CMC7" class="form-control"  style="font-family:'CMC7'" placeholder="LEITOR} DE CHEQUE/" />
                                        </div>
                                        <%
                                    else
                                        %>
                                        <%=quickField("text", "CheckNumber_2", "N&deg; do Cheque", "6", "", "", "", "")%>
                                        <%=quickField("datepicker", "CheckDate_2", "Data do Cheque", "6", DataCheque, "", "", "")%>
                                        <%=quickField("simpleCheckbox", "Cashed_2", "Compensado", "6", "1", "", "", "")%>
                                        <%
                                    end if
                                    %>
                                </div>
                                <%
                                if CD="C" then
                                    idCC=8
                                else
                                    idCC=10
                                end if
                                %>
                                <div class="detalheMetodo" id="divMetodo_<%=idCC %>">
                                    <div class="row">
									    <%=quickField("text", "TransactionNumber_"&idCC, "N&uacute;mero da Transa&ccedil;&atilde;o", "12", "", "", "", "")%>
                                        <div class="col-md-4">
                                            <label for="NumberOfInstallments_<%=idCC %>">Parcelas</label><br />
                                            <select class="form-control"  name="NumberOfInstallments_<%=idCC %>" id="NumberOfInstallments_<%=idCC %>">
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
                                        <%
                                        if CD="D" then
                                            %>
                                            <%= quickfield("currency", "ValorParcela", "Valor da Parcela", 8, ValorPagto, "", "", "") %>
                                            <script type="text/javascript">

                                                function treatval(valor){
	                                                valor = valor.replace('.', '');
	                                                valor = valor.replace(',', '.');
	                                                return valor;
                                                }
                                                function tvrev(valor){
	                                                valor = valor.replace('.', '');
                                                }
                                                function vpar() {
                                                    Parcelas = $('#NumberOfInstallments_10').val();
                                                    ValorPagto = treatval($('#ValorPagto').val());
                                                    ValorParcela = ValorPagto / Parcelas;
                                                    $('#ValorParcela').val( ValorParcela.toFixed(2).toString().replace('.', ',') );
                                                }
                                                function vtot() {
                                                    Parcelas = $('#NumberOfInstallments_10').val();
                                                    ValorParcela = treatval($('#ValorParcela').val());
                                                    ValorPagto = Parcelas * ValorParcela
                                                    $('#ValorPagto').val( ValorPagto.toFixed(2).toString().replace('.', ',') );
                                                }


                                                $('#ValorPagto').keyup(function () {
                                                    vpar();
                                                });

                                                $('#NumberOfInstallments_10').change(function () {
                                                    vpar();
                                                });

                                                $('#ValorParcela').keyup(function () {
                                                    vtot();
                                                });
                                            </script>
                                            <%
                                        else
                                            if session("Banco")="clinic5445" then
                                                CampoCartaoObrigatorio = " "
                                            end if
                                            %>
                                            <%=quickField("text", "AuthorizationNumber_"&idCC, "N&uacute;mero da Autoriza&ccedil;&atilde;o", "8", "", "", "", "  maxlength='14' "&CampoCartaoObrigatorio)%>
                                            <% onchangeEvent = "  "%> 
                                            <%= quickField("simpleSelect", "BandeiraCartaoID_"&idCC, "Bandeira do Cartão", 12, "", "select * from cliniccentral.bandeiras_cartao", "Bandeira", ""&CampoCartaoObrigatorio&onchangeEvent) %>
                                            <%
                                        end if
                                        %>
                                    </div>
                                </div>

                                <%
                                if CD="C" then
                                %>
                                <div class="detalheMetodo" id="divMetodo_9">
									<%=quickField("text", "TransactionNumber_9", "N&uacute;m. Transa&ccedil;&atilde;o", "6", "", "", "", "")%>
                                    <input type="hidden" name="NumberOfInstallments_9" id="NumberOfInstallments_9" value="1">
                                    <%=quickField("text", "AuthorizationNumber_9", "N&uacute;m. Autoriza&ccedil;&atilde;o", "6", "", "", "", " maxlength='14'")%>
                                    <%= quickField("simpleSelect", "BandeiraCartaoID_9", "Bandeira do Cartão", 12, "", "select * from cliniccentral.bandeiras_cartao", "Bandeira", ""&CampoCartaoObrigatorio) %>
                                </div>
                                <%
                                end if
                                %>
                                <%
                                if CD="D" then
                                %>
                                <div class="detalheMetodo" id="divMetodo_5">
                                    <%=quickField("currency", "BankFee_5", "Valor da Tarifa", "12", "0,00", "", "", "")%>
                                </div>
                                <div class="detalheMetodo" id="divMetodo_6">
                                    <%=quickField("currency", "BankFee_6", "Valor da Tarifa", "12", "0,00", "", "", "")%>
                                </div>
                                <%
                                end if
                                %>
                                <div class="detalheMetodo" id="divMetodo_7">
                                    <%
                                    if CD="D" then
                                        %>
									    <%=quickField("currency", "BankFee_7", "Valor da Tarifa", "6", "0,00", "", "", "")%>
                                        <%
                                    end if
                                    %>
                                </div>
                                <div class="detalheMetodo" id="divMetodo_3">
                                <%=selectInsertCA("Debitar de", "ContaRectoID_3", AssociationAccountID&"_"&AccountID, "4, 3, 2, 5", othersToSelect, othersToInput, campoSuperior)%>
                                </div>
                            </div>
                            <div class="col-md-4">
                            	<div class="row">
                                    <%
                                    if session("CaixaID")<>"" then
                                    'if session("CaixaID")<>"" OR aut("bloquearalteracaodatapagamento") then
                                        %>
                                        <div class="col-md-12 text-right">
                                            <input type="hidden" name="DataPagto" value="<%=date() %>" />
                                            <label>Data do Pagamento</label><br />
                                            <%=Date() %>
                                        </div>
                                        <%
                                    else
                                        call quickField("datepicker", "DataPagto", "Data do Pagamento", 12, date(), "", "", "")
                                    end if    
                                    %>
									<%=quickField("currency", "ValorPagto", "Valor do Pagamento", 12, ValorPagto , "", "", " onkeyup=""apaDist();""")%>
                                    <%
                                    if session("Banco")="clinic2901" or session("Banco")="clinic100000" then
                                        %>
                                        <div class="col-md-12 text-right" id="divJM">
                                            <a class="red" href="javascript:calcJM()"><i class="far fa-calculator"></i> Calcular juros e multa.</a>
                                        </div>
                                        <%
                                    end if
                                    %>
                                    <div class="col-md-12" id="ReceberTEF" style="display: none; margin-top: 20px">
                                        <div class="row">
                                            <div class="col-md-8">
                                                <button onClick="captureTransaction()" style="display: inline-block;" class="btn btn-system" type="button" id="receberTefButton"><i class="far fa-credit-card"></i> Receber da maquininha</button>
                                            </div>
                                            <%if aut("capptaA") then%>
                                            <div class="col-md-2">
                                                <button onClick="openPdvConfig()" style="display: inline-block;" class="btn btn-warning" type="button" id="pdv-config"><i class="far fa-cogs"></i></button>
                                            </div>
                                            <%end if%>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

<%if recursoAdicional(14)=4 and aut("capptaI")=1 then%>
    <script src="https://s3.amazonaws.com/cappta.api/v2/dist/cappta-checkout.js"></script>
    <script src="https://unpkg.com/axios/dist/axios.min.js"></script>
    <script>
       function checkForPendingTransactions(movementId) {
           console.log("Buscando transações pendentes para movementId: " + movementId);
            const logs = localStorage.getItem("cappta-logs");
            if(logs) {
                const logsArray = JSON.parse(logs);
                logsArray.forEach(function (el, i) {
                    if(el.movementId == movementId) {
                        $("#hasPendingPayments").css("display", "block");
                        $("#hasPendingPayments").attr("data-index", i)
                    }
                });
            }
       }checkForPendingTransactions(<%=Parcelas%>);

       function getTransactionInfo() {
            let radioType = $('input[type=radio][name="ContaID"]:checked').attr('id');
            let paymentMethod = radioType.split("_")[0].replace("ct", "");

            return {
                transactionType: paymentMethod == 8 ? "credit" : "debit",
                amount: parseFloat($("#ValorPagto").val().replace(/\./g, ' ').replace(",", ".").replace(/\s/g, "")),
                installmentNumber: $("#NumberOfInstallments_" + paymentMethod).val() || 1,
                invoiceId: $("#InvoiceId").val(),
                movementId: $("#MovementID").val()
            }
        }

        function autoConsolidate() {
            var d = new Date();
            var hours = d.getHours();
            var minutes = d.getMinutes();
            var seconds = d.getSeconds();
            var time = hours + ":" + minutes + ":" + seconds;

            $("#AutoConsolidar").attr("src", "AutoConsolidar.asp?AC=1&T" + time+"&I=<%=InvoiceID%>");
        }

        function refreshPage() {
            if ($.isNumeric($("#PacienteID").val())) {
            ajxContent('Conta', $('#PacienteID').val(), '1', 'divHistorico');
            if ($('#Checkin').val() == '1') {
               $.get("callAgendamentoProcedimentos.asp?Checkin=1&ConsultaID=" + $("#ConsultaID").val() + "&PacienteID=" + $("#PacienteID").val() + "&ProfissionalID=" + $("#ProfissionalID").val() + "&ProcedimentoID=" + $("#ProcedimentoID").val(), function (data) {
                   $("#divAgendamentoCheckin").html(data)
               });
            }
            } else {
                $('.parcela').prop('checked', false);
                $('#pagar').fadeOut();
                geraParcelas('N');
            }
        }

        function loadingButton(loading) {
           if(loading) {
              $("#receberTefButton").prop("disabled", true);
              $("#receberTefButton").html("<i class='far fa-spin fa-circle-o-notch'></i>")
           } else {
              $("#receberTefButton").prop("disabled", false);
              $("#receberTefButton").html("<i class=\"far fa-credit-card\"></i> Receber da maquininha")
           }
        }

        function openPdvConfig() {
           const cappta = new FeegowCappta();
           cappta.openPdvConfig();
        }

        function reciboPadrao() {
           if(typeof imprimir === "function") {
               imprimirReciboInvoice();
           }
        }

        async function captureTransaction() {
            try {
                loadingButton(true);
                const cappta = await new FeegowCappta(false);
                const serializedArray = $("#frmPagto, .parcela, #AccountID").serializeArray();
                const transactionInfo = await getTransactionInfo();
                const payment = await cappta.createTransaction(transactionInfo, serializedArray);

                if(payment.autoConsolidate) {
                    autoConsolidate();
                }

                reciboPadrao();
                refreshPage();
            } catch (e) {
                loadingButton(false);
                if(e.substr(11, 20) == "Cannot read property") {
                    showMessageDialog("Ocorreu um erro interno na operação. Atualize a página e tente novamente", 'danger', "Erro na transação")
                } else {
                    showMessageDialog(e, 'danger', "Erro na transação")
                }
            }
        }

       async function payPendingTransaction() {
           const index = $("#hasPendingPayments").data("index");
           const logs = localStorage.getItem("cappta-logs");

           let logsArray = JSON.parse(logs);
           const serializedArray = logsArray[index].serializedArray;
           const paymentInfo = logsArray[index].paymentInfo;

            try {
                const savePagto = await axios.post(domain + "microtef/pay-movement", {
                    serializedData: serializedArray,
                    ccInfo: paymentInfo,
                    type: "C"
                }, {
                    headers: {
                        "x-access-token": localStorage.getItem("tk")
                    }
                });

                if (!savePagto.data.success) {
                    showMessageDialog(savePagto.data.content, 'danger', "Erro na transação")
                } else {
                    delete logsArray[index];
                    logsArray = JSON.stringify(logsArray);
                    logsArray = logsArray === "[null]" ? "" : logsArray;

                    localStorage.setItem("cappta-logs", logsArray);
                    if(savePagto.data.content.autoConsolidate) {
                        autoConsolidate();
                    }

                    refreshPage();
                }
            } catch (e) {
                showMessageDialog("Ocorreu um erro na sincronização do pagamento.", 'danger', "Erro na transação")
            }
       }
    </script>
<%end if%>





    </div>
    <div class="row" id="divDist" style="display:none">
        <div class="col-md-12 widget-container-span ui-sortable">
            <div class="widget-box">
                <div class="widget-header">
                    <h5>Distribuição do Valor</h5>
                </div>
                <div class="widget-body">
                    <div class="widget-main">
                        <table class="table table-condensed">
                        <thead>
                            <tr>
                                <th width="50%">Item</th>
                                <th width="10%">Subtotal</th>
                                <th width="10%">Liquidado</th>
                                <th width="10%">Pendente</th>
                                <th width="20%">Descontar</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                        Disponivel = ValorPagto
                        TotalItens = 0
                        set inv = db.execute("select * from sys_financialinvoices i where id IN(select InvoiceID from sys_financialmovement where id IN("&Parcelas&"))")
                        while not inv.eof
                            set ii = db.execute("select ii.*, p.NomeProcedimento, prod.NomeProduto, (ii.Quantidade*(ii.ValorUnitario-ii.Desconto+ii.Acrescimo)) Subtotal from itensinvoice ii LEFT JOIN procedimentos p on p.id=ii.ItemID LEFT JOIN produtos prod ON prod.id=ii.ItemID where ii.InvoiceID="&inv("id"))
                            while not ii.eof
                                set liq=db.execute("select ifnull(sum(Valor),0) Liquidado from itensdescontados where ItemID="&ii("id"))
                                Liquidado = liq("Liquidado")
                                TipoItem = ii("Tipo")
                                Subtotal = ii("Subtotal")
                                Pendente = ii("Subtotal")-Liquidado
                                TotalItens = TotalItens + Pendente
                                NomeItem = ""
                                if TipoItem="S" then
                                    NomeItem = ii("NomeProcedimento")
                                elseif TipoItem="O" then
                                    NomeItem = ii("Descricao")
                                elseif TipoItem="M" then
                                    NomeItem = ii("NomeProduto")
                                end if

                                if ccur(Disponivel)>=(Pendente) then
                                    Descontar = Pendente
                                    Disponivel = Disponivel-Descontar
                                else
                                    Descontar = Disponivel
                                    Disponivel = 0
                                end if
                                if inv("FormaID")<>0 then
                                    %>
                                    <script type="text/javascript">
/*                                        $(".Metodo").prop("disabled", true);
                                        $(".Metodo[value=<%=inv("FormaID")%>]").prop("disabled", false);
                                        $(".Metodo[value=<%=inv("FormaID")%>]").click();
                                        $(".Metodo[value=<%=inv("FormaID")%>]").click();
*/                                    </script>
                                    <%
                                end if
                                
                                'se pendente for 0 item nem aparece
                                'se tiver só um item aparecendo, nem aparece, ja desconta tudo soh dele
                                if Pendente>=0 then
                                %>
                                <tr>
                                    <td><%'=inv("id") &"."& ii("id")%>
                                    <%
                                    if ii("Quantidade")>1 then
                                        response.Write(ii("Quantidade")&"x")
                                    end if
                                    response.Write(NomeItem)
                                    %></td>
                                    <td class="text-center"><%=fn(ii("Subtotal"))%></td>
                                    <td class="text-center"><%=fn(Liquidado)%></td>
                                    <td class="text-center"><%=fn(Pendente)%></td>
                                    <td>
                                    	<input type="hidden" name="ItemPagarID" value="<%=ii("id")%>" />
										<%=quickField("currency", "Descontar_"&ii("id"), "", 6, Descontar, "descontar", "", " data-descontar="""&Descontar&"""")%>
                                    </td>
                                </tr>
                                <%
                                end if
                            ii.movenext
                            wend
                            ii.close
                            set ii=nothing
                        inv.movenext
                        wend
                        inv.close
                        set inv=nothing
                        %>
                        </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>


    <div id="hasPendingPayments" style="margin-top: 30px; display: none" class="row">
        <div class="col-md-6">
            <div class="alert alert-danger">
                <p>Existe uma transação TEF pendente de sincronização</p>
                <button style="margin-top: 10px" class="btn btn-warning" type="button" onClick="payPendingTransaction()">Sincronizar pagamentos <i class="far fa-refresh"></i></button>
            </div>
        </div>
    </div>
    
    <%

    if CD="C" then
            if session("CaixaID")="" and (aut("contasareceberI") or aut("contasareceberV")) and (aut("aberturacaixinhaI") or aut("aberturacaixinhaV")) and session("Admin")=0 then%>
            <script>
                // $(".radio-custom").addClass("disabled");
                // $(".Metodo").prop("disabled", true);
                // $("#btnPagar").prop("disabled", true);
            </script>
            <div id="alertWarningPermCaixinha" style="margin-top: 30px" class="row">
                <div class="col-md-12">
                    <div class="alert alert-danger">
                        <p>Atenção! Seu caixa está fechado. Por favor, abra-o para receber esta conta.</p>
                    </div>
                </div>
            </div>
    <%
            end if
    end if
    %>

    <% if session("CaixaID")<>"" then
        set CaixaSQL = db.execute("SELECT cc.Empresa, date(c.dtAbertura) Abertura FROM caixa c INNER JOIN sys_financialcurrentaccounts cc ON c.ContaCorrenteID = cc.id WHERE c.id="&session("CaixaID"))

        if not CaixaSQL.eof then


            NaoPermitirRecebimentoCaixaComDataAnterior = getConfig("NaoPermitirRecebimentoCaixaComDataAnterior")


            if NaoPermitirRecebimentoCaixaComDataAnterior and CaixaSQL("Abertura")<>date() then
                %>
                <div id="alertWarningUnidadeCaixa" style="margin-top: 30px" class="row">
                    <div class="col-md-12">
                        <div class="alert alert-danger">
                            <div class="row">
                                <div class="col-md-9">
                                        <i class="far fa-info-circle"></i>
                                        A data de abertura do seu caixa é diferente da data atual. Para receber, favor realize o fechamento do caixa.
                                </div>
                                <div class="col-md-3">
                                    <a href="?P=PreFechaCaixa&Pers=1" style="margin-top: 15px; color: rgba(0,0,0,0.5)" class="btn btn-default btn-sm" type="button" onClick="unlockButton()">
                                        <i class="far fa-inbox"></i> Fechar caixa
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <script>
                    function unlockButton() {
                        $("#btnPagar").css("visibility", "visible");
                        $("#receberTefButton").css("visibility", "visible");
                        $("#alertWarningUnidadeCaixa").fadeOut();
                    }

                    $("#pagtoConv").remove();
                    $("#btnPagar").css("visibility", "hidden");
                    $("#receberTefButton").css("visibility", "hidden")
                </script>
                <%
            end if

            unidadeAtendido = "SELECT l.UnidadeID FROM sys_financialinvoices i LEFT JOIN itensinvoice ii ON i.id = ii.InvoiceID LEFT JOIN agendamentos a on i.AccountID = a.PacienteID LEFT JOIN locais l ON l.id = a.LocalID WHERE ii.Tipo = 'S' and ii.ItemID = a.TipoCompromissoID and a.Data = i.sysDate and a.StaID != 11 and i.AssociationAccountID = 3 and i.id ="&InvoiceID
            'response.write(unidadeAtendido)
            set InvoiceInfo = db.execute(unidadeAtendido)
            if not InvoiceInfo.eof then
                iUnidadeID = InvoiceInfo("UnidadeID")
                cUnidadeID = CaixaSQL("Empresa")

                if iUnidadeID <> cUnidadeID then %>
                    <div id="alertWarningUnidadeCaixa" style="margin-top: 30px" class="row">
                        <div class="col-md-12">
                            <div class="alert alert-danger">
                                <div class="row">
                                    <div class="col-md-9">
                                            <i class="far fa-info-circle"></i>
                                            A unidade em que o paciente foi atendido difere da unidade de abertura do caixa.
                                    </div>
                                    <div class="col-md-3">
                                        <button style="margin-top: 15px; color: rgba(0,0,0,0.5)" class="btn" type="button" onClick="unlockButton()">
                                            <i class="far fa-exclamation-triangle"></i> Continuar mesmo assim
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <script>
                        function unlockButton() {
                            $("#btnPagar").css("visibility", "visible");
                            $("#receberTefButton").css("visibility", "visible");
                            $("#alertWarningUnidadeCaixa").fadeOut();
                        }

                        $("#btnPagar").css("visibility", "hidden");
                        $("#receberTefButton").css("visibility", "hidden")
                    </script>
                <%end if
            end if
        end if
    end if%>


</div>
<div class="modal-footer">
	<button class="btn btn-success pull-right" id="btnPagar" disabled="disabled"><i class="far fa-check"></i> Pagar</button>
</div>
</form>

<script type="text/javascript">

$('[data-toggle="tooltip"]').tooltip();
function treatval(valor){
	valor = valor.replace('.', '');
	valor = valor.replace(',', '.');
	return valor;
}
function tvrev(valor){
	valor = valor.replace('.', '');
}
var MetodoIDSelecionado = "";
function apaDist(){
	var MetodoID = $("input[name=MetodoID]:checked").val();
	if($("input[name=MetodoID]:checked").size()==1){
		var ValorPagto = $("#ValorPagto").val().replace(/\./g,'');
		$("#btnPagar").removeAttr("disabled");
		ValorPagto = ValorPagto.replace(',', '.');
		var TotalItens = parseFloat('<%=treatval(TotalItens)%>').toFixed(2);
		if(ValorPagto<TotalItens){
			$("#divDist").slideDown();
		}else{
			$("#divDist").slideUp();
		}
//		console.log(MetodoID)
//		console.log(MetodoIDSelecionado)
		if(MetodoID !== MetodoIDSelecionado){
		    $(".detalheMetodo").not("#divMetodo_"+MetodoID).fadeOut("fast", "swing", function(){
			    $("#divMetodo_"+MetodoID).fadeIn("fast", "swing");
		    });
		}
        var UnidadeID = $("#UnidadeIDPagto").val();

        var parcelas = $("#NumberOfInstallments_" + MetodoID).val();
        var bandeiraId = $("#BandeiraCartaoID_" + MetodoID).val();

        setTimeout(() => {
            $.get("mudaPagarForma.asp", {FormaID: $("#FormaID option:selected").data("frid"),MetodoID:MetodoID, ContaID:$("[name='ContaID']:checked").val(), UnidadeID:UnidadeID, Parcelas:parcelas, BandeiraId:bandeiraId }, function(data) {
                eval(data);
            });
        }, 200);

        MetodoIDSelecionado=MetodoID;

		Disponivel = parseFloat(ValorPagto);
//		$("#test").html("Disponivel: "+ Disponivel +"<br />" );
		$(".descontar").each(function(index, element) {
			Pendente = parseFloat( treatval( $(this).attr('data-descontar') ) );
			if(Disponivel>=Pendente){
				Descontar=Pendente;
				Disponivel = Disponivel-Descontar;
			}else{
				Descontar = Disponivel;
				Disponivel = 0;
			}

			//$("#test").append( $(this).attr("id") + ' -&gt; ' + Descontar +'<br>' );
			$(this).val( Descontar.toFixed(2).toString().replace('.', ',') );
		});
	}

}



function subConta(MetodoID){
    $(".subConta").addClass("hidden");
    $("#contas_"+MetodoID).removeClass("hidden");
    if( $("#contas_"+MetodoID+" .Conta").size() == 0){
        apaDist();
    }else if($("#contas_"+MetodoID+" .Conta").size() == 1){
        $("#contas_"+MetodoID+" .Conta").prop("checked", true);
        apaDist();
    }else{
        $(".Conta").prop("checked", false);
        $("#btnPagar").attr("disabled", true);
    }
}

function createSplit (movements) {
        postUrl('splits/create', {
            movements: movements,
            timeout: true
        }, function (data) {
           $(data).each(function (i) {
               if (data[i]['success'] == false) {
                   console.log(true);
               } else if (data[i]['success'] == true) {
                   console.log(false);
               }
           })
        })
}


$("#frmPagto").submit(function(){
    if (verificaBandeira()) 
    {
        $("#btnPagar").attr("disabled", true);
        $.post("savePagto.asp?I=<%=InvoiceID%>&T=<%=req("T")%>", $("#frmPagto, .parcela, #AccountID").serialize(), function(data, status){ eval(data) });
    }
    return false;
});

var bandeiraObrigatoria = '<%=BandeiraCartaoObrigatorio%>';
var numeroAutorizacaoObrigatorio = '<%=NumeroAutorizacaoObrigatorio%>';
function verificaBandeira()
{
    let retorno = true;

    if(bandeiraObrigatoria == '1')
    {
        var MetodoID = $("input[name=MetodoID]:checked").val();
        var bandeiraId = $("#BandeiraCartaoID_" + MetodoID).val();
        
        if (bandeiraId == 0)
        {
            $("#AlertMessenger").html("Campo: Bandeira do cartão é obrigatório");
            $("#AlertMessenger").fadeIn();
            retorno = false;
        }else{
            $("#AlertMessenger").fadeOut();
            retorno = true;
        }
    }
    if(numeroAutorizacaoObrigatorio == '1')
    {
        var MetodoID = $("input[name=MetodoID]:checked").val();
        var numeroAutorizacao = $("#AuthorizationNumber_" + MetodoID).val();

        if (numeroAutorizacao == 0)
        {
            $("#AlertMessenger").html("Campo: Número de autorização é obrigatório");
            $("#AlertMessenger").fadeIn();
            retorno = false;
        }else{
            $("#AlertMessenger").fadeOut();
            retorno = true;
        }
    }

    return retorno;
}


$("#pagar").on("click",".credito",function(){
    $("#pagtoConv, #btnPagar").slideUp();
	$.post("calcCredito.asp?TotalItens=<%=TotalItens%>", $("#frmCredito").serialize(), function(data, success){ $("#pagtoCredito").html(data) } );
});

function applyCredit(){
	$.post("savePagtoCredito.asp", $("#frmPagto, .parcela, #AccountID, #frmCredito, #formItens").serialize(), function(data, status){ eval(data) });
}

function excluiMov(I){
	if(confirm('Tem certeza de que deseja excluir este crédito?')){
		$.post("xMov.asp", {I:I}, function(data, status){ eval(data) } );
	}
}

$("#UnidadeIDPagto").change(function(){
    var unityId = $(this).val();

    if(typeof getStoneCode === "function") {
        getStoneCode(unityId, function (stoneCode) {
            $("#StoneCode").val(stoneCode);
        });
    }

    $.post("pagar.asp?T=<%=req("T")%>&UnidadeID="+$(this).val(), $("input[name='Parcela']").serialize(), function(data){
        $("#pagar").html(data);
    });
});

function calcJM(){
    $.post("calcJM.asp", {
        Parcela: '<%=ref("Parcela")%>',
        DataPagto: $("#DataPagto").val()
    }, function(data){
        $("#divJM").html(data);
    });
}

$('#CMC7').keydown(function(e) {
    if(e.which == 10 || e.which == 13){
        $.post("CMC7.asp", { CMC7:$(this).val() }, function(data){eval(data)});

        if(Cmc7Validator.validate( $("#CMC7").val() )){
         //   alert("Cheque válido.");
        } else {
            alert("ATENÇÃO: Este cheque é inválido.");
        }

        return false;
    }
});

<!--#include file="jQueryFunctions.asp"-->




;(function(context){
  

  var Cmc7Validator = {
    validate : function (typedValue){
        typedValue      = typedValue.replace(/\s/g, "");
        if(!typedValue){
          return false;
        }

        var pieces = {
          firstPiece  : typedValue.substr(0,7)
          , secondPiece : typedValue.substr(8,10)
          , thirdPiece  : typedValue.substr(19,10)
        };
        

        var digits = {
          firstDigit : parseInt(typedValue.substr(7,1))
          , secondDigit :  parseInt(typedValue.substr(18,1))
          , thirdDigit : parseInt(typedValue.substr(29,1))
        };

        var calculatedDigits = {
          firstDigit : this.modulo10(pieces.firstPiece)
          , secondDigit :  this.modulo10(pieces.secondPiece)
          , thirdDigit : this.modulo10(pieces.thirdPiece)
        };

        if ( (calculatedDigits.secondDigit != digits.firstDigit) 
          || (calculatedDigits.firstDigit != digits.secondDigit)
          || (calculatedDigits.thirdDigit != digits.thirdDigit) ) {
            return false;
        }
        return true;
    }
    , modulo10 : function(str){
        var size = str.length - 1;
        var result = 0;
        var weight = 2;

        for (var i = size; i >= 0; i--) {

            total = str.substr(i, 1) * weight;

            if (total > 9) {
                result = result + 1 + (total - 10);
            } else {
                result = result + total;
            }
            if (weight == 1) {
                weight = 2;
            } else {
                weight = 1;
            }
        }
        var dv = 10 - this.mod(result, 10);
        if (dv == 10) {
            dv = 0;
        }
        return dv;
    }
    , mod : function(dividend, divisor){
        return Math.round(dividend - (Math.floor(dividend/divisor)*divisor));
    }

  };

  // Expose the module function.
  context.Cmc7Validator = Cmc7Validator;
})(window);
</script>

<%
if session("Banco")="clinic5760" or session("Banco")="clinic100000" or session("Banco")="clinic6102" then
%>
<script src="assets/js/microTEF.js"></script>
<script>
var invoiceId = parseInt("<%=InvoiceID%>");

function disableTefButton(context) {
    $('#receberTefButton').html("<i class='far fa-spin fa-circle-o-notch'></i> " + context + "...");
    $('#receberTefButton').prop("disabled", true);
}

function enableTefButton () {
    $('#receberTefButton').html("<i class='far fa-credit-card'></i> Receber da maquininha");
    $('#receberTefButton').prop("disabled", false);
}

function printReceipt(data) {

    var creditodebito = "";

    if(data.DebitoCredito == 'Credit') {
         creditodebito = "Credito"
    } else if (data.DebitoCredito == 'Debit') {
         creditodebito = "Debito"
    }

     var valor = data.Valor;
     var stoneId = data.TransactionKey;
     var parcelas = data.Parcelas;
     var aut = data.AUT;
     var digitos = data.Digitos;
     var pagador = data.Pagador;

     var url = mainDomain + "components/public/stone/receipt?debito_credito="+creditodebito+"&valor="+valor+"&stoneId="+stoneId+"&parcelas="+parcelas+"&aut="+aut+"&4digitos="+digitos+"&pagador="+pagador+"&invoiceId=" + invoiceId;

        $("<iframe>")                             // create a new iframe element
             .hide()                               // make it invisible
             .attr("src", url) // point the iframe to the page you want to print
             .appendTo("body");
}

function saveReceipt(data, paymentId) {
    postUrl("stone/save-receipt", {
        paymentId: paymentId,
        data: JSON.stringify(data)
    })
}

function logTransaction(json) {
    var stringJson = JSON.stringify(json);
    var data = JSON.parse(stringJson);
    postUrl("stone/log-microtef", data, function () {
        console.log("transação logada");
    });
}

function getStoneCode(unityId, cb) {
    getUrl("stone/get-stone-code", {
        unityId: unityId
    }, function (data) {
        if (data.StoneCode) {
            cb(data.StoneCode);
        } else {
            cb(0)
        }
    })
}

function getPayment() {

    var MetodoID = $('input[name=MetodoID]:checked').val();
    var unidadeId = $("#UnidadeIDPagto").val();
    var amount = parseFloat($("#ValorPagto").val().replace(/\./g,' ').replace(",", ".").replace(/\s/g, ""));
    var installmentNumber = $("#NumberOfInstallments_" + MetodoID).val();
    var radioType = $('input[type=radio][name="ContaID"]:checked').attr('id');
    var paymentMethod = radioType.split("_")[0].replace("ct", "");


        if(unidadeId && amount && invoiceId && installmentNumber) {

            var mc = new MicroTEF(unidadeId);

            mc.getPayment(amount, installmentNumber, radioType, paymentMethod, invoiceId, function (data) {
                if (data.success) {
                    showMessageDialog("Transação aprovada com sucesso", "success", "Sucesso!", 5000);
                    $("#BandeiraCartaoID_" + MetodoID).val(data.content.BandeiraId);
                    $("#AuthorizationNumber_" + MetodoID).val(data.content.TransactionKey);
                    setTimeout(function () {
                      $("#btnPagar").attr("disabled", true);
                        $.post("savePagto.asp?T=<%=req("T")%>", $("#frmPagto, .parcela, #AccountID").serialize(), function(dataAsp, status){
                            var receiptJSON = data.content;
                            printReceipt(receiptJSON);
                            eval(dataAsp);
                            var paymentId = MovementPayID;
                            saveReceipt(receiptJSON, paymentId);
                        });
                        return false;
                    }, 1500);
                } else {
                    enableTefButton();
                    showMessageDialog(data.content, "danger", "Erro na transação", 5000);
                }
            });

        } else {
            showMessageDialog("Informe todos os campos da transação", "danger", "Erro na transação", 5000);
        }
}


</script>
<%
end if
%>
<script >

getFormaRecebimento = async _ => {
    let MetodoID = $('input[name=MetodoID]:checked').val();

    let parcelas = $("#NumberOfInstallments_" + MetodoID).val();
    let bandeira = $("#BandeiraCartaoID_" + MetodoID).val();
    let formaPagamento = $('input[name=MetodoID]:checked').val();
    let contaCorrente = $("[name='ContaID']:checked").val();
    let unidade = $("#UnidadeIDPagto").val();

    let response = null;
    const header = { method: 'GET', cache: 'default' };
    await fetch(`getFormaRecebimento.asp?parcelas=${parcelas}&bandeira=${bandeira}&formaPagamento=${formaPagamento}&contaCorrente=${contaCorrente}&unidade=${unidade}`, header)
    .then(async promiseResponse => {
        await promiseResponse.json().then(responseJson => {
            response = responseJson;
        });
    });

    //await apaDist(1);
};

showOnlyPagamentoDisponivel = metodoId => {
    let listRadioFormaPagamento = [...document.getElementById("listRadioFormaPagamento").childNodes].filter(item => {
	    return item.className == 'radio-custom radio-primary';
    });

    listRadioFormaPagamento.map(item => {
        if(item.dataset.id != metodoId){
            item.style = "display:none;";
        }
    });

    let elementDadosPagamentoSelecionado = document.getElementById(`MetodoID${metodoId}`);

    if(elementDadosPagamentoSelecionado){
        elementDadosPagamentoSelecionado.click();
    }
    subConta(metodoId);
    //apaDist();
};

showBandeirasDisponiveis = (metodoId, bandeirasList) => {
    if(document.getElementById(`BandeiraCartaoID_${metodoId}`)){
       [...document.getElementById(`BandeiraCartaoID_${metodoId}`).options].forEach(itemOptionBandeiraCartao => {
            let codigoBandeiraCartao = parseInt(itemOptionBandeiraCartao.value);

            if(!bandeirasList.includes(codigoBandeiraCartao) && codigoBandeiraCartao !== 0) {
                itemOptionBandeiraCartao.remove();
            }
        });
   }

     $(`#BandeiraCartaoID_${metodoId}`).select2();
};

montarParcelas = async metodoId => {
    if(document.getElementById('FormaID')){
        let keyItemFormaPagamentoSelecionado = document.getElementById('FormaID').selectedIndex;
        let elementOptionsSelecionado = document.getElementById("FormaID").options[keyItemFormaPagamentoSelecionado];

        if(document.getElementById(`NumberOfInstallments_${metodoId}`)){
            let parcelaSelecionadaAnteriomente = document.getElementById(`NumberOfInstallments_${metodoId}`).selectedIndex;
        }
        let sysFormasrectoId = elementOptionsSelecionado.dataset.frid;

        let response = null;
        const header = { method: 'GET', cache: 'default' };
        await fetch(`getFormaPagamento.asp?sysFormasrectoId=${sysFormasrectoId}`, header)
            .then(async promiseResponse => {
                await promiseResponse.json().then(responseJson => {
                    response = responseJson;

                    if(responseJson[0] != '' && responseJson[0] != undefined){
                        response = responseJson[0];
                    }
                });
            });

        let parcelas = null;
        let parcelaMinima = parseInt(response.parcelasDe);
        let parcelaMaxima = parseInt(response.parcelasAte);

        for(let i = parcelaMinima; i <= parcelaMaxima; i++){
            parcelas += "<option value='"+i+"'>"+i+"</option>";
        }

        $(`#NumberOfInstallments_${metodoId}`).html(parcelas);
    }
};

function showOnlyContaRecto(metodoId, contaRecto) {
    setTimeout(function() {
        $("#ct"+metodoId+"_"+contaRecto).click();
    }, 100);
}

var bandeirasList = '<%= BandeirasIDSelect %>'.split(',').map(Number);
var metodoId = '<%= MetodoIDSelect %>';
var contaRecto = '<%= ContaRectoSelect %>';

if (metodoId != "") {
    showOnlyPagamentoDisponivel(metodoId);
    if('<%= BandeirasIDSelect %>'!=""){
        showBandeirasDisponiveis(metodoId, bandeirasList);
    }
    //montarParcelas(metodoId);
}
if (contaRecto != "") {
    showOnlyContaRecto(metodoId, contaRecto);
}
</script>