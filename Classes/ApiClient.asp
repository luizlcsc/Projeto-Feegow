<!--#include file="../connectCentral.asp"-->
<%
Class ApiClient
    
    Private endpoint
    Private licenseId
    Private token
    
    Public Sub Class_Initialize()
        endpoint = "https://api.feegow.com.br/"
        licenseId = replace(session("Banco"), "clinic","")
        token = request.Cookies("tk")
    end Sub

    Public Function getApiEndpoint(route, queryString)
        getApiEndpoint = endpoint&route&"?"&queryString
    End Function

    Public Function submitPost(url, data)
        if token="" then
            token="0"
        end if

        Set httpRequest = Server.CreateObject("MSXML2.ServerXMLHTTP")
        httpRequest.Open "POST", endpoint&url, False
        httpRequest.SetRequestHeader "Content-Type", "application/json"
        httpRequest.SetRequestHeader "x-access-token", token
        httpRequest.Send data

        postResponse = httpRequest.ResponseText

        submitPost= postResponse
    End Function

    Public Function submitGet(url, queryString)
        Set httpRequest = Server.CreateObject("MSXML2.ServerXMLHTTP")
        httpRequest.Open "GET", endpoint&url&"?"&queryString, False
        httpRequest.SetRequestHeader "Content-Type", "application/json"
        httpRequest.SetRequestHeader "x-access-token", token
        
        httpRequest.Send False

        postResponse = httpRequest.ResponseText

        submitGet= postResponse
    End Function

    Public Function addWebhookToQueue(eventId, body)
        'Verifica se existe algum webhook configurado para essa licença
        sql = "SELECT e.id FROM cliniccentral.webhook_eventos ev INNER JOIN cliniccentral.webhook_endpoints e ON e.EventoID=ev.id WHERE ev.Ativo='S' AND ev.id="&eventId&" AND e.LicencaID="&licenseId
        set EndpointSQL = dbc.execute(sql)

        if not EndpointSQL.eof then
            EventoID = EndpointSQL("id")

            Dim data, httpRequest, postResponse
            if isnumeric(body) then
                body = "{ ""id"": "&body&" }"
            end if

            data = "{""event_id"": "&eventId&", ""webhook_body"": "&body&" }"

            output = submitPost("webhook/add-webhook-queue", data)

            addToQueue=output
        end if
        addToQueue=False

    End Function

End Class
%>