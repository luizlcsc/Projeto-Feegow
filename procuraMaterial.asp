<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<%
codigo = ref("typed")
tabela = ref("tabela")
descricao = ref("descricao")

TemSimpro = True

if len(codigo)>=1 then
    sqlCodigo = " OR CodigoTuss like '"&codigo&"%'"

    sqlDescricao = " OR Descricao like '"&codigo&"%'"
    if Tabela<>"" then
        sqlTabela = " AND Tabela='"&tabela&"'"
    end if
    if TemSimpro then
        sqlCodigoSimpro = " OR CodigoSimpro like '"&codigo&"%'"
    end if
end if

sql = "SELECT *, (IF(CodigoSimpro LIKE '%"&codigo&"%', 1 , 0))EhSimpro FROM cliniccentral.produtos WHERE (1=0"&sqlCodigo&sqlCodigoSimpro&sqlDescricao&")"&sqlTabela&" LIMIT 20"
set list = dbc.execute(sql)
if list.eof then
	nada = "S"
else
	%>
    <ul class="select-insert">
	<%
	while not list.eof
	    Descricao=list("Descricao")
	    Codigo=list("CodigoTuss")

	    if TemSimpro and list("EhSimpro")="1" then
	        Codigo=list("CodigoSimpro")
	    end if

		%>
		<li data-codigo="<%=Codigo %>" data-id="<%=list("id")%>" data-descricao="<%=Descricao %>" class="select-insert-item" value=""><%=Codigo%> - <%=Descricao%></li>
		<%
	list.movenext
	wend
	list.close
	set list=nothing
	%>
	</ul>
	<%
end if
%>
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

		<% if ref("naoSeleciona")&"" = "" then %>
		$.post("selecionaProduto.asp", {
            id: $(this).attr("data-id"),
            codigo: $(this).attr("data-codigo"),
            tabela: "<%=Tabela%>",
           CodigoField:'<%=ref("CodigoField")%>',
           DescricaoField:'<%=ref("DescricaoField")%>',
           CDField:'<%=ref("CDField")%>',
           UnidadeMedidaField:'<%=ref("UnidadeMedidaField")%>',
           ValorField:'<%=ref("ValorField")%>',
           AdicionarValor:'<%=ref("AdicionarValor")%>'
		},function (data){
		    eval(data);
		});
		<% end if %>
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