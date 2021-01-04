<!--#include file="connect.asp"-->
<%
    exibir=req("exibir")
    if exibir<>"" then
        exibir = replace(exibir,"|","'")
        sqlExibir = " AND id IN ("&exibir&")"
    end if
    page = req("page")
    if page="" then
        page=0
    else
        page = ccur(page)-1
    end if
    set conta = db.execute("select count(id) total from "&req("t")&" where TRIM("&req("c")&") like '"&trim(req("q"))&"%'")
%>
{
  "total_count": <%=ccur(conta("total")) %>,
<%
if aut(lcase(ref("resource"))&"A")=1 then
    if lcase(req("t"))="pacientes" then
        if isnumeric(req("q")) and req("q")<>"" then
            sql = "select id, NomePaciente, Nascimento from pacientes where id like '%"&req("q")&"' or replace(replace(CPF,'.',''),'-','') like replace(replace('"&req("q")&"%','.',''),'-','') and sysActive=1 order by NomePaciente limit "& page*30 &", 30"
        elseif isdate(req("q")) and req("q")<>"" then
            DataNasc = mydatenull(req("q"))
            sql = "select id, NomePaciente, Nascimento from pacientes where Nascimento="& DataNasc &" and sysActive=1 order by NomePaciente limit "& page*30 &", 30"
        else
    	    sql = "select id, NomePaciente, Nascimento from pacientes where (NomePaciente) like '"&req("q")&"%' and sysActive=1  order by (case when NomePaciente like '"&req("q")&"%' then 1 else 2 end) , NomePaciente limit "& page*30 &", 30"
        end if
	    'campoSuperior???
	    ResourceID = 1
	    initialOrder = "NomePaciente"
	    tableName = "pacientes"
	    Pers = 1
	    mainFormColumn = ""
    else
        if instr(req("oti"), "agenda") then
            ProfissionalID = req("ProfissionalID")
            if ProfissionalID<>"" and isnumeric(ProfissionalID) and ProfissionalID<>"0" then
                set prof = db.execute("select EspecialidadeID from profissionais where not isnull(EspecialidadeID) and EspecialidadeID<>0 and id="& ProfissionalID)
                if not prof.eof then
                    EspecialidadeID = prof("EspecialidadeID")
                    sqlEsp = " or (opcoesagenda=4 and SomenteEspecialidades like '%|"& EspecialidadeID &"|%') "
                end if
                sqlProf = " or (opcoesagenda=4 and SomenteProfissionais like '%|"& ProfissionalID &"|%') "
            end if
            sql = "select id, NomeProcedimento from procedimentos where sysActive=1 and (NomeProcedimento like '%"&req("q")&"%' or Codigo like '%"&req("q")&"%') and Ativo='on' and (isnull(opcoesagenda) or opcoesagenda=0 or opcoesagenda=1 "& sqlProf & sqlEsp &") order by OpcoesAgenda desc, NomeProcedimento"
            initialOrder = "NomeProcedimento"
        else
    	    set dadosResource = db.execute("select * from cliniccentral.sys_resources where tableName like '"&req("t")&"'")
	        sql = replace(dadosResource("sqlSelectQuickSearch"), "[TYPED]", req("q"))
	        sql = replace(sql, "[campoSuperior]", req("cs"))
	        othersToAddSelectInsert = dadosResource("othersToAddSelectInsert")
	        ResourceID = dadosResource("id")
	        initialOrder = dadosResource("initialOrder")
	        tableName = dadosResource("tableName")
	        Pers = dadosResource("Pers")
	        mainFormColumn = dadosResource("mainFormColumn")


        end if

        if sqlExibir<>"" then
            sql = replace(sql, " order ",sqlExibir&" order ")
        end if
    end if
    if aut("|"&lcase(ref("resource"))&"I|") then
        %>
        "ins": "./?P=<%=tableName%>&Pers=<%=Pers%>",
        <%
    else
        %>
        "ins": false,
        <%
    end if
else
    %>
    "ins": false,
    <%
end if
%>
  "items": [
    <%
    set q = db.execute(sql)
    'set q = db.execute("select id, "&req("c")&" from "&req("t")&" where TRIM("&req("c")&") like '"&trim(req("q"))&"%' order by TRIM("&req("c")&") limit "& page*30 &", 30")
    c = 0

    if q.eof then
        %>
        {
          "id": -1,
          "permission":<%=aut("|"&lcase(req("t"))&"I|")%>,
          "full_name": "<%=replace(trim(req("q")), """", "\""") %>",
          "buscado": "<%=req("q") %>"
        }
        <%
    end if

    if instr(req("oti"),"empty") then
        %>
        {
          "id": " ",
          "full_name": "Selecione"
        },
        <%
    end if

    while not q.eof
        if c>0 then
            response.write(",")
        end if
        c=c+1

        Nascimento = ""
        if lcase(req("t"))="pacientes" then
            if q("Nascimento") <> "" then
                Nascimento = """birth"": "&""""&q("Nascimento")& ""","
            end if
        end if
    %>
    {
      "id": <%=q("id") %>,<%=Nascimento%>
      "full_name": "<%=replace(q(req("c")),"""","\""") %>"
    }
    <%
    q.movenext
    wend
    q.close
    set q=nothing
    %>
  ]
}
