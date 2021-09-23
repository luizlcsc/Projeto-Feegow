<!--#include file="connect.asp"-->
<%
De = cdate(01&"/"&month(date())&"/"&year(date()))
Ate = dateadd("m", 1, De)
Ate = dateadd("d", -1, Ate)

set min = db.execute("select concat('1/', month(min(Date)), '/', year(min(Date))) De from sys_financialmovement where not isnull(Date) and year(Date)>year(curdate())-5")
if min.eof then
    DeMin = cdate("01/01/"& year(date()))
else
    DeMin = cdate(min("De"))
end if
set max = db.execute("select concat('1/', month(max(Date)), '/', year(max(Date))) De from sys_financialmovement where not isnull(Date) and year(Date)<year(curdate())+2")
if max.eof then
    DeMax = cdate("01/01/"& year(date()))
else
    DeMax = cdate(max("De"))
end if
DeMax = cdate(dateadd("m", 12, DeMax))
%>
<form class="panel mt20" method="get" action="./PrintStatement.asp" target="_blank">
	<input type="hidden" name="R" value="fc">
    <div class="panel-heading">
        <h3 class="text-center">
            Fluxo de Caixa
        </h3>
    </div>
    <div class="panel-body">
        <div class="col-md-2 hidden">
            <label>Agrupar por:</label><br />
            <div class="radio-custom radio-primary"><input type="radio" name="Tipo" value="Diario" id="AgruparCategoria" checked /><label for="AgruparCategoria">Categoria</label></div>
            <div class="radio-custom radio-primary"><input type="radio" name="Tipo" value="Mensal" id="AgruparCentroCusto" /><label for="AgruparCentroCusto">Centro de Custo</label></div>
        </div>
        <%= quickfield("simpleSelect", "TipoFC", "Tipo", 2, "M", "select 'D' id, 'Diário' Descricao /*UNION select 'S', 'Semanal'*/ UNION select 'M', 'Mensal'", "Descricao", " no-select2 semVazio ") %>
        <%=quickfield("datepicker", "De", "De", 2, De, "", "", "")%>
        <%=quickfield("datepicker", "Ate", "Até", 2, Ate, "", "", "")%>
        <div class="col-md-2 pt25">
            <input type="checkbox" name="Previsto" value="S" checked> Mostrar previstos
        </div>
        <div class="col-md-2" id="qfdem">
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
        <div class="col-md-2" id="qfatem">
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
        <%=quickfield("empresa", "UnidadeID", "Unidade", 2, session("UnidadeID"), "", "", "")%>
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
            $("#qfde, #qfate").addClass("hidden");
            $("#qfdem, #qfatem").removeClass("hidden");


<!--#include file="jQueryFunctions.asp"-->
</script>
<%'= DeMin &" :: "& DeMax %>