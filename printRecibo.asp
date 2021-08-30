<!--#include file="connect.asp"-->
<!doctype html>
<html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <style>
            #areaImpressao table{
                width:100%;
                border: 2px solid black;
                border-collapse: collapse;
                table-layout: fixed;
                margin-bottom: 6px;
            }
            #areaImpressao tr{
                padding-left: 10px;
            }
            #areaImpressao th{
                text-align:left;
                background-color:#a3abad;
                padding-left: 10px;
                padding-top: 10px;
                padding-bottom: 30px;

            }
            #areaImpressao .inferior{
                border-bottom: 2px solid black;
            }
            #areaImpressao td{
                padding-left: 10px;
                padding-top: 10px;
                padding-bottom: 10px;
            }
  
        </style>
    </head> 
    <%
    sql =   " select                                                                                    "&chr(13)&_
            " 	p.NomeProduto as nomeProduto,                                                           "&chr(13)&_
            " 	coalesce(coi.valor,0) as valorUnitario,                                                 "&chr(13)&_
            " 	coalesce(coi.quantidade,0) as Quantidade,                                               "&chr(13)&_
            " 	coalesce(el.quantidadeTotal,0) as quantidadeTotal,                                      "&chr(13)&_
            " 	coalesce (nullif(pl.UnidadeID,0),e.id) localizacaoid,                                   "&chr(13)&_
            " 	coalesce(if(pl.UnidadeID=0,e.NomeEmpresa,sfcu.NomeFantasia),'Não informada')nomeUnidade,"&chr(13)&_
            " 	coalesce(pl.NomeLocalizacao,'Não informada') NomeLocalizacao,                           "&chr(13)&_
            " 	if(coalesce(pl.UnidadeID,0)=0,e.CNPJ,sfcu.CNPJ ) cnpj,                                  "&chr(13)&_
            " 	csi.ordemDeCompraId as ordemDeCompra,                                                   "&chr(13)&_
            " 	el.id as sequencia,                                                                     "&chr(13)&_
            " 	el.Observacoes as observacoes,                                                          "&chr(13)&_
            " 	coalesce(nullif(el.Responsavel,''),'Não Informado') as Responsavel,                     "&chr(13)&_
            " 	conf.notaFiscal as notafiscal                                                           "&chr(13)&_
            " from                                                                                      "&chr(13)&_
            " 	estoquelancamentos el                                                                   "&chr(13)&_
            " left join produtos p on el.ProdutoID = p.id                                               "&chr(13)&_
            " left join compras_solicitacao_item csi on csi.produtoId = p.id                            "&chr(13)&_
            " left join compras_ordem_item coi on coi.id = csi.comprasSolicitacaoId                     "&chr(13)&_
            " left join produtoslocalizacoes pl on el.LocalizacaoID = pl.id                             "&chr(13)&_
            " left join sys_financialcompanyunits sfcu on pl.UnidadeID = sfcu.id                        "&chr(13)&_
            " left join compras_ordem_nota_fiscal conf on coi.ordemNotaFiscalId = conf.id               "&chr(13)&_
            " join empresa e                                                                            "&chr(13)&_
            " where                                                                                     "&chr(13)&_
            " 	el.id = 63                                                                              "

    set dados = db.execute(sql)

    hoje  = formatdatetime(date(),2)
    if not dados.eof then
%>
    <body >
        <table id="areaImpressao">
            <tr class="inferior">
                <td colspan='5'><img style="width: 100%;"src="https://functions.feegow.com/load-image?licenseId=8437&folder=Arquivos&file=f3dbf652fb224b4c6f70be3a447945a6.PNG&renderMode=redirect&cache-prevent=1630253583&dimension=full"/></td>
                <td colspan='7'><h2> Nota de Tranferência</h2></td> 
            </tr>
            <tr>
                <td colspan='4'><strong>Nota Fiscal:</strong>&nbsp;<%=dados("notafiscal")%></td>
                <td colspan='4'><strong>Série:</strong>&nbsp;T </td>
                <td colspan='4'><strong>Data emissão:</strong>&nbsp;<%=hoje%></td>
            </tr>
            <tr>
                <td colspan='8'><strong>Sequência:</strong>&nbsp;<%=dados("sequencia")%></td>
                <td colspan='4'><strong>Entrada/Saída:</strong>&nbsp;<%=hoje%></td> 
            </tr>
            <tr>
                <td colspan='8'><strong>Ordem de compra:</strong>&nbsp;<%=dados("ordemDeCompra")%></td>
                <td colspan='4'><strong>Atual estoque:</strong>&nbsp;<%=hoje%></td>
            </tr>
            <tr>
                <td colspan='8'><strong>CNPJ emitente</strong>&nbsp;<%=dados("cnpj")%> - <%=dados("nomeUnidade")%></td>
                <td colspan='4'><strong>Cond. pagto:</strong>&nbsp;Tranferência</td>
            </tr>
            <tr>
                <td colspan='8'><strong>Natureza:</strong>&nbsp;<%=dados("observacoes")%> </td>
                <td colspan='4'><strong>Operação nota:</strong>&nbsp;Tranferência</td>
            </tr>
            <tr class="inferior">
                <td colspan='12'><strong>Solicitante:</strong>&nbsp;<%=dados("Responsavel")%></td>
            </tr>
            <tr>
                <th colspan='2'><strong>Material Descrição</strong></th>
                <th colspan='2'><strong>VI. unitário:</strong></th>
                <th colspan='4'><strong>Quantidade:</strong></th>
                <th colspan='4'><strong>Total item local estoque:</strong></th>
            </tr>
            <tr height="100" class="inferior">
                <td colspan='2'><%=dados("nomeProduto")%></td>
                <td colspan='2'><%=fn(ccur(dados("valorUnitario")))%></td>
                <td colspan='4'><%=dados("Quantidade")%></td>
                <td colspan='4'><%=dados("quantidadeTotal")%> - <%=dados("NomeLocalizacao")%></td>
            </tr>
            <tr height="30" >
                <td colspan='2'><strong>Mercadoria</strong></td>
                <% total =  fn(ccur(dados("valorUnitario"))*cint(dados("Quantidade"))) %>
                <td colspan='2'><%=total%></td>
                <td colspan='2'><strong>Frete:</strong></td>
                <td colspan='2'>00,00</td>
                <td colspan='2'><strong>Seguro</strong></td>
                <td colspan='2'>00,00</td>
            </tr>
            <tr height="100">
                <td colspan='2'><strong>Assessoria</strong></td>
                <td colspan='2'>00,00</td>
                <td colspan='2'><strong>IPI</strong></td>
                <td colspan='2'>00,00</td>
                <td colspan='1'><strong>Descontos</strong></td>
                <td colspan='1'>00,00</td>
                <td colspan='1'><strong>Total nota</strong></td>
                <td colspan='1'><%=total%></td>
            </tr>
        </table>
    </body>
    <% end if %>
</html>

<script type="text/javascript">
setTimeout(() => {
    print();
}, 500);
</script>