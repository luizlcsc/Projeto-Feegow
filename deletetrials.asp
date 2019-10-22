<!--#include file="connectCentral.asp"-->
<table border="1">
<%
set l = dbc.execute("select licencas.*, (select count(*) from licencaslogins where LicencaID=licencas.id) as total, (select DataHora from licencaslogins where LicencaID=licencas.id order by id desc limit 1) as UltimoAcesso, licencasusuarios.* from licencas join licencasusuarios on licencasusuarios.`LicencaID`=licencas.`id` where DATE(licencas.DataHora)<DATE_ADD(DATE(NOW()), INTERVAL -40 DAY) and Cliente=0 order by UltimoAcesso")
while not l.eof
	if ccur(l("total"))<20 then
	'	dbc.execute("update licencas set Excluido=DATE(NOW()) where id="&l("LicencaID"))
		'cor="#EAFFF4"
		strDrop = strDrop&"drop database if exists `clinic"&l("LicencaID")&"`;<br />"
		%>
		<tr bgcolor="<%=cor%>">
			<td><a href="allalter.asp?I=<%=l("LicencaID")%>" target="_blank"><%=l("LicencaID")%>  - <%=muda%></a></td>
			<td><%=l("NomeContato")%></td>
			<td><%=l("NomeContato")%></td>
			<td><%=l("Telefone")%></td>
		  <td><%=l("Celular")%></td>
		  <td><%=l("Email")%></td>
			<td><%=l("DataHora")%></td>
			<td><%=l("total")%></td>
			<td><%=l("UltimoAcesso")%>
		</tr>
		<%
	end if
l.movenext
wend
l.close
set l=nothing
%>
</table>
<br />
<%=strDrop%>