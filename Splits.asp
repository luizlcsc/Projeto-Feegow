<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Splits");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Realizar/realizados");
    $(".crumb-icon a span").attr("class", "far fa-th");
</script>
<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="far fa-spin fa-spinner"></i>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/vue/2.5.16/vue.min.js"></script>
<script type="text/javascript">
    var accountId = "<%=req("accountId")%>";
    var associationId = "<%=req("associationId")%>";
    getUrl("splits/list", {associationId: associationId, idInTable: accountId}, function(data) {
        $(".app").hide();
        $(".app").html(data);
        $(".app").fadeIn('slow');
    });
</script>