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
	response.Redirect("./?P=RepassesConferidos&Pers=1&AccountID="&req("AccountID")&"&Forma="&req("Forma")&"&Lancado="&req("Lancado")&"&Status="&req("Status")&"&De="&req("De")&"&Ate="&req("Ate"))
end if

	
ContaCredito = req("AccountID")
FormaID = req("FormaID")
Lancado = req("Lancado")
De = req("De")
Ate = req("Ate")
if De="" or not isdate(De) then
	De = dateadd("m", -1, date())
end if
if Ate="" or not isdate(Ate) then
	Ate = date()
end if
%>

    <form action="" id="buscaRepasses" name="buscaRepasses" method="get">
        <input type="hidden" name="P" value="RepassesConferidos" />
        <input type="hidden" name="Pers" value="1" />
        <br />
        <div class="panel">
            <div class="panel-body hidden-print">
                <div class="row">
                    <%= quickfield("multiple", "Forma", "Forma", 3, req("Forma"), "select '0' id, '     PARTICULAR' Forma UNION ALL select id, NomeConvenio from (select c.id, c.NomeConvenio from convenios c where c.sysActive=1 order by c.NomeConvenio) t ORDER BY Forma", "Forma", " required ") %>
                    <div class="col-md-3">
                        <label>Conta Cr&eacute;dito</label><br />
                        <%= simpleSelectCurrentAccounts("AccountID", "00, 5, 8, 4, 2, 1", req("AccountID"), " required") %>
                        <%'=selectInsertCA("Profissional", "AccountID", req("AccountID"), "5, 8, 2, 6", "", " required ", "")%>
                    </div>
                    <%= quickField("datepicker", "De", "Execução", 2, De, "", "", " placeholder='De' required='required'") %>
                    <%= quickField("datepicker", "Ate", "&nbsp;", 2, Ate, "", "", " placeholder='At&eacute;' required='required'") %>
                    <div class="col-md-2">
                        <label>&nbsp;</label><br />
                        <button class="btn btn-primary btn-block"><i class="fa fa-search"></i>Buscar</button>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-6" id="calculaRepasses">
                        <%server.Execute("calculaRepasse.asp")%>
                    </div>
                </div>
            </div>
        </div>
    </form>

<div class="panel">
    <div class="panel-body">
        <table class="table table-striped table-bordered table-condensed table-hover">
            <thead>
                <tr>
                    <th width="1%">
                        <span class="checkbox-customX">
                            <input type="checkbox" id="checkAll" /><label for="checkAll"></label>
                        </span>
                    </th>
                    <th>Data Exec.</th>
                    <th>Paciente</th>
                    <th>Descrição</th>
                    <th>Função</th>
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
'                set rr = db.execute("select rr.*, ii.InvoiceID InvoiceAPagarID from rateiorateios rr LEFT JOIN itensinvoice ii ON ii.id=rr.ItemContaAPagar where rr.ContaCredito='"& ContaCredito &"' AND rr.sysDate BETWEEN "& mydateNull(De) &" AND "& mydateNull(Ate) &" ORDER BY sysDate")

                sqlRR = "select t.*, iip.InvoiceID InvoiceAPagarID, c.NomeConvenio, proc.NomeProcedimento, pac.NomePaciente from	(	select 'ItemInvoiceID' Tipo, ii.DataExecucao, '0' ConvenioID, ii.ItemID ProcedimentoID, i.AccountID PacienteID, (ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto)) ValorProcedimento, rrp.* FROM itensinvoice ii 	LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID	INNER JOIN rateiorateios rrp ON rrp.ItemInvoiceID=ii.id	WHERE ii.Tipo='S' AND ii.DataExecucao BETWEEN "& mydateNull(De) &" AND "& mydateNull(Ate) &"		UNION ALL	SELECT 'GuiaConsultaID', gc.DataAtendimento, gc.ConvenioID, gc.ProcedimentoID, gc.PacienteID, gc.ValorProcedimento, rrgc.* FROM tissguiaconsulta gc 	INNER JOIN rateiorateios rrgc ON rrgc.GuiaConsultaID=gc.id	WHERE gc.DataAtendimento BETWEEN "& mydateNull(De) &" AND "& mydateNull(Ate) &"		UNION ALL	SELECT 'ItemGuiaID', gps.Data, gs.ConvenioID, gps.ProcedimentoID, gs.PacienteID, gps.ValorTotal, rrgps.* FROM tissprocedimentossadt gps 	INNER JOIN rateiorateios rrgps ON rrgps.ItemGuiaID=gps.id	LEFT JOIN tissguiasadt gs ON gps.GuiaID=gs.id WHERE gps.`Data` BETWEEN  "& mydateNull(De) &" AND "& mydateNull(Ate) &"	) t LEFT JOIN itensinvoice iip ON iip.id=t.ItemContaAPagar LEFT JOIN pacientes pac ON pac.id=t.PacienteID LEFT JOIN convenios c ON c.id=t.ConvenioID LEFT JOIN procedimentos proc ON proc.id=t.ProcedimentoID WHERE (t.ContaCredito LIKE CONCAT('%_"& ContaCredito &"') or t.ContaCredito='"& ContaCredito &"') AND t.ConvenioID IN ("& replace(req("Forma"), "|", "") &") ORDER BY t.DataExecucao, pac.NomePaciente, proc.NomeProcedimento"
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
                    ValorRepasse = fn(calculaRepasse(rr("id"), rr("Sobre"), rr("ValorProcedimento"), rr("Valor"), rr("TipoValor")))
                    TotalRepasse = TotalRepasse+ValorRepasse
                    TotalProcedimento = TotalProcedimento+Valor
                    ContaRepasses = ContaRepasses+1
                    %>
                    <tr>
                        <td>
                            <% if isnull(rr("InvoiceAPagarID")) then %>
                                <input type="checkbox" name="Repasses" value="<%= rr("id") &"|"& ValorRepasse %>" />
                            <% else %>
                            <a href="./?P=invoice&Pers=1&I=<%= rr("InvoiceAPagarID") %>" target="_blank" class="btn btn-xs btn-default" type="button"><i class="fa fa-external-link"></i></a>
                            <% end if %>
                        </td>
                        <td><%= DataExecucao %></td>
                        <td><%= Pagador %></td>
                        <td><%= Descricao %></td>
                        <td><%= rr("Funcao") %></td>
                        <td><%= FormaRecto %></td>
                        <td class="text-right"><%= fn(Valor) %></td>
                        <td class="text-right"><%= ValorRepasse %></td>
                        <td>
                            <% if isnull(rr("ItemContaAPagar")) then %>
                                <button onclick="x(<%= rr("id") %>)" class="btn btn-xs btn-danger"><i class="fa fa-remove"></i></button>
                            <% end if %>
                        </td>
                    </tr>
                    <%
                rr.movenext
                wend
                rr.close
                set rr=nothing
            end if
            %>
            </tbody>
            <tfoot>
                <tr>
                    <td colspan="6"><%= ContaRepasses %> repasses encontrados.</td>
                    <td class="text-right"><%= fn(TotalProcedimento) %></td>
                    <td class="text-right"><%= fn(TotalRepasse) %></td>
                </tr>
            </tfoot>
        </table>
    </div>
</div>


<script type="text/javascript">
$("input[name=Repasses], #checkAll").change(function(){
	$.ajax({
		type:"POST",
		url:"calculaRepasse.asp?ContaCredito=<%=request.QueryString("ContaCredito")%>",
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

function lancaRepasses(rps, vlr, cc){
    $btnLancaConta.attr("disabled", true);
	$("#calculaRepasses").html("Lan&ccedil;ando repasses no contas a pagar...");
	$.ajax({
		type:"POST",
		url:"calculaRepasse.asp?rps="+rps+"&vlr="+vlr+"&cc="+cc,
		data:$("input[name=Repasses], #buscaRepasses").serialize(),
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


</script>