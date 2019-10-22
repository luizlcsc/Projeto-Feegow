<!--#include file="connect.asp"-->
<div class="panel">
    <div class="panel-body">
        <%= quickfield("text", "ProcedimentoRapido", "Busca rápida de procedimento", 12, "", "", "", " placeholder='Digite a descrição ou o código do procedimento...' ") %>
    </div>
</div>

<script type="text/javascript">
$(document).ready(function(){
    $("#ProcedimentoRapido").keyup(function(){
        if($(this).val()==''){
            $("#table-, .pagination-sm").css("display", "block");
            $("#divProcedimentoRapido").html("");
        }else{
            $("#table-, .pagination-sm").css("display", "none");
            $("#divProcedimentoRapido").html("Buscando...");
            $.get("divProcedimentoRapidoResult.asp?txt="+$(this).val(), function(data){
                $("#divProcedimentoRapido").html(data);
            });
        }
    });
});
</script>