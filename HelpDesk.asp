<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->

<script type="text/javascript">
    $(".crumb-active a").html("Helpdesk Feegow");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("canal de relacionamento com o cliente");
    $(".crumb-icon a span").attr("class", "far fa-comments-o");
<%
if ref("Chamado")<>"" then
    dbc.execute("insert into cliniccentral.pesquisa (LicencaID, UserID, Texto,tipoChamadoID,deptoChamadoID,prioridadeChamadoID) values ("& replace(session("Banco"), "clinic", "") &", "& session("User") &", '"& ref("Chamado") &"',"&treatvalnull(ref("tipoChamado"))&","&treatvalnull(ref("deptoChamado"))&","&treatvalnull(ref("prioridadeChamado"))&")")
    %>
    alert('Chamado aberto com sucesso! Em até 24 horas úteis nossa equipe responderá a este chamado e você será notificado.');
    <%
end if
%>
</script>



<div class="panel mt15">
    <div class="panel-heading">
        <span class="panel-title">CHAMADOS PENDENTES</span>
        <span class="panel-controls">
            <button onclick="$('.alertChamado').removeClass('hidden'); $(this).addClass('hidden');" class="btn btn-sm btn-warning"><i class="far fa-plus"></i> NOVO CHAMADO</button>
        </span>
    </div>
    <div class="panel-body">

        <div class="alertChamado alert alert-info row hidden">
            <h3>Abertura de Chamado</h3>
            <form method="post" id="abrirChamado">
                <div class="col-md-3">
                    <%= quickfield("simpleSelect", "tipoChamado", "Tipo do chamado", 12, "", "select id, tipoChamado from cliniccentral.tipochamado", "tipoChamado", " no-select2 empty required ") %>
                    <%= quickfield("simpleSelect", "deptoChamado", "Departamento do chamado", 12, "", "select id, deptoChamado from cliniccentral.deptochamado", "deptoChamado", " no-select2 semVazio ") %>
                    <%= quickfield("simpleSelect", "prioridadeChamado", "Prioridade do chamado", 12, "", "select id, prioridadeChamado from cliniccentral.prioridadechamado", "prioridadeChamado", " no-select2 semVazio ") %>
                </div>
                <%= quickfield("memo", "Chamado", "Chamado", 9, "", "", "", " rows=8 required ") %>
                <div class="col-md-12">
                    <hr class="short alt" />
                </div>
                <div class="col-md-12">
                    <button class="btn btn-warning pull-right">ABRIR CHAMADO</button>
                </div>
            </form>
        </div>

        <table class="table table-bordered table-hover">
            <thead>
                <tr class="warning">
                    <th>Ticket</th>
                    <th>Data / Hora</th>
                    <th>Usuário</th>
                    <th>Chamado</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <%
                set cham = dbc.execute("select * from cliniccentral.pesquisa where LicencaID="& replace(session("Banco"), "clinic", "") &" and Fechado=0 order by DataHora desc")
                while not cham.eof
                    %>
                    <tr>
                        <td><%= cham("id") %></td>
                        <td><%= cham("DataHora") %></td>
                        <td><%= nameInTable(cham("UserID")) %></td>
                        <td><%= cham("Texto") %></td>
                        <td>Aguardando Resposta</td>
                    </tr>
                    <%
                cham.movenext
                wend
                cham.close
                set cham = nothing
                    %>
            </tbody>
        </table>
    </div>
</div>