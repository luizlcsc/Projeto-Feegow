<!--#include file="connect.asp"-->

<script type="text/javascript">
    $(".crumb-active a").html("Retorno bancário");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("Conciliar arquivo de retorno bancário");
    $(".crumb-icon a span").attr("class", "far fa-download");
</script>

<br>

<div class="panel">
    <div class="panel-body">
        <form action="/feegow_components/api/RetornoBancario/upload" id="FormRetorno" enctype="multipart/form-data" >
        <%=quickField("datepicker", "DataReferencia", "Data", 3, date(), "", "", " required")%>
        <label for="ArquivoXML">Arquivo de retorno</label>
        <input name="file" type="file" id="ArquivoRET" accept=".ret">
<br><br>
        <button id="BtnSubmit" class="btn btn-primary"> Baixar retorno</button>
        </form>

<div class="row"><br><br>
        <div class="col-md-12">
        <div id="ResultadoRetorno" style="display: none" class="alert alert-default">

<table class="table table-bordered">
    <thead>
        <tr>
            <th>DESCRIÇÃO</th>
            <th></th>
            <th>Vencimento</th>
            <th>Valor Titulo</th>
            <th>Banco</th>
            <th>Agência</th>
            <th>Tarifa</th>
            <th>Número</th>
            <th>Valor Pago</th>
            <th>Data do Pagamento</th>
            <th>Data do crédito</th>
            <th>Data da Tarica</th>
        </tr>
    </thead>
    <tbody>

    </tbody>
</table>
        </div></div></div>
    </div>
</div>
<script >
var $btnSubmit = $("#BtnSubmit");

var $Resultado = $("#ResultadoRetorno");

$('#FormRetorno').on('submit',(function(e) {
//        $btnSubmit.attr("disabled", true);
        var formData = new FormData(this);

        $.ajax({
            type:'POST',
            url: $(this).attr('action'),
            data:formData,
            cache:false,
            crossDomain: true,
            contentType: false,
            processData: false,
            success:function(data){
                if(data === "ERRO"){
                    alert("Data não encontrada. Faça o upload do arquivo.")
                }else{
                    $Resultado.fadeIn();
                   $Resultado.find("tbody").html(data);
                }

            },
            error: function(data){
                // console.log("error");
//                console.log(data);
            }
        });

        return false;
    }));
</script>