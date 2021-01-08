<!--#include file="connect.asp"-->
<%
    page = req("page")
    if page="" then
        page=0
    else
        page = ccur(page)-1
    end if
    set conta = db.execute("select count(id) total from pacientes where NomePaciente like '%"&req("q")&"%'")
%>
{
  "total_count": <%=conta("total") %>,
  "incomplete_results": false,
  "items": [
    <%
    set q = db.execute("select id, NomePaciente from pacientes where NomePaciente like '%"&req("q")&"%' order by (NomePaciente) limit "& page*30 &", 30")
    c = 0
    while not q.eof
        if c>0 then
            response.write(",")
        end if
        c=c+1
    %>
    {
      "id": <%=q("id") %>,
      "full_name": "<%=q("NomePaciente") %>"
    }
    <%
    q.movenext
    wend
    q.close
    set q=nothing
    %>
  ]
}
