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
</style>

<script src="https://cdnjs.cloudflare.com/ajax/libs/vue/2.5.16/vue.min.js"></script>
<script src="assets/js/cmc7.js"></script>

<script type="text/javascript">
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
	sqlVie = "select id, sysUser, sysActive from "&tableName&" where sysUser="&session("User")&" and sysActive=0 and CD='"&CD&"' and CompanyUnitID IS NULL"
	set vie = db.execute(sqlVie)
	if vie.eof then
		db_execute("insert into "&tableName&" (sysUser, sysActive, CD, Recurrence, RecurrenceType, Value) values ("&session("User")&", 0, '"&CD&"', 1, 'm', 0)")
		set vie = db.execute(sqlVie)
	end if
    if req("PacienteID")<>"" then
        reqPacDireto = "&PacienteID="&req("PacienteID")
    end if
	response.Redirect("?P=invoice&I="&vie("id")&"&A="&request.QueryString("A")&"&Pers=1&T="&CD&"&Ent="&req("Ent")& reqPacDireto)'A=AgendamentoID quando vem da agenda

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

Retencoes = req("Retencoes")
RetencaoPFPJ = req("RetencaoPFPJ")
RetencaoSimples = req("RetencaoSimples")
if Retencoes="1" then
    PIS = 0
    COFINS = 0
    CSLL = 0
    IR = 0
    set vcaRet = db.execute("select id from itensinvoice WHERE InvoiceID="& InvoiceID &" AND CategoriaID IN(201, 212, 197, 200, 198)")
    if not vcaRet.eof then
        %>
        <script>
            alert("Remova todas as retenções antes de reaplicar");
        </script>
        <%
    else
        set pValInv = db.execute("select sum(Value) ValorTotal from sys_financialmovement where InvoiceID="& InvoiceID)
        rValorTotalInvoice = ccur(pValInv("ValorTotal"))
        if RetencaoPFPJ="PJ" then
            if RetencaoSimples<>"SIMPLES" then'NAO OPTANTE
                if rValorTotalInvoice>215.5 then
                    'reter 200 0,65 - 197 3 - 198 1
                    PIS = rValorTotalInvoice * 0.0065
                    COFINS = rValorTotalInvoice * 0.03
                    CSLL = rValorTotalInvoice * 0.01
                    db.execute("insert into itensinvoice set InvoiceID="& InvoiceID &", Tipo='O', Quantidade=1, ItemID=0, ValorUnitario=0, Executado='', CategoriaID=200, Desconto="& treatvalzero(PIS) &", Descricao='Retenção - PIS', sysUser="& session("User"))
                    db.execute("insert into itensinvoice set InvoiceID="& InvoiceID &", Tipo='O', Quantidade=1, ItemID=0, ValorUnitario=0, Executado='', CategoriaID=197, Desconto="& treatvalzero(COFINS) &", Descricao='Retenção - COFINS', sysUser="& session("User"))
                    db.execute("insert into itensinvoice set InvoiceID="& InvoiceID &", Tipo='O', Quantidade=1, ItemID=0, ValorUnitario=0, Executado='', CategoriaID=198, Desconto="& treatvalzero(CSLL) &", Descricao='Retenção - CSLL', sysUser="& session("User"))
                end if
            end if
            if rValorTotalInvoice>666.7 then
                'reter 201 1,5
                IR = rValorTotalInvoice * 0.015
                db.execute("insert into itensinvoice set InvoiceID="& InvoiceID &", Tipo='O', Quantidade=1, ItemID=0, ValorUnitario=0, Executado='', CategoriaID=201, Desconto="& treatvalzero(IR) &", Descricao='Retenção - IR', sysUser="& session("User"))
            end if
            db.execute("update sys_financialmovement set Value="& treatvalzero(rValorTotalInvoice-PIS-COFINS-CSLL-IR) &" WHERE InvoiceID="& InvoiceID)
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
        <small><i class="fa fa-exclamation-circle"></i> Você não pode alterar os dados desta conta, pois existem pagamentos realizados.</small>
    </div>

    <input type="hidden" id="sysActive" name="sysActive" value="<%=data("sysActive")%>" />
    <div class="panel">
        <div class="panel-body">
        <div class="row">
        <div class="col-md-3">
            <%
            if req("Ent")="Conta" then
                %>
                <input type="hidden" name="AccountID" id="AccountID" value="<%=Pagador %>" />
            <%else %>
                <label><%=Subtitulo%></label><br />
                <%=selectInsertCA("", "AccountID", Pagador, "5, 4, 3, 2, 6", " onclick=""autoPC($(this).attr(\'data-valor\')) "" ", " required", "")%>
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

        <%=quickField("empresa", "CompanyUnitID", "Unidade", 2, UnidadeID, "", showColumn , onchangeParcelas& disabUN)%>

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
            set recibos = db.execute(sqlRecibo)
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
        
        <% if CD = "D" then 
            if aut("|rateiocontaspagarV|") = 1 then 
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
        <div class="panel-body mb15">
            <div class="col-md-2 pt10">
                <span class="checkbox-custom checkbox-warning">
                    <input type="checkbox" name="AExecutadoTodos" id="ExecutadoTodos" value="S">
                    <label for="ExecutadoTodos">
                        Marcar todos como executados
                    </label>
                </span>
            </div>
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
                       set sqlProcessamento = db.execute(sqlProcessamentoFixa)

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


            <div class="col-md-2">
<%
if getConfig("CalculoReembolso") then
%>
                <br>
                <button type="button" onclick="calculaReembolso()" class="btn btn-default disable">Calcular reembolso</button>
<%
end if
%>&nbsp;
            </div>

            <%
             if session("Banco")="clinic6118" then
                camposRequired=" required empty"
            else
                camposRequired=""
            end if
            %>
            
            <% if aut("profissionalsolicitanteA")=1 then
                    if getconfig("profissionalsolicitanteobrigatorio")=1 then
                        SolicitanteRequired = " required empty "
                    end if
                    response.write (quickfield("simpleSelect", "ProfissionalSolicitante", "Profissional Solicitante", 3, ProfissionalSolicitante, "select concat('0_',id) id, NomeEmpresa NomeProfissional, 0 ordem from empresa union all select concat('5_',id) id, NomeProfissional, 1 ordem from profissionais where sysActive=1 and ativo='on' union all select concat('8_',id) id, NomeProfissional, 2 ordem from profissionalexterno where sysActive=1 order by ordem, NomeProfissional", "NomeProfissional", SolicitanteRequired ))

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
            <%= quickfield("simpleSelect", "invTabelaID", "Tabela", 3, TabelaID, "select id, NomeTabela from tabelaparticular where sysActive=1 and ativo='on' order by NomeTabela", "NomeTabela", " no-select2 mn  onchange=""tabelaChange()"" data-row='no-server' "& camposRequired) %>
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

                    if ContaID&"" then
                        set pNat = db.execute("select Naturalidade, Documento FROM pacientes WHERE id="& ContaID)
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
                                <button onclick="location.href='./?P=invoice&I=<%= InvoiceID %>&Pers=1&T=<%= CD %>&Retencoes=1&RetencaoPFPJ=<%= tipoPessoa %>&RetencaoSimples=<%= Nat %>'" type="button" class="btn btn-sm btn-alert">APLICAR RETENÇÕES - <%= Nat &" - "& tipoPessoa %></button>
                                <%
                            end if
                        end if
                    end if
                end if
                %>

                <span class="checkbox-custom checkbox-warning">
                    <input type="checkbox" name="VariosProcedimentos" id="VariosProcedimentos" value="1">
                    <label for="VariosProcedimentos" id="lblprocedimentos">
                        Adição Rápida
                    </label>
                </span>

                <%

                    if recursoAdicional(24)=4 then
                        set labAutenticacao = db.execute("SELECT * FROM labs_autenticacao WHERE UnidadeID="&treatvalzero(UnidadeID))
                        if not labAutenticacao.eof then

                        matrixColor = "warning"
                        set soliSQL = db.execute("SELECT * FROM labs_solicitacoes WHERE InvoiceID="&treatvalzero(InvoiceID))
                        if not soliSQL.eof then
                            matrixColor = "success"
                        end if

                        set executados = db.execute("select count(*) as totalexecutados from itensinvoice where InvoiceID="&InvoiceID&" AND Executado!='S'")
                        set temintegracao = db.execute("select count(*) as temintegracao from itensinvoice ii inner join procedimentos p on ii.ItemId = p.id  where InvoiceID="&InvoiceID&" and p.IntegracaoPleres = 'S'")
                         
                         ' para abrir integração com DB quando hoverem apenas procedimetos direcionados para DB
                        sql = "SELECT pl.labID, l.NomeLaboratorio FROM itensinvoice AS ii " &_
                              "INNER JOIN procedimentos AS pro ON (pro.id = ii.itemid) " &_
                              "INNER JOIN labs_procedimentos_laboratorios AS pl ON (pl.procedimentoID = pro.id) " &_
                              "INNER JOIN cliniccentral.labs AS l ON (l.id  = pl.labID) " &_
                              "WHERE invoiceid = "& treatvalzero(InvoiceID) &" ORDER BY 1 LIMIT 1 "
                        set procedimentos  = db.execute(sql)
                        laboratorioproc  = 1
                        nomelaboratorioproc = ""
                        if  not procedimentos.eof then
                             laboratorioproc  = procedimentos("labID")
                             nomelaboratorioproc = procedimentos("NomeLaboratorio")
                        end if 
                        '  -----------------------------------------------------------------------------------------
                        
                        set laboratorios = db.execute("SELECT * FROM cliniccentral.labs AS lab INNER JOIN labs_procedimentos_laboratorios AS lpl ON (lpl.labID = lab.id) WHERE lpl.procedimentoID ="& treatvalzero(ProcedimentoID) )
                    
                        laboratorioid = 1
                        NomeLaboratorio = ""
                        if  not laboratorios.eof then
                            laboratorioid = laboratorios("labID")
                            NomeLaboratorio = laboratorios("NomeLaboratorio")
                        end if 

                        if CInt(temintegracao("temintegracao")) > 0 then

                    %>
                                <script>
                                setTimeout(function() {
                                    $("#btn-abrir-modal-pleres").css("display", "none");
                                }, 1000)
                                </script>
                               <!-- <div class="btn-group">
                                    <button type="button" onclick="abrirMatrix('<%=InvoiceID%>')" class="btn btn-<%=matrixColor%> btn-sm" id="btn-abrir-modal-matrix" title="Abrir integração de laboratórios">
                                        <i class="fa fa-flask"></i>
                                    </button>
                                </div> -->

                                <div class="btn-group">
                                    <% if laboratorioproc = "1" then %>
                                        <button type="button" onclick="abrirMatrix('<%=InvoiceID%>')" class="btn btn-<%=matrixColor%> btn-xs" id="btn-abrir-modal-matrix" title="Abrir integração com <%=nomelaboratorioproc %>">
                                            <i class="fa fa-flask"></i>
                                        </button>
                                    <% else %>
                                        <button type="button" onclick="abrirDiagBrasil('<%=InvoiceID%>','<%=laboratorioproc %>')" class="btn btn-<%=matrixColor%> btn-xs" id="btn-abrir-modal-matrix" title="Abrir integração com <%=nomelaboratorioproc %>">
                                            <i class="fa fa-flask"></i>
                                        </button>    
                                    <% end if %>
                                </div>

                        <%
                            end if
                        end if
                    end if

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

                        <% if CD="C" and Aut("cancelamentocontareceberI") = 1 then %>
                        <div class="btn-group ">
                            <button type="button" class="btn btn-danger btn-sm" id="btn-abrir-modal-cancelamento">
                                Cancelamento
                            </button>
                        </div>
                        <% end if %>

                    <div class="btn-group hidden">
                        <button type="button" onclick="abrirMatrix('<%=InvoiceID%>')" class="btn btn-<%=corBtnPleres%> btn-sm" id="btn-abrir-modal-pleres" title="<%=titleBtnPleres%>">
                            <i class="fa fa-flask"></i>
                        </button>
                    </div>
                    <div class="btn-group">
                        <button class="btn btn-success btn-sm dropdown-toggle disable" data-toggle="dropdown">
                        <i class="fa fa-plus"></i> Adicionar Item
                        <span class="fa fa-caret-down icon-on-right"></span>
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
                        <i class="fa fa-plus"></i> Adicionar Pacote
                        <span class="fa fa-caret-down icon-on-right"></span>
                        </button>
                        <ul class="dropdown-menu dropdown-success pull-right" style="overflow-y: scroll; max-height: 400px;">
                          <%
                            set pac = db.execute("select * from pacotes where sysActive=1 and Ativo='on' ORDER BY NomePacote")
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
                <i class="fa fa-circle-o-notch fa-spin fa-fw"></i>
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
//    console.log("c")

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


function parametrosInvoice(ElementoID, id, lote){
    <%
    LanctoAgenda = ""

    if req("Lancto")="Dir" and req("I")<>"" then
        LanctoAgenda="Dir"
    end if
    %>
	$.ajax({
		type:"POST",
		url:"invoiceParametros.asp?ElementoID="+ElementoID+"&id="+id+"&LanctoAgenda=<%=LanctoAgenda%>&lote="+lote,
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

function imprimir(){
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


function itens(T, A, II, autoPCi, cb){
	var inc = $('[data-val]:last').attr('data-val');
	var centroCustoId = $("#CentroCustoBase").val();
	var LimitarPlanoContas = $("#LimitarPlanoContas").val();

	if(inc==undefined){inc=0}
	$.post("invoiceItens.asp?I=<%=InvoiceID%>&Row="+inc+"&autoPCi="+autoPCi, {T:T,A:A,II:II, CC: centroCustoId, LimitarPlanoContas: LimitarPlanoContas}, function(data, status){
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

    console.log("invoiceSelectPagto.asp?I=<%=req("I")%>&T=<%=req("T")%>&FormaID=");
    $.post("invoiceSelectPagto.asp?I=<%=req("I")%>&T=<%=req("T")%>&FormaID="+ $("#FormaID option:selected").attr("data-frid"), $("#formItens").serialize(), function(data, status){ $("#selectPagto").html(data) });
}
function planPag(I){
    $.post("invoiceParcelas.asp?PlanoPagto="+ I +"&I=<%=req("I")%>&T=<%=req("T")%>", $("#formItens").serialize(), function(data, status){ $("#invoiceParcelas").html(data) });
}

function recalc(input, mod){
    if(mod == undefined){
        mod = 0;
    }
	var input = $("#formItens input");
    var elemSerialized = "";
    var dadosForm =  $("#formItens").serialize();
    $.each(input, function (key, val) {
        if(dadosForm.indexOf(val.name) == -1){
            elemSerialized +=  val.name + '=' + val.value + "&";
        } 
    });

	$.post("recalc.asp?InvoiceID=<%=InvoiceID%>&input="+input+"&mod="+mod, $("#formItens").serialize()+"&"+elemSerialized, function(data, status){ eval(data);  });
}

function geraParcelas(Recalc){
     var input = $("#formItens input");
   var elemSerialized = "";
   var dadosForm =  $("#formItens").serialize();
   $.each(input, function (key, val) {
       if(dadosForm.indexOf(val.name) == -1){
           elemSerialized +=  val.name + '=' + val.value + "&";
        } 
   });

	$.post("invoiceParcelas.asp?I=<%=req("I")%>&T=<%=req("T")%>&Recalc="+Recalc, $("#formItens").serialize()+elemSerialized, function(data, status){ $("#invoiceParcelas").html(data) });
}
function saveInvoiceSubmit(cb){
    
    $("#btnSave").prop("disabled", true);
	$.post("invoiceSave.asp?I=<%=InvoiceID%>&Lancto=<%=req("Lancto")%>", $("#formItens").serialize(), function(data, status){ 
            eval(data); 
            if(cb){
                cb();
            }
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
	if(confirm('Tem certeza de que deseja excluir esta conta?')){
		location.href='./?P=ContasCD&T=<%=req("T")%>&Pers=1&X=<%=req("I")%>';
	}
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
    if($("#AccountID").val()=="" || $("#AccountID").val()=="0" || $("#AccountID").val()=="_"){
        alert("Selecione um pagador para gerar o contrato.");
        $("#searchAccountID").focus();
    }else{
        $("#modal-table").modal("show");
        $("#modal").html("Carregando...");
        $.post("addContrato.asp?ModeloID="+ModeloID+"&InvoiceID="+InvoiceID+"&ContaID="+ContaID, "", function(data){
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

    if("<%=request.QueryString("time")%>" != ''){
    console.log('recalc...');
        recalc();
    }

    $("#btn-abrir-modal-cancelamento").on('click', function(){
        var accountId = $("#AccountID").val();
        if(accountId == '_'){
            alert('Você precisa selecionar um paciente!');
        }else{
            openComponentsModal("devolucao_invoice.asp", {"accountId": accountId, "InvoiceID": <%=InvoiceID%>}, "Gerar Devoluções", false, "");
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

            $.get('../feegow_components/odontograma?P='+accountId+'&B=<%=ccur(replace(session("Banco"), "clinic", ""))*999 %>&O=Invoice&U=<%=session("User")%>&I=<%=InvoiceID%>',
            function (data) {
                fn(data);
            });
        }
    });
    <% if req("Scan")="1" then %>
    $(document).ready(function(){
        $(".modal-content").html("Carregando...");
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
    $("#modal").html("Carregando...");
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
    if(executeLote == "S"){
        $.post("divEspecialidadeII.asp?Change=1&R="+I+"&executeLote=S", { ProfissionalID: profissionaisID }, function(data){ eval(data) });
    }else{
        $.post("divEspecialidadeII.asp?Change=1&R="+I, { ProfissionalID: $('#ProfissionalID'+I).val() }, function(data){ $("#divEspecialidadeID"+I).html(data) });
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

</script>

<!--#include file="CalculaMaximoDesconto.asp"-->

<input type="hidden" name="PendPagar" id="PendPagar" />

<%'=request.QueryString() %>
<!--#include file="disconnect.asp"-->