<style>

.modais-recursos .contain {
  display: flex;
  justify-content: flex-start;
  flex-wrap: wrap;
}

.modais-recursos .item {
  box-sizing: border-box;
}
.modais-recursos .modal-body{
    padding: 0px !important;
}

@font-face {
     font-family: rubidBold;
     src: url('assets/recurso-indisponivel/Fonte/Rubik-Bold.ttf');
}
@font-face {
     font-family: rubid;
     src: url('assets/recurso-indisponivel/Fonte/Rubik-Regular.ttf');
}

.modais-recursos  .titulo-carinha{
    font-size: 70px;
    font-family: rubidBold;
    color: #217dbb;
}

.modais-recursos .recurso-indisponivel{
    margin-left: 15px;
    font-size: 38px;
    font-family: rubidBold;
    color: #217dbb;
    line-height: 35px;
    margin-top: 19px;
    text-align: left;
}

.modais-recursos .text-indisponivel{
    margin-top: 20px;
    max-width: 335px;
    text-align: justify;
    line-height: 16px;
    font-size: 14px;
}

.modais-recursos .text-indisponivel{
    font-family: rubid;
}

.modais-recursos .text-indisponivel strong{
    font-family: rubidBold;
}

.modais-recursos .contain .icon-recurso div{
    width: 25%;
    text-align: center;
    margin-top: 20px;
}
</style>
<div class="modais-recursos">
    <div id="modal-recurso-indisponivel" class="modal fade" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content" id="modal-fimtestecontent" style="width:700px; margin-left:-130px;">
                <div class="modal-body text-center">
                    <div class="contain">
                        <div class="item">
                            <img src="assets/recurso-indisponivel/imagem-medico-modal-recursos-bloqueados.png">
                        </div>
                        <div class="item" style="flex: auto;">
                            <div style="position: absolute; right: 0px; padding: 10px" >
                                <a href="javascript:void(0)" data-dismiss="modal" aria-label="Close">
                                    <img src="assets/recurso-indisponivel/close-button.png">
                                </a>
                            </div>
                            <div style="margin: 25px 30px">
                                <div class="contain">
                                    <div class="item titulo-carinha">
                                        :(
                                    </div>
                                    <div class="item recurso-indisponivel">
                                        Recurso <br/> indisponível
                                    </div>
                                </div>
                                <div class="text-indisponivel">
                                    <p>Uma pena, mas este recurso não está acessível nesta versão.</p>
                                    <p>
                                       Quer ter todas as funcionalidades disponíveis a poucos cliques de você? Entre em contato com nosso time e conheça nossos planos para obter
                                       a versão completa!</p>
                                    <a href="https://feegowclinic.com.br/fale-com-a-feegow/" target="_blank" class="btn btn-success" style="width: 100%;background-color: #2e9e83;" type="button">
                                        Quero solicitar a versão completa!
                                    </a>
                                    <div class="contain icon-recurso">
                                        <div>
                                            <img src="assets/recurso-indisponivel/icone-agenda.png">
                                        </div>
                                        <div>
                                            <img src="assets/recurso-indisponivel/icone-financeiro.png">
                                        </div>
                                        <div>
                                        <img src="assets/recurso-indisponivel/icone-faturamento.png">

                                        </div>
                                        <div>
                                            <img src="assets/recurso-indisponivel/icone-prontuario.png">
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div>
</div>