<!--#include file="connect.asp"-->
<h4>Pacientes por Indica&ccedil;&atilde;o</h4>
<%
set p=db.execute("select distinct IndicadoPor from pacientes where not IndicadoPor like '' order by IndicadoPor")
while not p.eof
set rsConta = db.Execute("Select COUNT(id) as TOTAL from pacientes where IndicadoPor like '"&p("IndicadoPor")&"'")
c=rsConta("TOTAL")
%>
  <%if req("Lista")="" then%>
  <button name="button" type="button" class="btn btn-primary btn-block btn-sm" onclick="location.href='./?P=<%=req("TipoRel")%>&Pers=1&TipoRel=<%=req("TipoRel")%>&IndicadoPor=<%=p("IndicadoPor")%>&Lista=Sim';"><i class="far fa-list"></i> <%=p("IndicadoPor")%>: <%=c%> paciente(s) - Visualizar</button>
  <% end if %>
<br />
<%
p.moveNext
wend
p.close
set p=nothing
%><%if req("Lista")="Sim" then%>
<table class="table table-bordered table-striped" width="100%" border="0">
  <tr>
    <th>Nome</th>
    <th>Sexo</th>
    <th>Nascimento</th>
    <th>Indicado Por</th>
  </tr>
  <%
c=0
set p = db.Execute("Select * from pacientes where IndicadoPor like '"&req("IndicadoPor")&"'")
while  not p.eof
	c=c+1
%>
  <tr onclick="location.href='./?P=Pacientes&Pers=1&I=<%=p("id")%>';">
    <td><div align="left"><%=p("NomePaciente")%></div></td>
    <td><div align="left"><%=getsexo(p("Sexo"))%></div></td>
    <td><div align="left"><%=p("Nascimento")%></div></td>
    <td><div align="left"><%=p("IndicadoPor")%></div></td>
  </tr>
  <%
p.moveNext
wend
set p=nothing
%>
</table>
<%end if%>
