<!--#include file="connectCentral.asp"-->
<%
response.Charset="ISO-8859-1"
%>
<form id="frmBula" method="post" action="">
    <div class="input-group">
        <input class="form-control search-query input-md" id="BuscaBula" value="<%=Med%>" name="BuscaBula" type="text" placeholder="Nome ou princ&iacute;pio ativo">
        <span class="input-group-btn">
            <button class="btn btn-info">
                Buscar
                <i class="fa fa-search icon-on-right bigger-110"></i>
            </button>
        </span>
    </div>
</form>

<%
Med = request.QueryString("M")
if Med="undefined" then Med="" end if

if request.QueryString("I")="" then
	if Med<>"" then
		set b=dbc.execute("select * from bulas where Bula like '%"&replace(replace(Med, " ", "%"), "'", "''")&"%' order by nome limit 300")
		if b.eof then
			%>
			Nenhum medicamento encontrado com o termo '<%=Med%>'.
			<%
		else
			%>
			<table class="table table-striped table-hover">
				<thead>
					<tr>
						<th>Medicamento</th>
						<th>Laborat&oacute;rio</th>
						<th width="1%"></th>
					</tr>
				</thead>
				<tbody>
				<%
				while not b.eof
					%>
					<tr>
						<td><%=b("Nome")%></td>
						<td><%=b("Laboratorio")%></td>
						<td><button type="button" onclick="bula('<%=Med%>', <%=b("id")%>)" class="btn btn-sm btn-info"><i class="fa fa-search-plus"></i></button></td>
					</tr>
					<%
				b.movenext
				wend
				b.close
				set b = nothing
				%>
				</tbody>
			</table>
		<%
		end if
	end if
else
	set b=dbc.execute("select * from bulas where id="&request.QueryString("I"))
	%>
	<br>
    <button class="btn btn-warning btn-md form-control" type="button" onclick="bula('<%=Med%>', '')"><i class="fa fa-search"></i> Voltar para o resultado da busca</button>
	<%=b("Bula")%>
	<%
end if
%>

<script type="text/javascript">
$("#frmBula").submit(function(){
	bula($("#BuscaBula").val(), '');
	return false;
});
</script>