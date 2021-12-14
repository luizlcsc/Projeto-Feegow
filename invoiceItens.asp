<!--#include file="connect.asp"-->
<%
IF not aut("PodeDescontoV")   = "1"  THEN
  displayDesconto = "display:none"
END IF
IF not aut("PodeAcrescimoV") = "1"  THEN
  displayAcrescimo = "display:none"
END IF

InvoiceID=req("I")
Acao = ref("A")
Tipo = ref("T")
LimitarPlanoContas = ref("LimitarPlanoContas")
if Tipo="P" then
    Tipo = "S"
end if
II = ref("II")
Row = req("Row")
PacoteID = ""
if Row<>"" then
	Row=ccur(Row)
end if
desabilitarExclusaoItem = ""

titleNotaFiscal = ""
if recursoAdicional(34) = 4 then
    set existeNotaEmitida = db.execute("select id from nfse_emitidas where invoiceid ="&InvoiceID&" and Status = 3")
    if not existeNotaEmitida.eof then
        desabilitarExclusaoItem = " disabled "
        titleNotaFiscal = "Existe nota com status autorizada"
    end if
end if

TemRegrasDeDesconto=False

set TemRegrasDeDescontoSQL = db_execute("SELECT rd.id FROM regrasdescontos rd INNER JOIN regraspermissoes rp ON rp.id=rd.RegraID LIMIT 1")
if not TemRegrasDeDescontoSQL.eof then
    TemRegrasDeDesconto=True
end if

set ValorPagoSQL = db_execute("SELECT SUM(IFNULL(ValorPago,0)) ValorPago FROM sys_financialmovement WHERE InvoiceID="&InvoiceID)

sqlintegracao = " SELECT lia.id, lie.StatusID FROM labs_invoices_amostras lia "&_
				" inner JOIN labs_invoices_exames lie ON lia.id = lie.AmostraID "&_
				" WHERE lia.InvoiceID = "&treatvalzero(InvoiceID)&" AND lia.ColetaStatusID <> 5 "
set integracaofeita = db_execute(sqlintegracao)

if not ValorPagoSQL.eof then
    if ValorPagoSQL("ValorPago")>0 and session("Admin")=0 then
        NaoPermitirAlterarExecutante=getConfig("NaoPermitirAlterarExecutante")
    end if
end if

ExecutantesTiposAjax = "5, 8, 2"
if session("Banco")="clinic6118" then
    ExecutantesTiposAjax = "5"
end if

if Acao="" then
	%>
	<table width="100%" class="duplo table table-striped table-condensed">
		<thead>
			<tr class="info">
				<th width="7%">Quant.</th>
				<th>Item</th>
                <th id="hPlanoContas"></th>
                <th width="100px" id="hCentroCusto">
                        <span class="checkbox-custom checkbox-primary all-checkbox-executado hidden" style="display: none"><input type="checkbox" onchange="selectAllExecutados(this.checked)" class="all-checkbox-executado" name="TodosExecutado" id="TodosExecutado" /><label  for="TodosExecutado">&nbsp;</label></span>
                </th>
				<th width="15%">Valor Unit.</th>
				<th width="11%"><span style="<%=displayDesconto%>">Desconto</span></th>
				<th width="11%"><span style="<%=displayAcrescimo%>">Acr&eacute;scimo</span></th>
				<th width="9%">Total</th>
				<th width="1%"></th>
				<th width="1%"></th>
				<th width="1%"></th>
			</tr>
			<script>
			    function selectAllExecutados(arg){
			        if(!arg){
			            $(".checkbox-executado:checked").click()
			        }
			        if(arg){
                        $(".checkbox-executado:not(:checked)").click()
                    }
			    }
            </script>
		</thead>
		<tbody>
		<%

		conta = 0
		Total = 0
		Subtotal = 0
        response.Buffer

		set itens = db_execute("select ii.*, left(md5(ii.id), 7) as senha, dp.Desconto DescontoPendente, dp.Status StatusDesconto, i.Voucher, i.DataCancelamento from itensinvoice ii LEFT JOIN descontos_pendentes dp ON dp.ItensInvoiceID=ii.id JOIN sys_financialinvoices i ON i.id=ii.InvoiceID where ii.InvoiceID="&InvoiceID&" order by ii.id")

        ExistemDescontosPendentes = False
        DataCancelamento=""

		if not itens.eof then
            Voucher = itens("Voucher")
		    set FornecedorSQL = db_execute("SELECT f.limitarPlanoContas FROM fornecedores f INNER JOIN sys_financialinvoices i ON i.AccountID=f.id WHERE i.AssociationAccountID=2 AND f.limitarPlanoContas != '' and f.limitarPlanoContas is not null AND i.id="&InvoiceID)

		    if not FornecedorSQL.eof then
		        LimitarPlanoContas = FornecedorSQL("limitarPlanoContas")
		    end if



            while not itens.eof
                response.Flush()
                conta = conta+itens("Quantidade")
                StatusDesconto = itens("StatusDesconto")
                DescontoPendente = itens("DescontoPendente")
                if not isnull(StatusDesconto) then
                    if StatusDesconto&""="0" then
                        ExistemDescontosPendentes = True
                    end if
                end if
                if itens("Executado")="C" then
                    DataCancelamento = "1"
                else
                    DataCancelamento = ""
                end if


                Subtotal = itens("Quantidade")*(itens("ValorUnitario")-itens("Desconto")+itens("Acrescimo"))
                Total = Total+Subtotal
                NomeItem = ""
				integracaopleres = "N"
                if itens("Tipo")="S" then
                    set pItem = db_execute("select NomeProcedimento NomeItem, integracaoPleres  from procedimentos where id="&itens("ItemID"))
                    if not pItem.eof then
                        NomeItem = pItem("NomeItem")
						integracaopleres = pItem("integracaoPleres")
                    end if
                elseif itens("Tipo")="M" then
                    set pItem = db_execute("select NomeProduto NomeItem from produtos where id="&itens("ItemID"))
                    if not pItem.eof then
                        NomeItem = pItem("NomeItem")
                    end if
                elseif itens("Tipo")="O" then
                    NomeItem = itens("Descricao")
                end if
                id = itens("id")
                Quantidade = itens("Quantidade")
                ItemID = itens("ItemID")
                CategoriaID = itens("CategoriaID")
                if CategoriaID=0 then
                    CategoriaID = ""
                end if
                CentroCustoID = itens("CentroCustoID")
                if CentroCustoID=0 then
                    CentroCustoID = ""
                end if

                Desconto = itens("Desconto")
                ValorCustoCalculado = itens("ValorCustoCalculado")
                Acrescimo = itens("Acrescimo")
                Tipo = itens("Tipo")
                Descricao = itens("Descricao")
                ValorUnitario = itens("ValorUnitario")
                Executado = itens("Executado")
                ProfissionalID = itens("ProfissionalID")
                EspecialidadeID = itens("EspecialidadeID")
                Associacao = itens("Associacao")
				AtendimentoID = itens("AtendimentoID")
				AgendamentoID = itens("AgendamentoID")
                DataExecucao = itens("DataExecucao")
                HoraExecucao = itens("HoraExecucao")
                Senha = itens("senha")
                PacoteID = itens("PacoteID")
				imposto = itens("imposto")

				' if imposto = 1 then
				' 	Desconto =  valorUnitario
				' 	valorUnitario = 0
				' end if 

                if session("Odonto")=1 then
                    OdontogramaObj = itens("OdontogramaObj")
                end if
                if not isnull(HoraExecucao) and isdate(HoraExecucao) then
                    HoraExecucao = formatdatetime(HoraExecucao, 4)
                end if
                HoraFim = itens("HoraFim")
                if not isnull(HoraFim) and isdate(HoraFim) then
                    HoraFim = formatdatetime(HoraFim, 4)
                end if

				if (not integracaofeita.eof or DataCancelamento&""<>"") and req("T")<>"D" and itens("Tipo")<>"M" then
				%>
					<!--#include file="invoiceLinhaItemRO.asp"-->
				<%
				else 
				%>
					<!--#include file="invoiceLinhaItem.asp"-->				
				<%
				end if 
                
            itens.movenext
            wend
            itens.close
            set itens=nothing

		end if


		if req("Lancto")="Dir" then
			conta = 0
			Total = 0
			Subtotal = 0
			Row = 0
			set itens=db.execute("select * from tempinvoice where InvoiceID="&InvoiceID)
			while not itens.eof
                response.Flush()
				Row = Row-1
				conta = conta+itens("Quantidade")
				Subtotal = itens("Quantidade")*(itens("ValorUnitario")-itens("Desconto")+itens("Acrescimo"))
				Total = Total+Subtotal
				NomeItem = ""
				if itens("Tipo")="S" then
					set pItem = db.execute("select NomeProcedimento NomeItem from procedimentos where id="&itens("ItemID"))
					if not pItem.eof then
						NomeItem = pItem("NomeItem")
					end if
				elseif itens("Tipo")="M" then
					set pItem = db.execute("select NomeProduto NomeItem from produtos where id="&itens("ItemID"))
					if not pItem.eof then
						NomeItem = pItem("NomeItem")
					end if
				elseif itens("Tipo")="O" then
					NomeItem = itens("Descricao")
				end if
				id = Row
				Quantidade = itens("Quantidade")
				ItemID = itens("ItemID")
				CategoriaID = itens("CategoriaID")
                if CategoriaID=0 then
                    CategoriaID = ""
                end if
				Desconto = itens("Desconto")
				Acrescimo = itens("Acrescimo")
				Tipo = itens("Tipo")
				Descricao = itens("Descricao")
				ValorUnitario = itens("ValorUnitario")
				Executado = itens("Executado")
				ProfissionalID = itens("ProfissionalID")
				EspecialidadeID = itens("EspecialidadeID")
				Associacao = 5
				DataExecucao = itens("DataExecucao")
				HoraExecucao = itens("HoraExecucao")
				AtendimentoID = itens("AtendimentoID")
				AgendamentoID = itens("AgendamentoID")
				if not isnull(HoraExecucao) and isdate(HoraExecucao) then
					HoraExecucao = formatdatetime(HoraExecucao, 4)
				end if
				HoraFim = itens("HoraFim")
				if not isnull(HoraFim) and isdate(HoraFim) then
					HoraFim = formatdatetime(HoraFim, 4)
				end if
				'response.write("SELECT id FROM labs_invoices_amostras lia WHERE lia.InvoiceID = "&treatvalzero(InvoiceID))			
				
				if not integracaofeita.eof or DataCancelamento&"" <>"" and req("T")<>"D" then
				%>
					<!--#include file="invoiceLinhaItemRO.asp"-->
				<%
				else
				%>
					<!--#include file="invoiceLinhaItem.asp"-->				
				<%
				end if 
			itens.movenext
			wend
			itens.close
			set itens=nothing
		end if
		%>
		<tr id="footItens">
		</tr>
		</tbody>
		<tfoot>
			<% if not integracaofeita.eof then
				%>
			<tr>
				<th colspan="5"><%=conta%> itens</th>
				<th></th>
				<th></th>
				<th id="total" class="text-right" nowrap>R$ <%=formatnumber(Total,2)%></th>
				<th colspan="3"><input type="hidden" name="Valor" id="Valor" value="<%=formatnumber(Total,2)%>" /></th>
			</tr>
			<%
				else 
			%>
			<tr>
				<th colspan="5"><%=conta%> itens</th>
				<th>
				    <%
				    msgVoucherHidden=""
				    if Voucher&"" = "" then
                        msgVoucherHidden = "display:none"


                        if ExistemDescontosPendentes then
                            %>
                            <span class="label label-warning"><i class="far fa-exclamation-circle"></i> Existem descontos pendentes</span>
                            <%
                        else
                            %>
                            <button id="btn-aplicar-desconto" type="button" class="btn btn-default btn-xs disable" data-toggle="modal" data-target="#modal-desconto" style="width: 100%;"> <i class="far fa-percentage"></i> Aplicar Descontos</button>
                            <%
                        end if
				    end if
				    %>
				    <span style="<%=msgVoucherHidden%>" id="msg-voucher-aplicado" class="label label-alert"><i class="far fa-ticket-alt"></i> Voucher <i class="voucher-aplicado"><%=Voucher%></i> aplicado</span>
                </th>
				<th></th>
				<th id="total" class="text-right" nowrap>R$ <div id="totalGeral"><%=formatnumber(Total,2)%></div></th>
				<th colspan="3"><input type="hidden" name="Valor" id="Valor" value="<%=formatnumber(Total,2)%>" /></th>
			</tr>
			<% 
				end if 
			%>
		</tfoot>
	</table>
	<div id="modal-desconto" class="modal fade" role="dialog">
		<div class="modal-dialog modal-sm">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">&times;</button>
					<h4 class="modal-title">Aplicar Desconto</h4>
				</div>
				<div class="modal-body">
					<div class="row">
						<div class="col-md-6">
							<div class="form-group">
								<input type="text" class="form-control input-mask-brl text-right disable" id="modal-desconto-valor" placeholder="Digite o desconto">
							</div>
						</div>
						<div class="col-md-6">
							<div class="form-group">
								<select id="modal-percent" class="form-control">
									<option value="%">%</option>
									<option value="R$">R$</option>
								</select>
							</div>
						</div>
					</div>
					<div class="row">
						<div class="col-md-4">
						</div>
						<div class="col-md-4">
							<div class="form-group">
								<button type="button" class="btn btn-success form-control" onclick="aplicarDescontos()">Aplicar</button>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
    </div>
<script type="text/javascript">
	function aplicarDescontos() {
		let valueChange = $('#modal-desconto-valor').val();
		let formatoDesconto = $('#modal-percent').val();
		let links = $("input[name^='Desconto']").closest('.input-group').find('a');
		if(valueChange != '' && valueChange != 0){
			links.each(function (key, value) {
				valorUnitario   = $(value).closest('tr').find("input[name^='ValorUnitario']").val();
				if(formatoDesconto == '%'){
					$(value).closest('.input-group-btn').find('button').text('%');
					$(value).text('R$');
					$(value).closest('.input-group').find("input[name^='Desconto']").hide();
					$(value).closest('.input-group').find("input[name^='PercentDesconto']").show();
					$(value).closest('.input-group').find("input[name^='PercentDesconto']").val(inputBRL(valueChange));
					$(value).closest('.input-group').find("input[name^='Desconto']").val(convertPorcentagemParaReal(valueChange, valorUnitario));
				}else{
					$(value).closest('.input-group-btn').find('button').text('R$');
					$(value).text('%');
					$(value).closest('.input-group').find("input[name^='Desconto']").show();
					$(value).closest('.input-group').find("input[name^='PercentDesconto']").hide();
					$(value).closest('.input-group').find("input[name^='Desconto']").val(inputBRL(inputBRL(valueChange)));
					$(value).closest('.input-group').find("input[name^='PercentDesconto']").val(convertRealParaPorcentagem(valueChange, valorUnitario));
				}
			});
			$('.CampoDesconto').change();
			recalc();			
		}
		$('#modal-desconto').modal('hide');
	}
</script>

<script type="text/javascript">
    <!--#include file="JQueryFunctions.asp"-->
</script>
<%
elseif Acao="I" then
    id = (Row+1)*(-1)
    Quantidade = 1
    if req("autoPCi")<>"" and isnumeric(req("autoPCi")) then
        CategoriaID = req("autoPCi")
    else
        CategoriaID = ""
    end if
    Desconto = 0
    Acrescimo = 0
    Descricao = ""
    CentroCustoID=ref("CC")

	if ref("T")<>"P"  and ref("T")<>"K" then
		ItemID = 0'id do procedimento
		ValorUnitario = 0
		if not integracaofeita.eof or DataCancelamento&"" <>"" and req("T")<>"D" then
		%>
			<!--#include file="invoiceLinhaItemRO.asp"-->
		<%
		else 
		%>
			<!--#include file="invoiceLinhaItem.asp"-->				
		<%
		end if 
	elseif ref("T")="K" then
		set pct = db.execute("select pdk.ProdutoID, pdk.Valor, pdk.Quantidade from produtosdokit pdk INNER JOIN produtos p ON p.id=pdk.ProdutoID where pdk.KitID="&II)
		while not pct.EOF
			ItemID = pct("ProdutoID")'id do procedimento
			ValorUnitario = pct("Valor")
			Quantidade = pct("Quantidade")
			Subtotal = ValorUnitario * Quantidade
            PacoteID = II
            Executado="U"
			if not integracaofeita.eof or DataCancelamento&""<>"" and req("T")<>"D" then
			%>
				<!--#include file="invoiceLinhaItemRO.asp"-->
			<%
			else 
			%>
				<!--#include file="invoiceLinhaItem.asp"-->				
			<%
			end if 
			id = id-1
		pct.movenext
		wend
		pct.close
		set pct=nothing
	elseif ref("T")="P" then
		set pct = db.execute("select pi.ProcedimentoID, pi.ValorUnitario from pacotesitens pi where pi.PacoteID="&II)
		while not pct.EOF
			ItemID = pct("ProcedimentoID")'id do procedimento
			ValorUnitario = pct("ValorUnitario")
			Subtotal = ValorUnitario
            PacoteID = II
			if not integracaofeita.eof or DataCancelamento&""<>"" and req("T")<>"D" then
			%>
				<!--#include file="invoiceLinhaItemRO.asp"-->
			<%
			else 
			%>
				<!--#include file="invoiceLinhaItem.asp"-->				
			<%
			end if 
			id = id-1
		pct.movenext
		wend
		pct.close
		set pct=nothing
	end if
	%>
	<script>
    geraParcelas('S');
//	recalc();
		<!--#include file="jqueryfunctions.asp"-->
    </script>
    <%
elseif Acao="X" then
	%>
	$("#row<%= II %>, #row2_<%= II %>").replaceWith("");
    recalc();

	<%
	response.end
end if

if Acao<>"X" then
%>
<script type="text/javascript">
$("input[name^=Executado]").click(function(){
	id = $(this).attr('id');
	id = id.replace('Executado', '');
	if($(this).prop('checked')==true){
        $("#row2_" + id).removeClass('hidden');
        $("#Cancelado" + id).prop("checked", false);
		calcRepasse(id);
	}else{
		$("#row2_"+ id ).addClass('hidden');
		$("#rat"+id).html("");
	}
});

    $("input[name^=Cancelado]").click(function () {
        id = $(this).attr('id');
        id = id.replace('Cancelado', '');
        if ($(this).prop('checked') == true) {
            if ($("#Executado" + id).prop("checked")==true){
                $("#Executado" + id).click();
            }
        }
    });


function allRepasses(){
	$("input[name^=Executado").each(function(index, element) {
        if( $(this).prop('checked')==true ){
			id = $(this).attr('id');
			id = id.replace('Executado', '');
			calcRepasse(id);
		}
    });
}

/*
$("select[name^=ProfissionalID]").change(function(){
	id = $(this).attr('id');
	id = id.replace('ProfissionalID', '');
	calcRepasse(id);
});
colocar a funcao direta no onclick (ver a documentacao do select insert)
*/

$("input[name^=searchCategoria]").attr("placeholder", "Categoria...");

<%
if session("BloquearValorInvoice")="S" and aut("|contasareceberA|")=0 then
    %>
    $("input[name^=ValorUnitario], input[name^=Desconto], input[name^=Acrescimo]").prop("readonly", true);
    <%
end if
%>

$("input[name^=searchCategoria]").attr("placeholder", "Categoria...");

$(".checkbox-executado").click(function() {
    var checked = $(this).prop("checked");
    var id = $(this).parents("tr").data("id");
    var $divExecucao = $(".div-execucao[data-id="+id+"]");

    $divExecucao.find("select").attr("required", checked);
    $divExecucao.find(".input-mask-date").attr("required", checked);
});
<% IF aut("agendamentosantigosA")=0  THEN %>
        $(function() {
                var d = new Date();
                 d.setDate(d.getDate()-1);
                 $("input[id^=DataExecucao]").datepicker("setStartDate",d);
                 $("input[id^=DataExecucao]").change(function() {
                   let dataSelecionada = $(this).val().replace(/(\d{2})\/(\d{2})\/(\d{4}).*/, '$3$2$1');
                   let dataAtual = new Date().toLocaleDateString('pt-BR').replace(/(\d{2})\/(\d{2})\/(\d{4}).*/, '$3$2$1');
                   if(dataSelecionada < dataAtual){
                       $(this).val("");
                       $(this).focus();
                   }
                 });
        });
<% END IF %>


</script>
<%
end if
%>
<script >

$(function(){
    $(".notedit").on('keydown', function() {
       return false
    });
})

document.onkeyup  = function(evt) {
    if(evt.keyCode == 13){
        var proc = $("#VariosProcedimentos").is(':checked');
        if(proc == true){
            var todospreenchidos = 1;
            var i = 1;
            $("select[name^='ItemID-']").each(function(){
                console.log($(this).attr("id"));
                var value = $(this).val();

                if(value == 0) todospreenchidos = 0;
                i++;
            });

            let elem = document.activeElement;
            let labelid = elem.getAttribute("aria-labelledby");
            let result = labelid.match( /select2-ItemID-([0-9]+)-container/ig );

            if(labelid != null && result != null && result.length > 0){
                if(todospreenchidos == 1){
                    itens('S', 'I', 0, '', function(){
                        $("select[name=ItemID-"+i+"]").select2('open');
                        $("select[name=ItemID-"+i+"]").focus();
                    });
                }
            }
        }
    }
};

$('.PercentDesconto').change(function () {
    $('.CampoDesconto').change();
})

function syncValuePercentReais(inputUnitario) {
    let valorDescontoReais = $(inputUnitario).closest('tr').find("input[name^='Desconto']");
    let valorDescontoPercentual = $(inputUnitario).closest('tr').find("input[name^='PercentDesconto']");
    let botaoDesconto = $(inputUnitario).closest('tr').find(".btn-desconto");
    if(botaoDesconto.text() == '%'){
        setInputDescontoEmReais(valorDescontoPercentual);
    }else{
        setInputDescontoEmPorcentagem(valorDescontoReais);
    }
    recalc();
}

function mudarFormatoDesconto(menu){
    let text = $(menu).text();
    if(text == 'R$'){
        $(menu).closest('.input-group').find("input[name^='Desconto']").show();
        $(menu).closest('.input-group').find("input[name^='PercentDesconto']").hide();
        $(menu).closest('.input-group-btn').find('button').text('R$');
        $(menu).text('%');
    }else{
        $(menu).closest('.input-group').find("input[name^='Desconto']").hide();
        $(menu).closest('.input-group').find("input[name^='PercentDesconto']").show();
        $(menu).closest('.input-group-btn').find('button').text('%');
        $(menu).text('R$');
    }
}

function setInputDescontoEmReais(descontoInput){
    let percentDesconto = $(descontoInput).closest('.input-group').find("input[name^='PercentDesconto']").val();
    let valorUnitario   = $(descontoInput).closest('tr').find("input[name^='ValorUnitario']").val();
    valorDesconto       = convertPorcentagemParaReal(percentDesconto, valorUnitario);
    $(descontoInput).closest('.input-group').find("input[name^='Desconto']").val(valorDesconto);
    recalc();
}

function setInputDescontoEmPorcentagem(descontoInput){
    let desconto                = $(descontoInput).val();
    let valorUnitario           = $(descontoInput).closest('tr').find("input[name^='ValorUnitario']").val();
    let valorDescontoPercentual = convertRealParaPorcentagem(desconto, valorUnitario);
    $(descontoInput).closest('.input-group').find("input[name^='PercentDesconto']").val(valorDescontoPercentual);
    recalc();
}

function convertRealParaPorcentagem(valorReal, valorUnitario){
    valorReal      = String(valorReal).replace(".","");
    valorUnitario  = String(valorUnitario).replace(".","");
    valorReal      = parseFloat(valorReal.replace(",","."));
    valorUnitario  = parseFloat(valorUnitario.replace(",","."));
    if(valorReal == "0.00" || valorUnitario == "0.00") return "0,00";
    return inputBRL((valorReal/valorUnitario)*100);
}

function convertPorcentagemParaReal(valorPorcentagem, valorUnitario){
    valorPorcentagem    = valorPorcentagem.replace(".","");
    valorUnitario       = valorUnitario.replace(".","");
    valorPorcentagem    = parseFloat(valorPorcentagem.replace(",","."));
    valorUnitario       = parseFloat(valorUnitario.replace(",","."));
    if(valorPorcentagem == "0.00" || valorUnitario == "0.00") return "0,00";
    return inputBRL(valorPorcentagem * (valorUnitario/100));
}

function inputBRL(value) {
    let replacedValue    = value.toString().replace(".","").replace(",",".");
    let inputBRLCurrency = parseFloat(replacedValue).toFixed(2).replace(".",",").replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1.');
    return inputBRLCurrency;
}

function repasses(T, I){
    $("#modal-table").modal("show");
    $.get("repassesGerados.asp?T="+ T +"&I="+ I, function(data){
        $("#modal").html(data);
    });
}

const filtraExecutantes = async (procedimentoId, linhaId) => {
//      obtém um json dos executantes
    const response = await doApiRequest({
        url: "jsonProfissionaisPorProcedimento.asp", //executantes/lista-executante
        params: {
            procedimento_id: procedimentoId,
            tipo_executantes: "<%=ExecutantesTiposAjax%>"
        }
    });
    const $selectExecutantes = $("#ProfissionalID" + linhaId);

    const executantes = response.data;


    if(executantes){
        executantes.unshift({
            NomeProfissional: "Selecione",
            AssociacaoID: null,
            ID: null,
        });

        var valorSelecionado = $selectExecutantes.val();
        $selectExecutantes.html("");
        let htmlExecutantes = "";

        executantes.map(function(executante) {
            var executanteIdentificador = executante.AssociacaoID + "_" + executante.ID;

            htmlExecutantes += `<option value="${executanteIdentificador}">${executante.NomeProfissional}</option>`;
        });
        $selectExecutantes.html(htmlExecutantes);
        $selectExecutantes.val(valorSelecionado);
    }

}


function onChangeProcedimento(linhaId, procedimentoId) {
  parametrosInvoice(linhaId, procedimentoId);
  filtraExecutantes(procedimentoId, linhaId);
}

$(document).ready(function(){
    let inputs = $("input[name^='PercentDesconto']");
	if (inputs.length>0){
		inputs.each(function (key, input) {
			let valorUnitario           = $(this).closest('tr').find("input[name^='ValorUnitario']").val();
			valorUnitario !== undefined ? valorUnitario = valorUnitario.replace(",","."):valorUnitario=0
			let descontoEmReais         = $(this).closest('tr').find("input[name^='Desconto']").val();
			descontoEmReais !== undefined ? descontoEmReais = descontoEmReais.replace(",","."):descontoEmReais=0
			let descontoEmPercentual    = convertRealParaPorcentagem(descontoEmReais, valorUnitario);
			$(input).val(descontoEmPercentual);
			$(input).prop('data-desconto',$("input[name^='PercentDesconto']").val());
		});
	}
    <%
    if req("T")="C" then
    %>
	let executados = $("input[id^='Executado']")
	executados.each((key,input)=>{
		let id = $(input).attr('id').replace('Executado','')
		let numOptions = $("#EspecialidadeID"+id).find("option").length ;

		if(numOptions<=1){return;}
		if($(input).prop('checked')){
			$("#EspecialidadeID"+id).attr('required',true) 
		}else{
			$("#EspecialidadeID"+id).attr('required',false) 
		}
	})
	let rows = $("tr[id^='row']")
	rows.each((key,element)=>{
		let procedimentoId = $(element).find('select').val()
		let linhaId = $(element).attr('id').replace('row','')
		filtraExecutantes(procedimentoId, linhaId);
	});
    <%
    end if
    %>
});

</script>
<!--#include file="disconnect.asp"-->