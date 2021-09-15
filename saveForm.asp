<!--#include file="connect.asp"-->
<%
'set modelo = db.execute("select * from ")
if instr(ref("field"), "campo_")>0 then
	campo = replace(ref("field"), "campo_", "")
	if trim(ref("checkbox"))<>"" then
		valor = trim(cstr(refhtml("checkbox")))
	else
		valor = refhtml("value")
	end if
else
	lembrarme = "S"
end if

set modelo = db.execute("select * from buiforms where id="&ref("ModeloID"))
if not modelo.EOF then
	if modelo("Tipo")=4 or modelo("Tipo")=3 then
		FTipo = "L"
	else
		FTipo = "AE"
	end if
end if

if session("FP"&FTipo)="N" then
	db_execute("insert into buiFormsPreenchidos (ModeloID, PacienteID, sysUser) values ("&ref("ModeloID")&", "&ref("PacienteID")&", "&session("User")&")")
	set pult = db.execute("select * from buiFormsPreenchidos where ModeloID="&ref("ModeloID")&" and PacienteID="&ref("PacienteID")&" order by id desc LIMIT 1")
	if lembrarme="S" then
		sqlIns = "insert into `_"&ref("ModeloID")&"` (id, PacienteID, sysUser) values ("&pult("id")&", "&ref("PacienteID")&", "&session("User")&")"
	else
		sqlIns = "insert into `_"&ref("ModeloID")&"` (id, `"&campo&"`, PacienteID, sysUser) values ("&pult("id")&", '"&valor&"', "&ref("PacienteID")&", "&session("User")&")"
	end if
	
	%>
    atualizaHistorico();
	<%
	
	
	'response.Write(sqlIns)
	db_execute(sqlIns)
	FormID = pult("id")
	session("FP"&FTipo) = pult("id")
	%>
    $("#FormID").val(<%=FormID%>);
    <%
	call FormValPadImg(ref("ModeloID"), FormID)
else
	FormID = session("FP"&FTipo)
	if lembrarme="" then
		sqlUp = "update `_"&ref("ModeloID")&"` set `"&campo&"`='"&valor&"' where id="&FormID
		db_execute(sqlUp)
	end if
end if

if lembrarme="S" then
	if ref("checked")="checked" then
		db_execute("insert into buiformslembrarme (PacienteID, ModeloID, FormID, CampoID) values ('"&ref("PacienteID")&"', '"&ref("ModeloID")&"', '"&FormID&"', '"&replace(ref("field"), "lembrarme_", "")&"')")
	else
		db_execute("delete from buiformslembrarme where PacienteID="&ref("PacienteID")&" and ModeloID="&ref("ModeloID")&" and FormID="&FormID&" and CampoID="&replace(ref("field"), "lembrarme_", ""))
	end if
end if
%>
$.gritter.add({
    title: '<i class="far fa-save"></i> Salvo automaticamente...',
    text: '',
    time: 500,
    class_name: 'gritter-success gritter-light'
});
