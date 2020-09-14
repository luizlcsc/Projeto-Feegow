<!--#include file="connect.asp"-->
<option value=""></option>
<%
CampoID = req("CampoID")
Grupo = req("Grupo")

set s = db.execute("SELECT id, trim(subgrupo) subgrupo FROM cliniccentral.tusscorrelacao WHERE subgrupo NOT LIKE '' AND Grupo LIKE '%"& Grupo &"%' GROUP BY subgrupo ORDER BY trim(subgrupo)")
while not s.eof
    %>
    <option value="<%= s("Subgrupo") %>"><%= s("Subgrupo") %></option>
    <%
s.movenext
wend
s.close
set s = nothing
%>