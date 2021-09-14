<!--#include file="connect.asp"-->
<table class="table table-bordered table-striped" width="100%" border="0">
<tr><th>ORIGEM</th><th>OCORR&Ecirc;NCIAS</th></tr>
<%
set por=db.execute("select distinct Origem from pacientes where not Origem like '' and Origem<>0 order by Origem")
while not por.EOF
	set pconta=db.execute("select count(Origem) as Total from pacientes where Origem like '"&por("Origem")&"'")
	set pNomOr=db.execute("select * from Origens where id = '"&por("Origem")&"'")
	if pNomOr.EOF then
		Origem="<em>Origem excluída.</em>"
	else
		Origem=pNomOr("Origem")
	end if
%><tr><td><%=Origem%></td><td><a href="./?P=<%=req("TipoRel")%>&TipoRel=<%=req("TipoRel")%>&Pers=1&OrigemID=<%=por("Origem")%>&Origem=<%=Origem%>"><%=pconta("Total")%></a></td></tr>
<%
por.movenext
wend
por.close
set por=nothing
%></table>


<%if req("OrigemID")<>"" then%>
<h4>Pacientes Encontrados por Origem - <%=req("Origem")%></h4>
<table class="table table-bordered table-striped" width="100%" border="0">
  <tr>
    <th>Nome</th>
    <th>Sexo</th>
    <th>Nascimento</th>
  </tr>
  <%
c=0
set p = db.Execute("Select * from pacientes where Origem="&req("OrigemID"))
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