<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Gerenciar Sprints");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("lista de sprints");
    $(".crumb-icon a span").attr("class", "far fa-users");
    <%
    if aut("tarefasI")=1 then
    %>
    $("#rbtns").html('<a class="btn btn-sm btn-success" href="./?P=sprints&I=N&Pers=1"><i class="far fa-users"></i><span class="menu-text"> Inserir sprint</span></a>&nbsp;&nbsp;' +
     '<a class="btn btn-sm btn-primary" href="./?P=listaTarefas&Pers=1"><i class="far fa-tasks"></i><span class="menu-text"> Tarefas</span></a>');
    <%
    end if
    %>
</script>

<%
    sql =  " SELECT s.*,                                                              "&chr(13)&_
           "      ps.Descricao AS Status,                                             "&chr(13)&_
           "      ps.Classe AS StatusClasse,                                          "&chr(13)&_
           "      cc.NomeCentroCusto                                                  "&chr(13)&_
           " FROM sprints s                                                           "&chr(13)&_
           " LEFT JOIN cliniccentral.projetosstatus ps ON ps.id = s.StatusID          "&chr(13)&_
           " LEFT JOIN centrocusto cc ON cc.id = s.CentroCustoID                      "&chr(13)&_
           " WHERE s.sysActive = 1                                                    "&chr(13)&_
           " ORDER BY s.Descricao;                                                    "
    set sprints = db.execute(sql)
%>

<div class="panel" style="margin-top:20px">
    <div class="panel-body" id="lista">
        <div class="col-md-12">
            <table class="table table-striped table-hover table-bordered table-condensed">
                <thead>
                  <tr class="success">
                    <th>Sprint</th>
                    <th>Status</th>
                    <th>Prazo</th>
                    <th>Horas Orçadas</th>
                    <th>Centro de Custo</th>
                    <th>Responsáveis</th>
                    <th>Participantes</th>
                    <th>Observações</th>
                    <th></th>
                  </tr>
                </thead>
                <tbody>
                <% while not sprints.eof %>
                <%
                    Participantes = ""
                    participantesAux = sprints("Participantes")
                    if InStr(participantesAux, "|") > 0 then
                        participantes = db.execute("SELECT GROUP_CONCAT(DISTINCT NomeProfissional ORDER BY NomeProfissional ASC SEPARATOR ', ') AS Participantes FROM profissionais WHERE id IN ("&REPLACE(participantesAux, "|", "")&")")
                        Participantes = participantes("Participantes")
                    end if

                    Responsaveis = ""
                    responsaveisAux = sprints("Responsaveis")
                    if InStr(responsaveisAux, "|") > 0 then
                        responsaveis = db.execute("SELECT GROUP_CONCAT(DISTINCT NomeProfissional ORDER BY NomeProfissional ASC SEPARATOR ', ') AS Responsaveis FROM profissionais WHERE id IN ("&REPLACE(responsaveisAux, "|", "")&")")
                        Responsaveis = responsaveis("Responsaveis")
                    end if
                %>
                    <tr>
                        <td class="text-center"><%=sprints("Descricao")%></td>
                        <td class="text-center text-<%=sprints("StatusClasse")%>"><%=sprints("Status")%></td>
                        <td class="text-center">De <%=sprints("PrazoDe")%> até <%=sprints("PrazoAte")%></td>
                        <td class="text-center"><%=FormatDateTime(sprints("HorasOrcadas"), 4)%></td>
                        <td class="text-center"><%=sprints("NomeCentroCusto")%></td>
                        <td class="text-center"><%=Responsaveis%></td>
                        <td class="text-center"><%=Participantes%></td>
                        <td class="text-center"><%=sprints("Obs")%></td>
                        <td class="text-center"><a href="./?P=sprints&Pers=1&I=<%=sprints("id") %>" class="btn btn-success btn-xs"><i class="far fa-edit"></i></a></td>
                    </tr>
                <%
                   sprints.movenext
                   wend
                   sprints.close
                   set sprints=nothing
                %>
                </tbody>
            </table>
        </div>
    </div>
</div>