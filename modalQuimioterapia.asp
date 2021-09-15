<!--#include file="connect.asp"-->
<form method="post" action="" name="frmModal" id="frmModal">
<input type="hidden" name="E" id="E" value="E" />
<%
ItemID = request.QueryString("II")
GuiaID = request.QueryString("I")
Tipo = request.QueryString("T")

if Tipo="Produto" then
	if ItemID<>"0" then
		set reg = db.execute("select * from tissmedicamentosquimioterapia where id="&ItemID)
		if not reg.eof then
			ProdutoID = reg("ProdutoID")
			TabelaID = reg("TabelaID")
			CodigoMedicamento = reg("CodigoMedicamento")
            Descricao = reg("Descricao")
			DataAdministracao = reg("DataAdministracao")
			DosagemMedicamento = reg("DosagemMedicamento")
			UnidadeMedidaMedicamento = reg("UnidadeMedidaMedicamento")
			ViaADM = reg("ViaADM")
			Frequencia = reg("Frequencia")
		end if
    else
        TabelaID = "22"
	end if
	%>
        <div class="row">
            <div class="col-md-3">
	            <%= selectInsert("* Medicamento", "gProdutoID", ProdutoID, "produtos", "NomeProduto", " onchange=""tissCompletaDados(4, this.value);""", "required='required", "") %>
            </div>
            <script>
                $('#gProdutoID').prop('required', true);
            </script>
            <%= quickField("simpleSelect", "TabelaID", "* Tabela", 3, TabelaID, "select * from tisstabelas order by descricao", "descricao", " empty='' required='required' no-select2") %>
            <div class="col-md-3">
                <%=selectProc("* Código do Medicamento", "CodigoMedicamento", CodigoMedicamento, "codigo", "TabelaID", "CodigoMedicamento", "Descricao", " required='required' ", "", "", "") %>
            </div>
            <div class="col-md-3">
                <%=selectProc("* Descrição", "Descricao", Descricao, "Descricao", "TabelaID", "CodigoMedicamento", "Descricao", " required='required' ", "", "", "") %>
            </div>
        </div>
        <div class="row">
            <%= quickField("datepicker", "DataAdministracao", "* Data Prevista para administração", 3, DataAdministracao, "", "", "required") %>
            <%= quickField("text", "DosagemMedicamento", "* Doses", 3, DosagemMedicamento, "", "", " required") %>
            <%= quickField("text", "ViaADM", "* Via Adm", 3, ViaADM, "", "", " required minlength='1' maxlength='2'") %>
            <%= quickField("number", "Frequencia", "* Frequência", 3, Frequencia, "", "", " required min='1' max='99'") %>
        </div>
      <%
id = ItemID
end if
%>
<div style="float: right;margin-top: 15px">
	<button class="btn btn-success btn-sm"><i class="far fa-save"></i> Salvar</button>
    <button class="btn btn-sm btn-default" type="button" onclick="itemQuimioterapia('<%=Tipo %>', 0, <%=ItemID %>, 'Cancela');">
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
       url:"saveModalQuimioterapia.asp?I=<%=request.QueryString("I")%>&II=<%=request.QueryString("II")%>&T=<%=request.QueryString("T")%>",
       data:$("#frmModal, #GuiaQuimioterapia").serialize(),
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