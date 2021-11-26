<!--#include file="connect.asp"-->
<!--#include file="modalcontrato.asp"-->
<!--#include file="modalAlertaMultiplo.asp" -->

<style type="text/css">
.duplo>tbody>tr:nth-child(4n+1)>td,
.duplo>tbody>tr:nth-child(4n+2)>td
{    background-color: #f9f9f9;
}
.duplo>tbody>tr:nth-child(4n+3)>td,
.duplo>tbody>tr:nth-child(4n+4)>td
{    background-color: #ffffff;
}

.bs-component .form-control{
    min-width: 50px !important;
}

.modal-lg{
    width:70%!important
}
#lblprocedimentos:before{
    margin-top: 15px;
    margin-left: 5px;
}
/* #invoiceItens .input-group{
    display: flex;
    justify-content: center;
    align-items: center;
} */
.infoValor{
    display: none;
    position: absolute;
    bottom: 130%;
    left: 70%;
    background-color: white;
    border: 1px solid #217dbb;
    flex-direction: column;
    padding: 10px;
    border-radius: 7px;
    width: auto;
    min-width: 100%;
    z-index: 10;
}
.infoValor:after {
    content: "";
    height: 5px;
    width: 5px;
    position: absolute;
    bottom: -11px;
    left: 17%;
    border-left: 5px solid transparent;
    border-right: 5px solid transparent;
    border-top: 5px solid #217dbb;
    border-bottom: 5px solid transparent;
}
.hover{
    display:flex!important
}
i.infoBtnValor {
    color: #217dbb;
}
.select2-dropdown--below , .select2-dropdown--above{
    min-width: 400px !important;
}
</style>

<script src="https://cdnjs.cloudflare.com/ajax/libs/vue/2.5.16/vue.min.js"></script>
<script src="assets/js/cmc7.js"></script>

<script type="text/javascript">




	function moneyString (valor){
		if(valor.indexOf(",") < 0){
			return (valor.toString())+",00"
		}else{
			return valor
		}
	}
    function addHiddenFormaId(addRemove){
        var $formaIdHidden = $(".forma-id-hidden");

        if(addRemove){
            if($formaIdHidden.length === 0){
                var FormaID = $("#FormaID").val();
                $("#FormaID").after("<input type='hidden' class='forma-id-hidden' name='FormaID' value='"+FormaID+"'/>");
            }
        }else if(!addRemove && typeof $formaIdHidden==="undefined"){
            $formaIdHidden.remove();
        }
    }

    function disable(val){

        $(".disable, #searchAccountID, input[id^='searchItemID']").prop("disabled", val);
        $(".nao-mostrar-caso-pago").css("display", val ? "none" : "");

        <%
        if aut("tabelacontapagaA")=0 then
            %>
            $("#invTabelaID").prop("disabled", val);
            <%
        end if
        %>
        addHiddenFormaId(val);
        if(val==true){
            $("#btn-abrir-modal-cancelamento").prop("disabled", false);
            $("#alert-disable").removeClass("hidden");
            $('.contratobt').attr("disabled", false)
            $('.rgrec').attr("disabled", false)
        }else{
            $("#btn-abrir-modal-cancelamento").prop("disabled", true);
            $("#alert-disable").addClass("hidden");

        }
            // $("#btn_NFe").attr("disabled", !val);
    }

</script>
<%
tableName = "sys_financialinvoices"
CD = req("T")
InvoiceID = req("I")
TabelaID = req("TabelaID")

Rateado = 0

sqlintegracao = " SELECT le.labid, lia.id, lie.StatusID FROM labs_invoices_amostras lia "&_
                                        " inner JOIN labs_invoices_exames lie ON lia.id = lie.AmostraID "&_
                                        " INNER JOIN cliniccentral.labs_exames le ON le.id = lie.LabExameID "&_
                                        " WHERE lia.InvoiceID = "&treatvalzero(InvoiceID)&" AND lia.ColetaStatusID <> 5 "
                       
set integracao = db_execute(sqlintegracao)

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
	sqlVie = "select id, sysUser, sysActive from "&tableName&" where sysUser="&session("User")&" and sysActive=0 and CD='"&CD&"' and CompanyUnitID IS NULL AND ISNULL(DataCancelamento)"
	set vie = db_execute(sqlVie)
	if vie.eof then
		db_execute("insert into "&tableName&" (sysUser, sysActive, CD, Recurrence, RecurrenceType, Value) values ("&session("User")&", 0, '"&CD&"', 1, 'm', 0)")
		set vie = db.execute(sqlVie)
	end if
    if req("PacienteID")<>"" then
        reqPacDireto = "&PacienteID="&req("PacienteID")
    end if
	response.Redirect("?P=invoice&I="&vie("id")&"&A="&req("A")&"&Pers=1&T="&CD&"&Ent="&req("Ent")& reqPacDireto)'A=AgendamentoID quando vem da agenda

else
	set data = db_execute("select * from "&tableName&" where id="&InvoiceID)
	if data.eof then
		response.Redirect("?P=invoice&I=N&Pers=1&T="&CD)
    else
        if CD<>data("CD") then
            response.Redirect("?P=invoice&I="& InvoiceID &"&Pers=1&T="&data("CD"))
        end if
	end if
end if

Retencoes = req("Retencoes")
RetencaoPFPJ = req("RetencaoPFPJ")
RetencaoSimples = req("RetencaoSimples")
if Retencoes="1" then
    PIS = 0
    COFINS = 0
    CSLL = 0
    IR = 0
    set vcaRet = db_execute("select id from itensinvoice WHERE InvoiceID="& InvoiceID &" AND CategoriaID IN(201, 212, 197, 200, 198)")
    if not vcaRet.eof then
        %>
        <script>
            alert("Remova todas as retenções antes de reaplicar");
        </script>
        <%
    else
        set pValInv = db_execute("select sum(Value) ValorTotal from sys_financialmovement where InvoiceID="& InvoiceID)
        rValorTotalInvoice = ccur(pValInv("ValorTotal"))
        if RetencaoPFPJ="PJ" then
            if RetencaoSimples<>"SIMPLES" then'NAO OPTANTE
                if rValorTotalInvoice>215.5 then
                    'reter 200 0,65 - 197 3 - 198 1
                    PIS = rValorTotalInvoice * 0.0065
                    COFINS = rValorTotalInvoice * 0.03
                    CSLL = rValorTotalInvoice * 0.01
                    db_execute("insert into itensinvoice set InvoiceID="& InvoiceID &", Tipo='O', Quantidade=1, ItemID=0, ValorUnitario=0, Executado='', CategoriaID=200, Desconto="& treatvalzero(PIS) &", Descricao='Retenção - PIS', sysUser="& session("User"))
                    db_execute("insert into itensinvoice set InvoiceID="& InvoiceID &", Tipo='O', Quantidade=1, ItemID=0, ValorUnitario=0, Executado='', CategoriaID=197, Desconto="& treatvalzero(COFINS) &", Descricao='Retenção - COFINS', sysUser="& session("User"))
                    db_execute("insert into itensinvoice set InvoiceID="& InvoiceID &", Tipo='O', Quantidade=1, ItemID=0, ValorUnitario=0, Executado='', CategoriaID=198, Desconto="& treatvalzero(CSLL) &", Descricao='Retenção - CSLL', sysUser="& session("User"))
                end if
            end if
            if rValorTotalInvoice>666.7 then
                'reter 201 1,5
                IR = rValorTotalInvoice * 0.015
                db_execute("insert into itensinvoice set InvoiceID="& InvoiceID &", Tipo='O', Quantidade=1, ItemID=0, ValorUnitario=0, Executado='', CategoriaID=201, Desconto="& treatvalzero(IR) &", Descricao='Retenção - IR', sysUser="& session("User"))
            end if
            db_execute("update sys_financialmovement set Value="& treatvalzero(rValorTotalInvoice-PIS-COFINS-CSLL-IR) &" WHERE InvoiceID="& InvoiceID)
        end if
    end if
end if

if req("Lancto")<>"" and req("Lancto")="Dir" then
%>
<script>
    $(document).ready(function () {

        setTimeout(function () {
            /*
           $.each($('select[name^=ItemID]'), function(){
               parametrosInvoice($(this).attr('data-row'), $(this).val());
           })
           */

        }, 1000);
    });
    </script>
<%
    ProfissionalSolicitante = req("ProfissionalSolicitante")
else
    ProfissionalSolicitante = data("ProfissionalSolicitante")
end if

Voucher = data("Voucher")

ContaID = data("AccountID")
AssID = data("AssociationAccountID")
nroNFe = data("nroNFe")
if scp() then
    dataNFe = data("dataNFe")
    valorNFe = data("valorNFe")
end if

if req("PacienteID")="" then
    if ContaID&""<>"" and AssID&""<>"" then
        Pagador = AssID&"_"&ContaID
    end if
else
	Pagador = "3_"&req("PacienteID")
end if

if not isnull(data("TabelaID")) then
    TabelaID = data("TabelaID")
end if

Rateado = data("Rateado")

%>

<%
posModalPagar = "fixed"
%>
<!--#include file="invoiceEstilo.asp"-->

    <form id="formItens" action="" method="post">
    <input type="hidden" id="temregradesconto" name="temregradesconto" value="0">
    <input id="Lancto" type="hidden" name="Lancto" value="<%=req("Lancto")%>">
    <input id="CentroCustoBase" type="hidden" name="CentroCustoBase" value="">
    <input id="LimitarPlanoContas" type="hidden" name="LimitarPlanoContas" value="">
    <input id="ExisteRepasse" type="hidden" name="ExisteRepasse" value="N">
    <input id="InvoiceID" type="hidden" value="<%=InvoiceID%>">
    <%=header("sys_financialinvoices", titulo, data("sysActive"), InvoiceID, 1, "Follow")%>

        <br />

    <div class="alert alert-danger text-center no-margin no-padding hidden" id="alert-disable">
        <small><i class="far fa-exclamation-circle"></i> Você não pode alterar os dados desta conta, pois existem pagamentos realizados.</small>
    </div>

    <input type="hidden" id="sysActive" name="sysActive" value="<%=data("sysActive")%>" />
    <div class="panel">
        <div class="panel-body">

<%
if not isnull(data("DataCancelamento")) then
    %>
    <div class="alert alert-danger">
        <i class="far fa-minus-circle"></i> FATURA CANCELADA EM <%= data("DataCancelamento") &" POR "& ucase(nameInTable(data("sysUserCancelamento"))&"") %>.
        <br>
        MOTIVO: <%= data("MotivoCancelamento") %>
    </div>
    <script type="text/javascript">
    $(document).ready(function(){
        $(".btn").remove();
    });
    </script>
    <%
end if
%>


        <div class="row">
        <div class="col-md-3">
            <%
            if req("Ent")="Conta" then
                %>
                <input type="hidden" name="AccountID" id="AccountID" value="<%=Pagador %>" />
            <%else %>
                <label><%=Subtitulo%></label><br />
                <%=selectInsertCA("", "AccountID", Pagador, "5, 4, 3, 2, 6, 8", " onclick=""autoPC($(this).attr(\'data-valor\')) "" ", " required", "")%>
            <%end if %>
        </div>
        <%
        if aut("|alterardatacriacaocontaA|")=0 then
            dateReadonly = " readonly "
        end if

        if data("sysActive")=0 then
            UnidadeID = session("UnidadeID")
            if not isnull(data("CompanyUnitID")) and req("Lancto")="Dir" then
                UnidadeID=data("CompanyUnitID")
            end if
			sysDate = date()

            IF getConfig("ContaComDataDeAberturaDoCaixaAberto") = "1" THEN
                set caixa = db_execute("select * from caixa where sysUser="&session("User")&" and isnull(dtFechamento)")
                IF NOT caixa.EOF THEN
                    sysDate = caixa("dtAbertura")
                END IF
            END IF
        else
            UnidadeID = data("CompanyUnitID")
			sysDate = data("sysDate")
        end if



        showColumn = ""

        'if CD="D" then showColumn = "rateio" end if
        %>

        <%
        if aut("|altunirectoA|")=0 and CD="C" then
            disabUN = " disabled "
            response.write("<input type='hidden' name='CompanyUnitID' id='UnidadeIDPagtoHidden' value='"& UnidadeID &"'>")
       end if
       %>
        <%=quickField("empresa", "CompanyUnitID", "Unidade", 2, UnidadeID, "", showColumn , onchangeParcelas& disabUN )%>

        <%
        if scp()=1  then
            call quickField("datepicker", "sysDate", "Data", 1, sysDate, "input-mask-date", "", ""&dateReadonly)
            call quickField("text", "nroNFe", "N. Fiscal", 1, nroNFe, "text-right", "", "")
            call quickField("datepicker", "dataNFe", "Data NF", 1, dataNFe, "text-right", "", "")
            call quickField("text", "valorNFe", "Valor NF", 1, fn(valorNFe), "text-right input-mask-brl", "", "")
        elseif scp()=2 then
            %>
            <div class="col-md-2">
                <button type="button" class="btn btn-block btn-default mt25" onclick="nfiscal(<%= InvoiceID %>)">N. Fiscal</button>
            </div>
            <%
        else
            call quickField("datepicker", "sysDate", "Data", 2, sysDate, "input-mask-date", "", ""&dateReadonly)
            call quickField("text", "nroNFe", "N. Fiscal", 2, nroNFe, "text-right", "", "")
        end if
        %>
        <div class="col-md-3">
            <%=quickField("memo", "Description", "", 1, data("Description"), "", "", " rows='2' placeholder='Observa&ccedil;&otilde;es...'")%>
        </div>
        </div>
        <%
        if getConfig("financeiroGuiaManual") = 1 then
            sqlRecibo = "select NumeroRPS from recibos where InvoiceID = " &InvoiceID& " AND Nome = 'Recibo GUIA MANUAL' AND sysActive = 1 limit 1"
            set recibos = db_execute(sqlRecibo)
            guiaManual = ""
            readonlyRecibo = ""
            if not recibos.eof then 
                guiaManual = recibos("NumeroRPS")
                readonlyRecibo = " readonly "
            end if
         %>
        <div class="row">
                <%=quickField("text", "guiaManual", "Guia Manual", 1, guiaManual, "text-right", "", readonlyRecibo&" ")%>
        </div>
        <% end if %>
        <%
        if session("Banco")="clinic5459" then
            if CD="C" AND Pagador&""<>"" then
                Cliente = split(Pagador, "_")
                if Cliente(0)=3 then
                    set ClienteStatus = db_execute("SELECT Status FROM cliniccentral.licencas WHERE Cliente="&Cliente(1)&" ORDER BY id LIMIT 1")
                    if not ClienteStatus.eof then
                        Status = ClienteStatus("Status")
                        if Status="C" then
                            %><span class="label bg-success">Efetivado</span><%
                        end if
                        if Status="T" then
                            %><span class="label bg-warning">Testando</span><%
                        end if
                        if Status="B" then
                            %><span class="label bg-danger">Bloqueado</span><%
                        end if
                        if Status="I" then
                            %><span class="label bg-primary">Implementação</span><%
                        end if
                    end if
                    set ClienteCPF = db_execute("SELECT CPF FROM pacientes WHERE id="&treatvalzero(Cliente(1)))
                    if not ClienteCPF.EOF then
                        %><span class="label bg-info">CPF / CNPJ: <%=ClienteCPF("CPF")%></span><%
                    end if
                end if
            end if
        end if

        %>
        <% if CD = "D" OR getConfig("RateioContasAReceber") = "1"  then
            if aut("|rateiocontaspagarV|") = 1 or aut("|rateiocontasreceberV|") = 1 then
        %>
        <div class="row">
            <div class="col-md-12 mt10">
                <%
                    btnClass = "btn-default"
                    if Rateado = 1 or Rateado = True then
                        btnClass = "btn-warning"
                    end if
                %>
                <button type="button"  class="btn <%=btnClass%> btnverrateio btn-xs">GERAR RATEIO DA CONTA</button>
            </div>
        </div>
            <% end if %>
        <% end if %>
        </div>
    </div>
    <%
    if CD="C" then
    %>
        <div class="row mb15">
            <div class="col-md-2"><br/>
            <%
            if session("Banco")="clinic5459" then
            %>
                <% sqlProcessamentoFixa = " SELECT coalesce(sum(cliniccentral.processoreceitafixa.id IS NOT NULL),0) as Quant,coalesce(max(invoicesfixas.id),0) id FROM sys_financialinvoices"&chr(13)&_
                                          "      JOIN invoicesfixas ON invoicesfixas.id = sys_financialinvoices.FixaID                                                                       "&chr(13)&_
                                          "      JOIN cliniccentral.processoreceitafixa consolidarInvoice ON consolidarInvoice.InvoiceID    = sys_financialinvoices.id                       "&chr(13)&_
                                          "                                                              AND consolidarInvoice.ClientID     = 5459                                           "&chr(13)&_
                                          "                                                              AND consolidarInvoice.TipoExecucao = ('ConsolidarInvoice')                          "&chr(13)&_
                                          "                                                              AND consolidarInvoice.Status       = 3                                              "&chr(13)&_
                                          " LEFT JOIN cliniccentral.processoreceitafixa                   ON cliniccentral.processoreceitafixa.InvoiceID = sys_financialinvoices.id          "&chr(13)&_
                                          "                                                              AND cliniccentral.processoreceitafixa.ClientID  = 5459                              "&chr(13)&_
                                          "                                                              AND cliniccentral.processoreceitafixa.TipoExecucao in('EmailConsolidacaoAVencer')   "&chr(13)&_
                                          " WHERE TRUE                                                                                                                                       "&chr(13)&_
                                          "   AND invoicesfixas.FecharAutomatico = 'N'                                                                                                       "&chr(13)&_
                                          "   AND sys_financialinvoices.id = "&InvoiceID&";                                                                                                            "
                       set sqlProcessamento = db_execute(sqlProcessamentoFixa)

                   IF NOT sqlProcessamento.EOF THEN

                       IF sqlProcessamento("Quant") = "0" AND sqlProcessamento("id") = "1" THEN
                        %>
                           <button class="btn btn-primary" type="button" onclick="prosseguirComProcesso(this)">
                               Consolidar Cobrança
                           </button>
                       <%
                       END IF
                   END IF
               END IF
                %>
            </div>

<%
if getConfig("CalculoReembolso") then

    set ProcedimentoComReembolsoSQL=db.execute("SELECT ii.id FROM itensinvoice ii INNER JOIN procedimentos proc ON proc.id=ii.ItemID WHERE proc.PermiteReembolsoConvenio='S' AND ii.InvoiceID="&treatvalzero(InvoiceID))
    if not ProcedimentoComReembolsoSQL.eof then
%>
            <div class="col-md-4">
                <br>
                <button type="button" onclick="calculaReembolso()" class="btn btn-default disable"><i class="far fa-calculator"></i> Calcular reembolso</button>
            </div>
<%
    else
    %>
    <div class="col-md-3"></div>
    <%
    end if

else
%>
<div class="col-md-3"></div>
<%
end if
             if getConfig("ObrigarTabelaParticular") then
                camposRequired=" required empty"
            else
                camposRequired=""
            end if
            %>

            <% if aut("profissionalsolicitanteA")=1 then
                    if getconfig("profissionalsolicitanteobrigatorio")=1 then
                        SolicitanteRequired = " required empty "
                    end if
                    qInputProfissionais = " SELECT CONCAT('0_',id) id, NomeEmpresa NomeProfissional, 0 ordem, '|0|' Unidades"&chr(13)&_
                        " FROM empresa UNION ALL                                                          "&chr(13)&_
                        " SELECT CONCAT('5_',id) id, NomeProfissional, 1 ordem, Unidades                  "&chr(13)&_
                        " FROM profissionais                                                              "&chr(13)&_
                        " WHERE sysActive=1 AND ativo='on' "&franquia("and (id in ( select ProfissionalID from profissionais_unidades where UnidadeID in ('"&session("UnidadeID")&"'))or nullif(Unidades, '') is null) ")& " UNION ALL "&chr(13)&_
                        " SELECT CONCAT('8_',id) id, NomeProfissional, 2 ordem, ''                        "&chr(13)&_
                        " FROM profissionalexterno                                                        "&chr(13)&_
                        " WHERE sysActive=1                                                               "&chr(13)&_
                        "                                                                                 "&chr(13)&_
                        " ORDER BY ordem, NomeProfissional                                                "



                    ' antiga
                    qInputProfissionais = "SELECT * FROM ("&qInputProfissionais&") AS t "&franquia(" WHERE COALESCE(cliniccentral.overlap(Unidades,COALESCE(NULLIF('[Unidades]',''),'-999')),TRUE)")


                    set VoucherCountSQL = db.execute("SELECT count(id)qtd from voucher WHERE sysActive=1")
                    if ccur(VoucherCountSQL("qtd"))>0 then
                        response.write (quickfield("text", "Voucher", "Voucher", 2, Voucher, "", "", " placeholder=""Digite..."""))
                    else
                        %>
                        <div class="col-md-2">&nbsp; <input type="hidden" id="Voucher" name="Voucher" value="<%=Voucher%>"></div>
                        <%
                    end if
                    response.write (quickfield("simpleSelect", "ProfissionalSolicitante", "Profissional Solicitante", 2, ProfissionalSolicitante, qInputProfissionais, "NomeProfissional", SolicitanteRequired ))

              else %>
            <div class="col-md-3 qf" id="qfprofissionalsolicitante"><label for="ProfissionalSolicitante">Profissional Solicitante</label><br>
             <input type="hidden" name="ProfissionalSolicitante" value="<%=ProfissionalSolicitante%>">
                <%
                if ProfissionalSolicitante&""<>"" and ProfissionalSolicitante&""<>"0" then
                %>
              <span> <% response.write(accountName("", ProfissionalSolicitante)) %> </span>
                <%
                end if
                %>
            </div>
            <% end if %>
            <%
                sqlTabela = "select id, NomeTabela from tabelaparticular where sysActive=1 and ativo='on' "&franquiaUnidade(" AND COALESCE(cliniccentral.overlap(Unidades,COALESCE(NULLIF('[Unidades]',''),'-999')),true) ")&" order by NomeTabela"

                set ValorPagoSQL = db_execute("SELECT ii.*, left(md5(ii.id), 7) as senha, SUM(IFNULL(ValorPago,0)) ValorPago FROM sys_financialmovement sf LEFT JOIN itensinvoice ii ON ii.InvoiceID = sf.InvoiceID WHERE sf.InvoiceID="&InvoiceID)

                if not ValorPagoSQL.eof then
                    Executado = ValorPagoSQL("Executado")
                    camposBloqueados = ""
                    if ValorPagoSQL("ValorPago")>0 and Executado = "S" then
                        camposBloqueados = "disabled"
                    end if
                end if
            %>
            <%= quickfield("simpleSelect", "invTabelaID", "Tabela / Parceria", 3, TabelaID, sqlTabela , "NomeTabela", " no-select2 mn  onchange=""tabelaChange()"" data-row='no-server' "& camposRequired&camposBloqueados) %>
            <%
            if camposBloqueados<>"" then
                %>
                <input type="hidden" name="invTabelaID" value="<%=TabelaID%>">
                <%
            end if
            %>
        </div>
        <%
    end if
     %>
    <div class="panel">
        <div class="panel-heading">
            <span class="panel-title">Itens <small>&raquo; servi&ccedil;os, produtos e outros</small></span>
            <span class="panel-controls">

                <%
                if (session("Banco")="clinic5459" or session("Banco")="clinic105") AND AssID=3 then

                    if ContaID&""<> "" then
                        set pNat = db_execute("select Naturalidade, Documento FROM pacientes WHERE id="& ContaID)
                        if not pNat.eof then
                            Nat = ucase(pNat("Naturalidade")&"")
                            CNPJ = trim(pNat("Documento")&"")
                            if CNPJ="" then
                                tipoPessoa = "PF"
                            else
                                tipoPessoa = "PJ"
                            end if
                            if tipoPessoa="PJ" then
                                %>
                                <button onclick="location.href='./?P=invoice&I=<%= InvoiceID %>&Pers=1&T=<%= CD %>&Retencoes=1&RetencaoPFPJ=<%= tipoPessoa %>&RetencaoSimples=<%= Nat %>'" type="button" class="btn btn-sm btn-alert"><i class="far fa-check-circle"></i> APLICAR RETENÇÕES - <%= Nat &" - "& tipoPessoa %></button>
                                <%
                            end if
                        end if
                    end if
                end if
                %>


                <%

                    if recursoAdicional(24)=4 then
                        set labAutenticacao = db_execute("SELECT * FROM labs_autenticacao WHERE UnidadeID="&treatvalzero(UnidadeID))
                        if not labAutenticacao.eof then

                        matrixColor = "warning"
                        sqlintegracao = " SELECT lia.id, lie.StatusID FROM labs_invoices_amostras lia "&_
                                        " inner JOIN labs_invoices_exames lie ON lia.id = lie.AmostraID "&_
                                        " WHERE lia.InvoiceID = "&treatvalzero(InvoiceID)&" AND lia.ColetaStatusID <> 5 "
                        set soliSQL = db_execute(sqlintegracao)
                        if not soliSQL.eof then
                            matrixColor = "success"
                        end if

                        set executados = db_execute("select count(*) as totalexecutados from itensinvoice where InvoiceID="&InvoiceID&" AND Executado!='S'")
                        set temintegracao = db_execute("select count(*) as temintegracao from itensinvoice ii inner join procedimentos p on ii.ItemId = p.id  where InvoiceID="&InvoiceID&" and p.IntegracaoPleres = 'S'")
                         
                         sqllaboratorios = "SELECT lab.id labID, lab.NomeLaboratorio, count(*) total "&_
                                            " FROM cliniccentral.labs AS lab "&_
                                            " INNER JOIN labs_procedimentos_laboratorios AS lpl ON (lpl.labID = lab.id) "&_
                                            " INNER JOIN procedimentos AS proc ON (proc.id  = lpl.procedimentoID) "&_
                                            " INNER JOIN itensinvoice ii ON (ii.ItemID = proc.id) "&_
                                            " WHERE proc.TipoProcedimentoID = 3 AND ii.InvoiceID ="&treatvalzero(InvoiceID)&""&_
                                            "  GROUP BY 1,2 "
                        set laboratorios = db_execute(sqllaboratorios)

                        

                        totallabs=0
                        multiploslabs = 0
                        laboratorioid = 1
                        contintegracao = 0
                        NomeLaboratorio = ""
                        informacao = ""
                        if  not laboratorios.eof then
                            while not laboratorios.eof ' recordcount estava retornando -1 então...
                                totallabs = totallabs +1
                                laboratorios.movenext
                            wend 
                            laboratorios.movefirst
                            if totallabs > 1 then
                                multiploslabs = 1
                                informacao = "<p> Os <strong>PROCEDIMENTOS</strong> desta conta estão vinculados a laboratórios diferentes. Por favor verifique a<strong> CONFIGURAÇÃO DOS PROCEDIMENTOS</strong>. <p>"
                            else 
                                laboratorioid = laboratorios("labID")
                                NomeLaboratorio = laboratorios("NomeLaboratorio")
                            end if
                        end if 

                         if not integracao.eof then 
                            laboratorioid = integracao("labid")
                            multiploslabs = 0
                            contintegracao = 1
                        end if
                    
                        if CInt(temintegracao("temintegracao")) > 0 then

                    %>
                                <script>
                                setTimeout(function() {
                                    $("#btn-abrir-modal-pleres").css("display", "none");
                                }, 1000)
                                </script>                               

                                <div class="btn-group">
                                    <% if multiploslabs = 1 then %> 
                                        <!-- <button type="button" onclick="avisoLaboratoriosMultiplos('<%=informacao%>')" class="btn btn-danger btn-xs" title="Laboratórios Multiplos">
                                            <i class="far fa-flask"></i>
                                        </button> -->
                                        <button type="button" onclick="abrirSelecaoLaboratorio('<%=InvoiceID%>','<%=CInt(temintegracao("temintegracao")) %>')" class="btn btn-danger btn-xs" title="Laboratórios Multiplos">
                                            <i class="far fa-flask"></i>
                                        </button>
                                    <% else %> 
                                        <button type="button" onclick="abrirIntegracao('<%=InvoiceID%>','<%=laboratorioid%>', '<%=CInt(temintegracao("temintegracao")) %>')" class="btn btn-<%=matrixColor%> btn-xs" id="btn-abrir-modal-matrix<%=InvoiceID%>" title="Abrir integração com Laboratório <%=NomeLaboratorio %>">
                                            <i class="far fa-flask"></i>
                                        </button>
                                    <% end if %>

                                </div>
                        <%
                            end if
                        end if
                    end if

                    if CD="C" then
                        %>
                        <span class="checkbox-custom checkbox-warning nao-mostrar-caso-pago hidden-xs">
                            <input type="checkbox" name="VariosProcedimentos" id="VariosProcedimentos" value="1">
                            <label for="VariosProcedimentos" id="lblprocedimentos" style="margin-bottom:0px">
                                Adição Rápida
                            </label>
                        </span>

                        <button type="button" onclick="marcarMultiplosExecutados()" class="btn btn-default btn-sm hidden-xs">
                            <i class="far fa-check-circle"></i> Marcar execução
                        </button>

                        <%

                        if session("Odonto")=1  then
                            %>
                        <div class="btn-group nao-mostrar-caso-pago">
                            <button type="button" class="btn btn-system btn-sm hidden-xs" id="btn-abrir-modal-odontograma">
                                <i class="far fa-tooth"></i>

                                Odontograma
                            </button>
                        </div>
                            <%
                        end if
                        %>

                        <% if  Aut("cancelamentocontareceberI") = 1 and contintegracao = 0 then %>
                        <div class="btn-group ">
                            <button type="button" class="btn btn-danger btn-sm" id="btn-abrir-modal-cancelamento">
                                <i class="far fa-times"></i> Cancelamento
                            </button>
                        </div>
                        <% end if %>

                    <% end if %>

                    <div class="btn-group hidden">
                        <button type="button" onclick="abrirMatrix('<%=InvoiceID%>')" class="btn btn-<%=corBtnPleres%> btn-sm" id="btn-abrir-modal-pleres" title="<%=titleBtnPleres%>">
                            <i class="far fa-flask"></i>
                        </button>
                    </div>
                    <% if contintegracao = 0 then %>
                    <div class="btn-group">
                        <button class="btn btn-success btn-sm dropdown-toggle disable" data-toggle="dropdown">
                        <i class="far fa-plus"></i> Adicionar Item
                        <span class="caret ml5"></span>
                        </button>
                        <ul class="dropdown-menu dropdown-success pull-right">
                      <%
                          if CD="C" then
                            descOutra = "Receita"
                          %>
                            <li>
                                <% if contintegracao = 0 then %>
                                <a href="javascript:itens('S', 'I', 0)">Consulta ou Procedimento</a>
                                <% else %>
                                <a href="javascript:avisoLaboratoriosMultiplos('Operação NÃO PERMITIDA! Exitem integrações feitas para esta conta!');">Consulta ou Procedimento</a>
                                <% end if %>
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
                        <span class="caret ml5"></span>
                        </button>
                        <ul class="dropdown-menu dropdown-success pull-right" style="overflow-y: scroll; max-height: 400px;">
                          <%
                            set pac = db_execute("select * from pacotes where "&franquia(" COALESCE(cliniccentral.overlap(Unidades,COALESCE(NULLIF('[Unidades]',''),'-999')),TRUE) AND ")&" sysActive=1 and Ativo='on' ORDER BY NomePacote")
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


                    <% end if %>
            </span>

        </div>
        <div class="panel-body pn">
            <div class="bs-component" id="invoiceItens">
                <% server.Execute("invoiceItens.asp") %>
            </div>
        </div>
   </div>

    <div class="panel">

        <div class="panel-body" id="selectPagto">
            <%server.Execute("invoiceSelectPagto.asp")%>
        </div>
        <div id="NFeContent"></div>
        <div class="panel-body pn mt10">
            <div class="bs-component" id="invoiceParcelas">
                <%server.Execute("invoiceParcelas.asp")%>
            </div>
            <input type="hidden" name="T" value="<%=req("T")%>" />
        </div>
    </div>

    <div >
        <%
        if data("sysActive")=1 then
            DescricaoGeracao = data("Name")

            if DescricaoGeracao&"" = "" then
                DescricaoGeracao="Cadastrado"
            end if

            %>
            <code>ID: #<%=data("id")%></code> <%=DescricaoGeracao%> por <%=nameInTable(data("sysUser"))%> em <%=data("DataHora")%>
            <%
        end if
        %>
        <button type='button' class='btn btn-default btn-xs ml5' title='Histórico de alterações' onClick='historicoInvoice()'><i class='far fa-history bigger-110'></i></button>
    </div>

    </form>

<%
set vcaCanc = db.execute("select l.*, pm.PaymentMethod Forma, m.Value from xmovement_log l LEFT JOIN sys_financialmovement_removidos m ON m.id=l.MovimentacaoID LEFT JOIN cliniccentral.sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID where Invoices LIKE '%|"& InvoiceID &"|%'")
if not vcaCanc.eof then
    %>
    <hr class="short alt">

    <div class="panel">
        <div class="panel-heading bg-warning">
            <span class="panel-title"><i class="far fa-ban"></i> Pagamentos cancelados desta fatura</span>
        </div>
        <div class="panel-body">
            <table class="table table-condensed">
                <thead>
                    <tr>
                        <th>Data</th>
                        <th>Usuário</th>
                        <th>Autorizador</th>
                        <th>Forma</th>
                        <th>Valor</th>
                        <th>Justificativa</th>
                        <th class="hidden">Detalhes</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    while not vcaCanc.eof
                        %>
                        <tr>
                            <td><%= vcaCanc("sysDate") %></td>
                            <td><%= nameInTable(vcaCanc("sysUser")) %></td>
                            <td><%= nameInTable(vcaCanc("AutorizadoPor")) %></td>
                            <td><%= vcaCanc("Forma") %></td>
                            <td>R$ <%= fn(vcaCanc("Value")) %></td>
                            <td><%= vcaCanc("Descricao") %></td>
                            <td class="hidden"><button class="btn btn-default btn-xs">Ver detalhes</button></td>
                        </tr>
                        <%
                    vcaCanc.movenext
                    wend
                    vcaCanc.close
                    set vcaCanc = nothing
                    %>
                </tbody>
            </table>
        </div>
    </div>
    <%
end if
%>







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


<div id="permissaoTabela" class="modal fade" role="dialog">
  <div class="modal-dialog">

    <!-- Modal content-->
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Permissão para uso de Tabela</h4>
      </div>
      <div class="modal-body">
        <div class="col-md-4">
            <p>Selecione um usuário abaixo que tenha  permissão:</p>      
              
        </div>        
            <div class="col-md-6">
                <label style="" class="error_msg"></label><br>
                <label>Senha do Usuário</label>
                <input type="hidden" id="tabela-password" name="tabela-password" class="form-control">
            </div>

        <div class="col-md-12 tabelaParticular" style="color:#000;">
        
             
        </div>
        </div>
       
        <div class="modal-footer" style="margin-top:13em;">
                <button type="button" class="btn btn-default fechar" data-dismiss="modal" >Fechar</button>
            
                <button type="button" class="btn btn-info confirmar"    >Confirmar</button>
       
         </div>

  </div>
</div>
</div>

<script type="text/javascript">


function printProcedimento(ProcedimentoID, PacienteID, ProfissionalID, DataExecucao, TipoImpresso) {

    if(TipoImpresso === "Preparos"){
        $("body").append("<iframe id='ImpressaoEtiqueta' src='listaDePreparoPorProcedimento.asp?PacienteId="+PacienteID+"&procedimento="+ProcedimentoID+"' style='display:none;'></iframe>")
        return;
    }

    $.get("printProcedimentoAgenda.asp", {
        ProcedimentoID:ProcedimentoID,
        PacienteID:PacienteID,
        ProfissionalID:ProfissionalID,
        UnidadeID:'<%=UnidadeID%>',
        Tipo: TipoImpresso,
        DataAgendamento: DataExecucao
    }, function(data) {
        eval(data);
    });
}

var $componentsModal = $("#feegow-components-modal"),
        $componentsModalTitle = $componentsModal.find('.modal-title'),
        $componentsModalBodyContent = $componentsModal.find('.modal-body-content'),
        $componentsModalFooter = $componentsModal.find('.modal-footer'),
        $componentsModalLoading = $componentsModal.find('.modal-loading'),
        defaultComponentsModalFooter = '<button type="button" class="btn btn-default" data-dismiss="modal">Fechar</button>';

var $btnMarcarTodos = $("#ExecutadoTodos");

$btnMarcarTodos.click(function() {

    var $checks = $(".checkbox-primary");
    var idsProdutos = "";
    var idsProfissionais = "";
    var $preenchido = false;

    $.each($checks, function(row, v) {
        if($(this).find("input").prop("checked") && !$preenchido){
            $preenchido = $(this).parents("tr").next("tr");
        }else if($preenchido){
            var prf = $preenchido.find(".select2-single").val();
            var date = $preenchido.find(".date-picker").val();
            var hora = $preenchido.find(".input-mask-l-time").first().val();
            var $des = $(this).parents("tr").next("tr");
            //$des.find(".select2-single").val(prf).change();
            $des.find(".select2-single").val(prf);
            $des.find(".date-picker").val(date);
            $des.find(".input-mask-l-time").first().val(hora);

            //$(this).find("input").click()
            $(this).find("input").prop("checked", true)
            var idItem = $(this).parents("tr").attr("data-id");
            idsProfissionais += prf + ",";
            idsProdutos += idItem + ",";
        }
    });
    idsProfissionais += "0";
    idsProdutos += "0";

    espProf(idsProdutos, idsProfissionais,"S");


    //$("#invoiceItens .select2-single").change();

});


function parametrosInvoice(ElementoID, id, lote,start=false){
    <%
    LanctoAgenda = ""

    if req("Lancto")="Dir" and req("I")<>"" then
        LanctoAgenda="Dir"
    end if
    %>
	$.ajax({
		type:"POST",
		url:"invoiceParametros.asp?ElementoID="+ElementoID+"&id="+id+"&LanctoAgenda=<%=LanctoAgenda%>&lote="+lote+"&start="+start,
		data:$("#formItens").serialize(),
		success:function(data){
			eval(data);
			$(".valor").val( $("#Valor").val() );
            $(".topbar-right .btn-primary").attr("disabled", false);
            
		},
        error:function(err,data){
            $(".topbar-right .btn-primary").attr("disabled", false);
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

function imprimirReciboInvoice(){
	if($("#sysActive").val()==0){
	    bootbox.alert("Para imprimir este recibo voc&ecirc; precisa salvar esta conta.", function(result) {});
	}else{
	    $.post("reciboIntegrado.asp?I=<%=InvoiceID%>", $("#formItens").serialize(), function(data, status){
	        $("#modal").html(data);
	        setTimeout(function() {
                $.get("listaRecibos.asp", {InvoiceID: <%=InvoiceID%>}, function(data) {
                    $("#modal-components").find(".modal-body").html(data);
                })
            }, 1000);
	        })
	}
}

var itensAlterados = false;

function itens(T, A, II, autoPCi, cb){
    itensAlterados=true;
	var inc = $('tr[id^="row"][data-val]:last').attr('data-val');
	var centroCustoId = $("#CentroCustoBase").val();
	var LimitarPlanoContas = $("#LimitarPlanoContas").val();
    var fornecedor = "";
    if(T=="O"){
        fornecedor = "&fornecedor="+$('#AccountID').val();
    }
	if(inc==undefined){inc=0}
	$.post("invoiceItens.asp?I=<%=InvoiceID%>&Row="+inc+fornecedor+"&autoPCi="+autoPCi, {T:T,A:A,II:II, CC: centroCustoId, LimitarPlanoContas: LimitarPlanoContas}, function(data, status){
	if(A=="I"){
		$("#footItens").before(data);
	}else if(A=="X"){
		eval(data);
	}else{
		$("#invoiceItens").html(data);
	}
    if(typeof cb === 'function'){
        setTimeout(cb, 200);
    }
});}

function formaRecto(){
    $.post("invoiceSelectPagto.asp?I=<%=req("I")%>&T=<%=req("T")%>&FormaID="+ $("#FormaID option:selected").attr("data-frid"), $("#formItens").serialize(), function(data, status){ $("#selectPagto").html(data) });
}
function planPag(I){
    $.post("invoiceParcelas.asp?PlanoPagto="+ I +"&I=<%=req("I")%>&T=<%=req("T")%>", $("#formItens").serialize(), function(data, status){ $("#invoiceParcelas").html(data) });
}

var clearInput = null;
function recalc(input, mod){
    if(mod == undefined){
        mod = 0;
    }
	var _input = $("#formItens input");
    var elemSerialized = "";
    var dadosForm =  $("#formItens").serialize();
    var Voucher = $("#Voucher").val();
    $.each(_input, function (key, val) {
        if(dadosForm.indexOf(val.name) == -1){
            elemSerialized +=  val.name + '=' + val.value + "&";
        } 
    });

    clearTimeout(clearInput);
    clearInput = setTimeout(() =>{
        $.post("recalc.asp?InvoiceID=<%=InvoiceID%>&input="+input+"&mod="+mod+"&Voucher="+Voucher, $("#formItens").serialize()+"&"+elemSerialized, function(data, status){ eval(data);  });
    },200)
}

function geraParcelas(Recalc,call = null){
     var input = $("#formItens input");
   var elemSerialized = "";
   var dadosForm =  $("#formItens").serialize();
   $.each(input, function (key, val) {
       if(dadosForm.indexOf(val.name) == -1){
           elemSerialized +=  val.name + '=' + val.value + "&";
        } 
   });

	$.post("invoiceParcelas.asp?I=<%=req("I")%>&T=<%=req("T")%>&Recalc="+Recalc, $("#formItens").serialize()+elemSerialized, function(data, status){
	    $("#invoiceParcelas").html(data);
	    call && call()
	});
}
function saveInvoiceSubmit(cb){
    
    $("#btnSave").prop("disabled", true);
	$.post("invoiceSave.asp?I=<%=InvoiceID%>&Lancto=<%=req("Lancto")%>", $("#formItens").serialize(), function(data, status){ 
            eval(data); 
            if(cb){
                cb();
            }
    }).error(function(err){
        showMessageDialog("Ocorreu um erro ao tentar salvar");

        //notifyEvent({
        //    description: "Erro ao salvar conta.",
        //    criticity: 1,
        //    moduleName: "<%=req("P")%>" 
        //});
    });
}
$("#formItens").submit(function(){
    saveInvoiceSubmit();
	return false;
});

function calcRepasse(id){
	$.post("invoiceRepasse.asp?Row="+id+"&InvoiceID=<%=InvoiceID%>", $("#formItens").serialize(), function(data){ $("#rat"+id).html(data) });
}

function deleteInvoice(){
	/*
    if(confirm('Tem certeza de que deseja excluir esta conta?')){
		location.href='./?P=ContasCD&T=<%=req("T")%>&Pers=1&X=<%=req("I")%>';
	}
    */
   $.get("faturaCancela.asp?T=<%= req("T") %>&I=<%= InvoiceID %>", function(data){
       $("#modal").html(data);
       $("#modal-table").modal("show");
    });
}

$(function() {
    $( "#pagar" ).draggable();

    // recalc()
});


if( $(".parte-paga").size()>0 ){
    if($("#invoiceParcelas").find(".liPar").find(".input-mask-brl").val()!=="0,00"){
            disable(true);
    }
    // if($("#invoiceParcelas").find(".liPar").find(".input-mask-brl"))
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
        var liberaPagamento = true;
        var total = $("#total").text();
        var valorNFe = $("#valorNFe").val();

        <%
        if session("Banco")="clinic5968" then
        %>
        liberaPagamento = true;
        if(total){
            total = total.replace("R$ ", "")
            total = total.replace(".", "")
            total = total.replace(",", ".")
            total = parseFloat(total)
        }

        if(valorNFe){
            valorNFe = valorNFe.replace("R$ ", "")
            valorNFe = valorNFe.replace(".", "")
            valorNFe = valorNFe.replace(",", ".")
            valorNFe = parseFloat(valorNFe)
        }
        <%
        end if
        %>
        var submitPagar = function(){
            $("#pagar").fadeIn(function(){
                $.post("pagar.asp?T=<%=CD%>&InvoiceID=<%=InvoiceID%>", $(".parcela").serialize(), function(data){ $("#pagar").html(data) });

            });
        };

        if ( valorNFe == total || liberaPagamento) {
            if(InvoiceAlterada) {
                $("#PendPagar").val( total );

                saveInvoiceSubmit(submitPagar);
                InvoiceAlterada = false;
            }else{
                submitPagar();
            }
            
        }else{
            $(".parcela").prop("checked", false);
            showMessageDialog("O Valor da nota deve ser o mesmo valor da conta", "warning");
        }
    }
}


function addContrato(ModeloID, InvoiceID, ContaID){
    var ProfissionalExecutante_final = ""
    //PEGA O PROFISSIONAL EXECUTANTE
    $('select[id*="ProfissionalID"]').each(function(index, value){ 
        if(index>0){
            ProfissionalExecutante_final+=","
        }
        var ProfissionalExecutante = $(value).val();
        ProfissionalExecutante_final+= ProfissionalExecutante
    });

    if($("#AccountID").val()=="" || $("#AccountID").val()=="0" || $("#AccountID").val()=="_"){
        alert("Selecione um pagador para gerar o contrato.");
        $("#searchAccountID").focus();
    }else{
        $("#modal-table").modal("show");
        $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
        $.post("addContrato.asp?ProfissionalExecutante="+ProfissionalExecutante_final+"&ModeloID="+ModeloID+"&InvoiceID="+InvoiceID+"&ContaID="+ContaID, "", function(data){
            $("#modal").html(data);
        });
    }
}
var invoiceId = '<%=InvoiceID%>';


<!--#include file="jQueryFunctions.asp"-->
<!--#include file="financialCommomScripts.asp"-->

var InvoiceAlterada = false;

        $("#selAll").on("click", function(){
            $("input[id^=Executado]").click();
            $("input[id^=Executado]").click();
            $("input[id^=Executado]").prop("checked", true);
            $("select[id^=ProfissionalID]").val("5_21");
            $("input[id^=DataExecucao]").val("02/01/2017");
        });

    if("<%=req("time")%>" != ''){
        recalc();
    }

    $("#btn-abrir-modal-cancelamento").on('click', function(){
        var accountId = $("#AccountID").val();
        if(accountId == '_'){
            alert('Você precisa selecionar um paciente!');
        }else{
            openComponentsModal("devolucao_invoice.asp", {"accountId": accountId, "InvoiceID": <%=InvoiceID%>}, "Gerar Devoluções", false, false, "md");
        }
    })

    $('#btn-abrir-modal-odontograma').on('click', function () {
        var accountId = $("#AccountID").val();
        if(accountId == '_'){
            alert('Você precisa selecionar um paciente!');
        }else{
            changeComponentsModalTitle('Odontograma');
            var fn = appendComponentsModal();
            changeComponentsModalFooter('<button type="button" class="btn btn-success" id="feegow-odontograma-finalizar">Finalizar</button>');
            $.get('<%=componentslegacyurl%>index.php/odontograma?P='+accountId+'&B=<%=ccur(replace(session("Banco"), "clinic", ""))*999 %>&O=Invoice&U=<%=session("User")%>&I=<%=InvoiceID%>&L=<%=session("Banco")%>',
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


function splitNFE() {
    $.post("splitNFe.asp?InvoiceID=<%=InvoiceID%>", "", function (data) {
        $("#modal-table").modal("show");
        $("#modal").html(data);
    });
}

function emiteNFeFornecedor(fornecedorId, nfeOrigemId, repasseId, valor) {

}

function addBoleto(invoiceId) {
    openComponentsModal("financial/add-invoice-barcode", {"invoiceId": invoiceId}, "Criar conta a partir de código de barras", true, "Adicionar");
}

function cnabBeta(invoiceId) {
    openComponentsModal("cnab-movements/interface", {"invoiceId": invoiceId})
}

function addXmlNFe(invoiceId) {
    openComponentsModal("nfe-xml", {invoiceId: invoiceId}, "Importar XML")
}

function autoPC(CA, ApenasLimitarPlanoContas) {
    if(!ApenasLimitarPlanoContas){
        ApenasLimitarPlanoContas=false;
    }
    var sCA = parseInt(CA.substring(0, 1));
    if(sCA === 2 || sCA === 5 || sCA === 4){
        $.get("invoiceAutoPC.asp?CA="+CA+"&ApenasLimitar="+ (ApenasLimitarPlanoContas), function(data){
            eval(data);
        });
    }
}
if($("#sysActive").val()==1){
    autoPC($("#AccountID").val(), true);
}

function espProf(I,profissionaisID,executeLote){
    let pacoteId = $("#PacoteID"+I).val()
    if(executeLote == "S"){
        $.post("divEspecialidadeII.asp?Change=1&R="+I+"&executeLote=S&PacoteId="+pacoteId, { ProfissionalID: profissionaisID }, function(data){ eval(data) });
    }else{
        $.post("divEspecialidadeII.asp?Change=1&R="+I, { ProfissionalID: $('#ProfissionalID'+I).val() }, function(data){ 
            $("#divEspecialidadeID"+I).html(data) 
        });
    }
}

<% if CD="C" then %>
$("#invoiceItens").on("change",".CampoDesconto", function() {
    var $descontoLinha = $(this).parents("tr");

    var Desconto = parseInt($descontoLinha.find(".CampoDesconto").val().replace(",","").replace(".",""));
    var ProcedimentoID = parseInt($descontoLinha.find("[data-resource=procedimentos]").val());
    var TipoDesconto = "V";
    var ValorUnitario = parseFloat($descontoLinha.find(".CampoValorUnitario").val().replace(",","").replace(".",""));

    if(TipoDesconto!=="P"){
        Desconto = (Desconto/ValorUnitario) * 100;
    }
    CalculaDesconto(ValorUnitario, Desconto, TipoDesconto, ProcedimentoID, "ContasAReceber", $descontoLinha.find(".CampoDesconto"));
});
<% end if %>

$("#invTabelaID").select2();

function aplicarRegra(){
    var account = $("#AccountID").val();
    var values = account.split("_");

    <%
    if session("Banco")="clinic5968" then
    %>
    if(values[0] == 3){
        //$("#nroNFe").prop("required", true);
    }else{
        //$("#nroNFe").prop("required", false);
    }
    <%
    end if
    %>
}

$(function(){

    aplicarRegra();

    $("#AccountID").on('change', function(){
        aplicarRegra();
    })

});

$(".btnverrateio").on('click', function(){
    var total = $("#total").text();
    if(total){
        total = total.replace("R$ ", "")
        total = total.replace(".", "")
        total = total.replace(",", ".")
        total = parseFloat(total)
    }
    
    if(total > 0){
        //$("#modal-rateio").modal();
        openComponentsModal("rateio_invoice.asp", { InvoiceID : '<%=InvoiceID%>' }, "Rateio", true, false); //"Adicionar");
        //atualizarValorRateio()
    }else{
        alert("Adicione itens para o rateio")
    }
});
$("#TipoValor").on('change', function(){
    var tipo = $(this).val();
    if(tipo == 0){

    }else{
        atualizarValorRateio()
    }
});


function tabelaChange(){
    this.InvoiceAlterada = true;
    $(".topbar-right .btn-primary").attr("disabled", true);
    $(".parcela").prop("disabled", true);
    var ids=''; 
    var rows=''; 
    $.each($('select[name^=ItemID]'), function(){ 
        ids += $(this).attr('data-row') + ','; 
        rows +=  $(this).val() + ','; 
    }); 
    
    ids += '0';
    rows += '0'; 

    parametrosInvoice(ids,rows,'S');
}

function prosseguirComProcesso(arg){
    $(arg).remove();
    $.get(domain + "billing/receitafixa/finalizar-processos-parciais?invoiceID=<%=InvoiceID%>&sysUser=<%=session("User")%>", function(data) {
        if(data.msg){
            new PNotify({
              title: 'Sucesso!',
              text: data.msg,
              type: 'success',
              delay: 2500
            });
            return ;
        }

        new PNotify({
          title: 'Erro.',
          text: "Não foi possível consolidar a conta.",
          type: 'success',
          delay: 2500
        });
        return ;
    });
}

function historicoInvoice() {
    openComponentsModal("LogUltimasAlteracoes.asp", {
        Tabelas: "sys_financialinvoices,itensinvoice",
        ID: "<%=InvoiceID%>",
        PaiID: "<%=InvoiceID%>",
        TipoPai: "InvoiceID",
    }, "Log de alterações", true);
}

function marcarMultiplosExecutados(){
    const proceed = function(){
        openComponentsModal("modulos/financial/MarcarMultiplosExecutados.asp", {
              invoiceId: "<%=InvoiceID%>"
          }, "Marcar múltiplas execuções", true, function(data) {
              const formData = getFormData($("#form-components"));
              let itemMultiplosExecutados = formData["item-multiplos-executados"];

              if(!formData.ExecutanteIDMultiplo){
                  return showMessageDialog("Preencha o executante", "warning");
              }
              if(!itemMultiplosExecutados){
                  return showMessageDialog("Selecione pelo menos um item", "warning");
              }

              if(typeof itemMultiplosExecutados!=="object"){
                  itemMultiplosExecutados=[itemMultiplosExecutados];
              }

              if(itemMultiplosExecutados){

                  for(let i=0;i<itemMultiplosExecutados.length;i++){
                      let itemSelecionarId = itemMultiplosExecutados[i];

                      let $itemSelecionar = $("#row"+itemSelecionarId);

                      let sel = "#ProfissionalID"+itemSelecionarId +" option[value=\""+formData.ExecutanteIDMultiplo+"\"]";

                      if($(sel).length > 0){
                          $itemSelecionar.find(".checkbox-executado").prop("checked", true);
                          $("#row2_"+itemSelecionarId).removeClass("hidden");
                          $("#ProfissionalID"+itemSelecionarId).val(formData.ExecutanteIDMultiplo ).change();
                          $("#DataExecucao"+itemSelecionarId).val(formData.DataExecucaoMultiplo );
                      }
                  }
              }

              closeComponentsModal();

          }, "md");
    };


    if(!itensAlterados){
        return proceed()
    }

    saveInvoiceSubmit(function() {
      proceed();
    })

};
</script>


<input type="hidden" name="PendPagar" id="PendPagar" />


<div class="modal fade" id="configGuia" tabindex="-1" role="dialog">
<div class="modal-dialog" role="document">
    <div class="modal-content">
    <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title">Guia de Encaminhamento</h4>
    </div>
    <form target="_blank">
        <input type="hidden" name="invoiceID"  value="<%=req("I")%>">
        <input type="hidden" name="P"  value="guiaDeEncaminhamento">
        <input type="hidden" name="Pers"  value="1">
        <div class="modal-body">
            <p>Mostrar colunas:</p>
            <p><input type="checkbox" name="valor" checked value="1"> Valor Original</p>
            <p><input type="checkbox" name="valorFinal" checked value="1"> Valor Total</p>
            <p><input type="checkbox" name="desconto" checked value="1"> Desconto</p>
            <p><input type="checkbox" name="repasse" checked value="1"> Repasse</p>
            <p><input type="checkbox" name="valorreceber" checked value="1"> Valor a Receber</p>
            <p><input type="checkbox" name="quebrarlinha" checked value="1"> Quebra em Páginas</p>

        </div>
        <div class="modal-footer">
            <button type="submit" class="btn btn-primary" >Save changes</button>
        </div>
    </form>
    </div><!-- /.modal-content -->
</div><!-- /.modal-dialog -->
</div><!-- /.modal -->
<div id='toPrint' style='display:none'></div>
<script>
    $('#configModal').click(()=>{
        $('#configGuia').modal('toggle')
    })
    function gerarImpressao(){
        let valor = ($("#valor").prop('checked')?1:0)
        let repasse = ($("#repasse").prop('checked')?1:0)

        window.open("./?P=guiaDeEncaminhamento&Pers=1&invoiceID=<%=req("I")%>&valor="+valor+"&repasse="+repasse)
        // $.get("./guiaDeEncaminhamento.asp?Pers=1&invoiceID=<%=req("I")%>&valor="+valor+"&repasse="+repasse, function (data) {
        //     // $('#toPrint').html(data)
        //     // $('#toPrint').print("#toPrint");
        // });
    }

var idStr = "#invTabelaID";
$('.modal').click(function(){
  $('#select2-invTabelaID-container').text("Selecione");
$(idStr).val(0);
 $('.error_msg').empty();
});


$(idStr).change(function(){
        var id  = $(idStr).val();
        var Nometable  = $('#select2-invTabelaID-container').text();    
        var sysUser  = "<%=session("user") %>";
        var regra  = "|tabelaParticular12V|";
        $.ajax({
        method: "POST",
        url: "TabelaAutorization.asp",
        data: {autorization:"buscartabela",id:id,sysUser:sysUser},
        success:function(result){
            if(result == "Tem regra") {
                $("#tabela-password").attr("type","password");
                $('#permissaoTabela').modal('show');
               buscarNome(id,sysUser,regra);
                }
        }
    });
        $('.confirmar').click(function(){
                var Usuario =  $('input[name="nome"]:checked').val();
                var senha   =  $('#tabela-password').val();
                liberar(Usuario , senha , id , Nometable);
                $('.error_msg').empty(); 
            
        });
    });



function  buscarNome(id,sysUser,regra){
    $.ajax({
        method: "POST",
        ContentType:"text/html",
        url: "TabelaAutorization.asp",
        data: {autorization:"pegarUsuariosQueTempermissoes",id:id,LicencaID:sysUser,regra:regra},
        success:function(result){
            res = result.split('|');     
                   $('.tabelaParticular').html(result);
            }
        });
}

function liberar(Usuario , senha , id, Nometable){
    $.ajax({
    method: "POST",
    url: "SenhaDeAdministradorValida.asp",
    data: {autorization:"liberar",id:id ,U:Usuario , S:senha},
    success:function(result){      
            if( result == "1" ){
                    $('.error_msg').text("Logado Com Sucesso!").fadeIn().css({color:"green" });;
                setTimeout(() => {
                    $('#permissaoTabela').modal('hide');
                    $(idStr).val(id);

                   $('#select2-invTabelaID-container').text(Nometable);
                }, 2000);
                }else{
                        $('.error_msg').text("Senha incorreta!").css({color:"red" }).fadeIn();
                        $('#select2-invTabelaID-container').text("Selecione");
                        $(idStr).val(0);
                }
            }
          
        });
       
}


let BloquearRecibo    =   "<%=getConfig("bloquearemissaoderecibo")%>";
let BloquearContrato  =   "<%=getConfig("bloquearemissaodecontrato")%>";
let BloquearInvoice   =   "<%=invoicePaga(req("I"))%>";

 if(BloquearContrato == 1 && BloquearInvoice == "False"){
            $('.contratobt').attr("disabled", true);
         }else{
            $('.contratobt').attr("disabled", false)
         } 



if(BloquearRecibo == 1 && BloquearInvoice == "False"){
       $('.rgrec').attr("disabled", true);
    }else{
          $('.rgrec').attr("disabled", false);
    } 


$('.contratobt').click(function(){
   if($(".contratobloqueio").hasClass("open")){
      $(".contratobloqueio").removeClass("open");
   }else{
        $(".contratobloqueio").addClass("open");
   }
});



    function saveExecutados(){
        arrayExecutados = [];
        $(".checkbox-executado:checked").each((i,item) => {
           let id                    = $(item).parents("tr").attr("data-id");
           let ProfissionalID        = $("[id=ProfissionalID"+id+"]").val();
           let ArrayData             = ProfissionalID.split("_");
           let Account               = ArrayData[1];
           let AssociationAccount    = ArrayData[0];
           let DataExecucao          = $("[id=DataExecucao"+id+"]").val();

           arrayExecutados.push({id,Account,AssociationAccount,DataExecucao})
        });

        proms = []
        arrayExecutados.forEach((item) => {
            proms.push($.post("SaveExecutadosItensInvoice.asp",item, function(data) {}));
        })

        if (proms.length > 0 ){
                Promise.all(proms).then(() => {
                         new PNotify({
                            title: 'Sucesso',
                            text: 'Item Executado com sucesso',
                            type: 'success'
                        });
                });
        }

    }

    function itensFatura(){
        $.get("itensFatura.asp?tipoTela=invoice&InvoiceID=<%= InvoiceID %>", function(data){
            $("#modal").html(data);
            $("#modal-table").modal("show");
        });
    }

    <%
if not isnull(data("DataCancelamento")) then
    %>
    $(".btn").remove();
    <%
end if
%>
$("#Voucher").change(function(){
	$.post("voucherAplica.asp?InvoiceID=<%= InvoiceID %>", $("#formItens").serialize(), function(data){
		eval(data);
	});
});

<%
if req("Div")="divHistorico" then
    %>
    $("#rbtns").fadeIn();
    <%
end if
%>


$('.deletaGuia').on('click', function(){
    var itemGuiaId = $(this).data('id');
    var linhaItem = $('.js-del-linha[id="' + itemGuiaId + '"]');

    if(confirm("Tem Certeza Que Deseja Deletar a Guia?")){
        $.post("deletaItemGuia.asp", { guiaInvoiceID: guiaInvoiceID , itemID:itemID, InvoiceID:InvoiceID}, function(data) {
            if(data){
                linhaItem.fadeOut('fast', function (){
                    $('#totalGeral').html(data);
                });
            }
        })
    };
})
</script>



<%
' LINK PARA ORDEM DE COMPRA
' Verifica se a invoice foi gerada pela Ordem de Compra
' para inserir o botão com link para a ordem de compra.
' Foi feito desta forma para não precisar alterar a estrutura da tabela de invoice.
geracao = data("Name")
if InStr(geracao, "ordem de compra") > 0 then
    set ordemDeCompra = db.execute("SELECT id FROM compras_ordem WHERE invoiceId = "&InvoiceID& " AND deletedAt IS NULL LIMIT 1")
    if not ordemDeCompra.eof then
        ordemId = ordemDeCompra("id")
%>
        <script>
        // insere o botão para ir para a Ordem de Compra
        $(document).ready(function() {
            $('#rbtns .btn-group').after(' <a class="btn btn-warning btn-sm" href="?P=solicitacoescompras&Pers=1#/ordens/edit/<%=ordemId%>" title="Ir para  ordem de compra"><i class="far fa-shopping-cart bigger-110"></i></a>');
        });
        </script>
<%
    end if
end if
%>
<!--#include file="CalculaMaximoDesconto.asp"-->

<input type="hidden" name="PendPagar" id="PendPagar" />


<%'=request.QueryString() %>
<!--#include file="disconnect.asp"-->