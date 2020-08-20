/* ----------------------------------------------------------------------------------------------------------------------
	JS MEDICAMENTOS
---------------------------------------------------------------------------------------------------------------------- */

var medicamentosConvenio  = function(){

    var $opts = {};
	var _optsDefaults = {
        'seletor'                       :  '',
        'medicamentos'                  :  [],
        'convenios'                     :  [],
        'modal'                         :  false,
        'fns'                           :  {},
        'conveniosSelecionados'         : [],
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
        $opts = fns.utilitarios.setDefaults(opts, _optsDefaults);
        getMedicamentos()
        getConvenios()
    }

    function getMedicamentos(){
        $opts.fns.utilitarios.request('convenio/getMedicamento','',(data)=>{
            data = JSON.parse(data)
            $opts.medicamentos = data
        })
    }
    function getPlano(convenio,callback){
        $opts.fns.utilitarios.request('convenio/getPlanos',`convenio=${convenio}`,(data)=>{
            data= JSON.parse(data)
            if(data.length > 0){
                callback(data)
            }else{
                callback(false)
            }
        })
    }

    function getConvenios(){
        $opts.fns.utilitarios.request('convenio/getConvenios',``,(data)=>{
            data= JSON.parse(data)
            $opts.convenios = data
        })
    }

    function addModal(status=false,selecionados=false){
        let modal =`
        <div class="modal fade" id="modalMedicamentoConvenio" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
          <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
              <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="myModalLabel"><span id='action'>Criar</span> cadastro</h4>
              </div>
              <div class="modal-body">
                <div class='row'>
                    <div class='col-md-6'>
                        <label class="col-md-12 control-label">Medicamento Prescrito</label>
                        <select class="form-control col-md-12 prescrito">
                            <option>Selecione o medicamento prescrito</option>
                            ${$opts.medicamentos.map((ele)=>{
                                return `<option value='${ele.id}'>${ele.NomeProduto}</option>`
                            })}
                        </select>
                    </div>
                    <div class='col-md-6'>
                        <label class="col-md-12 control-label">Medicamento Referência (Convênio)</label>
                        <select class="form-control col-md-12 referencia">
                        <option>Selecione o medicamento referência</option>
                        ${$opts.medicamentos.map((ele)=>{
                            return `<option value='${ele.id}'>${ele.NomeProduto}</option>`
                        })}
                        </select>
                    </div>
                </div>
                <div class='row mt30'>
                    <div class='col-md-6'>
                        <label class="col-md-12 control-label">Convênios</label>
                        <div class='convenioBtn'></div>
                    </div>
                    <div class='col-md-6'>
                        <label class="col-md-12 control-label clearText">P</label>
                        <div class='btn-area col-md-12'>
                            <button id='planos' class="btn btn-warning btn-block" style='display:none'><i class="fa fa-h-square"></i> Planos</button>
                        </div>
                    </div>
                </div>
                <div id='planosSelect' style='display:none' class="container-fluid mt20">
                </div>
              </div>
              <div class="modal-footer">
                <button id='salvarModal' type="button" class="btn btn-success"><i class="fa fa-save"></i> Salvar</button>
              </div>
            </div>
          </div>
        </div>`

        $(`#${$opts.seletor}`).parent().append(modal)
        $('#salvarModal').click(event=>{
            salvarModal(event)
        })

        $('#modalMedicamentoConvenio').on('hide.bs.modal', function (e) {
            $('#modalMedicamentoConvenio').detach()
        })
    }

    function startBtn(){
        let base = `
        <select id='convenios' multiple>
            ${$opts.convenios.map((ele,key)=>{
                let option = `<option value='${ele.id}'>${ele.NomeConvenio}</option>`
                return option
            }).join('')}
        </select>`

        $(`#modalMedicamentoConvenio .convenioBtn`).append(base)
        let select      =  $('#convenios')
        select.multiselect($opts.config);

        $('#convenios').change((event)=>{
            let valor = $(event.target).val()
            planosBtn(valor)
        })
        $('#planos').click(()=>{
            planoSelects()
        })
    }

    function planosBtn(valor){
        $opts.conveniosSelecionados = valor
        if(valor.length>0){
            $('#planos').slideDown()
        }else{
            $('#planos').slideUp()
        }
    }

    function planoSelects(){
        let status = $('#planosSelect').css('display')
        if(status=='none'){
            $opts.conveniosSelecionados.map((convenio)=>{
                getPlano(convenio,(data)=>{
                    createNewSelect(convenio,data)
                })
            })
            $('#planosSelect').slideDown()
        }else{
            $('#planosSelect').slideUp()
        }
    }

    function createNewSelect (convenio,planos){
        let select =  `<select id='plano_${convenio}' multiple>
            ${planos.map((ele,key)=>{
                let option = `<option value='${ele.id}'>${ele.NomePlano}</option>`
                return option
            }).join('')}
        </select>`

        let convenioNome = ''
        $opts.convenios.filter(convenioObj=>{
            if(convenioObj.id == convenio){
                convenioNome = convenioObj.NomeConvenio
            }
        })

        let warper  =  `
            <div class='col-md-6'>
                <label class="col-md-12 control-label">${convenioNome}</label>
                ${select}
            </div>
        `
        $('#planosSelect').append(warper)
        let selectToTurn =  $(`#plano_${convenio}`)
        selectToTurn.multiselect($opts.config);
    }

    function modalMedicamentos(status,id=false){
   
        addModal()
        startBtn()

        $('#modalMedicamentoConvenio #action').html(status)
        let apagar = $('#linha_'+id).attr('data-id')
        $('#modalMedicamentoConvenio').attr('data-id',apagar)
        if(id){
            let prescrito = $('#linha_'+id).find('td[data-prescrito]').attr('data-prescrito')
            let referencia = $('#linha_'+id).find('td[data-referencia]').attr('data-referencia')
            let convenios = $('#linha_'+id).find('td[data-convenios]').attr('data-convenios').split(',')
            let conveniosName = $('#linha_'+id).find('td[data-convenios]').html()


            $('select.prescrito').val(prescrito)
            $('select.referencia').val(referencia)

            $('#convenios').parent().children('div').children().prop('title',conveniosName)
            // let options = $('#convenios').parent().children('div').children().children().detach()
            $('#convenios').parent().children('div').children('button').html(conveniosName+'<b class="caret"></b>')

            let selectToTurn =  $(`#convenios`)
            selectToTurn.multiselect($opts.config);


            convenios.map(convenio=>{
                $('#convenios option[value=' + convenio + ']').attr('selected', true);
                $('#convenios').parent().children('div').find('input[value="'+convenio+'"]').parent().parent().parent().addClass('active')
                $(`input[value="${convenio}"]`).prop('checked',true)

                getPlano(convenio,(data)=>{
                    if(data){
                        createNewSelect(convenio,data)
                        $('#planos').slideDown()
                        $('#planosSelect').slideDown()
                    }
                })
            })
        }
        $('#modalMedicamentoConvenio').modal('toggle')
    }

    function salvarModal(){
        let action = $('#action').html()
        let prescrito = $('select.prescrito').val()
        let referencia = $('select.referencia').val()
        let convenios = $('#convenios').val()
        let obj = []

        convenios.map(convenio=>{
            let planos = $('#plano_'+convenio).val()
            obj.push({convenio,planos})
        })

        convenios = obj
        
        if(action == 'Editar'){
            let id = $('#modalMedicamentoConvenio').attr('data-id')
            remove(id)
        }


        convenios.map(convenio=>{
            let params = `prescrito=${prescrito}&referencia=${referencia}&convenio=${convenio.convenio}&plano=`
    
            if(convenio.planos){
                convenio.planos.map((plano,key)=>{
                    params += plano
                    send(params)
                })
            }else{
                send(params)
            }
        })

        $('#modalMedicamentoConvenio').modal('hide')
        new PNotify({
            title: 'Medicamento cadastrado com sucesso',
            type: 'success',
            delay: 1500
        });
        $opts.fns.loadInfos()
    }

    function send(params){
        $opts.fns.utilitarios.request('convenio/saveMedicamentosConvenio',params,(data)=>{
            return data
        })
    }

    function remove(ids){
        $opts.fns.utilitarios.request('convenio/removeMedicamentosConvenio','ids='+ids,(data)=>{
            return data
        })
    }

    /**
     * Funções externadas
     */
    return {
        init                : init,
        modalMedicamentos   : modalMedicamentos
    };
}() 