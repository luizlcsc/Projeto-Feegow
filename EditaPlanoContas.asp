<!--#include file="connect.asp"-->

<script type="text/javascript">
    $(".crumb-active a").html("Plano de Contas");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("arraste os itens para reordenar");
    $(".crumb-icon a span").attr("class", "fa fa-outdent");
</script>

<br />
<div class="row">
	<div class="col-sm-6">
        <div class="panel">
    	    <div class="panel-heading"><span class="panel-title">RECEITAS</span></div>
            <div class="panel-body">
        	    <iframe frameborder="0" width="100%" height="2000" src="relatorio.asp?tiporel=sys_financialincometype&Pers=1"></iframe>
            </div>
        </div>
    </div>
	<div class="col-sm-6">
        <div class="panel">
    	    <div class="panel-heading"><span class="panel-title">DESPESAS</span></div>
            <div class="panel-body">
            	<iframe frameborder="0" width="100%" height="2000" src="relatorio.asp?tiporel=sys_financialexpensetype&Pers=1"></iframe>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
$(document).ready(function() {
  setTimeout(function() {
    $("#toggle_sidemenu_l").click()
  }, 500);
})
</script>