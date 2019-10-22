<!--#include file="connect.asp"-->
<%
set plog = db.execute("select l.recurso, ifnull(r.Pers, '') Pers, l.I from log l LEFT JOIN cliniccentral.sys_resources r on r.name=l.recurso where l.id="&req("LI"))
if not plog.eof then
    if plog("Pers")="0" then
        Pers="0"
    else
        Pers="1"
    end if
    response.Redirect("./?P="& plog("recurso") &"&Pers="&Pers&"&I="&plog("I"))
end if
%>