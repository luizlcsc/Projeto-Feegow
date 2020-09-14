/* ----------------------------------------------------------------------------------------------------------------------
	JS MEDICAMENTOS
---------------------------------------------------------------------------------------------------------------------- */

var medicamentosConvenio  = function(){

    var $opts = {};
	var _optsDefaults = {
        'select'                        :   'medicamentoConvenio',
        'last'                          :   0,
        'data'                          :   [],
        'fns'                           :   {}
	};

    function init(opts,fns){
        opts.fns = fns
        $opts = fns.utilitarios.setDefaults(opts, _optsDefaults);
        getMedicamentos()
    }

    function getMedicamentos(){
        $opts.fns.utilitarios.request('convenio/getMedicamento','',(data)=>{
            data = JSON.parse(data)
            $opts.data = data
            console.log(data)
        })
    }



    function newRow(row=false){
        event.preventDefault()
        let base = `
        <div class='row'>
            <div id='item-${$opts.last}' class="formFlex mt20">
                <div class='col-md-3'>
                    <label class="col-md-12 control-label">Convênios</label>
                    <div class='convenioBtn'></div>
                </div>
                <div class='col-md-3'>
                    <label class="col-md-12 control-label">Medicamento Prescrito</label>
                    <select class="form-control col-md-12 prescrito">
                        <option>Selecione o medicamento prescrito</option>
                        ${$opts.data.map((ele)=>{
                            return `<option value='${ele.id}'>${ele.NomeProduto}</option>`
                        })}
                    </select>
                </div>
                <div class='col-md-3'>
                    <label class="col-md-12 control-label">Medicamento Referência (Convênio)</label>
                    <select class="form-control col-md-12 referencia">
                    <option>Selecione o medicamento referência</option>
                    ${$opts.data.map((ele)=>{
                        return `<option value='${ele.id}'>${ele.NomeProduto}</option>`
                    })}
                    </select>
                </div>
                <div class='col-md-3'>
                    <label class="col-md-12 control-label clearText">teste</label>
                    <div class='btn-area col-md-12'>
                        <button style='display:none' class='btnPlanos${$opts.last} btn btn-warning col-md-4'><i class="fa fa-lock"></i> Planos</button>
                        <button class='removeRow btn btn-danger col-md-2 ml20' onClick='medicamentosConvenio.removeRow("#item-${$opts.last}")' ><i class="fa fa-trash"></i></button>
                    </div>
                </div>
            </div>
        </div>`

        $(`#${$opts.select}`).append(base)
        $opts.fns.convenioBtn.createRow(`item-${$opts.last}`,['16'])
        $opts.last ++
    }

    function removeRow (selector){
        event.preventDefault()
        $(selector).detach()
        $opts.last --
    }

    
    /**
     * Funções externadas
     */
    return {
        init                : init,
        newRow              : newRow,
        removeRow           : removeRow
    };
}() 