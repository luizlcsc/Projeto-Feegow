<!--#include file="connect.asp"-->
<%
ItemInvoiceID = req("ItemInvoiceID")
ProdutoInvoiceID = req("ProdutoInvoiceID")
AtendimentoID = req("AtendimentoID")
ProdutoID = req("I")
CD = req("CD")


if ItemInvoiceID<>"" or AtendimentoID<>"" or ProdutoInvoiceID<>"" then
    hiddenII = "hidden"
    if CD="C" then
        hiddenE = "hidden"
    elseif CD="D" then
        hiddenS = "hidden"
    end if
end if

set reg = db.execute("select p.*, u.* from produtos as p left join cliniccentral.tissunidademedida as u on p.ApresentacaoUnidade=u.id where p.id="& ProdutoID)
if len(reg("descricao"))>6 then
	unidade = right(reg("Descricao"), len(reg("Descricao"))-6 )
end if
conjunto = reg("ApresentacaoNome")

sqlUnidadesUsuario = ""
if aut("lctestoqueV")=0 then
    UnidadesUsuario = replace(session("Unidades")&"", "|", "")
    sqlUnidadesUsuario = " AND pl.UnidadeID  IN ("&UnidadesUsuario&") "
end if
QuantidadeTotalUnidade = 0
QuantidadeTotalConjunto = 0
call refazPosicao(ProdutoID)
%>

<br />
<table width="100%" class="table table-striped table-bordered table-hover">
    <thead>
        <tr class="system">
            <th colspan="8">Posi&ccedil;&atilde;o de Estoque</th>
            <th class="<%=hiddenII %>"><button class="btn btn-sm btn-primary" type="button" onclick="printEtiqueta(<%=req("I") %>)"><i class="fa fa-barcode"></i> Imprimir Etiquetas</button></th>
        </tr>
        <tr class="info">
            <th class="<%= hiddenII %>" width="1%"><input onclick="$('.eti').prop('checked', $(this).prop('checked'))" type="checkbox" /></th>
            <th>Lote</th>
            <th>Validade</th>
            <th>Cód. Individual</th>
            <th>Localização</th>
            <th>Responsável</th>
            <th>Quantidade</th>
            <th nowrap>Valor Médio</th>
            <th class="p5" width="75">
                <button class="btn btn-system mn btn-block btn-sm btnLancto <%= hiddenE %>" type="button"<%=disabled%> onclick="$('#save').click(); lancar(<%=req("I")%>, 'E', '', '', '', '<%= ItemInvoiceID %>', '', <%= ProdutoInvoiceID %>);"><i class="fa fa-level-down"></i> Entrada</button>
            </th>
        </tr>
    </thead>
    <tbody>
        <%
        set lanc = db.execute("select ep.id PosicaoID, ep.Lote, ep.Validade, ep.Quantidade, ep.LocalizacaoID, ep.CBID, ep.Responsavel, ep.TipoUnidade, ep.ValorPosicao, pl.NomeLocalizacao from estoqueposicao ep LEFT JOIN produtoslocalizacoes pl ON pl.id=ep.LocalizacaoID WHERE ep.ProdutoID="&req("I")&sqlUnidadesUsuario)
        while not lanc.eof
            Responsavel = lanc("Responsavel")&""
            if instr(Responsavel, "_")>0 then
                splResp = split(Responsavel, "_")
                Responsavel = accountName(splResp(0), splResp(1))
            end if
			
			
			
            Quantidade = lanc("Quantidade")
            TipoUnidade = lanc("TipoUnidade")
			
			if TipoUnidade="C" then
				QuantidadeTotalConjunto = QuantidadeTotalConjunto + Quantidade
			else
				QuantidadeTotalUnidade = QuantidadeTotalUnidade + Quantidade
			end if
			
			
            if Quantidade<>0 then
                if instr(lanc("Responsavel")&"", "_") and Responsavel="" then
                    db_execute("update estoquelancamentos set Responsavel='' WHERE Responsavel='"& lanc("Responsavel") &"'")
                    atualizaLanctos = "S"
                end if
                %>
                <tr>
                    <td class="<%=hiddenII %>" width="1%"><input class="eti" type="checkbox" name="etiqueta" value="<%=lanc("PosicaoID") %>" /></td>
                    <td><%=lanc("Lote")%></td>
                    <td><%=lanc("Validade")%></td>
                    <td><%=lanc("CBID") %></td>
                    <td><%=lanc("NomeLocalizacao") %></td>
                    <td><%=Responsavel %></td>
                    <td><%=descQuant(Quantidade, TipoUnidade, conjunto, unidade) %></td>
                    <td class="text-right"><%= fn(lanc("ValorPosicao")) %></td>
                    <td class="p5">
                        <button class="btn btn-alert mn btn-block btn-xs btnLancto <%= hiddenS %>" type="button"<%=disabled%> onclick="lancar(<%=req("I") %>, 'S', '<%=req("LocalizacaoID")%>', '', <%=lanc("PosicaoID") %>, '<%=ItemInvoiceID %>', '<%= AtendimentoID %>', <%= ProdutoInvoiceID %>);"><i class="fa fa-level-up"></i> Sa&iacute;da</button>
                        <button class="mt10 btn btn-info mn btn-block btn-xs <%=hiddenII %>" type="button"<%=disabled%> onclick="dividir(<%=req("I") %>, 'S', '<%=req("LocalizacaoID")%>', '', <%=lanc("PosicaoID") %>, '<%=req("Quantidade")%>');"><i class="fa fa-retweet"></i> Mover</button>
                    </td>
                </tr>
                <%
            end if
        lanc.movenext
        wend
        lanc.close
        set lanc = nothing
        %>
    </tbody>
	<tfoot>
		<tr>
			<th colspan="9" class="text-right">
				Conjunto: <%=QuantidadeTotalConjunto&" "&lcase(conjunto)%> <br>
				Unidade: <%=QuantidadeTotalUnidade&" "&lcase(unidade)%>
			</th>
		</tr>
	</tfoot>
</table>

<script>
    function lancar(P, T, L, V, PosicaoID, ItemInvoiceID, AtendimentoID) {
    $("#modal-table").modal("show");
    $("#modal").html("Carregando...");
    $.ajax({
        type:"POST",
        url:"EstoqueLancamento.asp?P="+P+"&T="+T+"&L="+L+"&V="+V+"&PosicaoID="+PosicaoID +"&ItemInvoiceID=" + ItemInvoiceID + "&AtendimentoID="+ AtendimentoID,
        success: function(data){
            setTimeout(function(){
                if ($("div-secundario").length == 0 ){
                    $("#modal").html(data);
                } else {
                    $("div-secundario").html(data);
                }
            }, 500);
        }
    });
}

</script>
<%
if atualizaLanctos="S" then
    %>
    <script type="text/javascript">
        atualizaLanctos();
    </script>
    <%
end if
%>