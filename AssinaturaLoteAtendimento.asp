<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Certificado digital");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Assinatura digital");
    $(".crumb-icon a span").attr("class", "fa fa-th");
</script>

<script type="text/javascript" src="https://get.webpkiplugin.com/Scripts/LacunaWebPKI/lacuna-web-pki-2.12.0.min.js"
                integrity="sha256-jDF8LDaAvViVZ7JJAdzDVGgY2BhjOUQ9py+av84PVFA="
                crossorigin="anonymous"></script>

<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="fa fa-spin fa-spinner"></i>
</div>

<script type="text/javascript">
var PacienteId = null;

    getUrl("/digital-certification/assinar-lote",{PacienteId: PacienteId} ,function(data) {
        $(".app").hide();
        $(".app").html(data);
        $(".app").fadeIn('slow');

    });

</script>