<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<script type="text/javascript">
    function log(){$('#modal-table').modal('show');$.get('DefaultLog.asp?R=sprints&I=<%= req("I")%>', function(data){$('#modal').html(data);})}

    $(".crumb-active a").html("Gerenciar Sprints");
    $(".crumb-link").removeClass("hidden");
    <% if req("I") = "N" then %>
        $(".crumb-link").html("criando nova sprint");
    <% else %>
        $(".crumb-link").html("editando sprint");
    <% end if %>
    $(".crumb-icon a span").attr("class", "far fa-users");
    <%
        btnIncluir = ""
        if PermitirI = 1 then
            btnIncluir = " <a title='Novo' href='?P=tarefas&Pers=1&I=N' class='btn btn-sm btn-default'><i class='far fa-plus'></i></a> "
        end if
    %>
    $("#rbtns").html('<a title="Lista" href="?P=listaSprints&Pers=1" class="btn btn-sm btn-default"><i class="far fa-list"></i></a> <a title="Histórico de Alterações" href="javascript:log()" class=\"btn btn-sm btn-default hidden-xs\"><i class=\"far fa-history\"></i></a>');
</script>

<%
call insertRedir(req("P"), req("I"))
    sql = " SELECT s.*,                                                              "&chr(13)&_
          "      ps.Descricao AS Status,                                             "&chr(13)&_
          "      ps.Classe AS StatusClasse,                                          "&chr(13)&_
          "      cc.NomeCentroCusto                                                  "&chr(13)&_
          " FROM sprints s                                                           "&chr(13)&_
          " LEFT JOIN cliniccentral.projetosstatus ps ON ps.id = s.StatusID          "&chr(13)&_
          " LEFT JOIN centrocusto cc ON cc.id = s.CentroCustoID                      "&chr(13)&_
          " WHERE s.id =                                                             "& req("I")

    sprint = db.execute(sql)

    if not isnull(sprint("Descricao")) then
        Descricao = sprint("Descricao")
        StatusID = sprint("StatusID")
        CentroCustoID = sprint("CentroCustoID")
        PrazoDe = sprint("PrazoDe")
        PrazoAte = sprint("PrazoAte")
        HorasOrcadas = sprint("HorasOrcadas")
        Responsaveis = sprint("Responsaveis")
        Participantes = sprint("Participantes")
        Obs = sprint("Obs")
    else
        Descricao = ""
        StatusID = ""
        CentroCustoID = ""
        PrazoDe = ""
        PrazoAte = ""
        HorasOrcadas = ""
        Responsaveis = ""
        Participantes = ""
        Obs = ""
    end if
%>
<form id="frm" method="post">
<div class="row">
    <div class="col-md-11"></div>
    <div class="col-md-1">
        <button class="btn btn-sm btn-primary" type="submit" id="Salvar" style="margin:20px 0;float: right;">&nbsp;&nbsp;<i class="far fa-save"></i> <strong>SALVAR</strong>&nbsp;&nbsp;</button>
    </div>
</div>
<div class="panel" >
    <div class="panel-body" id="lista">
            <input type="hidden" name="P" value="sprints" />
            <input type="hidden" name="I" value="<%= req("I") %>" />
            <input type="hidden" name="sysActive" value="1" />
            <div class="row">
                <%=quickField("text", "Descricao", "Sprint", 7, Descricao, "", "", " maxlength='250' required ")%>
                <%=quickfield("simpleSelect", "StatusID", "Status", 2, StatusID, "select id, Descricao from cliniccentral.projetosstatus ORDER BY id", "Descricao", " semVazio ") %>
                <%=quickfield("simpleSelect", "CentroCustoID", "Centro de Custo", 3, CentroCustoID, "select id, NomeCentroCusto from centrocusto ORDER BY id", "NomeCentroCusto", " semVazio ") %>
            </div>
            <div class="row">
                <%=quickField("datepicker", "PrazoDe", "De", 2, PrazoDe, "", "", "")%>
                <%=quickField("datepicker", "PrazoAte", "Até", 2, PrazoAte, "", "", "")%>
                <%=quickField("timepicker", "HorasOrcadas", "Horas Orçadas", 2, HorasOrcadas, "", "", "")%>
                <%=quickField("multiple", "ResponsaveisArr", "Responsáveis", 3, Responsaveis, "SELECT DISTINCT p.id, NomeProfissional FROM profissionais p INNER JOIN sys_users su ON su.idInTable = p.id WHERE sysActive = 1 AND Ativo = 'on' ORDER BY NomeProfissional", "NomeProfissional", " ")%>
                <%=quickField("multiple", "ParticipantesArr", "Participantes", 3, Participantes, "SELECT DISTINCT p.id, NomeProfissional FROM profissionais p INNER JOIN sys_users su ON su.idInTable = p.id WHERE sysActive = 1 AND Ativo = 'on' ORDER BY NomeProfissional", "NomeProfissional", " ")%>
            </div>
            <div class="row">
            </div>
            <div class="row" style="margin-top:20px">
                <div class="col-md-12">
                    <label for="Obs">Observações</label>
                    <textarea type="text" class="form-control" name="Obs" id="Obs"><%=Obs%></textarea>
                </div>
            </div>

    </div>
</div>
</form>


<hr class="short alt" />
<h4 style="margin: 5px"><i class="far fa-tasks"></i> Tarefas Vinculadas</h4>
<div id="tarefas" class="tab-pane chat-widget active" role="tabpanel">
    <%server.Execute("TarefasSprints.asp") %>
</div>


<script>
    $("#frm").submit(function () {
        let participantes = "", responsaveis = "";

        if($("#ParticipantesArr").val()) {
            $("#ParticipantesArr").val().forEach(function (element, index, array){
                if($("#ParticipantesArr").val().length-1 !== index) {
                    participantes += element + ",";
                } else {
                    participantes += element;
                }
            });
        }

        if($("#ResponsaveisArr").val()) {
            $("#ResponsaveisArr").val().forEach(function (element, index, array){
                if($("#ResponsaveisArr").val().length-1 !== index) {
                    responsaveis += element + ",";
                } else {
                    responsaveis += element;
                }
            });
        }

        let responsaveisQuery = "";

         if($("#ResponsaveisArr").val()) {
             $("#ResponsaveisArr").val().forEach(function (element){
                 responsaveisQuery += ",5_" + element.replace(/\|/g,'');
             });
         }

        $.post("save.asp?I=<%=req("I")%>", $("#frm").serialize()+"&Participantes="+participantes+"&Responsaveis="+responsaveis, function(data){
            eval(data);
        });

        $("input[name^=NewTitulo]").each(function () {
            if ($(this).val() !== "") {
                 let codigo = $(this).attr("name");
                 codigo = codigo.replace("NewTitulo", "");

                 let Ordem = $("#NewOrdem"+codigo).val();
                 let Titulo = $("#NewTitulo"+codigo).val();
                 let TipoEstimado = $("#NewTipoEstimado"+codigo).val();
                 let TempoEstimado = $("#NewTempoEstimado"+codigo).val();

                 $.get("tarefaSave.asp?SprintID=<%=req("I")%>&tarefasSprints=true&Ordem="+Ordem+"&Titulo="+Titulo+"&TipoEstimado="+TipoEstimado+"&TempoEstimado="+TempoEstimado+"&Para="+participantes+"&Solicitantes="+responsaveisQuery, function(data){
                     eval(data);
                 });
            }
        });

        $("#tarefas").html("<div style='display: block;margin-left: auto;margin-right: auto;width: 50%;'><img src='assets/img/gif_cubo_alpha.gif'></div>");

        setTimeout(function(){
            $.post("TarefasSprints.asp?I=<%=req("I")%>", function(data){
                $("#tarefas").html(data);
            });
        } , 1500);


        return false;
    });

    function saveTarefa() {

        var Solicitantes = "";
        $("input[name^=Solicitante]").each(function () {
            Solicitantes += "," + $(this).val();
        });
    }
</script>