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
  'AUTENTICAÇÃO
  Case "GetLoginAgente"
    ff_endPoint     = "AgenteLogin/Login"
    ff_metodo       = "AgenteLogin"
    ff_parametros   = "|agente|:|"&agente&"|,|senha|:|"&senha&"|,|ramal|:|"&ramal&"|,|pausa|:|"&pausa&"|"
    ff_parametros2  = ""
  Case "GetLoginAgenteLogoff"
    ff_endPoint     = "AgenteLogin/Logoff"
    ff_metodo       = "AgenteLogin"
    ff_parametros   = "|agente|:|"&agente&"|"
  Case "GetLoginAgentePainel"
    ff_endPoint     = "AgenteLogin/LoginPainel"
    ff_metodo       = "AgenteLogin"
    ff_parametros   = "|agente|:|"&agente&"|,|ramal|:|"&ramal&"|,|pausa|:|"&pausa&"|"
    ff_parametros2  = ""
  'LIGAÇÃO
  Case "GetLigacaoIniciar"
    ff_endPoint     = "Ligacao/Iniciar"
    ff_metodo       = "LigacaoIniciar"
    ff_parametros   = "|src|:|"&src&"|,|dst|:|"&dst&"|"
    ff_parametros2  = ""
  Case "GetAudioPlayer"
    ff_endPoint     = "Ligacao/GetAudioPlayer"
    ff_metodo       = "Ligacao"
    ff_parametros   = "|uniqueid|:|"&uniqueid&"|" 
    ff_parametros2  = ""
  Case "GetAudio"
    ff_endPoint     = "Ligacao/GetAudio"
    ff_metodo       = "Ligacao"
    ff_parametros   = "|uniqueid|:|"&uniqueid&"|"
    ff_parametros2  = ""
  'CAMPANHAS
  Case "GetCampanhaAgendaConfirma" 'NÃO ESPECIFICAR CAMPANHA ATIVA - NÃO PODE TER + DE UMA
    ff_endPoint     = "Campanha/ConfirmacaoAgenda"
    ff_metodo       = "CampanhaContato"
    ff_parametros   = "|uid|:|"&uid&"|,|telefone|:|"&telefone&"|,|detalhe|:|"&detalhe&"|"
    ff_metodo2      = "detalhe"
    ff_parametros2  = "|variavel|:|"&variavel&"|,|valor|:|"&valor&"|"
  Case "GetCampanhaCancelarPendentes" 'NÃO ESPECIFICAR CAMPANHA ATIVA - NÃO PODE TER + DE UMA
    ff_endPoint     = "Campanha/ConfirmacaoAgenda/CancelarPendentes"
    ff_metodo       = "Campanha"
    ff_parametros   = "|campanha|:|"&campanha&"|" 
  
  Case else
    response.write("Erro! Médodo Inválido.")
End Select

ff_parametros = replace(ff_parametros,"|","""")


url = ff_host&"/"&ff_endPoint&"/?json={"""&ff_metodo&""":{"&ff_parametros&"},""Options"":{""key"":"""&ff_chave&"""}}"
'response.write(url)
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