<!--#include file="connect.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Atualizar Tabelas do Faturamento");
</script>
<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="far fa-spin fa-spinner"></i>
</div>

<script type="text/javascript">
    getUrl("estoque/produtos/atualizar-tabelas-view",{}, function(data) {
        $(".app").hide();
        $(".app").html(data);
        $(".app").fadeIn('slow');
    });
</script>