<!--#include file="connect.asp"-->
<%
if req("De")="" then
	De=dateadd("m", -1, date())
else
	De=req("De")
end if
if req("Ate")="" then
	Ate=dateadd("m", 1, date())
else
	Ate=req("Ate")
end if
%>
<script type="text/javascript">
    $(".crumb-active a").html("Detalhamento da Fatura do Cartão de Crédito");
    $(".crumb-icon a span").attr("class", "far fa-credit-card");
</script>

<form id="frmCC" method="get">
    <input type="hidden" name="P" value="<%=req("P")%>">
    <input type="hidden" name="Pers" value="<%=req("Pers")%>">
    <br>
    <div class="panel ">
        <div class="panel-body">
            <%= quickField("simpleSelect", "Fatura", "Selecione a fatura", 4, req("Fatura"), "select Concat(ca.AccountName,' | ',i.Name) as 'Fatura', i.id from sys_financialinvoices i LEFT JOIN sys_financialcurrentaccounts ca ON ca.id = i.AccountID where i.Name like 'Fatura do cartão %' AND i.AssociationAccountID=1", "Fatura", " required") %>
            <div class="col-md-2">
                <label>&nbsp;</label><br>
                <button id="btnBuscar" class="btn btn-primary btn-block"><i class="far fa-search"></i> Buscar</button>
            </div>
        </div>
    </div>
</form>

<div class="panel">
    <div class="panel-body pn" id="resultado">
        <%server.Execute("DetalhamentoFaturaResultado.asp") %>
    </div>
</div>
<script type="text/javascript">
    $("#frmCC").submit(function () {
        $.post("DetalhamentoFaturaResultado.asp", $(this).serialize(), function (data) {
            $("#resultado").html(data);
        });
        return false;
    });
</script>