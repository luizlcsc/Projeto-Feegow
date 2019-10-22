<!--#include file="connect.asp"-->
<%
Tipo = ref("Tipo")
Rotulo = ref("Rotulo")
I = ref("I")
Action = ref("Action")
FormID = req("FormID")
txtUpdate = ref("txtUpdate")

if Action="Add" then
	db_execute("insert into buiformsestilo (ParametroID, Elemento, FormID) values ("&I&", '"&Tipo&"', "&FormID&")")
elseif Action="Remove" then
	db_execute("delete from buiformsestilo where id="&I)
	refLay = "refLay();"
elseif Action="Update" then
	db_execute("update buiformsestilo set Valor='"&txtUpdate&"' where id="&I)
	refLay = "refLay();"
elseif Action="LaL" then
	if txtUpdate="true" then
		txtUpdate="S"
	else
		txtUpdate=""
	end if
	sql = "update buiforms set LadoALado='"&txtUpdate&"' where id="&FormID
	db_execute(sql)
	refLay = "refLay();"
end if
%>
<!--#include file="formEstiloTipo.asp"-->
<script>
<%=refLay%>
<!--#include file="jQueryFunctions.asp"-->
</script>