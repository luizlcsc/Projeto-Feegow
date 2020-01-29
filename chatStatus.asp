<!--#include file="connect.asp"-->
<%

Visualizado = req("Visualizado")

if Visualizado&""<>"" then
    De = req("De")
    Para = req("Para")

    set chatstatus = db.execute("SELECT * FROM chatmensagens WHERE De="&De&" and Para="&Para&" and Visualizado = 0 ")
    if not chatstatus.eof then
	    db_execute("update chatmensagens set Visualizado=1 where De="&De&" and Para="&Para)
    end if

else
    set chatmensagens = db.execute("SELECT t.id"&_
                                    " FROM ("&_
                                    " SELECT sp.id"&_
                                    " FROM profissionais p"&_
                                    " LEFT JOIN sys_users sp ON sp.idInTable=p.id AND sp.Table LIKE 'profissionais'"&_
                                    " WHERE p.sysActive=1 AND p.Ativo='on' AND NOT ISNULL(sp.id) UNION ALL"&_
                                    " SELECT sf.id"&_
                                    " FROM funcionarios f"&_
                                    " LEFT JOIN sys_users sf ON sf.idInTable=f.id AND sf.Table LIKE 'funcionarios'"&_
                                    " WHERE f.sysActive=1 AND NOT ISNULL(sf.`id`) AND f.Ativo='on'"&_
                                    " )t"&_
                                    " LEFT JOIN chatmensagens chat ON De=t.id"&_
                                    " where chat.Visualizado = 0 and chat.Para= "&session("User")&" "&_
                                    " GROUP BY t.id"&_
                                    " ORDER BY chat.DataHora DESC")
    if not chatmensagens.eof then
        %>
            $("#badge-chat").html("!");
        <%
        else
        %>
            $("#badge-chat").html("");
        <%
    end if
end if
%>
