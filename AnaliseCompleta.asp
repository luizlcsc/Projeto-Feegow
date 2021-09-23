<!--#include file="connect.asp"-->
<form method="get" action="./PrintStatement.asp" target="_blank">
	<input type="hidden" name="R" value="rAnaliseCompleta">
    <div class="page-header">
        <h3 class="text-center">
            Análise Completa
        </h3>
    </div>
    <div class="row">
        <%=quickfield("datepicker", "Data", "Data", 2, date(), "", "", "")%>
        <%'=quickfield("simpleCheckbox", "UsarDataMensal", "Utilizar data mensal", 3, "", "", "", "")%>
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
        <%=quickfield("empresa", "U", "Unidade", 4, session("UnidadeID"), "", "", "")%>
        <div class="col-md-2">
            <label>&nbsp;</label>
            <br>
            <button class="btn btn-primary btn-block"><i class="far fa-chart"></i> Gerar</button>
        </div>
    </div>
    <hr class="short alt" />
    <div class="alert alert-info"><i class="far fa-info-circle"></i> Para emissão correta deste relatório, certifique-se de que todos os repasses de serviços executados na data selecionada estão devidamente consolidados.</div>
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