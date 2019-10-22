<!--#include file="connect.asp"-->
<%

'FornecedorID=replace(ref("FornecedorID"),"2_","")
'if FornecedorID="" then
'	FornecedorID=0
'end if
FornecedorID=ref("FornecedorID")
call LanctoEstoque(0, req("PosicaoID"), req("P"), req("T"), ref("TipoUnidadeOriginal"), ref("TipoUnidade"), ref("Quantidade"), ref("Data"), FornecedorID, ref("Lote"), ref("Validade"), ref("NotaFiscal"), ref("Valor"), ref("UnidadePagto"), ref("Observacoes"), ref("Responsavel"), ref("PacienteID"), ref("Lancar"), ref("LocalizacaoID"), req("ItemInvoiceID"), req("AtendimentoID"), "eval", ref("CBID"), req("ProdutoInvoiceID"), ref("ResponsavelOriginal"), ref("LocalizacaoIDOriginal"), ref("Individualizar"), ref("CBIDs"), ref("InvoiceID"))
%>