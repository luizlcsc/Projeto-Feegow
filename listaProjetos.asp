<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Gerenciar Projetos");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("lista de projetos");
    $(".crumb-icon a span").attr("class", "far fa-th-large");
    <%
    if aut("tarefasI")=1 or aut("tarefasgerenciarI")=1 then
    %>
    $("#rbtns").html('<a class="btn btn-sm btn-success" href="./?P=projetos&I=N&Pers=1"><i class="far fa-th-large"></i><span class="menu-text"> Inserir projeto</span></a>&nbsp;&nbsp;' +
     '<a class="btn btn-sm btn-primary" href="./?P=listaTarefas&Pers=1"><i class="far fa-tasks"></i><span class="menu-text"> Tarefas</span></a>');
    <%
    end if
    %>
</script>

<%
    sql =  " SELECT p.id,                                                           "&chr(13)&_
           "        p.Titulo,                                                       "&chr(13)&_
           "        p.Descricao,                                                    "&chr(13)&_
           "        p.PrioridadeID,                                                 "&chr(13)&_
           "        p.Participantes,                                                "&chr(13)&_
           "        p.Responsaveis,                                                 "&chr(13)&_
           "        p.DataPrazo,                                                    "&chr(13)&_
           "        tp.Prioridade,                                                  "&chr(13)&_
           "        tp.Classe AS PrioridadeClasse,                                  "&chr(13)&_
           "        ps.Descricao AS Status,                                         "&chr(13)&_
           "        ps.Classe AS StatusClasse                                       "&chr(13)&_
           " FROM projetos p                                                        "&chr(13)&_
           " LEFT JOIN cliniccentral.tarefasprioridade tp ON tp.id = p.PrioridadeID "&chr(13)&_
           " LEFT JOIN cliniccentral.projetosstatus ps ON ps.id = p.StatusID        "&chr(13)&_
           " WHERE p.sysActive=1                                                    "&chr(13)&_
           " ORDER BY p.PrioridadeID DESC "
    set projetos = db.execute(sql)
%>

<div class="panel" style="margin-top:20px">
    <div class="panel-body" id="lista">
        <div class="col-md-12">
            <table class="table table-striped table-hover table-bordered table-condensed">
                <thead>
                  <tr class="success">
                    <th>Título</th>
                    <th>Descrição</th>
                    <th>Prioridade</th>
                    <th>Status</th>
                    <th>Participantes</th>
                    <th>Responsáveis</th>
                    <th>Prazo</th>
                    <th></th>
                  </tr>
                </thead>
                <tbody>
                <% while not projetos.eof %>
                <%
                    Participantes = ""
                    participantesAux = projetos("Participantes")
                    if InStr(participantesAux, "|") > 0 then
                        participantes = db.execute("SELECT GROUP_CONCAT(DISTINCT NomeProfissional ORDER BY NomeProfissional ASC SEPARATOR ', ') AS Participantes FROM profissionais WHERE id IN ("&REPLACE(participantesAux, "|", "")&")")
                        Participantes = participantes("Participantes")
                    end if

                    Responsaveis = ""
                    responsaveisAux = projetos("Responsaveis")
                    if InStr(responsaveisAux, "|") > 0 then
                        responsaveis = db.execute("SELECT GROUP_CONCAT(DISTINCT NomeProfissional ORDER BY NomeProfissional ASC SEPARATOR ', ') AS Responsaveis FROM profissionais WHERE id IN ("&REPLACE(responsaveisAux, "|", "")&")")
                        Responsaveis = responsaveis("Responsaveis")
                    end if
                %>
                    <tr>
                        <td class="text-center"><%=projetos("Titulo")%></td>
                        <td class="text-center"><%=projetos("Descricao")%></td>
                        <td class="text-center text-<%=projetos("PrioridadeClasse")%>"><%=projetos("Prioridade")%></td>
                        <td class="text-center text-<%=projetos("StatusClasse")%>"><%=projetos("Status")%></td>
                        <td class="text-center"><%=Participantes%></td>
                        <td class="text-center"><%=Responsaveis%></td>
                        <td class="text-center"><%=projetos("DataPrazo")%></td>
                        <td class="text-center"><a href="./?P=projetos&Pers=1&I=<%=projetos("id") %>" class="btn btn-success btn-xs"><i class="far fa-edit"></i></a></td>
                    </tr>
                <%
                   projetos.movenext
                   wend
                   projetos.close
                   set projetos=nothing
                %>
                </tbody>
            </table>
        </div>
    </div>
</div>