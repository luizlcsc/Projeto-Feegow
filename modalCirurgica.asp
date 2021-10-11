<!--#include file="connect.asp"-->
<!--#include file="RepasseLinhaFuncao.asp"-->
<form method="post" action="" name="frmModal" id="frmModal">
<input type="hidden" name="E" id="E" value="E" />
<%
ItemID = req("II")
GuiaID = req("I")
Tipo = req("T")

if Tipo="Profissionais" then
	if ItemID<>"0" then
		set reg = db.execute("select * from profissionaiscirurgia where id="&ItemID)
		if not reg.eof then
			Sequencial = reg("Sequencial")
			GrauParticipacaoID = reg("GrauParticipacaoID")
			ProfissionalID = reg("ProfissionalID")
			CodigoNaOperadoraOuCPF = reg("CodigoNaOperadoraOuCPF")
			ConselhoID = reg("ConselhoID")
			DocumentoConselho = reg("DocumentoConselho")
			UFConselho = reg("UFConselho")
			CodigoCBO = reg("CodigoCBO")
	    end if
    else
        Sequencial = getSequencial(GuiaID)
	end if
	%>
    	<div class="row">
        	<div class="col-md-1"><label for="Sequencial">Seq. Ref.</label><br>
            <select class="form-control" name="Sequencial" id="Sequencial" required>
            	<option value="">
				<%
				n = 0
				while n<100
					n=n+1
					%>
					<option value="<%=n%>"<%if Sequencial=n then%> selected<%end if%>><%=n%></option>
					<%
				wend
			%>
            </select>
            </div>
            <%= quickField("simpleSelect", "gProfissionalID", "Nome do Profissional", 2, ProfissionalID, "select * from profissionais where sysActive=1 and Ativo='on' order by NomeProfissional", "NomeProfissional", " onchange=""tissCompletaDados('Profissional', this.value);"" empty='' required='required'") %>
            <%= quickField("simpleSelect", "GrauParticipacaoID", "Participa&ccedil;&atilde;o", 2, GrauParticipacaoID, "select * from cliniccentral.tissgrauparticipacao order by descricao", "descricao", " required='required' no-select2 ") %>
            <%= quickField("text", "CodigoNaOperadoraOuCPF", "Cód. na Operadora / CPF", 2, CodigoNaOperadoraOuCPF, "", "", " required='required'") %>
            <%= quickField("simpleSelect", "ConselhoID", "Conselho", 1, ConselhoID, "select * from conselhosprofissionais order by descricao", "descricao", " empty='' required='required' no-select2 ") %>
            <%= quickField("text", "DocumentoConselho", "N&deg; no Conselho", 2, DocumentoConselho, "", "", " required='required'") %>
            <%= quickField("text", "UFConselho", "UF", 1, UFConselho, "", "", " required='required'") %>
            <%= quickField("text", "CodigoCBO", "C&oacute;d. CBO", 1, CodigoCBO, "", "", " required='required'") %>
	  		
        </div>
	<%
elseif Tipo="Procedimentos" then
	Fator = calculaFator(GuiaID)
	if ItemID<>"0" then
		set reg = db.execute("select * from procedimentoscirurgia where id="&ItemID)
		if not reg.eof then
			ProfissionalID = reg("ProfissionalID")
			Data = reg("Data")
			if isnull(reg("HoraInicio")) then HoraInicio="" else HoraInicio = right(reg("HoraInicio"), 8) end if
			if isnull(reg("HoraFim")) then HoraFim="" else HoraFim = right(reg("HoraFim"), 8) end if
			ProcedimentoID = reg("ProcedimentoID")
			TabelaID = reg("TabelaID")
			CodigoProcedimento = reg("CodigoProcedimento")
			Descricao = reg("Descricao")
			Quantidade = reg("Quantidade")
			ViaID = reg("ViaID")
			TecnicaID = reg("TecnicaID")
			Fator = reg("Fator")
			ValorUnitario = reg("ValorUnitario")
			ValorTotal = reg("ValorTotal")
		end if
    else
        Data = date()
	end if
	if isnull(Quantidade) or Quantidade=0 or Quantidade="" then Quantidade = 1 end if
	if isnull(Fator) or Fator=0 or Fator="" then
		Fator = calculaFator(GuiaID)
	end if
	%>
        <div class="row">
            <div class="col-md-3">
	            <%= selectInsert("Procedimento", "gProcedimentoID", ProcedimentoID, "procedimentos", "NomeProcedimento", " onchange=""tissCompletaDados(4, this.value);""", "required", "") %>
            </div>
            <%= quickField("simpleSelect", "TabelaID", "Tabela", 3, TabelaID, "select * from tisstabelas order by descricao", "descricao", " empty='' required='required' no-select2 ") %>
            <%= quickField("text", "CodigoProcedimento", "C&oacute;d. proced.", 2, CodigoProcedimento, "", "", " ") %>
            <%= quickField("text", "Descricao", "Descri&ccedil;&atilde;o", 4, Descricao, "", "", " required='required'") %>
        </div>
        <div class="row">
            <%= quickField("text", "Quantidade", "Quant.", 1, Quantidade, " text-right input-sm", "", " required='required' onkeyup=""tissRecalc('Quantidade');""") %>
            <%= quickField("simpleSelect", "ViaID", "Via", 2, ViaID, "select * from tissvia order by descricao", "descricao", " empty='' required='required' no-select2 ") %>
            <%= quickField("simpleSelect", "TecnicaID", "T&eacute;c.", 3, TecnicaID, "select * from tisstecnica order by descricao", "descricao", " empty='' required='required' no-select2 ") %>
            <%= quickField("text", "Fator", "Fator", 2, formatnumber(Fator,2), " input-mask-brl text-right input-sm", "", " required='required' onkeyup=""tissRecalc('Fator');""") %>
            <%= quickField("currency", "ValorUnitario", "Valor Unit&aacute;rio", 2, ValorUnitario, " input-sm", "", " required='required' onkeyup=""tissRecalc('ValorUnitario');""") %>
            <%= quickField("currency", "ValorTotal", "Valor Total", 2, ValorTotal, " input-sm", "", " required='required'") %>
         </div>
	<%id = ItemID%>
    <div class="clearfix form-actions">
        <div class="row">
            <%=quickField("simpleSelect", "ProfissionalID"&id, "Profissional", 3, ProfissionalID, "select id, NomeProfissional from profissionais where sysActive=1", "NomeProfissional", " onchange='repasses("&id&")' onchange='abreRateio("&n&")'")%>
            <%= quickField("datepicker", "Data", "Data", 3, Data, "", "", " required") %>
            <%= quickField("text", "HoraInicio", "Hora In&iacute;cio", 2, HoraInicio, " input-mask-l-time", "", "") %>
            <%= quickField("text", "HoraFim", "Hora Fim", 2, HoraFim, " input-mask-l-time", "", "") %>

            <div class="divider">&nbsp;</div>
            <div class="row">
                <div class="col-md-12" id="divRepasses<%=id%>XXXXX"><!--#include file="divRepassesConvenio.asp"--></div>
            </div>
        </div>
    </div>
	<%
elseif Tipo="Despesas" then
		set reg = db.execute("select * from cirurgiaanexos where id="&ItemID)
		if not reg.eof then
			GuiaID = reg("GuiaID")
			CD = reg("CD")
			Data = reg("Data")
			HoraInicio = reg("HoraInicio")
			HoraFim = reg("HoraFim")
			TabelaProdutoID = reg("TabelaProdutoID")
			ProdutoID = reg("ProdutoID")
			CodigoProduto = reg("CodigoProduto")
			Quantidade = formatnumber(reg("Quantidade"), 2)
			UnidadeMedidaID = reg("UnidadeMedidaID")
			Fator = formatnumber(reg("Fator"), 2)
			ValorUnitario = formatnumber(reg("ValorUnitario"), 2)
			ValorTotal = formatnumber(reg("ValorTotal"), 2)
			RegistroANVISA = reg("RegistroANVISA")
			CodigoNoFabricante = reg("CodigoNoFabricante")
			AutorizacaoEmpresa = reg("AutorizacaoEmpresa")
			Descricao = reg("Descricao")
		end if
		if isnull(Quantidade) or Quantidade=0 or Quantidade="" then Quantidade = 1 end if
		if isnull(Fator) or Fator=0 or Fator="" then Fator = 1 end if
	%>
  	<div class="row">
            <div class="col-md-3"><%= selectInsert("Descri&ccedil;&atilde;o", "ProdutoID", ProdutoID, "produtos", "NomeProduto", " onchange=""tissCompletaDados(5, this.value);""", "required", "") %></div>
            <%= quickField("simpleSelect", "CD", "CD", 1, CD, "select * from cliniccentral.tisscd order by id", "Descricao", " empty='empty' required='required' no-select2 ") %>
            <%= quickField("simpleSelect", "TabelaProdutoID", "Tabela", 2, TabelaProdutoID, "select *, concat(id, ' - ', descricao) desccomp from tisstabelas order by id", "desccomp", " empty='' onchange=""tissCompletaDados(6, this.value+'_'+$('#ProdutoID').val());"" no-select2 ") %>
            <%= quickField("text", "CodigoProduto", "C&oacute;digo do Item", 2, CodigoProduto, "", "", " ") %>
            <%= quickField("text", "RegistroANVISA", "ANVISA", 1, RegistroANVISA, "", "", "") %>
            <%= quickField("text", "CodigoNoFabricante", "C&oacute;d. Fab.", 1, CodigoNoFabricante, "", "", "") %>
            <%= quickField("text", "AutorizacaoEmpresa", "N&deg; Aut. de Func. da Empresa", 2, AutorizacaoEmpresa, "", "", "") %>
        </div>
        <div class="row">
          <%= quickField("text", "Quantidade", "Quantidade", 1, fn(Quantidade), " text-right input-mask-brl", "", " required='required' onkeyup=""tissRecalc('Quantidade');""") %>
            <%= quickField("simpleSelect", "UnidadeMedidaID", "Unid. Medida", 2, UnidadeMedidaID, "select * from cliniccentral.tissunidademedida order by descricao", "descricao", " empty='' required='required' no-select2 ") %>
            <%= quickField("text", "Fator", "Fator", 1, fn(Fator), " input-mask-brl", "", " required='required' onkeyup=""tissRecalc('Fator');""") %>
            <%= quickField("currency", "ValorUnitario", "Valor Unit.", 2, fn(ValorUnitario), "", "", " required='required' onkeyup=""tissRecalc('ValorUnitario');""") %>
            <%= quickField("currency", "ValorTotal", "Valor Total", 2, fn(ValorTotal), "", "", " required='required'") %>
        </div>
	<%
end if
%>
<div class="modal-footer">
	<button class="btn btn-success btn-sm"><i class="far fa-save"></i> Salvar</button>
    <button class="btn btn-sm btn-default" type="button" onclick="itemCirurgia('<%=Tipo %>', 0, <%=ItemID %>, 'Cancela');">
    	<i class="far fa-remove"></i> Cancelar
    </button>
</div>
</form>
<script language="javascript">
<!--#include file="jQueryFunctions.asp"-->
$("#frmModal").submit(function(){
	$.ajax({
		   type:"POST",
		   url:"savemodalCirurgica.asp?I=<%=req("I")%>&II=<%=req("II")%>&T=<%=req("T")%>",
		   data:$("#frmModal, #AgendaCirurgica").serialize(),
		   success:function(data){
			   eval(data);
		   }
		   });
	return false;
});

function rateio(n){
	if($('#divRateio'+n).css("display")=="none"){
		$('#divRateio'+n).slideDown(500);
	}else{
		$('#divRateio'+n).slideUp(500);
	}
}

function repasses(Item){
	$.ajax({
		type:"POST",
		url:"chamaDivRepassesConvenio.asp?Item="+Item+"&Change=Profissional",
		data:$("#frmModal").serialize(),
		success:function(data){
			$("#divRepasses"+Item).html(data);
		}
	});
}


function AddRepasse(Item, Q, FM){
	$.ajax({
		type:"POST",
		url:"chamaDivRepassesConvenio.asp?Add="+Q+"&FM="+FM+"&Item="+Item+"&I=0&Valor="+$("#Valor").val()+"&Desconto="+$("#Desconto").val(),
		data:$("#frmModal").serialize(),
		success:function(data){
			$("#divRepasses"+Item).html(data);
		}
	});
}
//corrigir
function RemoveRepasse(Item, R){
	$.ajax({
		type:"POST",
		url:"chamaDivRepassesConvenio.asp?Remove="+R+"&Item="+Item+"&I=0&Valor="+$("#Valor").val()+"&Desconto="+$("#Desconto").val(),
		data:$("#frmModal").serialize(),
		success:function(data){
			$("#divRepasses"+Item).html(data);
		}
	});
}
function tissRecalc(Pressed){
	$.ajax({
		type:"POST",
		url:"tissRecalc.asp?Pressed="+Pressed,
		data:$("#frmModal").serialize(),
		success:function(data){
			eval(data);
		}
	});
}
</script>