<!--#include file="connect.asp"-->
<div class="panel">
    <div class="panel-body">
        <%= quickfield("text", "ProcedimentoRapido", "Busca rápida de procedimento", 9, "", "", "", " placeholder='Digite a descrição ou código do procedimento ou nome técnico do procedimento...' ") %>
        <%=quickField("simpleSelect", "TipoProcedimento", "Tipo de Procedimento", 3, "", "SELECT * FROM tiposprocedimentos order by 2 ", "TipoProcedimento", "")%>
    </div>
</div>

<script type="text/javascript">
function changePesquisa(){
        let fil1 = $("#ProcedimentoRapido").val()
        let fil2 = $("#TipoProcedimento").val()

        if(!(fil1 || fil2)){
            $("#table-, .pagination-sm").show();
            $("#divProcedimentoRapido").html("");
        }else{
            $("#table-, .pagination-sm").hide();
            $("#divProcedimentoRapido").html("Buscando...");
            $.get("divProcedimentoRapidoResult.asp?tipo="+fil2+"&txt="+fil1, function(data){
                $("#divProcedimentoRapido").html(data);
            });
        }
    }
$(document).ready(function(){
    $("#ProcedimentoRapido").keyup(changePesquisa);
    $("#TipoProcedimento").change(changePesquisa);
});
</script>