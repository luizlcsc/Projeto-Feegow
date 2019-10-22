<!--#include file="connect.asp"-->
<%
FormID = req("FormID")


set CamposSQL = db.execute("SELECT * FROM buicamposforms WHERE FormID="&FormID&" AND TipoCampoID=2")

CamposExibir=""

while not CamposSQL.eof
    %>
    <%=quickField("datepicker", "DataDe"&CamposSQL("id"), "Data inicio ("&CamposSQL("RotuloCampo")&")", 3, "", " input-mask-date ", "", "")%>
    <%=quickField("datepicker", "DataAte"&CamposSQL("id"), "Data fim ("&CamposSQL("RotuloCampo")&")", 3, "", " input-mask-date ", "", "")%>
    <%
    CamposExibir = CamposExibir&",|"&CamposSQL("id")&"|"
CamposSQL.movenext
wend
CamposSQL.close
set CamposSQL=nothing

campos = "0"
set CarmposForm = db.execute("SELECT GROUP_CONCAT(COLUMN_NAME SEPARATOR ', ') ColunasNome FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='"&session("Banco")&"' AND TABLE_NAME = '_"&FormID&"' ;")
if not CarmposForm.eof then
    campos = CarmposForm("ColunasNome")

    camposSplit = split(campos, ", ")
    for i=0 to ubound(camposSplit)
        if not isnumeric(camposSplit(i)) then
            campos = replace(campos, camposSplit(i)&", ", "")
        end if
    next
    campos = replace(campos, "DHUp", "")

end if
%>
<%=quickField("multiple", "CamposExibir", "Campos a exibir", 3, CamposExibir, " SELECT * FROM buicamposforms WHERE FormID="&FormID&" AND id IN ("&campos&")", "RotuloCampo", "")%>
<%
%>
<script >
    $('.multisel').multiselect({
        includeSelectAllOption: true,
        enableFiltering: true,
        numberDisplayed: 1
    });
</script>