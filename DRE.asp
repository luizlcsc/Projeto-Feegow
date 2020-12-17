<!--#include file="connect.asp"-->

<h3>DRE</h3>
<form method="post" target="_blank" action="PrintStatement.asp">
	<input type="hidden" name="R" value="rDREPers">
    <div class="row">
        <%'= quickfield("simpleSelect", "Exibicao", "Modo de Exibição", 2, "", "select 'm' id, 'Mensal' Exibicao UNION select 'a', 'Anual'", "Exibicao", " no-select2 semVazio") %>
        <%= quickfield("simpleSelect", "Exercicio", "Exercício", 2, year(date()), "select distinct year(sysDate) id, year(sysDate) Ano from sys_financialinvoices where not isnull(sysDate) and year(sysDate)<=year(curdate()) order by year(sysDate) desc", "Ano", " semVazio placeholder='Exercício'") %>
        <%= quickfield("simpleSelect", "ModeloID", "Modelo", 2, "1", "select * from dre_modelos where sysActive=1 ORDER BY NomeModelo", "NomeModelo", " semVazio ") %>
        <%=quickField("empresaMultiIgnore", "UnidadeID", "Unidade", 4, "|"& session("UnidadeID") &"|", " input-sm", "", "")%>
        <div class="col-md-2">
            <button class="btn btn-primary btn-block mt25">Gerar</button>
        </div>
    </div>
    <% if session("Admin")=1 then %>
    <hr class="short alt">
    <div class="row">
        <div class="col-md-12">
            <a target="_blank" href="./?P=dre_modelos&Pers=Follow">Gerenciar modelos de DRE</a>
        </div>
    </div>
    <% end if %>
</form>

<script type="text/javascript">
    <!--#include file="JQueryFunctions.asp"-->
</script>