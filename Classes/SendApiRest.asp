<%
'***
'ENVIO API REST VIA ASP
'
Function sendWebAPI(EndPoint, Content, Method, Async, Token) 

  'EndPoint::::: https:'domain/
  'Content:::::: jsonContent
  'Method::::::: POST, GET, PUT, DELETE
  'AsyncType:::: true or false
  'response.write("<hr>"&EndPoint&"<hr>"&Content&"<hr>"&Method&"<hr>"&Async)
  if Async = false then
    Set http = Server.CreateObject("WinHttp.WinHttpRequest.5.1")
    With http
      Call .Open(Method, EndPoint, false) 'ASYNC = true
      Call .SetRequestHeader("Content-Type", "application/json")
      Call .SetRequestHeader("X-Api-Key", "[X-Api-Key]")
      Call .SetRequestHeader("X-Auth-Token", "[X-Auth-Token]")
      Call .Send(Content)
    End With
    If http.Status = 201 Then
      sendWebAPI = "Success: "
    Else
      sendWebAPI = "Server returned: "
    End If
      
    sendWebAPI = sendWebAPI&http.Status & " " & http.StatusText
  else
    set xmlhttp = Server.CreateObject("Microsoft.XMLHTTP")
    xmlhttp.Open Method, EndPoint, Async
    xmlhttp.setRequestHeader "Content-Type", "application/json"
    if Token&""<>"" then
      xmlhttp.setRequestHeader "x-access-token", Token
    end if
    xmlhttp.Send Content
  end if

End Function
%>