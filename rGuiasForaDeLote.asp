<!--#include file="connect.asp"-->
<% response.charset="utf-8" %>
<style type="text/css">
    .link {
        visibility:hidden;
    }
    td {
        font-size:9px;
    }
</style>
<h2 class="text-center">Guias Fora de Lote
</h2>

<%

De = ref("De")
Ate = ref("Ate")
AgruparPor = ref("AgruparPor")

if De<>"" then
    sqlDeGC = " AND DataAtendimento>="& mydatenull(De) &" "
    sqlDeGS = " AND gps.Data>="& mydatenull(De) &" "
    sqlDeGH = " AND gph.Data>="& mydatenull(De) &" "
end if
if Ate<>"" then
    sqlAteGC = " AND DataAtendimento<="& mydatenull(Ate) &" "
    sqlAteGS = " AND gps.Data<="& mydatenull(Ate) &" "
    sqlAteGH = " AND gph.Data<="& mydatenull(Ate) &" "
end if

if AgruparPor="ConvenioID" then
    OrderDist = " c.NomeConvenio "
    colH = "NomeConvenio"
elseif AgruparPor="DataAtendimento" then
    OrderDist = " t.DataAtendimento "
    colH = "DataAtendimento"
elseif AgruparPor="ProfissionalID" then
    OrderDist = "prof.NomeProfissional"
    colH = "NomeProfissional"
end if

    %>

    <table class="table table-hover table-condensed">
        <thead>
            <tr>
                <th>Atendimento</th>
                <th>Conv&ecric;nio</th>
                <th>N&deg; Guia</th>
                <th>Paciente</th>
                <th>Profissional</th>
                <th>Servi&ccedil;o</th>
            </tr>
        </thead>
        <tbody>
        <%
        set dist = db.execute("select t.id, t.DataAtendimento, t.NGuiaPrestador, t.ConvenioID, t.ProfissionalID, t.Tabela, pac.NomePaciente, c.NomeConvenio, prof.NomeProfissional, proc.NomeProcedimento from ("&_
        "select id, DataAtendimento, NGuiaPrestador, PacienteID, ConvenioID, ifnull(ProfissionalEfetivoID, ProfissionalID) ProfissionalID, ProcedimentoID, 'guiaconsulta' Tabela from tissguiaconsulta where LoteID=0 " & sqlDeGC & sqlAteGC &_
        "UNION ALL select gs.id, gps.Data, gs.NGuiaPrestador, gs.PacienteID, gs.ConvenioID, gps.ProfissionalID, gps.ProcedimentoID, 'guiasadt' from tissguiasadt gs LEFT JOIN tissprocedimentossadt gps ON gps.GuiaID=gs.id where gs.LoteID=0 " & sqlDeGS & sqlAteGS &_
        "UNION ALL select gh.id, gph.Data, gh.NGuiaPrestador, gh.PacienteID, gh.ConvenioID, gph.ProfissionalID, gph.ProcedimentoID, 'guiahonorarios' from tissguiahonorarios gh LEFT JOIN tissprocedimentoshonorarios gph ON gph.GuiaID=gh.id where gh.LoteID=0 " & sqlDeGH & sqlAteGH &_
        ") t LEFT JOIN convenios c ON c.id=t.ConvenioID LEFT JOIN profissionais prof ON prof.id=t.ProfissionalID LEFT JOIN pacientes pac ON pac.id=t.PacienteID LEFT JOIN procedimentos proc ON proc.id=t.ProcedimentoID where not isnull(c.NomeConvenio) ORDER BY "& OrderDist )
        while not dist.eof
            %>
            <tr>
                <td><%= dist("DataAtendimento") %></td>
                <td><%= dist("NomeConvenio") %></td>
                <td>
                    <a target="_blank" class="btn btn-success btn-xs link" href="./?P=tiss<%= dist("Tabela") %>&Pers=1&I=<%= dist("id") %>"><i class="far fa-external-link"></i></a>
                    <%= dist("NGuiaPrestador") %></td>
                <td><%= dist("NomePaciente") %></td>
                <td><%= dist("NomeProfissional") %></td>
                <td><%= dist("NomeProcedimento") %></td>
            </tr>
            <%
        dist.movenext
        wend
        dist.close
        set dist = nothing
        %>
        </tbody>
    </table>
<script type="text/javascript">
    $("tr").on("mouseover", function () {
        $(this).find(".link").css("visibility", "unset");
    });
    $("tr").on("mouseout", function () {
        $(this).find(".link").css("visibility", "hidden");
    });
</script>