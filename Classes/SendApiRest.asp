
<!--#include file="./../connect.asp"-->
<%
Function webhook(EventId, Async, replaceFrom, replaceTo)
  if isnumeric(EventID) then
    checkEndPointSQL =  " SELECT webEnd.id, webEnd.URL, webEve.Metodo, webEve.id evento_id, webEve.ModeloJSON FROM `cliniccentral`.`webhook_eventos` webEve                      "&chr(13)&_
                        " LEFT JOIN `cliniccentral`.`webhook_endpoints` webEnd ON webEnd.EventoID = webEve.id  "&chr(13)&_
                        " WHERE webEnd.LicencaID="&replace(session("Banco"),"clinic","")&" AND webEve.id="&EventId&"  AND webEve.Ativo='S'"
    
    SET  checkEndPoint = db.execute(checkEndPointSQL)
    if not checkEndPoint.eof then

      webhook_eventID  = checkEndPoint("evento_id")
      webhook_method   = checkEndPoint("Metodo")
      webhook_endpoint = checkEndPoint("URL")
      webhook_body     = checkEndPoint("ModeloJSON")
      webhook_body     = replace(webhook_body, replaceFrom,replaceTo)
      webhook_header   = checkEndPoint("id") 'HEADER CUSTOMIZADO
      
      CALL sendWebAPI(webhook_endpoint, webhook_body, webhook_method, True, Token, webhook_header)

    end if
    checkEndPoint.close
    set checkEndPoint = nothing
  end if

End Function

'***
'ENVIO API REST VIA ASP
'
Function sendWebAPI(EndPoint, Content, Method, Async, Token, EndPointHeader) 

  if Async= false then
    Set xmlhttp = CreateObject("MSXML2.serverXMLHTTP") 'NÃO FUNCIONANDO ASYNC
  else
    Set xmlhttp = CreateObject("Microsoft.XMLHTTP") 'NÃO FUNCIONANDO SYNC
  end if  
  xmlhttp.Open Method, EndPoint, Async

  if isnumeric(EndPointHeader) then
  set webHookHeader = db.execute("SELECT * FROM cliniccentral.webhook_header where endPointID="&EndPointHeader)
  if not webHookHeader.eof then
    while not webHookHeader.eof
      xmlhttp.setRequestHeader webHookHeader("header"), webHookHeader("value")
    webHookHeader.movenext
    wend
  end if
    webHookHeader.close
    set webHookHeader = nothing
  end if  

  xmlhttp.Send Content

  if Async= false then 
    If xmlhttp.Status = 200 Then
      message = xmlhttp.responseText
    Else
      message = xmlhttp.Status & ": " & xmlhttp.statusText
    End If

    response.write(message)
  end if  

  Set xmlhttp = Nothing

End Function
%>