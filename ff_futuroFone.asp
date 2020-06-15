<!--#include file="connect.asp"-->
<!--#include file="ff_config.asp"-->
<%
'VALORES
'=== switch case com os valores ===
'=== Método, Tipo, Parametros
'=== EX: Ligacao/GetAudioPlayer, Ligacao, Ligacao:{"uniqueid"}

'LIGACAO
uniqueid  = req("uniqueid")
'OPERADOR
agente    = req("agente")
senha     = req("senha")
ramal     = req("ramal")
pausa     = req("pausa")


ffMetodo = req("ff_metodo")

sessionClinicBase = session("banco")
sessionUser = session("User")

Select Case ffMetodo
  'AUTENTICAÇÃO
  Case "GetLoginAgente" 'LOGIN E PAUSAS
    ff_endPoint     = "AgenteLogin/Login"
    ff_metodo       = "AgenteLogin"
    ff_parametros   = "|agente|:|"&agente&"|,|senha|:|"&senha&"|,|ramal|:|"&ramal&"|,|pausa|:|"&pausa&"|"
    ff_parametros2  = ""
    
    if pausa<>"" then
      pausaUpdateSQL = ", `pabx_pausa`='"&pausa&"'"
    end if
    if sessionClinicBase<>"" then
      acaoSQL = "UPDATE `"&sessionClinicBase&"`.`sys_users` SET `pabx_logado`='1'"&pausaUpdateSQL&" WHERE  `id`='"&sessionUser&"';"
    end if
  Case "GetLoginAgenteLogoff"
    ff_endPoint     = "AgenteLogin/Logoff"
    ff_metodo       = "AgenteLogin"
    ff_parametros   = "|agente|:|"&agente&"|"

    if sessionClinicBase<>"" then
      acaoSQL = "UPDATE `"&sessionClinicBase&"`.`sys_users` SET `pabx_logado`='0' WHERE  `id`='"&sessionUser&"';"
    end if
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

'response.write(ff_parametros)
'response.write(session("banco"))
'response.write(url)
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

if acaoSQL<>"" then
  db.execute(acaoSQL)
end if
%>