<!--#include file="connectCentral.asp"-->
<%
response.Charset="utf-8"

response.Buffer
%>
<div class="table-responsive">
<table width="100%" id="table-trials" class="table table-striped table-bordered table-hover">
<thead>
<tr>
	<th>Licen&ccedil;a</th>
	<th>Empresa</th>
	<th>Contato</th>
	<th>Telefone</th>
	<th>Celular</th>
	<th>E-mail</th>
    <th>Data</th>
    <th>Status</th>
    <th>&Uacute;ltimo Acesso</th>
</tr>
</thead>
<tbody>
<%
if request.QueryString("C")="S" then
else
	set l = dbc.execute("select licencas.*, (select DataHora from licencaslogins where LicencaID=licencas.id order by id desc limit 1) as UltimoAcesso, licencasusuarios.* from licencas join licencasusuarios on licencasusuarios.`LicencaID`=licencas.`id` and isnull(Excluido) and Cliente=0 and (Telefone like '(1%' or Celular like '(1%') order by licencas.DataHora desc")
end if
while not l.eof
	response.Flush()
	'cor="#EAFFF4"
	%>
	<tr bgcolor="<%=cor%>">
    	<td><a href="allalter.asp?I=<%=l("LicencaID")%>" target="_blank"><%=l("LicencaID")%>  - <%=muda%></a></td>
    	<td><%=l("NomeContato")%></td>
    	<td><%=l("NomeContato")%></td>
    	<td><%=l("Telefone")%></td>
   	    <td><%=l("Celular")%></td>
   	    <td><%=l("Email")%></td>
        <td><%=l("DataHora")%></td>
        <td><%
		if l("Cliente")=0 then
			%><font color="#FF0000">TESTE</font><%
		else
			%>
			CLIENTE
			<%
		end if%></td>
        <td><%=l("UltimoAcesso")%></td>
    </tr>
	<%
l.movenext
wend
l.close
set l=nothing
%>
</tbody>
</table>
</div>

<script>
jQuery(function($) {
	var oTable1 = $('#table-trials').dataTable( {
	"aoColumns": [
	  null,null,null,null,null,null,null,null,null,null
	] } );
});
</script>