<!--#include file="connect.asp"-->
<%
if req("PropostaID")<>"" then
	PropostaID=req("PropostaID")
else
	PropostaID=req("I")
end if

Acao = ref("A")
II = ref("II")
Row = req("Row")
if Row<>"" then
	Row=ccur(Row)
end if

set propostaSql = db.execute("select StaID from propostas where id="&PropostaID)
if not propostaSql.eof then
	if propostaSql("StaID")&"" = "5" then
		desabilitarProposta =" disabled "
		escondeProposta = " hidden "
	end if
end if 

if Acao="" then
	%>
	<table width="100%" class="table table-striped table-condensed">
		<tbody>
		<%
		conta = 0
		Total = 0
		Subtotal = 0
		set itens=db.execute("select * from pacientespropostasformas where PropostaID="&PropostaID)
		while not itens.eof
			id = itens("id")
			Descricao = itens("Descricao")
			%>
            <!--#include file="propostaLinhaFormas.asp"-->
			<%
		itens.movenext
		wend
		itens.close
		set itens=nothing

		%>
		<tr id="PropostasFormas">
		</tr>
		</tbody>
	</table>
    <input type="hidden" id="minorRowFormas" value="0">
<%
elseif Acao="I" then
    id = ccur(ref("minorRowFormas"))-1
    Tipo = ref("T")
	set listaPedido = db.execute("select * from propostasformas where id="&ref("II"))
	if not listaPedido.eof then
		Descricao = listaPedido("Descricao")
		%>
		<!--#include file="propostaLinhaFormas.asp"-->
        <script>
			$("#minorRowFormas").val("<%=id%>");
		</script>
		<%
	end if
elseif Acao="X" then'nao esta usando, pois esta fazendo antes por javascript
	%>
	$("#row<%= II %>, #row2_<%= II %>").replaceWith("");
	<%
end if
%>
<!--#include file="disconnect.asp"-->