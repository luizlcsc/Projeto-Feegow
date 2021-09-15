<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Administrar lote");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Validar XML do lote");
    $(".crumb-icon a span").attr("class", "far fa-file");
</script>
<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="far fa-spin fa-spinner"></i>
</div>
<script src="https://unpkg.com/sweetalert/dist/sweetalert.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/vue/2.5.16/vue.min.js"></script>
<script type="text/javascript">

    getUrl("/tissxml", {}, function(data) {
    $(".app").hide();
    $(".app").html(data);
    $(".app").fadeIn('slow');
    });

</script>