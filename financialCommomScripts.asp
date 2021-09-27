function xMov(I){
    /*
    if(confirm('ATENÇÃO:\n\nAo cancelar este pagamento, você removerá todos os lançamentos relativos a ele.\n\nTem certeza de que deseja prosseguir?')){
        $.post("xMov.asp", {I:I}, function(data){ eval(data) });
    }
    $('.contratobt').attr("disabled", true);
    $('.rgrec').attr("disabled", true)
    */

    /*
    var jst = prompt("Descreva a justificativa para este cancelamento", "");
    if(jst!=null){
        $.post("xMov.asp", {I:I, jst:jst}, function(data){ eval(data) });
    }
    $('.contratobt').attr("disabled", true);
    $('.rgrec').attr("disabled", true)
    */

    $.post("xMovVerify.asp?I="+I, '', function(data){ $('#pagar .modal-body').html(data); });

}


function transaction(transactionID, Save, ModalMeuCaixa){
	var dados = $('#formTransaction').serialize();
	$.ajax({
		type: "POST",
		url: "transaction.asp?transactionID="+transactionID+"&Save="+Save,
		data: dados,
		success: function( data )
		{
		//trata por eval

		    if(Save!=="Save") {
		        setTimeout(function(){
                    var TelaFinanceiro = $("#modal").parents(".modal").hasClass("in");

                    if(TelaFinanceiro){
                        $("#modal").html(data);
                    }else{
                        $("#modalCaixaContent").html(data);
                    }
                }, 200);
            }else{
                eval(data);
            }
		}
	});
}

function modalPaymentDetails(movementID, deleteID){
    $("#pagar").html(`<div class="p10">
                                <center>
                                     <i class="far fa-2x fa-circle-o-notch fa-spin"></i>
                                 </center>
                            </div>`)
    $("#pagar").fadeIn();
    $.post("modalPaymentDetails.asp",{
		   movementID:movementID,
		   deleteID:deleteID
		   },function(data,status){
      $("#pagar, #modal").html(data);
    });
}

function modalPaymentAttachments(movementID){
    $.post("modalPaymentAttachments.asp",{
		   movementID:movementID
		   },function(data){
        $("#modal").html(data);
        $("#modal-table").modal("show");
    });
}

function getStatement(AccountID, DateFrom, DateTo, DeleteMovementID, CompanyUnitID){
	$("#Extrato").html('Carregando...');
	$.post("financialStatement.asp",{
		   AccountID:AccountID,
		   DateFrom:DateFrom,
           DateTo:DateTo,
           Pagto:$("#Pagto").val(),
           CompanyUnitID:CompanyUnitID,
		   DeleteMovementID:DeleteMovementID
		   },function(data,status){
	  $("#Extrato").html(data);
	});
}

function getExtratoConteudo(AccountID, DateFrom, DateTo, DeleteMovementID){
	$.post("ExtratoConteudo.asp",{
		   AccountID:AccountID,
		   DateFrom:DateFrom,
           DateTo:DateTo,
           Pagto:$("#Pagto").val(),
		   DeleteMovementID:DeleteMovementID
		   },function(data,status){
	  $("#Extrato").html(data);
	});
}

function extratoDireto(AccountID, DateFrom, DateTo, DeleteMovementID){
	$.post("ExtratoDireto.asp",{
		   AccountID:AccountID,
		   DateFrom:DateFrom,
           DateTo:DateTo,
           Pagto:$("#Pagto").val(),
		   DeleteMovementID:DeleteMovementID
		   },function(data,status){
	  $("#ExtratoDireto").html(data);
	});
}


function listaRecibos() {
    var _invoiceId = "<%=req("I")%>";

    if(_invoiceId!==""){
        InvoiceID=_invoiceId
    }

    openComponentsModal("listaRecibos.asp", {
        InvoiceID: InvoiceID
    }, "Recibos Gerados", true);
}


function calculaReembolso() {
    openComponentsModal("ConsultaDePrecos.asp", {
        InvoiceID: "<%=req("I")%>"
    }, "Calcular Reembolso", true, "Recalcular itens");
}


function dynamicallyLoadScript(url) {
    var script = document.createElement("script"); // Make a script DOM node
    script.src = url; // Set it's src to the provided URL

    document.head.appendChild(script); // Add it to the end of the head section of the page (could change 'head' to 'body' to add it to the end of the body section instead)
}
dynamicallyLoadScript("/feegow_components/assets/js/field-validator.js?cache-control=1");

<%
if session("Banco")="clinic5459" or session("Banco")="clinic3882" or session("Banco")="clinic2263" or  session("Banco")="clinic100000" or  session("Banco")="clinic6259" or  session("User")="81847" then
%>
dynamicallyLoadScript("https://app.feegow.com.br/modules/electronicinvoice/js/nota-fiscal-eletronica.js");
dynamicallyLoadScript("https://cdnjs.cloudflare.com/ajax/libs/axios/0.19.0/axios.min.js");

<%
else
%>
dynamicallyLoadScript("/feegow_components/assets/modules-assets/nfe/js/nota-fiscal-eletronica-1.2.0.js");
<%
end if
%>

function modalNFE(reciboId){
    if(!reciboId){
        reciboId=null;
    }
    <%
    if session("Banco")="clinic5459"  or session("Banco")="clinic3882" or session("Banco")="clinic2263" or  session("Banco")="clinic100000" or  session("Banco")="clinic6259" or  session("User")="81847" then
    %>

    changeComponentsModalFooter('');
    changeComponentsModalTitle('Nota Fiscal eletrônica');
    var fn = appendComponentsModal();

    $.get(domain+"electronicinvoice",{invoiceID: invoiceId, reciboId: reciboId},function(data) {
        fn(data);
    });
    <%
    else
    %>
    changeComponentsModalFooter('');
    changeComponentsModalTitle('Nota Fiscal eletrônica');
    var fn = appendComponentsModal();

    $.get(feegow_components_path+"nota_fiscal_eletronica/test",{invoiceId: invoiceId, reciboId: reciboId},function(data) {
        fn(data);
    });
    <%
    end if
    %>
}

function modalNFEBeta() {
    openComponentsModal("nfe/invoice/create-view", {invoiceId: invoiceId, provider: 'enotas'})
}

var $componentsModal = $("#feegow-components-modal"),
        $componentsModalTitle = $componentsModal.find('.modal-title'),
        $componentsModalBodyContent = $componentsModal.find('.modal-body-content'),
        $componentsModalFooter = $componentsModal.find('.modal-footer'),
        $componentsModalLoading = $componentsModal.find('.modal-loading'),
        defaultComponentsModalFooter = '<button type="button" class="btn btn-default" data-dismiss="modal">Fechar</button>';


function changeComponentsModalTitle(title) {
    $componentsModalTitle.html(title);
}

function appendComponentsModal() {
    $componentsModalLoading.fadeIn();
    changeComponentsModalBody();
    $componentsModal.modal('show');

    return function(data) {
        setTimeout(function () {
            changeComponentsModalBody(data);
            $componentsModalLoading.fadeOut(function () {
                $componentsModalBodyContent.fadeIn();
            });
        }, 200);
  }
}

function changeComponentsModalBody(body) {
    if(typeof body === 'undefined'){
        body = '';
        $componentsModalBodyContent.fadeOut();
    }
    $componentsModalBodyContent.html(body);
}

function changeComponentsModalFooter(footer) {
    $componentsModalFooter.html(defaultComponentsModalFooter + footer);
}


function abrirPleres(invoiceId) {
    openComponentsModal("labs-integration/pleres/exam-status", { I: invoiceId }, "Integração Pleres", false)
}

function abrirMatrix(invoiceId, labid = 1) {
    openComponentsModal("labs-integration/matrix/invoice-exams", {invoiceId: invoiceId, labid:labid }, false, false)
}

function abrirDiagBrasil(invoiceId,labid,itenscount) {
    openComponentsModal("labs-integration/diagbrasil/invoice-exams", {invoiceId: invoiceId, labid:labid, itens:itenscount }, false, false)
}

function abrirIntegracao(invoiceId,labid,itenscount) {
    switch (labid.trim()) {        
        case '1':
            openComponentsModal("labs-integration/matrix/invoice-exams", {invoiceId: invoiceId, labid:labid }, false, false);
            break;
        case '2':
            openComponentsModal("labs-integration/diagbrasil/invoice-exams", {invoiceId: invoiceId, labid:labid, itens:itenscount }, false, false);
            break;
        case '3':
            openComponentsModal("labs-integration/alvaro/invoice-exams", {invoiceId: invoiceId, labid:labid, itens:itenscount }, false, false);
            break;
        case '4':
            openComponentsModal("labs-integration/hermespardini/invoice-exams", {invoiceId: invoiceId, labid:labid, itens:itenscount }, false, false);
            break;
        default:
            alert ('Código de Laboratório não implementado');
        }
}

function abrirSelecaoLaboratorio(invoiceId,itenscount){
    openComponentsModal("labs-integration/invoice-lab-select", {invoiceId: invoiceId, itens:itenscount }, "Integração com Laboratórios", false, false)
}

function avisoLaboratoriosMultiplos(informacao) {
    $('#modalAlertaMultiploText').html(informacao); 
    $('#modalAlertaMultiplo').modal('toggle');
}

function selecionaLaboratorio() {
     var labid  = $('#selectLabID :selected').val();
     var invoiceid = $('#varinvoiceid').val();
     var itensCount = $('#varitenscount').val();

     abrirIntegracao(invoiceid,labid,itensCount);
    // if (labid ==1) { abrirMatrix(invoiceid, labid);  }
    // if (labid ==2) { abrirDiagBrasil(invoiceid,labid,itensCount); }
     
}