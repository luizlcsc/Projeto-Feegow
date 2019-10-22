<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<%

function addToQueue(eventId, body)
    LicencaID=replace(session("Banco"), "clinic","")
    set EndpointSQL = dbc.execute("SELECT e.id FROM cliniccentral.webhook_eventos ev INNER JOIN cliniccentral.webhook_endpoints e ON e.EventoID=ev.id WHERE ev.Ativo='S' AND ev.id="&eventId&" AND e.LicencaID="&LicencaID)

    if not EndpointSQL.eof then
        EventoID = EndpointSQL("id")

        set TokenSQL = dbc.execute("SELECT token FROM api_token WHERE LicencaID="&LicencaID&" AND Ativo=1")

        if not TokenSQL.eof then
            Token = TokenSQL("token")

            Dim data, httpRequest, postResponse
            if isnumeric(body) then
                body = "{ ""id"": "&body&" }"
            end if

            data = "{""event_id"": "&eventId&", ""webhook_body"": "&body&" }"

            Set httpRequest = Server.CreateObject("MSXML2.ServerXMLHTTP")
            httpRequest.Open "POST", "https://api.feegow.com.br/webhook/add-webhook-queue", False
            httpRequest.SetRequestHeader "Content-Type", "application/json"
            httpRequest.SetRequestHeader "x-access-token", Token
            httpRequest.Send data

            postResponse = httpRequest.ResponseText
        end if
    end if
end function

%>