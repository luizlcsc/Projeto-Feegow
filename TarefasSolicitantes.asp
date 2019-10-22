<!--#include file="connect.asp"-->
<%
if ref("Solicitantes")="" then
    set sols = db.execute("select Solicitantes from tarefas WHERE id="& req("I"))
    Solicitantes = sols("Solicitantes")&""
else
    Solicitantes = ref("Solicitantes")
end if
if req("A")="I" then
    Solicitantes = Solicitantes & ",_"
end if
if instr(Solicitantes, "_")=0 then
    %>
        Não há solicitantes definidos para esta tarefa.
    <%
    else
        splSol = split(Solicitantes, ",")

        c = 0
        newSolicitantes = ""
        for i=0 to ubound(splSol)
            SolID = trim(splSol(i))
            SolID = replace(SolID, "|", "")
            if SolID="_" then
                SolID = "0"
                Aparece = 1
            elseif instr(SolID, "_")>0 then
                Aparece = 1
            else
                Aparece = 0
            end if
            if Aparece = 1 then
                c = c+1
                call selectInsertCA("Solicitante "& c, "Solicitante"& c, SolID, "5, 4, 3, 2, 6", "", "", "")
                newSolicitantes = newSolicitantes &", |"& SolID &"|"
            end if
        next
        if c>0 then
            newSolicitantes = right(newSolicitantes, len(newSolicitantes)-2)
        end if
end if
%>
