<!--#include file="connect.asp"-->
<!--#include file="RepasseLinhaFuncao.asp"-->
<form method="post" action="" name="frmModal" id="frmModal">
<input type="hidden" name="E" id="E" value="E" />
<%
ItemID = req("II")
GuiaID = req("I")
Tipo = req("T")
AtualizarProdutos = req("AtualizarProdutos")

TotalCH = 0
TotalValorFixo = 0
TotalUCO = 0
TotalPORTE = 0
xTotalGeral = 0
TotalFILME = 0
CalcularEscalonamento = 1

IF AtualizarProdutos <> "" THEN

    set resultSql = db.execute("SELECT count(*) as quantidade FROM tissprodutostabela WHERE coalesce(TabelaID = nullif('"&AtualizarProdutos&"',''),TRUE)")

    IF resultSql("Quantidade") > "0" THEN
       response.write(quickfield("simpleSelect", "ProdutoID", "* Descri&ccedil;&atilde;o", 3, TipoContaFixaID, "select *,NomeProduto as NomeProduto from produtos where id in ((SELECT ProdutoID FROM tissprodutostabela WHERE coalesce(TabelaID = nullif('"&AtualizarProdutos&"',''),TRUE))) AND sysActive=1 order by NomeProduto;", "NomeProduto", " onchange=""tissCompletaDados(5, this.value);"" required "))
    ELSE
        response.write(quickfield("simpleSelect", "ProdutoID", "* Descri&ccedil;&atilde;o", 3, TipoContaFixaID, "select *,NomeProduto as NomeProduto from produtos where sysActive=1 order by NomeProduto;", "NomeProduto", " onchange=""tissCompletaDados(5, this.value);"" required "))
    END IF

    response.end
END IF

if Tipo="Profissionais" then
    set ConvenioSQL = db.execute("SELECT BloquearAlteracoes FROM convenios WHERE id="&treatvalzero(ref("gConvenioID")))

    if not ConvenioSQL.eof then
        BloquearAlteracoes = ConvenioSQL("BloquearAlteracoes")

        if BloquearAlteracoes then
            CampoReadonly=" readonly"
        end if
    end if

	if ItemID<>"0" then
		set reg = db.execute("select * from tissprofissionaissadt where id="&ItemID)
		if not reg.eof then
			Sequencial = reg("Sequencial")
			GrauParticipacaoID = reg("GrauParticipacaoID")
			ProfissionalID = reg("ProfissionalID")
			CodigoNaOperadoraOuCPF = reg("CodigoNaOperadoraOuCPF")
			ConselhoID = reg("ConselhoID")
			DocumentoConselho = reg("DocumentoConselho")
			UFConselho = reg("UFConselho")
			CodigoCBO = reg("CodigoCBO")
			Associacao = reg("Associacao")
	    end if
    else
        Sequencial = getSequencial(GuiaID)
        Associacao = 5
	end if
    IF Associacao  = 5 then
		reqI = "required = ""required"""
		reqE = ""
	else
		reqI = ""
		reqE = "required = ""required"""
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
            <%if recursoAdicional(50) = 4 then %>
                <span id="spanProfissionalI"<%if Associacao <> 5 Then %> style="display:none"<% End If %>>
                    <%= quickField("simpleSelect", "gProfissionalID", "Nome do Profissional", 2, ProfissionalID, "select * from profissionais where sysActive=1 and Ativo='on' order by NomeProfissional", "NomeProfissional", " onchange=""tissCompletaDados('Profissional', this.value);"" empty='' "&reqI) %>
                </span>
                <span id="spanProfissionalE"<%if Associacao = 5 Then %> style="display:none"<% End If %>>
                    <%= quickField("simpleSelect", "gProfissionalExternoID", "Profissional Externo", 2, ProfissionalID, "select * from profissionalexterno where sysActive=1 order by NomeProfissional", "NomeProfissional", " onchange=""tissCompletaDados('Profissional', this.value);"" empty='' "&reqE) %>
                </span>
                <span class="pull-left">
                    <br>
                    <label><input type="radio" name="tipoProfissional" id="tipoProfissionalI" value="5"<% if Associacao = 5 Then %> checked="checked"<% End If %> class="ace" onclick="tc('I');" /> <span class="lbl">Interno</span></label><br/>
                    <label><input type="radio" name="tipoProfissional" id="tipoProfissionalE" value="8"<% if Associacao = 8 Then %> checked="checked"<% End If %> class="ace" onclick="tc('E');" /> <span class="lbl">Externo</span></label>
                </span>
			<%else%>
            	<%= quickField("simpleSelect", "gProfissionalID", "Nome do Profissional", 2, ProfissionalID, "select * from profissionais where sysActive=1 and Ativo='on' order by NomeProfissional", "NomeProfissional", " onchange=""tissCompletaDados('Profissional', this.value);"" empty='' required='required'") %>
			<%end if%>
            <%= quickField("simpleSelect", "GrauParticipacaoID", "* Participa&ccedil;&atilde;o", 2, GrauParticipacaoID, "select * from cliniccentral.tissgrauparticipacao order by descricao", "descricao", " empty no-select2 ") %>
            <%= quickField("text", "CodigoNaOperadoraOuCPF", "* Cód. na Operadora / CPF", 2, CodigoNaOperadoraOuCPF, "", "", " required='required'"&CampoReadonly) %>
            <%= quickField("simpleSelect", "ConselhoID", "* Conselho", 1, ConselhoID, "select * from conselhosprofissionais order by descricao", "descricao", " empty='' required='required' no-select2"&CampoReadonly) %>
            <%= quickField("text", "DocumentoConselho", "* N&deg; no Conselho", 1, DocumentoConselho, "", "", " required='required'"&CampoReadonly) %>
            <%= quickField("text", "UFConselho", "* UF", 1, UFConselho, "", "", " required='required' pattern='[a-zA-Z]{2}'"&CampoReadonly) %>
            <%= quickField("text", "CodigoCBO", "* C&oacute;d. CBO", 1, CodigoCBO, "", "", " required='required'"&CampoReadonly) %>
        </div>
	<%
elseif Tipo="Procedimentos" then
	Fator = calculaFator(GuiaID)
	if ItemID<>"0" then
		set reg = db.execute("select * from tissprocedimentossadt where id="&ItemID)
		if not reg.eof then
			ProfissionalID = reg("ProfissionalID")
            Associacao = reg("Associacao")
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
            Executante = Associacao &"_"& ProfissionalID

            TotalCH        = reg("TotalCH")
            TotalValorFixo = reg("TotalValorFixo")
            TotalFILME      = reg("TotalFILME")
            TotalUCO       = reg("TotalUCO")
            TotalPORTE     = reg("TotalPORTE")
            xTotalGeral    = reg("TotalGeral")
            CalcularEscalonamento    = reg("CalcularEscalonamento")

		end if
    else
        Data = date()
        TabelaID = "22"
	end if
	if isnull(Quantidade) or Quantidade=0 or Quantidade="" then Quantidade = 1 end if
	if isnull(Fator) or Fator=0 or Fator="" then
		Fator = calculaFator(GuiaID)
	end if

	ValorRequired = "required"

	if session("Banco")="clinic3882" then
	    ValorRequired = ""
	end if

	ProfissionalRequired  = " required"

	recursoPermissaoUnimed = recursoAdicional(12)
    if recursoPermissaoUnimed=4 then
	    ProfissionalRequired = ""
	end if
	%>
        <div class="row">
            <div class="col-md-3">
	            <%= selectInsert("* Procedimento", "gProcedimentoID", ProcedimentoID, "procedimentos", "NomeProcedimento", " onchange=""tissCompletaDados(4, this.value);""", "required guia-tiss", "gConvenioID") %>
            </div>
            <%= quickField("simpleSelect", "TabelaID", "* Tabela", 3, TabelaID, "select tt.id, tt.descricao from tisstabelas tt UNION ALL SELECT tc.CodigoTabela, tc.Descricao FROM tabelasconvenios tc WHERE tc.sysActive = 1 order by descricao", "descricao", " empty='' required='required' no-select2") %>
            <div class="col-md-2">
                <%=selectProc("* Código proced.", "CodigoProcedimento", CodigoProcedimento, "codigo", "TabelaID", "CodigoProcedimento", "Descricao", " required='required' ", "","","") %>
            </div>
            <div class="col-md-4">
                <%=selectProc("* Descrição", "Descricao", Descricao, "descricao", "TabelaID", "CodigoProcedimento", "Descricao", " required='required' ", "", "", "") %>
            </div>

            <%'= quickField("text", "CodigoProcedimento", "C&oacute;d. proced.", 2, CodigoProcedimento, "", "", " required='required'") %>
            <%'= quickField("text", "Descricao", "Descri&ccedil;&atilde;o", 4, Descricao, "", "", " required='required'") %>
        </div>
        <div class="row">
            <%= quickField("number", "Quantidade", "* Quant.", 1, Quantidade, " text-right ", "", " required='required' min='0' onchange=""tissRecalc('Quantidade');""") %>
            <%= quickField("simpleSelect", "ViaID", "Via", 2, ViaID, "select * from tissvia order by descricao", "descricao", "  onchange=""tissCompletaDados(4, $('#gProcedimentoID').val());"" empty='' no-select2") %>
            <%= quickField("simpleSelect", "TecnicaID", "T&eacute;c.", 3, TecnicaID, "select * from tisstecnica order by descricao", "descricao", " empty='' no-select2") %>
            <%= quickField("text", "Fator", "* Fator", 2, formatnumber(Fator,2), " input-mask-brl text-right", "", " required='required' onchange=""alertCalculo(this);tissRecalc('Fator');""") %>
            <%= quickField("currency", "ValorUnitario", "* Valor Unit&aacute;rio", 2, ValorUnitario, "", "", " "&ValorRequired&" onchange=""alertCalculo(this);tissRecalc('ValorUnitario');""") %>
            <%= quickField("currency", "ValorTotal", "* Valor Total", 2, ValorTotal, "", "", " "&ValorRequired) %>
         </div>
         <div class="hidden procedimentos-hidden ">
            <input type="hidden" name="TotalCH"               value="<%=TotalCH%>" />
            <input type="hidden" name="TotalValorFixo"        value="<%=TotalValorFixo%>" />
            <input type="hidden" name="TotalUCO"              value="<%=TotalUCO%>" />
            <input type="hidden" name="TotalPORTE"            value="<%=TotalPORTE%>" />
            <input type="hidden" name="TotalFILME"            value="<%=TotalFILME%>" />
            <input type="hidden" name="xTotalGeral"           value="<%=xTotalGeral%>" />
            <input type="hidden" name="CalcularEscalonamento" value="<%=CalcularEscalonamento%>" />
         </div>
	<%id = ItemID%>
    <div class="clearfix form-actions">
        <div class="row">
        <div class="col-md-12">
            <%'=quickField("simpleSelect", "ProfissionalID"&id, "* Profissional", 3, ProfissionalID, "select id, NomeProfissional from profissionais where ativo='on' and sysActive=1 order by NomeProfissional", "NomeProfissional", " onchange='repasses("&id&")' onchange='abreRateio("&n&")'  no-select2 ")%>
            <div class="col-md-3">
                <label>Executante</label><br />
                <%= simpleSelectCurrentAccounts("ProfissionalID"& id, "5, 8", Executante, " "&ProfissionalRequired,"") %>
            </div>
            <%= quickField("datepicker", "Data", "* Data", 3, Data, "", "", " required") %>
            <%= quickField("text", "HoraInicio", "Hora In&iacute;cio", 2, HoraInicio, " input-mask-l-time", "", "") %>
            <%= quickField("text", "HoraFim", "Hora Fim", 2, HoraFim, " input-mask-l-time", "", "") %>
            <input type="hidden" name="QuantidadeFilme" id="QuantidadeFilme" />
            <input type="hidden" name="ValorFilmeADD"      id="ValorFilmeADD"      />

            <div class="col-md-2 hidden"><label>&nbsp;</label><br />
                <div class="btn-group pull-right">
                    <button class="btn btn-primary dropdown-toggle" data-toggle="dropdown"><i class="far fa-plus"></i> Adicionar <i class="far fa-chevron-down"></i></button>
                    <ul class="dropdown-menu dropdown-primary">
                        <li><a href="javascript:AddRepasse('<%=id%>', 1, 'F');">Fun&ccedil;&atilde;o ou repasse</a></li>
                        <li><a href="javascript:AddRepasse('<%=id%>', 1, 'M');">Material ou medicamento</a></li>
                    </ul>
                </div>
            </div>
            <br><br><br>
            <div class="divider">&nbsp;</div>
            <div class="row hidden">
                <div class="col-md-12" id="divRepasses<%=id%>"><!--#include file="divRepassesConvenio.asp"--></div>
            </div>
        </div>
        </div>
    </div>
	<%
elseif Tipo="Despesas" then
		set reg = db.execute("select * from tissguiaanexa where id="&ItemID)
		if not reg.eof then
			GuiaID = reg("GuiaID")
			CD = reg("CD")
			Data = reg("Data")
            if isnull(reg("HoraInicio")) then HoraInicio="" else HoraInicio = right(reg("HoraInicio"), 8)end if 
            if isnull(reg("HoraFim")) then HoraFim="" else HoraFim = right(reg("HoraFim"), 8) end if
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
  	        <%= quickField("simpleSelect", "TabelaProdutoID", "* Tabela", 2, TabelaProdutoID, "select *, concat( right(concat('00', id), 2), ' - ', descricao) desccomp from cliniccentral.tabelasprocedimentos where Ativo='S' and (Despesa=1 or Despesa is null) order by id", "desccomp", " empty='' required='required' onchange=""atualizaProdutos(this.value);tissCompletaDados(6, this.value+'_'+$('#ProdutoID').val());"" no-select2 ") %>
            <input type="hidden" name="Descricao" id="ProdutoDescricaoStr">
            <%= quickField("simpleSelect", "CD", "* CD", 1, CD, "select * from cliniccentral.tisscd order by id", "Descricao", " empty='empty' required='required' no-select2") %>
            <div class="col-md-3"><%= selectInsert("* Descri&ccedil;&atilde;o", "ProdutoID", ProdutoID, "produtos", "NomeProduto", " onchange=""tissCompletaDados(5, this.value);""", "required", "") %></div>
            <div class="col-md-2">
                <%=selectProc("* C&oacute;digo do Item", "CodigoProduto", CodigoProduto, "codigo", "TabelaProdutoID", "CodigoProduto", "ProdutoID", " required='required' produto adicionar-valor", "CD", "UnidadeMedidaID", "ValorUnitario") %>
            </div>
            <%= quickField("text", "RegistroANVISA", "ANVISA", 1, RegistroANVISA, "", "", "") %>
            <%= quickField("text", "CodigoNoFabricante", "C&oacute;d. Fab.", 1, CodigoNoFabricante, "", "", "") %>
            <%= quickField("text", "AutorizacaoEmpresa", "N&deg; Aut. de Func. da Empresa", 2, AutorizacaoEmpresa, "", "", "") %>
        </div>
        <div class="row">
              <%= quickField("datepicker", "Data", "* Data", 2, Data, "", "", " required='required'") %>
            <%= quickField("text", "HoraInicio", "Hora In&iacute;cio", 1, HoraInicio, " input-mask-l-time", "", "") %>
            <%= quickField("text", "HoraFim", "Hora Fim", 1, HoraFim, " input-mask-l-time ", "", "") %>
            <%= quickField("number", "Quantidade", "Quantidade", 1, replace(Quantidade,",","."), " text-right", "", " required='required' min='0' onchange=""tissRecalc('Quantidade');"" step=""0.01""") %>
            <%= quickField("simpleSelect", "UnidadeMedidaID", "Unid. Medida", 2, UnidadeMedidaID, "select * from cliniccentral.tissunidademedida order by descricao", "descricao", " empty='' required='required'  no-select2 ") %>
            <%= quickField("text", "Fator", "Fator", 1, fn(Fator), " input-mask-brl", "", " required='required' onchange=""tissRecalc('Fator');""") %>
            <%= quickField("currency", "ValorUnitario", "Valor Unit.", 2, fn(ValorUnitario), "", "", " required='required' onchange=""tissRecalc('ValorUnitario');""") %>
            <%= quickField("currency", "ValorTotal", "Valor Total", 2, fn(ValorTotal), "", "", " required='required'") %>
        </div>
	<%
end if
%>
<div style="float: right;margin-top: 15px">
	<button class="btn btn-success btn-sm"><i class="far fa-save"></i> Salvar</button>
    <button class="btn btn-sm btn-default" type="button" onclick="itemSADT('<%=Tipo %>', 0, <%=ItemID %>, 'Cancela');">
    	<i class="far fa-remove"></i> Cancelar
    </button>
</div>
</form>
<script language="javascript">
<!--#include file="jQueryFunctions.asp"-->

$(document).ready(function () {
    $("select[name=gProcedimentoID]").change(function () {
        let ProcedimentoCirurgico = false;
        $.post("./Classes/AjaxReturn.asp",
            {
                itemVal: $(this).val(),
                itemTab: "Procedimentos",
                itemCol: "TipoProcedimentoID"
            }, 
            function (valor) {
                if (valor==1){
                    ProcedimentoCirurgico=true;
                }
                $('#ViaID').attr('required',ProcedimentoCirurgico);
                $('#TecnicaID').attr('required',ProcedimentoCirurgico);

            }
        );           
    });
});

$("#frmModal").submit(function(){
    var val = $("#select2-ProdutoID-container").text();
    $("#ProdutoDescricaoStr").val(val);

	$.ajax({
       type:"POST",
       url:"saveModalSADT.asp?I=<%=req("I")%>&II=<%=req("II")%>&T=<%=req("T")%>",
       data:$("#frmModal, #GuiaSADT").serialize(),
       success:function(data){
           eval(data);
       }
    });
	return false;
});

$("#ProdutoID").change(function() {
    setTimeout(function() {
      var val = $("#select2-ProdutoID-container").text();

          $("#ProdutoDescricaoStr").val(val);
    }, 100);
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

function atualizaProdutos(arg) {

    $.ajax({
        type:"POST",
        url:"modalSADT.asp?AtualizarProdutos="+arg,
        data:$("#frmModal").serialize(),
        success:function(data){
            $('#ProdutoID').parent()[0].outerHTML = (data);
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
function formatNumber(num,fix){
    if(!num){
        return null;
    }
    return Number(num.replace(".","").replace(",",".")).toLocaleString('de-DE', {
     minimumFractionDigits: fix,
     maximumFractionDigits: fix
   });
}
function alertCalculo(arg){

    let diferent = formatNumber($("[name='xTotalGeral']").val(),2) !=  formatNumber($("#ValorUnitario").val(),2)

    if(diferent){
        $("[name='CalcularEscalonamento']").val("0");

        new PNotify({
              title: 'Valor unitário alterado!',
              text: 'Dados de précalculo não surtirão efeito.',
              type: 'danger',
              delay: 500
        });
        return ;
    }

    $("[name='CalcularEscalonamento']").val("1");


}function tissCompletaDados(T, I){

 	$.ajax({
 		type:"POST",
 		url:"tissCompletaDados.asp?I="+I+"&T="+T,
 		data:$("#GuiaSADT, #frmModal").serialize(),
 		success:function(data){
 			eval(data);
 			var convenio = $("#gConvenioID").val();
             $.get(
                 'CamposObrigatoriosConvenio.asp?ConvenioID=' + convenio,
                 function(data){
                     eval(data)
                 }
             );
 		}
 	});
     if(T === "Plano"){
 		let setConvenio = $("#gConvenioID").val();
 		let setPlano = $("#PlanoID").val();
 		let GuiadID = $("[name=GuiaID]").val();
 		atualizaTabela("tissprocedimentossadt", `tissprocedimentossadt.asp?I=${GuiadID}&T=${T}&setPlano=${setPlano}&setConvenio=${setConvenio}`)
     }
 }

 function tc(T){
	if(T=="I"){
		$("#spanProfissionalE").css("display", "none");
		$("#spanProfissionalI").css("display", "block");
		$("#gProfissionalID").attr("required", true);
		$("#gProfissionalExternoID").attr("required", false);
	}else{
		$("#spanProfissionalE").css("display", "block");
		$("#spanProfissionalI").css("display", "none");
		$("#gProfissionalID").attr("required", false);
		$("#gProfissionalExternoID").attr("required", true);
	}
}
</script>