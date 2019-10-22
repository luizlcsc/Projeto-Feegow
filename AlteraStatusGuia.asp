<!--#include file="connect.asp"-->
<%
GuiaID= req("GuiaID")
TipoGuia = req("TipoGuia")
Status = req("Status")

db_execute("update tiss"&TipoGuia&" SET GuiaStatus = "&Status&" WHERE id="&GuiaID)

if req("Lista")="1" then
    set StatusSQL = db.execute("SELECT * FROM cliniccentral.tissguiastatus WHERE id="&Status)
    if not StatusSQL.eof then

        %>{"Cor":"<%=StatusSQL("Cor")%>","Status":"<%=StatusSQL("Status")%>"}<%
    end if
end if
%>