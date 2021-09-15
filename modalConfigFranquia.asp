<!--#include file="connect.asp"-->
<%
Tipo = req("Tipo")
id = req("I")

ConnString43 = "Driver={MySQL ODBC 8.0 ANSI Driver};Server=dbfeegow01.cyux19yw7nw6.sa-east-1.rds.amazonaws.com;Database=cliniccentral;uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
Set db43 = Server.CreateObject("ADODB.Connection")
db43.Open ConnString43

ConnString45 = "Driver={MySQL ODBC 8.0 ANSI Driver};Server=dbfeegow02.cyux19yw7nw6.sa-east-1.rds.amazonaws.com;Database=cliniccentral;uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
Set db45 = Server.CreateObject("ADODB.Connection")
db45.Open ConnString45

ConnString34 = "Driver={MySQL ODBC 8.0 ANSI Driver};Server=dbfeegow03.cyux19yw7nw6.sa-east-1.rds.amazonaws.com;Database=cliniccentral;uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
Set db34 = Server.CreateObject("ADODB.Connection")
db34.Open ConnString34

if Tipo="I" then
    db43.execute("UPDATE cliniccentral.licencas SET SoftwareAnteriorID="&ref("SoftwareAnteriorID")&" WHERE id="&ref("I"))
    db45.execute("UPDATE cliniccentral.licencas SET SoftwareAnteriorID="&ref("SoftwareAnteriorID")&" WHERE id="&ref("I"))
    db34.execute("UPDATE cliniccentral.licencas SET SoftwareAnteriorID="&ref("SoftwareAnteriorID")&" WHERE id="&ref("I"))
else

%>
<div class="modal-header ">
    <div class="row">
        <div class="col-md-8">
            <h3 class="lighter blue">Condiguração da Licença</h3>
        </div>

        <div class="col-md-4" style="margin-top: 15px;">
            <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
        </div>
    </div>

</div>
<form method="post" id="frmConfigFranquia" name="frmConfigFranquia">
    <div class="modal-body">
        <div class="row">
            <%
            set soft = db.execute("SELECT SoftwareAnteriorID FROM cliniccentral.licencas WHERE id="&id)

            %>
            <input type="hidden" name="I" id="I" value="<%=id%>" />
            <input type="hidden" name="Tipo" id="Tipo" value="<%=Tipo%>" />
            <div class="col-md-12">
                <%=quickField("simpleSelect", "SoftwareAnteriorID", "Software Anterior", 4, soft("SoftwareAnteriorID"), "select * from cliniccentral.softwares", "Software", "")%>

            </div>

        </div>
        <br>
    </div>
    <div class="modal-footer no-margin-top">
        <button class="btn btn-sm btn-primary pull-right"><i class="far fa-save"></i> Salvar</button>
    </div>
</form>
<%end if%>


<script>

$("#frmConfigFranquia").submit(function(){
	$.post("modalConfigFranquia.asp?Tipo=I&I=<%=id%>", $(this).serialize(), function(data, status){ window.location.reload(); });
	return false;
});
</script>


<script type="text/javascript">

<!--#include file="JQueryFunctions.asp"-->
</script>
