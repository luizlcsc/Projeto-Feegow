<%
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