<!--#include file="connect.asp"-->

<script type="text/javascript">
    $(".crumb-active a").html("Plano de Contas");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("arraste os itens para reordenar");
    $(".crumb-icon a span").attr("class", "far fa-outdent");
</script>

<br />
<div class="row">
	<div class="col-sm-6">
        <div class="panel">
    	    <div class="panel-heading" style="display: flex; justify-content: start; align-items: center">
              <% 
              set rsPosicaoReceita = db.execute("select Posicao from sys_financialincometype where id = 0")
              posicaoReceita = ""
              if not rsPosicaoReceita.eof then
                posicaoReceita = rsPosicaoReceita("Posicao")
              end if
              %>
              <input id="codigo-mae-C" type="text" class="form-control input-codigo" style="width: 50px; min-width:50px" value="<%=posicaoReceita%>" maxlength="2">
              <span class="panel-title">RECEITAS</span>
          </div>
            <div class="panel-body">
        	    <iframe frameborder="0" width="100%" height="2000" src="relatorio.asp?tiporel=sys_financialincometype&Pers=1"></iframe>
            </div>
        </div>
    </div>
	<div class="col-sm-6">
        <div class="panel">
    	    <div class="panel-heading" style="display: flex; justify-content: start; align-items: center">
            <% 
              set rsPosicaoDespesa = db.execute("select Posicao from sys_financialexpensetype where id = 0")
              posicaoDespesa = ""
              if not rsPosicaoDespesa.eof then
                posicaoDespesa = rsPosicaoDespesa("Posicao")
              end if
              %>
            <input id="codigo-mae-D" type="text" class="form-control input-codigo" style="width: 50px; min-width:50px" value="<%=posicaoDespesa%>"  maxlength="2">
            <span class="panel-title">DESPESAS</span>
          </div>
            <div class="panel-body">
            	<iframe frameborder="0" width="100%" height="2000" src="relatorio.asp?tiporel=sys_financialexpensetype&Pers=1"></iframe>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
$(document).ready(function() {

  $(".input-codigo").mask('9?9', {
    placeholder: ''
  });
})
</script>