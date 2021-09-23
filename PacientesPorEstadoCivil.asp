<!--#include file="connect.asp"-->
<h4>Pacientes por Estado Civil</h4>
<%
set p=db.execute("select distinct EstadoCivil from pacientes where not EstadoCivil like '' order by EstadoCivil")
while not p.eof
set rsConta = db.Execute("Select COUNT(id) as TOTAL from pacientes where EstadoCivil like '"&p("EstadoCivil")&"'")
c=rsConta("TOTAL")
set pest=db.execute("select * from EstadoCivil where id = '"&p("EstadoCivil")&"'")
if not pest.eof then
ec=pest("estadoCivil")
bec=p("estadoCivil")
else
ec="N&atilde;o informado"
bec="0"
end if
%>
  <%if req("Lista")="" then%>
  <button name="button" class="btn btn-primary btn-block" type="button" onclick="location.href='./?P=<%=req("TipoRel")%>&Pers=1&TipoRel=<%=req("TipoRel")%>&EstadoCivil=<%=bec%>&Lista=Sim';"><i class="far fa-list"></i> <%=(ec)%>: <%=c%> paciente(s) - Listar</button>
  <% end if %>

<br />
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
  </tr>
  <%
c=0
set p = db.Execute("Select * from pacientes where EstadoCivil like '"&req("EstadoCivil")&"'")
while  not p.eof
	c=c+1
%>
  <tr onclick="location.href='./?P=Pacientes&Pers=1&I=<%=p("id")%>';">
    <td><div align="left"><%=p("NomePaciente")%></div></td>
    <td><div align="left"><%=getSexo(p("Sexo"))%></div></td>
    <td><div align="left"><%=p("Nascimento")%></div></td>
  </tr>
  <%
p.moveNext
wend
set p=nothing
%>
</table>
<%end if%>
