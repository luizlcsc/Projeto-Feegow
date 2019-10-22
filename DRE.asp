<!--#include file="connect.asp"-->

<h3>DRE</h3>
<form method="post" target="_blank" action="PrintStatement.asp">
	<input type="hidden" name="R" value="rDRE">
    <div class="row">
        <%'= quickfield("simpleSelect", "Exibicao", "Modo de Exibição", 2, "", "select 'm' id, 'Mensal' Exibicao UNION select 'a', 'Anual'", "Exibicao", " no-select2 semVazio") %>
        <%= quickfield("simpleSelect", "Exibicao", "Modo de Exibição", 2, "", "select 'm' id, 'Mensal' Exibicao", "Exibicao", " no-select2 semVazio") %>
        <%= quickfield("multiple", "Exercicio", "Exercício", 2, "|"&year(date())&"|", "select distinct year(sysDate) id, year(sysDate) Ano from sys_financialinvoices where not isnull(sysDate) and year(sysDate)<=year(curdate()) order by year(sysDate)", "Ano", " placeholder='Exercício'") %>
        <div class="col-md-2">
            <button class="btn btn-primary btn-block mt25">Gerar</button>
        </div>
    </div>
</form>

<script type="text/javascript">
    <!--#include file="JQueryFunctions.asp"-->
</script>