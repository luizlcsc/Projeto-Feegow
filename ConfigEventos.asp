<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->

<script type="text/javascript">
     $(".crumb-active a").html("Configurações de SMS/E-mail");
</script>
<%
if session("admin")=1 then
    if ref("E")="E" then
        db.execute("update configeventos set EnvioAutomaticoEmail='"&ref("EnvioAutomaticoEmail")&"' , EnvioAutomaticoSMS='"&ref("EnvioAutomaticoSMS")&"' ,EnvioAutomaticoWhatsapp='"&ref("EnvioAutomaticoWhatsapp")&"' , AtivarServicoEmail='"&ref("AtivarServicoEmail")&"', AtivarServicoSMS='"&ref("AtivarServicoSMS")&"', AtivarServicoWhatsapp='"&ref("AtivarServicoWhatsapp")&"', ModeloMsgWhatsapp='"&ref("ModeloMsgWhatsapp")&"' WHERE id=1")
        %>
        <script type="text/javascript">
        $(document).ready(function(e) {
            new PNotify({
                title: 'Salvo com sucesso!',
                text: '',
                type: 'success',
                delay: 3000
            });
        });

        </script>
        <%
    end if

    if req("T")= "ExcluirFila" then
        tabela = req("Tipo")
        if tabela = "sms" then
            dbc.execute("DELETE FROM cliniccentral.smsfila where LicencaID="&replace(session("Banco"), "clinic", "")&" AND DataHora>date(now()) ")
             %>
                <script type="text/javascript">
                $(document).ready(function(e) {
                    new PNotify({
                        title: 'SMS apagados com sucesso!',
                        text: '',
                        type: 'success',
                        delay: 3000
                    });
                });

                </script>
                <%
        elseif tabela = "email" then
            dbc.execute("DELETE FROM cliniccentral.emailsfila where LicencaID="&replace(session("Banco"), "clinic", "")&" AND DataHora>date(now()) ")
             %>
                <script type="text/javascript">
                $(document).ready(function(e) {
                    new PNotify({
                        title: 'E-mails apagados com sucesso!',
                        text: '',
                        type: 'success',
                        delay: 3000
                    });
                });

                </script>
             <%
        elseif tabela = "whatsapp" then

        end if

    end if

    MensalidadeIndividualSQL = "SELECT sa.MensalidadeIndividual custo FROM cliniccentral.servicosadicionais sa WHERE sa.id =43;"
    SET MensalidadeIndividual = db.execute(MensalidadeIndividualSQL)
    
    custoMSG  = MensalidadeIndividual("custo")
    custoMSG = formatNumber(custoMSG, 2)
    MensalidadeIndividual.close
    SET MensalidadeIndividual  = nothing

    set reg = db.execute("select * from configeventos where id=1")
    if not reg.EOF then
        EnvioAutomaticoEmail=reg("EnvioAutomaticoEmail")
        EnvioAutomaticoSMS=reg("EnvioAutomaticoSMS")
        EnvioAutomaticoWhatsapp=reg("EnvioAutomaticoWhatsapp")
        AtivarServicoEmail=reg("AtivarServicoEmail")
        AtivarServicoSMS=reg("AtivarServicoSMS")
        AtivarServicoWhatsapp=reg("AtivarServicoWhatsapp")
        ModeloMsgWhatsapp=reg("ModeloMsgWhatsapp")
        %>
        <%
        if recursoAdicional(31)=4 then
            LabelSmsZap = "WhatsApp"
        else
            LabelSmsZap = "SMS"
        end if
        %>
        <br />
        <div class="tabbable">
            <div class="tab-content">
                <form id="frm" name="frm" >
                    <input type="hidden" name="E" value="E" />
                    <div class="panel">
                        <div class="panel-heading">
                            <span class="panel-title">
                                Configurações dos Eventos
                            </span>
                            <span class="panel-controls">
                                <button class="btn btn-primary btn-sm" id="save"> <i class="far fa-save"></i> Salvar </button>
                            </span>
                        </div>
                        <div class="panel-body">

                            <div class="row" style="padding-left: 10px">
                                    <h5>Ativar o serviço de envio</h5>
                            </div>
                            <div class="row">
                                <div class="col-md-2">
                                    <label>
                                        E-mail <small><span class="badge badge-pink">R$ 0,00</span></small>
                                        <br />
                                        <div class="switch round">
                                            <input type="checkbox" <% If AtivarServicoEmail="S" Then %> checked="checked"<%end if%> value="S" class="checkbox-ativo" data-type="Email" data-group="AtivarEmail" name="AtivarServicoEmail" id="AtivarServicoEmail">
                                            <label for="AtivarServicoEmail"></label>
                                        </div>

                                    </label>
                                </div>
                                <div class="col-md-2">
                                    <label>
                                        <%=LabelSmsZap%> <small><span class="badge badge-pink">R$ <%=custoMSG%></span></small>
                                        <br />
                                        <div class="switch round">
                                            <input type="checkbox" <% If AtivarServicoSMS="S" Then %> checked="checked"<%end if%> value="S" class="checkbox-ativo" data-type="SMS" data-group="AtivarSMS" name="AtivarServicoSMS" id="AtivarServicoSMS">
                                            <label for="AtivarServicoSMS"></label>
                                        </div>

                                    </label>
                                </div>
                                <div class="col-md-2 hidden">
                                    <label>
                                        WhatsApp <small><span class="badge badge-pink">R$ 0,30</span></small><small><span class="badge badge-warning">Em breve</span></small>
                                        <br />
                                        <div class="switch round">
                                            <input disabled type="checkbox" <% If AtivarServicoWhatsapp="S" Then %> checked="checked"<%end if%> value="S" class="checkbox-ativo" data-type="WhatsApp" data-group="AtivarWhatsApp" name="AtivarServicoWhatsapp" id="AtivarServicoWhatsapp">
                                            <label for="AtivarServicoWhatsapp"></label>
                                        </div>

                                    </label>
                                </div>
                                <div class="col-md-3">
                                   <%= quickfield("simpleSelect", "ModeloMsgWhatsapp", "Modelo para mensagem do whatsapp", 12, ModeloMsgWhatsapp, "select * from sys_smsemail where sysActive=1", "Descricao", " no-select2 ") %>

                                </div>

                            </div>
                            <hr class="short alt" />


                            <div class="row" style="padding-left: 10px">
                                    <h5>Ativar o envio automático (a opção pode ser alterada no agendamento)</h5>
                            </div>
                            <div class="row">
                                <div class="col-md-2">
                                    <label>
                                        E-mail
                                        <br />
                                        <div class="switch round">
                                            <input type="checkbox" <% If EnvioAutomaticoEmail="S" Then %> checked="checked" <%end if%> value="S" data-group="AtivarEmail" data-type="Email" class="marcar-envio" name="EnvioAutomaticoEmail" id="EnvioAutomaticoEmail">
                                            <label for="EnvioAutomaticoEmail"></label>
                                        </div>

                                    </label>
                                </div>
                                <div class="col-md-2">
                                    <label>
                                        <%=LabelSmsZap%>
                                        <br />
                                        <div class="switch round">
                                            <input type="checkbox" <% If EnvioAutomaticoSMS="S" Then %> checked="checked" <%end if%> value="S" data-group="AtivarSMS" data-type="SMS" class="marcar-envio" name="EnvioAutomaticoSMS" id="EnvioAutomaticoSMS">
                                            <label for="EnvioAutomaticoSMS"></label>
                                        </div>

                                    </label>
                                </div>
                                <div class="col-md-2 hidden">
                                    <label>
                                        WhatsApp
                                        <br />
                                        <div class="switch round">
                                            <input disabled type="checkbox" <% If EnvioAutomaticoWhatsapp="S" Then %> checked="checked"<%end if%> value="S" data-group="AtivarWhatsApp" data-type="WhatsApp" class="marcar-envio" name="EnvioAutomaticoWhatsapp" id="EnvioAutomaticoWhatsapp">
                                            <label for="EnvioAutomaticoWhatsapp"></label>
                                        </div>

                                    </label>
                                </div>
                            </div>

                            <hr class="short alt" />
                            <div class="row">
                                 <div class="col-md-2">
                                    <button type="button" onclick="ExcluirFila('email')" data-group="AtivarEmail" data-type="Email" class="btn btn-sm btn-danger excluir-fila" disabled><i class="far fa-exclamation-triangle"></i>  Excluir E-mail da Fila  </button>

                                 </div>
                                 <div class="col-md-2">
                                    <button type="button" onclick="ExcluirFila('sms')" data-group="AtivarSMS" data-type="SMS" class="btn btn-sm btn-danger excluir-fila" disabled><i class="far fa-exclamation-triangle"></i>  Excluir <%=LabelSmsZap%> da Fila  </button>
                                 </div>
                                 <div class="col-md-2 hidden">
                                    <button disabled type="button" onclick="ExcluirFila('whatsapp')" data-group="AtivarWhatsApp" data-type="WhatsApp" class="btn btn-sm btn-danger excluir-fila" disabled><i class="far fa-exclamation-triangle"></i>  Excluir WhatsApp da Fila  </button>
                                 </div>
                            </div>


                        </div>
                        <hr class="short alt" />

                    </div>
                </form>
            </div>
        </div>

    <%end if%>
<script type="text/javascript">
$("#frm").submit(function(){
    $.post("configEventos.asp", $(this).serialize(), function(data){
        $("#content").find(".col-xs-12").html(data);

    });
    return false;
    });

$(".checkbox-ativo").click(function(){
    var group = $(this).data("group");
    var type = $(this).data("type");

    $(".marcar-envio[data-group='"+group+"'][data-type='"+type+"']").prop("checked", $(this).prop("checked"));

    if ($(this).is(':checked')){
        $(".excluir-fila[data-group='"+group+"'][data-type='"+type+"']").attr("disabled", true);
    } else{
        $(".excluir-fila[data-group='"+group+"'][data-type='"+type+"']").removeAttr("disabled");
    }
});

function ExcluirFila(Tipo){
    if(confirm("Tem certeza que deseja apagar da fila os envios futuro?"))(
        $.post("configEventos.asp?E=E&T=ExcluirFila&Tipo="+Tipo, $("#frm").serialize(), function(data){
            $("#content").find(".col-xs-12").html(data);

        })
    );

}

<!--#include file="JQueryFunctions.asp"-->
</script>
<%end if %>