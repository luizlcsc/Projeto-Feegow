<!--#include file="connect.asp"-->
<h4>Pacientes por Cor da Pele</h4>
<%
set p=db.execute("select distinct CorPele from pacientes where not CorPele like '' order by CorPele")
while not p.eof
set rsConta = db.Execute("Select COUNT(id) as TOTAL from pacientes where CorPele like '"&p("CorPele")&"'")
c=rsConta("TOTAL")
%>
  <%if req("Lista")="" then%>
	<button name="button" type="button" class="btn btn-primary btn-block" onclick="location.href='./?P=<%=req("TipoRel")%>&Pers=1&TipoRel=<%=req("TipoRel")%>&CorPele=<%=p("CorPele")%>&Lista=Sim';"><i class="far fa-list"></i> <%=getCorPele(p("CorPele"))%>: <%=c%> paciente(s)</button>
  <% end if %>
<br />
<%
p.moveNext
wend
p.close
set p=nothing
%>
<%if req("Lista")="Sim" then%>
<table class="table table-bordered table-striped" width="100%" border="0">
  <tr>
    <th>Nome</th>
    <th>Sexo</th>
    <th>Nascimento</th>
    <th>Cor da Pele</th>
  </tr>
  <%
c=0
set p = db.Execute("Select * from pacientes where CorPele like '"&req("CorPele")&"'")
while  not p.eof
	c=c+1
%>
  <tr onclick="location.href='./?P=Pacientes&Pers=1&I=<%=p("id")%>';">
    <td><div align="left"><%=p("NomePaciente")%></div></td>
    <td><div align="left"><%=getSexo(p("Sexo"))%></div></td>
    <td><div align="left"><%=p("Nascimento")%></div></td>
    <td><div align="left"><%=getCorPele(p("CorPele"))%></div></td>
  </tr>
  <%
p.moveNext
wend
set p=nothing
%>
</table>
<%end if%>
