<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<script type="text/javascript">
    $(".crumb-active").html("<a href='#'>Procedimentos x Laboratórios</a>");
    $(".crumb-icon a span").attr("class", "far fa-th-list");
    $(".crumb-trail").removeClass("hidden");
</script>
<br />


<div class="panel">
        <div class="panel-body">
            <div class="app" style="padding-top: 11px;">
            <i style="text-align: center; margin: 30px;" class="far fa-spin fa-spinner"></i>
            </div>
        </div>
</div>

<script type="text/javascript">

    getUrl("labs-integration/LabsConfig", {}, function(data) {
        $(".app").hide();
        $(".app").html(data);
        $(".app").fadeIn('slow');
    });

</script>