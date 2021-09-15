<!--#include file="connect.asp"-->
<%
id = ref("id")
AccountType = ref("AccountType")
set reg = db.execute("select * from sys_financialcurrentaccounts where id="&id)

if not reg.eof then
	id = reg("id")
	rAccountName = reg("AccountName")
	Holder = reg("Holder")
	CategoriadTaxaID = reg("CategoriadTaxaID")
	Document = reg("Document")
	UsuariosConfirmadores = reg("UsuariosConfirmadores")
	Bank = reg("Bank")
	Branch = reg("Branch")
	CurrentAccount = reg("CurrentAccount")
	Proprietario = reg("Proprietario")
	CreditAccount = reg("CreditAccount")
	DaysForCredit = reg("DaysForCredit")
	BestDay = reg("DaysForCredit")
	PercentageDeducted = reg("PercentageDeducted")
	if not isnull(PercentageDeducted) then PercentageDeducted=formatnumber(PercentageDeducted,2) end if
	DueDay = reg("DueDay")
	BestDay = reg("BestDay")
	sysActive = reg("sysActive")
	IntegracaoStone = reg("IntegracaoStone")
	IntegracaoSPLIT = reg("IntegracaoSPLIT")
end if


StatusSplit = recursoAdicional(15)
StatusTEF = recursoAdicional(14)
%>
<div class="row">
<%

select Case AccountType
	case 1
    	call quickField("text", "AccountName", "Nome de Identificação", "12", rAccountName, "", "", "")
	case 2
		'db_execute("update cliniccentral.sys_resources set sqlSelectQuickSearch='select id, BankName from sys_financialbanks where BankName like ''%[TYPED]%'' order by BankName', Pers=0 where name='Bancos'")
		%>
		<div class="col-md-6">
            <%=selectInsert("Banco", "Bank", Bank, "sys_financialBanks", "BankName", "", "", "")%>
        </div>
		<%
'		call quickField("select", "Bank", "Banco", "6", Bank, "select * from sys_financialBanks where sysActive=1 order by BankName", "BankName", "")
		call quickField("text", "AccountName", "Nome de Identificação", "6", rAccountName, "", "", "")
		call quickField("text", "Branch", "Agência", "6", Branch, "", "", "")
		call quickField("text", "CurrentAccount", "Número da Conta", "6", CurrentAccount, "", "", "")
		call quickField("text", "Holder", "Titular", "6", Holder, "", "", "")
		call quickField("text", "Document", "Documento", "6", Document, "", "", "")
	case 3, 4, 6
		call quickField("text", "AccountName", "Nome de Identificação", "6", rAccountName, "", "", "")
		call quickField("text", "DaysForCredit", "Dias para Crédito", "3", DaysForCredit, " text-right", "", "")
		call quickField("text", "PercentageDeducted", "Taxa Adm. Padrão", "3", PercentageDeducted, " input-mask-brl text-right", "", "")
		call quickField("simpleSelect", "CreditAccount", "Conta para Recebimento", 4, CreditAccount, "select * from sys_financialcurrentaccounts where AccountType=2 and sysActive=1 order by AccountName", "AccountName", "")
		call quickField("simpleSelect", "CategoriadTaxaID", "Categoria da Tarifa", 4, CategoriadTaxaID, "SELECT * FROM sys_financialexpensetype", "Name", "")
	case 5
		call quickField("text", "AccountName", "Cartão de Crédito - Especifique o Cartão", "12", rAccountName, "", "", "")
		call quickField("text", "DueDay", "Dia do Vencimento", "6", DueDay, "", "", "")
		call quickField("text", "BestDay", "Melhor Dia para Compra", "6", BestDay, "", "", "")
end select

%>
</div>

        <% if StatusTEF=4 then%>
        <div style="margin-top: 15px;" class="col-md-1">
            <label>
                TEF
                <div class="switch round">
                    <input type="checkbox" <% If IntegracaoStone="S" Then %> checked="checked"<%end if%> value="S" class="checkbox-ativo" data-type="IntegracaoStone" data-group="IntegracaoStone" name="IntegracaoStone" id="IntegracaoStone">
                    <label for="IntegracaoStone"></label>
                </div>

            </label>
        </div>
        <% end if %>

        <% if StatusSplit=4 then%>
        <div style="margin-top: 15px;" class="col-md-1">
            <label>
                SPLIT
                <div class="switch round">
                    <input type="checkbox" <% If IntegracaoSPLIT="S" Then %> checked="checked"<%end if%> value="S" class="checkbox-ativo" data-type="IntegracaoSPLIT" data-group="IntegracaoSPLIT" name="IntegracaoSPLIT" id="IntegracaoSPLIT">
                    <label for="IntegracaoSPLIT"></label>
                </div>

            </label>
        </div>
        <%
        end if
        %>

		<%		
		 if AccountType = 3 or AccountType = 6 or AccountType = 4 then %>
			<div class="col-md-8" style="margin-top: 25px;">
				<form id="percentual_form">
					<table id="percentual-conta" class="table table-bordered table-striped">
						<tr class="primary">						
							<th width="18%">Mínimo</th>
							<th width="18%">Máximo</th>
							<th width="18%">Bandeiras</th>
							<th width="35%">Taxa Administrativa</th>
						
								<th width="18%">Tipo</th>
							
							<th style="text-align: center;">
								<button type="button" onclick="gerarLinhaTabelaPercentualConfiguracao()" class="btn btn-xs btn-success">
									<i class="far fa-plus"></i>
								</button>
							</th>
						</tr>
						<% 					
						set list = db.execute("select * from sys_financial_current_accounts_percentual where sys_financialCurrentAccountId = "&id& " order by tipoFormaPagamento asc, minimo asc") %>
												
						<% while not list.eof %>
							<% readOnly = "" %>
							<% if list("tipoFormaPagamento")&"" = "9" then %>
								<% readOnly = "readOnly" %>
							<% end if %>
							<tr data-financial-current-account-id="<%=list("id")%>">								
								<td width="18%"><input type="number" <%= readOnly %> min="1" max="12" class="form-control  text-right" name="minimo" required value="<%=list("minimo")%>"></td>
								<td width="18%"><input type="number" <%= readOnly %> min="1" max="12" class="form-control  text-right" name="maximo" required value="<%=list("maximo")%>"></td>
								<td>
									<select class="select-bandeiras" name="bandeira">
										<option value=0 >Selecione um item</option>        
										<% set bandeiras = db.execute("SELECT * from cliniccentral.bandeiras_cartao")
										while not bandeiras.eof										
											selected = ""
											if list("bandeira") = bandeiras("id") then
												selected = "selected"	
											end if
										%>
											<option <%= selected %> value="<%=bandeiras("id")%>"><%=bandeiras("Bandeira")%></option>
										<%
										bandeiras.movenext
										wend
										bandeiras.close
										set bandeiras=nothing
										%>    									
									</select>
								</td>	
								<td width="15%"><input type="text" class="form-control  input-mask-brl text-right" name="percentual" required value="<%=fn(list("acrescimoPercentual"))%>"></td>
																
								
								<% if AccountType = 6 then %>
								<td>
									<% 																			
										Set dictionaryTipoPagamento = Server.CreateObject("Scripting.Dictionary")
										dictionaryTipoPagamento.Add "9","Débito"
										dictionaryTipoPagamento.Add "8","Crédito"																		
									 %>
									<select class="select-tipo-pagamento" name="tipo_pagamento" required onchange="checkTipoPagamento(this)">
										<option value='' >Selecione um item</option>
										<% for each intKey in dictionaryTipoPagamento 
											selected = ""			
											if intKey = list("tipoFormaPagamento")&"" then 
												selected = "selected"
											end if
										%>
											<option <%= selected %> value=<%= intKey %>><%= dictionaryTipoPagamento.item(intKey) %></option>											
										<% next %>										
									</select>
								</td>
								<% end if %>
								<% if AccountType = 3 then %>
								<td>
									<% 																			
										Set dictionaryTipoPagamento = Server.CreateObject("Scripting.Dictionary")										
										dictionaryTipoPagamento.Add "8","Crédito"																		
									 %>
									<select disabled class="select-tipo-pagamento" name="tipo_pagamento" required onchange="checkTipoPagamento(this)">
										<option selected value="8">Crédito</option>																															
									</select>
								</td>
								<% end if %>																					
								<% if AccountType = 4 then %>
								<td>
									<% 																			
										Set dictionaryTipoPagamento = Server.CreateObject("Scripting.Dictionary")										
										dictionaryTipoPagamento.Add "9","Débito"																		
									 %>
									<select disabled class="select-tipo-pagamento" name="tipo_pagamento" required onchange="checkTipoPagamento(this)">
										<option selected value="9">Débito</option>																															
									</select>
								</td>
								<% end if %>
								<td width="18%" ><button type="button" onclick="excluirItemPercentualConfiguracao(this)" class="btn btn-danger btn-xs far fa-trash"></button></td>
							</tr>
						<%
						list.movenext
						wend
						list.close
						set list = nothing
						%>
					</table>
				</form>
			</div>
		<% end if %>

		<%

if AccountType = 2 or AccountType=1 then
    %>
    <%=quickfield("multiple", "UsuariosConfirmadores", "Usuário confirmadores", 6, UsuariosConfirmadores, "SELECT id,Nome FROM                                                                                 (SELECT su.id,prof.NomeProfissional Nome                                                                                                                                                                 FROM profissionais prof                                                                                 INNER JOIN sys_users su ON su.idInTable=prof.id AND su.table='profissionais'                                                                                 WHERE prof.Ativo='on' AND prof.sysActive=1                                                                                                                                                                 UNION ALL                                                                                                                                                                 SELECT su.id,func.NomeFuncionario Nome                                                                                 FROM funcionarios func                                                                                 INNER JOIN sys_users su ON su.idInTable=func.id AND su.table='funcionarios'                                                                                 WHERE func.Ativo='on' AND func.sysActive=1)t                                                                                ORDER BY t.Nome", "Nome", "")%>
    <%
end if
%>
</div>

<script language="javascript">
	jQuery(function($) {
		$(".chosen-select").chosen();
	});

	/*$("#Bank").change(function(){
		$("#AccountName").val($("#Bank").val());
	});*/

	<!--#include file="jQueryFunctions.asp"-->
	
	var debito = 9;
	var credito = 8;
	
	function disableEnableInputsMinimoMaximoDebito(inputSelectTipo, disable) {
		let listInputsMinimoMaximo = inputSelectTipo.parentNode.parentNode.querySelectorAll('input[name="minimo"], input[name="maximo"]');
	
		listInputsMinimoMaximo.forEach(inputMinimoMaximo => {
			inputMinimoMaximo.readOnly = disable;
			if (disable == true) {
				inputMinimoMaximo.value = 1;
			}

		});
	};

	checkTipoPagamento = inputSelectTipo => {		
		let valueSelected = inputSelectTipo.options[inputSelectTipo.selectedIndex].value;

		if(valueSelected == debito) {
			disableEnableInputsMinimoMaximoDebito(inputSelectTipo, true);
		}

		if(valueSelected == credito) {
			disableEnableInputsMinimoMaximoDebito(inputSelectTipo, false);
		}
	};

	gerarLinhaTabelaPercentualConfiguracao = async _ => {
        let tableRef = document.getElementById("percentual-conta");
        let newRow = tableRef.insertRow(-1);

        let newCellMinimo = newRow.insertCell(0);		
        let newCellMaximo = newRow.insertCell(1);
		let newCellSelect = newRow.insertCell(2);
		let newCellAcrescimoPercentual = newRow.insertCell(3);
		let newCellTipoPagamento = newRow.insertCell(4);
		let newCellExcluir = newRow.insertCell(5);

		gerarInputButtonsToTableh = await gerarInputButtonsToTable();

        newCellMinimo.appendChild(gerarInputButtonsToTableh.inputNumberMinimo);
        newCellMaximo.appendChild(gerarInputButtonsToTableh.inputNumberMaximo);
 		newCellSelect.appendChild(gerarInputButtonsToTableh.selectListBandeira);
        newCellAcrescimoPercentual.appendChild(gerarInputButtonsToTableh.inputNumberPercentual);
		

		// console.log(gerarInputButtonsToTableh.selectListTipoPagamento);
		newCellTipoPagamento.appendChild(gerarInputButtonsToTableh.selectListTipoPagamento);

		if($("#AccountType").select2('val') == '3'){
			mudarValorTipoPagamentoSomenteCredito(newCellTipoPagamento);
			removerMinimoMaximoReadOnly();
		}
		if($("#AccountType").select2('val') == '4'){
			mudarValorTipoPagamentoSomenteDebito(newCellTipoPagamento);
			removerMinimoMaximoReadOnly();
		}
		
		newCellExcluir.appendChild(gerarInputButtonsToTableh.buttonExcluir);

		$(".input-mask-brl").maskMoney({prefix:'', thousands:'.', decimal:',', affixesStay: true});
		$('.select-bandeiras').select2();
		$('.select-tipo-pagamento').select2();		
	}

	function mudarValorTipoPagamentoSomenteCredito(cellTipoPagamento) {
		let selectTipoPagamento = (cellTipoPagamento.querySelectorAll("input, select, checkbox, textarea"))[0];
		selectTipoPagamento.selectedIndex = 2; //tipo crédito
		selectTipoPagamento.disabled = true;
	}
	function mudarValorTipoPagamentoSomenteDebito(cellTipoPagamento) {
		let selectTipoPagamento = (cellTipoPagamento.querySelectorAll("input, select, checkbox, textarea"))[0];
		selectTipoPagamento.selectedIndex = 1; //tipo crédito
		selectTipoPagamento.disabled = true;
	}

	removerMinimoMaximoReadOnly = _ => {
		document.getElementById("percentual-conta").querySelectorAll("input").forEach(item => {
			if(item.name == "minimo" || item.name == 'maximo') {
				item.readOnly = false;
			}
		});
	}

	createArrayObjectPercentual = _ => {
		let percentualForm = document.querySelector('#percentual_form');

		objectPercentualForm = {};
		Object.values(percentualForm).forEach(item => {
			if(item.name == '') {
				return;
			}
			objectPercentualForm[item.name] = [];
		});

		Object.values(percentualForm).forEach(item => {
			if(item.name == '') {
				return;
			}

			if(item.name === 'percentual' && item.value == "") {
				objectPercentualForm[item.name].push(item.value);
			}

			objectPercentualForm[item.name].push(item.value);
		});	

		return objectPercentualForm;
	}

	checkMinIsGreaterMax = _ => {
		objectPercentualForm = createArrayObjectPercentual();

		arrayMinMaxObject = [];
		for (var key in objectPercentualForm.minimo) {	
			arrayMinMaxObject[key] = {}	
		}

		for (var key in arrayMinMaxObject) {
			arrayMinMaxObject[key] = { 'minimo': objectPercentualForm.minimo[key], 'maximo': objectPercentualForm.maximo[key] };			
		}

		for (var item of arrayMinMaxObject) {
			if(parseInt(item.minimo) > parseInt(item.maximo)){				
				return true
			}			
		}

		return false;	
	}
	
	function countBy(arr) {
		return arr.reduce((prev, curr) => (prev[curr] = ++prev[curr] || 1, prev), {})
	}
	
	checkMaisUmaBandeiraDebito = _ => {
		let objectPercentualForm = createArrayObjectPercentual();
		let bandeirasDebito = [];
		let invalid = false;

		for (let key in objectPercentualForm.bandeira) {
			if (objectPercentualForm.tipo_pagamento[key] == debito) {
				bandeirasDebito.push(objectPercentualForm.bandeira[key]);	
			}	
		}		

		Object.values(countBy(bandeirasDebito)).forEach(item => {
			if(item > 1){
				invalid = true;
			}
		});

		return invalid;
	}

	checkConflictValorMinimoMaximoIgual = _ => {
		let objectMinMax = { minimo: [], maximo: [] };
		objectPercentualForm = createArrayObjectPercentual();

		arrayMinMaxObject = [];
		for (var key in objectPercentualForm.minimo) {	
			arrayMinMaxObject[key] = {}	
		}

		for (var key in arrayMinMaxObject) {		
			arrayMinMaxObject[key] = { 'minimo': objectPercentualForm.minimo[key], 'maximo': objectPercentualForm.maximo[key], 'tipo_pagamento': objectPercentualForm.tipo_pagamento[key] };
		}	

		arrayMinMaxObject.forEach(itemNivelUm => {
			if (itemNivelUm.tipo_pagamento != debito) {			
            	objectMinMax.minimo.push(itemNivelUm.minimo);
            	objectMinMax.maximo.push(itemNivelUm.maximo);
            }
		});		

		let conflictDetect = false;
		Object.values(countBy(objectMinMax.minimo)).forEach((item) => {
			if(item > 1) {
				// conflictDetect = true;
				return;
			}
		});

		Object.values(countBy(objectMinMax.maximo)).forEach((item) => {
			if(item > 1) {
				// conflictDetect = true;
				return;
			}
		});

		return conflictDetect;

	}

	checkConflict = _ => {		
		objectPercentualForm = createArrayObjectPercentual();

		arrayMinMaxObject = [];
		for (var key in objectPercentualForm.minimo) {	
			arrayMinMaxObject[key] = {}	
		}

		let objectMinMax = { minimo: [], maximo: [] };
		
		arrayMinMaxObject.forEach(itemNivelUm => {
            objectMinMax.minimo.push(itemNivelUm.minimo);
            objectMinMax.maximo.push(itemNivelUm.maximo);
		});
		for (var key in arrayMinMaxObject) {
			//console.log(objectPercentualForm);
			arrayMinMaxObject[key] = { 'minimo': objectPercentualForm.minimo[key], 'maximo': objectPercentualForm.maximo[key], 'tipo_pagamento': objectPercentualForm.tipo_pagamento[key] };
		}		
		
		let conflictDetect = false;
		arrayMinMaxObject.forEach(itemNivelUm => {

			if(itemNivelUm.tipo_pagamento == debito) {				
				return;	
			}	

			arrayMinMaxObject.forEach(itemNivelDois => {									
				if(itemNivelUm.minimo == itemNivelDois.minimo && itemNivelUm.maximo == itemNivelDois.maximo){
					return;
				}

				if(itemNivelDois.tipo_pagamento == debito) {					
					return;	
				}					

				if(checkBetween(itemNivelUm.minimo, itemNivelDois.minimo, itemNivelDois.maximo)){
					conflictDetect = true;
				}
			});

		});

		return conflictDetect;		
	}

	function checkBetween(value, min, max) {
 			return (value - min) * (value - max) <= 0;
	}

	fillObjectPercentualToQueryString = _ => {
		let percentualForm = document.querySelector('#percentual_form');

		let objectPercentualForm = {};
		Object.values(percentualForm).forEach((item) => {
			if(item.name == '') {
				return;
			}
			objectPercentualForm[item.name] = [];
		});

		Object.values(percentualForm).forEach((item) => {
			if(item.name == '') {
				return;
			}

			if(item.name === 'percentual' && item.value == "") {
				objectPercentualForm[item.name].push(item.value);
			}

			objectPercentualForm[item.name].push(item.value);
		});

		let formData = new FormData();
		for (const key of Object.keys(objectPercentualForm)) {
			formData.append(key, objectPercentualForm[key]);
		}

		let queryString = '';
		for (var key in objectPercentualForm) {
			if (queryString != "") {
				queryString += "&";
			}
			queryString += key + "=" + encodeURIComponent(objectPercentualForm[key].join("||"));
		}

		return queryString;
	}

	getBandeiras = async _ => {
		const header = { method: 'GET', cache: 'default' };
		let response = await fetch(`bandeirasJson.asp`);
		var res = '';
  		await response.json().then((item) => {
			  res = item;
		  });
		
  		return res;
	}

	criarInputMinimo = _ => {
		let inputNumberMinimo = document.createElement("input")
		inputNumberMinimo.setAttribute("type", "number")
		inputNumberMinimo.setAttribute("class", "form-control  text-right")
		inputNumberMinimo.setAttribute("name", "minimo");
		inputNumberMinimo.setAttribute("min", "1");
		<%
		if AccountType=4 then
        %>
        inputNumberMinimo.setAttribute("max", "1");
        inputNumberMinimo.setAttribute("value", "1");
        <%
        else
        %>
		inputNumberMinimo.setAttribute("max", "12");
        <%
		end if
		%>
		inputNumberMinimo.setAttribute("required", "");

		return inputNumberMinimo;
	}

	criarInputMaximo = _ => {
		let inputNumberMaximo = document.createElement("input")
		inputNumberMaximo.setAttribute("type", "number")
		inputNumberMaximo.setAttribute("class", "form-control  text-right")
		inputNumberMaximo.setAttribute("name", "maximo");
		inputNumberMaximo.setAttribute("min", "1");
		<%
		if AccountType=4 then
        %>
        inputNumberMaximo.setAttribute("max", "1");
        inputNumberMaximo.setAttribute("value", "1");
        <%
        else
        %>
		inputNumberMaximo.setAttribute("max", "12");
        <%
		end if
		%>
		inputNumberMaximo.setAttribute("required", "");

		return inputNumberMaximo;
	}

	criarSelectBandeira = async _ => {
		let selectListBandeira = document.createElement("select");
		selectListBandeira.setAttribute("class", "select-bandeiras");
		selectListBandeira.setAttribute("name", "bandeira");		

		let bandeiras = await getBandeiras();		

		let optionBandeiraDefault = document.createElement("option");				
		optionBandeiraDefault.text = 'Selecione um item';
		optionBandeiraDefault.value = 0;		
		
		selectListBandeira.appendChild(optionBandeiraDefault);	
		
		bandeiras.forEach(item => {
			let optionBandeira = document.createElement("option");
			optionBandeira.value = item.id
			optionBandeira.text = item.name
			selectListBandeira.appendChild(optionBandeira);	
		});

		return selectListBandeira;
	}

	criarInputNumberPercentual = _ => {
		let inputNumberPercentual = document.createElement("input")
		inputNumberPercentual.setAttribute("type", "text")
		inputNumberPercentual.setAttribute("class", "form-control input-mask-brl text-right")
		inputNumberPercentual.setAttribute("name", "percentual");
		inputNumberPercentual.setAttribute("required", "");

		return inputNumberPercentual;
	}	

	criarListListTipoPagamento = _ => {
		let selectListTipoPagamento = document.createElement("select");
		selectListTipoPagamento.setAttribute("class", "select-tipo-pagamento");
		selectListTipoPagamento.setAttribute("name", "tipo_pagamento");
		selectListTipoPagamento.setAttribute("onchange", "checkTipoPagamento(this)");		

		let arrayObjectTipoPagamento = [ {value: '', text: 'Selecione um item'}, {value: 9, text: 'Débito'}, {value: 8, text: 'Crédito'} ];

		for (let tipoPagamento of arrayObjectTipoPagamento) {
			let optionTipoPagamento = document.createElement("option");
			optionTipoPagamento.value = tipoPagamento.value;
			optionTipoPagamento.text = tipoPagamento.text;
			selectListTipoPagamento.appendChild(optionTipoPagamento);			
		}

		return selectListTipoPagamento;
	}

	criarButtonExcluir = _ => {
		let buttonExcluir = document.createElement("button");
		buttonExcluir.setAttribute("type", "button");
		buttonExcluir.setAttribute("class", "btn btn-danger btn-xs far fa-trash");
		buttonExcluir.setAttribute("onclick", "excluirItemPercentualConfiguracao(this)");

		return buttonExcluir;
	}

	gerarInputButtonsToTable = async _ => {
		let inputNumberMinimo = criarInputMinimo();
		let inputNumberMaximo = criarInputMaximo(); 
		let selectListBandeira = await criarSelectBandeira();
		let inputNumberPercentual = criarInputNumberPercentual();
		let selectListTipoPagamento = criarListListTipoPagamento();
		let buttonExcluir = criarButtonExcluir();

		return {inputNumberMinimo, inputNumberMaximo, selectListBandeira, inputNumberPercentual, selectListTipoPagamento, buttonExcluir}
	}

	excluirItemPercentualConfiguracao = (self) => {
		let objectParams = {};
		const sys_financialCurrentAccountId = <%= id %>

		self.closest("tr").querySelectorAll("input").forEach(item => {
			objectParams[item.name] = item.value;
		});

		let queryString = '';
		for (var key in objectParams) {
			if (queryString != "") {
				queryString += "&";
			}
			queryString += key + "=" + encodeURIComponent(objectParams[key]);
		}

		const header = { method: 'GET', cache: 'default' };
		return fetch(`deleteConfiguracaoPercentual.asp?sys_financialCurrentAccountId=${sys_financialCurrentAccountId}&${queryString}`, header)
				.then((promiseResponse) => {
					if(promiseResponse.status === 200) {
						self.parentElement.parentElement.remove();
						return;
					}

					new PNotify({
						title: 'Ocorreu um erro!',
						type: 'danger',
						delay: 3000
					});
				}
			);
	}

	validFields = _ => {
		let invalid = false;
		let percentualForm = document.querySelector('#percentual_form');
		Object.values(percentualForm).forEach((item) => {
			if(item.name == '') {
				return;
			}

		//	console.log(item.required, )
		//	console.log(item )
			if(item.required == true && item.value == ''){
				invalid = true;
				return;				
			}	 
		});

		return invalid;
	}

	validFieldsMinMax = _ => {		
		let percentualForm = document.querySelector('#percentual_form');

		for (var item of percentualForm) {	
			if(item.type != 'number'){
				continue;
			}		

			if(!(checkBetween(item.value, item.min, item.max))) {
				return false
			}			
		}

		function checkBetween(value, min, max) {
 			return (value - min) * (value - max) <= 0;
		}

		return true;
	}

	if($("#AccountType").select2('val') == 3){
		removerMinimoMaximoReadOnly();
	}

	persistPercentualConfiguracao = callback => {
		if ($("#AccountType").select2('val') != '3' && $("#AccountType").select2('val') != '6' && $("#AccountType").select2('val') != '4') {
			return;
		}

		if(!validFieldsMinMax()) {			
			new PNotify({ title: 'Valor mínimo ou máximo de parcelas: doze', type: 'danger', delay: 3000 });
			return;
		}

		if(validFields()) {
			new PNotify({ title: 'Todos os campos são obrigatórios!', type: 'danger', delay: 3000 });
			return;
		}

		if(checkConflict()) {
			// new PNotify({ title: 'Conflito detectado nas configurações de parcelas', type: 'danger', delay: 3000 });
			// return;
		}

		if(checkConflictValorMinimoMaximoIgual()) {
			// new PNotify({ title: 'Conflito detectado nas configurações de parcelas.', type: 'danger', delay: 3000 });
			// return;
		}

		if(checkMinIsGreaterMax()) {
			new PNotify({ title: 'Valor minímo não pode ser maior que o máximo', type: 'danger', delay: 3000 });
			return;	
		}

		if(checkMaisUmaBandeiraDebito()) {
			new PNotify({ title: 'Existe mais uma configuração de bandeira para debito', type: 'danger', delay: 3000 });
			return;	
		}

		const header = { method: 'POST',
						 cache: 'default',
						 body: fillObjectPercentualToQueryString(),
						 headers: {
						 	'Content-Type': 'application/x-www-form-urlencoded',
						}						 
					};

		const sys_financialCurrentAccountId = '<%= id %>'
		return fetch(`persistConfiguracaoPercentual.asp?id=${sys_financialCurrentAccountId}`, header)
				.then((promiseResponse) => {
					if(promiseResponse.status === 200) {
						callback();						
						return;
					}
					new PNotify({ title: 'Ocorreu um erro!', type: 'danger', delay: 3000 });				
				}
			);
	}
	 
	$('.select-bandeiras').select2();
	$('.select-tipo-pagamento').select2();
</script>