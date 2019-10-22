<div id="Extrato"></div>

<script language="javascript">

getStatement('CashFlow', '');

function modalPaymentDetails(movementID){
    $.post("modalPaymentDetails.asp",{
		   movementID:movementID
		   },function(data,status){
      $("#modal").html(data);	  
    });	
}

<!--#include file="financialCommomScripts.asp"-->

</script>

<!--#include file="modal.asp"-->