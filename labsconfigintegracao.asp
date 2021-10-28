<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<%
if recursoAdicional(24) <> 4 or Aut("labsconfigintegracao") <> 1 then
    response.status = 403
else
%>
<script type="text/javascript">
    $(".crumb-active a").html("Configurações Integração Laboratorial");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Dash");
    $(".crumb-icon a span").attr("class", "far fa-th");
</script>
<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="far fa-spin fa-spinner"></i>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/vue/2.5.16/vue.min.js"></script>
<script type="text/javascript">
    getUrl("labs-integration/config-integracao",{}, function(data) {
        $(".app").hide();
        $(".app").html(data);
        $(".app").fadeIn('slow');
    });
</script>
<% end if %>