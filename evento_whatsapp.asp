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

</style>

<body>
    <% 
        MensalidadeIndividualSQL = "SELECT sa.MensalidadeIndividual custo, ValorCusto FROM cliniccentral.servicosadicionais sa WHERE sa.id =43;"
        SET MensalidadeIndividual = db.execute(MensalidadeIndividualSQL)

        if  MensalidadeIndividual.eof then
            %>
            Recurso não habilitado
            <%
            Response.End
        end if
        custoMSG  = MensalidadeIndividual("ValorCusto")
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

        <div class="panel">
            <div class="panel-body mt20">
                <table id="table-" class="table table-striped table-bordered table-hover">
                    <thead>
                        <tr class="info">
                            <th class=" hidden-xs ">Tipo</th>

                            <th class=" hidden-xs">Descrição</th>
                            
                            <th class=" hidden-xs ">Visualizar</th>

                            <th class=" hidden-xs ">Ativo</th>
                                
                            <th width="1%" class="hidden-print"></th>
                        </tr>
                    </thead>
        
                    <tbody>
                        <% 
                            modeloDeMensagemSQL =   " SELECT                                                              "&chr(13)&_
                                                    " se.id sysID, se.AtivoWhatsApp, se.sysActive,                        "&chr(13)&_
                                                    " w.id whatsappID,  w.Nome, w.Descricao, w.Conteudo, w.ExemploResposta"&chr(13)&_
                                                    " FROM cliniccentral.eventos_whatsapp w                               "&chr(13)&_
                                                    " LEFT JOIN sys_smsemail se ON se.Descricao = w.Nome                  "
                            SET modeloDeMensagem = db.execute(modeloDeMensagemSQL)

                            i = 1
                            while not modeloDeMensagem.eof

                                sysID = modeloDeMensagem("sysID")&""
                                tipo = modeloDeMensagem("Nome")

                                if sysID = "" then

                                    AddModeloNoSysSQL = "INSERT INTO `sys_smsemail` (`Descricao`, `sysActive`) VALUES ('"&tipo&"', 0)"
                                    db.execute(AddModeloNoSysSQL) %>
                                    
                                    <script type="text/javascript">document.location.reload(true);</script> <%

                                end if
                                descricao = modeloDeMensagem("descricao")
                                modelo = modeloDeMensagem("Conteudo")
                                resposta = modeloDeMensagem("ExemploResposta")
                                ativoWhatsApp = modeloDeMensagem("AtivoWhatsApp")

                                checked = ""
                                if ativoWhatsApp = "on" then
                                    checked = "checked"
                                end if
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

                                    <td class=" hidden-xs ">
                                        <div class="switch switch-info switch-inline">
                                            <input name="ativoCheckbox-<%=i%>" id="ativoCheckbox-<%=i%>" type="checkbox" onchange="activeModel(this, <%=sysID%>)" value="<%=ativoWhatsApp%>" <%=checked%> />
                                            <label class="mn" for="ativoCheckbox-<%=i%>"></label>
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
                    <h2 class="modal-title mt20 text-center" id="modalWhatsappLongTitle">Modelo de mensagem disparada</h2>
                </div>
                <div class="modal-body">
                    <div id="waImagem">
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

        $( document ).ready(() => {
            const statusServicos = document.querySelectorAll("[id^=ativoCheckbox-]");
            const servicosArray = [].map.call(statusServicos, elem => elem.value);

            for(let i=0; i<servicosArray.length; i++) {
                if(servicosArray[i] == 1) {
                    $("input[type=checkbox]").prop("checked", true);
                }
            }
        });

        function showModal(elem, answerType) {

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
            }, 3000);

            elem.preventDefault();
        }

        function removeModalContent() {
            $('#insertModel').remove();
            $('#insertAnswer').remove();
        }

        function activeModel(elem, sysID) {

            const boolean = elem.checked;
            const wppActive = boolean===true ? "on" : "";

            $.post("updateWhatsappActive.asp", 
                {
                    wppActive:wppActive,
                    wppID: sysID
                }, function(data){
                $("#updateActive").html(data);
            });

            setTimeout(()=>{boolean === true?showMessageDialog("Ativado", "success"):showMessageDialog("Desativado", "warning");},10)

        }

            
    </script>
</body>

<!--#include file="disconnect.asp"-->