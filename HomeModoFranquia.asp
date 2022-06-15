<!--#include file="connect.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Bem-vindo ao Feegow Clinic");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("resumo da semana");
    $(".crumb-icon a span").attr("class", "far fa-dashboard");
    $("#modal-descontos-pendentes").css("z-index", 9999999999999999999999999);
</script>
<div style="margin-top: 10px">
<%server.Execute("modulos/marketing/RenderBanner.asp")%>
<div class="panel panel-tile text-center br-a br-light" >

      <div class="panel-body bg-primary light" style="padding: 50px; height: 100vh">
        <img src="https://cdn.feegow.com/feegowclinic-v7/assets/img/logo_white.png" />
        <br/>
        <h1>Seja Bem-vindo</h1>
        <h2>Software para clínicas médicas e consultórios </h2>
        <script src="https://unpkg.com/@lottiefiles/lottie-player@latest/dist/lottie-player.js"></script>
        <div  style="margin:0 auto">
            <lottie-player src="https://assets5.lottiefiles.com/packages/lf20_F4JpWs.json"  background="transparent"  speed="1"  style="width: 70%;  margin: 0 auto"  loop  autoplay></lottie-player>
        </div>
      </div>
    </div>
</div>

<div class="modais-new-prioridades modal-v8">
    <div id="modais-new-prioridades-modal" class="modal fade " tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content" style="margin: 0; padding: 0">
                <div class="modal-body" style="margin: 0; padding: 0">

                </div>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div>
</div>
<style>
.modal-v8 .modal-backdrop{
    background-color: transparent;
    background-image: linear-gradient(52deg, #00b4fc47, #17df9359, #00b4fc8f, #17df9382)
}

.modal-v8 .box-shadow{
    box-shadow: none;
}
</style>


<script>

function isJson(item) {
    item = typeof item !== "string"
        ? JSON.stringify(item)
        : item;

    try {
        item = JSON.parse(item);
    } catch (e) {
        return false;
    }

    if (typeof item === "object" && item !== null) {
        return true;
    }

    return false;
}


if("false"!=="<%=session("AutenticadoPHP")%>"){
    authenticate("-<%= session("User") * (9878 + Day(now())) %>Z", "-<%= replace(session("Banco"), "clinic", "") * (9878 + Day(now())) %>Z",  "<%=session("Partner")%>", "");
}

function getNews(onlyUnread) {

    if(onlyUnread === 1){
        getUrl("/news/get-news", {
            offset: 0,
            limit: 10,
            new_to_show: 1,
            ativo_hoje: 1
        }, function(data) {
            if(data === "false"){
                return;
            }
            if(data === "true"){
                openComponentsModal("/news", false, false, false, false, "lg");
            }
            if(!isJson(data)){
                return;
            }

            let j = data;
            if(j && j.length > 0 && j[0].Prioridade === 3)
            {
                $("#modais-new-prioridades-modal .modal-body").html(j[0].Conteudo);
                $("#modais-new-prioridades-modal").modal();
            }
        })
    }else{
        openComponentsModal("/news", false, false, false, false, "lg");
    }
}
<%
if session("Status")="C" then
%>
$(document).ready(function() {
  if (!ModalOpened){
      getNews(1);
  }
});
<%
end if
%>
</script>