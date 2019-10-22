<!--#include file="connect.asp"-->

<%
set rsConta = db.Execute("Select COUNT(id) as TOTAL from pacientes where Sexo=1")
set rsContaf = db.Execute("Select COUNT(id) as TOTALf from pacientes where Sexo=2")
Total=ccur(rsConta("TOTAL"))
Totalf=ccur(rsContaf("TOTALf"))

if request.QueryString("Lista")="" then%>
<div class="clearfix form-actions">
	<div class="col-md-6">
	    Sexo masculino: <%=Total%> paciente(s).
    	<input name="button" type="button" class="btn btn-success btn-sm" onclick="location.href='?P=<%=request.QueryString("TipoRel")%>&Sexo=1&Lista=Sim&Pers=1';" value="Visualizar" />
    </div>
	<div class="col-md-6">
		Sexo feminino: <%=Totalf%> paciente(s).
		<input name="button" type="button" class="btn btn-success btn-sm" onclick="location.href='?P=<%=request.QueryString("TipoRel")%>&Sexo=2&Lista=Sim&Pers=1';" value="Visualizar" />
    </div>
</div><%
else
	%>
	<h1>Pacientes do Sexo <%=getSexo(request.QueryString("Sexo"))%></h1>
	<%
end if%>
<%if request.QueryString("Lista")="Sim" then%>
<table width="100%" class="table table-striped table-borderes">
<thead>
  <tr>
    <th>Nome</th>
    <th>Nascimento</th>
    <th>Telefone</th>
    <th>Celular</th>
    <th>E-mail</th>
  </tr>
</thead>
<tbody>
  <%
c=0
set p = db.Execute("Select * from pacientes where Sexo like '"&request.QueryString("Sexo")&"'")
while  not p.eof
	c=c+1
%>
  <tr onclick="location.href='?P=Pacientes&I=<%=p("id")%>&Pers=1';">
    <td><div align="left"><%=p("NomePaciente")%></div></td>
    <td><div align="left"><%=p("Nascimento")%></div></td>
    <td><div align="left"><%=p("Tel1")%></div></td>
    <td><div align="left"><%=p("Cel1")%></div></td>
    <td><div align="left"><%=p("Email1")%></div></td>
  </tr>
  <%
p.moveNext
wend
set p=nothing
%>
</table>
<%end if%>
