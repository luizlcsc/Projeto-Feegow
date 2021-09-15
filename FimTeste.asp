<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<%
    response.write(session("DiasTeste"))
    IF req("Action") = "ToFree" THEN
        dbc.execute("UPDATE cliniccentral.licencas SET FimTeste=FimTeste+ INTERVAL 1 YEAR,Status = 'F' WHERE id = "&replace(session("Banco"), "clinic", ""))
        session("Status")       = "F"
        session("Bloqueado")    = ""
        session("DiasTeste")    = FALSE
        response.write("{data:true}")
        response.end
    END IF
%>


<div class="modais-recursos">
    <div id="modal-fimteste" class="modal fade" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content" id="modal-fimtestecontent" style="width:680px; margin-left:-130px;">
                <div class="modal-body text-center">
                    <div class="contain">
                        <div class="item" style="width: 300px; background: #008bd0;">
                            <div style="position: absolute;z-index: 100000"><img src="assets/fim-teste/corner_alert.png"></div>
                            <img style="margin-top: 60px" src="assets/fim-teste/icone-relogio.png">
                        </div>
                        <div class="item" style="flex: auto; padding: 25px 30px">
                            <div class="contain">
                                <div class="item recurso-indisponivel" style="line-height: 40px;margin-left: 0px">
                                    Seu período <br/> de teste grátis<br/>chegou ao fim :(
                                </div>
                            </div>
                            <div class="text-indisponivel" style="max-width: 315px; line-height: 20px">
                                <p><strong>Mas não precisa ficar triste!</strong>
                                <br/>Você pode contratar um de nossos planos e seguir utilizando os melhores recursos de nosso software!</p>
                                <br/>
                                <button class="btn btn-success" style="width: 48%;background-color: #00cc86; height: 58px;border-radius: 10px;" onclick="changeToFree()" type="button">
                                    Usar a versão Free
                                </button>
                                <div class="btn btn-success" style="width: 48%;background-color: #00bad7;border-radius: 10px;cursor: default" type="button">
                                    Contratar Um Plano <br/>
                                    <span style="color: #000000"><i class="far fa-phone"></i> 0800 591 3035</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div>
</div>


<script>

function changeToFree(){
    fetch("FimTeste.asp?Action=ToFree").then((data) => {
            window.location.reload()
    });
}

$(document).ready(function(e) {
<%
if session("Bloqueado")="FimTeste" then
%>
    setTimeout(function(){
		$("#modal-fimteste").modal({
		backdrop: 'static',
		keyboard: false
		});
	}, 2200);
<%
end if
if req("Contratar")="1" then
%>
    setTimeout(function(){
		$("#modal-fimteste").modal('show');
	}, 2200);
<%
end if
%>
});

$("#contratar").click(function(){
	$.post("Contratar.asp", "", function(data, status){ $("#modal-fimtestecontent .modal-body").html(data) });
});
<%
set vcaCont = dbc.execute("select id from cliniccentral.contratar where LicencaID="&replace(session("banco"), "clinic", "")&" order by id desc")
if not vcaCont.eof then
	%>
		$.get("Contratado.asp", function(data, status){ $("#modal-fimtestecontent .modal-body").html(data) });
	<%
end if
%>

</script>