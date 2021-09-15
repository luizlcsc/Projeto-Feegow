<!--#include file="connect.asp"-->

<script type="text/javascript">
    $(".crumb-active").html("<a href='#'>Controle de Estoque</a>");
    $(".crumb-icon a span").attr("class", "far fa-medkit");
    $(".crumb-trail").removeClass("hidden");
    $(".crumb-trail").html("painel principal");
</script>

<%
if aut("estoque")=1 then
%>
<br />
	<div class="panel">
    	<div class="panel-body">
        	<div class="col-xs-12" id="container" style="min-width: 310px; height: 400px; margin: 0 auto">
                <h3>Posição Atual</h3>
                <i class="far fa-circle-o-notch fa-spin"></i> Carregando gráfico...
        	</div>
        </div>
        <div class="panel-body">
            <div class="col-md-12">
                <h4>Itens próximos de acabar</h4>
                <h2 id="SaldoGeral">Carregando...</h2><br>
                <div class="row">
                    <div class="col-md-12">
                        <h3></h3>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
            
            </div>
        </div>

    </div>












<%
end if
%>