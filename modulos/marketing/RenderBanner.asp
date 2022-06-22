<!--#include file="./../../connect.asp"-->
<!--#include file="./../../Classes/Environment.asp"-->
<%
if session("Admin")=1 then
sql = "SELECT * FROM cliniccentral.popup_comunicados WHERE false AND TipoComunicado='banner' AND JSON_CONTAINS(Versao,'"""&session("PastaAplicacaoRedirect")&"""', '$') and sysActive=1"
GTM_ID = getEnv("FC_GTM_ID", "")

set BannerHomeSQL = db.execute(sql)
if not BannerHomeSQL.eof then
    %>
    <div onclick="callToActionBanner('<%=BannerHomeSQL("EndpointModal")%>', '<%=BannerHomeSQL("LinkCallToAction")%>', '<%=BannerHomeSQL("NomeComunicado")%>', '<%=BannerHomeSQL("id")%>')" class="panel panel-tile text-center br-a br-light mt10" style="border-radius: 18px; cursor: pointer; min-height: 307px;background-color: #ddddddbf;">
        <div>
            <img style="width: 100% ; object-fit: cover" src="<%=BannerHomeSQL("LinkImagem")%>" alt="<%=BannerHomeSQL("NomeComunicado")%>">
        </div>
    </div>
    <%
else
    %>
    <div id="banner-home" class="image-placeholder" class="panel panel-tile text-center br-a br-light mt10" style="border-radius: 18px; cursor: pointer; min-height: 310px;background-color: #ddddddbf;margin-bottom: 15px;margin-top: 15px;">

    </div>
    <%
end if
%>

<% if GTM_ID <> "" then %>
    <!-- Google Tag Manager -->
    <script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
    new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
    j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
    'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
    })(window,document,'script','dataLayer','<%=GTM_ID%>');</script>
    <!-- End Google Tag Manager -->
<% end if %>


<script >
var endpointModalRef;
var endpointRedirectRef;
var comunicadoIdRef;

function redirectUser(url, comunicadoId){

    $.get("./react/popup-comunicados/api/popup-api.asp", {
        action: "PopupVisualizado",
        Interesse: "1",
        ComunicadoID: comunicadoId
    });
    location.href = url;
}

function callToActionBanner(endpointModal, endpointRedirect, screenTitle, comunicadoId){
    endpointModalRef=endpointModal;
    endpointRedirectRef=endpointRedirect;
    comunicadoIdRef=comunicadoId;

    if(endpointModal){
        openComponentsModal(endpointModal, {}, screenTitle, true, function(data){
            $.post(endpointModalRef+"&Save=1", $("#form-components").serialize(), function (data){
                redirectUser(endpointRedirectRef, comunicadoIdRef);
            });
        });
    }else{

        redirectUser(endpointRedirectRef, comunicadoIdRef);
    }
}
</script>
<%
end if
%>