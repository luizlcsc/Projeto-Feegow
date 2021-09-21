<!--#include file="connect.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Locais");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Locais Externos");
    $(".crumb-icon a span").attr("class", "fa fa-map-marker");
</script>

<div class="panel">
        <div class="panel-heading">
            <span class="panel-title"> Locais Externos</span>
            <span class="panel-controls">
               <div id="btnacao"> <button class="btn btn-sm btn-success" onclick="incluirLocalExterno();"><i class="fa fa-plus"></i> INSERIR</button></div>
            </span>
        </div>
        <div class="panel-body">
            <div class="app" style="padding-top: 11px; ">
            <i style="text-align: center; margin: 30px;" class="fa fa-spin fa-spinner"></i>
            </div>
        </div>
</div>

<script type="text/javascript">

    getUrl("locais/lista", {}, function(data) {
        $(".app").hide();
        $(".app").html(data);
        $(".app").fadeIn('slow');
    });

</script>