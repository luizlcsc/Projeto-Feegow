<!--#include file="connect.asp"-->
<div class="panel">
    <div class="panel-body">
        <%= quickfield("text", "ConvenioRapido", "Busca rápida de Convênio", 12, "", "", "", " placeholder='Digite a descrição ou o código do connvênio...' ") %>
    </div>
</div>

<script type="text/javascript">
$(document).ready(function(){
    $("#ConvenioRapido").keyup(function(){
        if($(this).val()==''){
            $("#table-, .pagination-sm").show();
            $("#divProcedimentoRapido").html("");
        }else{
            $("#table-, .pagination-sm").hide();
            $("#ConvenioRapido").html("Buscando...");
            $.get("divConvenioRapidoResult.asp?txt="+$(this).val(), function(data){
                $("#divProcedimentoRapido").html(data);
            });
        }
    });
});
</script>