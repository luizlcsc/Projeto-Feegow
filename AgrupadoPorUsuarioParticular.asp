<!--#include file="connect.asp"-->
<%
DataDe = request.QueryString("DataDe")
DataAte = request.QueryString("DataAte")

if DataDe="" then
	DataDe = formatdatetime( 1&"/"&month(date())&"/"&year(date()), 2)
end if
if DataAte="" then
	DataAte = dateadd("m", 1, date())
	DataAte = 1&"/"&month(DataAte)&"/"&year(DataAte)
	DataAte = dateadd("d", -1, DataAte)
end if
%>
<h4>Lan&ccedil;amentos por Usu&aacute;rio - Particular</h4>
<form method="get" target="_blank" action="PrintStatement.asp">
	<input type="hidden" name="R" value="rAgrupadoPorUsuarioParticular">
    <div class="clearfix form-actions">
        <%=quickField("datepicker", "DataDe", "De", 3, DataDe, "", "", "")%>
        <%=quickField("datepicker", "DataAte", "At&eacute;", 3, DataAte, "", "", "")%>
        <div class="col-md-3">
            <label>&nbsp;</label><br>
            <button type="submit" class="btn btn-success"><i class="fa fa-search"></i> Buscar</button>
        </div>
    </div>
</form>
<script>
<!--#include file="jQueryFunctions.asp"-->
