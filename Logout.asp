<!--#include file="connect.asp"-->

  <%
  if request.QueryString("Log")="Off" then
      Inatividade = req("Inatividade")
      Evento = 6
      if Inatividade="1" then
          Evento = 7
          Desc = " por inatividade"
      end if
      'call gravaAuditoria(6, "cliniccentral.licencasusuarios", "Nome", session("User"), "Sessão encerrada"&Desc, Evento)

  	if session("Partner")="" then
  		urlRedir = "./?P=Login"
  	else
  		urlRedir = "./?P=Login&Partner="&session("Partner")
  	end if
  	session.Abandon()
  	response.Redirect(urlRedir)
  end if
  %>