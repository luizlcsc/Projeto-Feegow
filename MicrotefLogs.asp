<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Transações TEF");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Logs de transações realizadas pelo TEF");
    $(".crumb-icon a span").attr("class", "fa fa-th");
</script>
<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="fa fa-spin fa-spinner"></i>
</div>

<script src="https://s3.amazonaws.com/cappta.api/v2/dist/cappta-checkout.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script type="text/javascript">
    getUrl("microtef/list-index", {}, function(data) {
        $(".app").hide();
        $(".app").html(data);
        $(".app").fadeIn('slow');
    });

</script>