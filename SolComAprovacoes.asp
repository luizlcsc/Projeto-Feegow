<!--#include file="connect.asp"--;>
<!--#include file="modal.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Solicitação de compra");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Aprovar cotações");
    $(".crumb-icon a span").attr("class", "fa fa-th");
</script>
<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="fa fa-spin fa-spinner"></i>
</div>

<script src="https://unpkg.com/vue-select@latest"></script>
<link rel="stylesheet" href="https://unpkg.com/vue-select@latest/dist/vue-select.css">
<script type="text/javascript">
Vue.component('v-select', VueSelect.VueSelect);
    getUrl("purchaserequest/view/list-approvals", {}, function(data) {
        $(".app").hide();
        $(".app").html(data);
        $(".app").fadeIn('slow');
    });
</script>