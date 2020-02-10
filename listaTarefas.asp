<!--#include file="connect.asp"-->
<%
'De      Pendente, Enviada, Finalizada
'Para    Pendente, Respondida, Finalizada
%>
<script type="text/javascript">
    $(".crumb-active a").html("Gerenciar Tarefas");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("filtre as tarefas que deseja localizar");
    $(".crumb-icon a span").attr("class", "fa fa-tasks");
    <%
    botaoSprints = ""
    if session("Banco")="clinic5459" OR session("Banco")="clinic100000" then
        botaoSprints = "&nbsp;&nbsp;<a class=""btn btn-sm btn-primary"" href=""./?P=listaSprints&Pers=1""><i class=""fa fa-users""></i><span class=""menu-text""> Sprints</span></a>"
    end if


    if aut("tarefasI")=1 then
    %>
    $("#rbtns").html('<a class="btn btn-sm btn-success" href="./?P=Tarefas&I=N&Pers=1<% if req("Helpdesk") <> "" then response.write("&Helpdesk=1") end if %>"><i class="fa fa-tasks"></i><span class="menu-text"> Inserir tarefa</span></a>&nbsp;&nbsp;' +
     '<a class="btn btn-sm btn-primary" href="./?P=listaProjetos&Pers=1" <% if req("Helpdesk") <> "" then response.write(" style=""display:none"" ") end if %>><i class="fa fa-th-large"></i><span class="menu-text"> Projetos</span></a><%=botaoSprints%>');
    <%
    end if
    %>
</script>

<form id="frm">
    <br />
    <div class="panel hidden-print">
        <div class="panel-body">
            <div class="row">
                <%
                    if req("Helpdesk") <> "" then
                        StatusDe = "Enviada"
                    else
                        StatusDe=""
                    end if
                %>
                <% if req("Helpdesk") = "" then %>
                    <%= quickfield("simpleSelect", "De", "Autor", 3, "", "select su.id, t.Nome from (	select id, NomeProfissional Nome, 'profissionais' Tipo from profissionais where ativo='on'	UNION ALL	select id, NomeFuncionario, 'funcionarios' from funcionarios where ativo='on') t INNER JOIN sys_users su ON (su.idInTable=t.id AND lcase(su.`Table`)=t.Tipo) order by Nome", "Nome", " empty ") %>
                <% end if %>
                <%=quickfield("simpleSelect", "StatusDe", "Status (autor)", 3, StatusDe, "select id, De from cliniccentral.tarefasstatus where not isnull(De)", "De", " no-select2  empty ") %>
                <%=quickfield("datepicker", "AberturaDe", "Abertura entre", 2, "", "", "", "") %>
                <%=quickfield("datepicker", "AberturaAte", "&nbsp;", 2, "", "", "", "") %>
                <div class="col-md-1">
                    <label>&nbsp;</label><br />
                    <button id="Buscar" class="btn btn-sm btn-primary btn-block"><i class="fa fa-search"></i> Buscar</button>
                </div>
                <div class="col-md-1">
                    <label>&nbsp;</label><br />
                    <button class="btn-export btn btn-sm btn-info btn-block" name="Filtrate" onclick="print()" type="button"><i class="fa fa-print bigger-110"></i></button>
                </div>
            </div>
            <div class="row hidden-xs">
                <%
                    if req("Helpdesk") <> "" then
                        ParaSelecionado = ""
                        StatusPara = ""
                    else
                        ParaSelecionado = session("User")
                        StatusPara="Pendente"
                    end if
                %>
                <% if req("Helpdesk") = "" then %>
                    <%= quickfield("simpleSelect", "Para", "Destinatário", 3, ParaSelecionado, "select concat(su.id, '') id, t.Nome from (	select id, NomeProfissional Nome, 'profissionais' Tipo from profissionais where ativo='on'	UNION ALL	select id, NomeFuncionario, 'funcionarios' from funcionarios where ativo='on') t INNER JOIN sys_users su ON (su.idInTable=t.id AND lcase(su.`Table`)=t.Tipo)  UNION ALL select cc.id*(-1), concat('&raquo; ', cc.NomeCentroCusto) from centrocusto cc where cc.sysActive=1 order by Nome", "Nome", " empty ") %>
                <% end if %>
                <%=quickfield("simpleSelect", "StatusPara", "Status (destinatário)", 3, StatusPara, "select id, Para from cliniccentral.tarefasstatus where not isnull(Para)", "Para", " no-select2  empty ") %>
                <% if req("Helpdesk") = "" then %>
                    <%=quickfield("datepicker", "PrazoDe", "Prazo entre", 2, "", "", "", "") %>
                    <%=quickfield("datepicker", "PrazoAte", "&nbsp;", 2, "", "", "", "") %>
                <% end if %>
                <% if req("Helpdesk") = "" then %>
                    <div class="col-md-1">
                        <a class="btn btn-sm mt25" href="#" onclick="javascript:$('#maisOpcoes').removeClass('hidden');">+ opções</a>
                    </div>
                <% end if %>
                <div class="col-md-1">
                    <label>&nbsp;</label><br />
                    <button class="btn-export btn btn-sm btn-success btn-block" name="Filtrate" onclick="downloadExcel()" type="button"><i class="fa fa-table bigger-110"></i></button>
                </div>
            </div>
            <% if req("Helpdesk") = "" then %>
            <div class="row hidden" id="maisOpcoes">
                <%= quickfield("text", "Filtrar", "Filtrar", 4, "", "", "", "") %>
                <%=quickfield("simpleSelect", "Prioridade", "Prioridade", 3, "", "select id, Prioridade from cliniccentral.tarefasprioridade order by id", "Prioridade", " no-select2  empty ") %>
                <%=quickfield("simpleSelect", "Projeto", "Projeto", 3, "", "SELECT '0' id , 'Nenhum projeto' Titulo UNION ALL select id, Titulo from projetos where sysActive=1 order by 2", "Titulo", " no-select2  empty ") %>
                <div class="col-md-3">
                    <%= selectInsertCA("Solicitante "& c, "Solicitante"& c, "", "5, 4, 3, 2, 6", "", "", "") %>
                </div>
                <%
                if session("OtherCurrencies")="phone" then
                %>
                <%= quickfield("simpleSelect", "Responsavel", "Responsável", 3, "", "select su.id, t.Nome from (	select id, NomeProfissional Nome, 'profissionais' Tipo from profissionais where ativo='on' and sysActive=1	UNION ALL	select id, NomeFuncionario, 'funcionarios' from funcionarios where ativo='on' and sysActive=1) t INNER JOIN sys_users su ON (su.idInTable=t.id AND lcase(su.`Table`)=t.Tipo) order by Nome", "Nome", " empty ") %>
                 <%=quickfield("simpleSelect", "TipoTarefa", "Tipo da Tarefa", 2, "", "select '0' id, 'Sem Tipo' Descricao UNION ALL  select id, Descricao from tarefastipos order by id", "Descricao", " semVazio") %>

                <%
                end if
                %>
            </div>
            <%
            end if
            %>














        </div>
    </div>

    <div class="panel">
        <div class="panel-body" id="lista">

        </div>
    </div>
</form>
<form id="formTarefas" method="POST">
    <input type="hidden" name="html" id="htmlTable">
</form>
<script>
function downloadExcel(){
    $("#htmlTable").val($("#lista").html());
    var tk = localStorage.getItem("tk");

    $("#formTarefas").attr("action", domain+"/reports/download-excel?title=Tarefas&tk="+tk).submit();
}
</script>
<script type="text/javascript">
    $("#frm").submit(function () {
        $.post("listaTarefasResult.asp", $(this).serialize() + "&Helpdesk=<%=req("Helpdesk")%>", function (data) {
            $("#lista").html("<center><i class='fa fa-circle-o-notch fa-spin'></i></center>");
            $("#lista").html(data);
        });
        return false;
    });
    $("#Buscar").click();
</script>