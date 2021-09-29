<!--#include file="connect.asp"-->
<%
Data = req("Data")
ProfissionalID = req("ProfissionalID")
dataString = formatdatetime(Data, 1)

%>
<h3><%=dataString%></h3>

<div class="row">
    <div class="col-md-12">
        <a target="_blank" href="?P=Agenda-1&Pers=1&Data=<%=Data%>&ProfissionalID=<%=ProfissionalID%>" style="float: right;" class="btn btn-default">
            <i class="fa fa-calendar"></i> Abrir agenda completa
        </a>
    </div>
</div>

<div class="row mt20">
    <div class="col-md-12">
    <%
    Server.Execute("GradeAgenda-1.asp")
    %>
    </div>
</div>

<script >
$(".vazio").click(function() {
    closeComponentsModal();
})
</script>