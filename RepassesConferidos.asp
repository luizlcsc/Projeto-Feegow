<!--#include file="connect.asp"-->

<!--#include file="modal.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Repasses Consolidados");
    $(".crumb-icon a span").attr("class", "far fa-puzzle-piece");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("repasses previamente conferidos e consolidados");
    <%
    if aut("configrateio")=1 and false then
    %>
    $("#rbtns").html('<a class="btn btn-sm btn-success pull-right" href="./?P=Rateio&Pers=1"><i class="far fa-puzzle-piece"></i><span class="menu-text"> Configurar Regras de Repasse</span></a>');
    <%
    end if
    %>
</script>



<%

Unidades = reqf("Unidades")
if Unidades="" then
    Unidades = "|"& session("UnidadeID") &"|"
end if

if reqf("X")<>"" then
    set LinhaRepasseSQL = db_execute("SELECT ItemInvoiceID,ItemGuiaID,GuiaConsultaID,ItemHonorarioID,ItemDescontadoID FROM rateiorateios WHERE id="&reqf("X"))
    if not LinhaRepasseSQL.eof then
	    'db_execute("delete from rateiorateios where id="&reqf("X"))
	    ItemDescontadoID=LinhaRepasseSQL("ItemDescontadoID")
	    if isnull(ItemDescontadoID) then
	        ItemDescontadoID = " IS NULL"
        else
            ItemDescontadoID="="&ItemDescontadoID
	    end if

	    ItemInvoiceID=LinhaRepasseSQL("ItemInvoiceID")
	    if isnull(ItemInvoiceID) then
	        ItemInvoiceID = " IS NULL"
        else
            ItemInvoiceID="="&ItemInvoiceID
	    end if

	    ItemGuiaID=LinhaRepasseSQL("ItemGuiaID")
	    if isnull(ItemGuiaID) then
	        ItemGuiaID = " IS NULL"
        else
            ItemGuiaID="="&ItemGuiaID
	    end if

	    GuiaConsultaID=LinhaRepasseSQL("GuiaConsultaID")
	    if isnull(GuiaConsultaID) then
	        GuiaConsultaID = " IS NULL"
        else
            GuiaConsultaID="="&GuiaConsultaID
	    end if

	    ItemHonorarioID=LinhaRepasseSQL("ItemHonorarioID")
	    if isnull(ItemHonorarioID) then
	        ItemHonorarioID = " IS NULL"
        else
            ItemHonorarioID="="&ItemHonorarioID
	    end if
	    sqlDel = "delete from rateiorateios where ItemInvoiceID"&ItemInvoiceID&" AND ItemDescontadoID"&ItemDescontadoID&" AND ItemGuiaID"&ItemGuiaID&" AND GuiaConsultaID"&GuiaConsultaID&" AND ItemHonorarioID"&ItemHonorarioID
	    'response.write(sqlDel)
	    db_execute(sqlDel)
    end if
	response.Redirect("./?P=RepassesConferidos&Pers=1&AccountID="&reqf("AccountID")&"&Forma="&reqf("Forma")&"&Lancado="&reqf("Lancado")&"&Status="&reqf("Status")&"&De="&reqf("De")&"&Ate="&reqf("Ate"))
end if


ContaCredito = reqf("AccountID")
FormaID = reqf("FormaID")
Lancado = reqf("Lancado")
De = reqf("De")
TipoData = reqf("TipoData")
DeSqlProf = De

if De&""<>"" and TipoData="Comp" then
    DeExec = dateadd("m", -9, De)
    DeSqlProf = dateadd("d", -15, De)
else
    DeExec=De
end if

Ate = reqf("Ate")
if De="" or not isdate(De) then
	De = date()'dateadd("m", -1, date())
end if
if Ate="" or not isdate(Ate) then
	Ate = date()
end if
%>

    <form action="" id="buscaRepasses" name="buscaRepasses" method="post">
        <input type="hidden" name="P" value="RepassesConferidos" />
        <input type="hidden" name="Pers" value="1" />
        <br />
        <div class="panel">
            <div class="panel-body hidden-print">
                <div class="row">
                    <%
                    if ModoFranquia=true and session("UnidadeID")>0 then
                        filtroUnidade = " AND c.Unidades LIKE '%|"&session("UnidadeID")&"|%' "
                    end if
                    %>
                    <%= quickfield("multiple", "Forma", "Convênio", 2, reqf("Forma"), "select '0' id, '     PARTICULAR' Forma UNION ALL select id, NomeConvenio from (select c.id, c.NomeConvenio from convenios c where c.sysActive=1 "&filtroUnidade&" order by c.NomeConvenio) t ORDER BY Forma", "Forma", " required ") %>
                    <%= quickfield("multiple", "FormaRecto", "Forma de recto.", 2, reqf("FormaRecto"), "select id, PaymentMethod from cliniccentral.sys_financialpaymentmethod where TextC<>'' ORDER BY PaymentMethod", "PaymentMethod", "") %>
                    <%= quickfield("multiple", "Status", "Status de recto.", 2, reqf("Status"), "select 'RC' id, 'Recebido - Compensado' descricao UNION ALL select 'RN', 'Recebido - Não compensado' UNION ALL select 'NR', 'Não Recebidos'", "descricao", "") %>

                    <%= quickField("datepicker", "De", "Execução", 2, De, "", "", " placeholder='De' required='required'") %>
                    <%= quickField("datepicker", "Ate", "&nbsp;", 2, Ate, "", "", " placeholder='At&eacute;' required='required'") %>
                    <div class="col-md-2 ">
                        <label>Tipo de Data:</label><br />
                        <span class="radio-custom"><input type="radio" name="TipoData" value="Exec" <% if reqf("TipoData")="Exec" or reqf("TipoData")="" then response.write(" checked ") end if %> id="TDE" /><label for="TDE"> Execução</label></span>
                        <br />
                        <span class="radio-custom"><input type="radio" name="TipoData" value="Comp" <% if reqf("TipoData")="Comp" then response.write(" checked ") end if %> id="TDC" /><label for="TDC"> Compensação</label></span>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-1 pt20 checkbox-custom checkbox-warning">
                    <br>
                        <input type="checkbox" name="modoCalculo" id="modoCalculo" value="I" <% if reqf("modoCalculo")="I" then response.write(" checked ") end if %> /><label for="modoCalculo"> Invertido</label>
                    </div>
                    <div class="col-md-5" id="calculaRepasses">
                        <%server.Execute("calculaRepasse.asp")%>
                    </div>
                    <div class="col-md-2">
                        <%= quickfield("empresaMultiIgnore", "Unidades", "Unidades", 12, Unidades, "", "", "") %>
                    </div>
                    <div class="col-md-2">
                        <label>Conta Cr&eacute;dito</label><br />
                        <%= simpleSelectCurrentAccounts("AccountID", "00, 5, 8, 4, 2, 1", reqf("AccountID"), " ","") %>
                        <%'=selectInsertCA("Profissional", "AccountID", reqf("AccountID"), "5, 8, 2, 6", "", " required ", "")%>
                    </div>
                    <div class="col-md-1">
                        <label>&nbsp;</label><br />
                        <button class="btn btn-ms btn-primary"><i class="far fa-search"></i> Buscar</button>
                    </div>
                     <div class="col-md-1">
                         <label>&nbsp;</label><br />
                         <button type="button" class="btn  btn-info" onclick="print()"><i class="far fa-print"></i></button>
                        <!-- <button type="button" class="btn  btn-info"  onclick="printInvoices()"><i class="far fa-usd"></i></button> -->
                     </div>

                </div>
            </div>
        </div>
    </form>

<script>
    function printInvoices(){
        let invoices = [];
        $("[invoiceapagarid]").each((item,key) => {
        	 if(invoices.indexOf($(key).attr("invoiceapagarid")) == -1){
            		invoices.push($(key).attr("invoiceapagarid"));
             }
        });

        if(invoices && invoices.length > 0){
            $.post(`reciboIntegrado.asp?I=${invoices.join(",")}`, $("#formItens").serialize(), function(data, status){ $("#modal").html(data) });
        }
    }
</script>

<div class="panel">
    <div class="panel-body">
    <div style="text-align: right">
        <button type="button" class="btn btn-default btn-xs" onclick="openSelectCols()">
            <i class="far fa-table"></i> Selecionar Colunas
        </button>
    </div>
<div class="alert alert-danger hidden">
    <strong>Atenção! </strong> Esta página está em manutenção. Tente novamente mais tarde.
</div>

    <%
Response.Flush
ExibeResultado=True
if datediff("d", De, Ate)>122 then

    %>
<div class="alert alert-warning m10">
    <strong>Atenção!</strong> Escolha um período menor que 4 meses.
</div>
    <%
    ExibeResultado=False
end if
if datediff("d", De, Ate)>15 and reqf("AccountID")="" then

    %>
<div class="alert alert-warning m10">
    <strong>Atenção!</strong> Escolha um período menor que 15 dias ou prencha o executante.
</div>
    <%
    ExibeResultado=False
end if

if ExibeResultado then
    TemRepasse=0
    AccountID = reqf("AccountID")

    db_execute("update rateiorateios set DataServicoExecucao=  "&_
               "(CASE WHEN ItemInvoiceID IS NOT NULL THEN ( "&_
               "SELECT ii.DataExecucao "&_
               "FROM itensinvoice ii "&_
               "WHERE ii.id=ItemInvoiceID "&_
               "LIMIT 1) WHEN ItemGuiaID IS NOT NULL THEN ( "&_
               "SELECT ps.Data "&_
               "FROM tissprocedimentossadt ps "&_
               "WHERE ps.id=ItemGuiaID "&_
               "LIMIT 1) WHEN ItemGuiaID IS NOT NULL THEN ( "&_
               "SELECT ph.Data "&_
               "FROM tissprocedimentoshonorarios ph "&_
               "WHERE ph.id=ItemHonorarioID "&_
               "LIMIT 1) WHEN GuiaConsultaID IS NOT NULL THEN ( "&_
               "SELECT gc.DataAtendimento "&_
               "FROM tissguiaconsulta gc "&_
               "WHERE gc.id=GuiaConsultaID "&_
               "LIMIT 1) END) "&_
               " "&_
               "where DataServicoExecucao is null ")

    if AccountID="" then
        if ModoFranquia then
            sqlContas = "SELECT t.* FROM ("&_
                        "SELECT DISTINCT ContaCredito AccountID, SUBSTRING_INDEX(rr.ContaCredito, '_', 1) rAssociacaoID, SUBSTRING_INDEX(rr.ContaCredito, '_', -1) rContaID "&_
                        "FROM rateiorateios rr "&_
                        "WHERE rr.DataServicoExecucao BETWEEN "& mydateNull(DeSqlProf) &" AND "& mydateNull(Ate) &" AND ContaCredito not in ('0', '0_0', 'LAU', '') "&_
                         " )t "&_
                         "LEFT JOIN profissionais prof ON t.rAssociacaoID = t.rContaID=prof.id AND t.AccountID=5 "&_
                         "LEFT JOIN fornecedores forn ON t.rAssociacaoID = t.rContaID=forn.id AND t.AccountID=2 "&_
                         franquia(" WHERE COALESCE(cliniccentral.overlap(COALESCE(prof.Unidades, forn.Unidades),COALESCE(NULLIF('"&Unidades&"',''),'-999')),TRUE)")

            set ProfissionalSQL = db_execute(sqlContas)
        else
            sqlRepasses = "SELECT DISTINCT rr.ContaCredito AccountID FROM rateiorateios rr "&_
                          "WHERE rr.DataServicoExecucao BETWEEN "& mydateNull(DeSqlProf) &" AND "& mydateNull(Ate) &" AND rr.ContaCredito not in ('0', '0_0', 'LAU', '')"
            set ProfissionalSQL = db_execute(sqlRepasses)
        end if
    else
        set ProfissionalSQL = db_execute("SELECT '"&AccountID&"' AccountID")
    end if

    while not ProfissionalSQL.eof
        ContaCredito = ProfissionalSQL("AccountID")
        if ContaCredito<>"0" then
            if instr(ContaCredito,"_") then
                spltContaCredito = split(ContaCredito, "_")
                AssociationAccountID = spltContaCredito(0)
                AccountID = spltContaCredito(1)
            else
                AssociationAccountID = 0
                AccountID = 0
            end if
        else
            AssociationAccountID = 0
            AccountID = 0
        end if


            TotalRepasse = 0
            TotalProcedimento = 0
            ContaRepasses = 0

            Forma = replace(reqf("Forma"), "|", "")


            if ContaCredito<>"" and Forma<>"" then
            sql="select rr.*, ii.InvoiceID InvoiceAPagarID from rateiorateios rr LEFT JOIN itensinvoice ii ON ii.id=rr.ItemContaAPagar where rr.ContaCredito='"& ContaCredito &"'"
                    'response.write(sql)
'                set rr = db_execute(sql)

                modoCalculo = reqf("modoCalculo")
                if modoCalculo="" then
                    modoCalculo = "N"
                end if

                Unidades = reqf("Unidades")
                if Unidades<>"" then
                    sqlUnidades = " AND t.UnidadeID IN ("& replace(Unidades, "|", "") &") "
                end if

                FormaRecto = replace(reqf("FormaRecto"),"|","")
                if FormaRecto<>"" then
                    if instr(FormaRecto, "-1")>0 then
                        sqlFormRecto=" AND pmdesc.id IS NULL "
                    else
                        sqlFormRecto=" AND pmdesc.id IN ("&FormaRecto&") "
                    end if
                end if

'Response.End
                if reqf("TipoData")="Exec" then
                                sqlRR = "select  idesc.PagamentoID IDMovPay, ca.IntegracaoSPLIT, cheque.DataCompensacao DataCompenscaoCheque, mdisc.Date DataPagtoConvenio, ri.DateToReceive, mdesc.Value as ParcelaValor,mdesc.PaymentMethodID, mdesc.Date DataPagto, fct.Parcelas, ifnull(pmdesc.PaymentMethod, '-') PaymentMethod, t.*, iip.InvoiceID InvoiceAPagarID, c.NomeConvenio, proc.NomeProcedimento, pac.NomePaciente, t.Executado from	(	"&_
                                " select null GuiaID, null TipoGuia, i.CompanyUnitID UnidadeID, ifnull(tab.NomeTabela, '') NomeTabela, ii.InvoiceID, 'ItemInvoiceID' Tipo, ii.DataExecucao, '0' ConvenioID, ii.ItemID ProcedimentoID, i.AccountID PacienteID, (ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto)) ValorProcedimento, rrp.*, ii.Executado FROM itensinvoice ii 	INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN tabelaparticular tab ON tab.id=i.TabelaID	INNER JOIN rateiorateios rrp ON rrp.ItemInvoiceID=ii.id	WHERE ii.Tipo='S'  AND rrp.ContaCredito='"& ContaCredito &"' AND ii.DataExecucao BETWEEN "& mydateNull(DeExec) &" AND "& mydateNull(Ate) &"		UNION ALL	"&_
                                " SELECT gc.id GuiaID, 'GuiaConsulta' TipoGuia, gc.UnidadeID, '', NULL, 'GuiaConsultaID', gc.DataAtendimento, gc.ConvenioID, gc.ProcedimentoID, gc.PacienteID, gc.ValorProcedimento, rrgc.*, '' Executado FROM tissguiaconsulta gc 	INNER JOIN rateiorateios rrgc ON rrgc.GuiaConsultaID=gc.id	WHERE gc.DataAtendimento BETWEEN "& mydateNull(DeExec) &" AND "& mydateNull(Ate) &"		UNION ALL	"&_
                                " SELECT gps.id GuiaID, 'GuiaSADT' TipoGuia, gs.UnidadeID, '', NULL, 'ItemGuiaID', gps.Data, gs.ConvenioID, gps.ProcedimentoID, gs.PacienteID, gps.ValorTotal, rrgps.*, '' Executado FROM tissprocedimentossadt gps 	INNER JOIN rateiorateios rrgps ON rrgps.ItemGuiaID=gps.id	INNER JOIN tissguiasadt gs ON gps.GuiaID=gs.id WHERE gps.`Data` BETWEEN  "& mydateNull(DeExec) &" AND "& mydateNull(Ate) &" UNION ALL "&_
                                " SELECT gps.id GuiaID, 'GuiaHonorarios' TipoGuia, gh.UnidadeID, '', NULL, 'ItemHonorarioID', gps.Data, gh.ConvenioID, gps.ProcedimentoID, gh.PacienteID, gh.Procedimentos ValorTotal, rrgps.*, '' Executado FROM tissprocedimentoshonorarios gps 	INNER JOIN rateiorateios rrgps ON rrgps.ItemHonorarioID=gps.id	INNER JOIN tissguiahonorarios gh ON gps.GuiaID=gh.id WHERE gps.`Data` BETWEEN  "& mydateNull(DeExec) &" AND "& mydateNull(Ate) &"	) t "&_
                                " LEFT JOIN itensinvoice iip ON (iip.id=t.ItemContaAPagar) LEFT JOIN pacientes pac ON pac.id=t.PacienteID LEFT JOIN convenios c ON c.id=t.ConvenioID LEFT JOIN procedimentos proc ON proc.id=t.ProcedimentoID "&_
                                " LEFT JOIN itensdescontados idesc ON idesc.id=t.ItemDescontadoID "&_
                                " LEFT JOIN sys_financialmovement mdesc ON mdesc.id=idesc.PagamentoID "&_
                                " LEFT JOIN sys_financialcurrentaccounts ca ON ca.id=mdesc.AccountIDDebit "&_
                                " LEFT JOIN sys_financialpaymentmethod pmdesc ON pmdesc.id=mdesc.PaymentMethodID "&_
                                " LEFT JOIN sys_financialcreditcardtransaction fct ON fct.MovementID=mdesc.id "&_
                                " LEFT JOIN sys_financialcreditcardreceiptinstallments ri ON ri.id=t.ParcelaID "&_
                                " LEFT JOIN tissguiasinvoice tgi ON tgi.TipoGuia=t.TipoGuia AND tgi.GuiaID=t.GuiaID "&_
                                " LEFT JOIN sys_financialmovement mov ON mov.InvoiceID=tgi.InvoiceID "&_
                                " LEFT JOIN sys_financialdiscountpayments disc ON disc.InstallmentID=mov.id "&_
                                " LEFT JOIN sys_financialmovement mdisc ON mdisc.id=disc.MovementID "&_
                                " LEFT JOIN sys_financialreceivedchecks cheque ON cheque.MovementID=mdesc.id "&_
                                " WHERE (t.ContaCredito LIKE CONCAT('%_"& ContaCredito &"') or t.ContaCredito='"& ContaCredito &"') AND t.ConvenioID IN ("& Forma &") "&sqlFormRecto&" AND t.modoCalculo='"& modoCalculo &"' "& sqlUnidades &_
                                " GROUP BY t.id ORDER BY t.DataExecucao, pac.NomePaciente, proc.NomeProcedimento"
                else
                                 sqlRR = "select  idesc.PagamentoID IDMovPay, ca.IntegracaoSPLIT, cheque.DataCompensacao DataCompenscaoCheque, mdisc.Date DataPagtoConvenio, ri.DateToReceive, mdesc.Value as ParcelaValor,mdesc.PaymentMethodID, mdesc.Date DataPagto, fct.Parcelas, ifnull(pmdesc.PaymentMethod, '-') PaymentMethod, t.*, iip.InvoiceID InvoiceAPagarID, c.NomeConvenio, proc.NomeProcedimento, pac.NomePaciente, t.Executado from	(	"&_
                                 " select null GuiaID, null TipoGuia, i.CompanyUnitID UnidadeID, ifnull(tab.NomeTabela, '') NomeTabela, ii.InvoiceID, 'ItemInvoiceID' Tipo, ii.DataExecucao, '0' ConvenioID, ii.ItemID ProcedimentoID, i.AccountID PacienteID, (ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto)) ValorProcedimento, rrp.*, ii.Executado FROM itensinvoice ii 	INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN tabelaparticular tab ON tab.id=i.TabelaID	INNER JOIN rateiorateios rrp ON rrp.ItemInvoiceID=ii.id	WHERE ii.Tipo='S'  AND rrp.ContaCredito='"& ContaCredito &"' AND ii.DataExecucao BETWEEN "& mydateNull(DeExec) &" AND "& mydateNull(Ate) &"		UNION ALL	"&_
                                 " SELECT gc.id GuiaID, 'GuiaConsulta' TipoGuia, gc.UnidadeID, '', NULL, 'GuiaConsultaID', gc.DataAtendimento, gc.ConvenioID, gc.ProcedimentoID, gc.PacienteID, gc.ValorProcedimento, rrgc.*, '' Executado"&_
                                 " FROM tissguiaconsulta gc"&_
                                 " INNER JOIN rateiorateios rrgc ON rrgc.GuiaConsultaID=gc.id"&_
                                 " LEFT JOIN itensinvoice iip ON (iip.id=rrgc.ItemContaAPagar)"&_
                                 " LEFT JOIN pacientes pac ON pac.id=gc.PacienteID"&_
                                 " LEFT JOIN convenios c ON c.id=gc.ConvenioID"&_
                                 " LEFT JOIN procedimentos proc ON proc.id=gc.ProcedimentoID"&_
                                 " LEFT JOIN itensdescontados idesc ON idesc.id=rrgc.ItemDescontadoID"&_
                                 " LEFT JOIN sys_financialmovement mdesc ON mdesc.id=idesc.PagamentoID"&_
                                 " LEFT JOIN sys_financialcurrentaccounts ca ON ca.id=mdesc.AccountIDDebit"&_
                                 " LEFT JOIN cliniccentral.sys_financialpaymentmethod pmdesc ON pmdesc.id=mdesc.PaymentMethodID"&_
                                 " LEFT JOIN sys_financialcreditcardtransaction fct ON fct.MovementID=mdesc.id"&_
                                 " LEFT JOIN sys_financialcreditcardreceiptinstallments ri ON ri.id=rrgc.ParcelaID"&_
                                 " LEFT JOIN tissguiasinvoice tgi ON tgi.TipoGuia='GuiaConsulta' AND tgi.GuiaID=gc.id"&_
                                 " LEFT JOIN sys_financialmovement mov ON mov.InvoiceID=tgi.InvoiceID"&_
                                 " LEFT JOIN sys_financialdiscountpayments disc ON disc.InstallmentID=mov.id"&_
                                 " LEFT JOIN sys_financialmovement mdisc ON mdisc.id=disc.MovementID"&_
                                 " LEFT JOIN sys_financialreceivedchecks cheque ON cheque.MovementID=mdesc.id"&_
                                 " where mdisc.date BETWEEN "& mydateNull(DeExec) &" AND "& mydateNull(Ate) &_
                                 " UNION ALL	"&_
                                 " SELECT gps.GuiaID GuiaID, 'GuiaSADT' TipoGuia, gs.UnidadeID, '', NULL, 'ItemGuiaID', gps.Data, gs.ConvenioID, gps.ProcedimentoID, gs.PacienteID, gps.ValorTotal, rrgps.*, '' Executado"&_
                                 " FROM tissprocedimentossadt gps"&_
                                 " INNER JOIN rateiorateios rrgps ON rrgps.ItemGuiaID=gps.id"&_
                                 " INNER JOIN tissguiasadt gs ON gps.GuiaID=gs.id"&_
                                 " LEFT JOIN itensinvoice iip ON (iip.id=rrgps.ItemContaAPagar)"&_
                                 " LEFT JOIN pacientes pac ON pac.id=gs.PacienteID"&_
                                 " LEFT JOIN convenios c ON c.id=gs.ConvenioID"&_
                                 " LEFT JOIN procedimentos proc ON proc.id=gps.ProcedimentoID"&_
                                 " LEFT JOIN itensdescontados idesc ON idesc.id=rrgps.ItemDescontadoID"&_
                                 " LEFT JOIN sys_financialmovement mdesc ON mdesc.id=idesc.PagamentoID"&_
                                 " LEFT JOIN sys_financialcurrentaccounts ca ON ca.id=mdesc.AccountIDDebit"&_
                                 " LEFT JOIN cliniccentral.sys_financialpaymentmethod pmdesc ON pmdesc.id=mdesc.PaymentMethodID"&_
                                 " LEFT JOIN sys_financialcreditcardtransaction fct ON fct.MovementID=mdesc.id"&_
                                 " LEFT JOIN sys_financialcreditcardreceiptinstallments ri ON ri.id=rrgps.ParcelaID"&_
                                 " LEFT JOIN tissguiasinvoice tgi ON tgi.TipoGuia= 'GuiaSADT' AND tgi.GuiaID=gps.GuiaID"&_
                                 " LEFT JOIN sys_financialmovement mov ON mov.InvoiceID=tgi.InvoiceID"&_
                                 " LEFT JOIN sys_financialdiscountpayments disc ON disc.InstallmentID=mov.id"&_
                                 " LEFT JOIN sys_financialmovement mdisc ON mdisc.id=disc.MovementID"&_
                                 " LEFT JOIN sys_financialreceivedchecks cheque ON cheque.MovementID=mdesc.id"&_
                                 " where mdisc.date BETWEEN "& mydateNull(DeExec) &" AND "& mydateNull(Ate) &_
                                 " UNION ALL "&_
                                 " SELECT gh.id GuiaID, 'GuiaHonorarios' TipoGuia, gh.UnidadeID, '', NULL, 'ItemHonorarioID', gps.Data, gh.ConvenioID, gps.ProcedimentoID, gh.PacienteID, gh.Procedimentos ValorTotal, rrgps.*, '' Executado FROM tissprocedimentoshonorarios gps 	INNER JOIN rateiorateios rrgps ON rrgps.ItemHonorarioID=gps.id	INNER JOIN tissguiahonorarios gh ON gps.GuiaID=gh.id WHERE gps.`Data` BETWEEN  "& mydateNull(DeExec) &" AND "& mydateNull(Ate) &"	) t "&_
                                 " LEFT JOIN itensinvoice iip ON (iip.id=t.ItemContaAPagar) LEFT JOIN pacientes pac ON pac.id=t.PacienteID LEFT JOIN convenios c ON c.id=t.ConvenioID LEFT JOIN procedimentos proc ON proc.id=t.ProcedimentoID "&_
                                 " LEFT JOIN itensdescontados idesc ON idesc.id=t.ItemDescontadoID "&_
                                 " LEFT JOIN sys_financialmovement mdesc ON mdesc.id=idesc.PagamentoID "&_
                                 " LEFT JOIN sys_financialcurrentaccounts ca ON ca.id=mdesc.AccountIDDebit "&_
                                 " LEFT JOIN cliniccentral.sys_financialpaymentmethod pmdesc ON pmdesc.id=mdesc.PaymentMethodID "&_
                                 " LEFT JOIN sys_financialcreditcardtransaction fct ON fct.MovementID=mdesc.id "&_
                                 " LEFT JOIN sys_financialcreditcardreceiptinstallments ri ON ri.id=t.ParcelaID "&_
                                 " LEFT JOIN tissguiasinvoice tgi ON tgi.TipoGuia=t.TipoGuia AND tgi.GuiaID=t.GuiaID "&_
                                 " LEFT JOIN sys_financialmovement mov ON mov.InvoiceID=tgi.InvoiceID "&_
                                 " LEFT JOIN sys_financialdiscountpayments disc ON disc.InstallmentID=mov.id "&_
                                 " LEFT JOIN sys_financialmovement mdisc ON mdisc.id=disc.MovementID "&_
                                 " LEFT JOIN sys_financialreceivedchecks cheque ON cheque.MovementID=mdesc.id "&_
                                 " WHERE COALESCE(mdisc.date, mdesc.Date) BETWEEN "& mydateNull(DeExec) &" AND "& mydateNull(Ate) &" and (t.ContaCredito LIKE CONCAT('%_"& ContaCredito &"') or t.ContaCredito='"& ContaCredito &"') AND t.ConvenioID IN ("& Forma &") "&sqlFormRecto&" AND t.modoCalculo='"& modoCalculo &"' "& sqlUnidades &_
                                 " GROUP BY t.id ORDER BY t.DataExecucao, pac.NomePaciente, proc.NomeProcedimento"
                end if

                if reqf("Debug")="1" then
                    response.write( session("Banco") & chr(10) & chr(13) & sqlRR )
                end if

                set rr = db_execute( sqlRR )
                if not rr.eof then
                %>
                <h3><%=accountName(AssociationAccountID, AccountID)%></h3>

                <table id="datatableRepasses" class="table table-striped table-bordered table-condensed table-hover">
                    <thead>
                        <tr>
                            <th width="1%" class="colContaCredito">
                                <span class="checkbox-customX">
                                    <input type="checkbox" data-account="<%=ContaCredito%>" class="checkAll" /><label for="checkAll"></label>
                                </span>
                            </th>
                            <th class="colTh" name-col="colDataExec">Data Exec.</th>
                            <th class="colTh" name-col="colDataComp">Data Comp.</th>
                            <th class="colTh" name-col="colPaciente">Paciente</th>
                            <th class="colTh" name-col="colDescricao">Descrição</th>
                            <th class="colTh" name-col="colFuncao">Função</th>
                            <th class="colTh" name-col="colConvenio">Convênio</th>
                            <th class="colTh" name-col="colForma">Forma</th>
                            <th class="colTh" name-col="colParcelas">Parcelas</th>
                            <th class="colTh" name-col="colValorTotalServ">Valor do Procedimento</th>
                            <th class="colTh" name-col="colValorParcela">Valor Total do Pagamento</th>
                            <th class="colTh" name-col="colRepasse">Repasse</th>
                            <th width="1%"><i class="far fa-remove"></i></th>
                        </tr>
                    </thead>
                    <tbody>
                <%
                while not rr.eof
                    DataExecucao = rr("DataExecucao")
                    Descricao = rr("NomeProcedimento")
                    Pagador = rr("NomePaciente")
                    DateToReceive = rr("DateToReceive")
                    if rr("Tipo")="ItemInvoiceID" then
                        FormaRecto = "Particular"
                    else
                        FormaRecto = rr("NomeConvenio")
                    end if

                    ValorProcedimento = rr("ValorProcedimento")
                    ValorParcela = rr("ParcelaValor")

                    Forma = rr("PaymentMethod")
                    Parcelas = rr("Parcelas")
                    if Parcelas&""="" then
                        Parcelas=1
                    end if
                    aLink = ""
                    fLink = ""
                    Status = reqf("Status")
                    NomeTabela = rr("NomeTabela")

                    Exibe = 0
                    if Status="" then
                        Exibe = 1
                    else
                        if instr(Status, "|NR|")>0 and rr("Tipo")="ItemInvoiceID" and isnull(rr("PaymentMethodID")) then
                            Exibe = 1
                        elseif instr(Status, "|RC|")>0 and rr("Tipo")="ItemInvoiceID" and (rr("PaymentMethodID")=1 or rr("PaymentMethodID")=3 or rr("PaymentMethodID")=5 or rr("PaymentMethodID")=6 or rr("PaymentMethodID")=7) then
                            Exibe = 1
                        elseif instr(Status, "|RC|")>0 and rr("Tipo")="ItemInvoiceID" and (rr("PaymentMethodID")=8 or rr("PaymentMethodID")=9) then
                            'set vcBaixado = db.execute("")
                        elseif instr(Status, "|RC|")>0 and rr("Tipo")="ItemInvoiceID" and (rr("PaymentMethodID")=12 or rr("PaymentMethodID")=13) then
                            Exibe = 1
                        end if
                    end if
                    DataComp = ""


                    if Exibe=1 then
                        ValorRepasse = fn(calculaRepasse(rr("id"), rr("Sobre"), rr("ValorProcedimento"), rr("Valor"), rr("TipoValor")))


                        if not isnull(rr("ItemInvoiceID")) then
                            aLink = "<a target='_blank' href='./?P=invoice&Pers=1&I="& rr("InvoiceID") &"'>"
                            fLink = "</a>"
                        end if
                        if rr("PaymentMethodID")=1 or rr("PaymentMethodID")=7 or rr("PaymentMethodID")=3 or rr("PaymentMethodID")=12 or rr("PaymentMethodID")=13 then
                            DataComp = rr("DataPagto")
                        elseif rr("PaymentMethodID")=8 or rr("PaymentMethodID")=9 then
                            DataComp = DateToReceive
                        elseif rr("PaymentMethodID")=2 then
                            DataComp = rr("DataCompenscaoCheque")
                        else
                            DataComp = rr("DataPagtoConvenio")
                        end if

                        DataOk = True
                        if TipoData="Comp" then
                            if DataComp&""="" then
                                DataOk=False
                            end if

                            if DataOk then
                                if cdate(DataComp) < cdate(De) or cdate(DataComp) > cdate(Ate) then
                                    DataOk=False
                                end if
                            end if
                        end if


                        if NomeTabela<>"" then
                            NomeTabela = "<i class='far fa-table' title='"& NomeTabela &"'></i>"
                        end if

                        ExibeCheckbox = False

                        if rr("Executado") <> "C" then
                            ExibeCheckbox= True
                        else
                            TextoOcultarCheckbox= "Cancelado"
                        end if

                        if rr("IntegracaoSPLIT") = "S" then
                            set SplitStatusSQL = db_execute("SELECT SplitStatus FROM stone_splits WHERE MovementID="&treatvalzero(rr("IDMovPay")))

                            if not SplitStatusSQL.eof then
                                if SplitStatusSQL("SplitStatus")<>"rejected" then
                                    ExibeCheckbox= False
                                    TextoOcultarCheckbox= "Split"
                                end if
                            end if
                        end if


                        if DataOk then
                            ContaRepasses = ContaRepasses+1
                            TotalRepasse = TotalRepasse+ValorRepasse
                            TotalProcedimento = TotalProcedimento+ValorParcela
                        %>
                        <tr invoiceapagarid="<%=rr("InvoiceAPagarID")%>">
                            <td>
                                <code style="display:none;">#<%= rr("IDMovPay") %></code>
                                <% if rr("ItemContaAPagar")>0 then %>
                                    <a href="./?P=invoice&Pers=1&I=<%= rr("InvoiceAPagarID") %>" target="_blank" class="btn btn-xs btn-default" type="button"><i class="far fa-sign-out text-alert"></i></a>
                                <% elseif rr("ItemContaAReceber")>0 then
                                    set InvoiceReceberSQL = db_execute("SELECT InvoiceID FROM itensinvoice WHERE id="&rr("ItemContaAReceber"))
                                    if not InvoiceReceberSQL.eof then
                                        InvoiceAReceberID=InvoiceReceberSQL("InvoiceID")
                                    end if
                                %>
                                    <a href="./?P=invoice&Pers=1&I=<%= InvoiceAReceberID %>" target="_blank" class="btn btn-xs btn-default" type="button"><i class="far fa-sign-in text-system"></i></a>
                                <% elseif rr("CreditoID")>0 then %>
                                <a href="javascript:repassesCredito(<%= rr("CreditoID") %>)" class="btn btn-xs btn-default"><i class="far fa-search text-system"></i></a>
                                <% else %>
                                    <% if ExibeCheckbox then %>
                                        <input type="checkbox" data-account="<%=ContaCredito%>" name="Repasses" value="<%= rr("id") &"|"& ValorRepasse %>" />
                                    <% else %>
                                    <span class="label label-warning"><%=TextoOcultarCheckbox%></span>
                                    <% end if %>
                                <% end if %>

                            </td>
                            <td name-col="colDataExec"><%= DataExecucao %></td>
                            <td name-col="colDataComp"><%= DataComp %></td>
                            <td name-col="colPaciente"><%= Pagador %></td>
                            <td name-col="colDescricao"><%= aLink & Descricao & fLink %></td>
                            <td name-col="colFuncao"><%= rr("Funcao") %></td>
                            <td name-col="colConvenio"><%= NomeTabela &" " & FormaRecto %></td>
                            <td name-col="colForma"><%= Forma %></td>
                            <td name-col="colParcelas"><%= Parcelas %></td>
                            <td class="text-right" name-col="colValorTotalServ"><%= fn(ValorProcedimento) %></td>
                            <td class="text-right" name-col="colValorParcela"><%= fn(ValorParcela) %></td>
                            <td class="text-right" name-col="colRepasse"><%= ValorRepasse %></td>
                            <td>
                                <% if isnull(rr("ItemContaAPagar")) and aut("|repassesX|")=1 then %>
                                    <button onclick="x(<%= rr("id") %>)" class="btn btn-xs btn-danger"><i class="far fa-remove"></i></button>
                                <% end if %>
                            </td>
                        </tr>
                        <%
                        end if
                    end if
                rr.movenext
                wend
                rr.close
                set rr=nothing
                %>
                    </tbody>
                    <tfoot>
                        <tr>
                            <td colspan="10" class="colsPan"><%= ContaRepasses %> repasses encontrados.</td>
                            <td class="text-right"  name-col="colValorParcela" ><%= fn(TotalProcedimento) %></td>
                            <td class="text-right"  name-col="colRepasse"><%= fn(TotalRepasse) %></td>
                        </tr>
                    </tfoot>
                </table>

                <%
                TemRepasse=1
                end if

            end if
            %>
        <%
        ProfissionalSQL.movenext
        wend
        ProfissionalSQL.close
        set ProfissionalSQL=nothing
        end if

        if TemRepasse = 0 and reqf("Forma")<>"" then

                    %>
<div class="alert alert-default">
    <strong>Atenção!</strong> Nenhum repasse consolidado foi encontrado para os filtros selecionados.
</div>
                    <%
        end if
        %>
    </div>
</div>
<form style="display: none;" id="lancaRepasses">
<input type="hidden" id="APagarVlr" name="vlr">
<input type="hidden" id="APagarRps" name="rps">
</form>


<script type="text/javascript">
$("input[name=Repasses], .checkAll").change(function(){
	$.ajax({
		type:"POST",
		url:"calculaRepasse.asp?ContaCredito=<%=reqf("ContaCredito")%>&modoCalculo=<%=modoCalculo%>",
		data:$("input[name=Repasses]").serialize(),
		success: function(data){
			$("#calculaRepasses").html(data);
		}
	});
});

$(".checkAll").click(function(){
    var ContaCredito = $(this).data("account");

	if($(this).prop("checked")==true){
		$("input[name=Repasses][data-account='"+ContaCredito+"']").prop("checked", "checked");
	}else{
		$("input[name=Repasses][data-account='"+ContaCredito+"']").removeAttr("checked");
	}
});
var $btnLancaConta = $(".btn-lanca-conta");

function lancaRepasses(rps, vlr, cc, tipo){
    $btnLancaConta.attr("disabled", true);
	$("#calculaRepasses").html("Lan&ccedil;ando repasses no contas a pagar...");
	$("#APagarVlr").val(vlr);
	$("#APagarRps").val(rps);

	$.ajax({
		type:"POST",
		url:"calculaRepasse.asp?cc="+ cc +"&tipo="+ tipo,
		data:$("input[name=Repasses], #buscaRepasses, #lancaRepasses").serialize(),
		success: function(data){
            $btnLancaConta.attr("disabled", false);
			eval(data);
		}
	});
}

function x(I){
	if(confirm('Tem certeza de que deseja excluir este repasse?')){
		location.href='./?<%=request.QueryString()%>&X='+I;
	}
}

function consolida(){
    $.post("repasseConsolida.asp", $("input[name=linhaRepasse]:checked, input[type=hidden]").serialize(), function(data){
        eval(data);
    });
}

function repassesCredito(I){
    $("#modal-table").modal("show");
    $.get("repassesCredito.asp?I="+I, function(data){
        $("#modal").html(data);
    });
}

function openSelectCols(){
	let cols = {};
	$(".colTh").each((a,b) => {
		 let nameCol = $(b).attr("name-col")
		 let text    = $(b).text()
		 let checked = $(b).is(':visible')

		 cols[nameCol] = {nameCol,text,checked};
	})

	let html = Object.keys(cols).map((item) => {
		return `<div class="checkbox-custom checkbox-warning">
					<input onchange="toggleCol(this.checked,'${cols[item].nameCol}')" ${cols[item].checked?'checked':''} type="checkbox" name="${cols[item].nameCol}" id="${cols[item].nameCol}" value="I"><label for="${cols[item].nameCol}"> ${cols[item].text}</label>
				</div>`
	}).join("\n");
	openModal(`<div>
		  ${html}
		  </div>`,"Selecione as colunas que deseja exibir:",false,true
	);

}

function toggleCol(isChecked,colName){
    if(isChecked){
        $(`[name-col='${colName}']`).show();
    }else{
        $(`[name-col='${colName}']`).hide();
    }

	colSpanSum()
}

function colSpanSum(){

	let total = 1;

	$(".dataTables_wrapper:first .colTh:visible").each((a,b) => {
		 let nameCol = $(b).attr("name-col")
		 let checked = $(b).is(':visible')

		 if(!(['colValorParcela','colRepasse'].includes(nameCol))){
			total++;
		 }
	});

	$(".colsPan").attr("colspan",total)
}

$(document).ready( function () {
    $("#datatableRepasses").dataTable({
        bPaginate: false,
         bFilter: false,
         bInfo: false,
         bAutoWidth: false,
        blengthMenu: [[10, 50, 100, -1], [10, 50, 100, "Todos"]]
    });
} );

</script>