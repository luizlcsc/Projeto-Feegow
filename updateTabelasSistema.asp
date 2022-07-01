<%
if req("RefazSistema")="S" then
	on error resume next
	set t=Modelo.execute("select table_comment, table_name from information_schema.tables where TABLE_SCHEMA='"&session("MDatabase")&"' and table_comment='sistema'")
	while not t.eof
		Destino.execute("drop table "&t("table_name"))
		set CodigoCreate = dbc.execute("select * from comparar where tabela like '"&t("table_name")&"' and MD='M'")
		if not CodigoCreate.EOF then
			Destino.execute(CodigoCreate("Colunas"))

			set dados = Modelo.execute("select * from "&t("table_name"))
			while not dados.eof
				destinoColunas = "id"
				destinoValores = dados("id")
				spl = split(CodigoCreate("estrutura"), "|")
				for i=0 to ubound(spl)
					if spl(i)<>"" then
						spl2 = split(spl(i), ",")
						if isnull(dados(""&spl2(0)&"")) then
							valor = "NULL"
						else
							valor = "'"&replace(dados(""&spl2(0)&""), "'", "''")&"'"
						end if
						destinoColunas = destinoColunas&", `"&spl2(0)&"`"
						destinoValores = destinoValores&", "&valor
					end if
				next
				sqlInsert = "insert into "&t("table_name")&" ("&destinoColunas&") values ("&destinoValores&")"
				response.Write(sqlInsert&"<br>")
				Destino.execute(sqlInsert)
			dados.movenext
			wend
			dados.close
			set dados=nothing
		end if
		
	t.movenext
	wend
	t.close
	set t=nothing
	
	response.Redirect("updateComparaTabelas.asp")
end if
%>