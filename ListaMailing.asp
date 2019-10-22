<!--#include file="connect.asp"-->
<table class="table table-striped table-bordered" width="100%">
<thead>
	<tr>
    	<th>Prontu&aacute;rio</th>
    	<th>Nome</th>
        <th>Telefone 1</th>
        <th>Telefone 2</th>
        <th>Celular 1</th>
        <th>Celular 2</th>
        <th>E-mail 1</th>
        <th>E-mail 2</th>
    </tr>
</thead>
<tbody>
<%
set p = db.execute("select id, NomePaciente, Tel1, Tel2, Cel1, Cel2, Email1, Email2  from pacientes where sysActive=1 order by NomePaciente")
while not p.eof
	%>
	<tr>
    	<td nowrap><%=p("id")%></td>
    	<td nowrap><%=p("NomePaciente")%></td>
        <td nowrap><%=p("Tel1")%></td>
        <td nowrap><%=p("Tel2")%></td>
        <td nowrap><%=p("Cel1")%></td>
        <td nowrap><%=p("Cel2")%></td>
        <td nowrap><%=p("Email1")%></td>
        <td nowrap><%=p("Email2")%></td>
    </tr>
	<%
p.movenext
wend
p.close
set p=nothing
%>
</tbody>
</table>