<!--#include file="connect.asp"--><%
FPID = req("FPID")
CampoID = req("CampoID")
FileName = req("FileName")

if FPID <> "N" then
    set model = db.execute("select * from buiformspreenchidos where id="&FPID)
    if not model.EOF then
        db_execute("update _"&model("ModeloID")&" set `"&CampoID&"`='"&Filename&"' where id="&FPID)
    end if
end if
'response.Write(reg(""&Col&""))
%>
$("#fotoFoto<%=CampoID%>").html('<img src="uploads/<%=fileName%>" style="max-width:95%; max-height:90%;">');