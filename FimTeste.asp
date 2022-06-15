<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<%
    response.write(session("DiasTeste"))
    IF req("Action") = "ToFree" THEN
        dbc.execute("UPDATE cliniccentral.licencas SET FimTeste=FimTeste+ INTERVAL 1 YEAR,Status = 'F' WHERE id = "&replace(session("Banco"), "clinic", "")&" AND Status='T'")
        session("Status")       = "F"
        session("Bloqueado")    = ""
        session("DiasTeste")    = FALSE
        response.write("{data:true}")
        response.end
    END IF
%>

<style>
.modal-v8 .modal-backdrop{
    background-color: transparent;
    background-image: linear-gradient(52deg, #00b4fc47, #17df9359, #00b4fc8f, #17df9382)
}

.modal-v8 .box-shadow{
    box-shadow: none;
}
.container-modal-fim-trial{
    z-index: 10;
    width: 100%;
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
}
.modal-fim-trial{
    font-family: 'Open Sans', sans-serif;
    background: #fff;
    border-radius: 25px;
    padding: 65px;
    box-shadow:
    0 2.8px 2.2px rgba(0, 0, 0, 0.005)),
    0 6.7px 5.3px rgba(0, 0, 0, 0.005)),
    0 12.5px 10px rgba(0, 0, 0, 0.005)),
    0 22.3px 17.9px rgba(0, 0, 0, 0.005)),
    0 41.8px 33.4px rgba(0, 0, 0, 0.005),
    0 100px 80px rgba(0, 0, 0, 0.09);
    }
    .modal-fim-trial p{
    font-size: 17px;
    max-width: 450px;
    color:#4d4d4d;
    }
    .modal-fim-trial p span{
    color: #052b3b;
    display: block;
    font-weight: 700;
    font-size: 1.2em;
    }
    .modal-fim-trial .logo{
    width:170px; 
    }
    .titulo-modal{
    padding-top: 45px;
    padding-bottom: 16px;
    display: grid;
    grid-template-columns: 1fr 8fr;
    column-gap: 20px;
    }
    .imagem-titulo-modal img{
    width: 70px;
    }
    .texto-titulo-modal h3{
    padding: 0;
    margin: 0;
    font-size: 32px;
    line-height: 1em;
    }
    .texto-titulo-modal h3 span{
    color: #009af0;
    }
    .container-texto-modal{
    padding-bottom: 20px;
    }
    #cta-usar-free{
    border: none;
    padding: 20px 0px;
    margin-right: 10px;
    border-radius: 12px;
    width: 100%;
    background-color:#01e66a;
    color: #fff;
    font-size: 19px;
    cursor:pointer;
    transition: all 0.2s;
    }
    #cta-usar-free:hover{
    transform: scale(1.05);
    }
    #cta-contratar-plano{
    border: none;
    width: 100%;
    padding: 20px 0px;
    border-radius: 12px;
    background-color:#009af0;
    color: #fff;
    font-size: 19px;
    cursor:pointer;
    transition: all 0.2s;
    }
    #cta-contratar-plano:hover{
    transform: scale(1.05);
    }
    @media only screen and (max-width: 600px) {
    .modal-fim-trial{padding: 50px 30px 20px ;max-width: 300px;}
    .modal-fim-trial .logo {width: 140px;}
    .titulo-modal {padding-top: 24px;column-gap: 5px;}
    .imagem-titulo-modal img {width: 60px;}
    .texto-titulo-modal h3 {font-size: 22px;}
    .container-texto-modal {padding-bottom: 20px;}
    .modal-fim-trial p {font-size: 15px;margin: 0;}
    #cta-usar-free, #cta-contratar-plano {font-size: 15px;width: 220px;padding: 18px;margin-bottom: 14px;}


    }
</style>

<div class="modais-recursosxxx modal-v8 hidden" >
    <div id="modal-fimtestexxx" class="modal fade" tabindex="-1">
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

<div id="modal-fimteste" class="modal fade modal-v8" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content" id="modal-fimtestecontent">
            <div class="container-modal-fim-trial">
                <div class="modal-fim-trial">
                    <img src="assets/img/login_logo.svg" alt="" class="logo">
                    <div class="titulo-modal">
                        <div class="imagem-titulo-modal">
                        <img src="https://www.feegowclinic.com.br/wp-content/uploads/2022/06/icone-relogio.png" alt="">
                        </div>
                        <div class="texto-titulo-modal">
                        <h3>Seu período de teste grátis <span>chegou ao fim</span>!</h3>
                        </div>
                    </div>
                    <div class="container-texto-modal">
                        <p>
                        <span>Mas não precisa ficar triste!</span>
                        Você pode contratar um de nossos planos e seguir utilizando os melhores recursos do nosso sistema!
                        </p>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6">
                            <button type="button" id="cta-usar-free" onclick="changeToFree()">Usar a versão Free</button>
                        </div>
                        <div class="col-md-6">
                            <button  id="cta-contratar-plano">Contratar um plano</button>
                                <br/>
                            <div style="text-align: center; color: #000000"><i class="far fa-phone"></i> 0800 591 3035</div>
                        </div>
                    </div>
                </div>
            </div>
            </div>
        </div>
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