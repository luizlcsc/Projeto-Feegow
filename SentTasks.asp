<!--#include file="connect.asp"-->
<%
if req("X")<>"" then
	set taskX = db.execute("select * from tarefas where id="&req("X"))
	if not taskX.eof then
		call altNotif(taskX("De"), taskX("id"), "", "X")
		call altNotif(taskX("Para"), taskX("id"), "", "X")
	end if
	db_execute("delete from Tarefas where id="&req("X")&"")
	db_execute("delete from TarefasMSGs where TarefaID="&req("X")&"")
end if
%>
<script language="javascript">
  function excluiTarefa(aURL) {
    if(confirm('Tem certeza de que deseja excluir este registro?')) {
      location.href = aURL;
    }
  }
</script>


<div class="subPainelPrincipal">
    <h1>Tarefas Criadas por Mim</h1>
 </div>

<fieldset><legend><strong>Com pend&ecirc;ncia da minha parte </strong></legend>
<table width="100%" border="0" class="table table-striped table-hover table-bordered">
  <thead>
  <tr class="danger">
    <th width="26%">T&iacute;tulo</th>
    <th width="13%"> Prazo</th>
    <th width="13%">De</th>
    <th width="13%">Para</th>
    <th width="13%"> Abertura</th>
    <th width="1%">&nbsp;</th>
  </tr>
  </thead>
  <tbody>
  <%
Set PLista = db.Execute("Select * From Tarefas where De="&session("User")&" and staDe='Pendente' Order By DtPrazo,HrPrazo")
While Not PLista.EOF
%>
  <tr>
    <td><a href="./?P=Task&Pers=1&I=<%=PLista("id")%>"><%=PLista("Titulo")%></a></td>
    <td><%=PLista("DtPrazo")%> - <%=cdate(hour(PLista("HrPrazo"))&":"&minute(PLista("HrPrazo")))%></td>
    <td><%=nameInTable(PLista("De"))%><br /><em><%=PLista("staDe")%></em></td>
    <td><%nameInTable(PLista("Para"))%><br /><em><%=PLista("staPara")%></em></td>
    <td><%=PLista("DtAbertura")%> - <%=cdate(hour(PLista("HrAbertura"))&":"&minute(PLista("HrAbertura")))%></td>
    <td><button type="button" class="btn btn-sm btn-danger" onclick="excluiTarefa('./?P=<%=req("P")%>&Pers=1&X=<%=PLista("id")%>');"><i class="far fa-trash"></i></button></td>
  </tr>
  <%
PLista.MoveNext
Wend
PLista.Close
Set PLista = Nothing
%>
</tbody>
</table>
</fieldset><br />
<br />

<fieldset><legend><strong>Com pend&ecirc;ncia da outra parte </strong></legend>
<table width="100%" class="table table-striped table-hover table-bordered">
  <thead>
  <tr class="danger">
    <th width="26%">T&iacute;tulo</th>
    <th width="13%"> Prazo</th>
    <th width="13%">De</th>
    <th width="13%">Para</th>
    <th width="13%"> Abertura</th>
    <th width="1%">&nbsp;</th>
  </tr>
  </thead>
  <tbody>
  <%
Set PLista = db.Execute("Select * From Tarefas where De="&session("User")&" and staPara='Pendente' Order By DtPrazo,HrPrazo")
While Not PLista.EOF
%>
  <tr>
    <td><a href="./?P=Task&Pers=1&I=<%=PLista("id")%>"><%=PLista("Titulo")%></a></td>
    <td><%=PLista("DtPrazo")%> - <%=cdate(hour(PLista("HrPrazo"))&":"&minute(PLista("HrPrazo")))%></td>
    <td>
        <%=nameInTable(PLista("De"))%><br /><em><%=PLista("staDe")%></em>
      </td>
    <td><%=nameInTable(PLista("Para"))%><br /><em><%=PLista("staPara")%></em></td>
    <td><%=PLista("DtAbertura")%> - <%=cdate(hour(PLista("HrAbertura"))&":"&minute(PLista("HrAbertura")))%></td>
    <td><button type="button" class="btn btn-sm btn-danger" onclick="excluiTarefa('./?P=<%=req("P")%>&Pers=1&X=<%=PLista("id")%>');"><i class="far fa-trash"></i></button></td>
  </tr>
  <%
PLista.MoveNext
Wend
PLista.Close
Set PLista = Nothing
%>
</tbody>
</table>
</fieldset><br />
<br />
<fieldset><legend><strong>Finalizadas pela outra parte </strong></legend>
<table width="100%" border="0" class="table table-striped table-hover table-bordered">
  <thead>
  <tr class="warning">
    <th width="26%">T&iacute;tulo</th>
    <th width="13%"> Prazo</th>
    <th width="13%">De</th>
    <th width="13%">Para</th>
    <th width="13%"> Abertura</th>
    <th width="2%">&nbsp;</th>
  </tr>
  </thead>
  <tbody>
  <%
Set PLista = db.Execute("Select * From Tarefas where De="&session("User")&" and staDe<>'Finalizada' and staPara='Finalizada' Order By DtPrazo,HrPrazo")
While Not PLista.EOF
%>
  <tr>
    <td><a href="./?P=Task&Pers=1&I=<%=PLista("id")%>"><%=PLista("Titulo")%></a></td>
    <td><%=PLista("DtPrazo")%> - <%=cdate(hour(PLista("HrPrazo"))&":"&minute(PLista("HrPrazo")))%></td>
    <td><%=nameInTable(PLista("De"))%><br /><em><%=PLista("staDe")%></em></td>
    <td><%=nameInTable(PLista("Para"))%><br /><em><%=PLista("staPara")%></em></td>
    <td><%=PLista("DtAbertura")%> - <%=cdate(hour(PLista("HrAbertura"))&":"&minute(PLista("HrAbertura")))%></td>
    <td><button type="button" class="btn btn-sm btn-danger" onclick="excluiTarefa('./?P=<%=req("P")%>&Pers=1&X=<%=PLista("id")%>');"><i class="far fa-trash"></i></button></td>
  </tr>
  <%
PLista.MoveNext
Wend
PLista.Close
Set PLista = Nothing
%>
</tbody>
</table>
</fieldset><br />
<br />

<fieldset><legend><strong>Totalmente Finalizadas</strong></legend>
<table width="100%" border="0" class="table table-striped table-hover table-bordered">
  <thead>
  <tr class="success">
    <th width="26%">T&iacute;tulo</th>
    <th width="13%"> Prazo</th>
    <th width="13%">De</th>
    <th width="13%">Para</th>
    <th width="13%"> Abertura</th>
    <th width="2%">&nbsp;</th>
  </tr>
  </thead>
  <tbody>
  <%
Set PLista = db.Execute("Select * From Tarefas where De="&session("User")&" and staDe='Finalizada' and staPara='Finalizada' Order By DtPrazo,HrPrazo")
While Not PLista.EOF
%>
  <tr>
    <td><a href="./?P=Task&Pers=1&I=<%=PLista("id")%>"><%=PLista("Titulo")%></a></td>
    <td><%=PLista("DtPrazo")%> - <%=cdate(hour(PLista("HrPrazo"))&":"&minute(PLista("HrPrazo")))%></td>
    <td><%=nameInTable(PLista("De"))%><br /><em><%=PLista("staDe")%></em></td>
    <td><%=nameInTable(PLista("Para"))%><br /><em><%=PLista("staPara")%></em></td>
    <td><%=PLista("DtAbertura")%> - <%=cdate(hour(PLista("HrAbertura"))&":"&minute(PLista("HrAbertura")))%></td>
    <td><button type="button" class="btn btn-sm btn-danger" onclick="excluiTarefa('./?P=<%=req("P")%>&Pers=1&X=<%=PLista("id")%>');"><i class="far fa-trash"></i></button></td>
  </tr>
  <%
PLista.MoveNext
Wend
PLista.Close
Set PLista = Nothing
%>
</tbody>
</table>
</fieldset>
<!--#include file = "disconnect.asp"-->