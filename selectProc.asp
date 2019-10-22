<!--#include file="connect.asp"-->
<ul class="select-insert">
<%

'label, name, value, thisField, TabelaField, CodigoField, DescricaoField, othersToInput
typed = replace(ref("typed"), " ", "%")
Tabela = zeroEsq(ref("Tabela"), 2)

sql = "select * from cliniccentral.procedimentos where (codigo like '%"& typed &"%' or descricao like '%"& typed &"%') and tipoTabela like '"&Tabela&"' limit 100"
    'response.write( sql )
set list = db.execute(sql)
if list.eof then
	nada = "S"
else
	%>
	<%
	while not list.eof
		%>
		<li data-codigo="<%=list("codigo") %>" data-descricao="<%=list("descricao") %>" class="select-insert-item" value="<%=list("id")%>"><%=list("codigo")%> - <%=list("descricao")%></li>
		<%
	list.movenext
	wend
	list.close
	set list=nothing
end if
%>
</ul>
<script type="text/javascript">
jQuery(function($) {
<%

if nada = "" then
	%>
	$(".select-insert-item").click(function(){    
    
        <%=othersToSelect %>

        $("#<%=ref("CodigoField")%>").val( $(this).attr("data-codigo") );
        $("#<%=ref("DescricaoField")%>").val( $(this).attr("data-descricao") );
     
		$("#resultSelect<%=ref("selectID")%>").css("display", "none");
		$.get("selecionaProcedimentoBuscaRapida.asp", {
		    codigo: $(this).attr("data-codigo"),
		    tabela: "<%=Tabela%>",
		    selectID: "<%=ref("selectID")%>"
		},function (data){
		    eval(data);
		})
        });
    <%
else
	%>
	$("#resultSelect<%=ref("initialOrder")%>").css("display", "none");
	<%
end if
%>
});
</script>