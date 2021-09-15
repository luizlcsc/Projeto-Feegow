<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<script src="assets/js/estrela.js" type="text/javascript"></script>
<style>
.scroller, .scroller * {
    -webkit-user-select: auto !important;
    -moz-user-select: auto !important;
    -ms-user-select: auto !important;
    user-select: auto !important;
}

.scroller-navbar {
    max-height: 500px !important;
}

.panel .mn {
    width: 98.5%;
    margin: 0 auto !important;
}
.table-layout > aside {
    display: initial !important;
}
</style>
<form id="frm">
<%
tabela = "tarefas"
call insertRedir(tabela, req("I"))
set reg = db.execute("select t.*, tsDe.Classe ClasseDe, tsPara.Classe ClassePara from "&tabela&" t  LEFT JOIN cliniccentral.tarefasstatus tsDe on tsDe.id=t.StaDe LEFT JOIN cliniccentral.tarefasstatus tsPara on tsPara.id=t.StaPara where t.id="&req("I"))
'response.write("select t.*, tsDe.Classe ClasseDe, tsPara.Classe ClassePara from "&tabela&" t  LEFT JOIN cliniccentral.tarefasstatus tsDe on tsDe.id=t.StaDe LEFT JOIN cliniccentral.tarefasstatus tsPara on tsPara.id=t.StaPara where t.id="&req("I"))

if reg("De")=0 then
    De = session("User")
    DtAbertura = date()
    HrAbertura = time()
else
    De = reg("De")
    Para = reg("Para")
    DtAbertura = reg("DtAbertura")
    HrAbertura = ft(reg("HrAbertura"))
end if

if De=session("User") then
    Subtitulo = "recebida"
else
    Subtitulo = "enviada"
end if

set cc = db.execute("select CentroCustoID from "&session("Table")&" where id="& session("idInTable"))
if not cc.eof then
    CentroCustoID = cc("CentroCustoID")
end if

PermitirV = aut("tarefasgerenciarV")
PermitirA = aut("tarefasgerenciarA")
PermitirI = aut("tarefasgerenciarI")
%>
<input type="hidden" name="P" value="tarefas" />
<input type="hidden" name="I" value="<%= req("I") %>" />
<input type="hidden" name="De" value="<%= De %>" />
<input type="hidden" name="DtAbertura" value="<%= DtAbertura %>" />
<input type="hidden" name="HrAbertura" value="<%= HrAbertura %>" />

<script>
function log(){$('#modal-table').modal('show');$.get('DefaultLog.asp?R=tarefas&I=<%= req("I")%>', function(data){$('#modal').html(data);})}

$(".crumb-active a").html("Controle de Tarefa");
$(".crumb-icon a span").attr("class", "far fa-tasks");
$(".crumb-link").removeClass("hidden").html("<%=subtitulo%>");
<%
    btnIncluir = ""
    if PermitirI = 1 then
        btnIncluir = " <a title='Novo' href='?P=tarefas&Pers=1&I=N' class='btn btn-sm btn-default'><i class='far fa-plus'></i></a> "
    end if
%>
$("#rbtns").html("<a title=\"Lista\" href=\"?P=listatarefas&Pers=1\" class=\"btn btn-sm btn-default\"><i class=\"far fa-list\"></i></a> <a title=\"Histórico de Alterações\" href=\"javascript:log()\" class=\"btn btn-sm btn-default hidden-xs\"><i class=\"far fa-history\"></i></a><%=btnIncluir%>");

</script>

<div class="row" style="margin-top: 10px;">
    <div class="col-md-4">
        <div class="panel">

            <div class="panel-heading">
            <%
                if reg("sysActive")=0 then
                    disabled=""'por enquanto nao usa
                    DtPrazo = date()
                    HrPrazo = time()
                    Solicitantes = req("Solicitantes")
                    TempoEstimado = 1
                else
                    DtPrazo = reg("DtPrazo")
                    HrPrazo = ft(reg("HrPrazo"))
                    Solicitantes = reg("Solicitantes")
                    if reg("TempoEstimado") then
                        TempoEstimado = replace(reg("TempoEstimado"), ",", ".")
                    else
                        TempoEstimado = 0
                    end if
                    TipoEstimado = reg("TipoEstimado")
                    %>
                        <span class="panel-title"> Tarefa <strong>#<%= req("I") %> </strong></span>
                    <%
                end if
                %>
                    <span class="panel-controls">
                        <%if De=session("User") or reg("sysUser")=session("User") or PermitirA=1 then %>
                        <button class="btn btn-sm btn-primary" id="save">&nbsp;&nbsp;<i class="far fa-save"></i> <strong>SALVAR</strong>&nbsp;&nbsp;</button>
                        <%end if %>
                    </span>
            </div>
            <div class="panel-body">
                <div class="row">
                    <%=quickfield("simpleSelect", "Tipo", "Tipo", 6, cstr(reg("Tipo")&""), "select id, Descricao from tarefastipos order by id", "Descricao", " semVazio") %>
                    <%
                        projetoAux = reg("ProjetoID")
                        projetoAuxQuery = ""
                        if not isnull(projetoAux) then
                            projetoAuxQuery = " OR id IN ("&reg("ProjetoID")&") "
                        end if
                     %>
                    <%=quickfield("simpleSelect", "Urgencia", "Prioridade", 6, cstr(reg("Urgencia")&""), "select id, Prioridade from cliniccentral.tarefasprioridade "& whereAux &" order by id", "Prioridade", " semVazio no-select2 ") %>
                    <%=quickField("multiple", "Para", "Para", 12, Para, "select su.id, t.Nome from (	select id, NomeProfissional Nome, 'profissionais' Tipo from profissionais where ativo='on'	UNION ALL	select id, NomeFuncionario, 'funcionarios' from funcionarios where ativo='on') t INNER JOIN sys_users su ON (su.idInTable=t.id AND lcase(su.`Table`)=t.Tipo)  UNION ALL select cc.id*(-1), concat('&raquo; ', cc.NomeCentroCusto) from centrocusto cc where cc.sysActive=1 order by Nome", "Nome", " required")%>
                    <%=quickfield("simpleSelect", "ProjetoID", "Projeto", 12, cstr(reg("ProjetoID")&""), "SELECT '0' AS id, '== NENHUM ==' AS Titulo UNION ALL SELECT id, Titulo FROM projetos WHERE StatusID NOT IN (3, 4) "&projetoAuxQuery&" ORDER BY Titulo", "Titulo", " semVazio ") %>
                    <%
                        if (session("admin") <> 1) then
                            whereAux = " WHERE id NOT IN (6) "
                        end if

                        exibeDadosEstimativa = " disabled "
                        if (reg("sysUser") = session("user")) OR (PermitirA = 1) then
                            exibeDadosEstimativa = " "
                        end if
                    %>
                    <%=quickField("datepicker", "DtPrazo", "Data Prazo", 6, DtPrazo, "", "", " "& disabled &" ")%>
                    <%=quickField("timepicker", "HrPrazo", "Hora Prazo", 6, HrPrazo, "", "", " "& disabled &" ")%>
                    <%=quickField("number", "TempoEstimado", "Tempo Est.", 6, TempoEstimado, "", "", " min='0' step='0.01' "&exibeDadosEstimativa)%>
                    <%=quickfield("simpleSelect", "TipoEstimado", "Tipo Est.", 6, TipoEstimado, "select '1' id, 'Minutos' Tipo UNION SELECT '60', 'Horas' UNION SELECT '1440', 'Dias'", "Tipo", " semVazio no-select2 "&exibeDadosEstimativa)%>
                    <% if (reg("sysUser") <> session("user")) AND (session("admin") <> 1) then %>
                        <input type="hidden" value="<% if not isnull(reg("TempoEstimado")) then response.write(replace(reg("TempoEstimado"), ",", ".")) else response.write(0) end if%>" id="TempoEstimado" name="TempoEstimado">
                        <input type="hidden" value="<%=reg("TipoEstimado")%>" id="TipoEstimado" name="TipoEstimado">
                    <% end if %>
                </div>
                <div class="panel" style="margin-top: 30px;">
                    <div class="panel-heading">
                        <span class="panel-title">Solicitantes</span>
                        <span class="panel-controls">
                            <button type="button" class="btn btn-xs btn-success mn" onclick="tsol('I');"><i class="far fa-plus"></i></button>
                        </span>
                    </div>
                    <div class="panel-body">
                        <div class="row">
                          <div class="col-md-12" id="TarefasSolicitantes">
                              <% server.execute("TarefasSolicitantes.asp") %>
                          </div>
                        </div>
                    </div>
                </div>


                <%if reg("sysActive")=1 then %>
                <br>
                <div class="panel">
                    <div class="panel-heading">
                        <span class="panel-title"><i class="far fa-star-o blue"></i> Status desta Tarefa</span>
                    </div>

                    <div class="panel-body">
                        <div class="row">
                            <div class="col-md-12" id="tarefasExecucao">
                                <% server.Execute("tarefasExecucao.asp") %>
                            </div>
                        </div>
                        <div class="row">
                            <%
                            if reg("De")=session("User") then
                                %>
                                <%=quickfield("simpleSelect", "staDe", "Segundo você", 4, reg("staDe"), "select id, De from cliniccentral.tarefasstatus where not isnull(De)", "De", "") %>
                                <%
                            else
                                %>
                                <div class="col-md-4">
                                    <label>Segundo o remetente</label><br />
                                    <div class="label label-xlg btn-block arrowed-in arrewed-in-right label-<%=reg("classeDe") %>"><%=reg("staDe") %></div>
                                    <input type="hidden" name="staDe" value="<%=reg("staDe") %>" />
                                </div>
                                <%
                            end if
                            if instr(Para, "|"& session("User") &"|")>0 or instr(Para, "|-"& CentroCustoID &"|")>0 then
                                descPara = "Segundo o recebedor"
                                %>
                                <%=quickfield("simpleSelect", "staPara", descPara, 4, reg("staPara"), "select id, Para from cliniccentral.tarefasstatus where not isnull(Para)", "Para", "") %>
                                <%
                            else
                                descPara = "Segundo você"
                                    %>
                                    <div class="col-md-4">
                                        <label><%=descPara %></label><br />
                                        <div class="label label-xlg btn-block arrowed-in arrowed-in-right label-<%=reg("classePara") %>"> <%=reg("staPara") %></div>
                                        <input type="hidden" name="staPara" value="<%=reg("staPara") %>" />
                                    </div>
                                    <%
                            end if
                            %>
                            <input type="hidden" id="AvaliacaoNota" name="AvaliacaoNota" value="<%=reg("AvaliacaoNota") %>" />
                            <div class="col-md-4">
                                <label>Nota</label><br />
                                <div class="row lead">
                                    <div class="col-md-12 blue">
                                        <span style="cursor:pointer" id="stars-existing" class="starrr" data-rating='<%=reg("AvaliacaoNota") %>'></span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <%else %>
                <input type="hidden" name="staDe" value="Enviada" />
                <input type="hidden" name="staPara" value="Pendente" />
                <%end if %>

            </div>
        </div>
    </div>
    <div class="col-md-8">
        <div class="panel">
            <div class="panel-body">
                <div class="row">
                    <div style="margin-top: 10px;float: right">
                        <% if not isnull(reg("DtAbertura")) then %>
                                <span class="text-primary">
                                    <strong>Tarefa criada por <%=nameInTable(reg("De")) %> - <%=reg("DtAbertura") &" às "& ft(reg("HrAbertura")) %>&nbsp;&nbsp;</strong>
                                </span>
                        <% end if %>
                    </div>
                    <div class="col-md-12">
                        <%= selectList("Título", "Titulo", reg("Titulo"), "tarefas", "Titulo", "location.href=""?P=tarefas&Pers=1&I=""+$(this).val()", " "& disabled &" required", "") %>
                    </div>
                </div>
                <hr class="short alt" />
                <div class="row" style="margin: 5px">
                    <div class="col-md-1">
                        <div>
                            <label>Público</label>
                            <div class="switch">
                                <input type="checkbox" checked="checked" name="Publico" id="Publico">
                                <label for="Publico"></label>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-10"></div>
                    <div class="col-md-1" style="margin-top: 5px;">
                        <button type="button" id="btnInteracao" class="btn btn-primary"><i class="far fa-send"></i> Enviar</button>
                    </div>
                </div>
                <div class="row" style="margin: 10px;" >
                    <textarea hidden id="ta" name="ta"><%=reg("ta")%></textarea>
                    <%=quickField("editor", "msgInteracao", "", 12, "", "200", "", " "&disabled&" ")%>
                </div>
                <hr class="short alt" />
                <div id="interacoes" class="tab-pane chat-widget active" role="tabpanel">
                    <%server.Execute("TarefasInteracoes2.asp") %>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    $(document).ready(function() {
      setTimeout(function() {
        $("#toggle_sidemenu_l").click()
      }, 500);

          <%if session("User")=reg("De") then %>
        $('#stars-existing').on('starrr:change', function(e, value){
          $('#AvaliacaoNota').val(value);
        });
          <%end if%>
    });

    $("#btnInteracao").click(function () {
        var frm = $("#frm").serialize();
        $("#msgInteracao").val('');
        $("#btnInteracao").html("<center><i class='far fa-circle-o-notch fa-spin'></i></center>");

        $.post("TarefasInteracoes2.asp?I=<%=req("I")%>", frm, function(data){
            $("#interacoes").html(data);
            $("#btnInteracao").html("<i class='far fa-send'></i> Enviar");
        });
    });

    $("#frm").submit(function () {
        var Solicitantes = "";
        $("input[name^=Solicitante]").each(function () {
            Solicitantes += "," + $(this).val();
        });

        $.post("save.asp?I=<%=req("I")%>", $("#frm").serialize()+"&Solicitantes="+Solicitantes, function(data){
            eval(data);
        });
        return false;
    });

    function tsol(A) {
        var Solicitantes = "";
        $("input[name^=Solicitante]").each(function () {
            Solicitantes += "," + $(this).val();
        });
        $.post("TarefasSolicitantes.asp?I=<%=req("I")%>&A="+ A, { Solicitantes: Solicitantes }, function (data) {
            $("#TarefasSolicitantes").html(data);
        });
    }


    $("#staDe, #staPara").change(function(){
        $.get("tarefaSave.asp?I=<%=req("I")%>&onlySta="+$(this).attr("id")+"&Val="+$(this).val(), function(data){
            eval(data);
        });
    });

    function executarTarefa(A){
        $.post("tarefasexecucao.asp?I=<%=req("I")%>", {A: A, Texto: $('#TextoExecucao').val()}, function (data) {
            $("#tarefasExecucao").html(data);
        });
    }
</script>
<!--    </div>-->
<!--</div>-->
</form>