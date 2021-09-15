<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="Classes/Json.asp"-->
<%
IF ref("Titulo") <> "" THEN
    ID          = ref("ID")
    Titulo      = ref("Titulo")
    Conteudo    = ref("Conteudo")
    Ativo       = ref("Ativo")
    Grupos      = ref("Grupos")
    Usuarios    = ref("Usuarios")
    DataInicio  = myDateTISS(ref("DataInicio"))
    DataFim     = myDateTISS(ref("DataFim"))

    IF ID = "" THEN
        SQL = " INSERT INTO sistemademensagens(Titulo,Conteudo,Ativo,Grupos,Usuarios,DataInicio,DataFim,sysActive)"&chr(13)&_
              " VALUES (NULLIF('"&Titulo&"',''),NULLIF('"&Conteudo&"',''),NULLIF('"&Ativo&"',''),NULLIF('"&Grupos&"',''),NULLIF('"&Usuarios&"',''),NULLIF('"&DataInicio&"',''),NULLIF('"&DataFim&"',''),1)"
        db.execute(SQL)
        set IDreq = db.execute("SELECT LAST_INSERT_ID() AS ID")
        ID = IDreq("ID")
    ELSE
        SQL = " UPDATE sistemademensagens               "&chr(13)&_
              " SET Titulo   = NULLIF('"&Titulo&"','')    "&chr(13)&_
              " ,Conteudo    = NULLIF('"&Conteudo&"','')  "&chr(13)&_
              " ,Ativo       = NULLIF('"&Ativo&"','')     "&chr(13)&_
              " ,Grupos      = NULLIF('"&Grupos&"','')    "&chr(13)&_
              " ,Usuarios    = NULLIF('"&Usuarios&"','')  "&chr(13)&_
              " ,DataInicio  = NULLIF('"&DataInicio&"','')"&chr(13)&_
              " ,DataFim     = NULLIF('"&DataFim&"','')   "&chr(13)&_
              " WHERE id     = '"&ID&"';                  "
        db.execute(SQL)
    END IF

END IF

IF req("I") <> "" AND req("I") <> "N" THEN
    set reg     = db.execute("SELECT * FROM sistemademensagens WHERE id = "&req("I"))
    ID          = reg("ID")
    Titulo      = reg("Titulo")
    Conteudo    = reg("Conteudo")
    Ativo       = reg("Ativo")
    Grupos      = reg("Grupos")
    Usuarios    = reg("Usuarios")
    DataInicio  = reg("DataInicio")
    DataFim     = reg("DataFim")
END IF


sqlUsuarios = " SELECT                                                                             "&chr(13)&_
              "    DISTINCT                                                                        "&chr(13)&_
              "    sys_users.id as id,                                                             "&chr(13)&_
              "    coalesce(profissionais.NomeProfissional,funcionarios.NomeFuncionario) as Nome   "&chr(13)&_
              " FROM sys_users                                                                     "&chr(13)&_
              " LEFT JOIN profissionais              ON sys_users.`Table`       = 'profissionais'  "&chr(13)&_
              "                                     AND sys_users.idInTable     = profissionais.id "&chr(13)&_
              "                                     AND profissionais.sysActive = 1                "&chr(13)&_
              " LEFT JOIN funcionarios               ON sys_users.`Table`  = 'Funcionarios'        "&chr(13)&_
              "                                     AND sys_users.idInTable = funcionarios.id      "&chr(13)&_
              "                                     AND funcionarios.sysActive = 1                 "&chr(13)&_
              " WHERE profissionais.sysActive                                                      "&chr(13)&_
              " ORDER BY 2                                                                         "

%>
<script src="assets/js/estrela.js" type="text/javascript"></script>
<script>
$(".crumb-active a").html("Sistema de Mensagem");
$(".crumb-icon a span").attr("class", "far fa-comments");
</script>
<br/>
<form id="frm" method="post">
<div class="col-md-8">
        <div class="panel">
            <div class="panel-body">
                <div class="row">
                    <div style="margin-top: 10px;float: right">                    </div>
                    <div class="col-md-12">
                        <label>Título</label><br>
                        <div class="input-group">
                            <span for="firstname" class="input-group-addon">
                                <i class="far fa-search"></i>
                            </span>
                            <input type="hidden" name="ID" value="<%=ID%>" >
                            <input type="text" class="form-control" id="Titulo" name="Titulo" value="<%=Titulo%>" autocomplete="off" required="">
                        </div>
                    </div>
                </div>
                <hr class="short alt">
                <div class="row" style="margin: 10px;">
                    <textarea class="form-control" name="Conteudo" id="Conteudo" style="visibility: hidden; display: none;"><%=Conteudo%></textarea>
                    <script>
                        $(function () {
                            CKEDITOR.config.shiftEnterMode= CKEDITOR.ENTER_P;
                            CKEDITOR.config.enterMode= CKEDITOR.ENTER_BR;
                            CKEDITOR.config.height = 200;
                            $('#Conteudo').ckeditor();
                        });
                    </script>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-4">
        <div class="panel">
            <div class="panel-heading">
                <span class="panel-controls">
                    <button class="btn btn-sm btn-primary" id="save">&nbsp;&nbsp;<i class="far fa-save"></i> <strong>SALVAR</strong>&nbsp;&nbsp;</button>
                </span>
            </div>
            <div class="panel-body">
                <div class="row">
                    <div class="col-md-12" style="text-align: right; padding-right:30px ">
                        <label>Ativo</label>
                        <div></div>
                        <div class="switch " style="float:right">
                            <input type="checkbox" <%IF Ativo = "1" THEN%> checked <%END IF%> name="Ativo" id="Ativo" value="1">
                            <label for="Ativo"></label>
                        </div>
                    </div>
                    <%=quickField("multiple", "Grupos", "Grupos Alvo", 12, Grupos, "SELECT * FROM regraspermissoes", "Regra", " empty")%>
                    <%=quickField("multiple", "Usuarios", "Usuários Alvo", 12, Usuarios, sqlUsuarios, "Nome", " empty")%>
                    <%= quickField("datepicker", "DataInicio", "Data Início", 12, DataInicio, "", "", " placeholder='Data Início'") %>
                    <%= quickField("datepicker", "DataFim", "Data Fim", 12, DataFim, "", "", " placeholder='Data Fim'") %>
                    <br/>
                    <br/>&nbsp;
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-12">
    <div id="timeline" class="mt30" style="display: none">
              <!-- Timeline Divider -->
              <div class="timeline-divider mtn">
<!--                <div class="divider-label">2013</div>-->
                <div class="pull-right">
                  <button id="timeline-toggle" class="btn btn-default btn-sm">
                    <span class="ad ad-lines fs16 lh20"></span>
                  </button>
                </div>
              </div>
              <div class="row content"></div>
              <!-- Timeline Divider -->
              <div class="timeline-divider">
<!--                <div class="divider-label">2012</div>-->
              </div>
            </div>
    </div>
</form>
<script>

    <% sqlComentarios = " SELECT                                                                                                   "&chr(13)&_
                        "        sistemademensagens_comentarios.*,                                                               "&chr(13)&_
                        "        COALESCE(profissionais.NomeProfissional,funcionarios.NomeFuncionario) AS nome,                    "&chr(13)&_
                        "        COALESCE(NULLIF(profissionais.Foto,''),NULLIF(funcionarios.Foto,''),'assets/img/user.png') AS foto"&chr(13)&_
                        "      FROM sistemademensagens_comentarios                                                               "&chr(13)&_
                        "      JOIN sys_users     ON sys_users.id = sistemademensagens_comentarios.UsuarioID                     "&chr(13)&_
                        " LEFT JOIN profissionais ON profissionais.id  = sys_users.idInTable                                       "&chr(13)&_
                        "                        AND sys_users.`Table` = 'profissionais'                                           "&chr(13)&_
                        " LEFT JOIN funcionarios  ON funcionarios.id  = sys_users.idInTable                                        "&chr(13)&_
                        "                        AND sys_users.`Table` = 'funcionarios'                                            "&chr(13)&_
                        " WHERE NotificacaoID = '"&req("I")&"';                                                                    "&chr(13)&_
                        "                                                                                                          " %>

    notificacoes = <%=recordToJSON(db.execute(sqlComentarios)) %>

    var html = "";
    var flag = false;
    notificacoes.forEach((item) => {
        flag = !flag;
        direction = flag?'left-column':'right-column';

        html += `
        <div class="col-sm-6 ${direction}">
              <div class="timeline-item">
                <div class="timeline-icon">
                    <img src="${item.foto}" width="100%" />
                </div>
                <div class="panel">
                  <div class="panel-body p10">
                    <blockquote class="mbn ml10">
                      <p>${item.Comentario}</p>
                      <small>${item.nome}</small>
                    </blockquote>
                  </div>
                </div>
              </div>
            </div>`
    });

    $(".content").html(html);
    $(".timeline").show();


</script>
