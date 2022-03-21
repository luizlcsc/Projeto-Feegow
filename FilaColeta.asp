<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->

<style>
.sb-l-o #content_wrapper {
    margin-left: 0;
}
#sidebar_left {
    background-color: transparent!important;
    border:none!important;
}
</style>
<script type="text/javascript">
    $(".crumb-active a").html("Filas de coleta");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("");
    $(".crumb-icon a span").attr("class", "far fa-th");
</script>
<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="far fa-spin fa-spinner"></i>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/vue/2.5.16/vue.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sortablejs@1.8.4/Sortable.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/Vue.Draggable/2.20.0/vuedraggable.umd.min.js"></script>
<script type="text/javascript">
    <% response.write(retornaChamadaIntegracaoLaboratorial("fila-coleta")) %>   
</script>