<!--#include file="connect.asp"-->
<div class="panel">
    <div class="panel-body">
        <%= quickfield("text", "ProtocoloRapido", "Busca rápida de Protocolo", 9, "", "", "", " placeholder='Digite a descrição ou o código do Protocolo...' ") %>
        <%= quickField("simpleSelect", "TipoProtocolo", "Tipo de Protocolo", 3,   "", "SELECT * FROM protocolosgrupos order by 2 ", "NomeGrupo", "")%>
    </div>
</div>

<script type="text/javascript">
function changePesquisa(){
        let fil1 = $("#ProtocoloRapido").val()
        let fil2 = $("#TipoProtocolo").val()

        if(!(fil1 || fil2)){
            $("#table-, .pagination-sm").show();
            $(".target").html("");
        }else{
            $("#table-, .pagination-sm").hide();
            $(".target").html("Buscando...");
            $.get("divProtocoloRapidoResult.asp?tipo="+fil2+"&txt="+fil1, function(data){
                $(".target").html(data);
            });
        }
    }
$(document).ready(function(){
    $("#divProcedimentoRapido").parent().addClass('target')
    $("#ProtocoloRapido").keyup(changePesquisa);
    $("#TipoProtocolo").change(changePesquisa);
});
</script>