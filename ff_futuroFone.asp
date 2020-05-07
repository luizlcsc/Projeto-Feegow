<!--#include file="connect.asp"-->
<!--#include file="ff_config.asp"-->
<%
'VALORES
'=== switch case com os valores ===
'=== Método, Tipo, Parametros
'=== EX: Ligacao/GetAudioPlayer, Ligacao, Ligacao:{"uniqueid"}

uniqueid = req("uniqueid")

ffMetodo = req("ff_metodo")

Select Case ffMetodo
  Case "GetAudioPlayer"
    ff_endPoint = "Ligacao/GetAudioPlayer"
    ff_metodo   = "Ligacao"
    ff_parametros  = "|uniqueid|:|"&uniqueid&"|" 
    'EX. |uniqueid|:|"&valor 1'&"|,|uniqueid|:|"&valor 2 '&"|
  Case "GetAudio"
    ff_endPoint = "Ligacao/GetAudio"
    ff_metodo   = "Ligacao"
    ff_parametros  = "|uniqueid|:|"&uniqueid&"|" 
  Case else
    response.write("Erro! Médodo Inválido.")
End Select

ff_parametros = replace(ff_parametros,"|","""")


url = ff_host&"/"&ff_endPoint&"/?json={"""&ff_metodo&""":{"&ff_parametros&"},""Options"":{""key"":"""&ff_chave&"""}}"
Dim objWinHttp
Dim strHTML
Set objWinHttp = Server.CreateObject("WinHttp.WinHttpRequest.5.1")
objWinHttp.Open "GET", url,False
objWinHttp.Send
strHTML = objWinHttp.ResponseText
Set objWinHttp = Nothing

resultadoHTML = replace(strHTML,"Futurofone - player", "Feegow Player")
Response.Write(resultadoHTML)
%>