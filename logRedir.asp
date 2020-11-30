<!--#include file="connect.asp"-->
<%
plogSQL = "select l.recurso, ifnull(r.Pers, '') Pers, l.I, l.PaiID from log l LEFT JOIN cliniccentral.sys_resources r on r.name=l.recurso where l.id="&req("LI")
set plog = db.execute(plogSQL)
if not plog.eof then
    if plog("Pers")="0" then
        Pers="0"
    else
        Pers="1"
    end if
    Select Case plog("recurso")
    Case "assfixalocalxprofissional"
        redirectURL = "./?P=Profissionais&Pers="&Pers&"&I="&plog("PaiID")&"&Aba=Horarios"
    Case Else
        redirectURL = "./?P="& plog("recurso") &"&Pers="&Pers&"&I="&plog("I")
    End Select
end if
plog.close
set plog = nothing

if redirectURL&""<>"" then
    response.Redirect(redirectURL)
end if
%>
