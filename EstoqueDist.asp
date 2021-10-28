<!--#include file="connect.asp"-->
<%
P = req("P")
TipoLancto = req("T")

PosicaoID = req("PosicaoID")

MovimentacaoEmLote = False

if instr(PosicaoID,",")>0 then
    MovimentacaoEmLote=True
end if

sqlProd = "select p.*, u.* from produtos as p left join cliniccentral.tissunidademedida as u on p.ApresentacaoUnidade=u.id where p.id="&P
set prod = db.execute(sqlProd)
if len(prod("Descricao"))>6 then
	NomeUnidade = right(prod("Descricao"), len(prod("Descricao"))-6 )&"(s)"
end if
if TipoLancto="E" then
	tipo = "Entrada"
	icone = "far fa-level-down"
	tipoValor = "Compra"
	if not isnull(prod("PrecoCompra")) then
		valor = formatnumber(prod("PrecoCompra"),2)
	end if
    LocalizacaoPadrao = prod("LocalizacaoID")
else
	tipo = "Sa&iacute;da"
	icone = "far fa-level-up"
	tipoValor = "Venda"
	if not isnull(prod("PrecoVenda")) then
		valor = formatnumber(prod("PrecoVenda"),2)
	end if
    PosicaoID = req("PosicaoID")
    set pos = db.execute("select * from estoqueposicao where id in ("& PosicaoID&")")
    if not pos.eof then
        TipoUnidade = pos("TipoUnidade")
        TipoUnidadeOriginal = pos("TipoUnidade")
        ResponsavelOriginal = pos("Responsavel")
        Responsavel = pos("Responsavel")
        Validade = pos("Validade")
        Lote = pos("Lote")
        LocalizacaoID = pos("LocalizacaoID")
        LocalizacaoIDOriginal = pos("LocalizacaoID")
        CBID = pos("CBID")
    end if
end if
Quantidade=1
Responsavel=""

if req("L")<>"" then
    LocalizacaoID = req("L")
    Responsavel=accountUser(session("User"))
end if
if req("Q")<>"" then
    Quantidade = req("Q")
end if

ApresentacaoQuantidade = prod("ApresentacaoQuantidade")
if isnull(ApresentacaoQuantidade) then ApresentacaoQuantidade=1 end if

ApresentacaoNome = prod("ApresentacaoNome")
if isnull(ApresentacaoNome) or ApresentacaoNome="" then
	ApresentacaoNome="Conjunto"
end if

LocaisEntradas = prod("LocaisEntradas")&""
if LocaisEntradas&""<>"" then
    sqlLocalizacoes = " AND id IN ("&replace(LocaisEntradas, "|", "")&") "
end if
%>
<div class="modal-header">
    <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
    <h4 class="modal-title"><i class="far fa-retweet"></i> Movimentação de Produto &raquo; <small><%=prod("NomeProduto")%></small></h4>
</div>
<form id="EstoqueMovimentacao" name="EstoqueMovimentacao" method="post">
<div class="modal-body">
    <%
    if MovimentacaoEmLote then
        %>
<div class="row">

<div class="col-md-12 mb20">
    <h4>Movimentação em lote</h4>
    <table class="table table-bordered">
        <thead>
            <tr class="primary">
                <th>Código</th>
                <th>Lote</th>
                <th>Localização atual</th>
                <th>Validade</th>
                <th>Responsável</th>
                <th>Quantidade</th>
            </tr>
        </thead>
        <tbody>
            <%
            set PosicaoSQL = db.execute("select ep.*, ep.id PosicaoID,  pl.NomeLocalizacao, p.ApresentacaoNome, um.Descricao ApresentacaoUnidadeNome from estoqueposicao ep inner join produtos p ON p.id=ep.ProdutoID left join cliniccentral.tissunidademedida um ON um.id=p.ApresentacaoUnidade left join produtoslocalizacoes pl on pl.id=ep.LocalizacaoID where ep.id in ("& PosicaoID&")")
            while not PosicaoSQL.eof
                PosicaoIDProd = PosicaoSQL("PosicaoID")
                TipoUnidade = PosicaoSQL("TipoUnidade")
                NomeLocalizacao = PosicaoSQL("NomeLocalizacao")
                TipoUnidadeOriginal = PosicaoSQL("TipoUnidade")
                ResponsavelOriginal = PosicaoSQL("Responsavel")
                Responsavel = PosicaoSQL("Responsavel")
                Validade = PosicaoSQL("Validade")
                Lote = PosicaoSQL("Lote")
                LocalizacaoID = PosicaoSQL("LocalizacaoID")
                LocalizacaoIDOriginal = PosicaoSQL("LocalizacaoID")
                CBID = PosicaoSQL("CBID")

                Quantidade = PosicaoSQL("Quantidade")
                Conjunto = PosicaoSQL("ApresentacaoNome")
                unidade = PosicaoSQL("ApresentacaoUnidadeNome")
                %>
                <tr>
                    <input type="hidden" value="<%=TipoUnidadeOriginal%>" name="TipoUnidadeOriginal-<%=PosicaoIDProd%>">
                    <td><%=CBID%> <input type="hidden" value="<%=CBID%>" name="CBID-<%=PosicaoIDProd%>"> </td>
                    <td><%=Lote%> <input type="hidden" value="<%=Lote%>" name="Lote-<%=PosicaoIDProd%>"></td>
                    <td><%=NomeLocalizacao%> <input type="hidden" value="<%=LocalizacaoIDOriginal%>" name="LocalizacaoIDOriginal-<%=PosicaoIDProd%>"></td>
                    <td><%=Validade%></td>
                    <td><%=accountName("", Responsavel)%> <input type="hidden" value="<%=Responsavel%>" name="Responsavel-<%=PosicaoIDProd%>"></td>
                    <td><%=descQuant(Quantidade, TipoUnidade, conjunto, unidade)%></td>
                </tr>
                <%
            PosicaoSQL.movenext
            wend
            PosicaoSQL.close
            set PosicaoSQL=nothing
            %>
        </tbody>
    </table>
</div>
</div>
        <%
    end if
    %>
    <div class="row">
        <%=quickField("number", "Quantidade", "Quantidade", 2, Quantidade, " text-right", "", " input-mask-brl min='0' onkeyup='ind()'")%>
        <div class="col-md-4"><br>
        	<%if TipoUnidade="C" or TipoLancto="E" then %>
            <label><input class="ace" type="radio" name="TipoUnidade" required="required" value="C"<%if prod("Tipo"&tipoValor)="C" then%> checked<%end if%>><span class="lbl"> <%=ApresentacaoNome%> com <%=formatnumber(ApresentacaoQuantidade,2)%>&nbsp;<%=lcase(NomeUnidade)%></span></label>
            <br>
            <%end if %>
        	<label><input class="ace" type="radio" name="TipoUnidade" required="required" value="U"<%if prod("Tipo"&tipoValor)="U" or TipoUnidade="U" then%> checked<%end if%>><span class="lbl"> <%=QuantidadeNoConjunto%> <%=NomeUnidade%></span></label>
        </div>
        <%=quickField("datepicker", "Data", "Data", 3, date(), "", "", "")%>
<%

    response.write("<input type='hidden' name='ResponsavelOriginal' value='"& ResponsavelOriginal &"'>")
    response.write("<input type='hidden' name='Validade' value='"& Validade &"'>")
    response.write("<input type='hidden' name='Lote' value='"& Lote &"'>")
    response.write("<input type='hidden' name='LocalizacaoIDOriginal' value='"& LocalizacaoIDOriginal &"'>")
    response.write("<input type='hidden' name='CBID' value='"& CBID &"'>")
    response.write("<input type='hidden' name='TipoUnidadeOriginal' value='"& TipoUnidadeOriginal &"'>")
    
    
%>
    </div>
    <div class="row">
        <div class="col-md-3">
            <label>Responsável</label><br />
            <%=selectInsertCA("", "Responsavel", Responsavel, "5, 4, 2, 6, 1", "", "", "")%>
        </div>
            <div class="col-md-3">
            <%
            if LocaisEntradas&""<>"" then
                call quickField("simpleSelect", "LocalizacaoID", "Localização", 12, LocalizacaoID, "select * from produtoslocalizacoes where sysActive=1 "&sqlLocalizacoes&" order by NomeLocalizacao", "NomeLocalizacao", "")
            else
                call selectInsert("Localização", "LocalizacaoID", LocalizacaoID, "produtoslocalizacoes", "NomeLocalizacao", "", "", "")
            end if
            %>
            </div>
            <div class="col-md-2">
                <br />
                <div class="checkbox-custom checkbox-primary">
                    <input type="checkbox" id="Individualizar" name="Individualizar" onclick="ind()" value="S" /><label for="Individualizar">Individualizar</label>
                </div>
            </div>
    </div>





        <div class="row">
			<%=quickField("memo", "Observacoes", "Observa&ccedil;&otilde;es", 12, "", "", "", "")%>
        </div>
        <div class="row">
            <div class="col-md-12" id="divIndividualizar">
            </div>

        </div>
</div>
<div class="modal-footer no-margin-top">
	<button class="btn btn-sm btn-success " id="lancar"><i class="far fa-save"></i> Salvar</button>
</div>
</form>
<script type="text/javascript">
<!--#include file="jQueryFunctions.asp"-->

$("#EstoqueMovimentacao").submit(function(){
	$.ajax({
		type:"POST",
		url:"saveEstoqueLancamento.asp?P=<%=P%>&T=M&PosicaoID=<%=PosicaoID%>&MovimentacaoEmLote=<%=MovimentacaoEmLote%>",
		data:$(this).serialize(),
		success: function(data){
			eval(data);
		}
	});
	return false;
});

function ind() {
    if ($("#Individualizar").prop("checked")==true) {
        $.post("EstoqueIndividualizar.asp?q=" + $("#Quantidade").val() + "&ProdutoID=<%=req("P")%>", "", function (data) {
            $("#divIndividualizar").html(data);
        });
    } else {
        $("#divIndividualizar").html("");
    }
}

$(".select2-single").select2();
</script>