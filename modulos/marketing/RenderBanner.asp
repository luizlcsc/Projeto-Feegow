<!--#include file="./../../connect.asp"-->
<%
if session("Admin")=1 then
sql = "SELECT * FROM cliniccentral.popup_comunicados WHERE JSON_CONTAINS(Versao,'"""&session("PastaAplicacaoRedirect")&"""', '$') and sysActive=1"

set BannerHomeSQL = db.execute(sql)
if not BannerHomeSQL.eof then
    %>
    <div onclick="callToActionBanner('<%=BannerHomeSQL("EndpointModal")%>', '<%=BannerHomeSQL("LinkCallToAction")%>', '<%=BannerHomeSQL("NomeComunicado")%>')" class="panel panel-tile text-center br-a br-light" style="border-radius: 18px; cursor: pointer">
        <div>
            <img style="width: 100% ; object-fit: cover" src="<%=BannerHomeSQL("LinkImagem")%>" alt="<%=BannerHomeSQL("NomeComunicado")%>">
        </div>
    </div>
    <%
end if
%>
<script >
var endpointModalRef;
var endpointRedirectRef;

function callToActionBanner(endpointModal, endpointRedirect, screenTitle){
    endpointModalRef=endpointModal;
    endpointRedirectRef=endpointRedirect;

    if(endpointModal){
        openComponentsModal(endpointModal, {}, screenTitle, true, function(data){
            $.post(endpointModalRef+"&Save=1", $("#form-components").serialize(), function (data){
                location.href = endpointRedirectRef;
            });
        });
    }else{
        location.href = endpointRedirect;
    }
}
</script>
<%
end if
%>