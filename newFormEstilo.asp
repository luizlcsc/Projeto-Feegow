<style>
.btn-grupo {
	z-index:500;
	width:17px;
	margin-top:-20px;
}
.gs-w {
	<%
	prefixo = "caixa"
	set cssForm = db.execute("select p.*, e.Valor from buiformsparametros p left join buiformsestilo e on (p.id=e.ParametroID and e.FormID="&I&" and e.Elemento='"&prefixo&"')")
	while not cssForm.EOF
		if isnull(cssForm("Valor")) then
		    if instr(cssForm("Parametro"),"border")<=0 then
			    Valor = cssForm("ValorPadrao-"&prefixo)
            else
                Valor = ""
            end if
		else
			Valor = cssForm("Valor")
		end if
		%>
		<%=cssForm("Parametro")%>:<%=Valor%>!important;
		<%
	cssForm.movenext
	wend
	cssForm.close
	set cssForm=nothing
	%>
}
.campoInput {
	<%
	prefixo = "input"
	set cssForm = db.execute("select p.*, e.Valor from buiformsparametros p left join buiformsestilo e on (p.id=e.ParametroID and e.FormID="&I&" and e.Elemento='"&prefixo&"')")
	while not cssForm.EOF
		if isnull(cssForm("Valor")) then
			Valor = cssForm("ValorPadrao-"&prefixo)
		else
			Valor = cssForm("Valor")
		end if
		if cssForm("Parametro")="height" then
			alturaNotMemo = valor
		else
			%>
			<%=cssForm("Parametro")%>:<%=Valor%>!important;
			<%
		end if
	cssForm.movenext
	wend
	cssForm.close
	set cssForm=nothing
	%>
	width:100%;
}
input.campoInput, select.campoInput {
	height:<%=alturaNotMemo%>;
}
.campoLabel {
	<%
	prefixo = "label"
	set cssForm = db.execute("select p.*, e.Valor from buiformsparametros p left join buiformsestilo e on (p.id=e.ParametroID and e.FormID="&I&" and e.Elemento='"&prefixo&"')")
	while not cssForm.EOF
		if isnull(cssForm("Valor")) then
			Valor = cssForm("ValorPadrao-"&prefixo)
		else
			Valor = cssForm("Valor")
		end if
		%>
		<%=cssForm("Parametro")%>:<%=Valor%>!important;
		<%
	cssForm.movenext
	wend
	cssForm.close
	set cssForm=nothing
	%>
}
.caixaGrupo {
	<%
	prefixo = "caixaGrupo"
	set cssForm = db.execute("select p.*, e.Valor from buiformsparametros p left join buiformsestilo e on (p.id=e.ParametroID and e.FormID="&I&" and e.Elemento='"&prefixo&"')")
	while not cssForm.EOF
		if isnull(cssForm("Valor")) then
			Valor = cssForm("ValorPadrao-"&prefixo)
		else
			Valor = cssForm("Valor")
		end if
		%>
		<%=cssForm("Parametro")%>:<%=Valor%>!important;
		<%
	cssForm.movenext
	wend
	cssForm.close
	set cssForm=nothing
	%>
}
.labelGrupo {
	<%
	prefixo = "labelGrupo"
	set cssForm = db.execute("select p.*, e.Valor from buiformsparametros p left join buiformsestilo e on (p.id=e.ParametroID and e.FormID="&I&" and e.Elemento='"&prefixo&"')")
	while not cssForm.EOF
		if isnull(cssForm("Valor")) then
			Valor = cssForm("ValorPadrao-"&prefixo)
		else
			Valor = cssForm("Valor")
		end if
		%>
		<%=cssForm("Parametro")%>:<%=Valor%>!important;
		<%
	cssForm.movenext
	wend
	cssForm.close
	set cssForm=nothing
	%>
}
.botoes{
	display:none;
	position:absolute;
	right:0; top:0;
	display:none;
}
.campo:hover .botoes, .caixaGrupo:hover .botoes {
	display:block;
}
.valor {
	background-color:#FFC;
	width:30px;
}
div.campoInput, memorando{
    height: -moz-calc(100% - 30px)!important;  
    height: -webkit-calc(100% - 30px)!important;     
    height: calc(100% - 30px)!important;
	width:100%;
	border:1px solid #000;
	resize:none;
	}
</style>
