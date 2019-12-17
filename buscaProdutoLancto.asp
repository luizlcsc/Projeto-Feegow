<!--#include file="connect.asp"-->
<%
BuscaProduto = ref("BuscaProduto")
ItemInvoiceID = req("ItemInvoiceID")
ProdutoInvoiceID = req("ProdutoInvoiceID")
AtendimentoID = req("AtendimentoID")
CD = req("CD")
if ItemInvoiceID="undefined" then
    ItemInvoiceID = ""
end if
if ProdutoInvoiceID="undefined" then
    ProdutoInvoiceID = ""
end if

sqlUnidadesUsuario = ""
if aut("lctestoqueV")=0 then
    UnidadesUsuario = replace(session("Unidades")&"", "|", "")
    sqlUnidadesUsuario = " AND pl.UnidadeID  IN ("&UnidadesUsuario&") "
end if

'verifica os produtos pré-envolvidos pra buscar caso esteja vazia a busca
if BuscaProduto="" then
    if ItemInvoiceID<>"" then
        set ii = db.execute("select ii.ItemID, ii.Tipo from itensinvoice ii LEFT JOIN sys_financialinvoices i ON ii.InvoiceID=i.id WHERE ii.id="& ItemInvoiceID)
        if not ii.eof then
            if ii("Tipo")="M" then
                Produtos = ii("ItemID")
            end if
            if ii("Tipo")="S" then
                set iio = db.execute("SELECT group_concat(ProdutoID) produtos FROM itensinvoiceoutros WHERE ItemInvoiceID="& ItemInvoiceID)
                Produtos = iio("produtos")&""
            end if
        end if
    end if
    if ProdutoInvoiceID<>"" then
        set ii = db.execute("select ii.ItemID, ii.Tipo from itensinvoice ii LEFT JOIN sys_financialinvoices i ON ii.InvoiceID=i.id WHERE ii.id="& ProdutoInvoiceID)
        if not ii.eof then
            if ii("Tipo")="M" then
                Produtos = ii("ItemID")
            end if
            if ii("Tipo")="S" then
                set iio = db.execute("SELECT group_concat(ProdutoID) produtos FROM itensinvoiceoutros WHERE ItemInvoiceID="& ProdutoInvoiceID)
                Produtos = iio("produtos")&""
            end if
        end if
    end if
    if AtendimentoID<>"" then
        sqlpkit = "SELECT GROUP_CONCAT(pdk.ProdutoID) produtos FROM procedimentoskits pk LEFT JOIN produtosdokit pdk ON pdk.KitID=pk.KitID LEFT JOIN atendimentosprocedimentos ap ON ap.ProcedimentoID=pk.ProcedimentoID WHERE pk.Casos like '%|P|%' AND ap.id="& AtendimentoID
        'response.write(sqlpkit)
        set pkit = db.execute(sqlpkit)
        Produtos = pkit("Produtos")&""
    end if
    if Produtos="" then
        sqlProdutos = " AND 1=2 "
    else
        sqlProdutos = " AND id IN("& Produtos &") "
    end if
else
    set vcaCBID = db.execute("select ep.* from estoqueposicao ep LEFT JOIN produtoslocalizacoes pl ON pl.id=ep.LocalizacaoID where ep.CBID like '%"& BuscaProduto &"' AND ep.Quantidade>0"&sqlUnidadesUsuario&" LIMIT 1")
    if not vcaCBID.eof AND CD="C" then
        sqlProdutos = " AND 1=2 "
        %>
        <script type="text/javascript">
            lancar(<%=vcaCBID("ProdutoID")%>, 'S', '<%=vcaCBID("Lote")%>', '<%=vcaCBID("Validade")%>', <%=vcaCBID("id")%>, '<%=ItemInvoiceID%>', '<%=AtendimentoID%>', '<%=ProdutoInvoiceID%>');
        </script>
        <%
    else
        sqlBusca = " AND (NomeProduto like '%"& BuscaProduto &"%' OR Codigo LIKE '%"& BuscaProduto &"%')"
    end if
end if
%>

<div class="row">
	<div class="col-md-12">
    	<table class="table table-striped table-bordered table-hover">
        	<thead>
            	<tr>
                    <th colspan="2">Lançar movimentação de produto</th>
                </tr>
            </thead>
            <tbody>
            <%
            sql = "select id, NomeProduto from produtos where sysActive=1 "& sqlbusca & sqlProdutos &" order by NomeProduto"
            'response.write(sql)
            set prod = db.execute( sql )
			while not prod.eof
				%>
            	<tr>
                	<td><%=prod("NomeProduto")%></td>
                    <td width="1%"><button onclick="Posicao('<%=CD %>', <%= prod("id") %>)" class="btn btn-alert btn-sm"><i class="fa fa-exchange"></i></button></td>
                </tr>
                <%
				c=c+1
			prod.movenext
			wend
			prod.close
			set prod = nothing
			%>
            </tbody>
        </table>
    </div>
</div>
