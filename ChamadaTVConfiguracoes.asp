<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="far fa-spin fa-spinner"></i>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/vue/2.5.16/vue.min.js"></script>

<script type="text/javascript">

    <% 
    versao = "settings"
    licencaID = replace(session("Banco"),"clinic","")
    validaVersaoSQL = "SELECT ctvt.versao FROM cliniccentral.chamadas_tv ctv LEFT JOIN cliniccentral.chamadas_tv_templates ctvt ON ctvt.id=ctv.TemplateID WHERE ctv.LicencaID="&licencaID

    set validaVersao = db.execute(validaVersaoSQL)
    if not validaVersao.eof then 
        if validaVersao("versao") = 2 then
            versao = "settingsV2"
        end if
    end if
    %>

    getUrl("tvcall/<%=versao%>", {}, function(data) {
        $(".app").hide();
        $(".app").html(data);
        $(".app").fadeIn('slow');
    });

</script>

