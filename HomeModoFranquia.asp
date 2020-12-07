<!--#include file="connect.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Bem-vindo ao Feegow Clinic");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("resumo da semana");
    $(".crumb-icon a span").attr("class", "fa fa-dashboard");
    $("#modal-descontos-pendentes").css("z-index", 9999999999999999999999999);
</script>
<div style="margin-top: 10px">
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
<script>
if("false"!=="<%=session("AutenticadoPHP")%>"){
    authenticate("-<%= session("User") * (9878 + Day(now())) %>Z", "-<%= replace(session("Banco"), "clinic", "") * (9878 + Day(now())) %>Z",  "<%=session("Partner")%>", "");
}
</script>