<!--#include file="connect.asp"-->
<%
if recursoAdicional(24) <> 4 or Aut("labsconfigintegracao") <> 1 then
    response.status = 403
else
%>
<script type="text/javascript">
    $(".crumb-active a").html("Configurações Integração Laboratorial");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Listagem de Exames");
    $(".crumb-icon a span").attr("class", "fa fa-th");
</script>
<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="fa fa-spin fa-spinner"></i>
</div>

<script type="text/javascript">
    getUrl("labs-integration/listagem-exames-view",{}, function(data) {
        $(".app").hide();
        $(".app").html(data);
        $(".app").fadeIn('slow');
    });
</script>
<% end if %>