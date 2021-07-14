<!--#include file="connect.asp"-->
<%

'FornecedorID=replace(ref("FornecedorID"),"2_","")
'if FornecedorID="" then
'	FornecedorID=0
'end if
FornecedorID=ref("FornecedorID")
MovimentacaoEmLote = req("MovimentacaoEmLote")
PosicaoID=req("PosicaoID")

if PosicaoID="" then
    PosicaoID="0"
end if
spltPosicao = split(PosicaoID,",")

for i=0 to ubound(spltPosicao)
    PosicaoID= spltPosicao(i)
    PrefixoRef = ""

    if PosicaoID&""<>"0" and MovimentacaoEmLote="True" then
        PrefixoRef = "-"&PosicaoID

        response.write(PrefixoRef)
    end if

    TipoUnidadeOriginal=ref("TipoUnidadeOriginal"&PrefixoRef)
    Lote=ref("Lote"&PrefixoRef)
    ResponsavelOriginal=ref("ResponsavelOriginal"&PrefixoRef)
    LocalizacaoIDOriginal=ref("LocalizacaoIDOriginal"&PrefixoRef)
    CBID=ref("CBID"&PrefixoRef)

    call LanctoEstoque(0, PosicaoID, req("P"), req("T"), TipoUnidadeOriginal, ref("TipoUnidade"), ref("Quantidade"), ref("Data"), FornecedorID, Lote, ref("Validade"), ref("NotaFiscal"), ref("Valor"), ref("UnidadePagto"), ref("Observacoes"), ref("Responsavel"), ref("PacienteID"), ref("Lancar"), ref("LocalizacaoID"), req("ItemInvoiceID"), req("AtendimentoID"), "eval", CBID, req("ProdutoInvoiceID"), ResponsavelOriginal, LocalizacaoIDOriginal, ref("Individualizar"), ref("CBIDs"), ref("InvoiceID"),ref("Motivo"))
next
%>