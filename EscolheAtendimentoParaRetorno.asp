<!--#include file="connect.asp"-->
<%
PacienteID = req("PacienteID")
ProcedimentoID = req("ProcedimentoID")
ProfissionalID = req("ProfissionalID")
EspecialidadeID = req("EspecialidadeID")
Data = req("Data")

set ProcedimentoSQL = db.execute("SELECT DiasRetorno FROM procedimentos WHERE id="&treatvalzero(ProcedimentoID))

%>
<div class="row">
<%
if not ProcedimentoSQL.eof then
    DiasRetorno = ProcedimentoSQL("DiasRetorno")
else
    set UltimoProcedimentoSQL = db.execute("SELECT proc.DiasRetorno FROM agendamentos a INNER JOIN procedimentos proc ON proc.id=a.TipoCompromissoID WHERE a.PacienteID="&treatvalzero(PacienteID)&" AND StaID=3 and Data<"&mydatenull(Data)&" ORDER BY Data DESC LIMIT 1")
    if not UltimoProcedimentoSQL.eof then
        DiasRetorno = UltimoProcedimentoSQL("DiasRetorno")
    end if
end if



    if PacienteID<>"" and DiasRetorno<>"" then
        sql = "SELECT a.id, a.Data, a.Hora, prof.NomeProfissional, proc.NomeProcedimento, esp.especialidade, a2.id RetornoID FROM "&_
                          "agendamentos a INNER JOIN profissionais prof ON prof.id=a.ProfissionalID INNER JOIN procedimentos proc ON proc.id=a.TipoCompromissoID "&_
                          " LEFT JOIN especialidades esp ON esp.id=a.EspecialidadeID "&_
                          " LEFT JOIN agendamentos a2 ON a2.PacienteID = a.PacienteID and a2.ProfissionalID = a.ProfissionalID and a2.TipoCompromissoID = a.TipoCompromissoID and a2.Data > a.Data and a2.Data <= ADDDATE(a.Data, INTERVAL proc.DiasRetorno DAY) and a2.Retorno = 1 "&_
                          "WHERE (a.ProfissionalID="&ProfissionalID&" or a.EspecialidadeID="&treatvalzero(EspecialidadeID)&") AND a.PacienteID="&PacienteID&" AND a.StaID IN (3) AND DATEDIFF("&mydatenull(Data)&", a.Data) BETWEEN 1 AND proc.DiasRetorno AND a.Data<"&mydatenull(Data)&"  and proc.DiasRetorno>0 AND (a.Retorno!=1 OR a.Retorno IS NULL) "&_
                          "ORDER BY a.Data"
    set AtendimentosAnterioresSQL = db.execute(sql)


    if not AtendimentosAnterioresSQL.eof then
    %>
        <div class="col-md-12">
            <p>Selecione abaixo o atendimento que originou este retorno.</p>

            <table class="table table-striped">
                <thead>
                    <tr class="success">
                        <th></th>
                        <th>Data</th>
                        <th>Hora</th>
                        <th>Profissional</th>
                        <th>Procedimento</th>
                        <th>Especialidade</th>
                        <th>Possui retorno</th>
                    </tr>
                </thead>
                <tbody>
            <%
                i=0
                while not AtendimentosAnterioresSQL.eof

                    TemRetorno=""

                    if AtendimentosAnterioresSQL("RetornoID") <> "" then
                    TemRetorno= AtendimentosAnterioresSQL("RetornoID")
                    end if

                    %>
                    <tr>
                        <td><%if TemRetorno = "" then %><input type="radio" class="atendimentos-anteriores" data-id="<%=AtendimentosAnterioresSQL("id")%>" name="atendimentos-anteriores" <% if i=0 then %>checked<% end if%>><%end if%></td>
                        <td><%=AtendimentosAnterioresSQL("Data")%></td>
                        <td><%=AtendimentosAnterioresSQL("Hora")%></td>
                        <td><%=AtendimentosAnterioresSQL("NomeProfissional")%></td>
                        <td><%=AtendimentosAnterioresSQL("NomeProcedimento")%></td>
                        <td><%=AtendimentosAnterioresSQL("especialidade")%></td>
                        <td><%if TemRetorno <> "" then%><span><a target="_blank" href="?P=Agenda-1&Pers=1&AgendamentoID=<%=TemRetorno%>">Detalhes</a></span><%end if%></td>
                    </tr>
                    <%
                    i=i+1
                AtendimentosAnterioresSQL.movenext
                wend
                AtendimentosAnterioresSQL.close
                set AtendimentosAnterioresSQL=nothing
            %>
                </tbody>
            </table>

        </div>
        <div style="margin-top: 20px" id="TemRetorno" class="col-md-12">

        </div>
        <div class="col-md-3">
            <button type="button" class="btn btn-primary mt20" onclick="SelecionarAtendimento()"><i class="fa fa-check"></i> Selecionar atendimento</button>
        </div>

    <%
    else
        %>
        <div class="col-md-12">
            <div class="alert alert-warning">
                <strong>Atenção!</strong> Esse paciente não foi atendido nos últimos <%=DiasRetorno%> dias.
            </div>
        </div>
<script >
$("#Retorno").prop("checked", false);
</script>
        <%
    end if
else
    %>
    <div class="col-md-12">
        <div class="alert alert-warning">
            <strong>Atenção!</strong> Esse procedimento não está configurado o número de dias para retorno.
        </div>
    </div>
    <%
end if

%>
</div>
<script >
    function SelecionarAtendimento() {
        var AgendamentoID = $(".atendimentos-anteriores:checked").data("id");

        if(AgendamentoID) {
            $("#btnSalvarAgenda").prop("disabled", false);
            var $valoresProcedimentos = $(".valorprocedimento");

            $valoresProcedimentos.each(function() {
                var valorOriginal = $(this).val();
                $(this).attr("data-valor-original", valorOriginal);
                $(this).val("0,00");
            });

            closeComponentsModal();
        } else {
            alert("Selecione um atendimento para retorno")
        }
    }
</script>