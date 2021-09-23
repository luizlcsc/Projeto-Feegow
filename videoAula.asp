<!--#include file="connect.asp"-->
<%
Titulo = ucase(req("T"))
Recurso = req("P")
Atualizar = req("Atualizar")

if Atualizar = "1" then
    Tempo = req("time")
    id = req("id")
    Comentario = req("comment")

    if Comentario <> "" then
        db.execute("UPDATE cliniccentral.videoaberto SET Comentario = '"&Comentario&"' WHERE id = "&id)
    else
        db.execute("UPDATE cliniccentral.videoaberto SET Permanencia = "&Tempo&" WHERE id = "&id)
    end if
else
    db.execute("insert into cliniccentral.videoaberto (LicencaID, UserID, Recurso) values ("& replace(session("Banco"), "clinic", "")&", "& session("User") &", '"& Recurso &"')")
    set AssistirVideoIDObj = db.execute("SELECT id FROM cliniccentral.videoaberto ORDER BY id DESC LIMIT 1")
    AssistirVideoID = 0

    if not AssistirVideoIDObj.eof then
        AssistirVideoID = AssistirVideoIDObj("id")
    end if

    %>
    <!DOCTYPE html>
    <html lang="pt">
        <head>
            <meta charset="UTF-8">
            <title>Vídeo-aula - <%= titulo %></title>
            <link rel="shortcut icon" href="assets/img/feegowclinic.ico" type="image/x-icon">
            <link href="css/bootstrap.min.css" rel="stylesheet" />
            <!--[if IE 7]>
            <link rel="stylesheet" href="assets/css/font-awesome-ie7.min.css" />
            <![endif]-->

            <link rel="stylesheet" type="text/css" href="assets/skin/default_skin/css/fgw.css">
            <link rel="stylesheet" type="text/css" href="assets/fonts/icomoon/icomoon.css">
            <link rel='stylesheet' type='text/css' href="../assets/css/font-awesome.min.css">
            <script type="text/javascript" src="assets/js/jquery.min.js"></script>
            <script type="text/javascript" src="ckeditornew/ckeditor.js"></script>
            <script src="ckeditornew/adapters/jquery.js"></script>
            <script src="vendor/jquery/jquery-1.11.1.min.js"></script>
        </head>
        <style>
            body{
                overflow-y: hidden;
            }
        </style>
        <body>
            <div class="panel">
                <div class="panel-heading">
                    <span class="panel-title"><%= Titulo %></span>
                    <span class="panel-controls"><button class="btn btn-default" onclick="window.close()">FECHAR</button></span>
                </div>
                <div class="panel-body">
                    <div class="row">

                        <%
                        set vca = db.execute("select * from cliniccentral.videoaula where Recurso='"& Recurso &"'")
                        if vca.eof then
                        %>
                        <h3>Esta vídeo-aula inda não está disponível para visualização. Volte em breve.</h3>
                        <div style="width:720px; height:480px; border:1px solid #111; background-color:#ccc; text-align:center; padding-top:220px">
                            <i class="far fa-spinner fa-spin"></i>
                        </div>
                        <%
                        else
                            %>
                            <div class="col-md-12">
                            <iframe
                            width="100%"
                            style="height: calc(100vh - 120px)"
                            src="https://www.youtube.com/embed/<%= vca("URL") %>"
                            frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

                            </div>
                            <script >
                                var id = parseInt("<%=AssistirVideoID%>");
                                var time = 0;

                                setInterval(function() {
                                    time += 10;
                                    $.get("videoAula.asp?P=<%=Recurso%>&T=<%=Titulo%>&Atualizar=1&id="+id+"&time="+time);
//                                    console.log(id)
                                }, 10000);

                                $("#Comentario").change(function() {
                                    $.get("videoAula.asp?Atualizar=1&id="+id+"&comment="+$(this).val());
                                });
                            </script>
                        <%end if %>
                    </div>
                </div>
            </div>

        </body>
    </html>
    <%
end if

%>