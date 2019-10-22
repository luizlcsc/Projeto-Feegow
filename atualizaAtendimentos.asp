<%
if not isnull(reg("idBarra")) then
	idBarra = reg("idBarra")
	set v = db.execute("select pd.id, pd.data, pd.usuario, prof.id ProfissionalID, su.id sysUser from t_pacientesevolucoes_barra1312 pd left join pacientes p on p.idbarra=pd.paciente left join buiformspreenchidos fc on p.idbarra=pd.paciente and fc.DataHora=pd.`data` left join profissionais prof on prof.Barra=pd.usuario left join sys_users su on su.idInTable=prof.id and `Table`='profissionais' where paciente="&idBarra&" and isnull(fc.id)")
	while not v.eof


		Set objWinHttp = Server.CreateObject("WinHttp.WinHttpRequest.5.1")
		objWinHttp.Open "GET", "http://localhost/weegow/feegowclinic/RTFtoHTML.php?banco="&session("banco")&"&tabela=t_pacientesevolucoes_barra1312&coluna=texto&id="&v("id")
		objWinHttp.Send
		strHTML = objWinHttp.ResponseText
		Set objWinHttp = Nothing
		Valor = trim(Valor)
		Valor = replace(strHTML, chr(10), "<br>")

'		db_execute("update `_"&ModeloID&"` set `"&pFor("id")&"`='"&rep(Valor)&"' where id="&FormID)

		db_execute("insert into buiformspreenchidos (ModeloID, PacienteID, DataHora, sysUser) values (16, "&PacienteID&", "&mydatetime(v("Data"))&", "&treatvalnull(v("sysUser"))&")")
		set pult = db.execute("select id from buiformspreenchidos where PacienteID="&PacienteID&" order by id desc limit 1")
		db_execute("insert into _16 (id, PacienteID, DataHora, sysUser, `39`) values ("&pult("id")&", "&PacienteID&", "&mydatetime(v("data"))&", "&treatvalnull(v("sysUser"))&", '"&rep(Valor)&"')")
		%><%= v("id") %>|<%
	v.movenext
	wend
	v.close
	set v=nothing
end if

if reg("id")<140017 and 1=2 then
	idBangu = reg("id")
	set v = db.execute("select pd.id, pd.data, pd.usuario, prof.id ProfissionalID, su.id sysUser from t_pacientesevolucoes_bangu1312 pd left join pacientes p on p.id=pd.paciente left join buiformspreenchidos fc on p.id=pd.paciente and fc.DataHora=pd.`data` left join profissionais prof on prof.Bangu=pd.usuario left join sys_users su on su.idInTable=prof.id and `Table`='profissionais' where paciente="&idBangu&" and isnull(fc.id)")
	while not v.eof


		Set objWinHttp = Server.CreateObject("WinHttp.WinHttpRequest.5.1")
		objWinHttp.Open "GET", "http://localhost/weegow/feegowclinic/RTFtoHTML.php?banco="&session("banco")&"&tabela=t_pacientesevolucoes_bangu1312&coluna=texto&id="&v("id")
		objWinHttp.Send
		strHTML = objWinHttp.ResponseText
		Set objWinHttp = Nothing
		Valor = trim(Valor)
		Valor = replace(strHTML, chr(10), "<br>")

'		db_execute("update `_"&ModeloID&"` set `"&pFor("id")&"`='"&rep(Valor)&"' where id="&FormID)

		db_execute("insert into buiformspreenchidos (ModeloID, PacienteID, DataHora, sysUser) values (16, "&PacienteID&", "&mydatetime(v("Data"))&", "&treatvalnull(v("sysUser"))&")")
		set pult = db.execute("select id from buiformspreenchidos where PacienteID="&PacienteID&" order by id desc limit 1")
		db_execute("insert into _16 (id, PacienteID, DataHora, sysUser, `39`) values ("&pult("id")&", "&PacienteID&", "&mydatetime(v("data"))&", "&treatvalnull(v("sysUser"))&", '"&rep(Valor)&"')")
		%><%= v("id") %>|<%
	v.movenext
	wend
	v.close
	set v=nothing
end if
%>
