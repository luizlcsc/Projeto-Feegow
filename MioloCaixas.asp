<%
if session("DateFrom")="" then
	session("DateFrom") = dateadd("m", -1, date())
end if
if session("DateTo")="" then
	session("DateTo") = date()
end if
%>

<form id="frmExtrato">
<br />
    <div class="panel hidden-print">
    <div class="panel-body">
        <div class="col-md-4">
            <label>Selecione o usuário</label><br>
            <%'= simpleSelectCurrentAccounts("Conta", "4, 5", Conta, " required","") %>
            <%= quickfield("simpleSelect", "Conta", "", 12, "", "select distinct concat(aa.id, '_', su.idInTable) id, lu.nome from caixa cx LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=cx.sysUser LEFT JOIN sys_users su ON su.id=lu.id LEFT JOIN cliniccentral.sys_financialaccountsassociation aa ON aa.table=su.table WHERE NOT lu.nome like '' ORDER BY lu.Nome", "nome", "") %>
        </div>
		<div class="col-md-5" id="listaCaixas">
        </div>
         <%
        if session("Unidades")<>"|0|" AND 1=2 then
        %>
        <%=quickfield("multiple", "Unidades", "Unidades", 4, "", "select * from sys_financialcompanyunits where sysActive", "UnitName", "")%>
<input type="hidden" value="<%=ref("AccountID")%>" name="StatementAccountID" id="StatementAccountID" />
        <%else%>
        <input type="hidden" name="Unidades" value="0">
        <%end if%>
            <div class="col-md-2"><label>&nbsp;</label><br />
                <button class="btn btn-sm btn-primary btn-block" id="Filtrate" name="Filtrate"><i class="far fa-search bigger-110"></i> Gerar</button>
            </div>
            <div class="col-md-1"><label>&nbsp;</label><br />
                <button class="btn btn-sm btn-info btn-block" type="button" onclick="print()"><i class="far fa-print bigger-110"></i></button>
            </div>
        </div>
    </div>
    <h1 class="hidden-screen visible-print">Caixa Diário</h1>
    <div class="panel">
        <div id="Extrato" class="panel-body">
            <center><em>Selecione acima o funcionário ou o profissional para visualizar seus caixas.</em></center>
        </div>
    </div>
</form>
<script>
$("#frmExtrato").submit(function(){
	$.post("ExtratoConteudo.asp?T=MeuCaixa", $("#frmExtrato").serialize(), function(data){ $("#Extrato").html(data) });
	return false;
});
$("#Conta").change(function(){
	$.post("listaCaixas.asp?Conta="+$(this).val(), $("#frmExtrato").serialize(), function(data){ $("#listaCaixas").html(data) });
});

<!--#include file="financialCommomScripts.asp"-->
</script>