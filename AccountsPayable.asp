<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<%
if req("T")="C" then
	titulo = "CONTAS A RECEBER"
else
	titulo = "CONTAS A PAGAR"
end if
%>
<div class="row">
  <div class="col-xs-2">
	<!--#include file="MenuFinanceiro.asp"-->
  </div>
  <div class="col-xs-10">






<div class="widget-box transparent">
    <div class="widget-header widget-header-flat">
        <h4><i class="far fa- blue"></i> <%= titulo %></h4>
    </div>
</div>

    
    <div id="Extrato"></div>

  </div>
</div>
<script language="javascript">

getStatement('<%=req("T")%>', '', '', '', '<%=session("Unidades")%>');

function atualizaPagtos(){
	$("#Filtrate").click();
}

<!--#include file="financialCommomScripts.asp"-->

</script>