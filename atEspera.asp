<!--#include file="connect.asp"-->
<%
'limpa não finalizados

PacienteID = req("PacienteID")
Atendimentos = replace(replace(req("Atendimentos"), "||", ", "), "|", "")
Acao = req("Acao")
Obs = req("O")
I = req("I")

if Acao="" then
    db.execute("delete from esperaprocedimentos where isnull(EsperaID) and sysUser="& session("User"))
elseif Acao="I" then
    db.execute("insert into esperaprocedimentos (ProcedimentoID, sysUser) values ("& I &", "& session("User") &")")
elseif Acao="X" then
    db.execute("delete from esperaprocedimentos where id="& I)
elseif Acao="A" then
    db.execute("update esperaprocedimentos set Obs='"& Obs &"' where id="& I)
elseif Acao="S" then
    db.execute("insert into espera set PacienteID="& PacienteID &", TempoAlerta="& treatvalnull(Obs) &", AtendimentoID=(select id from atendimentos where id in("& Atendimentos &") and PacienteID="& PacienteID &" limit 1), ProfissionalID="& session("idInTable") &", sysUser="& session("User"))
    set pult = db.execute("select id from espera where sysUser="& session("User") &" order by id desc limit 1")
    db.execute("update esperaprocedimentos set EsperaID="& pult("id") &" where isnull(EsperaID) and sysUser="& session("User"))
    db.execute("replace into staconsulta (id, StaConsulta) values (33, 'Em espera')")
    db.execute("update agendamentos set StaID="& 33 &" where id=(select AgendamentoID from atendimentos where id in("& Atendimentos &") and PacienteID="& PacienteID &" limit 1)")
    db.execute("update atendimentos set HoraFim=curtime() where id in("& Atendimentos &") and PacienteID="& PacienteID)
    splAt = split(Atendimentos, ", ")
    for i=0 to ubound(splAt)
        session("Atendimentos") = replace(session("Atendimentos"), "|"& splAt(i) &"|", "")
    next
    %>
    <script type="text/javascript">
        location.href = "./?P=ListaEspera&Pers=1&ProfissionalID=<%=session("idInTable")%>";
    </script>
    <%
    response.end
end if

set UltimaEsperaSQL = db.execute("SELECT TempoAlerta FROM espera WHERE sysUser="&session("User")&" ORDER BY id DESC LIMIT 1")
if not UltimaEsperaSQL.eof then
    UltimoAlertarEm=UltimaEsperaSQL("TempoAlerta")
else
    UltimoAlertarEm=15
end if
%>

<div class="panel" style="margin-bottom: 0px">
    <div class="panel-heading">
        <span class="panel-title">Colocar paciente em espera</span>
    </div>
    <div class="panel-body">
        <div class="row">
            <div class="col-md-12">
                <%= selectInsert("Adicionar itens a serem executados", "BuscaEspera", "", "procedimentos", "NomeProcedimento", " onchange=""acEspera('I', $(this).val())"" ", "", "") %>
            </div>
        </div>
        <hr class="short alt" />
        <div class="row">
            <div class="col-md-12">
                <%
                set vca = db.execute("select ep.*, p.NomeProcedimento from esperaprocedimentos ep LEFT JOIN procedimentos p ON p.id=ep.ProcedimentoID where isnull(ep.EsperaID) and ep.sysUser="& session("User"))
                if vca.eof then
                    %>
                    Nenhum item solicitado durante a espera.
                    <%
                else
                    %>
                    <table class="table table-condensed table-hover">
                        <thead>
                            <tr class="info">
                                <th>Procedimento</th>
                                <th width="40%">Observações</th>
                                <th width="1%"></th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            while not vca.eof
                                %>
                                <tr>
                                    <td><%= vca("NomeProcedimento") %></td>
                                    <td><%= quickfield("text", "ObsEsp"& vca("id"), "", 12, vca("Obs"), "", "", " onchange=""acEspera('A',"& vca("id") &", $(this).val())""") %></td>
                                    <td>
                                        <i class="btn btn-danger btn-xs far fa-remove" onclick="acEspera('X', <%= vca("id") %>)"></i>
                                    </td>
                                </tr>
                                <%
                            vca.movenext
                            wend
                            vca.close
                            set vca = nothing
                            %>
                        </tbody>
                    </table>
                    <%
                end if
                %>
            </div>
        </div>
    </div>
    <div class="panel-footer">
        <div class="row">
            <%= quickfield("text", "TempoAlerta", "Alertar em", 2, UltimoAlertarEm, "", "", " placeholder='minutos' ") %>
            <div class="col-md-10">
                <button class="btn btn-primary mt25 pull-right" onclick="acEspera('S', '', $('#TempoAlerta').val())"><i class=" far fa-pause"></i> Colocar em espera</button>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    function acEspera(A, I, O) {
        $.get("atEspera.asp?PacienteID=<%= PacienteID %>&Atendimentos=<%= session("Atendimentos")%>&Acao="+A+"&I="+I+"&O="+O, function (data) {
            $("#modal").html(data);
        });
    }
</script>