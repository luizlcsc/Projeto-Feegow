<!--#include file="connect.asp"-->
<%
LinhaID = req("L")

set l = db.execute("select distinct ifnull(Agrupamento, 'Outros') Agrupamento from cliniccentral.dre_temp where sysUser="& session("User") &" and LinhaID="& LinhaID &" ORDER BY Agrupamento")
while not l.eof
	Agrupamento = l("Agrupamento")
	if Agrupamento="Outros" then
		sqlAgrupamento = " is null "
	else
		sqlAgrupamento = "='"& Agrupamento &"'"
	end if
	%>
	<tr class='tmp<%= LinhaID %>'>
		<td class='pl50'><%= l("Agrupamento") %></td>
		<%
		m = 1
		while m<13
			set val = db.execute("select sum(Valor) Valor from cliniccentral.dre_temp where month(Data)="& m &" and sysUser="& session("User") &" and LinhaID="& LinhaID &" and Agrupamento "& sqlAgrupamento)
			Valor = fn(val("Valor"))
			%>
			<td class="text-right col-show-more" onclick="det(<%= LinhaID %>, <%=m%>, `<%= Agrupamento %>`)">
				<%= Valor %>
			</td>
			<%
			m = m+1
		wend
	%>
	</tr>
	<%
l.movenext
wend
l.close
set l = nothing
%>