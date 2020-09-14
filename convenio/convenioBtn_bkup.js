/* ----------------------------------------------------------------------------------------------------------------------
	JS MEDICAMENTOS
---------------------------------------------------------------------------------------------------------------------- */

var convenioBtn  = function(){

    var $opts = {};
	var _optsDefaults = {
        'select'                        : 'convenioBtn',
        'campo1'                        : 'id',
        'campo2'                        : 'Nome',
        'last'                          : 0,
        'planos'                        : [],
        'fns'                           : {},
        'config'                        : {
            enableFiltering: true,
            enableCaseInsensitiveFiltering: true,
            filterPlaceholder: 'Filtrar ...',
            allSelectedText: 'Todos Selecionados',
            maxHeight: 200,
            numberDisplayed: 3,
            includeSelectAllOption: true
        }
	};



    function init(opts,fns){
        opts.fns = fns
        $opts =  fns.setDefaults(opts, _optsDefaults);
        getPlanos()
        
    }

    function getPlanos(){
        $opts.fns.request('convenio/getPlanos',``,(data)=>{
            data= JSON.parse(data)
            $opts.planos = data
        })
    }

    function createRow(target,selected=false){
        let base2 = `
        <select multiple>
            ${$opts.planos.map((ele,key)=>{
                let option = `<option value='${ele.id}'>${ele.NomeConvenio}</option>`
                return option
            })}
        </select>
        `
        $(`#${target} .convenioBtn`).append(base2)
        let select      =  $(`#${target} .convenioBtn select`)
        select.multiselect($opts.config);
    }

    function saveModal(id){
       let selecionados = $(`.modalConvenio${id} tr input:checkbox:checked`)
       let valores = []
       selecionados.map((key,ele)=>{
            valores.push($(ele).val())
       })
       valoresFinal = valores.join(',')

       $('#planos'+id).val(valoresFinal)
      
       $(`#convenio${id}`).modal('hide')
       $(`.btn.btn-block[data-target="#convenio${id}"] span`).html('('+valores.length+')')

       manageBtnPlano(id,valoresFinal)
    }

    function manageBtnPlano(id,valor){
        $(`.btnPlanos${id}`).attr('data-valores',valor)
        if(valor.length > 0){
            $(`.btnPlanos${id}`).show()
        }else{
            $(`.btnPlanos${id}`).hide()
        }
    }
    
    /**
     * Funções externadas
     */
    return {
        init                : init,
        getPlanos           : getPlanos,
        createRow           : createRow,
        saveModal           : saveModal
    };
}() 


/*  componente de modal

let base = ` 
        <input id='planos${$opts.last}' type="text" hidden value=''>
        <button class='btn btn-block' data-toggle="modal" data-target="#convenio${$opts.last}"><span></span> Convenios</button>
        <!-- Modal -->
        <div class="modal fade modalConvenio modalConvenio${$opts.last}" id="convenio${$opts.last}" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h4 class="modal-title" id="myModalLabel">Planos de saúde</h4>
                </div>
                <div class="modal-body">
                    <input type='text' class='modalFilter modalConvenio${$opts.last}'>
                    <table>
                        <thead>    
                            <tr class="primary">      
                            <th width="150">${$opts.campo1}</th>      
                            <th colspan="2">${$opts.campo2}</th>    
                            </tr>  
                        </thead>
                        <tbody>
                        ${$opts.planos.map((ele,key)=>{
                            let obj = `<tr> 
                                        <td><code># ${key+1}</code></td>
                                        <td>${ele.NomeConvenio}</td>  
                                        <td width="60">    
                                            <div class="checkbox-custom checkbox-primary">      
                                                <input`
                                                selected.filter((selecionado)=>{
                                                    if(ele.id == selecionado){
                                                        obj += ' checked '
                                                    }
                                                })

                            obj += ` type="checkbox" name="unidade[]" class="qfMultiple" id="unidade_${ele.id}" value="${ele.id}">      
                                                <label for="unidade_${ele.id}" class="checkbox"></label>    
                                            </div>  
                                        </td>
                                    </tr>`
                            return obj
                        }).join('')}
                        </tbody>
                    <table>
                </table>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" onClick='convenioBtn.saveModal(${$opts.last})' >Save changes</button>
                </div>
                </div>
            </div>
        </div>`


        */