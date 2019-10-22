<!--#include file="connect.asp"--><%
CampoID=request.QueryString("I")
set pTexto=db.execute("select * from buiCamposForms where id="&CampoID)
Texto=pTexto("Texto")
if isNumeric(request.QueryString("L")) and isNumeric(request.QueryString("C")) then
	l=ccur(request.QueryString("L"))
	c=ccur(request.QueryString("C"))
else
	l=0
	c=0
end if
colunas=c
linhas=l
%>
<table border="0" cellpadding="1" cellspacing="1" bgcolor="#DDE4FF" width="100%">
<%

splLinhas=split(trim(Texto&" "),"^|;")
numeroLinhasSPL=ubound(splLinhas)+1
while linhas>0
	%><tr><%
	while colunas>0
		if linhas=l then
			estiloTH=" background-color:#DDE4FF; font-weight:bold;"
		else
			estiloTH=""
		end if
		%><td><input type="text" class="form-control" style="<%=estiloTH%>" id="<%=CampoID&"_"&linhas&"_"&colunas%>" value="<%
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

%>
</table>
<%'=Texto%>