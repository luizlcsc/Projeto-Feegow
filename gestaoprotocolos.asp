<script type="text/javascript">
    $(".crumb-active a").html("Protocolos");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Gerenciamento de Protocolos");
    $(".crumb-icon a span").attr("class", "far fa-th-list");
</script>
<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="far fa-spin fa-spinner"></i>
</div>

<script type="text/javascript">
    getUrl("oncology/protocol/list-view",{}, function(data) {
        $(".app").hide();
        $(".app").html(data);
        $(".app").fadeIn('slow');
    });
</script>