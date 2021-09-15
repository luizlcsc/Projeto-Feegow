<!--#include file="connect.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Marketplace");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Criar conta");
    $(".crumb-icon a span").attr("class", "far fa-th");
</script>
<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="far fa-spin fa-spinner"></i>
</div>

<script type="text/javascript">
    $(document).ready(function() {
      openComponentsModal("emissaoboleto/account-setup/view", {}, "Cadastro de conta", true, false);
    })
</script>