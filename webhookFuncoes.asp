<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<!--#include file="Classes/SendApiRest.asp"-->
<%
function addToQueue(eventId, body, EndPoint)
    LicencaID=replace(session("Banco"), "clinic","")
    set EndpointSQL = dbc.execute("SELECT e.id FROM cliniccentral.webhook_eventos ev INNER JOIN cliniccentral.webhook_endpoints e ON e.EventoID=ev.id WHERE ev.Ativo='S' AND ev.id="&eventId&" AND e.LicencaID="&LicencaID)

    if not EndpointSQL.eof then
        EventoID = EndpointSQL("id")

        set TokenSQL = dbc.execute("SELECT token FROM api_token WHERE LicencaID="&LicencaID&" AND Ativo=1")

        if not TokenSQL.eof then

            Token = TokenSQL("token")
            data = body
            if isnumeric(body) then
                body = "{ ""id"": "&body&" }"
                data = "{""event_id"": "&eventId&", ""webhook_body"": "&body&" }"
            end if
            
            CALL sendWebAPI(EndPoint, data, "POST", true, Token, Header) 

            '*** <MÉTODO ANTIGO> ***'

            'Set httpRequest = Server.CreateObject("MSXML2.ServerXMLHTTP")
            'httpRequest.Open "POST", "https://api.feegow.com.br/webhook/add-webhook-queue", False
            'httpRequest.SetRequestHeader "Content-Type", "application/json"
            'httpRequest.SetRequestHeader "x-access-token", Token
            'httpRequest.Send data

            'postResponse = httpRequest.ResponseText

            '*** </MÉTODO ANTIGO> ***'

        end if
    end if
end function

'WEBHOOK QUE UTILIZA O SERVIÇO DE MENSAGERIA DESACOPLADO DO SAVE.ASP
function webhookMessage()
    'VERIFICA TIPOS DE EVENTO PARA DISPARAR O WEBHOOK
    validaEventosSQL =  "SELECT ev.id, ev.Status                                                                                "&chr(13)&_
                        "FROM eventos_emailsms ev                                                                               "&chr(13)&_                                                              
                        "LEFT JOIN sys_smsemail AS sSmsEma ON sSmsEma.id = ev.ModeloID                                          "&chr(13)&_                                                              
                        "LEFT JOIN cliniccentral.eventos_whatsapp AS eveWha ON eveWha.id = sSmsEma.EventosWhatsappID            "&chr(13)&_
                        "WHERE ev.WhatsApp=1                                                                                    "&chr(13)&_                                                                                         
                        "AND ev.sysActive=1                                                                                     "&chr(13)&_
                        "AND ev.Ativo=1                                                                                         "&chr(13)&_
                        "AND eveWha.id IS NOT NULL                                                                              "&chr(13)&_                                                                                          
                        "AND (ev.Procedimentos LIKE '%|ALL|%' OR ev.Procedimentos LIKE '%|"& ref("ProcedimentoID") &"|%')       "&chr(13)&_               
                        "AND (ev.Unidades LIKE '%|ALL|%' OR ev.Unidades LIKE '%|"& AgendamentoUnidadeID &"|%')                  "&chr(13)&_                       
                        "AND (ev.Especialidades LIKE '%|ALL|%' OR ev.Especialidades LIKE '%|"& ref("EspecialidadeID") &"|%')    "&chr(13)&_           
                        "AND (ev.Profissionais LIKE '%|ALL|%' OR ev.Profissionais LIKE '%|"& ref("ProfissionalID") &"|%')       "
        
    set validaEventos = db.execute(validaEventosSQL)
    if not validaEventos.eof then
        while not validaEventos.eof
            
            EventoStatus = validaEventos("Status")
            EventoID = validaEventos("id")
            bodyContentFrom = "|PacienteID|,|EventoID|,|AgendamentoID|,|ProfissionalID|,|ProcedimentoID|,|UnidadeID|"
            bodyContentTo   = "|"&ref("PacienteID") &"|,|"& EventoID &"|,|"& ref("ConsultaID") &"|,|"& ref("ProfissionalID") &"|,|"& ref("ProcedimentoID") &"|,|"& AgendamentoUnidadeID &"|"
            'MARCADO CONFIRMADO E MARCADO NÃO CONFIRMADO
            webhookID = false

            select case ref("StaID")
                Case 1 'MARCADO NÃO CONFIRMADO
                    if instr(EventoStatus,"|1|") > 0 then
                        webhookID = 119
                    end if
                Case 3 'ATENDIDO
                    if instr(EventoStatus,"|3|") > 0 then
                        webhookID = 121
                    end if

                Case 6 'NÃO COMPARECEU = 6
                    if instr(EventoStatus,"|6|") > 0 then
                        webhookID = 122
                    end if

                Case 7 'MARCADO CONFIRMADO = 7
                    if instr(EventoStatus,"|7|") > 0 then
                        webhookID = 120
                    end if

                Case 11 'DESMARCADO PELO PACIENTE
                    if instr(EventoStatus,"|11|") > 0 then
                        webhookID = 123
                    end if

                Case 15 'REMARCADO
                    if instr(EventoStatus,"|15|") > 0 then
                        webhookID = 124
                    end if
            end select
                
            if webhookID then
                call webhook(webhookID, true, bodyContentFrom, bodyContentTo)
            end if

        validaEventos.movenext
        wend
    end if
    validaEventos.close
    set validaEventos = nothing

end function
%>