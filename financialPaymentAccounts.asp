<!--#include file="connect.asp"-->
<div class="col-md-12">
<%
T = ref("T")
PaymentMethod = ref("PaymentMethod")

if PaymentMethod="3" then
	%><label for="PaymentAccount">Selecione a Pessoa</label><br /><%
	call selectCurrentAccounts("PaymentAccount", "4, 3, 2", AssociationAccountID&"_"&AccountID, "")
else
	set PaymentMethods = db.execute("select * from sys_financialPaymentMethod where id="&PaymentMethod)
	if not PaymentMethods.EOF then
		%><label for="PaymentAccount"><%=PaymentMethods("Text"&T)%></label><br />
		<select name="PaymentAccount" class="chosen-select width-80" id="PaymentAccount">
			<%
			splAccountTypes = split(PaymentMethods("AccountTypes"&T), "|")
			for i=0 to ubound(splAccountTypes)
				set PaymentAccounts=db.execute("select * from sys_financialCurrentAccounts where AccountType="&splAccountTypes(i))
				while not PaymentAccounts.EOF
					%><option value="1_<%=PaymentAccounts("id")%>"><%=PaymentAccounts("AccountName")%></option>
				<%PaymentAccounts.movenext
				wend
				PaymentAccounts.close
				set PaymentAccounts=nothing
			next
			
				
			end if
			%></select>
<div class="row">
		<%
		if T="C" then
			select case PaymentMethods("id")
			case 2'check
				%>
				<%=quickField("select", "BankID", "Banco Emissor", "12", "", "select * from sys_financialBanks order by BankName", "BankName", "")%>
				<%=quickField("text", "CheckNumber", "N&uacute;mero do Cheque", "6", "", "", "", "")%>
				<%=quickField("text", "Holder", "Titular", "6", "", "", "", "")%>
				<%=quickField("text", "Document", "Documento", "6", "", "", "", "")%>
				<%=quickField("datepicker", "CheckDate", "Data do Cheque", "6", date(), "", "", "")%>
				<%=quickField("simpleCheckbox", "Cashed", "Compensado?", "6", "", "", "", "")%>
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
end if
%>
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
});

$("#PaymentAccount").change(function(){
	FinancialValuePayment();
});
</script>