<!--#include file="connect.asp"-->
                <table width="100%" class="table table-striped table-bordered">
                    <thead>
                        <tr class="success">
                            <th>Pagar</th>
                            <th>Parcela</th>
                            <th width="170">Vencimento</th>
                            <th width="170">Valor</th>
                            <th width="170">Pago</th>
                            <th width="170">Pendente</th>
                            <th width="1%"></th>
                        </tr>
                    </thead>
                    <tbody>
<%
InvoiceID=req("I")
sqlInvoice = "select * from sys_financialInvoices where id="&InvoiceID
'Response.Write(sqlInvoice)
set getInvoice = db.execute(sqlInvoice)
sysActive = getInvoice("sysActive")


simpleCountInstallments = 0
if sysActive=0 then
	Recurrence = ccur(ref("Recurrence"))
	RecurrenceType = ref("RecurrenceType")
	Installments = ref("Installments")
	if isNumeric(Installments) and Installments<>"" then
		Installments = ccur(Installments)
	else
		Installments = 1've no banco
	end if
	
	firstDueDate = ref("firstDueDate")
	if not isDate(firstDueDate) or firstDueDate="" then
		firstDueDate = date()
	end if
	DueDate = firstDueDate
	
	if ref("Value")="" or not isNumeric(ref("Value")) then
		refValue = 0
	else
		refValue = ccur(ref("Value"))
	end if
	
	if refValue>0 then
		installmentValue = refValue/Installments
	else
		installmentValue = 0
	end if
	
	cInstallments = 0
	while cInstallments<Installments
		cInstallments = cInstallments+1
		simpleCountInstallments = simpleCountInstallments+1
		%>
		<!--#include file="InstallmentDetails.asp"-->
		<%
		if isDate(DueDate) and not DueDate="" and RecurrenceType<>"" and Recurrence<>"" then
			DueDate = dateAdd(RecurrenceType, Recurrence, DueDate)
		end if
	wend
else
	'if sysActive=1
	set countInstallments = db.execute("select count(*) as TOTAL from sys_financialMovement where InvoiceID="&InvoiceID)
	Installments = ccur(countInstallments("TOTAL"))
	set getInstallments = db.execute("select * from sys_financialMovement where InvoiceID="&InvoiceID&" order by Date")
	while not getInstallments.EOF
		cInstallments = getInstallments("id")
		InstallmentValue = getInstallments("Value")
		DueDate = getInstallments("Date")
		simpleCountInstallments = simpleCountInstallments+1
		%>
		<!--#include file="InstallmentDetails.asp"-->
		<%
	getInstallments.movenext
	wend
	getInstallments.close
	set getInstallments=nothing
end if

if totalinstallmentValue>0 then
	factor = 100/totalinstallmentValue
	percentPaid = cint(totaldiscountedTotal*factor)
	percentNotPaid = 100 - percentPaid
end if
%>

<%'= "Pago: "&totaldiscountedTotal %>
<%'= "Total: "&totalinstallmentValue %>
<!--div class="row">
    <div class="col-md-12">
        <div class="progress progress-striped active" data-percent="<%=percentPaid%>%">
            <div class="progress-bar progress-bar-success" style="width: <%=percentPaid%>%;"></div>
            <div class="progress-bar progress-bar-danger" style="width: <%=percentNotPaid%>%;"></div>
            <!--div class="progress-bar progress-bar-warning" style="width: 80%;"></div-->
        <!--/div>
    </div>
</div-->
                    </tbody>
                </table>

<script language="javascript">
$(document).ready(function(){
	$(".firstDueDate").change(function(){
		$.post("financialFunctionDueDates.asp",{
			Installments:$("#Installments").val(),
			firstDueDate:$(".firstDueDate").val(),
			Recurrence:$("#Recurrence").val(),
			RecurrenceType:$("#RecurrenceType").val()
			},function(data,status){
		eval(data);
		});
	});
<% If sysActive=0 Then %>
	$(".bootbox-confirm").on(ace.click_event, function() {
		bootbox.confirm("Para efetuar o pagamento &eacute; necess&aacute;rio salvar esta conta.<br /><strong>Deseja salv&aacute;-la agora?</strong>", function(result) {
			if(result) {
				saveInvoice();
			}
			$(".bootbox-confirm").attr("checked", false);
		});
	});
//alert('(<%=sysActive%>)');
<% End If %>
});

jQuery(function($) {
	$('[data-rel=tooltip]').tooltip({container:'body'});
	$('[data-rel=popover]').popover({container:'body'});

});
<% If sysActive=1 Then %>
if(document.getElementById('TriedCheckbox').value!=''){
//	alert(document.getElementById('TriedCheckbox').value);
	document.getElementById(document.getElementById('TriedCheckbox').value).checked=true;
	document.getElementById('TriedCheckbox').value='';
	checkToPay();
}
<% End If %>
</script>
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
			
			function fTriedCheckbox(id){
				document.getElementById('TriedCheckbox').value=id;
			}
		</script>