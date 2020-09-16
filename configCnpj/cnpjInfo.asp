
<div class="panel">
    <div class="panel-heading">Cnpj info</div>
    <div class="panel-body">
        <form id='cnpjConfig'>
            <div class="form-group col-md-6">
                <label for="cnpj">CNPJ</label>
                <input type="text" class="form-control" id="cnpj" placeholder="Cnpj">
            </div>
            <div class="form-group col-md-6">
                <label for="">Simples Nacional</label>
                <br/>
                <label for="optante">
                    <input type="radio" name="optante" id="sn1" value="true" checked> Optante
                    <input class="ml10" type="radio" name="optante" id="sn2" value="false"> Não optante
                </label>
            </div>
        </form> 
            <div class="form-group col-md-offset-6 col-md-6">
                <button class="btn btn-success col-md-2 col-md-offset-10" onclick="saveCnpjConfig()">Enviar</button>
            </div>
    </div>
</div>

<script>
function saveCnpjConfig(){
    let optante = $("#cnpjConfig").serialize()
    let cnpj  = $("#cnpj").val().replace(/\./g,"").replace('/','').replace('-','')

    if(cnpj.length < 10){
        new PNotify({
            title: 'CNPJ',
            text: 'Cnpj precisa estar preenchido',
            type: 'danger',
            delay: 10000
        });
        return false
    }

     $.get("./configCnpj/cnpjinfoSave.asp?cnpj="+cnpj+"&"+optante, function (data) {
        new PNotify({
            title: 'Salvo',
            text: 'Cnpj configurado com sucesso',
            type: 'success',
            delay: 10000
        });
    });
}
$( document ).ready(function() {
    $("#cnpj").mask("99.999.999/9999-99");    
});
</script>