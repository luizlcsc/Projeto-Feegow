<!--#include file="connect.asp"-->
<%

GrupoID = req("GrupoID")
set ProcedimentosSQL = db.execute("SELECT id, NomeProcedimento FROM procedimentos WHERE sysActive=1 AND Ativo='on' AND GrupoID="&treatvalzero(GrupoID))

while not ProcedimentosSQL.eof
    %>
    <option value="<%=ProcedimentosSQL("id")%>"><%=ProcedimentosSQL("NomeProcedimento")%></option>
    <%
ProcedimentosSQL.movenext
wend
ProcedimentosSQL.close
set ProcedimentosSQL=nothing

%>