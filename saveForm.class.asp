<%
function newForm(modID, pacID)
	db_execute("insert into `buiformspreenchidos` (ModeloID, PacienteID, sysUser) values ("&modID&", "&pacID&", "&session("User")&")")
	set pult = db.execute("select id from `buiformspreenchidos` order by id desc limit 1")
	newForm = pult("id")
end if
%>