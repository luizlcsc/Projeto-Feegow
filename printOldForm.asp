<input type="hidden" name="FormID" id="FormID" value="<%=formID%>" />
<input type="hidden" name="ModeloID" id="ModeloID" value="<%=ModeloID%>" />
<div id="folha">
<%
if FormID<>"N" then
	set preen = db.execute("select * from `_"&ModeloID&"` where id="&FormID)
	if not preen.eof then
		preenchido = "S"
	end if
end if

set pac = db.execute("select p.*, ec.EstadoCivil, s.NomeSexo as Sexo, g.GrauInstrucao, o.Origem from pacientes as p left join estadocivil as ec on ec.id=p.EstadoCivil left join sexo as s on s.id=p.Sexo left join grauinstrucao as g on g.id=p.GrauInstrucao left join origens as o on o.id=p.Origem where p.id="&PacienteID)
set pFor=db.execute("select * from buiCamposForms where FormID like '"&req("ModeloID")&"' order by Ordem, id")
while not pFor.EOF
	if preenchido="S" then
		valor = preen(""&pFor("id")&"")
	else
		valor = pFor("ValorPadrao")
	end if
	valor = trim(valor&" ")
	
	valor = replace(valor, "[Data.DDMMAAAA]", date())
	valor = replace(valor, "[Data.Extenso]", formatdatetime(date(),1) )
	valor = replace(valor, "[Sistema.Hora]", formatdatetime(date(),1) )
	valor = replaceTags(valor, PacienteID, session("UserID"), session("UnidadeID"))
		
	if instr(valor, "[Paciente.")>0 then
		set rec = db.execute("select * from cliniccentral.sys_resourcesfields where resourceID=1")
		while not rec.eof
			Coluna = rec("columnName")
			Val = pac(""&Coluna&"")
			select case Coluna
				case "NomePaciente"
					Tag = "Nome"
				case "CorPele"
					Tag = "Cor"
					set cor = db.execute("select * from corpele where id="&pac("CorPele"))
					if not cor.eof then
						val = cor("NomeCorPele")
					else
						val = ""
					end if
				case else
					Tag = Coluna
			end select
			valor = replace(trim(valor&" "), "[Paciente."&Tag&"]", trim(Val&" "))
		rec.movenext
		wend
		rec.close
		set rec=nothing

		valor = replace(valor, "[Paciente.Idade]", idade(pac("Nascimento")))
		valor = replace(valor, "[Paciente.Prontuario]", pac("id"))
		set conv = db.execute("select pc.*, c.NomeConvenio from pacientesconvenios as pc left join convenios as c on c.id=pc.ConvenioID where PacienteID="&PacienteID&" and not isnull(ConvenioID)")
		if not conv.eof then
			valor = replace(valor, "[Paciente.Convenio]", conv("NomeConvenio"))
			valor = replace(valor, "[Paciente.Matricula]", conv("Matricula"))
			valor = replace(valor, "[Paciente.Validade]", conv("Validade"))
		end if
	end if
	

	AlturaLi=60
	if pFor("Tamanho")=1 then
		LarguraLi="90%"
	elseif pFor("Tamanho")=2 then
		LarguraLi="47%"
	elseif pFor("Tamanho")=3 then
		LarguraLi="31%"
	else
		LarguraLi="25%"
	end if
	if pFor("TipoCampoID")=8 then
		if isNull(pFor("MaxCarac")) or not isNumeric(pFor("MaxCarac")) then
			Linhas=2
		else
			Linhas=pFor("MaxCarac")
		end if
		NumeroDivsQuebrado=Linhas/2
		NumeroDivs=cint(NumeroDivsQuebrado)
		if NumeroDivs<NumeroDivsQuebrado then
			NumeroDivs=NumeroDivs+1
		end if
		AlturaLi=AlturaLi*NumeroDivs
	end if
%>
<div class="campos" id="<%=pFor("id")%>" style="width:<%=LarguraLi%>; min-height:40px; top:<%=pFor("pTop")%>px; left:<%=pFor("pLeft")%>px;><%
if pFor("TipoCampoID")=11 then
	if isNumeric(pFor("MaxCarac")) then
		response.Write("height:"&pFor("MaxCarac")&"px")
	else
		response.Write("height:250px")
	end if
end if%>">
	<%
	if TipoTitulo="B" or isNull(TipoTitulo) then
		abreDivTitulo="<div style=""padding-bottom:2px;"">"
		fechaDivTitulo="</div>"
	else
		abreDivTitulo=""
		fechaDivTitulo=""
	end if
	if pFor("TipoCampoID")<>10 then
		response.Write(abreDivTitulo&"<label>"&pFor("RotuloCampo")&"</label>"&fechaDivTitulo)
	end if
	if pFor("TipoCampoID")=1 then
	%>
    <div class="form-group"><input type="text" value="<%=valor%>" class="form-control postvalue" name="campo_<%=pFor("id")%>" size="<%=pFor("Largura")%>" maxlength="<%=pFor("MaxCarac")%>" placeholder="<%=pFor("Texto")%>"></div>
    <%
	elseif pFor("TipoCampoID")=2 then
	%>
    <div class="form-group"><%= quickField("datepicker", "campo_"&pFor("id"), "", "", valor, "postvalue", "", "") %>
     <%=pFor("Texto")%></div>
	<%
	elseif pFor("TipoCampoID")=3 then
		%>
		<img src="uploads/<%=valor%>" width="100%" />
		<%
	'CHECKBOX
	elseif pFor("TipoCampoID")=4 then
		if pFor("Checado")="S" then
			abreDiv="<div>"
			fechaDiv="</div>"
		else
			abreDiv=""
			fechaDiv=""
		end if
		set pOptions=db.execute("select * from buiOpcoesCampos where CampoID="&pFor("id")&" order by id")
		while not pOptions.eof
			response.Write(abreDiv)
			if preenchido="S" then
				if instr(valor, "."&pOptions("id")&".")>0 then
					checado = "checked=""checked"""
				else
					checado = ""
				end if
			else
				if pOptions("Selecionado")="S" then
					checado = "checked=""checked"""
				else
					checado = ""
				end if
			end if

			%>
			<label><input class="ace postvalue checkbox" title="checkbox-<%=pFor("id")%>" type="checkbox" name="campo_<%=pFor("id")%>" value=".<%=pOptions("id")%>." <%= checado %>><span class="lbl"> <%=pOptions("Nome")%></span>&nbsp;&nbsp;</label>&nbsp;
			<%
			response.Write(fechaDiv)
		pOptions.movenext
		wend
		pOptions.close
		set pOptions=nothing
	'RADIO
	elseif pFor("TipoCampoID")=5 then
		if pFor("Checado")="S" then
			abreDiv="<div>"
			fechaDiv="</div>"
		else
			abreDiv=""
			fechaDiv=""
		end if
		set pOp=db.execute("select * from buiOpcoesCampos where CampoID="&pFor("id")&" order by id")
		while not pOp.EOF
			if preenchido="S" then
				if valor=cstr(pOp("id")) then
					checado = "checked=""checked"""
				else
					checado = ""
				end if
			else
				if pOp("Selecionado")="S" then
					checado = "checked=""checked"""
				else
					checado = ""
				end if
			end if
			response.Write(abreDiv)
			%><label><input type="radio" class="ace postvalue" name="campo_<%=pFor("id")%>" value="<%=pOp("id")%>" <%=checado%>><span class="lbl"> <%=pOp("Nome")%></span>&nbsp;&nbsp;</label>
			<%
			response.Write(fechaDiv)
		pOp.moveNext
		wend
		pOp.close
		set pOp=nothing
	elseif pFor("TipoCampoID")=6 then
	%>
    <div class="form-group">
    <select name="campo_<%=pFor("id")%>" class="form-control postvalue" align="absmiddle">
    	<%
		set pOp=db.execute("select * from buiOpcoesCampos where CampoID="&pFor("id")&" order by id")
		while not pOp.EOF
			if preenchido="S" then
				if valor=cstr(pOp("id")) then
					checado = "selected=""selected"""
				else
					checado = ""
				end if
			else
				if pOp("Selecionado")="S" then
					checado = "selected=""selected"""
				else
					checado = ""
				end if
			end if
		%><option value="<%=pOp("id")%>"<%=checado%>><%=pOp("Nome")%></option>
        <%
		pOp.moveNext
		wend
		pOp.close
		set pOp=nothing
		%>
    </select></div>
	<%
	elseif pFor("TipoCampoID")=7 then
	%>
	<input type="button" class="btn btn-primary" value="<%=pFor("RotuloCampo")%>">
	<%
	elseif pFor("TipoCampoID")=8 then
		%>
		<%=valor%>
		<%
	'TABELA
	elseif pFor("TipoCampoID")=9 then
		CampoID=pFor("id")
		Texto=pFor("Texto")
		if isNumeric(pFor("Linhas")) and not isNull(pFor("Linhas")) and not isNull(pFor("Colunas")) and isNumeric(pFor("Colunas")) then
			l=pFor("Linhas")
			c=pFor("Colunas")
		else
			l=0
			c=0
		end if
		colunas=c
		linhas=l
		splLinhas=split(trim(Texto&" "),"^|;")
		numeroLinhasSPL=ubound(splLinhas)+1
%>
<table border="0" cellpadding="1" cellspacing="1" bgcolor="#DDE4FF" width="100%">
<%		while linhas>0
			%><tr><%
			while colunas>0
				if linhas=l then
					estiloTH=" background-color:#DDE4FF; font-weight:bold;"
				else
					estiloTH=""
				end if
				%><td><input type="text" class="form-control postvalue" style="<%=estiloTH%>" value="<%
				if linhas<=numeroLinhasSPL then
					splColunas=split(splLinhas(linhas-1),"^|")
					numeroColunasSPL=ubound(splColunas)+1
					if colunas<=numeroColunasSPL then
						response.Write(splColunas(colunas-1))
					end if
				end if
				%>" /></td><%
				colunas=colunas-1
			wend
			if colunas=0 then
				colunas=c
			end if
			%></tr><%
			linhas=linhas-1
		wend
%></table><%
	'TITULO
	elseif pFor("TipoCampoID")=10 then
		%>
		<h2 style="margin:0; padding:0"><%=pFor("RotuloCampo")%></h2>
		<%
		if pFor("Checado")="" or isNull(pFor("Checado")) then
		%>
		<hr />
		<%end if%>
		<%=replace(pFor("Texto")&" ", chr(10), "<br />")%>
		<%
	elseif pFor("TipoCampoID")=11 then
		if pFor("Checado")="B" then
			img="Barras"
		elseif pFor("Checado")="P" then
			img="Pizza"
		else
			img="Linhas"
		end if
		response.Write("<center><img src=""newImages/"&img&".png"" border=0/></center>")
	end if
	%>
</div>
<%
pFor.moveNext
wend
pFor.close
set pFor=nothing
%>
</div>
