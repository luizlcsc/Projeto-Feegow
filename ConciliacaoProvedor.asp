<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Conciliacao");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Faturas de provedor");
    $(".crumb-icon a span").attr("class", "far fa-th");
</script>
<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="far fa-spin fa-spinner"></i>
</div>

<script type="text/javascript">

    getUrl("conciliacao-provedor/index", {}, function(data) {
    $(".app").hide();
    $(".app").html(data);
    $(".app").fadeIn('slow');
    });

</script>