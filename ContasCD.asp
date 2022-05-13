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

    set regraspermissoes = db.execute("SELECT REPLACE(limitarcontaspagar, '|', '') AS limitarcontaspagar, IF( Permissoes like '%[%', SUBSTRING_INDEX(SUBSTRING_INDEX(Permissoes, '[', -1), ']', 1), '') RegraUsuario FROM sys_users WHERE id ="&idUser)
    queryTotal = " SELECT * from sys_financialexpensetype WHERE 1=1 "

    if not regraspermissoes.eof THEN
        limitarContasPagarValores = regraspermissoes("limitarcontaspagar")
        RegraUsuario = regraspermissoes("RegraUsuario")
        set limitarCategoria = db.execute("SELECT limitarcontaspagar FROM regraspermissoes WHERE id = "&treatvalzero(RegraUsuario))
        if not limitarCategoria.eof then
            limitarContasPagarValores = limitarCategoria("limitarcontaspagar")
        end if

        IF limitarContasPagarValores <> "" then
            limitarContasPagarValores = replace(limitarContasPagarValores, "|","")
            queryTotal = " "&queryTotal&" and id not in("&limitarContasPagarValores&")"
        END IF
    end if

    queryTotal = queryTotal&" ORDER BY Name"
    set categoriaContasAPagar = db.execute(queryTotal)

end if


' configura os valores default dos filtros vindos da sessão
De = req("De")
if De="" then
    De = session("ccDe")
end if

Ate = req("Ate")
if Ate="" then
    Ate = session("ccAte")
end if

Pagto = req("Pagto")
if Pagto="" then
    Pagto = session("ccPagto")
end if

CategoriaID = req("CategoriaID")
if CategoriaID="" then
    if CD = "C" then
        CategoriaID = session("ccCategoriaID_C")
    else
        CategoriaID = session("ccCategoriaID_D")
    end if
end if

UnidadeSelecionada = req("U")
if UnidadeSelecionada = "" then
    UnidadeSelecionada = session("ccCompanyUnitID")
end if
if UnidadeSelecionada = "" then
    UnidadeSelecionada = session("ccUnidades")
end if
if UnidadeSelecionada="" then
	UnidadeSelecionada = session("Unidades")
end if

AccountID = req("AccountID")
if AccountID = "" then
    AccountID = session("ccAccountID")
end if

NotaFiscal = req("NotaFiscal")
if NotaFiscal = "" then
    NotaFiscal = session("ccNotaFiscal")
end if

AccountAssociation = req("AccountAssociation")
if AccountAssociation = "" then
    AccountAssociation = session("ccAccountAssociation")
end if

TabelaID = req("TabelaID")
if TabelaID = "" then
    TabelaID = session("ccTabelaID")
end if

NotaFiscalStatus = req("NotaFiscalStatus")
if NotaFiscalStatus = "" then
    NotaFiscalStatus = session("ccNotaFiscalStatus")
end if

' período default caso não tenha nenhuma data no request ou na sessão
if De="" or Ate="" then
	De = cdate("1/"&month(date())&"/"&year(date()))
	Ate = dateadd("m", 1, De)
	Ate = dateadd("d", -1, Ate)

	set NumeroContasSQL = db.execute("SELECT COUNT(id)>500 MuitasContas FROM sys_financialinvoices WHERE MONTH(sysDate) = MONTH(CURDATE()) AND CD='"&CD&"'")

	if not NumeroContasSQL.eof then
	    if NumeroContasSQL("MuitasContas") then
            De = date()
            Ate = De
        end if
	end if
end if
%>

<script type="text/javascript">
    $(document).ready(function(){
        $(".crumb-active a").html("<%=Titulo%>");
        $(".crumb-icon a span").attr("class", "far fa-<%=icone%>");
    });
</script>


<div class="row">
    <div class="col-xs-12">

        <form id="frmCD">
            <div class="panel mt10 hidden-print">
            <input type="hidden" name="MotivoCancelamento" value="<%=ref("MotivoCancelamento")%>">
            <div class="panel-body">
                <div class="col-sm-12">
                    <div class="row">
                        <%=quickField("datepicker", "De", "De", 2, De, "", "", " required")%>
                        <%=quickField("datepicker", "Ate", "At&eacute;", 2, Ate, "", "", " required")%>
                        <div class="col-xs-2">
                            <label>Exibir</label><br />
                            <select class="form-control" id="Pagto" name="Pagto">
                                <option value="">Todas</option>
                                <option value="Q" <% If Pagto = "Q" Then %> selected="selected" <% End If %>>Quitadas</option>
                                <option value="N" <% If Pagto = "N" Then %> selected="selected" <% End If %>>N&atilde;o quitadas</option>
                            </select>
                        </div>
                        <%=quickField("empresaMulti", "CompanyUnitID", "Unidades", 2, session("Unidades"), "", "", "")%>
                        <% if UnidadeSelecionada <> "" then%>
                            <script type="text/javascript">
                                // a seleção de unidades default é feita por JS pq há um comportamento inesperado no default do quickField
                                let values = '<%=UnidadeSelecionada%>';
                                $("#CompanyUnitID option").prop("selected", false);
                                $.each(values.split(","), function(i,e) {
                                    $("#CompanyUnitID option[value='" + e.trim() + "']").prop("selected", true);
                                });
                            </script>
                        <% end if
                        if CD="C" then
                        %>
                        <div class="col-md-2">
                            <label>Tabela</label><br>
                            <%=selectInsert("", "TabelaID", TabelaID, "TabelaParticular", "NomeTabela", "", "", "")%>
                        </div>
                        <%
                        end if
                        %>
                        <div class="col-md-2 pull-right">
                            <label>&nbsp;</label><br />
                            <button class="btn btn-primary btn-block" id="Filtrate" name="Filtrate"><i class="far fa-search bigger-110"></i> Filtrar</button>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-3">
                            <label><%=tituloConta%></label><br />
                            <%=selectInsertCA("", "AccountID", AccountID, "5, 4, 3, 2, 6, 1, 8", "", "", "")%>
                        </div>
                        <div class="col-md-3">
                            <label>Categoria</label><br>

                            <% if req("T")="C" then
                                response.write(selectInsert("", "CategoriaID", CategoriaID, TabelaCategoria, "Name", "", "", ""))
                                else %>

                                <select name="CategoriaID" class="categoria-single">
                                    <option value="">Selecione um item</option>
                                    <% while not categoriaContasAPagar.eof  %>
                                        <option value="<%=categoriaContasAPagar("id")%>" <% If CategoriaID = categoriaContasAPagar("id")&"" Then %> selected="selected" <% End If %>><%=categoriaContasAPagar("Name")%></option>
                                    <%
                                    categoriaContasAPagar.movenext
                                    wend
                                    categoriaContasAPagar.close
                                    set categoriaContasAPagar=nothing
                                    %>
                                </select>
                            <% end if %>

                        </div>

                        <%=quickField("text", "NotaFiscal", "Nota Fiscal", 2, NotaFiscal, "", "", " ")%>
                        <%=quickField("multiple", "AccountAssociation", "Limitar Tipo de Pagador", 2, AccountAssociation, "select * from cliniccentral.sys_financialaccountsassociation WHERE id NOT IN(1, 7)", "AssociationName", "")%>

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
                                    <option value="1" <% If NotaFiscalStatus = "1" Then %> selected="selected" <% End If %>>Emitida</option>
                                    <option value="3" <% If NotaFiscalStatus = "3" Then %> selected="selected" <% End If %>>Cancelada</option>
                                    <option value="0" <% If NotaFiscalStatus = "0" Then %> selected="selected" <% End If %>>Não emitida</option>
                                </select>
                            </div>
                            <%
                            end if
                            %>

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
                                            if instr(RecursosAdicionais,"CNAB") or recursoAdicional(28)=4 then
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

            <div class="panel-heading">
                <span class="panel-title">Contas</span>
                <span class="panel-controls">
                    <button type="button" class="btn btn-sm btn-default" title="Geral Impressão" onclick="print()"><i class="far fa-print"></i></button>
                    <button type="button" class="btn btn-sm btn-success" title="Gerar Excel" onclick="downloadExcel()"><i class="far fa-table"></i></button>
                </span>
            </div>
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

var RemoveContaID = '<%=req("X")%>';
$('#frmCD').submit(function(){
	$('#ContasCDContent').html('Carregando...');
	$.post('ContasCDContent.asp?T=<%=req("T")%>&X='+RemoveContaID, $('#frmCD').serialize(), function(data){ $('#ContasCDContent').html(data) });
	RemoveContaID="";
	return false;
});

<% if req("X")<>"" then %>
    $("#frmCD").submit();
<% end if %>

<% if getConfig("ListarAutomaticamenteContas") = "1" or req("Buscar")="1" then%>
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