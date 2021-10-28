<!--#include file="connect.asp"-->
<div class="panel">
<% 
    pag = req("P")

%>
    <div class="panel-body">
        <%= quickfield("text", "PreparoResticaoRapido", "Busca Rápida", 12, "", "", "", " placeholder='Digite a descrição...' ") %>
    </div>
</div>

<script type="text/javascript">
$(document).ready(function(){
    $("#PreparoResticaoRapido").keyup(function(){
        if($(this).val()==''){
            $("#table-, .pagination-sm").css("display", "block");
            $("#divProcedimentoRapido").html("");
        }else{
            $("#table-, .pagination-sm").css("display", "none");
            $("#divProcedimentoRapido").html("Buscando...");
            $.get("divRestricaoPreparoRapidoResult.asp?pag=<%=pag%>&txt="+$(this).val(), function(data){
                $("#divProcedimentoRapido").html(data);
            });
        }
    });
});
</script>