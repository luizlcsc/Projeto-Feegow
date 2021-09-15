<script type="text/javascript">
    $(".crumb-active a").html("Programas de Saúde");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Listagem de Programas");
    $(".crumb-icon a span").attr("class", "far fa-th");
    $(".topbar-right").html('<button type="button" class="btn btn-sm btn-success btn-inserir-programa"><i class="far fa-plus"></i> INSERIR</button>');
</script>
<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="far fa-spin fa-spinner"></i>
</div>

<script type="text/javascript">
    getUrl("health-programs/list-view",{}, function(data) {
        $(".app").hide();
        $(".app").html(data);
        $(".app").fadeIn('slow');
    });
</script>