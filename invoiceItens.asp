<!--#include file="connect.asp"-->
<%
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

TemRegrasDeDesconto=False

set TemRegrasDeDescontoSQL = db.execute("SELECT rd.id FROM regrasdescontos rd INNER JOIN regraspermissoes rp ON rp.id=rd.RegraID LIMIT 1")
if not TemRegrasDeDescontoSQL.eof then
    TemRegrasDeDesconto=True
end if

set ValorPagoSQL = db.execute("SELECT SUM(IFNULL(ValorPago,0)) ValorPago FROM sys_financialmovement WHERE InvoiceID="&InvoiceID)

sqlintegracao = " SELECT lia.id, lie.StatusID FROM labs_invoices_amostras lia "&_
				" inner JOIN labs_invoices_exames lie ON lia.id = lie.AmostraID "&_
				" WHERE lia.InvoiceID = "&treatvalzero(InvoiceID)&" AND lia.ColetaStatusID <> 5 "
set integracaofeita = db.execute(sqlintegracao)

if not ValorPagoSQL.eof then
    if ValorPagoSQL("ValorPago")>0 and session("Admin")=0 then
        NaoPermitirAlterarExecutante=getConfig("NaoPermitirAlterarExecutante")
    end if
end if


if Acao="" then
	%>
	<table width="100%" class="duplo table table-striped table-condensed">
		<thead>
			<tr class="info">
				<th width="7%">Quant.</th>
				<th>Item</th>
                <th id="hPlanoContas"></th>
                <th width="100px" id="hCentroCusto"></th>
				<th width="15%">Valor Unit.</th>
				<th width="11%">Desconto</th>
				<th width="11%">Acr&eacute;scimo</th>
				<th width="9%">Total</th>
				<th width="1%"></th>
				<th width="1%"></th>
				<th width="1%"></th>
			</tr>
		</thead>
		<tbody>
		<%
		conta = 0
		Total = 0
		Subtotal = 0
        response.Buffer

		set itens = db.execute("select * from itensinvoice where InvoiceID="&InvoiceID&" order by id")

		if not itens.eof then

		    set FornecedorSQL = db.execute("SELECT f.limitarPlanoContas FROM fornecedores f INNER JOIN sys_financialinvoices i ON i.AccountID=f.id WHERE i.AssociationAccountID=2 AND f.limitarPlanoContas != '' and f.limitarPlanoContas is not null AND i.id="&InvoiceID)

		    if not FornecedorSQL.eof then
		        LimitarPlanoContas = FornecedorSQL("limitarPlanoContas")
		    end if

            while not itens.eof
                response.Flush()
                conta = conta+itens("Quantidade")
                Subtotal = itens("Quantidade")*(itens("ValorUnitario")-itens("Desconto")+itens("Acrescimo"))
                Total = Total+Subtotal
                NomeItem = ""
				integracaopleres = "N"
                if itens("Tipo")="S" then
                    set pItem = db.execute("select NomeProcedimento NomeItem, integracaoPleres  from procedimentos where id="&itens("ItemID"))
                    if not pItem.eof then
                        NomeItem = pItem("NomeItem")
						integracaopleres = pItem("integracaoPleres")
                    end if
                elseif itens("Tipo")="M" then
                    set pItem = db.execute("select NomeProduto NomeItem from produtos where id="&itens("ItemID"))
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
                Acrescimo = itens("Acrescimo")
                Tipo = itens("Tipo")
                Descricao = itens("Descricao")
                ValorUnitario = itens("ValorUnitario")
                Executado = itens("Executado")
                ProfissionalID = itens("ProfissionalID")
                EspecialidadeID = itens("EspecialidadeID")
                Associacao = itens("Associacao")
                DataExecucao = itens("DataExecucao")
                HoraExecucao = itens("HoraExecucao")
                PacoteID = itens("PacoteID")
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
				if not integracaofeita.eof then
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
				
				if not integracaofeita.eof then
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
				<th colspan="2"><input type="hidden" name="Valor" id="Valor" value="<%=formatnumber(Total,2)%>" /></th>
			</tr>
			<%
				else 
			%>
			<tr>
				<th colspan="5"><%=conta%> itens</th>
				<th><button type="button" class="btn btn-default btn-sm disable" data-toggle="modal" data-target="#modal-desconto" style="width: 100%;"> Aplicar Descontos</button></th>
				<th></th>
				<th id="total" class="text-right" nowrap>R$ <%=formatnumber(Total,2)%></th>
				<th colspan="2"><input type="hidden" name="Valor" id="Valor" value="<%=formatnumber(Total,2)%>" /></th>
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
		if not integracaofeita.eof then
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
			if not integracaofeita.eof then
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
			if not integracaofeita.eof then
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
<!--#include file="disconnect.asp"-->