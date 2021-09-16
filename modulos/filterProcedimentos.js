/* ----------------------------------------------------------------------------------------------------------------------
	JS PARA CARREGAR O SELECT
---------------------------------------------------------------------------------------------------------------------- */

var filterProcedimentos = function(){
    var $opts = {};
	var _optsDefaults = {
        'seletor'			:   '',
        'title'             :   '', 
        'name'              :   '', 
        'value'             :   '', 
        'result'            :   '', 
        'filterOn'          :   0, 
        'requestTo'         :   'consulta/getProcedimentos', 
        'tabelaId'          :   '',
        'franquia'          :   '',
        'place'             :   'Busque procedimento pelo nome',
        'data'              :   [],
        'fns'               :   null,
        'allowChange'       :   1,
        'allowRequestChange':   0
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
        let input = `<input type="text" class="form-control " name="${$opts.name}" id="${$opts.name}" value="${$opts.value}" placeholder="Busque procedimento pelo nome" />`
        let html = css + label + '</br>' + input
        $(`#${$opts.seletor}`).append(html)

        $(`#${$opts.name}`).keyup((event)=>{
            let valor = $(event.target).val()
            if(valor.length >= $opts.filterOn){
                let parametros = `nome=${valor}&tabelaId=${$opts.tabelaId}&tipo=${$opts.tipo}`
                $opts.fns.request($opts.requestTo,parametros,populate)
            }
        })
    }



    function populate(data){
        data = JSON.parse(data)
        console.log(data)
        $opts.data = data
        if(data.length>0){

            removeDropdown()
            let html = `<ul class="dropdown-ajaxfilter">`
            data.map((elem)=>{
                html+= `<li data-id='${elem.id}'>${elem.NomeProcedimento}</li>`
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
                let id = $(event.target).attr('data-id')
                let linhas  =  $(`#${$opts.result} tr`)
                $opts.data.map((elem)=>{
                    if(elem.id == id){
                        let jaTem = linhas.filter((key,linha)=>{
                            let id = $(linha).attr('data-id')
                            if(id == elem.id){
                                return true
                            }
                            return false
                        })
                        if(jaTem.length ==0){
                            addRow(elem)
                        }else{
                            focusTo(elem)
                        }
                    }
                })
                removeDropdown()
            })
        }
    }


    function addRow(linha, focus=true){
        let $input = `<div class="input-group">
                        <span class="input-group-addon">
                            <strong>R$</strong>
                        </span>
                        <input id="ValorTabela${linha.id}" class="form-control input-mask-brl " type="text" style="text-align:right" name="ValorTabela${linha.id}" value="${fixMoney(linha.ValorTabela)}" onchange="changeValorTabela(this,'${linha.id}','${linha.TabelaID}','Valor')">
                    </div>`;
        let classeTr = "";
        let ValorBase = fixMoney(linha.Valor);

        if(linha.PermiteAlteracao == 0){
            ValorBase = "";
            linha.titulo = "Alteração de valor não permitida pela unidade";
            classeTr = "tr-disabled";
            $input = `<i>Padrão</i> 
            <input id="ValorTabela${linha.id}" type="hidden" style="text-align:right" name="ValorTabela${linha.id}" value="${fixMoney(linha.ValorTabela)}" >
            `;
        }

        if($opts.allowChange == 0){
            $input = `<i>${linha.ValorTabela}</i> 
            <input class="linha-valor-tabela" id="ValorTabela${linha.id}" type="hidden" style="text-align:right" name="ValorTabela${linha.id}" value="${fixMoney(linha.ValorTabela)}" >
            `;
        }

        let tdRequestChange = ``;

        if($opts.allowRequestChange == 1){
            tdRequestChange = `<td class="text-right">
                <input style="display: none;" class="solicitar-alteracao-ipt text-right form-control input-sm" placeholder="Digite..." value="${fixMoney(linha.ValorTabela)}"/>

                <button onclick="proporValorProcedimento('${linha.id}')" class="solicitar-alteracao-btn btn btn-xs btn-default" type="button" title="Solicitar alteração de valor">
                    <i class="fa fa-edit"></i>
                </button>
            </td>`;
        }

        let base = `
            <tr title="${linha.titulo}" data-id="${linha.id}" data-name="${linha.NomeProcedimento.toUpperCase()}" class="${classeTr} linha-procedimento">
                <td class="hidden hidden-print"><input type="checkbox" class="chk" name="chk${linha.id}" /></td>
                <td><span class="linha-nome-procedimento">${linha.NomeProcedimento}</span></td>
                <td class="text-right">${linha.TipoProcedimento}</td>
                <td class="text-right"  width="100">${ValorBase}</td>
                <td class="text-right hidden" width="150">
                    <div class="input-group">
                        <span class="input-group-addon">
                            <strong>R$</strong>
                        </span>
                        <input id="RecebimentoParcial_${linha.id}" class="form-control input-mask-brl " type="text" style="text-align:right" name="RecebimentoParcial_${linha.id}" value="${fixMoney(linha.RecebimentoParcial)}" onchange="changeValorTabela(this,'${linha.id}','${linha.TabelaID}','RecebimentoParcial')">
                    </div>
                </td>
                <td class="text-right" width="150">
                    ${$input}
                </td>
                ${tdRequestChange}
            </tr>
        `
        $(`#${$opts.result}`).prepend(base)
        if(focus){
            focusTo(linha)
        }
        $(`#${$opts.result} input`).maskMoney({prefix:'', thousands:'.', decimal:',', affixesStay: true});
    }

    function focusTo(linha){
        scrollTo(`ValorTabela${linha.id}`)
        $(`#${$opts.result} tr[data-id=${linha.id}] input[id^="ValorTabela"]`).focus()
    }

    function scrollTo(id){
        $([document.documentElement, document.body]).animate({
            scrollTop: $(`#${id}`).offset().top
        }, 2000)
    }

    function fixMoney (valor){
        if(!valor){
            return "";
        }

        if(valor.indexOf(',') > 0){
            if((valor.split(',')[1]).length == 1){
                return valor + '0'
            }
        }else{
            return valor + ',00'
        }
        return valor
    }
    function removeDropdown (){
        $(`#${$opts.seletor} .dropdown-ajaxfilter`).detach()
    }
    /**
     * Funções externadas
     */
    return {
        init                : init,
        addRow              : addRow
    };

    //uso <div id='nqfProcedimentos' class='col-md-3 ajaxFilter'></div>
}()