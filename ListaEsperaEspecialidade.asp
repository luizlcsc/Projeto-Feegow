<!--#include file="connect.asp"-->

<%
ListaProfissionais = ListProID
if selectedPropf&"" <>""then
    ListaProfissionais = selectedPropf
end if

if req("ListaProfissionais")&""<>"" then
    ListaProfissionais = req("ListaProfissionais")
end if

if req("ProfissionalID")<>"" and req("ProfissionalID")<>"ALL"  then
    ListaProfissionais = req("ProfissionalID")
else
    if req("ProfissionalID")<>"ALL" then
        ListaProfissionais=session("idInTable")
    end if
end if

sql = "select t.id 'ProfissionalID',t.EspecialidadeID id, especialidade from (select id, EspecialidadeID from Profissionais union all select profissionalID, Especialidadeid from profissionaisespecialidades)t left join especialidades on especialidades.id = t.EspecialidadeID where t.id in("&ListaProfissionais&") group by t.EspecialidadeID"


set EspecialidadesSQL = db.execute(sql)
%>
<select name="EspecialidadeID" id="EspecialidadeID">
    <option value="" selected >Todas as especialidades</option>
    <%
    while not EspecialidadesSQL.eof

        if not isnull(EspecialidadesSQL("especialidade")) and EspecialidadesSQL("especialidade")&"" <> "" then
        %>
        <option value="<%=EspecialidadesSQL("id")%>"><%=EspecialidadesSQL("especialidade")%></option>
        <%
        end if
    EspecialidadesSQL.movenext
    wend
    EspecialidadesSQL.close
    set EspecialidadesSQL=nothing
    %>
</select>