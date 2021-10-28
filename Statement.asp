<!--#include file="connect.asp"-->
<div class="row">
  <div class="col-xs-2">
	<!--#include file="MenuFinanceiro.asp"-->
  </div>
  <div class="col-xs-10">
    <div class="widget-box transparent">
        <div class="widget-header widget-header-flat">
            <h4><i class="far fa-money blue"></i> EXTRATO <small>&raquo; hist&oacute;rico financeiro</small></h4>
        </div>
    </div>
    <%server.Execute("Extrato.asp")%>
</div>


<script language="javascript">

//getStatement('<%=req("T")%>', '', '', '');

<!--#include file="financialCommomScripts.asp"-->

</script>

<!--#include file="modal.asp"-->