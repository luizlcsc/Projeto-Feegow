<!--#include file="connect.asp"-->
<%
ElementoID = req("ElementoID")
ProdutoID = req("id")
CD = ref("T")
set proc = db.execute("select p.*, u.Descricao NomeUnidade from produtos p LEFT JOIN cliniccentral.tissunidademedida u ON u.id=p.ApresentacaoUnidade where p.id="&ProdutoID)
if not proc.EOF then
    if CD="D" then
        Coluna = "TipoCompra"
        Preco = "PrecoCompra"
    else
        Coluna = "TipoVenda"
        Preco = "PrecoVenda"
    end if
	Valor = fn(proc( Preco ))
	Subtotal = Valor*ccur(ref("Quantidade"&ElementoID))
    if len(proc("ApresentacaoNome"))>2 then
        ApresentacaoUnidade = proc("ApresentacaoNome")
    else
        Apresenta
    end if
    NomeUnidade = proc("NomeUnidade")
    if len( NomeUnidade )>2 then
        NomeUnidade = proc("NomeUnidade")
        if instr(NomeUnidade, " - ")>0 then
            spl = split( NomeUnidade, " - " )
            NomeUnidade = spl(1)
        end if
    else
        NomeUnidade = "Unidade"
    end if
	%>
    $("#Executado<%=ElementoID %>C, #Executado<%=ElemntoID %>U").prop("checked", false);
    $("#Executado<%=ElementoID & proc(""&Coluna&"") %>").prop("checked", true);
	 $("#ValorUnitario<%=ElementoID%>").val('<%=Valor%>');
    $("label[for='Executado<%=ElementoID %>C']").html("<%=ApresentacaoUnidade %>");
    $("label[for='Executado<%=ElementoID %>U']").html("<%=NomeUnidade %>");


     $("#sub<%=ElementoID%>").html("R$ <%=formatnumber(Subtotal,2)%>");
      calcRepasse(<%=ElementoID%>);
     recalc();
	<%
end if
%>