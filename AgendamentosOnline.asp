<!--#include file="connect.asp"-->
<style type="text/css">
    body {
        font-size: 11px;
    }
</style>
<script type="text/javascript">
    $(".crumb-active a").html("Agendamentos Online");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("realizados via website");
    $(".crumb-icon a span").attr("class", "fa fa-calendar");
</script>
<% if aut("agendaV") then
    sqlAgendamentoOnline = "select age.*, age.sysDate DataHora, prof.NomeProfissional, proc.NomeProcedimento, conv.NomeConvenio, age.ValorPlano Valor, loc.NomeLocal, pac.CPF, pac.Cel1 Celular, pac.Email1 Email, age.Notas Obs "&_
                           "from agendamentos age "&_
                           "LEFT JOIN profissionais prof ON prof.id=age.ProfissionalID "&_
                           "LEFT JOIN pacientes pac ON pac.id=age.PacienteID "&_
                           "LEFT JOIN procedimentos proc ON proc.id=age.TipoCompromissoID "&_
                           "LEFT JOIN convenios conv ON conv.id=age.ValorPlano AND age.rdValorPlano='P' "&_
                           "LEFT JOIN locais loc ON loc.id=age.LocalID "&_
                           "order by age.sysDate desc "&_
                           "limit 1000"


    set age = db.execute(sqlAgendamentoOnline)
    %>
    <div class="panel mt15">
        <div class="panel-body bg-white p15">
            <table class="table table-striped table-condensed table-hover">
                <thead>
                    <tr class="primary">
                        <th>Data</th>
                        <th width="22%">Paciente / CPF</th>
                        <th width="22%">Profissional / Procedimento</th>
                        <th>Valor / Local</th>
                        <th width="22%">Celular / E-mail / Obs</th>
                        <th width="1%"></th>
                    </tr>
                </thead>
            <%
            if not age.eof then
                while not age.eof
                    if isnull(age("NomeConvenio")) then
                        Valor = fn(age("Valor"))
                    else
                        Valor = age("NomeConvenio")
                    end if
                    %>
                    <tr>
                        <td nowrap>Em: <%= age("DataHora") %><br />
                        Para: <%= age("Data")&" "& ft(age("Hora")) %></td>
                        <td><a href="./?P=Pacientes&I=<%= age("PacienteID") %>&Pers=1" target="_blank"><%= age("NomePaciente") %></a>
                            <br /> <%= age("CPF") %>
                        </td>
                        <td><%= age("NomeProfissional") %> <br />
                        <%= age("NomeProcedimento") %></td>
                        <td><%= Valor %> <br />
                        <%= age("NomeLocal") %></td>
                        <td><%= age("Celular") %> <br />
                            <%= age("Email") %> <br />
                            <%= age("Obs") %></td>
                        <td></td>
                    </tr>
                    <%
                age.movenext
                wend
                age.close
                set age = nothing
            else
                %><tr><td>Nenhum agendamento online encontrado.</td></tr><%
            end if
            %>
            </table>
        </div>
    </div>
    <%
end if
%>
