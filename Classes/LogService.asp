<!--#include file="Base64.asp"-->
<%
'FeegowLogService
'Version: 0.1

'CONSTANTES DO LOG
LOG_SERVICE_API_ENDPOINT = "https://galahad.feegow.com/logs"
LOG_SERVICE_API_TOKEN    = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjAsImxpY2Vuc2VJZCI6MCwiaWF0IjoxNjM1MTcxODk3fQ.oiKNt06F9TPoUDM91xJJKghpKHYCjutaeN8KamkzAvk"

if Request.ServerVariables("SERVER_NAME") = "localhost" then
  LOG_SERVICE_API_ENDPOINT = "http://localhost:3000/logs"
end if


'Envia um log de forma assíncrona
'Parâmetros:
'   logType (string required):      Tipos aceitáveis auth, error, event, audit
'   logLicenseId (number required): Id da licença onde o log será gravado
'   logCategory (string required):  Categoria do log
'   logEvent (string required):     Evento de log
'   logMessage (string ou vazio):   Mensagem de log
'   logUserId (number ou vazio):    Id do usuário
'   logUserName (string ou vazio):  Nome de usuário (username)
'   logPayload (string ou vazio):   Payload do Log
function sendLog(logType, logLicenseId, logCategory, logEvent, logMessage, logUserId, logUserName, logPayload)

    Dim logBody
    'required
    logBody = "{" &_
          """type"": """ & logType & """, " &_
          """licenseId"": """ & logLicenseId & """, " &_
          """category"": """ & getLogJsonEncoded(logCategory) & """, " &_
          """event"": """ & getLogJsonEncoded(logEvent) & """"

    'optional
    if logMessage <> "" then
      logBody = logBody & ", ""message"": """ & getLogJsonEncoded(logMessage) & """"
    end if
    if logUserId <> "" then
      logBody = logBody & ", ""userId"": """ & getLogJsonEncoded(logUserId) & """"
    end if
    if logUserName <> "" then
      logBody = logBody & ", ""userName"": """ & getLogJsonEncoded(logUserName) & """"
    end if

    'payload
    if logPayload <> "" then
      logBody = logBody & ", ""payload"": {" & logPayload & "}"
    end if

    'request metadata
    logBody = logBody & ", ""request"": {" & getLogRequestVariables() & "}"

    logBody = logBody & "}"

    Set xmlhttp = CreateObject("Microsoft.XMLHTTP")
    xmlhttp.Open "POST", LOG_SERVICE_API_ENDPOINT, True

    xmlhttp.setRequestHeader "Authorization", "Bearer " & LOG_SERVICE_API_TOKEN
    xmlhttp.setRequestHeader "Content-type", "application/json"

    xmlhttp.Send logBody

    Set xmlhttp = Nothing

end function

'Retorna variáveis do request (ServerVariables) que serão registradas junto com a mensagem de log
function getLogRequestVariables()

    if lcase(Request.ServerVariables("HTTPS")) = "on" then
        strProtocol = "https"
    else
        strProtocol = "http"
    end if

    strRemoteAddr = Request.ServerVariables("HTTP_X_FORWARDED_FOR")
    if strRemoteAddr = "" then
      strRemoteAddr = Request.ServerVariables("REMOTE_ADDR")
    end if

    strServerName  = Request.ServerVariables("SERVER_NAME")
    strUrl         = Request.ServerVariables("URL")
    strQueryString = Request.ServerVariables("QUERY_STRING")
    
    strFullUrl     = strProtocol & "://" & strServerName & strUrl
    if strQueryString <> "" then
      strFullUrl = strFullUrl & "?" & strQueryString
    end if

    srvContent = """method"": """ & Request.ServerVariables("REQUEST_METHOD") & """, " &_
                 """url"": """ & getLogJsonEncoded(strFullUrl) & """, " &_
                 """queryString"": """ & getLogJsonEncoded(strQueryString) & """, " &_
                 """protocol"": """ & strProtocol & """, " &_
                 """serverName"": """ & strServerName & """, " &_
                 """serverAddr"": """ & Request.ServerVariables("LOCAL_ADDR") & """, " &_
                 """serverPort"": """ & Request.ServerVariables("SERVER_PORT") & """, " &_
                 """remoteAddr"": """ & strRemoteAddr & """, " &_
                 """userAgent"": """ & getLogJsonEncoded(Request.ServerVariables("HTTP_USER_AGENT")) & """, " &_
                 """referer"": """ & getLogJsonEncoded(Request.ServerVariables("HTTP_REFERER")) & """"

    getLogRequestVariables = srvContent
end function

'Trata um valor para Json
function getLogJsonEncoded(ByVal val)
  val = Replace(val, "\", "\\")
  val = Replace(val, """", "\""")
  val = Replace(val, Chr(8), "\b")
  val = Replace(val, Chr(12), "\f")
  val = Replace(val, Chr(10), "\n")
  val = Replace(val, Chr(13), "\r")
  val = Replace(val, Chr(9), "\t")
  getLogJsonEncoded = Trim(val)
End Function

'Envia um log do evento de Login com Sucesso
function sendLogLoginSuccess()
    licenseId = replace(session("Banco"), "clinic", "")
    if session("MasterPwd") = "S" then
      isMasterLogin = "true"
    else
      isMasterLogin = "false"
    end if

    userId   = session("User")
    userName = getLogJsonEncoded(session("Email"))

    payload = """userId"": " & userId & ", " &_ 
              """userName"": """ & userName & """, " &_
              """isMasterLogin"":" & isMasterLogin

    if req("Partner") <> "" then
        payload = payload & ", ""partner"": """ & getLogJsonEncoded(req("Partner")) & """"
    end if

    call sendLog("auth", licenseId, "LoginPadrao", "login", "User logged in", userId, userName, payload)

    Response.Cookies("logLastUser")("id")=Base64Encode(userId)
    Response.Cookies("logLastUser")("username")=Base64Encode(userName)
    Response.Cookies("logLastUser")("licenseId")=Base64Encode(licenseId)
end function

'Envia um log do evento de Logout
function sendLogLogout()
    if session("User") <> "" and session("Banco") <> "" then
        licenseId = replace(session("Banco"), "clinic", "")
        if session("MasterPwd") = "S" then
            isMasterLogin = "true"
        else
            isMasterLogin = "false"
        end if

        userId   = session("User")
        userName = getLogJsonEncoded(session("Email"))

        payload = """userId"": " & userId & ", " &_ 
                  """userName"": """ & userName & """, " &_
                  """isMasterLogin"":" & isMasterLogin

        if req("Partner") <> "" then
            payload = payload & ", ""partner"": """ & getLogJsonEncoded(req("Partner")) & """"
        end if

        call sendLog("auth", licenseId, "LoginPadrao", "logout", "User logged out", userId, userName, payload)

        Response.Cookies("logLastUser").Expires = DateAdd("d",-1,Now())
    end if
end function

'Envia um log do evento de Falha/Tentativa de Login
'Parâmetros:
'   logLicenseId (number required): Id da licença onde o log será gravado
'   logErrorMsg (string required):  Mensagem de erro
'   logUserName (string required):  Nome de usuário (username)
function sendLogLoginError(logLicenseId, logErrorMsg, logUserName, logIsMaster)
    if logIsMaster then
      isMasterLogin = "true"
    else
      isMasterLogin = "false"
    end if

    payload = """isMasterLogin"":" & isMasterLogin

    if logUserName <> "" then
      payload =  payload & ", ""userName"": """ & getLogJsonEncoded(logUserName) & """"
    end if

    if req("Partner") <> "" then
      payload = payload & ", ""partner"": """ & getLogJsonEncoded(req("Partner")) & """"
    end if

    call sendLog("auth", logLicenseId, "LoginPadrao", "login_error", logErrorMsg, "", logUserName, payload)
end function

'Envia um log do evento de Sessão Expirada
function sendLogSessionExpired()
    if Len(Request.Cookies("logLastUser")) > 0 then
      logUserId    = Base64Decode(Request.Cookies("logLastUser")("id"))
      logUserName  = Base64Decode(Request.Cookies("logLastUser")("username"))
      logLicenseId = Base64Decode(Request.Cookies("logLastUser")("licenseId"))

      payload = """userId"": " & logUserId & ", " &_ 
                """userName"": """ & logUserName & """"

      call sendLog("auth", logLicenseId, "LoginPadrao", "session_expired", "Session expired", logUserId, logUserName, payload)

      Response.Cookies("logLastUser").Expires = DateAdd("d",-1,Now())
    end if
end function

%>
