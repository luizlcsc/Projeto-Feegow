<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Nota Fiscal");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Emissão em lote");
    $(".crumb-icon a span").attr("class", "far fa-file-text");
</script>
<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="far fa-spin fa-spinner"></i>
</div>

<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script type="text/javascript">
    getUrl("electronicinvoice/bills-receive", {}, function(data) {
        $(".app").hide();
        $(".app").html(data);
        $(".app").fadeIn('slow');
    });

</script>