<!--#include file="connect.asp"-->
<%
if recursoAdicional(24) <> 4 or Aut("labsconfigintegracao") <> 1 then
    response.status = 403
else
%>
<script type="text/javascript">
    $(".crumb-active a").html("Configurações Integração Laboratorial");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Listagem de Procedimentos");
    $(".crumb-icon a span").attr("class", "far fa-th");
</script>
<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="far fa-spin fa-spinner"></i>
</div>

<script type="text/javascript">
    <% response.write(retornaChamadaIntegracaoLaboratorial("listagem-procedimentos-view")) %>
</script>
<% end if %>