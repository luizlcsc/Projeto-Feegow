<!--#include file="connect.asp"-->
<%
'fecha ponto de ontem se a pessoa esqueceu
fechaPonto(session("User"))

if req("Bater")="1" then
    set vcNULL = db.execute("select id from ponto where isnull(Fim) and Data=curdate() and UsuarioID="&session("User"))
    if vcNULL.eof then
        db_execute("insert into Ponto (UsuarioID, Data, Inicio, IP, Device) values ("&session("User")&", curdate(), curtime(), '"&request.ServerVariables("REMOTE_ADDR")&"', '"&device()&"')")
    else
        db_execute("update ponto set Fim=curtime() where id="&vcNULL("id"))
    end if
    response.redirect("./?P=Ponto&Pers=1")
end if



%>
<script type="text/javascript">
    $(".crumb-active a").html("Ponto Eletrônico");
    $(".crumb-icon a span").attr("class", "far fa-hand-o-up");
</script>

<br>
<div class="panel">
    <div class="panel-body">
        <div class="clearfix form-actions">
            <h3 class="text-center"><%=tempoTrab(session("User"), "Status") %></h3>
            <hr />
            <div class="row">
                <div class="col-md-4 col-md-offset-4"><button type="button" onclick="location.href='./?P=Ponto&Pers=1&Bater=1';" class="btn btn-block btn-primary btn-lg">BATER PONTO</button></div>
            </div>
            <hr />
            <div class="row">
                <%=tempoTrab(session("User"), "Grafico") %>
            </div>
        </div>
        <div class="row">
            <h1><%'=tempoTrab(session("User"), "Min") %> </h1>
        </div>

    </div>
</div>

