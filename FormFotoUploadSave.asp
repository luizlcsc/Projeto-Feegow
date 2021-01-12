<!--#include file="connect.asp"--><%
FormID = request.QueryString("FormID")
ModeloID = request.QueryString("ModeloID")
Col = request.QueryString("Col")
Action = request.QueryString("Action")
FileName = request.QueryString("FileName")
PacienteID = request.QueryString("PacienteID")
FTipo = request.QueryString("FTipo")

if request.QueryString("Action")<>"" then
	if FormID="N" then
		db_execute("insert into buiFormsPreenchidos (ModeloID, PacienteID, sysUser) values ("&ModeloID&", "&PacienteID&", "&session("User")&")")
		set pult = db.execute("select * from buiFormsPreenchidos where ModeloID="&ModeloID&" and PacienteID="&PacienteID&" order by id desc LIMIT 1")
		FormID = pult("id")
		db_execute("insert into `_"&ModeloID&"` (id, PacienteID, sysUser) values ("&FormID&", "&PacienteID&", "&session("User")&")")
		session("FP"&FTipo) = FormID
		call FormValPadImg(ModeloID, FormID)
	end if
	db_execute("update `_"&ModeloID&"` set `"&Col&"`='"&FileName&"' where id="&FormID)
end if

if Action="Insert" then
	resultado = "Inserido"
	url = "uploads/"&FileName
end if
set reg = db.execute("select * from `_"&ModeloID&"` where id="&FormID)
'response.Write(reg(""&Col&""))
if Action="Remove" then
	'vai chamar no eval
	%>
    $("#FormID").val(<%=FormID%>);
	<%
else
	'vai chamar pela callform
	%>{"status":"OK","resultado":"<%=resultado%>","url":"<%=url%>","FormID":"<%=FormID%>"}<%
end if
%>