<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->
<%
sqlBloquear = "select ProtocoloID from pacientesprotocolosmedicamentos where sysActive = 1"
bloquear = recordToJSON(db.execute(sqlBloquear))

%>

<div class="panel">
    <div class="panel-body">
        <%= quickfield("text", "ProtocoloRapido", "Busca rápida de Protocolo", 9, "", "", "", " placeholder='Digite a descrição ou o código do Protocolo...' ") %>
        <%= quickField("simpleSelect", "TipoProtocolo", "Tipo de Protocolo", 3,   "", "SELECT * FROM protocolosgrupos order by 2 ", "NomeGrupo", "")%>
    </div>
</div>

<script type="text/javascript">
    let bloquear = JSON.parse('<%=bloquear%>');

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
                bloquearBtn()
            });
        }
    }
$(document).ready(function(){
    $("#divProcedimentoRapido").parent().addClass('target')
    $("#ProtocoloRapido").keyup(changePesquisa);
    $("#TipoProtocolo").change(changePesquisa);

    bloquearBtn()
});

function bloquearBtn(){

    links = $('.btn.btn-xs.btn-info.tooltip-info')

    links.map((key,link)=>{
        let href = $(link).attr('href')
        bloquear.map((block)=>{
            console.log(block)
            if(href.indexOf(`I=${block.ProtocoloID}`)>0){
                $(link).parent().find('.btn.btn-xs.btn-danger.tooltip-danger').attr('disabled',true)
            }
        })
    })
}
</script>