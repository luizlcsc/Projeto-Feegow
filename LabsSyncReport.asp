<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Relatório Sincronização Laboratórios");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Detalhes de importação e confirmação");
    $(".crumb-icon a span").attr("class", "fa fa-th");
</script>
<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="fa fa-spin fa-spinner"></i>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/vue/2.5.16/vue.min.js"></script>
<script type="text/javascript">
    $("#rbtns").html("<a class='btn btn-warning' href='#'>Sincronizar Resultados</a>");

    getUrl("labs-integration/relatorio-sincronizacao", {}, function(data) {
        $(".app").hide();
        $(".app").html(data);
        $(".app").fadeIn('slow');
    });

</script>