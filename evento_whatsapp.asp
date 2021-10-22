<!--#include file="connect.asp"-->

<style>
    #waImagem {
    position: relative;
    left:110px;
  }
  #waConteudo {
    display: flex;
    flex-flow: row wrap;
    flex-direction: column;
    justify-content: space-between; 
    position: absolute;
    top:200px;
    left:86px;
  }
  .waRemetente {
    padding: 0.2rem;
    margin-bottom: 16px;

    word-wrap: break-word;

    background: #DCF8C6;
    border-radius: 4.8px;
  }

  
  .waDestinatario {
    position: relative;
    left: -36px;
    
    padding: 0.2rem;

    word-wrap: break-word;
    
    background: #FFFFFF;
    border-radius: 4.8px;
  }
  
  .waRemetente::after{
    content: "";
    width: 0;
    height: 0;
    position: absolute;
    border-left: 14px solid transparent;
    border-right: 14px solid transparent;
    border-bottom: 20px solid #DCF8C6;
    top: -4.28px;
    right: -6.4%;
    transform: rotate(54deg);
  }

  .waDestinatario::before{
    content: "";
    width: 0;
    height: 0;
    position: absolute;
    border-left: 14px solid transparent;
    border-right: 14px solid transparent;
    border-bottom: 20px solid rgb(255, 255, 255);
    top: -3.94px;
    left: -6.4%;
    transform: rotate(-54deg);
  }

  .fontCentered{
    margin-left: 12px;
    width: 180px;

    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
    font-size: 11px;
    line-height: 13px;
    color: #000000;
  }

  .border {
    border: 0.564453px solid #E6E6E6;
  }

  .noselect {
    -webkit-touch-callout: none;
    -webkit-user-select: none;
    -khtml-user-select: none;
    -moz-user-select: none;
    -ms-user-select: none;
    user-select: none;
    }   

</style>

<body>
    <% 
        MensalidadeIndividualSQL = "SELECT sa.MensalidadeIndividual custo, ValorUnitario FROM cliniccentral.servicosadicionais sa WHERE sa.id =43;"
        SET MensalidadeIndividual = db.execute(MensalidadeIndividualSQL)

        if  MensalidadeIndividual.eof then
            %>
            Recurso não habilitado
            <%
            Response.End
        end if
        custoMSG  = MensalidadeIndividual("ValorUnitario")
        custoMSG = formatNumber(custoMSG, 2)
        MensalidadeIndividual.close
        SET MensalidadeIndividual  = nothing

    %>

    <div class="container-fluid">

        <div class="panel mt20">
            <div class="panel-heading">
                Custo por mensagem enviada <span class="badge badge-pink">R$ <%=custoMSG%></span>
            </div>
        </div>

        <div class="panel" id="conteudoWhatsapp">
            <div class="panel-body mt20">
                <table id="table-" class="table table-striped table-bordered table-hover">
                    <thead>
                        <tr class="info">
                            <th class=" hidden-xs ">Tipo</th>

                            <th class=" hidden-xs">Descrição</th>
                            
                            <th class=" hidden-xs ">Visualizar</th>

                            <th width="1%" class="hidden-print">Editar</th>
                        </tr>
                    </thead>
        
                    <tbody>
                        <% 
                            modeloDeMensagemSQL =   " SELECT                                                                        "&chr(13)&_
                                                    " eveW.id ModeloID, eveW.Nome, eveW.Descricao, eveW.Conteudo, eve.`Status`,     "&chr(13)&_
                                                    " eveW.ExemploResposta, eve.id 'EventoID', eve.AntesDepois, eve.IntervaloHoras, "&chr(13)&_
                                                    " eve.Unidades, eve.Especialidades, eve.ApenasAgendamentoOnline, eve.EnviarPara,"&chr(13)&_
                                                    " eve.Procedimentos, eve.Profissionais, eve.Ativo, eve.sysActive                "&chr(13)&_
                                                    " FROM cliniccentral.eventos_whatsapp eveW                                      "&chr(13)&_
                                                    " LEFT JOIN eventos_emailsms eve ON eve.Descricao = eveW.Nome                   "
                            SET modeloDeMensagem = db.execute(modeloDeMensagemSQL)

                            i = 1
                            while not modeloDeMensagem.eof
                                eveID = modeloDeMensagem("EventoID")&""
                                tipo = modeloDeMensagem("Nome")

                                if eveID = "" then

                                    AddModeloNoEveSQL = "INSERT INTO `eventos_emailsms` (`Descricao`, `sysActive`) VALUES ('"&tipo&"', 0)"
                                    db.execute(AddModeloNoEveSQL) %>
                                    
                                    <script type="text/javascript">document.location.reload(true);</script> <%

                                end if
                                descricao = modeloDeMensagem("Descricao")
                                modelo = modeloDeMensagem("Conteudo")
                                resposta = modeloDeMensagem("ExemploResposta")
                                ativoWhatsApp = modeloDeMensagem("Ativo")
                                sysActive = modeloDeMensagem("sysActive")
                                statusAgenda = modeloDeMensagem("Status")
                                intervaloHoras = modeloDeMensagem("IntervaloHoras")
                                antesDepois = modeloDeMensagem("AntesDepois")
                                paraApenas = modeloDeMensagem("ApenasAgendamentoOnline")
                                profissionais = modeloDeMensagem("Profissionais")
                                especialidades = modeloDeMensagem("Especialidades")
                                procedimentos = modeloDeMensagem("Procedimentos")
                                enviarPara = modeloDeMensagem("EnviarPara")
                            %>
                                <tr>

                                    <td class="hidden-xs">
                                        <a id="tipo-<%=i%>" href="#"><%=tipo%></a>
                                    </td>

                                    <td class="hidden-xs">
                                        <p class="text-truncate"><%=descricao%></p>
                                    </td>

                                    <td class=" hidden-xs ">
                                        <button class="btn btn-xs btn-default btn-block" id="mostrar-<%=i%>" onclick="showModal(this, '<%=resposta%>')" data-toggle="modal" data-target="#modalWhatsapp" value="<%=modelo%>"><i class="fa fa-mobile-phone" style="font-size:24px"></i></button>
                                    </td>

                                    <td width="1%" nowrap="nowrap" class="hidden-print">
                                        <div class="action-buttons">
                                            <a href="#" class="btn btn-xs btn-info tooltip-info" onclick="configWhatsapp(this, <%=eveID%>)" data-rel="tooltip" data-original-title="Editar">
                                                <i class="far fa-edit bigger-130"></i>
                                                <input name="statusAgenda" id="statusAgenda-<%=i%>" type="hidden" value="<%=statusAgenda%>"/>
                                                <input name="intervalo" id="intervalo-<%=i%>" type="hidden" value="<%=intervaloHoras%>"/>
                                                <input name="antesDepois" id="antesDepois-<%=i%>" type="hidden" value="<%=antesDepois%>" />
                                                <input name="paraApenas" id="paraApenas-<%=i%>" type="hidden" value="<%=paraApenas%>" />
                                                <input name="ativoCheckbox" id="ativoCheckbox-<%=i%>" type="hidden" value="<%=ativoWhatsApp%>"/>
                                                <input name="profissionais" id="profissionais-<%=i%>" type="hidden" value="<%=profissionais%>"/>
                                                <input name="unidades" id="unidades-<%=i%>" type="hidden" value="<%=unidades%>"/>
                                                <input name="especialidades" id="especialidades-<%=i%>" type="hidden" value="<%=especialidades%>">
                                                <input name="procedimentos" id="procedimentos-<%=i%>" type="hidden" value="<%=procedimentos%>"/>
                                                <input name="enviarPara" id="enviarPara-<%=i%>" type="hidden" value="<%=enviarPara%>"/>
                                            </a>
                                        </div>
                
                                    </td>
                                </tr>

                            <%
                            i = i+1
                            modeloDeMensagem.movenext
                            wend
                            modeloDeMensagem.close
                            set modeloDeMensagem = nothing
                        %>
                    </tbody>
                </table>

            </div>

        </div>
    </div>

    <!-- Modal -->
    <div class="modal fade" id="modalWhatsapp" tabindex="-1" role="dialog" aria-labelledby="modalWhatsappTitle" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close btn btn-secondary" onclick="removeModalContent()" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                    <h2 class="modal-title mt20 text-center noselect" id="modalWhatsappLongTitle">Modelo de mensagem disparada</h2>
                </div>
                <div class="modal-body">
                    <div class="noselect" id="waImagem">
                        <img src="./eventos-whatsapp-images/demo-iphonex.png" alt="whatsapp-events">
                        <div id="waConteudo">                     
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" onclick="removeModalContent()" class="btn btn-secondary" data-dismiss="modal">Fechar</button>
                </div>
            </div>
        </div>
    </div>

    <script>

        function configWhatsapp(elem, eventoWhatsappID) {

            const statusAgenda   = $(elem).children("[name=statusAgenda]").val();
            const intervalo      = $(elem).children("[name=intervalo]").val();
            const antesDepois    = $(elem).children("[name=antesDepois]").val();
            const paraApenas     = $(elem).children("[name=paraApenas]").val();
            const ativoCheckbox  = $(elem).children("[name=ativoCheckbox]").val();
            const profissionais  = $(elem).children("[name=profissionais]").val();
            const unidades       = $(elem).children("[name=unidades]").val();
            const especialidades = $(elem).children("[name=especialidades]").val();
            const procedimentos  = $(elem).children("[name=procedimentos]").val();
            const enviarPara     = $(elem).children("[name=enviarPara]").val();

            $("#conteudoWhatsapp").html("Carregando...");

            $.post("configWhatsapp.asp", 
                {
                    statusAgenda:statusAgenda,
                    intervalo:intervalo,
                    antesDepois:antesDepois,
                    paraApenas:paraApenas,
                    ativoCheckbox:ativoCheckbox,
                    profissionais:profissionais,
                    unidades:unidades,
                    especialidades:especialidades,
                    procedimentos:procedimentos,
                    enviarPara:enviarPara,
                    wppID: eventoWhatsappID
                }, 
                function(data){
                $("#conteudoWhatsapp").html(data);
            })
            
        }

        $(".crumb-active a").html("Configurar Eventos");
        $(".crumb-icon a span").attr("class", "far fa-");
        $(".topbar-right").html('<a class="btn btn-sm btn-success" href="?P=configWhatsapp&Pers=1"><i class="far fa-plus"></i> INSERIR</a>');
    
        function showModal(elem, answerType) {

            removeModalContent();

            setTimeout(() => {
                $('#waConteudo').append(`<div id="insertModel" class="waRemetente border">
                                            <p class="fontCentered">
                                                ${elem.value}
                                            </p>
                                        </div> `);
            }, 1000);

            setTimeout(() => {
                $('#waConteudo').append(`<div id="insertAnswer" class="waDestinatario border">
                                            <p class="fontCentered">
                                                ${answerType}
                                            </p>
                                        </div>`);
            }, 2000);

        }

        function removeModalContent() {
            $('#insertModel').remove();
            $('#insertAnswer').remove();
        }

            
    </script>
</body>

<!--#include file="disconnect.asp"-->