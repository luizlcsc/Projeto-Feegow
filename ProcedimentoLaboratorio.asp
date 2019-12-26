<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="fa fa-spin fa-spinner"></i>
</div>

<script type="text/javascript">

    getUrl("labs-integration/LabsConfig", {}, function(data) {
        $(".app").hide();
        $(".app").html(data);
        $(".app").fadeIn('slow');
    });

</script>