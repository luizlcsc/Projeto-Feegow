<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Integracao Memed");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Cadastro Memed");
    $(".crumb-icon a span").attr("class", "far fa-th");
</script>
<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="far fa-spin fa-spinner"></i>
</div>


<script type="text/javascript">
var professionalId = "<%=req("I")%>";
    getUrl("prescription/memed/professional-index", {professionalId: professionalId}, function(data) {
    $(".app").hide();
    $(".app").html(data);
    $(".app").fadeIn('slow');
    });

</script>