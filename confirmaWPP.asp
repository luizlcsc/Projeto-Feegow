<!--#include file="connect.asp"-->
<%
if LicenseID<>5459 then
    response.end
end if

FilaID = req("FilaID")
Resultado = req("Resultado")
if FilaID<>"" then
    db.execute("INSERT INTO cliniccentral.smshistorico (LicencaID, DataHora, AgendamentoID, EventoID, Mensagem, Resultado, Celular, WhatsApp) select LicencaID, DataHora, AgendamentoID, EventoID, Mensagem, '"& Resultado &"', Celular, WhatsApp FROM cliniccentral.smsfila WHERE id="& FilaID )
    db.execute("DELETE FROM cliniccentral.smsfila WHERE id="& FilaID )
    response.end
end if
%>
<div class="row">
    <div class="col-md-3 col-md-offset-9">
        <select data-toggle="tooltip" title="" name="TipoLinkWhatsApp" id="TipoLinkWhatsApp" class="form-control input-sm " data-original-title="Comportamento para o envio de WhatsApp">
            <option value="whatsapp://send">WhatsApp Desktop</option>
            <option value="https://web.whatsapp.com/send">WhatsApp Web</option>
        </select>
    </div>
</div>
<script src="https://cdn.feegow.com/feegowclinic-v7/vendor/plugins/pnotify/pnotify.js"></script>
<script src="https://amor-saude.feegow.com/v7.6/js/components.js?a=50"></script>

<script type="text/javascript">

    var whatsAppAlertado = false;
    function AlertarWhatsapp(Celular, Texto, id) {
        var TipoLinkWhatsApp = $("#TipoLinkWhatsApp").val();

        localStorage.setItem("TipoLinkWhatsApp", TipoLinkWhatsApp);

        var url = TipoLinkWhatsApp+"?phone="+Celular+"&text="+Texto;
        $("#wpp-"+id).html("<i class='success fa fa-check-circle'></i>");

        openTab(url);
    }

    function openTab(url) {
      const link = document.createElement('a');
      link.href = url;
      link.target = '_blank';
      document.body.appendChild(link);
      link.click();
      link.remove();
    }
</script>

<div class="panel">
    <div class="panel-body">
        <table class="table">
        <%

        set fila = db.execute("select sms.*  from cliniccentral.smsfila sms  "&_
                              " "JOIN clientes_servicosadicionais sa ON sa.LicencaID=sms.LicencaID "&_
                              " "where sms.WhatsApp=1 AND date(sms.DataHora)=CURDATE()  "&_
                              " "AND sa.`Status`=4 AND sa.ServicoID=47 "&_
                              " "AND length(mensagem)>10  "&_
                              " "ORDER BY sms.DataHora LIMIT 100")
        while not fila.eof
            AgendamentoID = fila("AgendamentoID")
            LicencaID = fila("LicencaID")
            msg = replace(fila("Mensagem")&"", chr(13), "%0D")
            if not isnull(AgendamentoID) then
                msg = msg & "%0D%0D"
                msg = msg & "Para confirmar ou cancelar seu agendamento, clique neste link ou cole no navegador de internet:  https://confirmacao-api.feegow.com/"& AgendamentoID &":"& LicencaID
                msg = replace(msg, "&", "e")
                msg = replace(msg, "[Profissional.Tratamento]", "")
            end if
            %>
            <tr id="div<%= fila("id") %>">
                <td><%= fila("LicencaID") %></td>
                <td><%= quickfield("memo", "msg"& fila("id"), "", 12, msg, "", "", " rows=6 ") %></td>
                <td><%= fila("Celular") %></td>
                <td>
                <div class="col-md-12">
                    <button type="button" class="btn btn-lg btn-primary btn-conf btn-block m10" type="button" onclick="AlertarWhatsapp('<%= fila("Celular") %>', $('#msg<%= fila("id") %>').val(), '<%= fila("id") %>'); $(this).removeClass('btn-primary'); $(this).addClass('btn-warning');"><i class="fa fa-whatsapp"></i> <%= fila("Celular") %></button>
                </div>
                <div class="col-md-6">
                    <button type="button" class="btn btn-xs btn-danger btn-block m10" onclick="feito(<%= fila("id") %>, '400')"><i class="fa fa-thumbs-down"></i> Erro</button>
                </div>
                <div class="col-md-6">
                    <button type="button" class="btn btn-xs btn-success btn-block m10" onclick="feito(<%= fila("id") %>, '202')"><i class="fa fa-thumbs-up"></i> Sucesso</button>
                </div>
                
                </td>
            </tr>
            <%
        fila.movenext
        wend
        fila.close
        set fila = nothing
        %>
        </table>
    </div>
</div>
<script>
function feito(FilaID, Resultado) {
    $.get("confirmaWPP.asp?FilaID="+ FilaID +"&Resultado="+ Resultado, function(data){
        $("#div"+FilaID).remove();
    });
}
</script>