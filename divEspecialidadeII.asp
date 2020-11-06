<!--#include file="connect.asp"-->
<%

ProfissionalID = ref("ProfissionalID")
id = req("R")'id da row
executeLote = req("executeLote")'id da row

col = 2
if (req("C")<>"") then
    col = req("C")
end if

if(executeLote = "S") then
    ProfissionalIDItem = Split(ProfissionalID, ",")
    Row = Split(id, ",")
    todosId = req("R")'id da row
    %> totalVal = ""; <%
    for i = 0 to ubound(Row) 
        id = Row(i)
        if left(ProfissionalIDItem(i), 2)="5_" then
            ProfissionalID = replace(ProfissionalIDItem(i), "5_", "")
            sqlEsp = "select esp.EspecialidadeID id, e.especialidade from (select EspecialidadeID from profissionais where id="& ProfissionalID &" and not isnull(EspecialidadeID) union all	select EspecialidadeID from profissionaisespecialidades where profissionalID="& ProfissionalID &" and not isnull(EspecialidadeID)) esp left join especialidades e ON e.id=esp.EspecialidadeID"
            %>
            $("#divEspecialidadeID<%=id%>").html(`<%=quickField("simpleSelect", "EspecialidadeID"&id, "Especialidade", col, EspecialidadeID, sqlEsp, "especialidade", " no-select2 semVazio ")%>`)
            <%
        end if
        if id <> 0 then
            %>
                totalVal += $('#ItemID<%= id %>').val() + ",";
            <%
        end if
    next
    %>
        parametrosInvoice('<%=todosId%>', totalVal, 'S');
        // PRIMEIRO COLOCAR PRA PEGAR O VALOR CORRETO DESSA LINHA E DEPOIS -> calcRepasse(<%= id %>);
    <%
else 
    if left(ProfissionalID, 2)="5_" then
        ProfissionalID = replace(ProfissionalID, "5_", "")
        sqlEsp = "select esp.EspecialidadeID id, e.especialidade from (select EspecialidadeID from profissionais where id="& ProfissionalID &" and not isnull(EspecialidadeID) union all	select EspecialidadeID from profissionaisespecialidades where profissionalID="& ProfissionalID &" and not isnull(EspecialidadeID)) esp left join especialidades e ON e.id=esp.EspecialidadeID"

    end if

    if left(ProfissionalID, 2)="8_" then
        ProfissionalExternoID = replace(ProfissionalID, "8_", "")
        sqlEsp = "select e.id, e.especialidade FROM profissionalexterno p "&_
                 "INNER JOIN especialidades e ON e.id=p.EspecialidadeID "&_
                 "WHERE p.id="&ProfissionalExternoID

    end if


    if left(ProfissionalID, 2)="8_" then
        ProfissionalExternoID = replace(ProfissionalID, "8_", "")
        sqlEsp = "select e.id, e.especialidade FROM profissionalexterno p "&_
                 "INNER JOIN especialidades e ON e.id=p.EspecialidadeID "&_
                 "WHERE p.id="&ProfissionalExternoID

    end if


    if sqlEsp<>"" then
        set QtdEspecialidadesSQL = db.execute(sqlEsp)

        if not QtdEspecialidadesSQL.eof then
            call quickField("simpleSelect", "EspecialidadeID"&id, "Especialidade", col, EspecialidadeID, sqlEsp, "especialidade", " no-select2 semVazio ")

        %>
        <script type="text/javascript">
            parametrosInvoice('<%=id%>', $('#ItemID<%= id %>').val());
        // PRIMEIRO COLOCAR PRA PEGAR O VALOR CORRETO DESSA LINHA E DEPOIS -> calcRepasse(<%= id %>);
        </script>
    <%  end if 
        end if 
    end if 
    
    %>