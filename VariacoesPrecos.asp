<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<%
if req("Ins")="1" then
    db_execute("insert into varprecos () values ()")
    response.redirect("./?P="& req("P") &"&Pers=1")
end if

%>

<br />
<div class="panel">
    <div class="panel-body" id="divVarPrecos">
        <% server.execute("VariacoesPrecosConteudo.asp") %>
    </div>
</div>

<script type="text/javascript">

    function editVP(I) {
        $("#modal-table").modal("show");
        $("#modal").html("<center class='p20'><i class='far fa-circle-o-notch fa-spin'></i></center>")
        $.get("VariacoesPrecosConteudo.asp?I=" + I, function (data) {
            $("#modal").html(data);
        });
}


    $(".crumb-active a").html("Variações de Preços");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("crie as combinações para preços diferenciados de procedimentos");
    $(".crumb-icon a span").attr("class", "far fa-usd");
    <%
    if aut("variacoesprecosI")=1 then
    %>
    $("#rbtns").html('<a class="btn btn-sm btn-success pull-right" href="./?P=<%=req("P")%>&Pers=1&Ins=1"><i class="far fa-plus"></i><span class="menu-text"> Inserir</span></a>');
    <%
    end if
    %>
</script>