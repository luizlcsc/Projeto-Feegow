<!--#include file="connect.asp"--;>
<!--#include file="modal.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Solicitação de compra");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Listagem de aprovados");
    $(".crumb-icon a span").attr("class", "far fa-th");
</script>
<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="far fa-spin fa-spinner"></i>
</div>

<script src="https://unpkg.com/vue-select@latest"></script>
<link rel="stylesheet" href="https://unpkg.com/vue-select@latest/dist/vue-select.css">
<script type="text/javascript">
Vue.component('v-select', VueSelect.VueSelect);
    getUrl("purchaserequest/view/list-approveds", {}, function(data) {
        $(".app").hide();
        $(".app").html(data);
        $(".app").fadeIn('slow');
    });
</script>