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
    $(".crumb-active a").html("Faturas do Cartão de Crédito");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("administração das faturas de cartões");
    $(".crumb-icon a span").attr("class", "far fa-credit-card");
</script>

<form id="frmCC" method="get">
    <input type="hidden" name="P" value="<%=req("P")%>">
    <input type="hidden" name="Pers" value="<%=req("Pers")%>">
    <br>
    <div class="panel">
        <div class="panel-body">
            <%= quickField("simpleSelect", "Conta", "Selecione o cartão", 4, req("Conta"), "select * from sys_financialcurrentaccounts where AccountType in(5)", "AccountName", " required") %>
            <%= quickField("datepicker", "De", "De", 2, De, "", "", "") %>
            <%= quickField("datepicker", "Ate", "Até", 2, Ate, "", "", "") %>
            <div class="col-md-2">
                <label>&nbsp;</label><br>
                <button id="btnBuscar" class="btn btn-primary btn-block"><i class="far fa-search"></i> Buscar</button>
            </div>
        </div>
    </div>
</form>

<div class="panel">
    <div class="panel-body pn" id="resultado">
        <%server.Execute("FaturaCartaoResultado.asp") %>
    </div>
</div>
<script type="text/javascript">
    $("#frmCC").submit(function () {
        $.post("FaturaCartaoResultado.asp", $(this).serialize(), function (data) {
            $("#resultado").html(data);
        });
        return false;
    });
</script>