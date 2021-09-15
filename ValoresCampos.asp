<!--#include file="connect.asp"-->
<%
Nome  = replace(ref("Nome"),"'","''")
Valor = replace(ref("Valor"),"'","''")
I=replace(req("I"),"'","''")
CI=replace(req("CI"),"'","''")
if req("A")="X" then
	db_execute("delete from buiOpcoesCampos where id = '"&CI&"'")
elseif req("A")="V" then
	db_execute("update buiOpcoesCampos set Valor='"&Valor&"' where id = '"&CI&"'")
elseif req("A")="C" then
	set pTipoCampo=db.execute("select * from buiCamposForms where id="&I)
	if pTipoCampo("TipoCampoID")=5 or pTipoCampo("TipoCampoID")=6 then
		db_execute("update buiOpcoesCampos set Selecionado='' where CampoID="&I)
	end if
	if req("Check")="true" then
		Selecionado="S"
	else
		Selecionado=""
	end if
	db_execute("update buiOpcoesCampos set Selecionado='"&Selecionado&"' where id = '"&CI&"'")
elseif req("A")="N" then
	db_execute("update buiOpcoesCampos set Nome='"&Nome&"' where id = '"&CI&"'")
elseif req("A")="A" then
	db_execute("insert into buiOpcoesCampos (CampoID, Nome, Valor, Selecionado) values ('"&I&"', '', '', '')")
end if
%>
<hr />
<table width="100%" class="table table-striped table-hover table-condensed">
<thead>
  <tr>
    <th width="1%">&nbsp;</th>
    <th width="29%">VALOR</th>
    <th width="70%">NOME</th>
  <th width="2%"></th>
  </tr>
</thead>
  <%
set pCampo=db.execute("select * from buiCamposForms where id = '"&I&"'")
if not pCampo.EOF then
	TipoCampoID=pCampo("TipoCampoID")
end if
set pItens=db.execute("select * from buiOpcoesCampos where CampoID like '"&I&"' order by id")
while not pItens.EOF
%><tr>
    <td>
	<input type="<%
	if TipoCampoID=4 then
		%>checkbox<%
	else
		%>radio<%
	end if%>" name="CheckOpcao" onChange="updateOption('C', <%=I%>, <%=pItens("id")%>);" id="CheckOpcao<%=pItens("id")%>"<%if pItens("Selecionado")="S" then%> checked="checked"<%end if%> />
	
	</td>
	<td><input type="text" class="form-control" name="ValorOpcao<%=pItens("id")%>" id="ValorOpcao<%=pItens("id")%>" value="<%=pItens("Valor")%>" onBlur="updateOption('V', <%=I%>, <%=pItens("id")%>);"></td>
    <td><input type="text" class="form-control" name="NomeOpcao<%=pItens("id")%>" id="NomeOpcao<%=pItens("id")%>" value="<%=pItens("Nome")%>" onBlur="updateOption('N', <%=I%>, <%=pItens("id")%>);"></td>
  <td><button type="button" class="btn btn-sm btn-danger" onClick="updateOption('X', <%=I%>, <%=pItens("id")%>);"><i class="far fa-remove"></i></button></tr>
<%
pItens.moveNext
wend
pItens.close
set pItens=nothing
%></table>
