<!--#include file="connect.asp"-->
<div class="modal-header">
    <h4 class="lighter blue">Detalhes do Cheque</h4>
</div>
<form id="formCheque" method="post" action="">
<div class="modal-body">

<div class="row">
    <div class="col-md-12">
        <%
        ids = ref("ids[]")
        idsSplt = split(ids,",")

        cheques = ""

        for i = 0 to ubound(idsSplt)
            if i > 0 then
                cheques = cheques& ","
            end if

            cheques = cheques & idsSplt(i)
        next

        nCheques = ubound(idsSplt) + 1

        %>
        <strong><%=nCheques%> cheques selecionados.</strong>
    </div>
    <input type="hidden" name="cheques" value="<%=cheques%>">
    <div class="col-md-6">
        <label for="ContaCorrente">Localiza&ccedil;&atilde;o</label><br>
        <%=simpleSelectCurrentAccounts("ContaCorrente", "1, 7, 2, 4, 5, 6, 3", "", "","")%>
    </div>
    <div class="col-md-3" id="divDataMovimentacao">
        <label for="DataMovimentacao">Data da Movimenta&ccedil;&atilde;o</label><br />
        <%=quickfield("datepicker", "DataMovimentacao", "", 3, date(), "", "", "")%>
    </div>
    <%=quickfield("simpleSelect", "StatusID", "Status", 3, "", "select * from chequestatus", "Descricao", "")%>
</div>

</div>
<div class="modal-footer">
	<button class="btn btn-primary pull-right"><i class="far fa-save"></i> Salvar</button>
</div>
</form>
<script>
$("#divDataMovimentacao").css("display", "none");

$("#formCheque").submit(function(){
	$.post("saveTransferirChequesEmLote.asp", $("#formCheque").serialize(), function(data, status){ eval(data) });
	return false;
});
</script>