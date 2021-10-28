<!--#include file="connect.asp"-->
<%IF req("ClientLicencaID") <> "" THEN
    licencaSql  = "SELECT GROUP_CONCAT('|',id,'|') as licencas FROM cliniccentral.licencas WHERE Cliente = "&req("ClientLicencaID")
    set licencasObj = db.execute(licencaSql)
    Licencas = ""
    IF NOT licencasObj.EOF THEN
        Licencas = licencasObj("licencas")
    END IF

    response.write(Licencas)
    response.end
END IF%>
<!--#include file="modalcontrato.asp"-->
<style>
.duplo>tbody>tr:nth-child(4n+1)>td,
.duplo>tbody>tr:nth-child(4n+2)>td
{    background-color: #f9f9f9;
}
.duplo>tbody>tr:nth-child(4n+3)>td,
.duplo>tbody>tr:nth-child(4n+4)>td
{    background-color: #ffffff;
}
</style>

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
tableName = "invoicesfixas"
CD = req("T")
InvoiceID = req("I")

if CD="C" then
	Titulo = "Receita Fixa"
	Subtitulo = "Receber de"
    onchangeParcelas = " onchange=""formaRecto()"""
else
	Titulo = "Despesa Fixa"
	Subtitulo = "Pagar a"
    onchangeParcelas = ""
end if

if InvoiceID="N" then
	sqlVie = "select id, sysUser, sysActive from "&tableName&" where sysUser="&session("User")&" and sysActive=0 and CD='"&CD&"'"
	set vie = db.execute(sqlVie)
	if vie.eof then
		db_execute("insert into "&tableName&" (sysUser, sysActive, CD, Intervalo, TipoIntervalo, Value) values ("&session("User")&", 0, '"&CD&"', 1, 'm', 0)")
		set vie = db.execute(sqlVie)
	end if
    if req("PacienteID")<>"" then
        reqPacDireto = "&PacienteID="&req("PacienteID")
    end if
	response.Redirect("?P=Recorrente&I="&vie("id")&"&A="&req("A")&"&Pers=1&T="&CD )'A=AgendamentoID quando vem da agenda
else
	set data = db.execute("select * from "&tableName&" where id="&InvoiceID)
	if data.eof then
		response.Redirect("?P=Recorrente&I=N&Pers=1&T="&CD)
	end if
end if

ContaID = data("AccountID")
AssID = data("AssociationAccountID")
Pagador = AssID&"_"&ContaID
Intervalo = data("Intervalo")
TipoIntervalo = data("TipoIntervalo")
RepetirAte = data("RepetirAte")
DiasAntes = data("DiasAntes")
EmitirNotaAntecipada = data("EmitirNotaAntecipada")
TipoContaFixaID = data("TipoContaFixaID")
PaymentMethodID = data("PaymentMethodID")
ValorMinimoPorUsuario = data("ValorMinimoPorUsuario")
Licencas = data("Licenca")
if data("sysActive")=1 then
    PrimeiroVencto = data("PrimeiroVencto")
else
    PrimeiroVencto = date()
end if

LicencaFinanceiro =  session("Banco")="clinic100003" or session("Banco")="clinic5459"

%>

<script type="text/javascript">
    $(document).ready(function(){
        $(".crumb-active a").html("<%=Titulo%>");
        $(".crumb-icon a span").attr("class", "far fa-refresh");
        <%
        if (aut("contasapagarI") and CD="D") OR (aut("contasareceberI") and CD="C") then
            %>
            $(".topbar-right").html('<button class="btn btn-sm btn-primary" onclick="$(\'#save\').click()"><i class="far fa-save"></i> Salvar</button>');
            <%
        end if
        %>
    });
</script>


<br />

<div class="row">

<%
posModalPagar = "fixed"
%>
<!--#include file="invoiceEstilo.asp"-->




  <div class="col-xs-12">
    <form id="formItens" action="" method="post">
    <input id="Lancto" type="hidden" name="Lancto" value="<%=req("Lancto")%>">
    <%'=header("recorrente", titulo, data("sysActive"), InvoiceID, 1, "Follow")%>
    <button id="save" class="hidden">Salvar</button>
   
    <input type="hidden" id="sysActive" name="sysActive" value="<%=data("sysActive")%>" />



    <div class="col-md-9">
        <div class="panel">
            <div class="panel-body">
                <div class="row">
                    <div class="col-md-4">
                        <%
                        if req("Ent")="Conta" then
                            %>
                            <input type="hidden" name="AccountID" id="AccountID" value="<%=Pagador %>" />
                        <%else %>
                            <%=selectInsertCA(Subtitulo, "AccountID", Pagador, "5, 4, 3, 2, 6", "", " required", "")%>
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
                    <%=quickField("empresa", "CompanyUnitID", "Unidade", 4, UnidadeID, "", "", "")%>

                   

                    <%=quickField("datepicker", "PrimeiroVencto", "Primeiro Vencimento", 2, PrimeiroVencto, "input-mask-date", "", " required" )%>
                    <%=quickField("datepicker", "RepetirAte", "Repetir até", 2, RepetirAte, "", "", " placeholder='Ilimitado'")%>
                </div>
                <div class="row">
                    <%=quickField("number", "Intervalo", "Intervalo da Recorrência", 2, Intervalo, "", "", " min='1' required")%>
                    <%=quickField("simpleSelect", "TipoIntervalo", "&nbsp;", 2, TipoIntervalo, "select 'm' id, 'Mês(es)' label UNION ALL select 'd', 'Dia(s)' UNION ALL select 'yyyy', 'Ano(s)'", "label", " required semVazio ")%>
                    <%= quickfield("simpleSelect", "PaymentMethodID", "Forma de Pagamento", 2, PaymentMethodID, "select id, PaymentMethod from cliniccentral.sys_financialpaymentmethod where TextC<>'' AND id in(1,8,4) ORDER BY PaymentMethod", "PaymentMethod", "") %>
                    <% if LicencaFinanceiro then %>
                        <%=quickField("number", "DiasAntes", "Dias Antes para Processamento", 2, DiasAntes, " ", "", " ")%>
                        <%= quickfield("simpleSelect", "TipoContaFixaID", "Tipo de Conta de Pagamento", 2, TipoContaFixaID, "SELECT * FROM cliniccentral.tiposcontasfixas", "Descricao", "") %>
                        <%=quickField("simpleCheckbox", "FecharAutomatico", "Fechar fatura automático", 2,data("FecharAutomatico"), "", "", "")%>
                        <div style="margin-top: 15px">
                            <%=quickField("simpleCheckbox", "EmitirNotaAntecipada", "Emitir nota antecipada", "2",EmitirNotaAntecipada, "", "", "")%>
                        </div>
                    <% end if %>
                </div>
                <div class="row">
                <% if LicencaFinanceiro then
                    Licencas = ""
                    IF Pagador <> "" THEN
                        licencaSql  = "SELECT GROUP_CONCAT('|',id,'|') as licencas FROM cliniccentral.licencas WHERE Cliente = SUBSTRING_INDEX('"&Pagador&"', '_', -1)"
                        set licencasObj = db.execute(licencaSql)

                        IF NOT licencasObj.EOF THEN
                            Licencas = licencasObj("licencas")
                        END IF

                    END IF
                 %>
                    <!--
                     <%=quickField("currency", "ValorMinimoPorUsuario", "Mínimo por Usuários", 2, ValorMinimoPorUsuario, " ", "", " ")%>
                     -->
                     <%=quickField("multiple", "Licenca", "Licença", 10, Licencas, "SELECT licencas.id,coalesce(concat(licencas.id,' - ',NomeContato,' - ',NomeEmpresa),CONCAT(licencas.id,' - ',pacientes.NomePaciente),licencas.id) as NomeContato FROM cliniccentral.licencas LEFT JOIN pacientes ON pacientes.id = cliniccentral.licencas.Cliente", "NomeContato", " ")%>
                <% end if %>
                </div>
            </div>
        </div>
        <div class="panel">
            <div class="panel-heading">
                <span class="panel-title">Itens <small>&raquo; servi&ccedil;os, produtos e outros</small></span>
                <div class="panel-controls">
                    <div class="btn-toolbar">
                	    <%if CD="C" then%>
                        <div class="btn-group">
                            <button class="btn btn-success btn-sm dropdown-toggle disable" data-toggle="dropdown">
                            <i class="far fa-plus"> Adicionar Item</i>
                            <span class="far fa-caret-down icon-on-right"></span>
                            </button>
                            <ul class="dropdown-menu dropdown-success">
                                <li>
                                <a href="javascript:itens('S', 'I', 0)">Consulta ou Procedimentos</a>
                                </li>
                                <li class="hide">
                                <a href="#">Produto</a>
                                </li>
                                <li>
                                <a href="javascript:itens('O', 'I', 0)">Outras Receitas</a>
                                </li>
                            </ul>
                        </div>
                        <% Else %>
                            <button onClick="itens('O', 'I', 0)" type="button" class="btn btn-success btn-sm disable"><i class="far fa-plus"> Adicionar Item</i></button>
                        <% End If %>

    
    
                        <div class="btn-group">
                            <button class="btn btn-success btn-sm dropdown-toggle disable<% If CD="D" Then %> hidden<% End If %>" data-toggle="dropdown">
                            <i class="far fa-plus"> Adicionar Pacote</i>
                            <span class="far fa-caret-down icon-on-right"></span>
                            </button>
                            <ul class="dropdown-menu dropdown-success">
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
    
    
                    </div>            
                </div>
            </div>
            <div class="row">
                <div class="col-xs-12" id="invoiceItens">
                    <%server.Execute("invoiceItensFixa.asp")%>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="panel">
            <div class="panel-heading">
                <span class="panel-title">
                    <i class="far fa- blue"></i>
                    CONTAS GERADAS
                </span>
            </div>
            <div class="panel-body">
                <div class="col-md-12" id="RecorrenteLista">
                    Carregando...
                </div>
            </div>
        </div>
    </div>
    
    



        <input type="hidden" name="T" value="<%=req("T")%>" />
    </form>
  </div>
</div>
<script type="text/javascript">
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
	$.post("invoiceItensFixa.asp?I=<%=InvoiceID%>&Row="+inc, {T:T,A:A,II:II}, function(data, status){
	if(A=="I"){
		$("#footItens").before(data);
	}else if(A=="X"){
		eval(data);
	}else{
		$("#invoiceItens").html(data);
	}
});}

function formaRecto(){
	$.post("invoiceSelectPagto.asp?I=<%=req("I")%>&T=<%=req("T")%>", $("#formItens").serialize(), function(data, status){ $("#selectPagto").html(data) });
}

function recalc(input){
	$.post("recalc.asp?InvoiceID=<%=InvoiceID%>&input="+input, $("#formItens").serialize(), function(data, status){ eval(data) });
}

function geraParcelas(Recalc){
	$.post("invoiceParcelas.asp?I=<%=req("I")%>&T=<%=req("T")%>&Recalc="+Recalc, $("#formItens").serialize(), function(data, status){ $("#invoiceParcelas").html(data) });
}

$("#formItens").submit(function(){
	$.post("invoiceFixaSave.asp?I=<%=InvoiceID%>&T=<%=req("T")%>", $("#formItens").serialize(), function(data, status){ eval(data) });
	return false;
});


function calcRepasse(id){
	$.post("invoiceRepasse.asp?Row="+id, $("#formItens").serialize(), function(data){ $("#rat"+id).html(data) });
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
    $("#modal-table").modal("show");
    $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
    $.post("addContrato.asp?ModeloID="+ModeloID+"&InvoiceID="+InvoiceID+"&ContaID="+ContaID, "", function(data){
        $("#modal").html(data);
    })
}

function recorrenteLista(){
    $.post("RecorrenteLista.asp?I=<%=req("I")%>", $("form").serialize(), function(data){ $("#RecorrenteLista").html(data) })
}



$("#PrimeiroVencto, #Intervalo, #TipoIntervalo").change(function(){
    recorrenteLista();
})

recorrenteLista();

<!--#include file="jQueryFunctions.asp"-->
<!--#include file="financialCommomScripts.asp"-->
</script>
<script>
 $(function() {
       document.addEventListener("click", (arg) => {
           let dataValor = $(arg.target).attr("data-valor")

           if(!dataValor){
               return ;
           }

           if((dataValor).indexOf("3_") === -1){
               return false;
           }

           $.post("Recorrente.asp?ClientLicencaID="+dataValor.replace("3_",""), "", function(data){
               $("#Licenca").val(data.split(",")).multiselect("rebuild")
           })

       }, true);
 });
 </script>
<input type="hidden" name="PendPagar" id="PendPagar" />

<%
' LINK PARA ORDEM DE COMPRA
' Verifica se a invoice foi gerada pela Ordem de Compra
' para inserir o botão com link para a ordem de compra.
' Foi feito desta forma para não precisar alterar a estrutura da tabela de invoice.
geracao = data("Name")
if InStr(geracao, "ordem de compra") > 0 then
    set ordemDeCompra = db.execute("SELECT id FROM compras_ordem WHERE invoiceFixaId = "&InvoiceID& " AND deletedAt IS NULL LIMIT 1")
    if not ordemDeCompra.eof then
        ordemId = ordemDeCompra("id")
%>
        <script>
        // insere o botão para ir para a Ordem de Compra
        $(document).ready(function() {
            $('#topbar .topbar-right button').after(' <a class="btn btn-warning btn-sm" href="?P=solicitacoescompras&Pers=1#/ordens/edit/<%=ordemId%>" title="Ir para  ordem de compra"><i class="far fa-shopping-cart bigger-110"></i></a>');
        });
        </script>
<%
    end if
end if
%>

<%'=request.QueryString() %>
<!--#include file="disconnect.asp"-->