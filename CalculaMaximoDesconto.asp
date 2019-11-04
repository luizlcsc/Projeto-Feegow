<!--#include file="connect.asp"-->

<div id="DescontoMaximoUltrapassado" class="modal fade" role="dialog" style="display: none;">
  <div class="modal-dialog">

    <!-- Modal content-->
    <div class="modal-content">
    <form id="FormDescontoMaximoUltrapassado">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal">&times;</button>
            <h4 class="modal-title">Desconto máximo ultrapassado</h4>
          </div>
          <div class="modal-body" id="ModalDescontoMaximoConteudo">

          </div>
          <div class="modal-footer">
            <button type="button " class="btn btn-default btnfechar" data-dismiss="modal">Fechar</button>
            <button class="btn btn-default btnaguardar"  data-dismiss="modal">Aguardar Autorização</button>
            <button class="btn btn-primary btnconfirmar">Confirmar</button>
          </div>
      </form>
    </div>

  </div>
</div>

<script type="text/javascript">
var $DescontoMaximoUltrapassado = $("#DescontoMaximoUltrapassado");
var SenhaValida = false;
$(".btnfechar").on('click', function(){ $("#temregradesconto").val(1); recalc() });
$(".btnaguardar").on('click', function(){ 
    $("#temregradesconto").val(1);  
    recalc()
  });
$(".btnconfirmar").on('click', function(){
  $("#temregradesconto").val(0);
  if(!SenhaValida){
        desfazer()
    }
}); 

function desfazer(){
    $("#temregradesconto").val(0);  
    $(".CampoDesconto").val("0,00")
    $(".CampoDesconto ").each(function(value, i){
      recalc()
    })
    
  }
function CalculaDesconto(ValorUnitario, Desconto, TipoDesconto, ProcedimentoID, TipoFuncaoDesconto, $campoDesconto) {
        SenhaValida=false;

        function desfazDesconto(){
            var $descontoTotal = $("#DescontoTotal");
            if($descontoTotal){
                $descontoTotal.val("");
            }
            $campoDesconto.val("0,00").trigger("keyup");
        }

        $DescontoMaximoUltrapassado.on('hidden.bs.modal', function () {
          // do something…
            if(!SenhaValida){
                //desfazDesconto()
            }
        });
      
        $("#temregradesconto").val(1)
        $.get("VerificaMaximoDesconto.asp", {

            ProcedimentoID: ProcedimentoID,
            ValorUnitario: ValorUnitario,
            //Desconto: Math.round(Desconto),
            Desconto: Desconto,
            TipoDesconto: TipoDesconto,
            TipoFuncaoDesconto: TipoFuncaoDesconto //proposta / ct a receber

        }, function(data) {
            eval(data);
        });
}



$DescontoMaximoUltrapassado.find("form").submit(function() {
    SenhaValida = false;
    $.post("SenhaDeAdministradorValida.asp", {S: $("#SenhaAdministrador").val(), U: $('input[name=RegraUsuario]:checked').val()}, function(data) {
        data = parseInt(data);

        if (data===1){
            $DescontoMaximoUltrapassado.modal("hide");
            SenhaValida = true;
        }else{
            new PNotify({
                title: 'ERRO',
                text: 'Senha inválida.',
                type: 'danger',
                delay: 3000
            });
        }
    });

    return false;
});

</script>