<!--#include file="connect.asp"-->

<h3>Guias Fora de Lote</h3>
<form method="post" target="_blank" action="PrintStatement.asp">
	<input type="hidden" name="R" value="rGuiasForaDeLote">
    <div class="row">
        <%= quickfield("datepicker", "De", "Preenchimento", 2, "", " input-mask-date ", "", " placeholder='De'") %>
        <%= quickfield("datepicker", "Ate", "&nbsp;", 2, "", " input-mask-date ", "", " placeholder='Até' ") %>
        <%= quickfield("simpleSelect", "AgruparPor", "Agrupar por", 3, "Convenio", "select 'ConvenioID' id, 'Convênio' AgruparPor UNION select 'DataAtendimento', 'Data de Atendimento' UNION select 'ProfissionalID', 'Profissional Executante'", "AgruparPor", " no-select2 semVazio ") %>
        <div class="col-md-2">
            <button class="btn btn-primary btn-block mt25">Gerar</button>
        </div>
    </div>
</form>

<script type="text/javascript">
    <!--#include file="JQueryFunctions.asp"-->
</script>