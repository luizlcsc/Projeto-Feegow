<!--#include file="connect.asp"-->


<%
DataDe = req("DataDe")
DataAte = req("DataAte")

%>
<h2 class="text-center">Produção por Convênio</h2>
<h5 class="text-center">Período - <%=DataDe%> até <%=DataAte%></h5>

<%
ProfissionalID = req("ProfissionalID")
ConvenioID = req("ConvenioID")
if ProfissionalID="" then
    erro = "Selecione ao menos um profissional."
end if
if ConvenioID="" then
    erro = "Selecione ao menos um convênio."
end if
if erro<>"" then
    %>
    <div class="alert alert-warning"><%=erro %></div>
    <%
else
    %>
    <table class="table">
    <%
    sql = "select p.id, p.NomeProfissional, t.Tratamento from profissionais p LEFT JOIN tratamento t on t.id=p.TratamentoID where p.id in("& ProfissionalID &") ORDER BY p.NomeProfissional"
    set profs = db.execute( sql )
    while not profs.eof
        UConvenio = "--"
        %>
        <tr class="warning"><td colspan="7"><h3 class="mn text-dark"><%=ucase(profs("Tratamento") &" "& profs("NomeProfissional")) %></h3></td></tr>
        <%
        sqlGC = "(SELECT c.NomeConvenio, p.NomePaciente, p.id Prontuario, proc.NomeProcedimento, gc.DataAtendimento Data, gc.NGuiaPrestador, gc.CodigoProcedimento, gc.ValorProcedimento ValorUnitario, '1' Quantidade, gc.ValorProcedimento ValorTotal FROM tissguiaconsulta gc LEFT JOIN convenios c ON c.id=gc.ConvenioID LEFT JOIN pacientes p ON p.id=gc.PacienteID LEFT JOIN procedimentos proc ON proc.id=gc.ProcedimentoID WHERE gc.ProfissionalID="&profs("id")&")"

        sqlGS = "(SELECT cs.NomeConvenio, ps.NomePaciente, ps.id Prontuario, igs.Descricao, igs.Data, gs.NGuiaPrestador, igs.CodigoProcedimento, igs.ValorUnitario, igs.Quantidade, igs.ValorTotal FROM tissguiasadt gs LEFT JOIN pacientes ps ON ps.id=gs.PacienteID LEFT JOIN convenios cs ON cs.id=gs.ConvenioID LEFT JOIN tissprocedimentossadt igs ON igs.GuiaID=gs.id)"

        set guias = db.execute("SELECT t.NomeConvenio, t.NomePaciente, t.Prontuario, t.NomeProcedimento, t.Data, t.NGuiaPrestador, t.CodigoProcedimento, t.ValorUnitario, t.Quantidade, t.ValorTotal FROM ("& sqlGC &" UNION ALL "& sqlGS &") t WHERE t.Data BETWEEN "& mydatenull(req("DataDe")) &" AND "& mydatenull(DataAte) &" ORDER BY t.NomeConvenio, t.Prontuario")
        while not guias.eof
            if UConvenio<>guias("NomeConvenio") then
            %>
            <tr class="success"><td colspan="7"><h4 class="mn text-dark"><%=ucase(guias("NomeConvenio")&"") %></h4></td></tr>
            <%
            end if
            if UPaciente<>guias("Prontuario") then %>
            <tr class="default"><td colspan="7"><h5 class="mn text-dark"><%=ucase(guias("NomePaciente")) %></h5></td></tr>
            <%end if %>
            <tr>
                <td><%=guias("Data") %></td>
                <td><%=guias("NGuiaPrestador") %></td>
                <td><%=guias("CodigoProcedimento") %></td>
                <td><%=guias("NomeProcedimento") %></td>
                <td><%=guias("ValorUnitario") %></td>
                <td><%=guias("Quantidade") %></td>
                <td><%=guias("ValorTotal") %></td>
            </tr>
            <%
            UPaciente = guias("Prontuario")
            UConvenio = guias("NomeConvenio")
        guias.movenext
        wend
        guias.close
        set guias=nothing
    profs.movenext
    wend
    profs.close
    set profs=nothing
    %>
    </table>
    <%
end if


'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! colocar pra escolher tipo de guia (consulta, sadt, honorarios)
%>