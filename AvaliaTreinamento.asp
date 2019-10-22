<!--#include file="connect.asp"-->
<div class="panel mt20">
    <div class="panel-body">
    <%
    set t = db.execute("select *, Date(Inicio) Data, time(Inicio) Hora from clinic5459.treinamentos where isnull(Nota) and LicencaUsuarioID="& session("User"))
    while not t.eof
        Data = t("Data")
        if Data=date() then
            Data = " hoje "
        elseif Data=date()-1 then
            Data = " ontem "
        else
            Data = " em "& Data &" "
        end if
        Hora = ft(t("Hora"))
        %>
        <h1>Você recebeu um treinamento de <%= nameInTable(t("AnalistaID")) &" "& Data &" às "& Hora %> </h1>

        <div class="row">
            <div class="col-md-10">
                <h2 class="col-md-12 blue">
                    Por favor, avalie o treinamento recebido: <span style="cursor:pointer" id="stars-existing" class="starrr text-warning" data-rating=''></span>
                </h2>

                <%= quickfield("memo", "Observacoes", " ", 12, "", "", "", " placeholder='Ajude-nos a melhorar! Deixe suas observações, críticas e sugestões sobre o treinamento recebido.' rows='6' ") %>
            </div>
            <div class="col-md-2 text-center">
                <img class="img-thumbnail" src="https://clinic7.feegow.com.br/<%= fotoInTable(t("AnalistaID")) %>" />
                <hr class="short alt" />
                <%= nameInTable(t("AnalistaID")) %>
            </div>
        </div>

        <%
    t.movenext
    wend
    t.close
    set t = nothing
    %>
    </div>
</div>
<script src="assets/js/estrela.js" type="text/javascript"></script>
