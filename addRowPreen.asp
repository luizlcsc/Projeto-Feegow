<!--#include file="connect.asp"-->
<%
CampoID = req("CampoID")
ModeloID = req("ModeloID")
Acao = req("Acao")'0=remove, 1=add
FormPreenID = req("FormPreenID")
ValID = req("ValID")
PacienteID = req("PacienteID")

if FormPreenID="N" then
	FormPreenID = newForm(ModeloID, PacienteID)
end if

if Acao = "1" then
	db_execute("insert into buitabelasvalores (CampoID, FormPreenchidoID) values ("&CampoID&", "&FormPreenID&")")
elseif Acao="0" then
	db_execute("delete from buitabelasvalores where id="&ValID)
end if

set pCampo = db.execute("select * from buicamposforms where id="&CampoID)
if not pCampo.EOF then
	if isnumeric(pCampo("Largura")) and not isnull(pCampo("Largura")) then
		Largura = pCampo("Largura")
	else
		Largura = 5
	end if
else
	Largura = 5
end if

set pMod = db.execute("select * from buitabelasvalores where CampoID="&CampoID&" and FormPreenchidoID="&FormPreenID)
while not pMod.EOF
	%><tr><%
	contaLargura = 0
	while contaLargura<cint(Largura) and contaLargura<20
		contaLargura = contaLargura+1
		%><td><input class="campoInput form-control trow" onchange="saveTabVal('t_<%=pMod("id")&"_"&contaLargura%>', $(this).val())" data-campoid="<%=CampoID%>" name="t_<%=pMod("id")&"_"&contaLargura%>" value="<%=pMod("c"&contaLargura)%>" /></td><%
	wend
	%><td><button type="button" class="btn btn-xs btn-danger btn-20" onClick="addRowPreen(<%=CampoID%>, 0, <%=pMod("id")%>)"><i class="far fa-remove"></i></button></td></tr><%
pMod.movenext
wend
pMod.close
set pMod = nothing
%>