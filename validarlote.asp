<!--#include file="connect.asp"-->
<%

%>
<script type="text/javascript">
    $(".crumb-active a").html("Validar Lotes");
    $(".crumb-icon a span").attr("class", "far fa-check-square");
</script>

<br>
<style>
.sortfirstdec{
    width: 30%;
}
</style>
<div class="panel">
    <div class="panel-body">
        <form action="/feegow_components/api/validaCampo/validaTiss" id="FormValidarXML" enctype="multipart/form-data" >
        <label for="ArquivoXML">XML do lote</label>
        <input required name="file" type="file" id="ArquivoXML" accept=".xml">
        <br>*Obs: Baixe o xml do lote específico em <a href="https://clinic.feegow.com.br/v7/?P=tisslotes&Pers=1">Administrar Lotes</a>
<br><br><br>
        <button id="BtnValidarXML" class="btn btn-primary"> Validar</button>
        </form>

<div class="row"><br><br>
        <div class="col-md-12">
        <div id="ResultadoValidacao" style="display: none" class="alert alert-warning"></div></div></div>
    </div>
</div>
<script >
var $btnValidar = $("#BtnValidarXML");

var $Resultado = $("#ResultadoValidacao");

$('#FormValidarXML').on('submit',(function(e) {
        $btnValidar.attr("disabled", true);
        var formData = new FormData(this);

        $.ajax({
            type:'POST',
            url: $(this).attr('action'),
            data:formData,
            cache:false,        crossDomain: true,

            contentType: false,
            processData: false,
            success:function(data){
//                console.log("success");
//                console.log(data);

                $btnValidar.attr("disabled", false);

                data = data.replace("Arquivo recebido com sucesso. Iniciando processamento.","");
                data = data.replace("Validando estrutura do arquivo...","");
                data = data.replace("Verificando versão do TISS do arquivo...\
","");
                data = data.replace("Validando o HASH de segurança...","");

                $Resultado.addClass("alert-warning").removeClass("alert-success")

                if(data.indexOf("passou em todos os testes") > -1){
                    $Resultado.removeClass("alert-warning").addClass("alert-success")
                }


                $Resultado.fadeIn().html(data);
                $Resultado.find("a").not(".redirect-guia").remove();
            },
            error: function(data){
                console.log("error");
//                console.log(data);
            }
        });

        return false;
    }));
</script>