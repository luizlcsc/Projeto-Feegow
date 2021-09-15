<!--#include file="connect.asp"-->
<%
FormID = req("F")

set vtam = db.execute("select c.CHARACTER_MAXIMUM_LENGTH tamanho from information_schema.`COLUMNS` c WHERE c.TABLE_SCHEMA='"&session("banco")&"' AND c.TABLE_NAME='buipermissoes' AND c.COLUMN_NAME='Permissoes'")
if vtam("tamanho")="20" then
	db_execute("ALTER TABLE `buipermissoes`	CHANGE COLUMN `Permissoes` `Permissoes` VARCHAR(500) NULL DEFAULT NULL AFTER `Grupo`")
end if

set permform = db.execute("select id from buipermissoes where FormID="&FormID)
while not permForm.eof
	db_execute("update buipermissoes set Grupo='"&ref("Grupo"&permform("id"))&"', Permissoes='"&ref("Permissoes"&permform("id"))&"' where id="&permform("id"))
permform.movenext
wend
permform.close
set permform=nothing
%>
$.gritter.add({
    title: '<i class="far fa-save"></i> Permiss&otilde;es salvas!',
    text: '',
    class_name: 'gritter-success gritter-light'
});
$("#modal-table").modal("hide");