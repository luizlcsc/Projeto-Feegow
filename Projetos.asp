<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<script type="text/javascript">
    function log(){$('#modal-table').modal('show');$.get('DefaultLog.asp?R=projetos&I=<%= req("I")%>', function(data){$('#modal').html(data);})}

    $(".crumb-active a").html("Gerenciar Projetos");
    $(".crumb-link").removeClass("hidden");
    <% if req("I") = "N" then %>
        $(".crumb-link").html("criando novo projeto");
    <% else %>
        $(".crumb-link").html("editando projeto");
    <% end if %>
    $(".crumb-icon a span").attr("class", "far fa-th-large");
    <%
        btnIncluir = ""
        if PermitirI = 1 then
            btnIncluir = " <a title='Novo' href='?P=tarefas&Pers=1&I=N' class='btn btn-sm btn-default'><i class='far fa-plus'></i></a> "
        end if
    %>
    $("#rbtns").html('<a title="Lista" href="?P=listaProjetos&Pers=1" class="btn btn-sm btn-default"><i class="far fa-list"></i></a> <a title="Histórico de Alterações" href="javascript:log()" class=\"btn btn-sm btn-default hidden-xs\"><i class=\"far fa-history\"></i></a>');
</script>

<%
call insertRedir(req("P"), req("I"))
    sql = " SELECT p.id,                                                           "&chr(13)&_
          "        p.Titulo,                                                       "&chr(13)&_
          "        p.Descricao,                                                    "&chr(13)&_
          "        p.PrioridadeID,                                                 "&chr(13)&_
          "        p.Participantes,                                                "&chr(13)&_
          "        p.Responsaveis,                                                 "&chr(13)&_
          "        p.DataPrazo,                                                    "&chr(13)&_
          "        tp.Prioridade,                                                  "&chr(13)&_
          "        p.StatusID                                                      "&chr(13)&_
          " FROM projetos p                                                        "&chr(13)&_
          " LEFT JOIN cliniccentral.tarefasprioridade tp ON tp.id = p.PrioridadeID "&chr(13)&_
          " LEFT JOIN cliniccentral.projetosstatus ps ON ps.id = p.StatusID        "&chr(13)&_
          " WHERE p.id =                                                           "& req("I")

    projeto = db.execute(sql)

    if not isnull(projeto("Titulo")) then
        Titulo = projeto("Titulo")
        Descricao = projeto("Descricao")
        DataPrazo = projeto("DataPrazo")
        PrioridadeID = projeto("PrioridadeID")
        Participantes = projeto("Participantes")
        Responsaveis = projeto("Responsaveis")
        StatusID = projeto("StatusID")
    else
        Titulo = ""
        Descricao = ""
        DataPrazo = ""
        PrioridadeID = ""
        Participantes = ""
        Responsaveis = ""
        StatusID = ""
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

            <input type="hidden" name="P" value="projetos" />
            <input type="hidden" name="I" value="<%= req("I") %>" />
            <input type="hidden" name="sysActive" value="1" />
            <div class="row">
                <%=quickField("text", "Titulo", "Título", 7, Titulo, "", "", " maxlength='250' required ")%>
                <%=quickfield("simpleSelect", "CentroCustoID", "Centro de Custo", 3, CentroCustoID, "select id, NomeCentroCusto from centrocusto ORDER BY id", "NomeCentroCusto", " semVazio ") %>
                <%=quickfield("simpleSelect", "PrioridadeID", "Prioridade", 2, PrioridadeID, "select id, Prioridade from cliniccentral.tarefasprioridade ORDER BY id", "Prioridade", " semVazio ") %>
            </div>
            <div class="row">
                <%=quickField("multiple", "ResponsaveisArr", "Responsáveis", 3, Responsaveis, "SELECT DISTINCT p.id, NomeProfissional FROM profissionais p INNER JOIN sys_users su ON su.idInTable = p.id WHERE sysActive = 1 AND Ativo = 'on' ORDER BY NomeProfissional", "NomeProfissional", " ")%>
                <%=quickField("multiple", "ParticipantesArr", "Participantes", 4, Participantes, "SELECT DISTINCT p.id, NomeProfissional FROM profissionais p INNER JOIN sys_users su ON su.idInTable = p.id WHERE sysActive = 1 AND Ativo = 'on' ORDER BY NomeProfissional", "NomeProfissional", " ")%>
                <%=quickfield("simpleSelect", "StatusID", "Status", 3, StatusID, "select id, Descricao from cliniccentral.projetosstatus ORDER BY id", "Descricao", " semVazio ") %>
                <%=quickField("datepicker", "DataPrazo", "Prazo", 2, DataPrazo, "", "", " required ")%>
            </div>
            <div class="row" style="margin-top:20px">
                <div class="col-md-12">
                    <label for="Descricao">Descrição</label>
                    <textarea type="text" class="form-control" name="Descricao" id="Descricao"><%=Descricao%></textarea>
                </div>
            </div>

    </div>
</div>
</form>


<hr class="short alt" />
<h4 style="margin: 5px"><i class="far fa-tasks"></i> Tarefas Vinculadas</h4>
<div id="tarefas" class="tab-pane chat-widget active" role="tabpanel">
    <%server.Execute("TarefasProjetos.asp") %>
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

                 $.get("tarefaSave.asp?ProjetoID=<%=req("I")%>&tarefasProjetos=true&Ordem="+Ordem+"&Titulo="+Titulo+"&TipoEstimado="+TipoEstimado+"&TempoEstimado="+TempoEstimado+"&Para="+participantes+"&Solicitantes="+responsaveisQuery, function(data){
                     eval(data);
                 });
            }
        });

        $("#tarefas").html("<div style='display: block;margin-left: auto;margin-right: auto;width: 50%;'><img src='assets/img/gif_cubo_alpha.gif'></div>");

        setTimeout(function(){
            $.post("TarefasProjetos.asp?I=<%=req("I")%>", function(data){
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