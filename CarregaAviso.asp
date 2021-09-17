<!--#include file="connect.asp"-->
<%
AvisoID = req("AvisoID")

set AvisoSQL = db.execute("SELECT * FROM avisos WHERE id="&AvisoID)


%>
<h3><%= AvisoSQL("Titulo") %></h3>

<div><%= AvisoSQL("Texto") %></div>


<div class="row ">
    <hr>
    <button type="button" onclick="MarcarComoLido('<%=AvisoID%>')" class="mr10 btn btn-primary" style="float: right">
        <i class="far fa-check"></i> Marcar como lido
    </button>
</div>


<script >
    function MarcarComoLido(AvisoID){
        $.post("AvisosLido.asp", {
            MarcarComoLido: 1,
            AvisoID: AvisoID
        });
        closeComponentsModal();
    }
</script>