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
    set chatmensagens = db.execute("SELECT * FROM chatmensagens WHERE  Para ="&session("User")&"  and Visualizado = 0 group by De")
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
