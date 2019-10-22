<li id="<%=CampoID%>" class="campo" data-row="<%=pTop%>" style="text-align:left" data-col="<%=pLeft%>" data-sizex="<%=Colunas%>" data-sizey="<%=Linhas%>"><span class="botoes"><% If TipoCampoID=13 Then 
	%><button onClick="menu(<%=CampoID%>)" class="btn btn-xs btn-warning" style="z-index:500; width:17px; margin-top:-20px;"><i class="fa fa-plus"></i></button>&nbsp;<button onClick="editField(<%=CampoID%>)" class="btn btn-xs btn-primary" style="z-index:500; width:17px; margin-top:-20px;"><i class="fa fa-edit"></i></button>&nbsp;<button onClick="removeCampo(<%=CampoID%>, 0)" class="btn btn-xs btn-danger" style="z-index:500; width:17px; margin-top:-20px;"><i class="fa fa-remove"></i></button><% 
else
	%><i class="fa fa-edit blue" onClick="editField(<%=CampoID%>)"></i>&nbsp;&nbsp;&nbsp;<i class="fa fa-remove red" onClick="removeCampo(<%=CampoID%>, <%=GrupoID%>);"></i><%
End If
	%></span><%
	  select case TipoCampoID
	  	case 1'Texto
			'response.Write("["&LadoALado&"]")
			if LadoALado="S" then
				%><table border="0" cellpadding="0" cellspacing="0" width="100%"><tr><td width="1%" class="cel_label" nowrap><label class="campoLabel"><%=RotuloCampo%></label></td><td width="99%" class="cel_input"><input tabindex="<%=Ordem%>" class="campoInput" name="input_<%=CampoID%>" value="<%=ValorPadrao%>" type="text"></td></tr></table><%
			else
				%><label class="campoLabel"><%=RotuloCampo%></label><input tabindex="<%=Ordem%>" name="input_<%=CampoID%>" value="<%=ValorPadrao%>" class="campoInput" type="text"><%
			end if
	  	case 2'Data
			if LadoALado="S" then
				%><table border="0" cellpadding="0" cellspacing="0" width="100%"><tr><td width="1%" class="cel_label" nowrap><label class="campoLabel"><%=RotuloCampo%></label></td><td width="99%" class="cel_input"><div class="input-group"><input name="input_<%=CampoID%>" value="<%=ValorPadrao%>" tabindex="<%=Ordem%>" class="campoInput form-control" type="text"><span class="input-group-addon"><i class="fa fa-calendar bigger-110"></i></span></div></td></tr></table><%
			else
				%><label class="campoLabel"><%=RotuloCampo%></label><div class="input-group"><input tabindex="<%=Ordem%>" class="campoInput form-control" name="input_<%=CampoID%>" value="<%=ValorPadrao%>" type="text"><span class="input-group-addon"><i class="fa fa-calendar bigger-110"></i></span></div><%
			end if
	  	case 3'imagem
				%><label class="campoLabel"><%=RotuloCampo%></label><div class="imagem"></div><div><button type="button" class="btn btn-xs btn-warning btn-20 pull-right"><i class="fa fa-plus"></i></button><%
				%></div><%
	  	case 4'checkbox
			if Checado="S" then
				Separador = "<br /><br />"
			else
				Separador = "&nbsp;&nbsp;"
			end if
			%><label class="campoLabel"><%=RotuloCampo%></label><br /><%
				set checks = db.execute("select * from buiopcoescampos where CampoID="&CampoID)
				while not checks.eof
					%><label style="margin-top:-7px"><input class="ace" name="input_<%=CampoID%>_<%=checks("id")%>"<%if checks("Selecionado")="S" then%> checked<%end if%> value="S" type="checkbox" /><span class="lbl"></span></label> <%=checks("Nome")%><%=Separador%><%
				checks.movenext
				wend
				checks.close
				set checks = nothing
	  	case 5'radio
			if Checado="S" then
				Separador = "<br /><br />"
			else
				Separador = "&nbsp;&nbsp;"
			end if
			%><label class="campoLabel"><%=RotuloCampo%></label><br /><%
				set checks = db.execute("select * from buiopcoescampos where CampoID="&CampoID)
				while not checks.eof
					%><label style="margin-top:-7px"><input class="ace" name="input_<%=CampoID%>"<%if checks("Selecionado")="S" then%> checked<%end if%> type="radio" value="<%=checks("id")%>" /><span class="lbl"></span></label> <%=checks("Nome")%><%=Separador%><%
				checks.movenext
				wend
				checks.close
				set checks = nothing
	  	case 6'select
			if Checado="S" then
				Separador = "<br /><br />"
			else
				Separador = "&nbsp;&nbsp;"
			end if
			%><label class="campoLabel"><%=RotuloCampo%></label><br /><select class="campoInput form-control" name="input_<%=CampoID%>"><%
				set checks = db.execute("select * from buiopcoescampos where CampoID="&CampoID)
				while not checks.eof
					%><option value="<%=checks("id")%>"<% If checks("Selecionado")="S" Then %> selected="selected"<% End If %>><%=checks("Nome")%></option><%
				checks.movenext
				wend
				checks.close
				set checks = nothing
				%></select><%
	  	case 8'textarea
			%><div style="padding-bottom:4px"><label class="campoLabel"><%=RotuloCampo%></label></div><textarea class="campoInput" name="input_<%=CampoID%>" tabindex="<%=Ordem%>"><%=ValorPadrao%></textarea><%
	  	case 9'tabela
			%><label class="campoLabel"><%=RotuloCampo%></label><table class="table table-condensed table-bordered table-hover"><thead><%
			sqlTit = "select * from buitabelastitulos where CampoID="&CampoID
			set pTit = db.execute(sqlTit)
			if pTit.EOF then
				insTit = "insert into buitabelastitulos (CampoID, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20) values ("&CampoID&", 'Título 1', 'Título 2', 'Título 3', 'Título 4', 'Título 5', 'Título 6', 'Título 7', 'Título 8', 'Título 9', 'Título 10', 'Título 11', 'Título 12', 'Título 13', 'Título 14', 'Título 15', 'Título 16', 'Título 17', 'Título 18', 'Título 19', 'Título 20')"
				'response.Write(insTit)
				db_execute(insTit)
				set pTit = db.execute(sqlTit)
			end if

			contaLargura = 0
			while contaLargura<cint(Largura) and contaLargura<20
				contaLargura = contaLargura+1
				%><th><input name="<%=CampoID&"_t"&contaLargura%>" value="<%=pTit("c"&contaLargura)%>" class="tabTit" /></th><%
			wend

			%><th width="1%"><button type="button" onClick="addRow(<%=CampoID%>, 0, 'Add')" class="btn btn-xs btn-primary btn-20"><i class="fa fa-plus"></i></button></th></thead><tbody><%
			
			set pMod = db.execute("select * from buitabelasmodelos where CampoID="&CampoID)
			while not pMod.EOF
				%><tr><%
				contaLargura = 0
				while contaLargura<cint(Largura) and contaLargura<20
					contaLargura = contaLargura+1
					%><td><input class="campoInput form-control" name="<%=CampoID&"_t"&contaLargura%>" value="<%=pMod("c"&contaLargura)%>" /></td><%
				wend
				%><td><button type="button" class="btn btn-xs btn-danger btn-20" onClick="addRow(<%=pMod("id")%>, 0, 'Remove')"><i class="fa fa-remove"></i></button></td></tr><%
			pMod.movenext
			wend
			pMod.close
			set pMod = nothing
			%></tbody></table><%
		case 10
			%><h1><%=RotuloCampo%></h1><%
			if Checado="" then response.Write("<hr>") end if
			response.Write(Texto)
	  end select
	  %></li>