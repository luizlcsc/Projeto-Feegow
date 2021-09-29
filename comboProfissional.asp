<!--#include file="connect.asp"-->
<option value="0">Selecione</option>
<%
Especialidade = req("Especialidade")
ProcedimentoID = req("ProcedimentoID")

'select id, if(isnull(NomeSocial) or NomeSocial='', NomeProfissional, NomeSocial) NomeProfissional from profissionais where sysActive=1 and ativo='on' order by if(isnull(NomeSocial) or NomeSocial='', NomeProfissional, NomeSocial)
sql = "select p.id idProf, if(isnull(NomeSocial) or NomeSocial='', NomeProfissional, NomeSocial) NomeProfissional from profissionais p left join profissionaisespecialidades pe ON p.id = pe.ProfissionalID " 

if ProcedimentoID&"" <> "" and ProcedimentoID <> "0" then
    sql = sql & " inner join procedimentos ps ON (ps.somenteprofissionais LIKE CONCAT('|', p.id, '|') OR ps.somenteprofissionais LIKE '|ALL' OR ps.somenteprofissionais = '' OR ps.somenteprofissionais IS NULL )  "
end if
        
sql = sql & " where p.sysActive=1 and p.ativo='on' "

if Especialidade&"" <> "" and Especialidade <> "0" then
    sql = sql & " AND  p.EspecialidadeID = "& treatvalzero(Especialidade) 
end if

if ProcedimentoID&"" <> "" and ProcedimentoID <> "0" then
    sql = sql & " AND  ps.id = "& treatvalzero(ProcedimentoID) 
end if

sql = sql & " order by if(isnull(NomeSocial) or NomeSocial='', NomeProfissional, NomeSocial)"

set Executor = db.execute(sql)

while not Executor.eof
    %>
    <option value="<%=Executor("idProf")%>"><%=Executor("NomeProfissional")%></option>
    <%
Executor.movenext
wend
Executor.close
set Executor=nothing

%>