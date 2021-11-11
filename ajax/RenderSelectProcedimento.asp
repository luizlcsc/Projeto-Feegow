<!--#include file="../connect.asp"-->
<%
GrupoID = req("GrupoID")



sqlGrupoID = ""
if GrupoID&"" <> "" and GrupoID&"" <> "0" then
    sqlGrupoID = " AND p.GrupoID="&treatvalzero(GrupoID)
end if


sql = " SELECT id, "&_
      " NomeProcedimento "&_
      " FROM procedimentos p "&_
      " WHERE sysActive=1 "&_
      " AND Ativo='on' " & sqlGrupoID & sqlProfissional &_
      " order by NomeProcedimento "

response.write(quickfield("simpleSelect", "bProcedimentoID", "Procedimento", 3, ProcedimentoID, sql, "NomeProcedimento", " "))
response.write("<script>$('#bProcedimentoID').select2();</script>")

%>
