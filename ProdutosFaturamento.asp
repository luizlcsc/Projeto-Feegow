<!--#include file="connect.asp"-->

<div class="app"></div>

<script type="text/javascript">
    $(".app").html('<i style="text-align: center; margin: 30px;" class="far fa-spin fa-spinner"></i>');
    getUrl("estoque/produtos/<%=req("I")%>/faturamento-valores", {}, function(data) {
        $(".app").hide();
        $(".app").html(data);
        $(".app").fadeIn('slow');
    });
</script>