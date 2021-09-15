<!--#include file="connect.asp"-->
<%


T=ref("T")
splInstallmentsToPay = split(ref("InstallmentsToPay"),", ")
checkedVal = 0
for i=0 to ubound(splInstallmentsToPay)
	if ref("difference"&splInstallmentsToPay(i))<>"" then
		checkedVal = checkedVal+ref("difference"&splInstallmentsToPay(i))
	else
		checkedVal = checkedVal+ref("ValueInstallment"&splInstallmentsToPay(i))
	end if
next
%>
<div class="row">
	<div class="col-md-12" id="Credits">
	<table class="table table-striped table-hover">
    <%
	CreditsHide = "$(""#Credits"").hide();"
	If checkedVal>0 and inStr(ref("AccountID"), "_")>0 and left(ref("AccountID"),2)<>"1_" Then
		splAccountInQuestion = split(ref("AccountID"), "_")
		AccountAssociationID = splAccountInQuestion(0)
		AccountID = splAccountInQuestion(1)



		Balance = 0
		set getMovement = db.execute("select * from sys_financialMovement where ((AccountAssociationIDCredit="&AccountAssociationID&" and AccountIDCredit="&AccountID&") or (AccountAssociationIDDebit="&AccountAssociationID&" and AccountIDDebit="&AccountID&")) and Date<='"&myDate(date())&"' order by Date")
		while not getMovement.eof
		

			Value = getMovement("Value")
			Rate = getMovement("Rate")
			
			
			AccountAssociationIDCredit = getMovement("AccountAssociationIDCredit")
			AccountIDCredit = getMovement("AccountIDCredit")
			AccountAssociationIDDebit = getMovement("AccountAssociationIDDebit")
			AccountIDDebit = getMovement("AccountIDDebit")
			PaymentMethodID = getMovement("PaymentMethodID")
			'defining who is the C and who is the D
			if getMovement("Currency")<>session("DefaultCurrency") then
				Value = Value / Rate
			end if
			'if ref("Currency")<>session("DefaultCurrency") then
			'	if getMovement("Currency")<>ref("Currency") then
			'		Value = Value * Rate
			'	end if
			'else
			'	if getMovement("Currency")<>ref("Currency") then
			'		Value = Value / Rate
			'	end if
			'end if
			if ccur(AccountAssociationIDCredit)=ccur(AccountAssociationID) and ccur(AccountIDCredit)=ccur(AccountID) then
				CD = "C"
				'response.Write(Balance&"+"&value)
				Balance = Balance+Value
				accountReverse = accountName(AccountAssociationIDDebit, AccountIDDebit)
			else
				CD = "D"
				'response.Write(Balance&"-"&value)
				Balance = Balance-Value
				accountReverse = accountName(AccountAssociationIDCredit, AccountIDCredit)
			end if
			'-
			cType = getMovement("Type")
			
			AlreadyDiscounted = 0
			set getAlreadyDiscounted = db.execute("select * from sys_financialDiscountPayments where InstallmentID="&getMovement("id"))
			while not getAlreadyDiscounted.EOF
				AlreadyDiscounted = AlreadyDiscounted+getAlreadyDiscounted("DiscountedValue")
			getAlreadyDiscounted.movenext
			wend
			getAlreadyDiscounted.close
			set getAlreadyDiscounted = nothing

			PaymentMovement = 0
			set getPaymentMovement = db.execute("select * from sys_financialDiscountPayments where MovementID="&getMovement("id"))
			while not getPaymentMovement.EOF
				PaymentMovement = PaymentMovement+getPaymentMovement("DiscountedValue")
				getPaymentMovement.movenext
				wend
				getPaymentMovement.close
				set getPaymentMovement = nothing
				
				NotDiscounted = Value - AlreadyDiscounted - PaymentMovement
			
				if (CD=T or getMovement("Type")="Pay") and round(NotDiscounted)>0 then
					CreditsHide = ""
				
					checkboxValue = NotDiscounted
					if getMovement("Currency")<>session("DefaultCurrency") then
						checkboxValue = checkboxValue * Rate
					end if
					%><tr>
						<td width="8%" class="text-right">
						<label><input class="ace overbalance" type="checkbox" name="overbalance" value="<%=getMovement("id")&"_"&checkboxValue%>"><span class="lbl"></span></label>
						</td>
						<td><%= getMovement("Date") %></td>
						<td nowrap="nowrap" class="text-right"><%=session("CurrencySymbol")%>&nbsp;<%= formatnumber(NotDiscounted,2) %><%'= NotDiscounted %></td>
						<td>
						  <div class="action-buttons">
								<a class="blue" onclick="modalPaymentDetails(<%=getMovement("id")%>);" data-toggle="modal" role="button" href="#modal-table">
									<i class="far fa-zoom-in bigger-130"></i>
								</a>
							</div>
						</td>
					</tr>
					<%
				end if
		getMovement.movenext
		wend
		getMovement.close
		set getMovement = nothing



	End If %>
    </table>
    </div>
</div>
<%'show this row only if is not checked overbalance%>
<div id="standardPayment"> <br />

    <div class="col-md-12">
    <label for="PaymentMethod">Forma de Pagamento</label>
    <select class="chosen-select width-80" name="PaymentMethod" id="PaymentMethod">
        <option value="0">Selecione</option>
        <%
        set PaymentMethod = db.execute("select * from sys_financialPaymentMethod where AccountTypes"&T&"<>'' or id=3 order by PaymentMethod")
        while not PaymentMethod.eof
            %><option value="<%=PaymentMethod("id")%>"><%=PaymentMethod("PaymentMethod")%></option>
            <%
        PaymentMethod.movenext
        wend
        PaymentMethod.close
        set PaymentMethod=nothing
        %>
    </select>
    </div>                                                            
    
    <div id="divPaymentMethod"></div>
    
    <div class="col-md-12">
    <label for="Obs">
    Observações
    </label>
    <textarea class="form-control" id="Obs" name="Obs" placeholder=""></textarea><br />
<div class="row" id="ValorPagamento">
</div>
<hr />
    </div>
    
    <div class="well well-sm"><button class="btn btn-sm btn-success" type="button" onclick="makePayment();"><i class="far fa-check align-top bigger-125"></i>Pagar</button></div>
</div>


<div id="overbalancePayment" style="display:none">
    <div class="col-md-6">
    <label>Valor a Descontar</label>
    <div class="input-group">
    <span class="input-group-addon">
    <strong><%=session("DefaultCurrency")%></strong>
    </span>
    <input class="form-control input-mask-brl" placeholder="" type="text" value="0,00" name="OverbalancePaymentValue" id="OverbalancePaymentValue" style="text-align:right" />
    </div>
    </div>

	<div class="col-md-12"><br />
		<div class="well well-sm"><button class="btn btn-sm btn-success" type="button" onclick="discountOverbalance();"><i class="far fa-check align-top bigger-125"></i>Pagar</button></div>
    </div>
</div>







<script type="text/javascript">
jQuery(function($) {
	$('#id-disable-check').on('click', function() {
		var inp = $('#form-input-readonly').get(0);
		if(inp.hasAttribute('disabled')) {
			inp.setAttribute('readonly' , 'true');
			inp.removeAttribute('disabled');
			inp.value="This text field is readonly!";
		}
		else {
			inp.setAttribute('disabled' , 'disabled');
			inp.removeAttribute('readonly');
			inp.value="This text field is disabled!";
		}
	});


	$(".chosen-select").chosen(); 

	$.mask.definitions['~']='[+-]';
	$('.input-mask-date').mask('99/99/9999');
	$(".input-mask-brl").maskMoney({prefix:'', thousands:'.', decimal:',', affixesStay: true});

	
	$('#id-input-file-1 , #id-input-file-2').ace_file_input({
		no_file:'No File ...',
		btn_choose:'Choose',
		btn_change:'Change',
		droppable:false,
		onchange:null,
		thumbnail:false //| true | large
		//whitelist:'gif|png|jpg|jpeg'
		//blacklist:'exe|php'
		//onchange:''
		//
	});
	
	$('#id-input-file-3').ace_file_input({
		style:'well',
		btn_choose:'Anexar arquivos',
		btn_change:null,
		no_icon:'icon-cloud-upload',
		droppable:true,
		thumbnail:'small'//large | fit
		//,icon_remove:null//set null, to hide remove/reset button
		/**,before_change:function(files, dropped) {
			//Check an example below
			//or examples/file-upload.html
			return true;
		}*/
		/**,before_remove : function() {
			return true;
		}*/
		,
		preview_error : function(filename, error_code) {
			//name of the file that failed
			//error_code values
			//1 = 'FILE_LOAD_FAILED',
			//2 = 'IMAGE_LOAD_FAILED',
			//3 = 'THUMBNAIL_FAILED'
			//alert(error_code);
		}

	}).on('change', function(){
		//console.log($(this).data('ace_input_files'));
		//console.log($(this).data('ace_input_method'));
	});
	

	//dynamically change allowed formats by changing before_change callback function
	$('#id-file-format').removeAttr('checked').on('change', function() {
		var before_change
		var btn_choose
		var no_icon
		if(this.checked) {
			btn_choose = "Anexar imagem";
			no_icon = "far fa-picture";
			before_change = function(files, dropped) {
				var allowed_files = [];
				for(var i = 0 ; i < files.length; i++) {
					var file = files[i];
					if(typeof file === "string") {
						//IE8 and browsers that don't support File Object
						if(! (/\.(jpe?g|png|gif|bmp)$/i).test(file) ) return false;
					}
					else {
						var type = $.trim(file.type);
						if( ( type.length > 0 && ! (/^image\/(jpe?g|png|gif|bmp)$/i).test(type) )
								|| ( type.length == 0 && ! (/\.(jpe?g|png|gif|bmp)$/i).test(file.name) )//for android's default browser which gives an empty string for file.type
							) continue;//not an image so don't keep this file
					}
					
					allowed_files.push(file);
				}
				if(allowed_files.length == 0) return false;

				return allowed_files;
			}
		}
		else {
			btn_choose = "Drop files here or click to choose";
			no_icon = "far fa-cloud-upload";
			before_change = function(files, dropped) {
				return files;
			}
		}
		var file_input = $('#id-input-file-3');
		file_input.ace_file_input('update_settings', {'before_change':before_change, 'btn_choose': btn_choose, 'no_icon':no_icon})
		file_input.ace_file_input('reset_input');
	});

	
	$('.date-picker').datepicker({autoclose:true}).next().on(ace.click_event, function(){
		$(this).prev().focus();
	});
	$('input[name=date-range-picker]').daterangepicker().prev().on(ace.click_event, function(){
		$(this).next().focus();
	});
	
	$('#timepicker1').timepicker({
		minuteStep: 1,
		showSeconds: true,
		showMeridian: false
	}).next().on(ace.click_event, function(){
		$(this).prev().focus();
	});
	
	$(".knob").knob();

	$('#PaymentMethod').change(function(){
		$.post("financialPaymentAccounts.asp",{
			   PaymentMethod:$("#PaymentMethod").val(),
			   T:$("#T").val(),
			   },function(data,status){
			$("#divPaymentMethod").html(data);
			FinancialValuePayment();
		});
	});



	$(".overbalance").click(function(){
	
	var result = $("input[name=overbalance]:checked").map(function () {return this.value;}).get().join(",");
	if(result!=''){
			$("#standardPayment").fadeOut(500);
			$("#overbalancePayment").fadeIn(500);
		}else{
			$("#standardPayment").fadeIn(500);
			$("#overbalancePayment").fadeOut(500);
		};
	
	});


});
<%= CreditsHide %>
</script>