<!--#include file="connect.asp"--><%
P = req("P")
I = req("I")
Col = req("Col")
Action = req("Action")
FileName = req("FileName")

if Action<>"" then
	db_execute("update "&P&" set "&Col&"='"&FileName&"' where id="&I)
end if

if Action="Insert" then
	resultado = "Inserido"
	url = "/uploads/"& replace(session("Banco"), "clinic", "") &"/Perfil/"&FileName
	set reg = db.execute("select * from "&P&" where id="&I)
	%>{"status":"OK","resultado":"<%=resultado%>","url":"<%=url%>"}<%
elseif Action="InsertCamera" then
	%>
	$("#divAvatar, #divDisplayFoto").css("display", "block");
	$("#take-photo, #cancelar").css("display", "none");
	$("#divDisplayFoto").html('<img id="avatarFoto" class="img-thumbnail" width="100%" src="/uploads/<%= replace(session("Banco"), "clinic", "") %>/Perfil/<%=FileName%>"><button class="btn btn-xs btn-danger" style="position:absolute; left:18px; bottom:6px;" onclick="removeFoto();" type="button"><i class="far fa-trash"></i></button>');
    $("#photo-data").val("");
    cancelar();
	<%
end if
'response.Write(reg(""&Col&""))
%>