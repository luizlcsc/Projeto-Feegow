/* ----------------------------------------------------------------------------------------------------------------------
	JS MEDICAMENTOS
---------------------------------------------------------------------------------------------------------------------- */

var medicamentosVinculados  = function(){

    var $opts = {};
	var _optsDefaults = {
        'medicamentoPrescritoID'        :   '',
        'medicamentoPrescritoSeletor'   :   'prescrito',
        'actionWarp'                    :   '',
        'selecionados'                  :   [],
        'data'                          :   [],
        'last'                          :   0,
        'fns'                           :   null
	};

    function init(opts,fns){
        opts.fns = fns
        $opts = setDefaults(opts, _optsDefaults);
        getInfoPrescrito($opts.medicamentoPrescritoID, (data)=>{
            $(`#${$opts.medicamentoPrescritoSeletor}`).append(`<option selected value=${$opts.medicamentoPrescritoID}>${data.NomeProduto}</option>`)
        })
        getVinculo()
        getOpcoes()

        $('.removeRow').click((event)=>{
            removeRow(event)
        })
    }
    function getInfoPrescrito (id,callback){
        request(`produto/getInfoProduto`,`id=${id}`,(data)=>{
            data = JSON.parse(data)[0]
            callback(data)
        })
    }
    function getVinculo (){
        request(`produto/getVinculos`,`id=${$opts.medicamentoPrescritoID}`,(data)=>{
            data = JSON.parse(data)
            if (data.length > 0){
                data.map((item)=>{
                    getInfoPrescrito(item.produtoSubistitutoID,(data)=>{
                        newRow(data)
                    })
                })
            }
        })
    }
    function getOpcoes(){
        request(`produto/getInfoProduto`,``,(data)=>{
            data = JSON.parse(data)
            $opts.data = data
        })
    }

    function newRow(row=false){
        event.preventDefault()
        $opts.last ++
        let base = `
        <div id='item-${$opts.last}' class="formFlex mt20">
            <label class="col-md-4 control-label">Medicamento Padrão</label>
            <div class='col-md-8'>
                <select class="form-control col-md-10">
                    <option value='0' selected>Selecione um medicamento para vincular</option>
                    ${$opts.data.map((ele)=>{
                        if(ele.id != $opts.medicamentoPrescritoID){
                            return `<option ${(row.id == ele.id?'selected':'')} value='${ele.id}' >${ele.NomeProduto}</option>`
                        }
                    })}
                </select>
                <div class='btn-area col-md-3'>
                    <button class='removeRow btn btn-danger col-md-6' onClick='medicamentosVinculados.removeRow("#item-${$opts.last}")' ><i class="fa fa-trash"></i></button>
                </div>
            </div>
        </div>`

        $(`#${$opts.actionWarp}`).append(base)
    }

    function removeRow (selector){
        event.preventDefault()
        let deletedValue = $(selector).find('input.ordem').val()
        $(selector).detach()
        let inputs = $('.ordem')
        $opts.last --
    }

    function request (caminho,parametros,callback=false){
        let url = `${caminho}.asp?${parametros}`
        $.get( url )
        .done(function(data) {
            callback(data)
        })
    }

    function setDefaults(params, defaults){
        var recursive = true;
        return $.extend(recursive, {}, defaults, params);
    }

    function salvarVinculacao (){
        event.preventDefault()

        validate(function (selecionados){
            request(`produto/removeVinculos`,`produto=${$opts.medicamentoPrescritoID}`,(data)=>{
                selecionados.map( function (ele,key){
                    request(`produto/salvarProduto`,`produtoID=${$opts.medicamentoPrescritoID}&subistitutoID=${ele}&ordem=${key}`,(data)=>{
                        return true
                    })
                })
                new PNotify({
                    title:  'Salvo',
                    text:   'Vinculação salva com sucesso.',
                    type:   'success',
                    delay:  5000
                });
            })
        })
    }

    function validate (callback){
        let selects = $('div[id^="item-"]').find('select')
        let selecionados = []
        selects.map((key,ele)=>{
            let selecionado = $(ele).val()
            if(selecionado == 0){
                new PNotify({
                    title:  'Erro',
                    text:   'Caso não exista item selecionado favor apagar a vinculação.',
                    type:   'error',
                    delay:  5000
                });
                return false
            }

            if(selecionados.length > 0){
                let existe = false
                selecionados.map((sel)=>{
                    if(sel == selecionado){
                        new PNotify({
                            title:  'Erro',
                            text:   'Existe vinculação duplicada.',
                            type:   'error',
                            delay:  5000
                        });
                        existe = true
                        return false
                    }
                })
                if(!existe){
                    selecionados.push(selecionado)
                }

            }else{
                selecionados.push(selecionado)
            }
        })
        callback(selecionados)
    }
    /**
     * Funções externadas
     */
    return {
        init                : init,
        request             : request,
        setDefaults         : setDefaults,
        newRow              : newRow,
        removeRow           : removeRow,
        salvarVinculacao    : salvarVinculacao
    };
}()