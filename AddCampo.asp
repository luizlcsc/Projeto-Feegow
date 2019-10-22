<!--#include file="connect.asp"--><%
response.Charset="utf-8"
'on error resume next
TipoCampoID=request.QueryString("I")
set pForm=db.execute("select * from buiForms where id = '"&request.QueryString("F")&"'")
if not pForm.EOF then
	NomeTabela="_"&pForm("id")
	TipoTitulo=pForm("TipoTitulo")
end if
if request.QueryString("A")="X" then
	set pNomeX=db.execute("select * from buiCamposForms where id = '"&request.QueryString("I")&"'")
	if not pNomeX.EOF then
		if pNomeX("TipoCampoID")=1 or pNomeX("TipoCampoID")=2 or pNomeX("TipoCampoID")=3 or pNomeX("TipoCampoID")=4 or pNomeX("TipoCampoID")=5 or pNomeX("TipoCampoID")=6 or pNomeX("TipoCampoID")=8 or pNomeX("TipoCampoID")=9 then
			db_execute("ALTER TABLE `"&NomeTabela&"` DROP COLUMN `"&pNomeX("id")&"`")
		end if
	end if
	db_execute("delete from buiCamposForms where id="&request.QueryString("I"))
	db_execute("delete from buiOpcoesCampos where CampoID="&request.QueryString("I"))
end if
if request.QueryString("A")="A" then
	numeroNovoCampo=0
	while numeroNovoCampo<>"Feito"
		numeroNovoCampo=numeroNovoCampo+1
		set vca=db.execute("select * from buiCamposForms where NomeCampo like 'Campo_"&numeroNovoCampo&"' and FormID like '"&request.QueryString("F")&"'")
		if vca.EOF then
			NomeCampo="Campo_"&numeroNovoCampo
			numeroNovoCampo="Feito"
		end if
	wend

	set pultim=db.execute("select * from buiCamposForms where FormID like '"&request.QueryString("F")&"' order by Ordem desc")
	if pultim.eof then
		UltOrdem=1
		Tamanho=1
	else
		UltOrdem=pultim("Ordem")+1
		Tamanho=pultim("Tamanho")
	end if
	db_execute("insert into buiCamposForms (TipoCampoID, NomeCampo, RotuloCampo, FormID, Ordem, Tamanho, Largura, MaxCarac, pTop, pLeft) values ('"&request.QueryString("I")&"', '"&NomeCampo&"', 'Texto', '"&request.QueryString("F")&"', '"&UltOrdem&"', '"&Tamanho&"', 20, '"&insertMaxCarac&"', '"&request.QueryString("pTop")&"', 55)")
	set pult=db.execute("select * from buiCamposForms where FormID like '"&request.QueryString("F")&"' order by Ordem desc")
	informaID=pult("id")

	if TipoCampoID="1" then
		sqlAlter="ALTER TABLE "&NomeTabela&" ADD COLUMN `"&informaID&"` VARCHAR(70) NULL"
		insertMaxCarac=70
	elseif TipoCampoID="2" then
		sqlAlter="ALTER TABLE "&NomeTabela&" ADD COLUMN `"&informaID&"` VARCHAR(10) NULL"
		insertMaxCarac=10
	elseif TipoCampoID="3" then
		sqlAlter="ALTER TABLE "&NomeTabela&" ADD COLUMN `"&informaID&"` VARCHAR(255) NULL"
		insertMaxCarac=255
	elseif TipoCampoID="12" then
		sqlAlter="ALTER TABLE "&NomeTabela&" ADD COLUMN `"&informaID&"` VARCHAR(255) NULL"
		insertMaxCarac=1000
	elseif TipoCampoID="4" then
		sqlAlter="ALTER TABLE "&NomeTabela&" ADD COLUMN `"&informaID&"` VARCHAR(500) NULL"
		insertMaxCarac=500
	elseif TipoCampoID="5" or TipoCampoID="6" then
		sqlAlter="ALTER TABLE "&NomeTabela&" ADD COLUMN `"&informaID&"` VARCHAR(25) NULL"
		insertMaxCarac=25
	elseif TipoCampoID="8" or TipoCampoID="9" then
		sqlAlter="ALTER TABLE "&NomeTabela&" ADD COLUMN `"&informaID&"` TEXT NULL"
		insertMaxCarac=""
	elseif TipoCampoID="10" then
		Checado=""
	end if

	db_execute("update buiCamposForms set MaxCarac='"&insertMaxCarac&"' where id="&informaID)

	if sqlAlter<>"" then
		db_execute(sqlAlter)
	end if
end if
%><div id="folha" class="demo">
<%
set pFor=db.execute("select * from buiCamposForms where FormID like '"&request.QueryString("F")&"' order by Ordem, id")
while not pFor.EOF
	Tamanho = pFor("Tamanho")
	AlturaLi=60
	if Tamanho=1 then
		LarguraLi="100%"
	elseif Tamanho=2 then
		LarguraLi="50%"
	elseif Tamanho=3 then
		LarguraLi="75%"
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
<div class="campos" onmouseup="graPos(this.id);" id="<%=pFor("id")%>" style="width:<%=LarguraLi%>; min-height:40px; top:<%=pFor("pTop")%>px; left:<%=pFor("pLeft")%>px;<%
if pFor("TipoCampoID")=11 then
	if isNumeric(pFor("MaxCarac")) then
		response.Write("height:"&pFor("MaxCarac")&"px")
	else
		response.Write("height:250px")
	end if
end if%>">
  <span style="position:absolute; right:0; top:0;">
	<img src="newImages/formEdit.png" width="20" height="20" onclick="editaCampo(<%=pFor("id")%>, 0, '<%=request.QueryString("F")%>');" style="cursor:pointer" />
  	<img src="newImages/formDelete.png" width="20" height="20" onclick="if(confirm('Tem certeza de que deseja excluir este campo e todos os seus registros?')){criaCampo(<%=pFor("id")%>, 0, 'X', '<%=request.QueryString("F")%>')}" style="cursor:pointer" />
  </span>
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
    <div class="form-group"><input type="text" value="<%=pFor("ValorPadrao")%>" class="form-control" size="<%=pFor("Largura")%>" maxlength="<%=pFor("MaxCarac")%>" readonly="readonly" placeholder="<%=pFor("Texto")%>"></div>
    <%
	elseif pFor("TipoCampoID")=2 then
	%>
    <div class="form-group"><%= quickField("datepicker", "", "", "", pFor("ValorPadrao"), "", "", " readonly") %>
     <%=pFor("Texto")%></div>
	<%
	elseif pFor("TipoCampoID")=3 then
		if Tamanho=1 then
			alturaFoto = 500
			larguraFoto = 720
		elseif Tamanho=2 then
			alturaFoto = 375
			larguraFoto = 540
		elseif Tamanho=3 then
			alturaFoto = 250
			larguraFoto = 360
		elseif Tamanho=4 then
			alturaFoto = 125
			larguraFoto = 180
		end if
		%>
        <div style="width:<%= larguraFoto %>px; height:<%= alturaFoto %>px; text-align:center; vertical-align:middle; border:1px dashed #099">
		<%
		if pFor("ValorPadrao")<>"" and not isnull(pFor("ValorPadrao")) then
			%>
				<img align="absmiddle" src="uploads/<%=pFor("ValorPadrao")%>" style="max-width:<%= larguraFoto %>px; max-height:<%= alturaFoto %>px; width:auto; height: auto;" border="1" />
			<%
		end if
		%>
		</div>
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
			%>
			<label><input class="ace" type="checkbox" readonly="readonly" name="campo_<%=pFor("id")%>" value="<%=pOptions("Valor")%>"<%if pOptions("Selecionado")="S" then
				%> checked="checked"<%
			end if%>><span class="lbl"> <%=pOptions("Nome")%></span>&nbsp;&nbsp;</label>&nbsp;
			<%
			response.Write(fechaDiv)
		pOptions.movenext
		wend
		pOptions.close
		set pOptions=nothing
	'RA�DIO
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
			response.Write(abreDiv)
			%><label><input type="radio" class="ace" name="<%=pFor("NomeCampo")%>" value="<%=pOp("Valor")%>" readonly="readonly"<%if pOp("Selecionado")="S" then
				%> checked="checked"<%
			end if%>><span class="lbl"> <%=pOp("Nome")%></span>&nbsp;&nbsp;</label>
			<%
			response.Write(fechaDiv)
		pOp.moveNext
		wend
		pOp.close
		set pOp=nothing
	elseif pFor("TipoCampoID")=6 then
	%>
    <div class="form-group">
    <select name="<%=pFor("NomeCampo")%>" class="form-control" align="absmiddle" disabled="disabled">
    	<%
		set pOp=db.execute("select * from buiOpcoesCampos where CampoID="&pFor("id")&" order by id")
		while not pOp.EOF
		%><option value="<%=pOp("Valor")%>"<%if pOp("Selecionado")="S" then
				%> selected="selected"<%
			end if%>><%=pOp("Nome")%></option>
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
	<input type="button" class="btn btn-primary" value="<%=pFor("RotuloCampo")%>" readonly="readonly">
	<%
	elseif pFor("TipoCampoID")=8 then
	%>
    <textarea class="form-control" name="<%=pFor("NomeCampo")%>" cols="<%=pFor("Largura")%>" disabled="disabled" rows="<%=Linhas%>"><%=pFor("ValorPadrao")%></textarea>
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
				%><td><input type="text" class="form-control" readonly="readonly" style="<%=estiloTH%>" value="<%
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
	elseif pFor("TipoCampoID")=12 then
		%>
		<iframe width="820" src="modeloaudiometria.asp" frameborder="0" height="580"></iframe>
		<%
	end if
	%>
</div>
<%
pFor.moveNext
wend
pFor.close
set pFor=nothing
%>
</div><%
if request.QueryString("A")="A" then
	%><--<%=ccur(informaID)+1000000000%>--><%
end if
%>