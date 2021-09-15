<!--#include file="connect.asp"-->
<%
'De      Pendente, Enviada, Finalizada
'Para    Pendente, Respondida, Finalizada
%>
<script type="text/javascript">
    $(".crumb-active a").html("Gerenciar Tarefas");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("filtre as tarefas que deseja localizar");
    $(".crumb-icon a span").attr("class", "far fa-tasks");
    <%
    botaoSprints = ""
    if session("Banco")="clinic5459" OR session("Banco")="clinic100000" then
        botaoSprints = "&nbsp;&nbsp;<a class=""btn btn-sm btn-primary"" href=""./?P=listaSprints&Pers=1""><i class=""far fa-users""></i><span class=""menu-text""> Sprints</span></a>"
    end if


    if aut("tarefasI")=1 or aut("tarefasgerenciarI")=1 then

      if req("Helpdesk") = "" then
    %>
    $("#rbtns").html('<a class="btn btn-sm btn-success" href="./?P=Tarefas&I=N&Pers=1<% if req("Helpdesk") <> "" then response.write("&Helpdesk=1") end if %>"><i class="far fa-tasks"></i><span class="menu-text"> Inserir tarefa</span></a>&nbsp;&nbsp;' +
     '<a class="btn btn-sm btn-primary" href="./?P=listaProjetos&Pers=1" <% if req("Helpdesk") <> "" then response.write(" style=""display:none"" ") end if %>><i class="far fa-th-large"></i><span class="menu-text"> Projetos</span></a><%=botaoSprints%>');
    <%
      end if
    end if

    MeusTickets = req("MeusTickets")
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
                <% if req("Helpdesk") = "" then
                    if MeusTickets="1" then
                        Autor=session("User")
                    end if
                %>
                    <%= quickfield("simpleSelect", "De", "Autor", 3, Autor, "select su.id, t.Nome from (	select id, NomeProfissional Nome, 'profissionais' Tipo from profissionais where ativo='on'	UNION ALL	select id, NomeFuncionario, 'funcionarios' from funcionarios where ativo='on') t INNER JOIN sys_users su ON (su.idInTable=t.id AND lcase(su.`Table`)=t.Tipo) order by Nome", "Nome", " empty ") %>
                <% end if %>
                <%=quickfield("simpleSelect", "StatusDe", "Status (autor)", 3, StatusDe, "select id, De from cliniccentral.tarefasstatus where not isnull(De)", "De", " no-select2  empty ") %>
                <%=quickfield("datepicker", "AberturaDe", "Abertura entre", 2, "", "", "", "") %>
                <%=quickfield("datepicker", "AberturaAte", "&nbsp;", 2, "", "", "", "") %>
                <div class="col-md-1">
                    <label>&nbsp;</label><br />
                    <button id="Buscar" class="btn btn-sm btn-primary btn-block"><i class="far fa-search"></i> Buscar</button>
                </div>
                <div class="col-md-1">
                    <label>&nbsp;</label><br />
                    <button class="btn-export btn btn-sm btn-info btn-block" name="Filtrate" onclick="print()" type="button"><i class="far fa-print bigger-110"></i></button>
                </div>
            </div>
            <div class="row hidden-xs">
                <%
                    if req("Helpdesk") <> "" then
                        ParaSelecionado = ""
                        StatusPara = ""
                    else

                        if MeusTickets<>"1" then
                            ParaSelecionado = session("User")
                            StatusPara="Pendente"
                        end if
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
                    <button class="btn-export btn btn-sm btn-success btn-block" name="Filtrate" onclick="downloadExcel()" type="button"><i class="far fa-table bigger-110"></i></button>
                </div>
            </div>
            <% if req("Helpdesk") = "" then %>
            <div class="row hidden" id="maisOpcoes">
                <%= quickfield("text", "Filtrar", "Filtrar", 4, "", "", "", " Placeholder='ID e/ou Título'") %>
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
                        <%=quickfield("simpleSelect", "CategoriaID", "Categoria", 3, "", "SELECT '0' id, 'SEM CATEGORIA' NomeCategoria UNION ALL SELECT id, CONCAT(IFNULL(Pai2,''), IFNULL(Pai1,''), NomeCategoria) NomeCategoria FROM (SELECT et.id, (CONCAT(SUBSTR((SELECT (SELECT etp2.NomeCategoria FROM tarefa_categoria etp2 WHERE etp2.id=etp1.PaiID) FROM tarefa_categoria etp1 WHERE etp1.id=et.PaiID),1,14),'', ' > ')) Pai2, (CONCAT(SUBSTR((SELECT etp.NomeCategoria FROM tarefa_categoria etp WHERE etp.id=et.PaiID),1,14),'', ' > ')) Pai1, et.NomeCategoria FROM tarefa_categoria et WHERE (SELECT COUNT(id) FROM tarefa_categoria WHERE et.id=PaiID)=0 AND sysActive=1 ORDER BY et.NomeCategoria)t ", "NomeCategoria", " empty ") %>

                <%
                end if
                %>
            </div>
            <%
            end if
            %>














        </div>
    </div>
<%
    if MeusTickets="1"  then
    %>
                <div class="row">
                    <div class="col-md-12">
                        <h4>Seus tickets</h4>
                    </div>
                    <div class="col-sm-3 ">
                      <div class="panel panel-tile text-center br-a br-grey">
                        <div class="panel-body">
                        <%
                        set SeusTicketsAbertosSQL = db.execute("SELECT COUNT(t.id) Qtd, t.staPara, t.staDe FROM tarefas t WHERE t.sysUser="&session("User")&" AND t.staDe != 'Finalizada'")
                        %>
                          <h1 class="fs30 mt5 mbn"><%=SeusTicketsAbertosSQL("Qtd")%></h1>
                          <h6 class="text-warning">TICKETS PENDENTES</h6>
                        </div>
                        <div class="hidden panel-footer br-t p12">
                          <span class="fs11">
                            <i class="far fa-arrow-up pr5"></i> 3% INCREASE
                            <b>1W AGO</b>
                          </span>
                        </div>
                      </div>
                    </div>

                    <div class="col-sm-3 ">
                      <div class="panel panel-tile text-center br-a br-grey">
                        <div class="panel-body">
                        <%
                        set SeusTicketsAbertosSQL = db.execute("SELECT COUNT(t.id) Qtd, t.staPara, t.staDe FROM tarefas t WHERE t.sysUser="&session("User")&" AND t.DtPrazo<=curdate() and t.staDe != 'Finalizada' and t.staPara not in ('Finalizada')")
                        %>
                          <h1 class="fs30 mt5 mbn"><%=SeusTicketsAbertosSQL("Qtd")%></h1>
                          <h6 class="text-danger">TICKETS VENCIDOS</h6>
                        </div>
                        <div class="hidden panel-footer br-t p12">
                          <span class="fs11">
                            <i class="far fa-arrow-up pr5"></i> 3% INCREASE
                            <b>1W AGO</b>
                          </span>
                        </div>
                      </div>
                    </div>

                    <div class="col-sm-3 ">
                      <div class="panel panel-tile text-center br-a br-grey">
                        <div class="panel-body">
                        <%
                        set SeusTicketsAbertosSQL = db.execute("SELECT COUNT(t.id) Qtd, t.staPara, t.staDe FROM tarefas t WHERE t.sysUser="&session("User")&" AND t.staPara='finalizada' AND t.staDe = 'Finalizada'")
                        %>
                          <h1 class="fs30 mt5 mbn"><%=SeusTicketsAbertosSQL("Qtd")%></h1>
                          <h6 class="text-system">TICKETS FINALIZADOS</h6>
                        </div>
                        <div class="hidden panel-footer br-t p12">
                          <span class="fs11">
                            <i class="far fa-arrow-up pr5"></i> 3% INCREASE
                            <b>1W AGO</b>
                          </span>
                        </div>
                      </div>
                    </div>

                     <div class="col-sm-3 ">
                      <div class="panel panel-tile text-center br-a br-grey">
                        <div class="panel-body">
                        <%
                        set SeusTicketsAbertosSQL = db.execute("SELECT COUNT(t.id) Qtd, t.staPara, t.staDe FROM tarefas t WHERE t.sysUser="&session("User")&" AND t.staPara IN ('Não entendido','Reavaliar') AND t.staDe != 'Finalizada'")
                        %>
                          <h1 class="fs30 mt5 mbn"><%=SeusTicketsAbertosSQL("Qtd")%></h1>
                          <h6 class="text-warning">TICKETS NÃO ENTENDIDOS</h6>
                        </div>
                        <div class="hidden panel-footer br-t p12">
                          <span class="fs11">
                            <i class="far fa-arrow-up pr5"></i> 3% INCREASE
                            <b>1W AGO</b>
                          </span>
                        </div>
                      </div>
                    </div>
                </div>
    <%
    end if
    %>
    <div class="panel">
        <div class="panel-body" >
            <div class="row">
                <div class="col-md-12" id="lista">

                </div>
            </div>
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
            $("#lista").html("<center><i class='far fa-circle-o-notch fa-spin'></i></center>");
            $("#lista").html(data);
        });
        return false;
    });
    $("#Buscar").click();
</script>