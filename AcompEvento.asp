<!--#include file="connect.asp"-->
<%
if session("banco")<>"clinic105" and session("banco")<>"clinic2184" then
    response.Redirect("./?P=Login")
end if

response.Buffer
%>
<div class="table-responsive">
<table width="100%" border="0" id="table-trials" class="table table-striped table-bordered table-hover">
<thead>
<tr>
	<th>Licen&ccedil;a</th>
	<th>Contato</th>
	<th>Telefone</th>
	<th>Celular</th>
	<th>E-mail</th>
    <th>Data</th>
    <th>Acompanhamento</th>
    <th width="200" nowrap>Próxima Ligação</th>
</tr>
</thead>
<tbody>
<%
set l = db.execute("select l.* from cliniccentral.licencas l where isnull(l.Excluido) and l.Status='"&req("Sta")&"' and ComoConheceu='Evento' order by l.DataHora desc")
while not l.eof
	response.Flush()
	'cor="#EAFFF4"
	%>
	<tr bgcolor="<%=cor%>">
    	<td><%=l("id")%></td>
    	<td><%=l("NomeContato")%></td>
    	<td><%=l("Telefone")%></td>
   	  <td><%=l("Celular")%></td>
   	  <td><%
             set ema = db.execute("select Email from cliniccentral.licencasusuarios where LicencaID="&l("id"))
             while not ema.eof
                response.Write(ema("Email")&"<br>")
             ema.movenext
             wend
             ema.close
             set ema=nothing
             %></td>
        <td><%=l("DataHora")%></td>
        <td><%=quickfield("memo", "Acompanhamento"&l("id"), "", 12, l("Acompanhamento"), "", "", " data-id='"&l("id")&"' ")%></td>
        <td><%=quickfield("datepicker", "ProximoContato"&l("id"), "", 12, l("ProximoContato"), "", "", " data-id='"&l("id")&"' ")%></td>
    </tr>
	<%
l.movenext
wend
l.close
set l=nothing
%>
</tbody>
</table>
</div>

<script>
jQuery(function($) {
	var oTable1 = $('#table-trials').dataTable( {
	"aoColumns": [
	  null,null,null,null,null,null,null,null
	] } );

    $("#main-container").removeClass("container");
});

$("textarea[name^=Acompanhamento], input[name^=ProximoContato]").change(function(){
    $.post("saveAcompanhamento.asp", {
        id: $(this).attr("data-id"),
        Acompanhamento: $("#Acompanhamento"+$(this).attr("data-id")).val(),
        ProximoContato: $("#ProximoContato"+$(this).attr("data-id")).val()
    });
});
</script>