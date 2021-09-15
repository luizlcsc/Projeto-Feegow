<!--#include file="connect.asp"-->
<form method="get" action="./PrintStatement.asp" target="_blank">
	<input type="hidden" name="R" value="rRelatorioCaixa">
    <div class="page-header">
        <h3 class="text-center">
            Relatório de Caixa
        </h3>
    </div>
    <div class="row">
        <div class="col-md-2 hidden">
            <label>Agrupar por:</label><br />
            <div class="radio-custom radio-primary"><input type="radio" name="Tipo" value="Diario" id="AgruparCategoria" checked /><label for="AgruparCategoria">Categoria</label></div>
            <div class="radio-custom radio-primary"><input type="radio" name="Tipo" value="Mensal" id="AgruparCentroCusto" /><label for="AgruparCentroCusto">Centro de Custo</label></div>
        </div>
        <%=quickfield("datepicker", "Data", "Data", 2, date(), "", "", "")%>
        <div class="col-md-2 hidden" id="qfdem">
            <label>De</label><br />
            <select name="DeM" class="form-control">
                <%
                De = DeMin
                while De<DeMax
                    %>
                    <option value="<%= De %>" <% if month(De)=month(date()) and year(De)=year(date()) then response.write(" selected ") end if %>><%= ucase(left(monthname(month(De)), 3)) &"/"& year(De) %></option>
                    <%
                    De = dateadd("m", 1, De)
                wend
                %>
            </select>
        </div>
        <div class="col-md-2 hidden" id="qfatem">
            <label>Até</label><br />
            <select name="AteM" class="form-control">
                <%
                De = DeMin
                while De<DeMax
                    %>
                    <option value="<%= De %>" <% if month(De)=month(date()) and year(De)=year(date()) then response.write(" selected ") end if %>><%= ucase(left(monthname(month(De)), 3)) &"/"& year(De) %></option>
                    <%
                    De = dateadd("m", 1, De)
                wend
                %>
            </select>
        </div>
        <%=quickfield("empresa", "UnidadeID", "Unidades", 4, session("UnidadeID"), "", "", "")%>
        <div class="col-md-3 pt25 checkbox-custom checkbox-success">
            <input type="checkbox" name="DetalharEntradas" value="S" id="DetalharEntradas" /><label for="DetalharEntradas">Detalhar entradas</label>
        </div>
        <div class="col-md-2">
            <label>&nbsp;</label>
            <br>
            <button class="btn btn-primary btn-block"><i class="far fa-chart"></i> Gerar</button>
        </div>
    </div>
</form>
<script type="text/javascript">
    $("#TipoFC").change(function () {
        if ($(this).val() == "D") {
            $("#qfdem, #qfatem").addClass("hidden");
            $("#qfde, #qfate").removeClass("hidden");
        } else {
            $("#qfde, #qfate").addClass("hidden");
            $("#qfdem, #qfatem").removeClass("hidden");
        }
    });

<!--#include file="jQueryFunctions.asp"-->
</script>
<%'= DeMin &" :: "& DeMax %>