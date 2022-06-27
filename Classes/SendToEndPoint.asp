<%

' exemplo
' EndPoint = "http://localhost:8000/api/quickfield2/test"
' Content="{""id"":3,""cor"":""azul""}"
' Method = "POST"
' call SendAsync(EndPoint, Content, Method, "")
' resp =  SendSync(EndPoint, Content, Method, "")
'EndPoint = url
'Content = json body
'Method = GET,POST
'Token = token se tiver
'EndPointHeader = se tiver
Function SendSync(EndPoint, Content, Method, Token)
    Set xmlHttp = Server.Createobject("MSXML2.ServerXMLHTTP")
    xmlhttp.Open Method, EndPoint, false

    if Token <> "" then
        xmlHttp.setRequestHeader "X-Access-Token", Token
    end if
    xmlHttp.setRequestHeader "User-Agent", "ASP/3.0"
    xmlHttp.setRequestHeader "Content-Type", "application/json"
    xmlHttp.setRequestHeader "Accept","application/json"
    xmlhttp.Send Content&" "
    If xmlhttp.Status = 200 Then
        message = xmlhttp.responseText
    Else
        message = xmlhttp.Status & ": " & xmlhttp.statusText
    End If
    sendWebAPI = CStr(message)
    xmlHttp.abort()
    Set xmlhttp = Nothing
End Function
Function SendAsync(EndPoint, Content, Method, Token)
    on error resume next
    Set xmlHttp = Server.Createobject("Microsoft.XMLHTTP")
    xmlhttp.Open Method, EndPoint, true

    if Token <> "" then
        xmlHttp.setRequestHeader "X-Access-Token", Token
    end if
    xmlHttp.setRequestHeader "User-Agent", "ASP/3.0"
    xmlHttp.setRequestHeader "Content-Type", "application/json"
    xmlHttp.setRequestHeader "Accept","application/json"
    ' response.write Content
    xmlhttp.Send Content&" "
    
    On Error Goto 0
End Function
%>