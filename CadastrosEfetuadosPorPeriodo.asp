<!--#include file="connect.asp"-->
<%
if not isdate(req("De")) or req("De")="" then
	De=dateadd("m", -1, date() )
else
	De=req("De")
end if

if not isdate(req("A")) or req("A")="" then
	A=date()
else
	A=req("A")
end if
%>
<h4>Cadastro Efetuados por Per&iacute;odo</h4>
<form id="Relatorio" name="Relatorio" method="get" action="Relatorio.asp" target="_blank">
<input type="hidden" name="Pers" value="1" />
<input type="hidden" name="P" value="Relatorio" />
<input type="hidden" name="TipoRel" value="CadastrosEfetuadosPorPeriodo" />
<div class="clearfix form-actions">
<%=quickField("datepicker", "De", "Data In&iacute;cio", 3, left(De, 10), "", "", "")%>
<%=quickField("datepicker", "A", "Data Fim", 3, left(A, 10), "", "", "")%>
<label>&nbsp;</label><br />

<button class="btn btn-success" name="Gerar"><i class="far fa-list"></i> Gerar</button>
</div>
</form>

<form method="post" action="Etiquetas.asp" target="_blank">

<table width="100%" border="0">
<%
set rsConta = db.Execute("Select COUNT(id) as TOTAL from pacientes where sysDate between '"&mydate(De)&"' and '"&mydate(A)&"'")
Total=rsConta("TOTAL")
%><tr>
<td><p>&nbsp;</p>
  <p align="center">Cadastros no per&iacute;odo: <%=Total%> paciente(s).<%if req("Lista")="" then%> <a class="btn btn-info" type="button" href="?P=Relatorio&TipoRel=<%=req("TipoRel")%>&De=<%=req("De")%>&A=<%=req("A")%>&Lista=Sim&Pers=1"><i class="far fa-zoom-in"></i> Detalhar</a><% end if %></p>
  <%'if req("Lista")="Sim" then%>
  <table width="100%" class="table table-striped table-bordered">
  <thead>
    <tr>
      <th>Nome</th>
      <th>Sexo</th>
      <th>Nascimento</th>
      <th>&Uacute;lt. Consulta</th>
      <th>Data de Cadastro</th>
    </tr>
    </thead>
	<tbody>
    <%
c=0
set p = db.Execute("Select * from pacientes where sysDate between '"&mydate(De)&"' and '"&mydate(A)&"'")
while  not p.eof
	set vca=db.execute("select * from agendamentos where PacienteID="&p("id")&" and not StaID=6 and data between '"&mydate(De)&"' and '"&mydate(A)&"'")
	c=c+1
		gerEt="S"
%>
    <tr onclick="location.href='?P=Pacientes&Pers=1&I=<%=p("id")%>';">
      <td><div align="left"><%=p("NomePaciente")%>
        <input type="hidden" name="Et" value="<%=p("id")%>" />
      </div></td>
      <td><div align="left"><%=getSexo(p("Sexo"))%></div></td>
      <td><div align="left"><%=p("Nascimento")%></div></td>
      <%
set pult=db.execute("select * from agendamentos where PacienteID="&p("id")&" and not StaID=6 order by Data desc")
if pult.eof then
	ultDat="Nunca"
else
	ultDat=pult("Data")
end if

%>
      <td><div align="left"><%=ultDat%></div></td>
      <td><%=p("sysDate")%></td>
    </tr>
    <%
p.moveNext
wend
set p=nothing
%>
</tbody>
  </table> 
 </td>
</tr>
</table>

<!----include file="gerEt.asp"---->
</form>
<script language="javascript">
$("#Relatorio").submit(function(){
	$("#relConteudo").html('Carregando...');
	$.get("CadastrosEfetuadosPorPeriodo.asp", $(this).serialize(), function(data){ $("#relConteudo").html(data) });
	return false;
});
<!--#include file="jQueryFunctions.asp"-->
</script>