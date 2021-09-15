<!--#include file="connect.asp"-->
<%
P = req("P")
TipoLancto = req("T")
ItemInvoiceID = req("ItemInvoiceID")
ProdutoInvoiceID = req("ProdutoInvoiceID")
AtendimentoID = req("AtendimentoID")
Motivo = req("Motivo")
Quantidade = 1
if ItemInvoiceID="undefined" then
    ItemInvoiceID = ""
end if
if ProdutoInvoiceID="undefined" then
    ProdutoInvoiceID = ""
end if


set prod = db.execute("select p.*, u.* from produtos as p left join cliniccentral.tissunidademedida as u on p.ApresentacaoUnidade=u.id where p.id="&P)
if len(prod("Descricao"))>6 then
	NomeUnidade = right(prod("Descricao"), len(prod("Descricao"))-6 )&"(s)"
end if

if prod("sysActive")<>1 then
    %>
    <div class="row">
        <div class="col-md-12 p20">
            <strong>Atenção!</strong> Salve o produto antes de registrar uma entrada.
        </div>
    </div>
    <%
    response.end
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
    set pos = db.execute("select ep.*, pl.NomeLocalizacao from estoqueposicao ep left join produtoslocalizacoes pl ON ep.LocalizacaoID=pl.id where ep.id="& PosicaoID)
    if not pos.eof then
        TipoUnidade = pos("TipoUnidade")
        TipoUnidadeOriginal = pos("TipoUnidade")
        ResponsavelOriginal = pos("Responsavel")
        Responsavel = pos("Responsavel")
        Validade = pos("Validade")
        Lote = pos("Lote")
        LocalizacaoID = pos("LocalizacaoID")
        if pos("NomeLocalizacao")&""<>"" then
            NomeLocalizacao = " ("&pos("NomeLocalizacao")&")"
        end if
        LocalizacaoIDOriginal = pos("LocalizacaoID")
        CBID = pos("CBID")
    end if
end if
UnidadePagto = prod("Tipo"&tipoValor)

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
<input type="hidden" id="validationConfig" value="<%=getConfig("Motivo")%>">
<div class="modal-header">
    <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
    <h4 class="modal-title"><i class="<%=icone%>"></i> Lan&ccedil;amento de <%=tipo%> &raquo; <small><%=prod("NomeProduto")&NomeLocalizacao%></small></h4>
</div>
<div class="modal-body">
<form id="EstoqueLancamento" name="EstoqueLancamento" method="post">
<div class="alert alert-danger" id="notifyy" role="alert">

</div>
<%
'if ItemInvoiceID<>"" then
 '    set ii = db.execute("select ValorUnitario, Quantidade, Executado, Desconto, Acrescimo from itensinvoice where id="& ItemInvoiceID)
 '    if not ii.eof then
 '        Quantidade = ii("Quantidade")
 '        TipoUnidade = ii("Executado")
 '        UnidadePagto = ii("Executado")
 '        Valor = ii("ValorUnitario")-ii("Desconto")+ii("Acrescimo")
 '    end if
 'end if
if ProdutoInvoiceID<>"" and ProdutoInvoiceID<>"undefined" then
    set ii = db.execute("select ValorUnitario, Quantidade, Executado, Desconto, Acrescimo from itensinvoice where id="& ProdutoInvoiceID)
    if not ii.eof then
        Quantidade = ii("Quantidade")
        TipoUnidade = ii("Executado")
        UnidadePagto = ii("Executado")
        Valor = ii("ValorUnitario")-ii("Desconto")+ii("Acrescimo")
    end if
end if
%>
    <div class="row">
        <%=quickField("number", "Quantidade", "Quantidade", 2, Quantidade, " text-right", "", " min='0' ")%>
        <div class="col-md-4"><br>
        	<%if TipoUnidade="C" or TipoLancto="E" then %>
            <label><input class="ace" type="radio" checked name="TipoUnidade" required="required" value="C"<%if prod("Tipo"&tipoValor)="C" then%> checked<%end if%>><span class="lbl"> <%=ApresentacaoNome%> com <%=formatnumber(ApresentacaoQuantidade,2)%>&nbsp;<%=lcase(NomeUnidade)%></span></label>
            <br>
            <%end if %>
        	<label><input class="ace" type="radio" name="TipoUnidade" required="required" value="U"<%if prod("Tipo"&tipoValor)="U" or TipoUnidade="U" then%> checked<%end if%>><span class="lbl"> <%=QuantidadeNoConjunto%> <%=NomeUnidade%></span></label>
        </div>
        <%=quickField("currency", "Valor", "Valor de "&tipoValor, 2, Valor, "", "", "")%>
        <div class="col-md-4" id="qfunidadepagto"><br>
            <label><input class="ace" type="radio" name="UnidadePagto" value="C" required<%if UnidadePagto="C" then%> checked<%end if%>><span class="lbl"> Por <%=lcase(ApresentacaoNome)%> com <%=formatnumber(ApresentacaoQuantidade,2)%>&nbsp;<%=lcase(NomeUnidade)%></span></label><br>
            <label><input class="ace" type="radio" name="UnidadePagto" value="U" required<%if UnidadePagto="U" then%> checked<%end if%>><span class="lbl"> Por <%=lcase(QuantidadeNoConjunto)%> <%=NomeUnidade%></span></label>
        </div>

    </div>
    <div class="row">
        <%=quickField("datepicker", "Data", "Data", 3, date(), "", "", "")%>
        <%
        if ProdutoInvoiceID="" then
            %>
            <%= quickfield("text", "NotaFiscal", "Nota fiscal", 3, "", "", "", "") %>
            <%
        end if
        %>
    </div>
    <%
    if TipoLancto="E" then
		%>
        <div class="row">

            <div class="col-md-3">
            <%
            if LocaisEntradas&""<>"" then
                call quickField("simpleSelect", "LocalizacaoID", "Localização", 12, 0, "select * from produtoslocalizacoes where sysActive=1 "&sqlLocalizacoes&" order by NomeLocalizacao", "NomeLocalizacao", "")
            else
                call selectInsert("Localização", "LocalizacaoID", 0, "produtoslocalizacoes", "NomeLocalizacao", "", "", "")
            end if
            %>
            </div>
            <div class="col-md-3">
                <%=selectInsertCA("Responsável", "Responsavel", Responsavel, "5, 4, 2, 6, 1, 3", "", "", "")%>
            </div>
            <%=quickField("text", "Lote", "Lote", 3, "", "", "", "")%>
            <%if ProdutoInvoiceID="" then %>
                <div class="col-md-3">
                    <%=selectInsertCA("Fornecedor", "FornecedorID", FornecedorID, "2, 5, 4, 3", "", " onchange=onchangeFornecedor(this) ", "")%>
                </div>
            <%end if %>
            <%=quickField("datepicker", "Validade", "Validade", 3, "", "", "", "")%>
            <%
                call quickfield("text", "CBID", "Código Individual", 3, "", "", "", "")
            %>


        </div>
        <div class="row">
            <%= quickfield("simpleSelect", "Motivo", "Motivo", 4, "", "SELECT * FROM cliniccentral.estoque_fluxo where tipo='entrada' and sysActive = 1 order by id ASC", "Motivo", "required onchange=""habilitapaciente();""") %>
            <div class="col-md-6" id="comboPaciente">
                <%= selectInsert("Paciente", "PacienteID", PacienteID, "pacientes", "NomePaciente", "", "", "") %>
            </div>
        </div>
		<%
    else
        response.write("<input type='hidden' name='Responsavel' value='"& Responsavel &"'>")
        response.write("<input type='hidden' name='ResponsavelOriginal' value='"& ResponsavelOriginal &"'>")
        response.write("<input type='hidden' name='Validade' value='"& Validade &"'>")
        response.write("<input type='hidden' name='Lote' value='"& Lote &"'>")
        response.write("<input type='hidden' name='LocalizacaoID' value='"& LocalizacaoID &"'>")
        response.write("<input type='hidden' name='LocalizacaoIDOriginal' value='"& LocalizacaoIDOriginal &"'>")
        response.write("<input type='hidden' name='CBID' value='"& CBID &"'>")
        response.write("<input type='hidden' name='TipoUnidadeOriginal' value='"& TipoUnidadeOriginal &"'>")
	end if
    if TipoLancto="S" then
        pedePac = 0
        if AtendimentoID="" and ItemInvoiceID="" and ProdutoInvoiceID="" then
            pedePac = 1
        else
            if AtendimentoID<>"" then
                sql = "SELECT a.PacienteID FROM atendimentosprocedimentos ap LEFT JOIN atendimentos a ON a.id=ap.AtendimentoID WHERE ap.id="& AtendimentoID
            elseif ItemInvoiceID<>"" then
                sql = "SELECT i.AccountID PacienteID FROM itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID WHERE i.AssociationAccountID=3 AND ii.id="& ItemInvoiceID
            elseif ProdutoInvoiceID<>"" then
                sql = "SELECT i.AccountID PacienteID FROM itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID WHERE i.AssociationAccountID=3 AND ii.id="& ProdutoInvoiceID
            end if
            set busPac = db.execute( sql )
            if not busPac.eof then
                PacienteID = busPac("PacienteID")
                pedePac = 0
            else
                pedePac = 1
            end if
        end if
        combomotivo =  quickfield("simpleSelect", "Motivo", "Motivo", 4, "", "SELECT * FROM cliniccentral.estoque_fluxo WHERE tipo='saida' AND sysActive=1 ORDER BY id ASC", "Motivo", "required onchange=""habilitapaciente();""")
        response.write (combomotivo)
        if pedePac=0 then
            %>
               <input type="hidden" name="PacienteID" value="<%= PacienteID %>" />
            <%
        else
            %>
            <div class="col-md-3" id="comboPaciente">
                <%= selectInsert("Paciente", "PacienteID", PacienteID, "pacientes", "NomePaciente", "", "", "") %>
            </div>
            <%
        end if
        %>


   <% end if %>

        <div class="row">
			<%=quickField("memo", "Observacoes", "Observa&ccedil;&otilde;es", 12, "", "", "", "")%>
        </div>

        <hr class="short alt" />

        <%if ProdutoInvoiceID="" and TipoLancto="E" then %>
            <div class="row">
                <div class="col-md-12 checkbox-custom checkbox-primary">
                    <input type="checkbox" name="Lancar" onchange="changeLancar(this.checked)" id="Lancar" value="S" /><label for="Lancar"> Lançar no contas a pagar.</label>
                </div>
            </div>
        <%end if %>

        <%if ProdutoInvoiceID="" and TipoLancto="S" then %>
            <div class="row">
                <div class="col-md-12 checkbox-custom checkbox-primary">
                    <input type="checkbox" name="Lancar" id="Lancar" value="S" /><label for="Lancar"> Lançar na conta do paciente.</label>
                </div>
            </div>
        <%end if %>
        <div class="possibilidades" style="margin-top: 10px">

        </div>
</form>
</div>
<div class="modal-footer no-margin-top">
    <%
    if ItemInvoiceID<>"" or ProdutoInvoiceID<>"" then
        %>
        <button type="button" onclick="modalEstoque('<%= ItemInvoiceID %>', <%= req("P") %>, '<%= ProdutoInvoiceID %>')" class="btn btn-default btn-sm"><i class="far fa-chevron-left"></i> Voltar</button>
        <%
    end if
    %>
	<button class="btn btn-sm btn-success pull-right" type="button" id="lancar"><i class="far fa-save"></i> Salvar</button>
</div>
<script type="text/javascript">
<!--#include file="jQueryFunctions.asp"-->
function onchangeFornecedor(arg){
    setTimeout(() =>{
        changeLancar($("#Lancar").is(":checked"))
    },200)

}
function changeLancar(value){
    $(".possibilidades").html("");

    if(value)
    {
        if(!$("#FornecedorID").val()){
            return;
        }

        if($("#FornecedorID").val() === "0"){
            return;
         }

        let valores = ($("#FornecedorID").val()+"").split("_");
        $.ajax({
       		type:"GET",
       		url:`ListaDeContasParaEstoque.asp?AccountIDDebit=${valores[1]}&AccountAssociationIDDebit=${valores[0]}`,
       		success: function(data){
       		    $(".possibilidades").html(data);
       		}
       	});
    }
}

$("#notifyy").hide();
$("#lancar").click(function(){
    if($("#validationConfig").val() == 1)
    {
        if(verificaCampoVazio() === true){
             $("#notifyy").show();
             return false;
        }
    }
    $("#lancar").attr("disabled", true);

        $.ajax({
            type:"POST",
            url:"saveEstoqueLancamento.asp?P=<%=P%>&T=<%=TipoLancto%>&PosicaoID=<%=PosicaoID%>&ItemInvoiceID=<%=ItemInvoiceID%>&ProdutoInvoiceID=<%=ProdutoInvoiceID%>&AtendimentoID=<%=AtendimentoID%>&Motivo=<%=Motivo%>",
            data:$("#EstoqueLancamento").serialize(),
            success: function(data){
                eval(data);
                $("#lancar").attr("disabled", false)
            }
        });

});
function verificaCampoVazio()
{
        $("#notifyy").html();
        let erro = false;
        let motivo = $("#EstoqueLancamento #Motivo").val();
        let FornecedorID = $("#FornecedorID").val();
        let Responsavel = $("#Responsavel").val();
        if(motivo == 0)
        {
            erro = true;
            $("#notifyy").append("<p>Preencha o campo <b>Motivo</b></p>")
        }
        // if(FornecedorID == 0 || FornecedorID == "")
        // {
        //     erro = true;
        //         //$("#notifyy").show();
        //         $("#notifyy").append("<p>Preencha o campo <b>Fornecedor</b></p>")
        //         //return false
        // }
        // if(Responsavel == 0 || Responsavel == "")
        // {
        //     erro = true;
        //         //$("#notifyy").show();
        //         $("#notifyy").append("<p>Preencha o campo <b>Reponsavel</b></p>")
        //         //return false
        // }
       return erro;
}
// $('#comboPaciente').hide();
function habilitapaciente()
{
    
    if ($( "#Motivo option:selected" ).val() =='8' || $( "#Motivo option:selected" ).val() =='9' || $('#Lancar').is(":checked"))
    {
        $('#comboPaciente').show();
    }
    else
    {
        $('#comboPaciente').hide();
    }
}



<%
if AtendimentoID<>"" or ItemInvoiceID<>"" or ProdutoInvoiceID<>"" then
    %>
        $("#qfunidadepagto, #qfvalor, #qfnotafiscal").css("display", "none");
    <%
end if
%>

$("#Lancar").click(function () {
    if ($(this).prop("checked")==true) {
        $("#qfunidadepagto, #qfvalor, #qfnotafiscal").css("display", "block");
    } else {
        $("#qfunidadepagto, #qfvalor, #qfnotafiscal").css("display", "none");
    }
});

$(".select2-single").select2();
</script>