<!--#include file="connect.asp"-->
<script type="text/javascript">
    function formaRecto(M, C, B, P, U, Inv){
        $.post("itensFatura.asp?FormaRecto=S&InvoiceID="+ Inv, {
            M:M,
            C:C,
            B:B,
            P:P,
            U:U
        }, function(data){
            $("#divRecto").html(data);
        });
    }
    
    function invoiceFuncoes(fcn, tipoTela, InvoiceID, Div){
        $.get("invoiceFuncoes.asp?fcn="+ fcn +"&tipoTela="+ tipoTela +"&InvoiceID="+ InvoiceID, function(data){
            $('#'+ Div).html(data);
        });
    }
</script>    
<%
tipoTela = req("tipoTela")
InvoiceID = req("InvoiceID")

db.execute("delete iit, iitv from cliniccentral.itensinvoice_temp iit LEFT JOIN cliniccentral.itensinvoicevar_temp iitv ON iitv.iiTempID=iit.id WHERE (iit.sysUser="& session("User") &" AND iit.tipoTela='"& tipoTela &"') OR date(sysDate)<CURDATE()")

if tipoTela="checkin" then

    n = 0
    splAg = split(ref("AgendamentoID"), "|")

    for i=0 to ubound(splAg)
        n = n+1
        if instr(splAg(i), "_")>0 then
            splAg2 = split(splAg(i), "_")
            AgID = splAg2(0)
            AgPID = splAg2(1)
            if AgPID="" then
                sqlAg = "SELECT IFNULL(l.UnidadeID,0) UnidadeID, a.PacienteID, a.TabelaParticularID, a.TipoCompromissoID ProcedimentoID, a.ProfissionalID, a.EspecialidadeID, proc.NomeProcedimento FROM agendamentos a LEFT JOIN locais l ON l.id=a.LocalID LEFT JOIN procedimentos proc ON proc.id=a.TipoCompromissoID WHERE a.id="& AgID
            else
                sqlAg = "SELECT IFNULL(l.UnidadeID,0) UnidadeID, a.PacienteID, a.TabelaParticularID, ap.TipoCompromissoID ProcedimentoID, a.ProfissionalID, a.EspecialidadeID, proc.NomeProcedimento FROM agendamentos a LEFT JOIN agendamentosprocedimentos ap ON a.id=ap.AgendamentoID LEFT JOIN locais l ON l.id=ap.LocalID LEFT JOIN procedimentos proc ON proc.id=ap.TipoCompromissoID WHERE ap.id="& AgPID
            end if
            'response.write( sqlAg &"<br>")
            set ag = db.execute( sqlAg )
            if not ag.eof then
                EspecialidadeID = ag("EspecialidadeID")
                PacienteID = ag("PacienteID") 'Sempre será só um na tela de recto checkin
                ProcedimentoID = ag("ProcedimentoID")
                ProfissionalID = ag("ProfissionalID") 'Sempre será só um na tela de recto checkin
                TabelaID = ag("TabelaParticularID") 'Sempre será só uma na tela de recto checkin
                UnidadeID = ag("UnidadeID") 'Sempre será só uma na tela de recto checkin
                NomeProcedimento = ag("NomeProcedimento")

                ValorCru = calcValorProcedimento(ProcedimentoID, TabelaID, UnidadeID, ProfissionalID, EspecialidadeID, "", 0)

                db.execute("insert into cliniccentral.itensinvoice_temp set sysUser="& session("User") &", ItemInvoiceID=0, InvoiceID="& InvoiceID &", tipoTela='"& tipoTela &"', Tipo='S', ItemID="& ProcedimentoID &", Quantidade=1, ValorUnitario="& treatvalzero(ValorCru) &"")

            end if
        end if
    next

    


    'pega o concat do itens (procedimentos) do checkin pra comparar se tem invoice nao paga pra usar ou criar uma
    set pItensCheckin = db.execute("select group_concat(ItemID ORDER BY ItemID) itensCheckin from cliniccentral.itensinvoice_temp WHERE tipoTela='checkin' AND sysUser="& session("User"))
    itensCheckin = pItensCheckin("itensCheckin")&""

    'verifica se tem invoice não paga e (não executada ou executada por este profissional) cujos itens sejam identicos ao do checkin
    set inv = db.execute("SELECT i.id, group_CONCAT(ii.ItemID ORDER BY ii.ItemID) itens, ifnull(COUNT(idesc.id),0) descontados FROM sys_financialinvoices i LEFT JOIN itensinvoice ii ON ii.InvoiceID=i.id LEFT JOIN itensdescontados idesc ON idesc.ItemID=ii.id WHERE i.cd='C' AND i.AssociationAccountID=3 AND i.AccountID="& PacienteID &" AND i.CompanyUnitID="& UnidadeID &" AND ii.Executado<>'C' and i.sysActive=1 AND (ii.ProfissionalID="& ProfissionalID &" OR isnull(ii.ProfissionalID) OR ii.ProfissionalID=0) GROUP BY i.id LIMIT 1000")
    while not inv.eof
        itens = inv("itens")&""
        descontados = ccur(inv("descontados"))

        'se localizou usa esse id
        if descontados=0 and itens=itensCheckin then
            InvoiceID = inv("id")
        end if
    inv.movenext
    wend
    inv.close
    set inv = nothing

    'RESPONSE.END

    if InvoiceID="0" then
        'se não localizou cria a invoice
        set pVal = db.execute("select sum( Quantidade *(ValorUnitario+Acrescimo-Desconto)) ValorTotal from cliniccentral.itensinvoice_temp where sysUser="& session("User") &" and tipoTela='checkin' and InvoiceID=0")
        valorTotal = pVal("ValorTotal")

        db.execute("insert into sys_financialinvoices set Name='Gerado pelo check-in', AccountID="& PacienteID &", AssociationAccountID=3, Value="& treatvalzero(ValorTotal) &", Tax=1, Currency='BRL', CompanyUnitID="& UnidadeID &", Recurrence=1, RecurrenceType='m', CD='C', sysActive=1, sysUser="& session("User") &", FormaID=0, ContaRectoID=0, sysDate=CURDATE(), CaixaID="& treatvalnull(session("CaixaID")) &", TabelaID="& treatvalnull(TabelaID) &" ")
        
        set pult = db.execute("select id from sys_financialinvoices where sysUser="& session("User") &" ORDER BY id DESC LIMIT 1")
        InvoiceID = pult("id")
        
        db.execute("insert into itensinvoice (InvoiceID, Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Desconto, Executado, DataExecucao, AgendamentoID, sysUser, ProfissionalID, EspecialidadeID, Acrescimo, Associacao, CentroCustoID) select "& InvoiceID &", Tipo, Quantidade, 0, ItemID, ValorUnitario, Desconto, 'S', CURDATE(), 0, "& session("User") &", "& ProfissionalID &", "& treatvalzero(EspecialidadeID) &", Acrescimo, 5, 0 FROM cliniccentral.itensinvoice_temp WHERE sysUser="& session("User") &" AND tipoTela='checkin'")
        
        db.execute("insert into sys_financialmovement set AccountAssociationIDCredit=0, AccountIDCredit=0, AccountAssociationIDDebit=3, AccountIDDebit="& PacienteID &", Value="& treatvalzero(ValorTotal) &", Date=CURDATE(), CD='C', Type='Bill', Currency='BRL', Rate=1, InvoiceID="& InvoiceID &", InstallmentNumber=1, sysUser="& session("User") &", CaixaID="& treatvalnull(session("CaixaID")) &", UnidadeID="& UnidadeID)
    end if

    'Dá o update nos invoiceID 0 do iitemp do checkin
    db.execute("delete from cliniccentral.itensinvoice_temp where tipoTela='checkin' and ItemInvoiceID=0 and sysUser="& session("User"))
    db.execute("insert into cliniccentral.itensinvoice_temp (sysUser, ItemInvoiceID, InvoiceID, tipoTela, Tipo, ItemID, Quantidade, ValorUnitario, Desconto, Acrescimo) select "& session("User") &", id, InvoiceID, 'checkin', 'S', ItemID, Quantidade, ValorUnitario, Desconto, Acrescimo from itensinvoice where InvoiceID="& InvoiceID)

    %>
    <script>
        invoiceFuncoes('listaItens', 'checkin', <%= InvoiceID%>, 'itensinvoice_<%= tipoTela %>');
        //atualizaItens('<%= tipoTela %>');
    </script>
    <%


elseif tipoTela="invoice" then
    sql = "insert into cliniccentral.itensinvoice_temp (sysUser, ItemInvoiceID, InvoiceID, tipoTela, Tipo, ItemID, Quantidade, ValorUnitario) SELECT "& session("User") &", ii.id, "& InvoiceID &", '"& tipoTela &"', ii.Tipo, ii.ItemID, ii.Quantidade, ii.ValorUnitario FROM sys_financialinvoices i LEFT JOIN itensinvoice ii ON ii.InvoiceID=i.id WHERE i.id="& InvoiceID
    'response.write( sql )
    db.execute(sql)
    'JÁ CHAMA OS ITENS DA INVOICE ASSIM QUE CARREGA A TELA'
    %>
    <script>
        invoiceFuncoes('listaItens', 'invoice', <%= InvoiceID%>, 'itensinvoice_<%= tipoTela %>');
        //atualizaItens('<%= tipoTela %>');
    </script>
    <%

end if

function iiTempRecalc(MetodoID, ContaID, BandeiraID, Parcelas, UnidadeID, tipoTela)
    '-> ATUALIZA A LISTA DE IITEM DE ACORDO COM A FORMA PREDEFINIDA
    db.execute("delete iitv from cliniccentral.itensinvoice_temp iit LEFT JOIN cliniccentral.itensinvoicevar_temp iitv ON iitv.iiTempID=iit.id WHERE iit.sysUser="& session("User") &" AND iit.tipoTela='"& tipoTela &"' AND iitv.tipoOrigem<>'autorizacao'")
    '<- ATUALIZA A LISTA DE IITEM DE ACORDO COM A FORMA PREDEFINIDA
    set iit = db.execute("select iit.* from cliniccentral.itensinvoice_temp iit WHERE iit.sysUser="& session("User") &" AND iit.Tipo='S' AND iit.tipoTela='"& tipoTela &"'")
    while not iit.eof
        'SÓ VAI BUSCAR NOS QUE TIVER DESCONTO OU ACRÉSCIMO
        ProcedimentoID = iit("ItemID")
        ValorUnitario = iit("ValorUnitario")
        sql = "select * from sys_formasrecto WHERE (Desconto>0 OR Acrescimo>0) AND MetodoID="& MetodoID &" AND (Contas LIKE '%|ALL|%' OR Contas LIKE '%|"& ContaID &"|%') AND "& Parcelas &" BETWEEN ParcelasDe AND ParcelasAte AND (Bandeiras='' OR Bandeiras LIKE '%|"& BandeiraID &"|%') "&_ 
        " AND ("&_
            "(Unidades='|ALL|') OR"&_
            "(Unidades='|EXCEPT|' AND NOT UnidadesExcecao LIKE '%|"& UnidadeID &"|%') OR"&_
            "(Unidades='|ONLY|' AND UnidadesExcecao LIKE '%|"& UnidadeID &"|%')"&_
        " ) "&_ 
        " AND ("&_
            "(Procedimentos LIKE '%|ALL|%') OR"&_
            "(Procedimentos LIKE '%|EXCEPT|%' AND NOT Procedimentos LIKE '%|"& ProcedimentoID &"|%') OR"&_
            "(Procedimentos LIKE '%|ONLY|%' AND Procedimentos LIKE '%|"& ProcedimentoID &"|%')"&_
        ")"
        'response.write( sql )
        set pFormas = db.execute( sql )
        if not pFormas.eof then
            Desconto = pFormas("Desconto")
            tipoDesconto = pFormas("tipoDesconto")
            if tipoDesconto="P" then
                Desconto = Desconto/100*ValorUnitario
            end if

            Acrescimo = pFormas("Acrescimo")
            tipoAcrescimo = pFormas("tipoAcrescimo")
            Descricao = "Forma de recebimento"
            tipoOrigem = "formasrecto"
            db.execute("insert into cliniccentral.itensinvoicevar_temp SET iiTempID="& iit("id") &", Desconto="& treatvalzero(Desconto) &", Acrescimo="& treatvalzero(Acrescimo) &", idOrigem=NULL, tipoOrigem='"& tipoOrigem &"', Descricao='"& Descricao &"'")
        end if
    iit.movenext
    wend
    iit.close
    set iit=nothing

    if tipoTela="checkin" then
    %>
    <script>
        invoiceFuncoes('listaItens', 'checkin', <%= InvoiceID%>, 'itensinvoice_<%= tipoTela %>');
        //atualizaItens('<%= tipoTela %>');
    </script>
    <%
    end if
end function


'if req("fcn")<>"" then
'    call listaItens(req("tipoTela"), 0)
'    response.end
'end if


'-> Ajax da forma de recto
if req("FormaRecto")<>"" then
    refMetodoID = ccur(ref("M"))
    refContaID = ref("C")
    refBandeiraID = ref("B")
    refParcelas = ref("P")
    refUnidadeID = ref("U")

        'VERIFICA SE HÁ FORMAS DE RECEBIMENTO PRÉ-DEFINIDAS PRA ESTA UNIDADE
        set m = db.execute("select pm.PaymentMethod, f.id, f.MetodoID FROM sys_formasrecto f LEFT JOIN sys_financialpaymentmethod pm ON pm.id=f.MetodoID WHERE f.MetodoID IN (1,2,8,9) AND ("&_
            "(Unidades='|ALL|') OR"&_
            "(Unidades='|EXCEPT|' AND NOT UnidadesExcecao LIKE '%|"& UnidadeID &"|%') OR"&_
            "(Unidades='|ONLY|' AND UnidadesExcecao LIKE '%|"& UnidadeID &"|%')"&_
        ") ORDER BY f.MetodoID")
        if not m.eof then
            %>
            <div class="row">
                <div class="col-md-12"><label>Forma de Pagamento</label></div>
            <%
            MetodosElegiveis = "0"
            while not m.eof
                Metodo = m("PaymentMethod")&""
                MetodoID = m("MetodoID")
                MetodosElegiveis = MetodosElegiveis &", "& m("id")
                if Metodo<>UltimoMetodo then
                    %>
                    <div class="col-md-3" onclick="formaRecto(<%= MetodoID %>, '', '', '', '<%= refUnidadeID %>', '<%= InvoiceID %>'); return false;"><label class="btn btn-block btn-default btn-sm"><input type="radio" name="MetodoID" value="<%= MetodoID %>" <% if refMetodoID=MetodoID then response.write(" checked ") end if %> > <%= Metodo %></label></div>
                    <%
                    UltimoMetodo = Metodo
                end if
            m.movenext
            wend
            m.close
            set m = nothing
            'sqlMetodo = "select GROUP_CONCAT(Contas) ContasBruto from sys_formasrecto where MetodoID="& refMetodoID &" AND (Unidades='|ALL|' OR (Unidades='|EXCEPT|' AND UnidadesExcecao NOT LIKE '%|"& refUnidadeID &"|%') OR (Unidades='|ONLY|' AND UnidadesExcecao LIKE '%|"& refUnidadeID &"|%') ) "

            %>
            </div>
            <div class="row pt10 contas">
                <div class="col-md-12"><label>Conta</label></div>
            <%
            nContas = 0
            if (session("CaixaID")="" AND refMetodoID=1) OR refMetodoID<>1 then
                set pMethod = db.execute("select AccountTypesC from cliniccentral.sys_financialpaymentmethod WHERE id="& refMetodoID)
                AccountTypesC = replace( pMethod("AccountTypesC")&"", "|", ", " )
                set pContas = db.execute("select * from sys_financialcurrentaccounts cc WHERE AccountType IN("& AccountTypesC &") AND cc.Empresa="& refUnidadeID &" AND cc.sysActive=1")
                while not pContas.eof
                    NomeConta = pContas("AccountName")
                    ContaID = pContas("id")

                    if refContaID="" then
                        refContaID = ContaID &""
                    end if

                    nContas = nContas+1
                    %>
                    <div class="col-md-3" onclick="formaRecto(<%= refMetodoID %>, <%= ContaID %>, '', '', <%= refUnidadeID %>, <%= InvoiceID %>); return false;"><label class="btn btn-block btn-default btn-sm"><input type="radio" name="ContaID" value="<%= ContaID %>" <% if refContaID=ContaID&"" then response.write(" checked ") end if %> > <%= NomeConta %></label></div>
                    <%
                pContas.movenext
                wend
                pContas.close
                set pContas = nothing
            else
                set pConta = db.execute("select ContaCorrenteID from caixa where id="& session("CaixaID"))
                ContaID = pConta("ContaCorrenteID")
            end if
            %>
            </div>
            <%
            if refMetodoID&""<>"8" then
                refParcelas = "1"
            else
                if refBandeiraID="" then
                    refBandeiraID = "1"
                end if
                %>
                <div class="row pt10">
                    <%= quickfield("simpleSelect", "BandeiraID", "Bandeira", 3, refBandeiraID, "select * from cliniccentral.bandeiras_cartao", "Bandeira", " semVazio onchange=""formaRecto("& refMetodoID &", "& refContaID &", $(this).val(), '', '"& refUnidadeID &"', '"& InvoiceID &"')"" ") %>

                    <div class="col-md-9">
                        <label class="pb5">Parcelas</label><br>
                        <%
                        set parcs = db.execute("SELECT ifnull(MIN(ParcelasDe), 1) ParcelasDe, ifnull(MAX(ParcelasAte), 1) ParcelasAte FROM sys_formasrecto WHERE MetodoID="& refMetodoID &" AND (Contas LIKE '%|"& refContaID &"|%' OR Contas LIKE '%|ALL|%') AND Bandeiras LIKE '%|"& refBandeiraID &"|%' AND ("&_
                            "(Unidades='|ALL|') OR"&_
                            "(Unidades='|EXCEPT|' AND NOT UnidadesExcecao LIKE '%|"& UnidadeID &"|%') OR"&_
                            "(Unidades='|ONLY|' AND UnidadesExcecao LIKE '%|"& UnidadeID &"|%')"&_
                        ")")
                        Parcela = ccur( parcs("ParcelasDe") )
                        while Parcela<=ccur( parcs("ParcelasAte") )
                            if refParcelas="" then
                                refParcelas = Parcela&""
                            end if
                            %>
                            <label class="btn btn-light btn-xs"><input type="radio" name="Parcelas" value="<%= Parcela %>" <% if refParcelas=Parcela&"" then response.write(" checked ") end if %>  onclick="formaRecto(<%= refMetodoID %>, <%= refContaID %>, '<%= refBandeiraID %>', <%= Parcela %>, '<%= refUnidadeID %>', '<%= InvoiceID %>'); return false;" > <%= Parcela %>x</label>
                            <%
                            Parcela = Parcela+1
                        wend
                        %>
                    </div>
                </div>
                <%
            end if

            'response.write("<br> refMetodoID: "& refMetodoID )
            'response.write("<br> refContaID: "& refContaID )
            'response.write("<br> refBandeiraID: "& refBandeiraID )
            'response.write("<br> refParcelas: "& refParcelas )
            
            '-> RECALCULA CADA PROCEDIMENTO DE ACORDO COM A FORMA DE RECEBIMENTO
            call iiTempRecalc(refMetodoID, refContaID, refBandeiraID, refParcelas, refUnidadeID, "checkin")
            '<- RECALCULA CADA PROCEDIMENTO DE ACORDO COM A FORMA DE RECEBIMENTO
        else
            %>
            Nenhuma forma predefinida, segue com a criação da invoice em valor cheio e modal de pagamento normal.
            <%
        end if

        if nContas=1 then
            %>
            <script>
                $(".contas").css("display", "none")
            </script>
            <%
        end if


        %>
        <script>
            $(".desc-manual").css("display", "none");
        </script>
        <div class="col-md-12 desc-forma">
            <div class="row">
                <div class="col-md-2 col-md-offset-10">
                    <button type="button" class="btn btn-sm btn-block btn-success" onclick="confAut(1)">Confirmar</button>
                </div>
            </div>
        </div>
    <%

    response.end
end if
'<- Ajax da forma de recto

%>

<div class="panel">
    <div class="panel-heading">
        <span class="panel-title">Itens da Fatura</span>
    </div>
    <div class="panel-boby" id="conteudo-pagto-checkin">
        <form id="frm-pagto-checkin">
            <div class="row">
                <div class="col-md-6"></div>
                <%= quickfield("text", "DescontoGeral", "Aplicar desconto", "3", "", " text-right input-mask-brl ", "", " onkeyup='fDescontoGeral()' ") %>
                <div class="col-md-2 pt25">
                    <input type="radio" value="P" name="TipoDescontoGeral" onchange="fDescontoGeral()" checked> %
                    <input type="radio" value="V" name="TipoDescontoGeral" onchange="fDescontoGeral()"> R$
                </div>
            </div>

            <hr class="short alt ml20 mr20">

            <div class="row">
                <div class="col-md-12 pl25 pr25" id="itensinvoice_<%= tipoTela %>">
                </div>
            </div>
            <hr class="short alt ml20 mr20">
            <div class="row pb20">
                <div class="col-md-12 pl25" id="divRecto">

                </div>
            </div>

            <div class="row  ptn pbn" >
                <div class="col-md-12" id="divDescontos">
                    
                </div>
            </div>
        </form>
    </div>
    <div class="panel-footer">
        <div class="row">
            <div class="col-md-12 text-right" id="divReceber">
                <button class="btn btn-primary hidden" id="btn-modal-checkin-receber" onclick="invoiceFuncoes('Receber', 'checkin', '<%= InvoiceID %>', 'divReceber')">RECEBER</button>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">

<% if req("FormaRecto")="" and tipoTela="checkin" then %>
    formaRecto(1, '', '', '', '<%= UnidadeID %>', '<%= InvoiceID %>');
<% end if %>

var intervalDesconto;

function fDescontoGeral(){
    var DescontoGeral = $("#DescontoGeral").val();
    var TipoDescontoGeral = $("input[name=TipoDescontoGeral]:checked").val();

    clearInterval(intervalDesconto);

    intervalDesconto = setTimeout(() => {
        $.get("invoiceFuncoes.asp?fcn=DescontoGeral&tipoTela=<%= tipoTela %>&InvoiceID=<%= InvoiceID %>&DescontoGeral="+ DescontoGeral +"&TipoDescontoGeral="+ TipoDescontoGeral, function(data){
            eval(data);
        });    
    }, 300);
    
}

function validaDescontos(){
    $.post("invoiceFuncoes.asp?fcn=avaliaDesconto&InvoiceID=<%= InvoiceID %>&tipoTela=<%= tipoTela%>", 
                $("input[name^=ifatDesconto]").serialize()
            , function(data){
                $("#divDescontos").html(data);
            });
}

function solicitarAutorizacao(){
    $.post("modulos/discount/SolicitarAutorizacaoDesconto.asp", $("#frm-pagto-checkin").serialize(), function(data){
        var solicitacaoId = parseInt(data);

        if(solicitacaoId > 0){
            showMessageDialog("Desconto solicitado para aprovação.", "warning");

            $(".badge-waiting-approval").html(`<span><i class='far fa-circle-o-notch fa-spin'></i> Aguardando aprovação...</span>`)
            $("#btn-solicitar-aprovacao").fadeOut();
            
            startCheckAprovacaoDesconto(solicitacaoId);
        }else{
            showMessageDialog("Preencha todos os campos para solicitar aprovação do desconto.", "danger");
        }
    });
}

var checkAprovacaoInterval;

function startCheckAprovacaoDesconto(requestId, interval = 5000){
    endCheckAprovacaoInterval();
    
    checkAprovacaoInterval = setInterval(function(){
        $.get("modulos/discount/CheckAutorizacaoDesconto.asp", {SolicitacaoID:requestId}, function(data){
            if(data==="APROVADO"){
                $("#audioNotificacao").trigger("play");

                invoiceFuncoes('listaItens', 'checkin', <%= InvoiceID%>, 'itensinvoice_<%= tipoTela %>');
                endCheckAprovacaoInterval();
                $("#content-solicitar-aprovacao-desconto").fadeOut();
                $(".desc-forma").fadeIn();

                showMessageDialog("Desconto aprovado com sucesso.", "success");
            }
        });
    }, interval);
}

function endCheckAprovacaoInterval(){
    clearInterval(checkAprovacaoInterval);
}

var myModalEl = document.getElementById('modal-table');
myModalEl.addEventListener('hidden.bs.modal', function (event) {
    endCheckAprovacaoInterval();
});

function confAut(dir){
    $.post("invoiceFuncoes.asp?fcn=confAut&InvoiceID=<%= InvoiceID %>&tipoTela=<%= tipoTela%>", 
                {
                    senhaAprovacao:$("#senhaAprovacao").val(),
                    UsuarioAprovacao:$("input[name=UsuarioAprovacao]:checked").val(),
                    ObsDesconto:$("#ObsDesconto").val(),
                    dir:dir
                }
            , function(data){
                eval(data);
            });
}

function aDesc(){
    $.post("invoiceFuncoes.asp?fcn=aDesc&InvoiceID=<%= InvoiceID %>&tipoTela=<%= tipoTela%>", 
                $("input[name^=ifatDesconto], input[name=MetodoID]").serialize()
            , function(data){
                eval(data);
            });
}
</script>