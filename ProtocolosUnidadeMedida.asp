<!--#include file="connect.asp"-->
<%
Tipo = req("T")
CampoID = req("ID")
Valor = req("Valor")
Sigla = ""

set getMedicamento = db.execute("SELECT un.Sigla FROM produtos p LEFT JOIN cliniccentral.unidademedida un ON p.UnidadePrescricao=un.id WHERE p.id="&Valor)
if not getMedicamento.eof then
    Sigla = getMedicamento("Sigla")
end if

if Tipo="M" then
    %>
    $("#QteDoseMedicamento_<%=CampoID%>").html('<%=Sigla%>')
    <%
end if

if Tipo="D" then
    %>
    $("#QteDiluenteMedicamento_<%=CampoID%>").html('<%=Sigla%>')
    <%
end if

if Tipo="R" then
    %>
    $("#QteReconstituinteMedicamento_<%=CampoID%>").html('<%=Sigla%>')
    <%
end if
%>