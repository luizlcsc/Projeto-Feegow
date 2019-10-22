<!--#include file="connect.asp"-->
<%
T = ref("T")
spl = split(T, "_")

Data = spl(0)
Data = right(Data, 4) &"-"& mid(Data, 3, 2) &"-"& left(Data, 2)
ProcedimentoID = spl(1)
ProfissionalID = spl(2)
PacienteID = spl(3)

set vcaFat = db.execute("select * from tempfaturamento where Data='"& Data &"' and ProcedimentoID="& ProcedimentoID &" and ProfissionalID="& ProfissionalID &" and PacienteID="& PacienteID &" and Situacao='Faturado'")
if not vcaFat.eof then
    db_execute("update atendimentos a LEFT JOIN atendimentosprocedimentos ap ON a.id=ap.AtendimentoID SET a.UnidadeID="& vcaFat("UnidadeID") &" WHERE a.PacienteID="& PacienteID &" and Data='"& Data &"' and ProfissionalID="& ProfissionalID &" and ap.ProcedimentoID="& ProcedimentoID)
    %>
    $("#<%= T %>").closest("tr").remove();
//    alert("Unidade do faturado: <%= vcaFat("UnidadeID") %> \n Unidade do não faturado: <%'= nf("UnidadeID") %>");
    <%
end if
%>