<!--#include file="connect.asp"-->
<!--#include file="modalcontrato.asp"-->
<style type="text/css">
.duplo>tbody>tr:nth-child(4n+1)>td,
.duplo>tbody>tr:nth-child(4n+2)>td
{    background-color: #f9f9f9;
}
.duplo>tbody>tr:nth-child(4n+3)>td,
.duplo>tbody>tr:nth-child(4n+4)>td
{    background-color: #ffffff;
}

.modal-lg{
    width:70%!important
}
</style>
<script src="assets/js/cmc7.js"></script>
<%if request.ServerVariables("REMOTE_ADDR")<>"::1" then %>
    <script src="feegow_components/assets/feegow-theme/vendor/plugins/datatables/media/js/jquery.dataTables.js"></script>
<%end if %>
<script type="text/javascript">
    function disable(val){
        $(".disable, #searchAccountID, input[id^='searchItemID']").prop("disabled", val);
        if(val==true){
            $("#alert-disable").removeClass("hidden");
        }else{
            $("#alert-disable").addClass("hidden");
        }
    }
</script>

<%
tableName = "sys_financialinvoices"
CD = req("T")
InvoiceID = req("I")


if CD="C" then
	Titulo = "Contas a Receber"
	Subtitulo = "Receber de"
    onchangeParcelas = " onchange=""formaRecto()"""
    icone = "arrow-circle-down"
    if isnumeric(InvoiceID) then
        'db_execute("delete from itensinvoiceoutros where InvoiceID="&InvoiceID&" and sysActive=0")
    end if
else
	Titulo = "Contas a Pagar"
	Subtitulo = "Pagar a"
    onchangeParcelas = ""
    icone = "arrow-circle-up"
end if

if InvoiceID="N" then
	sqlVie = "select id, sysUser, sysActive from "&tableName&" where sysUser="&session("User")&" and sysActive=0 and CD='"&CD&"'"
	set vie = db.execute(sqlVie)
	if vie.eof then
		db_execute("insert into "&tableName&" (sysUser, sysActive, CD, Recurrence, RecurrenceType, Value) values ("&session("User")&", 0, '"&CD&"', 1, 'm', 0)")
		set vie = db.execute(sqlVie)
	end if
    if req("PacienteID")<>"" then
        reqPacDireto = "&PacienteID="&req("PacienteID")
    end if
	response.Redirect("?P=invoice&I="&vie("id")&"&A="&req("A")&"&Pers=1&T="&CD&"&Ent="&req("Ent")& reqPacDireto)'A=AgendamentoID quando vem da agenda
else
	set data = db.execute("select * from "&tableName&" where id="&InvoiceID)
	if data.eof then
		response.Redirect("?P=invoice&I=N&Pers=1&T="&CD)
    else
        if CD<>data("CD") then
            response.Redirect("?P=invoice&I="& InvoiceID &"&Pers=1&T="&data("CD"))
        end if
	end if
end if

ContaID = data("AccountID")
AssID = data("AssociationAccountID")
nroNFe = data("nroNFe")

if req("PacienteID")="" then
	Pagador = AssID&"_"&ContaID
else
	Pagador = "3_"&req("PacienteID")
end if
%>

<%
posModalPagar = "fixed"
%>
<!--#include file="invoiceEstilo.asp"-->




    <form id="formItens" action="" method="post">
    <input id="Lancto" type="hidden" name="Lancto" value="<%=req("Lancto")%>">
    <%=header("sys_financialinvoices", titulo, data("sysActive"), InvoiceID, 1, "Follow")%>

        <br />

    <div class="alert alert-danger text-center no-margin no-padding hidden" id="alert-disable">
        <small><i class="far fa-exclamation-circle"></i> Você não pode alterar os dados desta conta, pois existem pagamentos realizados.</small>
    </div>
   
    <input type="hidden" id="sysActive" name="sysActive" value="<%=data("sysActive")%>" />
    <div class="panel">
        <div class="panel-body">
        <div class="col-md-3">
            <%
            if req("Ent")="Conta" then
                %>
                <input type="hidden" name="AccountID" id="AccountID" value="<%=Pagador %>" />
            <%else %>
                <label><%=Subtitulo%></label><br />
                <%=selectInsertCA("", "AccountID", Pagador, "5, 4, 3, 2, 6, 1", "", " required", "")%>
            <%end if %>
        </div>
        <%
        if data("sysActive")=0 then
            UnidadeID = session("UnidadeID")
			sysDate = date()
        else
            UnidadeID = data("CompanyUnitID")
			sysDate = data("sysDate")
        end if
        %>
        <%=quickField("empresa", "CompanyUnitID", "Unidade", 2, UnidadeID, "", "", onchangeParcelas)%>
        <%=quickField("datepicker", "sysDate", "Data", 2, sysDate, "input-mask-date", "", "")%>
        <%=quickField("text", "nroNFe", "N. Fiscal", 2, nroNFe, "text-right", "", "")%>
        <div class="col-md-3">
            <%=quickField("memo", "Description", "", 3, data("Description"), "", "", " rows='2' placeholder='Observa&ccedil;&otilde;es...'")%>
        </div>
        </div>
    </div>
    <%
    if CD="C" then
    %>
     <span class="checkbox-custom checkbox-warning">
     <input type="checkbox" name="ExecutadoTodos" id="ExecutadoTodos" value="S">
     <label for="ExecutadoTodos">
        Marcar todos executado </label></span>
     <br>
     <br>

     <%
    end if
     %>
    <div class="panel">
        <div class="panel-heading">
            <span class="panel-title">Itens <small>&raquo; servi&ccedil;os, produtos e outros</small></span>
            <span class="panel-controls">
                	<%
                        if session("Odonto")=1 and CD="C" then
                            %>
                        <div class="btn-group">
                            <button type="button" class="btn btn-primary btn-sm" id="btn-abrir-modal-odontograma">
                                Odontograma
                            </button>
                        </div>
                            <%
                        end if
                        %>


                    <div class="btn-group">
                        <button class="btn btn-success btn-sm dropdown-toggle disable" data-toggle="dropdown">
                        <i class="far fa-plus"></i> Adicionar Item
                        <span class="far fa-caret-down icon-on-right"></span>
                        </button>
                        <ul class="dropdown-menu dropdown-success pull-right">
                      <%
                          if CD="C" then
                            descOutra = "Receita"
                          %>
                            <li>
                                <a href="javascript:itens('S', 'I', 0)">Consulta ou Procedimento</a>
                            </li>
                          <%
                          else
                            descOutra = "Despesa"
                          end if
                          %>
                            <li>
                                <a href="javascript:itens('M', 'I', 0)">Produto</a>
                            </li>
                            <li>
                                <a href="javascript:itens('O', 'I', 0)">Outra <%=descOutra %></a>
                            </li>
                        </ul>
                    </div>


    
                    <div class="btn-group">
                        <button class="btn btn-success btn-sm dropdown-toggle disable<% If CD="D" Then %> hidden<% End If %>" data-toggle="dropdown">
                        <i class="far fa-plus"></i> Adicionar Pacote
                        <span class="far fa-caret-down icon-on-right"></span>
                        </button>
                        <ul class="dropdown-menu dropdown-success pull-right">
                          <%
                            set pac = db.execute("select * from pacotes where sysActive=1")
                            while not pac.eof
                            %>  
                            <li>
                            <a href="javascript:itens('P', 'I', <%=pac("id")%>)"><%=pac("NomePacote")%></a>
                            </li>
                            <%
                          pac.movenext
                          wend
                          pac.close
                          set pac=nothing
                          %>
                        </ul>
                    </div>
    
            </span>
    
        </div>
        <div class="panel-body pn">
            <div class="bs-component" id="invoiceItens">
                <%server.Execute("invoiceItens.asp")%>
            </div>
        </div>
   </div>

    <div class="panel">

        <div class="panel-body" id="selectPagto">
            <%server.Execute("invoiceSelectPagto.asp")%>
        </div>
        <div id="NFeContent"></div>
        <div class="panel-body pn">
            <div class="bs-component" id="invoiceParcelas">
                <%server.Execute("invoiceParcelas.asp")%>
            </div>
            <input type="hidden" name="T" value="<%=req("T")%>" />
        </div>
    </div>
    
    </form>

<div id="feegow-components-modal" class="modal fade" role="dialog">
    <div class="modal-dialog modal-lg">

        <!-- Modal content-->
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h4 class="modal-title"></h4>
            </div>
            <div class="modal-body">
                <div class="modal-loading">
                <i class="far fa-circle-o-notch fa-spin fa-fw"></i>
                <span class="sr-only">...</span>
                Carregando...
                </div>
                <div class="modal-body-content"></div>
            </div>
            <div class="modal-footer"></div>
        </div>
    </div>
</div>
<script type="text/javascript">
var $componentsModal = $("#feegow-components-modal"),
        $componentsModalTitle = $componentsModal.find('.modal-title'),
        $componentsModalBodyContent = $componentsModal.find('.modal-body-content'),
        $componentsModalFooter = $componentsModal.find('.modal-footer'),
        $componentsModalLoading = $componentsModal.find('.modal-loading'),
        defaultComponentsModalFooter = '<button type="button" class="btn btn-default" data-dismiss="modal">Fechar</button>';

var $btnMarcarTodos = $("#ExecutadoTodos");

$btnMarcarTodos.click(function() {
//    console.log("c")

    var $checks = $(".checkbox-primary");

    var $preenchido = false;

    $.each($checks, function() {
        if($(this).find("input").prop("checked") && !$preenchido){
            $preenchido = $(this).parents("tr").next("tr");

        }else if($preenchido){
            var prf = $preenchido.find(".select2-single").val();
            var date = $preenchido.find(".date-picker").val();
            var hora = $preenchido.find(".input-mask-l-time").first().val();
            var $des = $(this).parents("tr").next("tr");


            $des.find(".select2-single").val(prf).change();
            $des.find(".date-picker").val(date);
            $des.find(".input-mask-l-time").first().val(hora);

            $(this).find("input").click()
        }
    });

});

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

function parametrosInvoice(ElementoID, id){
	$.ajax({
		type:"POST",
		url:"invoiceParametros.asp?ElementoID="+ElementoID+"&id="+id,
		data:$("#formItens").serialize(),
		success:function(data){
			eval(data);
			$(".valor").val( $("#Valor").val() );
		}
	});
}

function parametrosProduto(ElementoID, id){
	$.ajax({
		type:"POST",
		url:"invoiceProdutos.asp?ElementoID="+ElementoID+"&id="+id,
		data:$("#formItens").serialize(),
		success:function(data){
			eval(data);
			$(".valor").val( $("#Valor").val() );
		}
	});
}

function pagamento(mi){
	if(mi!=""){
		$(".parcela").prop("checked", false);
		$("#Parcela"+mi).prop("checked", true);
	}
	if($("#sysActive").val()==0 && 1==2){
		bootbox.confirm("Para efetuar o pagamento &eacute; necess&aacute;rio salvar esta conta.<br /><strong>Deseja salv&aacute;-la agora?</strong>", function(result) {
			if(result) {
				$("#formItens").submit();
			}
		});
	}else{
		$.post("invoicePagamento.asp?I=<%=InvoiceID%>&Lancto=<%=req("Lancto")%>", $("#formItens").serialize(), function(data, status){ $("#modal-table").modal("show"); $("#modal").html(data) });
	}
	$.post("invoicePagamento.asp?I=<%=InvoiceID%>&Lancto=<%=req("Lancto")%>", $("#formItens").serialize(), function(data, status){ $("#modal-table").modal("show"); $("#modal").html(data) });
}

function check(mi){
	if(mi!=""){
		$(".parcela").prop("checked", false);
		$("#Parcela"+mi).prop("checked", true);
	}
}

function imprimir(){
	if($("#sysActive").val()==0){ bootbox.alert("Para imprimir este recibo voc&ecirc; precisa salvar esta conta.", function(result) {});
	}else{ $.post("reciboIntegrado.asp?I=<%=InvoiceID%>", $("#formItens").serialize(), function(data, status){ $("#modal-table").modal("show"); $("#modal").html(data) }); } }


function itens(T, A, II){
	var inc = $('[data-val]:last').attr('data-val');
	if(inc==undefined){inc=0}
	$.post("invoiceItens.asp?I=<%=InvoiceID%>&Row="+inc, {T:T,A:A,II:II}, function(data, status){
	if(A=="I"){
		$("#footItens").before(data);
	}else if(A=="X"){
		eval(data);
	}else{
		$("#invoiceItens").html(data);
	}
});}

function formaRecto(){
    $.post("invoiceSelectPagto.asp?I=<%=req("I")%>&T=<%=req("T")%>&FormaID="+ $("#FormaID option:selected").attr("data-frid"), $("#formItens").serialize(), function(data, status){ $("#selectPagto").html(data) });
}
function planPag(I){
    $.post("invoiceParcelas.asp?PlanoPagto="+ I +"&I=<%=req("I")%>&T=<%=req("T")%>", $("#formItens").serialize(), function(data, status){ $("#invoiceParcelas").html(data) });
}

function recalc(input){
	$.post("recalc.asp?InvoiceID=<%=InvoiceID%>&input="+input, $("#formItens").serialize(), function(data, status){ eval(data) });
}

function geraParcelas(Recalc){
	$.post("invoiceParcelas.asp?I=<%=req("I")%>&T=<%=req("T")%>&Recalc="+Recalc, $("#formItens").serialize(), function(data, status){ $("#invoiceParcelas").html(data) });
}

$("#formItens").submit(function(){
    $("#btnSave").prop("disabled", true);
	$.post("invoiceSave.asp?I=<%=InvoiceID%>&Lancto=<%=req("Lancto")%>", $("#formItens").serialize(), function(data, status){ eval(data) });
	return false;
});


function calcRepasse(id){
	$.post("invoiceRepasse.asp?Row="+id+"&InvoiceID=<%=InvoiceID%>", $("#formItens").serialize(), function(data){ $("#rat"+id).html(data) });
}

function deleteInvoice(){
	if(confirm('Tem certeza de que deseja excluir esta conta?')){
		location.href='./?P=ContasCD&T=<%=req("T")%>&Pers=1&X=<%=req("I")%>';
	}
}

$(function() {
    $( "#pagar" ).draggable();
});

if( $(".parte-paga").size()>0 ){
    disable(true);
}

<%
if req("Lancto")="Dir" then
	%>
	$(document).ready(function(e) {
        formaRecto(); allRepasses();
    });
    <%
end if
%>

function pagar(){
    var clicked = $(".parcela:checked").length;
    if(clicked==0){
        $("#pagar").fadeOut();
    }else{
        $("#pagar").fadeIn(function(){
            $.post("pagar.asp?T=<%=CD%>", $(".parcela").serialize(), function(data){ $("#pagar").html(data) });
        });
    }
}

function addContrato(ModeloID, InvoiceID, ContaID){
    if($("#AccountID").val()=="" || $("#AccountID").val()=="0" || $("#AccountID").val()=="_"){
        alert("Selecione um pagador para gerar o contrato.");
        $("#searchAccountID").focus();
    }else{
        $("#modal-table").modal("show");
        $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
        $.post("addContrato.asp?ModeloID="+ModeloID+"&InvoiceID="+InvoiceID+"&ContaID="+ContaID, "", function(data){
            $("#modal").html(data);
        });
    }
}

<!--#include file="jQueryFunctions.asp"-->
<!--#include file="financialCommomScripts.asp"-->
var invoiceId = '<%=InvoiceID%>';
var userId = '<%=session("User")%>';

function dynamicallyLoadScript(url) {
    var script = document.createElement("script"); // Make a script DOM node
    script.src = url; // Set it's src to the provided URL

    document.head.appendChild(script); // Add it to the end of the head section of the page (could change 'head' to 'body' to add it to the end of the body section instead)
}
dynamicallyLoadScript("../feegow_components/assets/js/field-validator.js?cache-control=1");
dynamicallyLoadScript("../feegow_components/assets/modules-assets/nfe/js/nota-fiscal-eletronica-1.2.0.js");

function modalNFE(y){
    changeComponentsModalFooter('');
    changeComponentsModalTitle('Nota Fiscal eletrônica');
    var fn = appendComponentsModal();
    $.get("../feegow_components/nota_fiscal_eletronica/test",{invoiceId: invoiceId, userId: userId},function(data) {
        fn(data);
    });
}

        $("#selAll").on("click", function(){
            $("input[id^=Executado]").click();
            $("input[id^=Executado]").click();
            $("input[id^=Executado]").prop("checked", true);
            $("select[id^=ProfissionalID]").val("5_21");
            $("input[id^=DataExecucao]").val("02/01/2017");
        });

    if("<%=req("time")%>" != ''){
    console.log('recalc...');
        recalc();
    }

    $('#btn-abrir-modal-odontograma').on('click', function () {
        var accountId = $("#AccountID").val();
        if(accountId == '_'){
            alert('Você precisa selecionar um paciente!');
        }else{
            changeComponentsModalTitle('Odontograma');
            var fn = appendComponentsModal();
            changeComponentsModalFooter('<button type="button" class="btn btn-success" id="feegow-odontograma-finalizar">Finalizar</button>');

            $.get('https://components-legacy.feegow.com/index.php/odontograma?P='+accountId+'&B=<%=ccur(replace(session("Banco"), "clinic", ""))*999 %>&O=Invoice&U=<%=session("User")%>&I=<%=InvoiceID%>&L=<%=session("Banco")%>',
            function (data) {
                fn(data);
            });
        }
    });
    <% if req("Scan")="1" then %>
    $(document).ready(function(){
        $(".modal-content").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
        $("#modal-table").modal("show");
        $.post("ScanExecutado.asp?I=<%=InvoiceID%>", {}, function(data){
            $(".modal-content").html(data);
        });
    });
    <% end if %>


function modalEstoque(ItemInvoiceID, ProdutoID, ProdutoInvoiceID){
    $("#modal-table").modal("show");
    $.get("invoiceEstoque.asp?CD=<%=CD%>&I="+ ProdutoID +"&ItemInvoiceID="+ ItemInvoiceID + "&ProdutoInvoiceID=" + ProdutoInvoiceID, function (data) {
        $("#modal").html( data );
    });
}
function lancar(P, T, L, V, PosicaoID, ItemInvoiceID, AtendimentoID, ProdutoInvoiceID){
    $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
    $.ajax({
        type:"POST",
        url:"EstoqueLancamento.asp?P="+P+"&T="+T+"&L="+L+"&V="+V+"&PosicaoID="+PosicaoID +"&ItemInvoiceID=" + ItemInvoiceID + "&ProdutoInvoiceID=" + ProdutoInvoiceID,
        success: function(data){
            setTimeout(function(){
                $("#modal").html(data);
            }, 500);
        }
    });
}


</script>
<input type="hidden" name="PendPagar" id="PendPagar" />

<%'=request.QueryString %>
<!--#include file="disconnect.asp"-->