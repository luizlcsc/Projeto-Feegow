<script type="text/javascript" src="https://get.webpkiplugin.com/Scripts/LacunaWebPKI/lacuna-web-pki-2.12.0.js"
                integrity="sha256-jDF8LDaAvViVZ7JJAdzDVGgY2BhjOUQ9py+av84PVFA="
                crossorigin="anonymous"></script>
                
<script type="text/javascript">
    $(".crumb-active a").html("Assinatura digital");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Assinatura digital");
    $(".crumb-icon a span").attr("class", "far fa-user");
    var PacienteId = "<%=req("I")%>";

    getUrl("/digital-certification/assinar-lote",{PacienteId: PacienteId} ,function(data) {
        $(".app").hide();
        $(".app").html(data);
        $(".app").fadeIn('slow');
        // console.log(domain);
    });

    

</script>

<div class="app" style="padding-top: 11px;" id="divAssinatura">
    <i style="text-align: center; margin: 30px;" class="far fa-spin fa-spinner"></i>
</div>

