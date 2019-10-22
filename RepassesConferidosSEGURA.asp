<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Repasses Consolidados");
    $(".crumb-icon a span").attr("class", "fa fa-puzzle-piece");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("repasses previamente conferidos e consolidados");
    <%
    if aut("configrateio")=1 then
    %>
    $("#rbtns").html('<a class="btn btn-sm btn-success pull-right" href="./?P=Rateio&Pers=1"><i class="fa fa-puzzle-piece"></i><span class="menu-text"> Configurar Regras de Repasse</span></a>');
    <%
    end if
    %>
</script>
      
      
      
<%

Unidades = req("Unidades")
if Unidades="" then
    Unidades = "|"& session("UnidadeID") &"|"
end if

if req("X")<>"" then
    set LinhaRepasseSQL = db.execute("SELECT ItemInvoiceID,ItemGuiaID,GuiaConsultaID,ItemHonorarioID,ItemDescontadoID FROM rateiorateios WHERE id="&req("X"))
    if not LinhaRepasseSQL.eof then
	    'db_execute("delete from rateiorateios where id="&req("X"))
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
	response.Redirect("./?P=RepassesConferidosSEGURA&Pers=1&AccountID="&req("AccountID")&"&Forma="&req("Forma")&"&Lancado="&req("Lancado")&"&Status="&req("Status")&"&De="&req("De")&"&Ate="&req("Ate"))
end if

	
ContaCredito = req("AccountID")
FormaID = req("FormaID")
Lancado = req("Lancado")
De = req("De")
Ate = req("Ate")
if De="" or not isdate(De) then
	De = date()'dateadd("m", -1, date())
end if
if Ate="" or not isdate(Ate) then
	Ate = date()
end if
%>

    <form action="" id="buscaRepasses" name="buscaRepasses" method="get">
        <input type="hidden" name="P" value="RepassesConferidosSEGURA" />
        <input type="hidden" name="Pers" value="1" />
        <br />
        <div class="panel">
            <div class="panel-body hidden-print">
                <div class="row">
                    <%= quickfield("multiple", "Forma", "Convênio", 2, req("Forma"), "select '0' id, '     PARTICULAR' Forma UNION ALL select id, NomeConvenio from (select c.id, c.NomeConvenio from convenios c where c.sysActive=1 order by c.NomeConvenio) t ORDER BY Forma", "Forma", " required ") %>
                    <%= quickfield("multiple", "FormaRecto", "Forma de recto.", 2, req("FormaRecto"), "select id, PaymentMethod from cliniccentral.sys_financialpaymentmethod where TextC<>'' ORDER BY PaymentMethod", "PaymentMethod", "") %>
                    <%= quickfield("multiple", "Status", "Status de recto.", 2, req("Status"), "select 'RC' id, 'Recebido - Compensado' descricao UNION ALL select 'RN', 'Recebido - Não compensado' UNION ALL select 'NR', 'Não Recebidos'", "descricao", "") %>

                    <%= quickField("datepicker", "De", "Execução", 2, De, "", "", " placeholder='De' required='required'") %>
                    <%= quickField("datepicker", "Ate", "&nbsp;", 2, Ate, "", "", " placeholder='At&eacute;' required='required'") %>
                    <div class="col-md-2">
                        <label>Tipo de Data:</label><br />
                        <span class="radio-custom"><input type="radio" name="TipoData" value="Exec" <% if req("TipoData")="Exec" or req("TipoData")="" then response.write(" checked ") end if %> id="TDE" /><label for="TDE"> Execução</label></span>
                        <br />
                        <span class="radio-custom"><input type="radio" name="TipoData" value="Comp" <% if req("TipoData")="Comp" then response.write(" checked ") end if %> id="TDC" /><label for="TDC"> Compensação</label></span>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-1 pt20 checkbox-custom checkbox-warning">
                    <br>
                        <input type="checkbox" name="modoCalculo" id="modoCalculo" value="I" <% if req("modoCalculo")="I" then response.write(" checked ") end if %> /><label for="modoCalculo"> Invertido</label>
                    </div>
                    <div class="col-md-5" id="calculaRepasses">
                        <%server.Execute("calculaRepasse.asp")%>
                    </div>
                    <div class="col-md-2">
                        <%= quickfield("empresaMultiIgnore", "Unidades", "Unidades", 12, Unidades, "", "", "") %>
                    </div>
                    <div class="col-md-2">
                        <label>Conta Cr&eacute;dito</label><br />
                        <%
                            if session("Banco")="clinic105" or session("Banco")="clinic6118" then
                                call simpleSelectCurrentAccounts("AccountID", "00, 5, 8, 4, 2, 1", req("AccountID"), "") 
                            else
                                call simpleSelectCurrentAccounts("AccountID", "00, 5, 8, 4, 2, 1", req("AccountID"), " required")
                            end if
                        %>
                        <%'=selectInsertCA("Profissional", "AccountID", req("AccountID"), "5, 8, 2, 6", "", " required ", "")%>
                    </div>
                    <div class="col-md-1">
                        <label>&nbsp;</label><br />
                        <button class="btn btn-ms btn-primary"><i class="fa fa-search"></i> Buscar</button>
                    </div>
                     <div class="col-md-1">
                         <label>&nbsp;</label><br />
                         <button type="button" class="btn  btn-info" onclick="print()"><i class="fa fa-print"></i></button>
                     </div>
                </div>
            </div>
        </div>
    </form>

<div class="panel">
    <div class="panel-body">

<div class="alert alert-danger hidden">
    <strong>Atenção! </strong> Esta página está em manutenção. Tente novamente mais tarde.
</div>

    <%
ExibeResultado=True
if datediff("d", De, Ate)>122 then

    %>
<div class="alert alert-warning m10">
    <strong>Atenção!</strong> Escolha um período menor que 4 meses.
</div>
    <%
    ExibeResultado=False
end if

if ExibeResultado and req("De")<>"" then

    if req("AccountID")="" then
        set pContasRR = db.execute("select group_concat( distinct(rr.ContaCredito) separator ', ' ) ContasRR from rateiorateios rr where rr.ContaCredito like '%\_%' and rr.sysDate BETWEEN "& mydateNull(De) &" AND "& mydateNull(Ate) &" ")
        ContasRR = pContasRR("ContasRR")&""
        'response.write( ContasRR )
    else
        ContasRR = req("AccountID")
    end if



    spl = split( ContasRR , ", ")
    for i=0 to ubound(spl)
        ContaCredito = replace(spl(i), "|", "")
        NomeConta = accountName(NULL, spl(i))
        'response.write( ContaCredito )
    %>
        <h4><%= NomeConta %></h4>
        <table id="datatableRepasses<%= ContaCredito %>" class="table table-striped table-bordered table-condensed table-hover">
            <thead>
                <tr>
                    <th width="1%">
                        <span class="checkbox-customX">
                            <input type="checkbox" id="checkAll" /><label for="checkAll"></label>
                        </span>
                    </th>
                    <th>Data Exec.</th>
                    <th>Data Comp.</th>
                    <th>Paciente</th>
                    <th>Descrição</th>
                    <th>Função</th>
                    <th>Convênio</th>
                    <th>Forma</th>
                    <th>Valor Serv.</th>
                    <th>Repasse</th>
                    <th width="1%"><i class="fa fa-remove"></i></th>
                </tr>
            </thead>
            <tbody>
            <%
            TotalRepasse = 0
            TotalProcedimento = 0
            ContaRepasses = 0
            if ContaCredito<>"" then
            sql="select rr.*, ii.InvoiceID InvoiceAPagarID from rateiorateios rr LEFT JOIN itensinvoice ii ON ii.id=rr.ItemContaAPagar where rr.ContaCredito='"& ContaCredito &"' AND rr.sysDate BETWEEN "& mydateNull(De) &" AND "& mydateNull(Ate) &" ORDER BY sysDate"
                    'response.write(sql)
'                set rr = db.execute(sql)

                modoCalculo = req("modoCalculo")
                if modoCalculo="" then
                    modoCalculo = "N"
                end if

                Unidades = req("Unidades")
                if Unidades<>"" then
                    sqlUnidades = " AND t.UnidadeID IN ("& replace(Unidades, "|", "") &") "
                end if

                FormaRecto = replace(req("FormaRecto"),"|","")
                if FormaRecto<>"" then
                    sqlFormRecto=" AND pmdesc.id IN ("&FormaRecto&") "
                end if

'Response.End
                sqlRR = "select mdesc.PaymentMethodID, mdesc.Date DataPagto, ifnull(pmdesc.PaymentMethod, '-') PaymentMethod, t.*, iip.InvoiceID InvoiceAPagarID, c.NomeConvenio, proc.NomeProcedimento, pac.NomePaciente from	(	select i.CompanyUnitID UnidadeID, ifnull(tab.NomeTabela, '') NomeTabela, ii.InvoiceID, 'ItemInvoiceID' Tipo, ii.DataExecucao, '0' ConvenioID, ii.ItemID ProcedimentoID, i.AccountID PacienteID, (ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto)) ValorProcedimento, rrp.* FROM itensinvoice ii 	INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN tabelaparticular tab ON tab.id=i.TabelaID	INNER JOIN rateiorateios rrp ON rrp.ItemInvoiceID=ii.id	WHERE ii.Tipo='S' AND rrp.ContaCredito='"& ContaCredito &"' AND ii.DataExecucao BETWEEN "& mydateNull(De) &" AND "& mydateNull(Ate) &"		UNION ALL	SELECT gc.UnidadeID, '', NULL, 'GuiaConsultaID', gc.DataAtendimento, gc.ConvenioID, gc.ProcedimentoID, gc.PacienteID, gc.ValorProcedimento, rrgc.* FROM tissguiaconsulta gc 	INNER JOIN rateiorateios rrgc ON rrgc.GuiaConsultaID=gc.id	WHERE gc.DataAtendimento BETWEEN "& mydateNull(De) &" AND "& mydateNull(Ate) &"		UNION ALL	SELECT gs.UnidadeID, '', NULL, 'ItemGuiaID', gps.Data, gs.ConvenioID, gps.ProcedimentoID, gs.PacienteID, gps.ValorTotal, rrgps.* FROM tissprocedimentossadt gps 	INNER JOIN rateiorateios rrgps ON rrgps.ItemGuiaID=gps.id	INNER JOIN tissguiasadt gs ON gps.GuiaID=gs.id WHERE gps.`Data` BETWEEN  "& mydateNull(De) &" AND "& mydateNull(Ate) &"	) t LEFT JOIN itensinvoice iip ON (iip.id=t.ItemContaAPagar) LEFT JOIN pacientes pac ON pac.id=t.PacienteID LEFT JOIN convenios c ON c.id=t.ConvenioID LEFT JOIN procedimentos proc ON proc.id=t.ProcedimentoID "&_
                " LEFT JOIN itensdescontados idesc ON idesc.ItemID=t.ItemInvoiceID "&_
                " LEFT JOIN sys_financialmovement mdesc ON mdesc.id=idesc.PagamentoID "&_
                " LEFT JOIN sys_financialpaymentmethod pmdesc ON pmdesc.id=mdesc.PaymentMethodID "&_
                " WHERE (t.ContaCredito LIKE CONCAT('%_"& ContaCredito &"') or t.ContaCredito='"& ContaCredito &"') AND t.ConvenioID IN ("& replace(req("Forma"), "|", "") &") "&sqlFormRecto&" AND t.modoCalculo='"& modoCalculo &"' "& sqlUnidades &_
                " GROUP BY t.id ORDER BY t.DataExecucao, pac.NomePaciente, proc.NomeProcedimento"
                'response.write( sqlRR )
                set rr = db.execute( sqlRR )
                while not rr.eof
                    DataExecucao = rr("DataExecucao")
                    Descricao = rr("NomeProcedimento")
                    Pagador = rr("NomePaciente")
                    if rr("Tipo")="ItemInvoiceID" then
                        FormaRecto = "Particular"
                    else
                        FormaRecto = rr("NomeConvenio")
                    end if
                    Valor = rr("ValorProcedimento")
                    Forma = rr("PaymentMethod")
                    aLink = ""
                    fLink = ""
                    Status = req("Status")
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
                        end if
                    end if
                    DataComp = ""
                    

                    if Exibe=1 then
                        ValorRepasse = fn(calculaRepasse(rr("id"), rr("Sobre"), rr("ValorProcedimento"), rr("Valor"), rr("TipoValor")))
                        TotalRepasse = TotalRepasse+ValorRepasse
                        TotalProcedimento = TotalProcedimento+Valor
                        ContaRepasses = ContaRepasses+1
                        if not isnull(rr("ItemInvoiceID")) then
                            aLink = "<a target='_blank' href='./?P=invoice&Pers=1&I="& rr("InvoiceID") &"'>"
                            fLink = "</a>"
                        end if
                        if rr("PaymentMethodID")=1 or rr("PaymentMethodID")=7 or rr("PaymentMethodID")=3 then
                            DataComp = rr("DataPagto")
                        end if
                        if NomeTabela<>"" then
                            NomeTabela = "<i class='fa fa-table' title='"& NomeTabela &"'></i>"
                        end if
                        %>
                        <tr>
                            <td>
                                <% if rr("ItemContaAPagar")>0 then %>
                                    <a href="./?P=invoice&Pers=1&I=<%= rr("InvoiceAPagarID") %>" target="_blank" class="btn btn-xs btn-default" type="button"><i class="fa fa-sign-out text-alert"></i></a>
                                <% elseif rr("ItemContaAReceber")>0 then %>
                                    <a href="./?P=invoice&Pers=1&I=<%= rr("InvoiceAPagarID") %>" target="_blank" class="btn btn-xs btn-default" type="button"><i class="fa fa-sign-in text-system"></i></a>
                                <% elseif rr("CreditoID")>0 then %>
                                <a href="javascript:repassesCredito(<%= rr("CreditoID") %>)" class="btn btn-xs btn-default"><i class="fa fa-search text-system"></i></a>
                                <% else %>
                                    <input type="checkbox" name="Repasses" value="<%= rr("id") &"|"& ValorRepasse %>" />
                                <% end if %>
                            </td>
                            <td><%= DataExecucao %></td>
                            <td><%= DataComp %></td>
                            <td><%= Pagador %></td>
                            <td><%= aLink & Descricao & fLink %></td>
                            <td><%= rr("Funcao") %></td>
                            <td><%= NomeTabela &" " & FormaRecto %></td>
                            <td><%= Forma %></td>
                            <td class="text-right"><%= fn(Valor) %></td>
                            <td class="text-right"><%= ValorRepasse %></td>
                            <td>
                                <% if isnull(rr("ItemContaAPagar")) then %>
                                    <button onclick="x(<%= rr("id") %>)" class="btn btn-xs btn-danger"><i class="fa fa-remove"></i></button>
                                <% end if %>
                            </td>
                        </tr>
                        <%
                    end if
                rr.movenext
                wend
                rr.close
                set rr=nothing
            end if
            %>
            </tbody>
            <tfoot>
                <tr>
                    <td colspan="8"><%= ContaRepasses %> repasses encontrados.</td>
                    <td class="text-right"><%= fn(TotalProcedimento) %></td>
                    <td class="text-right"><%= fn(TotalRepasse) %></td>
                </tr>
            </tfoot>
        </table>
    <%
    next
end if
%>
    </div>
</div>
<form style="display: none;" id="lancaRepasses">
<input type="hidden" id="APagarVlr" name="vlr">
<input type="hidden" id="APagarRps" name="rps">
</form>


<script type="text/javascript">
$("input[name=Repasses], #checkAll").change(function(){
	$.ajax({
		type:"POST",
		url:"calculaRepasse.asp?ContaCredito=<%=req("ContaCredito")%>&modoCalculo=<%=modoCalculo%>",
		data:$("input[name=Repasses]").serialize(),
		success: function(data){
			$("#calculaRepasses").html(data);
		}
	});
});

$("#checkAll").click(function(){
	if($(this).prop("checked")==true){
		$("input[name=Repasses]").prop("checked", "checked");
	}else{
		$("input[name=Repasses]").removeAttr("checked");
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

$(document).ready( function () {
    $("#datatableRepasses").dataTable({
        bPaginate: false,
        blengthMenu: [[10, 50, 100, -1], [10, 50, 100, "Todos"]]
    });
} );

</script>