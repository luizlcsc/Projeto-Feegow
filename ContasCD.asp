<script src="js/highcharts.js"></script>
<script src="js/exporting.js"></script>

<div id="grafico" style="position:absolute; width:120px; height:120px; right:0; z-index:1000000; margin-top:-50px ; display: none"></div>

<style>
    text[text-anchor=end], .highcharts-button {
        display:none;
    }
</style>

<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<%
    posModalPagar = "fixed"
%>
<!--#include file="invoiceEstilo.asp"-->
<%
CD = req("T")


if req("T")="C" then
	titulo = "Contas a Receber"
	TabelaCategoria = "sys_financialincometype"
	tituloConta = "Receber de"
    icone = "arrow-circle-down"
else
	titulo = "Contas a Pagar"
	TabelaCategoria = "sys_financialexpensetype"
	tituloConta = "Pagar a"
    icone = "arrow-circle-up"

    idUser = session("User")
   
    set regraspermissoes = db.execute("SELECT REPLACE(limitarcontaspagar, '|', '') AS limitarcontaspagar FROM sys_users WHERE id ="&idUser)    
    queryTotal = " SELECT * from sys_financialexpensetype WHERE 1=1 "

    if not regraspermissoes.eof THEN
        limitarContasPagarValores = regraspermissoes("limitarcontaspagar")
        IF limitarContasPagarValores <> "" then
            queryTotal = " "&queryTotal&" and id not in("&limitarContasPagarValores&")"
        END IF
    end if

    queryTotal = queryTotal&" ORDER BY Name"
    set categoriaContasAPagar = db.execute(queryTotal)
    
end if


De = req("De")
Ate = req("Ate")

if De="" then
    De = session("ccDe")
end if
if Ate="" then
    Ate = session("ccAte")
end if

CategoriaID = req("CategoriaID")
Unidades = req("U")

if CategoriaID="" then
    CategoriaID = session("ccCategoriaID")
end if

if Unidades = "" then
    Unidades = session("ccUnidades")
end if

if Unidades="" then
	Unidades = session("Unidades")
end if

if De="" or Ate="" then
	De = cdate("1/"&month(date())&"/"&year(date()))
	Ate = dateadd("m", 1, De)
	Ate = dateadd("d", -1, Ate)

	if session("Banco")="clinic5459" or session("Banco")="clinic5760" or session("Banco")="clinic6118" then
	    De = date()
	    Ate = De
	end if
end if
%>

<script type="text/javascript">
    $(document).ready(function(){
        $(".crumb-active a").html("<%=Titulo%>");
        $(".crumb-icon a span").attr("class", "fa fa-<%=icone%>");
    });
</script>


<div class="row">
    <div class="col-xs-12">

        <form id="frmCD">
            <div class="panel hidden-print">
            <div class="panel-body">
                <div class="col-sm-12">
                    <div class="row">
                        <%=quickField("datepicker", "De", "De", 2, De, "", "", " required")%>
                        <%=quickField("datepicker", "Ate", "At&eacute;", 2, Ate, "", "", " required")%>
                        <div class="col-xs-2">
                            <label>Exibir</label><br />
                            <select class="form-control" id="Pagto" name="Pagto">
                                <option value="">Todas</option>
                                <option value="Q" <% If ref("Pagto")="Q" or req("Pagto")="Q" or (session("ccPagto")="Q" and req("Pagto")="") Then %> selected="selected" <% End If %>>Quitadas</option>
                                <option value="N" <% If ref("Pagto")="N" or req("Pagto")="N" or (session("ccPagto")="N" and req("Pagto")="") Then %> selected="selected" <% End If %>>N&atilde;o quitadas</option>
                            </select>
                        </div>
                        <%=quickField("empresaMulti", "CompanyUnitID", "Unidades", 4, Unidades, "", "", "")%>
                        <div class="col-md-2">
                            <label>&nbsp;</label><br />
                            <button class="btn btn-primary btn-block" id="Filtrate" name="Filtrate"><i class="fa fa-search bigger-110"></i> Filtrar</button>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-3">
                            <label>Categoria</label><br>

                            <% if req("T")="C" then
                                response.write(selectInsert("", "CategoriaID", "", TabelaCategoria, "Name", "", "", ""))
                                else %>
                                <select name="CategoriaID" class="categoria-single">
                                    <option value="">Selecione um item</option>
                                    <% while not categoriaContasAPagar.eof  %>
                                        <option value="<%=categoriaContasAPagar("id")%>"><%=categoriaContasAPagar("Name")%></option>
                                    <% 
                                    categoriaContasAPagar.movenext
                                    wend
                                    categoriaContasAPagar.close 
                                    set categoriaContasAPagar=nothing
                                    %>
                                </select>
                            <% end if %>
                        
                        </div>
                        <div class="col-md-3">
                            <label><%=tituloConta%></label><br />
                            <%=selectInsertCA("", "AccountID", session("ccAccountID"), "5, 4, 3, 2, 6, 1", "", "", "")%>
                        </div>
                        <%=quickField("text", "NotaFiscal", "Nota Fiscal", 2, session("ccNotaFiscal"), "", "", " ")%>
                        <%=quickField("multiple", "AccountAssociation", "Limitar Tipo de Pagador", 2, session("ccAccountAssociation"), "select * from cliniccentral.sys_financialaccountsassociation WHERE id NOT IN(1, 7)", "AssociationName", "")%>
                        <div class="col-md-1">
                            <label>&nbsp;</label><br />
                            <button type="button" class="btn btn-block btn-info" title="Geral Impressão" onclick="print()"><i class="fa fa-print"></i></button>
                        </div>
                        <div class="col-md-1">
                            <label>&nbsp;</label><br />
                            <button type="button" class="btn btn-block btn-success" title="Gerar Excel" onclick="downloadExcel()"><i class="fa fa-table"></i></button>
                        </div>
                    </div>
                    <%
                    set RecursosAdicionaisSQL = db.execute("SELECT RecursosAdicionais FROM sys_config WHERE id=1")

                    if not RecursosAdicionaisSQL.eof then
                        RecursosAdicionais=RecursosAdicionaisSQL("RecursosAdicionais")
                    end if
                    if CD="C" then

                        %>
                        <div class="row">
                            <%
                            if instr(RecursosAdicionais, "|NFe|") then
                            %>
                            <div class="col-md-3">
                                <label for="NotaFiscalStatus">Status da NF-e</label>
                                <select name="NotaFiscalStatus" id="NotaFiscalStatus" class="form-control">
                                    <option value="">Selecione</option>
                                    <option value="1">Emitida</option>
                                    <option value="3">Cancelada</option>
                                    <option value="0">Não emitida</option>
                                </select>
                            </div>
                            <%
                            end if
                            %>
                            <div class="col-md-2">
                                <label>Tabela</label><br>
                                <%=selectInsert("", "TabelaID", "", "TabelaParticular", "NomeTabela", "", "", "")%>
                            </div>
                        </div>
                        <Div class="row">
                            <Div class="col-md-12 mt5">
                                                                <% IF session("Banco")="clinic100000" or session("Banco")="clinic100003" or session("Banco")="clinic5459" THEN  %>
                                                                         <button type="button" class="btn btn-primary" onclick="controleDeMensalidades()">
                                                                             Controle de Mensalidades
                                                                         </button>&nbsp;
                                                                         <button type="button" class="btn btn-primary" onclick="controleDeProcessos()">
                                                                              Controle de Processos
                                                                         </button>
                                                                         <script>
                                                                        function controleDeMensalidades(){
                                                                                window.open(domain+"/billing/detailing-fixas/detailing/interface?tk="+localStorage.getItem("tk"), '_blank');
                                                                        }
                                                                        function controleDeProcessos(){
                                                                                window.open(domain+"/billing/detailing-fixas/detailing/processos?tk="+localStorage.getItem("tk"), '_blank');
                                                                        }
                                                                     </script>
                                                                 <% END  IF %>
</Div>
                        </Div>
                        <%
                    else
                            %>
                            <div class="row">
                                <div class="col-md-3 mt10">
                                    <div class="btn-group" id="acoes-contas-a-pagar" >
                                      <div class="btn-group">
                                        <button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown">
                                        Ações <span class="caret"></span></button>
                                        <ul class="dropdown-menu" role="menu">
                                          <li><a href="#" onclick="printInvoices()">Imprimir</a></li>
                                          <%
                                            if instr(RecursosAdicionais,"CNAB") then
                                          %>
                                          <li><a href="#" id="GerarArquivoRemessa" style="display:none;">Gerar arquivo de remessa</a></li>
                                          <li><a href="#" id="GerarArquivoRemessaBeta" style="display:none;">Gerar arquivo de remessa <label class="label label-primary">BETA</label> </a></li>
                                          <%
                                          end if
                                          %>
                                        </ul>
                                      </div>
                                    </div>

                                </div>
                            </div>
                            <%
                    end if
                        %>
                </div>
                <%

                if aut("|repassesV|") and aut("|contasapagarV|")=0 and req("T")="D" then
                %>
                <div class="col-md-12">
                <div class="alert alert-default mt10">
                    <strong>Atenção! </strong> Você só possui permissão para visualizar contas a pagar de repasse.
                </div>
                </div>
                <%
                end if
                %>

            </div>
            </div>
        </form>
        <form id="formExcel" method="POST">
            <input type="hidden" name="html" id="htmlTable">
        </form>

        <div class="panel">
            <div class="panel-body">
                <div id="ContasCDContent"></div>
            </div>
        </div>

    </div>
</div>
<script>
$(document).ready(function() {
    $('.categoria-single').select2();
});

function printInvoices(){
        let invoices = [];
        $(".conta-a-pagar-checkbox").each((item,key) => {
        	 if(invoices.indexOf($(key).attr("invoiceapagarid")) == -1){
        	     if($(key).prop("checked")){
                    invoices.push($(key).attr("invoiceapagarid"));
        	     }
             }
        });

        if(invoices && invoices.length > 0){
            $.post(`reciboIntegrado.asp?I=${invoices.join(",")}`, $("#formItens").serialize(), function(data, status){ $("#modal").html(data) });
        }
    }

function downloadExcel(){
    $("#htmlTable").val($("#ContasCDContent").html());
    $("#formExcel").attr("action", domain+"reports/download-excel?title=Extrato&tk=" + localStorage.getItem("tk")).submit();
}

$('#frmCD').submit(function(){
	$('#ContasCDContent').html('Carregando...');
	$.post('ContasCDContent.asp?T=<%=req("T")%>&X=<%=req("X")%>', $('#frmCD').serialize(), function(data){ $('#ContasCDContent').html(data) });
	return false;
});

<% if req("X")<>"" then %>
    $("#frmCD").submit();
<% end if %>

<% if getConfig("ListarAutomaticamenteContas") = "1" then%>
    $('#Filtrate').click();
<%
else
%>
$("#ContasCDContent").html("Clique em \"Filtrar\"");
<% end if %>

<!--#include file="financialCommomScripts.asp"-->

$("#GerarArquivoRemessa").click(function() {
    var movementIds = [];

    $.each($checkboxContasAPagar.filter(":checked"), function() {
        movementIds.push($(this).val());
    });

    openComponentsModal("financial/payment/pay-multiple-invoices", {"movementsIds[]": movementIds}, "Gerar arquivo de remessa", true, "Baixar Arquivo");
});

$("#GerarArquivoRemessaBeta").click(function() {
    var movementIds = [];

    $.each($checkboxContasAPagar.filter(":checked"), function() {
        movementIds.push($(this).val());
    });

    openComponentsModal("cnab-movements/interface", {"movements[]": movementIds}, "Gerar arquivo de remessa", false, false);
});

</script>