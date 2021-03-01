/* ----------------------------------------------------------------------------------------------------------------------
	JS PARA CARREGAR O SELECT
---------------------------------------------------------------------------------------------------------------------- */

var changeUnidades = function(){
    var $opts = {};
	var _optsDefaults = {
        'seletor'			:   '',
        'target'            :   '',
        'fns'               :   null
	};

    function init(opts,fns){
        opts.fns = fns
        $opts = fns.setDefaults(opts, _optsDefaults);
        changeEvent()
    }

    function changeEvent(){
        $(`#${$opts.seletor}`).change((event)=>{
            let unidade = $(event.target).val()
            $.get("MioloExtratoGetLancadoPor.asp?unidade="+unidade,function(data){ 
                data = JSON.parse(data)
                applyNewData(data)
            });
        })
    }

    function applyNewData(data){
        let html = '<option value="0">Selecione</option>'
        data.map((elem)=>{
            let opcao = `<option value="${elem.id}">${elem.Nome}</option>`
            html += opcao
        })
        $(`#${$opts.target}`).val('')
        $(`#select2-${$opts.target}-container`).attr('title','')
        $(`#select2-${$opts.target}-container`).html('')
        $(`#${$opts.target}`).html(html)
    }    
    /**
     * Funções externadas
     */
    return {
        init                : init,
    };

    //uso <div id='qfProfissionais2' class='col-md-3 ajaxFilter' data-label='Profissionais'></div>
}()