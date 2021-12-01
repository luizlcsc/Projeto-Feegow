<!--#include file="connect.asp"-->
<!--#include file="invoiceEstilo.asp"-->
<!--#include file="modal.asp"-->
<%
    posModalPagar = "fixed"
    if req("Data")<>"" then
        session("DateFrom") = req("Data")
        session("DateTo") = req("Data")
    end if
    if session("DateFrom")="" then
        session("DateFrom") = dateadd("m", -1, date())
    end if
    if session("DateTo")="" then
        session("DateTo") = date()
    end if
%>
<script src="extratoPaginacao.js"></script>
<style>
    #autoPaginacao{
        display: flex;
        justify-content: center;
    }
</style>
<%
    if ref("AccountID")&""<>"" then
        AccountID = ref("AccountID")
        AssociationID = left(AccountID,1)
    end if

	if req("T")<>"" then
		AccountID = req("T")
    %>
    <script>
		$(document).ready(function(e) {
            $("#Filtrate").click();
        });
    </script>
<%
	end if
%>
<form id="extratoFiltros" class="panel hidden-print">
        <div class="panel-body">
            <div class="row">
            <%
                PermiteSelecionarConta = (aut("contasareceber") and aut("contasapagar")) or aut("contaprofV")

                if AccountID<>"" then
                    PermiteSelecionarConta = False
                end if

                if not PermiteSelecionarConta and aut("proprioextratoV") and AccountID="" then
                    if lcase(session("table"))="profissionais" then
                        AccountID = "5_"& session("idInTable")
                    elseif lcase(session("table"))="funcionarios" then
                        AccountID = "2_"& session("inInTable")
                    else
                        AccountID = "5_1"
                    end if
                end if

                if PermiteSelecionarConta then
                    %>
                    <div class="col-md-4">
                        <label>Selecione a conta ou paciente</label><br>
                        <%=selectInsertCA("", "AccountID", AccountID, "5, 4, 3, 2, 8, 6, 1", "", "", "")%>
                    </div>
                    <%
                else
                    %>
                    <div class="col-md-4">
                        <br>
                        <input type="hidden" id="AccountID" name="AccountID" value="<%=AccountID%>" />
                        <%=accountName(null, AccountID)%>
                    </div>
                    <%
                end if
            %>
                <%=quickField("datepicker", "DateFrom", "De", 2, session("DateFrom"), " input-sm", "", " required")%>
                <%=quickField("datepicker", "DateTo", "At&eacute;", 2, session("DateTo"), " input-sm", "", " required")%>
                <%=quickField("users", "LancadoPor", "Lançado por", 3, "", " input-sm", "", "")%>
            </div>
            <%
            if session("Unidades")<>"|0|" then
            %>
            <div class="row">
                <%=quickField("empresaMultiIgnore", "Unidades", "Unidades", 10, "", "", "", "")%>
            </div>
            <%
	        else
            %>
            <input type="hidden" name="Unidades" value="|0|">
            <%
	        end if
            %>
            <br />
            <div class="row">
                <%=quickField("multiple", "Formas", "Filtrar Formas", 6, "", "select id, PaymentMethod from cliniccentral.sys_financialpaymentmethod", "PaymentMethod", "")%>
                <div class="col-md-5">
                    <label>Tipos de operação</label><br />
                    <span class="btn-group">
                        <label class="btn btn-default radio-custom radio-primary">
                            <input type="radio" class="ace" name="Tipo" id="opTodos" value="0" checked /><label for="opTodos"> Todos</label></label>
                        <label class="btn btn-default radio-custom radio-primary">
                            <input type="radio" class="ace" name="Tipo" id="opCreditos" value="1" /><label for="opCreditos"> Pagamentos</label></label>
                        <label class="btn btn-default radio-custom radio-primary">
                            <input type="radio" class="ace" name="Tipo" id="opDebitos" value="2" /><label for="opDebitos"> Recebimentos</label></label>
                    </span>
                </div>
                <%'=quickField("simpleCheckbox", "DetalharRecebimentos", "Detalhar recebimentos", "2", "", "", "", "")%>
            </div>
            <div class="col-md-2">
                <label>&nbsp;</label><br />
                <button class="btn btn-sm btn-primary btn-block" id="Filtrate" name="Filtrate" onclick="extratoPaginacao.filter(this)" ><i class="fa fa-search bigger-110"></i>Gerar</button>
            </div>
            <div class="col-md-2">
                <label>&nbsp;</label><br />
                <button disabled class="btn-export btn btn-sm btn-info btn-block" name="Filtrate" onclick="$('#headerExtrato h2').html( $('#searchAccountID').val() ); $('#headerExtrato h4').html( $('#DateFrom').val() + ' a ' + $('#DateTo').val() ); print()" type="button"><i class="fa fa-print bigger-110"></i> Imprimir</button>
            </div>
            <div class="col-md-2">
                <label>&nbsp;</label><br />
                <button disabled class="btn-export btn btn-sm btn-success btn-block" name="Filtrate" onclick="downloadExcel()" type="button"><i class="fa fa-table bigger-110"></i> Excel</button>
            </div>
        </div>
    </form>
<div class="panel">
    <div class="text-center visible-print" id="headerExtrato">
        <h2 mtn ptn>
            <%
            if AssociationID="3" then
                qPacienteSQL = "select NomePaciente from pacientes where id='"&AccountID&"'"
                set PacienteSQL = db.execute(qPacienteSQL)
                if not PacienteSQL.eof then
                    response.write(PacienteSQL("NomePaciente"))
                end if
                PacienteSQL.close
                set PacienteSQL = nothing
            end if
            %>
        </h2>
        <h4>01/01/2000 a 10/12/2000</h4>
    </div>
    <div id="extrato" class="panel-body">
        <center><em>Selecione acima a conta, o paciente, o funcionário ou o profissional para ver o extrato.</em></center>
    </div>
    <div id="autoPaginacao" ></div>
</div>

<div id="detalhamento" onclick="extratoPaginacao.toggleDetalhamento()">
    <div id="seta">
        <i class="fa fa-arrow-up up" aria-hidden="true"></i>
        <i class="fa fa-arrow-down down" aria-hidden="true"></i>
    </div>
    <div id="conteudoDescritivo">
    </div>
</div>

<style>
    #seta{
        position: fixed;
        top: 93%;
        left: 50%;
        background: white;
        padding: 20px;
        border-radius: 30px 30px 0 0;
        transition: 1s;
    }
    #seta i{
       transition: 1s; 
    }
    #detalhamento:hover div#seta i{
        animation: slide1 1s ease-in-out infinite;
        margin-top: 3px;
    }
    #detalhamento.aberto:hover div#seta i{
        animation: slide1 1s ease-in-out infinite;
        margin-top: 3px;
    }
    div#detalhamento {
        width: 100%;
        height: auto;
        background: white;
        position: fixed;
        top: 97%;
        transition: 1s;
        left: 0;
        z-index: 2;
        box-shadow: 1px -1px 8px 0px #a3a3a3;
    }

    .aberto{
        top:68%!important
    }

    .aberto #seta{
        top: 68%!important;
    }
    
    @keyframes slide1 {
        0%,
        100% {
            transform: translate(0, 0);
        }

        50% {
            transform: translate(0, -10px);
        }
    }
    .up{
        display:block
    }
    .down{
        display:none
    }

    .aberto .up{
        display: none
    }
    .aberto .down{
        display:block
    }
    #conteudoDescritivo{
        padding:10px 100px;
    }
    .entrada{
        color:#26DE81
    }
    .saida{
        color:#EE5253
    }
    /* Extra small devices (phones, 600px and down) */
    @media screen  and (max-height: 657px) {
        div#detalhamento{
            top: 94%;
        }
        #seta{
            top: 86%;
        }
        .aberto {
            top: 30%!important;
        }
        .aberto #seta {
            top: 22%!important;
        }
    }
    @media screen  and (max-height: 1002px) {
        div#detalhamento{
            top: 96%;
        }
        #seta{
            top: 91%;
        }
        .aberto {
            top: 55%!important;
        }
        .aberto #seta {
            top: 50%!important;
        }
    }
    @media screen  and (max-height: 1090px) {
        div#detalhamento{
            top: 96%;
        }
        #seta{
            top: 91%;
        }
        .aberto {
            top: 58%!important;
        }
        .aberto #seta {
            top: 54%!important;
        }
    }

</style>
<script>

extratoPaginacao.init({
    seletor             : 'extrato',
    seletorPaginacao    : 'autoPaginacao',
    seletorDetalhamento : 'conteudoDescritivo',
    form                : 'extratoFiltros',
    endpoint            : 'financeiro/getFinancialData'
})


function downloadExcel(){
    var tk = localStorage.getItem("tk");

    var $reportValues = $(".column-number");

    $reportValues.each((index,item)=> {
        item.innerHTML = item.getAttribute("data-value").replace(".","").replace(",",".");
    });
    
    $("#htmlTable").val($("#Extrato").html());

    $("#formExcel").attr("action", domain+"/reports/download-excel?title=Extrato&tk="+tk).submit();

    $reportValues.each((index,item)=> {
        item.innerHTML = item.getAttribute("data-formated-value");
    });
}

<!--#include file="financialCommomScripts.asp"-->
</script>