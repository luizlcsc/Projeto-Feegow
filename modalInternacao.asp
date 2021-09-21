<!--#include file="connect.asp"-->
<form method="post" action="" name="frmModal" id="frmModal">
<input type="hidden" name="E" id="E" value="E" />
<%
ItemID = req("II")
GuiaID = req("I")
Tipo = req("T")

if Tipo="Procedimentos" then
	if ItemID<>"0" then
		set reg = db.execute("select * from tissprocedimentosinternacao where id="&ItemID)
		if not reg.eof then
			ProcedimentoID = reg("ProcedimentoID")
			TabelaID = reg("TabelaID")
			CodigoProcedimento = reg("CodigoProcedimento")
			Descricao = reg("Descricao")
			Quantidade = reg("Quantidade")
			QuantidadeAutorizada = reg("QuantidadeAutorizada")
		end if
    else
        TabelaID = "22"
	end if
	if (isnull(Quantidade) or Quantidade=0 or Quantidade="") and (isnull(QuantidadeAutorizada) or QuantidadeAutorizada=0 or QuantidadeAutorizada="") then
	Quantidade = 1
	QuantidadeAutorizada = 1
	end if
	%>
        <div class="row">
            <div class="col-md-2">
	            <%= selectInsert("* Procedimento", "gProcedimentoID", ProcedimentoID, "procedimentos", "NomeProcedimento", " onchange=""tissCompletaDados(4, this.value);""", "required", "") %>
            </div>
            <%= quickField("simpleSelect", "TabelaID", "* Tabela", 2, TabelaID, "select * from tisstabelas order by descricao", "descricao", " empty='' required='required' no-select2") %>
            <div class="col-md-2">
                <%=selectProc("* Código proced.", "CodigoProcedimento", CodigoProcedimento, "codigo", "TabelaID", "CodigoProcedimento", "Descricao", " required='required' ", "", "", "") %>
            </div>
            <div class="col-md-3">
                <%=selectProc("* Descrição", "Descricao", Descricao, "descricao", "TabelaID", "CodigoProcedimento", "Descricao", " required='required' ", "", "", "") %>
            </div>
            <%= quickField("number", "Quantidade", "* Quant. Sol.", 1, Quantidade, " text-right input-sm", "", " required='required'") %>
            <%= quickField("number", "QuantidadeAutorizada", "* Quant. Aut.", 1, QuantidadeAutorizada, " text-right input-sm", "", " required='required'") %>
        </div>
      <%
id = ItemID
end if
%>
<div style="float: right;margin-top: 15px">
	<button class="btn btn-success btn-sm"><i class="far fa-save"></i> Salvar</button>
    <button class="btn btn-sm btn-default" type="button" onclick="itemInternacao('<%=Tipo %>', 0, <%=ItemID %>, 'Cancela');">
    	<i class="far fa-remove"></i> Cancelar
    </button>
</div>
</form>
<script language="javascript">
<!--#include file="jQueryFunctions.asp"-->
$("#frmModal").submit(function(){
    var val = $("#select2-ProdutoID-container").text();
    $("#ProdutoDescricaoStr").val(val);

	$.ajax({
       type:"POST",
       url:"saveModalInternacao.asp?I=<%=req("I")%>&II=<%=req("II")%>&T=<%=req("T")%>",
       data:$("#frmModal, #GuiaInternacao").serialize(),
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

</script>