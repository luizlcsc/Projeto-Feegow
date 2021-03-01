/* ----------------------------------------------------------------------------------------------------------------------
	JS PARA CARREGAR O SELECT
---------------------------------------------------------------------------------------------------------------------- */

var filterProfissionais = function(){
    var $opts = {};
	var _optsDefaults = {
        'seletor'			:   '',
        'title'             :   '', 
        'name'              :   '', 
        'value'             :   '', 
        'filterOn'          :   0, 
        'requestTo'         :   'consulta/getProfissionais', 
        'fns'               :   null
	};

    function init(opts,fns){
        opts.fns = fns
        $opts = fns.setDefaults(opts, _optsDefaults);


        let css = `<style>
            ul.dropdown-ajaxfilter {
                position: absolute;
                background-color: #ececec;
                width: 94%;
                padding: 10px;
                z-index: 10;
                list-style: none;
                border: 1px solid #d4d4d4;
                border-top: none;
            }
            ul.dropdown-ajaxfilter li {
                cursor: pointer;
                padding: 10px 0;
            }
        </style>`
        let label = `<label>${$opts.title}</label>`
        let input = `<input type="text" class="form-control " name="${$opts.name}" id="${$opts.name}" value="${$opts.value}" />`
        let html = css + label + '</br>' + input
        $(`#${$opts.seletor}`).append(html)

        $(`#${$opts.name}`).keyup((event)=>{
            let valor = $(event.target).val()
            if(valor.length >= $opts.filterOn){
                let parametros = `nome=${valor}`
                $opts.fns.request($opts.requestTo,parametros,populate)
            }
        })
    }



    function populate(data){
        data = JSON.parse(data)
        if(data.length>0){

            removeDropdown()
            let html = `<ul class="dropdown-ajaxfilter">`
            data.map((elem)=>{
                html+= `<li data-id='${elem.idIntegracao}'>${elem.nome}</li>`
            })
            html += `</ul>`
            $(`#${$opts.seletor}`).append(html)
            $(document).on("click", function(event){
                if(!$(event.target).closest(`#${$opts.seletor} li`).length){
                    removeDropdown()
                }
            });
            $(`#${$opts.seletor} li`).click((event)=>{
                let valorClicado = $(event.target).html()
                $(`#${$opts.name}`).val(valorClicado)
                removeDropdown()
            })
        }
    }
    function removeDropdown (){
        $(`#${$opts.seletor} .dropdown-ajaxfilter`).detach()
    }
    /**
     * Funções externadas
     */
    return {
        init                : init,
    };

    //uso <div id='qfProfissionais2' class='col-md-3 ajaxFilter' data-label='Profissionais'></div>
}()